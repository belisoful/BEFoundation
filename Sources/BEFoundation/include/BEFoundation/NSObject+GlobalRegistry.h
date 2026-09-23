/*!
 @header		NSObject+GlobalRegistry.h
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		A category extension for NSObject that provides global object registration and tracking capabilities.
 @discussion	This category registers and tracks object instances in a process-wide
 BEObjectRegistry singleton. Each registered object is identified by a UUID, registrations
 of one object are counted, and the registry holds objects weakly. Registering an object
 that does not conform to `BERegistryProtocol` raises `NSInvalidArgumentException`.
 */

#ifndef NSObject_GlobalRegistry_h
#define NSObject_GlobalRegistry_h

#import <Foundation/Foundation.h>
#import <BEFoundation/BEObjectRegistry.h>

/*!
 @category NSObject(BEGlobalRegistry)
 @abstract A category that extends NSObject with global registry capabilities.
 @discussion This category exposes the global registry as a class property and adds
 instance-level registration methods. The registry persists for the lifetime of the process.
 All methods are safe for concurrent access.

 Example usage:
 @code
 NSString *uuid = [myObject registerGlobalInstance];
 id sameObject = [NSObject.globalRegistry registeredObjectForUUID:uuid];
 [myObject unregisterGlobalInstance];
 @endcode
 */
@interface NSObject (BEGlobalRegistry)

#pragma mark - Class Properties

/*!
 @property globalRegistry
 @abstract The shared global registry instance for all objects.
 @discussion This class property provides access to the singleton BEObjectRegistry instance
 that manages all globally registered objects. The registry is created lazily on first access
 using thread-safe initialization patterns.
 
 The registry persists for the lifetime of the application and is shared across all object instances.
 It provides methods for registering, unregistering, and querying objects.
 
 @note This property is thread-safe and can be accessed from any queue.
 @see BEObjectRegistry
 */
@property (readonly, class, nonatomic, nonnull) BEObjectRegistry *globalRegistry;

#pragma mark - Instance Methods

/*!
 @property globalRegistryUUID
 @abstract The receiver's UUID in the global registry.
 @discussion Reading assigns a UUID when the receiver has none, whether or not it is
 registered. Reads nil, and writes are ignored, for a receiver that does not conform to
 `BERegistryProtocol`. Writing replaces the UUID; an object that conforms to
 `CustomRegistryUUID` keeps its own. These four accessors implement the
 `BERegistryProtocol` properties for every NSObject.
 */
@property (nonatomic, nullable) NSString *globalRegistryUUID;

/*!
 @property globalRegistryCount
 @abstract How many times the receiver is registered in the global registry; 0 when it is
 not registered or does not conform to `BERegistryProtocol`.
 */
@property (readonly, nonatomic) NSUInteger globalRegistryCount;

/*!
 @property isGlobalRegistered
 @abstract YES when the receiver is registered in the global registry.
 */
@property (readonly, nonatomic) BOOL isGlobalRegistered;

/*!
 @method registerGlobalInstance
 @abstract Registers this object instance in the global registry.
 @return A UUID string that uniquely identifies this registration.
 @exception NSInvalidArgumentException Raised when the receiver does not conform to `BERegistryProtocol`.
 @discussion This method registers the receiver in the global registry and returns a UUID
 that can be used to identify this specific registration. If the object is already registered,
 this increments its reference count and returns the existing UUID.
 
 The returned UUID remains valid until the object is fully unregistered (reference count reaches zero).
 Repeated registrations of one object return the same UUID and increment the count.
 
 @note This method is thread-safe and can be called from any queue.
 @note The registry holds the object weakly.
 
 Example usage:
 @code
 NSString *uuid = [myObject registerGlobalInstance];
 NSLog(@"Object registered with UUID: %@", uuid);
 @endcode
 */
- (NSString * _Nullable)registerGlobalInstance;

/*!
 @method unregisterGlobalInstance
 @abstract Unregisters this object instance from the global registry.
 @return A BEUnregisterStatus value describing the outcome.
 @discussion This method decrements the reference count for this object in the global registry.
 The return value indicates the specific outcome:
 - BEUnregisterStatus_NotRegistered: The object was not registered in the first place
 - BEUnregisterStatus_Decremented: The object's reference count was decremented but is still > 0
 - BEUnregisterStatus_Unregistered: The object was fully unregistered (reference count reached 0)
 
 @note This method is thread-safe and can be called from any queue.
 @note Objects are automatically cleaned up when deallocated, so manual unregistration is optional.
 
 Example usage:
 @code
 BEUnregisterStatus result = [myObject unregisterGlobalInstance];
 switch (result) {
	 case BEUnregisterStatus_NotRegistered: NSLog(@"Object was not registered"); break;
	 case BEUnregisterStatus_Decremented: NSLog(@"Object count decremented"); break;
	 case BEUnregisterStatus_Unregistered: NSLog(@"Object fully unregistered"); break;
 }
 @endcode
 */
- (BEUnregisterStatus)unregisterGlobalInstance;

@end

#endif // NSObject_GlobalRegistry_h
