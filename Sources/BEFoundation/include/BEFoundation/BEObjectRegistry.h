/*!
 @header        BEObjectRegistry.h
 @copyright     -© 2025 Delicense - @belisoful. All rights released.
 @date          2025-01-01
 @author		belisoful@icloud.com
 @abstract      A thread-safe object registry system for managing object instances with UUID-based identification.
 @discussion    BEObjectRegistry provides a centralized system for registering and managing object instances using UUID-based identification. The registry maintains weak references to objects and provides thread-safe operations for registration, lookup, and management. Objects can be registered multiple times with reference counting, and the registry supports both automatic UUID generation and custom UUID provision through protocols.

The registry uses NSMapTable with weak references to avoid retain cycles, and provides management methods including bulk operations and protocol-based filtering. All operations are thread-safe.

Example usage:
```objc
BEObjectRegistry *registry = [[BEObjectRegistry alloc] init];
MyObject *obj = [[MyObject alloc] init];
NSString *uuid = [registry registerObject:obj];
// The registry holds obj weakly; retain it elsewhere or the lookup returns nil
MyObject *retrievedObj = [registry registeredObjectForUUID:uuid];
```
*/

#ifndef BEObjectRegistry_h
#define BEObjectRegistry_h

#import <Foundation/Foundation.h>

@class BEObjectRegistry;

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, BEUnregisterStatus) {
	BEUnregisterStatus_NotRegistered = 0,
	BEUnregisterStatus_DecrementedBit = (1 << 0),
	BEUnregisterStatus_UnregisteredBit = (1 << 1),
	BEUnregisterStatus_Decremented = BEUnregisterStatus_DecrementedBit,
	BEUnregisterStatus_Unregistered = BEUnregisterStatus_DecrementedBit | BEUnregisterStatus_UnregisteredBit
};

/*!
 @protocol      BERegistryProtocol
 @abstract      Protocol for objects that can be registered in a BEObjectRegistry.
 @discussion    Objects conforming to this protocol can be registered in the global registry system. The protocol provides read-only access to the object's registry state, including its UUID, registration count, and registration status. All properties are automatically managed by the registry system.
 
 The globalRegistryUUID property returns the UUID assigned to this object in the global registry, or nil if not registered. The globalRegistryCount indicates how many times this object has been registered (supports multiple registrations with reference counting). The isGlobalRegistered property provides a quick check for registration status.
 
 Objects can trigger registration and unregistration through the provided methods, which interact with the global registry instance.

Example usage:
```objc
// MyModel declares conformance to BERegistryProtocol.
MyModel *model = [[MyModel alloc] init];
NSString *uuid = [model registerGlobalInstance];
BOOL isRegistered = model.isGlobalRegistered; // YES
[model unregisterGlobalInstance];
```
 */
@protocol BERegistryProtocol <NSObject>

/*!
 @property      globalRegistryUUID
 @abstract      The UUID assigned to this object in the global registry.
 @discussion    Returns the UUID string assigned to this object in the global registry, generating and assigning one on first access if the object does not yet have one. Setting a value assigns a specific UUID (or nil to clear it); UUIDs are otherwise managed automatically by the registry system.
 */
@property (nonatomic, nullable) NSString *globalRegistryUUID;

/*!
 @property      globalRegistryCount
 @abstract      The number of times this object has been registered in the global registry.
 @discussion    Returns the registration count for this object in the global registry. Objects can be registered multiple times, and this count reflects the total number of active registrations. When the count reaches zero, the object is automatically removed from the registry.
 */
@property (readonly, nonatomic) NSUInteger globalRegistryCount;

/*!
 @property      isGlobalRegistered
 @abstract      Whether this object is currently registered in the global registry.
 @discussion    Returns YES if the object is currently registered in the global registry (registration count > 0), NO otherwise. This provides a quick way to check registration status without examining the count or UUID.
 */
@property (readonly, nonatomic) BOOL isGlobalRegistered;

/*!
 @method        registerGlobalInstance
 @abstract      Registers this object in the global registry.
 @discussion    Registers this object instance in the global registry, incrementing its registration count. If the object is not already registered, a new UUID is generated and assigned. The method never returns nil; a failure raises. The return type stays nullable for source compatibility.
 @result        The UUID assigned to this object in the global registry.
 @exception     NSInvalidArgumentException Thrown if the object doesn't conform to BERegistryProtocol.
 */
- (nullable NSString *)registerGlobalInstance;

/*!
 @method        unregisterGlobalInstance
 @abstract      Unregisters this object from the global registry.
 @discussion    Decrements the registration count for this object in the global registry. If the count reaches zero, the object is completely removed from the registry.
 @result        BEUnregisterStatus_Unregistered (3) if the object was completely removed, BEUnregisterStatus_Decremented (1) if a registration was removed but others remain, BEUnregisterStatus_NotRegistered (0) if it was not registered.
 */
- (BEUnregisterStatus)unregisterGlobalInstance;

@end



/*!
 @protocol      CustomRegistryUUID
 @abstract      Protocol for objects that provide custom UUID generation for registry purposes.
 @discussion    Objects conforming to this protocol supply their own UUID when registered in a BEObjectRegistry. Objects with a natural identifier, or that need one UUID across registries, adopt it.
 
 The registry calls objectRegistryUUID: when an object needs a UUID and has none. The method returns a string that is unique within the given registry.
 
 setRegistryUUID:forObject: leaves the UUID of a conforming object unchanged.

Example usage:
```objc
// Document conforms to CustomRegistryUUID and supplies a stable identifier:
//   - (NSString *)objectRegistryUUID:(BEObjectRegistry *)registry { return self.fileID; }
BEUniversalObjectRegistry *registry = BEUniversalObjectRegistry.new;
[registry registerObject:document]; // registered under document.fileID
```
 */
@protocol CustomRegistryUUID <NSObject>

/*!
 @method        objectRegistryUUID:
 @abstract      Provides a custom UUID for this object in the specified registry.
 @discussion    Called by the registry system when this object needs a UUID and doesn't already have one assigned. The implementation should return a unique string identifier for this object within the context of the given registry. The returned UUID must be unique within the registry to avoid conflicts. When this method returns nil, the registry generates a UUID and assigns it to the object.
 @param         registry The registry requesting the UUID.
 @result        A unique string identifier for this object, or nil if no UUID can be provided.
 */
- (nullable NSString *)objectRegistryUUID:(nonnull BEObjectRegistry *)registry;

@end



/*!
 @const         NSDuplicateUUIDException
 @abstract      Exception thrown when attempting to register an object with a UUID that's already in use.
 @discussion    This exception is raised when trying to set a UUID for an object that is already assigned to a different object in the registry. This prevents UUID conflicts and ensures registry integrity.
 */
extern NSExceptionName _Nonnull const NSDuplicateUUIDException;



/*!
 @class         BEObjectRegistry
 @abstract      A thread-safe registry for managing object instances with UUID-based identification.
 @discussion    BEObjectRegistry provides a centralized system for registering and managing object instances using UUID-based identification. The registry maintains weak references to objects to avoid retain cycles, and provides thread-safe operations for registration, lookup, and management.
 
 				The registry counts repeated registrations of one object and removes the object when the count reaches zero. Objects that conform to CustomRegistryUUID supply their own UUID. Bulk clear operations remove groups of objects at once. All operations are synchronized.
 				 
 				 Registries that share a keySalt share one UUID namespace; a different salt isolates a registry's UUIDs from the others.
				 
				 Objects are stored in an NSMapTable with weak values. Per-instance registration counts are stored as associated objects keyed by the registry, so they are released when a registered object deallocates.
 */
@interface BEObjectRegistry : NSObject
{
	/*!
	 @var           _requireRegistryProtocol
	 @abstract      Whether or not to require Objects to conform to BERegistryProtocol.
	 @discussion    For this `BEObjectRegistry`, this is YES.
	 */
	BOOL _requireRegistryProtocol;
	
	/*!
	 @var           registryTable
	 @abstract      Internal map table storing UUID-to-object mappings.
	 @discussion    NSMapTable with strong keys and (by default) weak values, so objects are
	                automatically removed when deallocated. BEStorageObjectRegistry overrides the
	                value option to strong memory.
	 */
	NSMapTable *registryTable;
}

/*!
 @property      keyOptions
 @abstract      Allows subclasses to determine the key Options for the NSMapTable registryTable .
 @discussion    The default is NSPointerFunctionsStrongMemory, but this allows for more options in subclasses.
 */
@property(class, readonly) NSPointerFunctionsOptions keyOptions;

/*!
 @property      valueOptions
 @abstract      Allows subclasses to determine the value Options for the NSMapTable registryTable .
 @discussion    The default is NSPointerFunctionsWeakMemory so the object can be released without being removed from the registry first, but this allows for more options in subclasses.
 */
@property(class, readonly) NSPointerFunctionsOptions valueOptions;

/*!
 @property      requireRegistryProtocol
 @abstract      Whether objects must conform to BERegistryProtocol to be registered.
 @discussion    When YES (default), only objects conforming to BERegistryProtocol can be registered. When NO, any NSObject can be registered. This property can be modified at runtime to change the registry's behavior.
 */
@property (nonatomic, assign) BOOL requireRegistryProtocol;

/*!
 @property      uuidKey
 @abstract      Internal key used for storing UUIDs in associated objects.
 @discussion    A void pointer used as a key for objc_setAssociatedObject/objc_getAssociatedObject calls. This key is generated based on the registry's salt and method selector to ensure uniqueness across different registry instances.
 */
@property (nonatomic, readonly, nonnull) void *uuidKey;

/*!
 @property      objectCountKey
 @abstract      Internal key used for storing object counts in associated objects.
 @discussion    A void pointer used as a key for objc_setAssociatedObject/objc_getAssociatedObject calls. This key is generated based on the registry's salt and method selector to ensure uniqueness across different registry instances.
 */
@property (nonatomic, readonly, nonnull) void *objectCountKey;

/*!
 @property      keySalt
 @abstract      Salt value used for generating unique internal keys.
 @discussion    A numeric salt value used in the generation of uuidKey and objectCountKey to ensure different registry instances use different keys. This prevents conflicts when multiple registries are used with the same objects.
 */
@property (nonatomic, readonly) NSUInteger keySalt;

/*!
 @property      registeredObjectsCount
 @abstract      The total number of objects currently registered in this registry.
 @discussion    Returns the count of unique objects currently registered in the registry. This count reflects unique objects, not total registrations (an object registered multiple times counts as one).
 @note          With the default weak value storage, NSMapTable does not promptly reap entries whose object has deallocated, so this count may transiently include not-yet-reaped slots of objects that were registered without being unregistered. Treat it as an upper bound until the table is next mutated.
 */
@property (nonatomic, readonly) NSUInteger registeredObjectsCount;

/*!
 @method        init
 @abstract      Initializes a new registry with default settings.
 @discussion    Creates a new BEObjectRegistry with default settings: requireRegistryProtocol is YES, and keySalt is 0. The registry is immediately ready for use.
 @result        A new BEObjectRegistry instance.
 */
- (instancetype)init;

/*!
 @method        initWithKeySalt:
 @abstract      Initializes a new registry with a specific salt value.
 @discussion    Creates a new BEObjectRegistry with the specified salt value. The salt is used to generate unique internal keys, allowing multiple registry instances to safely operate on the same objects without conflicts.
 @param         salt The salt value to use for key generation.
 @result        A new BEObjectRegistry instance, or nil if initialization fails.
 */
- (nullable instancetype)initWithKeySalt:(NSUInteger)salt;

/*!
 @method        registryUUIDForObject:
 @abstract      Gets or generates a UUID for the specified object.
 @discussion    Returns the UUID for the specified object, generating a new one if necessary. If the object conforms to CustomRegistryUUID, that protocol method is called to generate the UUID. Otherwise, a new UUID is generated and stored.
 
 If requireRegistryProtocol is YES, the object must conform to BERegistryProtocol or nil is returned.
 @param         object The object to get a UUID for.
 @result        The UUID for the object, or nil if the object is invalid or doesn't meet protocol requirements.
 */
- (nullable NSString *)registryUUIDForObject:(nonnull id)object;

/*!
 @method        setRegistryUUID:forObject:
 @abstract      Sets a specific UUID for an object.
 @discussion    Assigns a specific UUID to an object. If the object already has a UUID, it is updated in the registry. If the UUID is already in use by another object, an exception is thrown.

 Objects conforming to CustomRegistryUUID cannot have their UUIDs set through this method, as they manage their own identifiers.

 The UUID is stored on the object under uuidKey, which is derived from keySalt, so registries sharing a keySalt share the object's UUID. This method re-keys the receiver's table only; another registry with the same keySalt keeps its entry under the prior UUID until it unregisters the object. Registries that assign UUIDs to the same objects must use distinct keySalt values.
 @param         uuid The UUID to assign, or nil to remove the UUID.
 @param         object The object to assign the UUID to.
 @exception     NSInvalidArgumentException Thrown if the object doesn't conform to required protocols or if the UUID is invalid.
 @exception     NSDuplicateUUIDException Thrown if the UUID is already in use by another object.
 */
- (void)setRegistryUUID:(nullable NSString *)uuid forObject:(nonnull id)object;

/*!
 @method        countForObject:
 @abstract      Returns the total registration count for a specific object across registries sharing this registry's keySalt.
 @discussion    Returns the number of times the specified object has been registered across all registries created with the same keySalt. The count is stored on the object under objectCountKey, which is derived from the keySalt, so registries with different salts maintain independent counts.
 @param         object The object to check.
 @result        The registration count for the object across all registries sharing this registry's keySalt, or 0 if not registered.
 */
- (NSUInteger)countForObject:(nonnull id)object;

/*!
 @method        registeredCountForObject:
 @abstract      Returns the active registration count for a specific object.
 @discussion    Returns the number of active registrations for the specified object in this registry instance: how many times the object has been registered minus how many times it has been unregistered. The count is stored as an associated object on the registered object, keyed by the registry, and is released automatically when the object deallocates.
 @param         object The object to check.
 @result        The active registration count for the object, or 0 if not registered.
 */
- (NSUInteger)registeredCountForObject:(nonnull id)object;

/*!
 @method        registerObject:
 @abstract      Registers an object in the registry.
 @discussion    Registers the specified object in the registry, incrementing its registration count. If the object doesn't already have a UUID, one is generated. The object is added to the registry table if not already present.
 
 Objects can be registered multiple times, with the registry maintaining a count of active registrations.
 @param         object The object to register.
 @result        The UUID assigned to the object. The method never returns nil; a failure raises. The return type stays nullable for source compatibility.
 @exception     NSInvalidArgumentException Thrown if the object is nil or doesn't conform to required protocols.
 @exception     NSDuplicateUUIDException Thrown if the object's UUID conflicts with another object.
 */
- (nullable NSString *)registerObject:(nonnull id)object;

/*!
 @method        isObjectRegistered:
 @abstract      Checks if an object is currently registered.
 @discussion    Returns YES if the specified object is currently registered in the registry (registration count > 0), NO otherwise.
 @param         object The object to check.
 @result        YES if the object is registered, NO otherwise.
 */
- (BOOL)isObjectRegistered:(nonnull id)object;

/*!
 @method        registeredObjectForUUID:
 @abstract      Retrieves an object by its UUID.
 @discussion    Returns the object associated with the specified UUID, or nil if no object is found. Since the registry uses weak references, the returned object may be nil if the original object has been deallocated.
 @param         uuid The UUID to look up.
 @result        The object associated with the UUID, or nil if not found.
 */
- (nullable id)registeredObjectForUUID:(nonnull NSString *)uuid;

/*!
 @method        allRegisteredObjects
 @abstract      Returns all currently registered objects as a dictionary.
 @discussion    Returns a dictionary containing all currently registered objects, with UUIDs as keys and objects as values. The dictionary is a snapshot of the current registry state.
 @result        A dictionary of UUID-to-object mappings for all registered objects.
 */
- (nonnull NSDictionary *)allRegisteredObjects;

/*!
 @method        allRegisteredObjectUUIDs
 @abstract      Returns all currently registered UUIDs as an array.
 @discussion    Returns an array containing all UUIDs of currently registered objects. The array is a snapshot of the current registry state.
 @result        An array of UUID strings for all registered objects.
 */
- (nonnull NSArray *)allRegisteredObjectUUIDs;

/*!
 @method        unregisterObject:
 @abstract      Unregisters an object from the registry.
 @discussion    Decrements the registration count for the specified object. If the count reaches zero, the object is completely removed from the registry. The entry is located by the object's current UUID, or by object identity when another registry sharing this keySalt changed the UUID after registration, so no entry remains in either case.
 @param         object The object to unregister.
 @result        BEUnregisterStatus_Unregistered (3) if the object was completely removed, BEUnregisterStatus_Decremented (1) if unregistered but still has remaining registrations, BEUnregisterStatus_NotRegistered (0) if the object was not registered.
 */
- (BEUnregisterStatus)unregisterObject:(nonnull id)object;

/*!
 @method        unregisterObjectByUUID:
 @abstract      Unregisters an object by its UUID.
 @discussion    Decrements the registration count for the object with the specified UUID. If the count reaches zero, the object is completely removed from the registry.
 @param         uuid The UUID of the object to unregister.
 @result        BEUnregisterStatus_Unregistered (3) if the object was completely removed, BEUnregisterStatus_Decremented (1) if unregistered but still has remaining registrations, BEUnregisterStatus_NotRegistered (0) if the UUID was not found.
 */
- (BEUnregisterStatus)unregisterObjectByUUID:(nonnull NSString *)uuid;

/*!
 @method        clearObjectsWithoutRegistryProtocol
 @abstract      Removes all objects that don't conform to BERegistryProtocol.
 @discussion    Removes all registered objects that don't conform to BERegistryProtocol from the registry. Such objects can only be registered while requireRegistryProtocol is NO. Object UUIDs are preserved.
 */
- (void)clearObjectsWithoutRegistryProtocol;

/*!
 @method        clearObjectsWithoutRegistryProtocol:
 @abstract      Removes all objects that don't conform to BERegistryProtocol, optionally clearing UUIDs.
 @discussion    Removes all registered objects that don't conform to BERegistryProtocol from the registry. If clearObjectUUIDs is YES, the UUIDs stored in the objects are also cleared.
 @param         clearObjectUUIDs Whether to clear the UUID stored in each object when the object registry count reaches zero
 */
- (void)clearObjectsWithoutRegistryProtocol:(BOOL)clearObjectUUIDs;

/*!
 @method        clearObject:
 @abstract      Completely removes an object from the registry.
 @discussion    Completely removes the specified object from the registry, regardless of its registration count. All registrations for the object are cleared.
 @param         object The object to remove.
 @result        YES if the object was removed, NO if it wasn't registered.
 */
- (BOOL)clearObject:(nonnull id)object;

/*!
 @method        clearObjectByUUID:
 @abstract      Completely removes an object by its UUID.
 @discussion    Completely removes the object with the specified UUID from the registry, regardless of its registration count. All registrations for the object are cleared.
 @param         uuid The UUID of the object to remove.
 @result        YES if the object was removed, NO if the UUID wasn't found.
 */
- (BOOL)clearObjectByUUID:(nonnull NSString *)uuid;

/*!
 @method        clearAllRegisteredObjects
 @abstract      Removes all objects from the registry.
 @discussion    Removes all objects from the registry, clearing all registrations and counts. Object UUIDs are preserved.
 */
- (void)clearAllRegisteredObjects;

/*!
 @method        clearAllRegisteredObjects:
 @abstract      Removes all objects from the registry, optionally clearing UUIDs.
 @discussion    Removes all objects from the registry, clearing all registrations and counts. If clearUUIDs is YES, the UUIDs stored in the objects are also cleared.
 @param         clearUUIDs Whether to clear the UUID stored in each object when the object count reaches zero
 */
- (void)clearAllRegisteredObjects:(BOOL)clearUUIDs;

@end

/*!
 @class         BEUniversalObjectRegistry
 @abstract      A registry that accepts any NSObject instance regardless of protocol conformance.
 @discussion    BEUniversalObjectRegistry is a subclass of BEObjectRegistry that registers any NSObject instance; BERegistryProtocol conformance is not required. Setting requireRegistryProtocol to YES restores the requirement. UUID generation, CustomRegistryUUID support, registration counting, and salt-keyed namespaces are inherited from BEObjectRegistry.
 
				Example usage:
				```objc
				BEUniversalObjectRegistry *registry = [[BEUniversalObjectRegistry alloc] init];
				NSString *myString = @"Hello World";
				NSString *uuid = [registry registerObject:myString];
				NSString *retrievedString = [registry registeredObjectForUUID:uuid];
				```
 
				The registry holds objects weakly. An object retained nowhere else deallocates and leaves the registry.
 
 @see           BEObjectRegistry
 @see           BEStorageObjectRegistry
 @since         1.0
 */
@interface BEUniversalObjectRegistry : BEObjectRegistry

/*!
 @method        init
 @abstract      Initializes a new universal object registry with default settings.
 @discussion    Creates a new BEUniversalObjectRegistry with requireRegistryProtocol set to NO, allowing any NSObject to be registered. The registry uses a default salt value of 0 and is immediately ready for use.
 
				The registry accepts any NSObject instance. Set requireRegistryProtocol to YES to require BERegistryProtocol conformance.
 
 @result        A new BEUniversalObjectRegistry instance.
 @see           BEObjectRegistry#init
 @since         1.0
 */
- (instancetype)init;

@end



/*!
 @class         BEStorageObjectRegistry
 @abstract      A registry that maintains strong references to registered objects for persistent storage.
 @discussion    BEStorageObjectRegistry is a subclass of BEUniversalObjectRegistry that stores strong references to its values. A registered object stays alive until it is unregistered or the registry is cleared. Use it for caches, object pools, and objects that have no other strong reference.
 
				The registry never releases an object on its own. Unregister objects, or call clearAllRegisteredObjects:, to free them.
 
				Example usage:
				```objc
				BEStorageObjectRegistry *registry = [[BEStorageObjectRegistry alloc] init];
				NSMutableArray *data = [NSMutableArray arrayWithObjects:@"item1", @"item2", nil];
				NSString *uuid = [registry registerObject:data];
				data = nil; // Object is still retained by registry
				NSMutableArray *retrievedData = [registry registeredObjectForUUID:uuid];
				// retrievedData is still valid and contains the original data
				```
 
 @see           BEUniversalObjectRegistry
 @see           BEObjectRegistry
 @since         1.0
 */
@interface BEStorageObjectRegistry : BEUniversalObjectRegistry

/*!
 @method        valueOptions
 @abstract      Returns the pointer functions options used for values in the internal map table.
 @discussion    Overrides the parent class implementation to return NSPointerFunctionsStrongMemory instead of NSPointerFunctionsWeakMemory. This ensures that the registry maintains strong references to all registered objects, preventing them from being deallocated while registered.
 
				This method is called during initialization to configure the NSMapTable used for internal storage. The strong memory option ensures object persistence at the cost of requiring explicit memory management.
 
 @result        NSPointerFunctionsStrongMemory to maintain strong references to registered objects.
 @see           BEObjectRegistry#valueOptions
 @see           BEObjectRegistry#keyOptions
 @since         1.0
 */
+ (NSPointerFunctionsOptions)valueOptions;

@end


NS_ASSUME_NONNULL_END

#endif // BEObjectRegistry_h
