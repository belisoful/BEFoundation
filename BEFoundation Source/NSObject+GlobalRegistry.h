/*!
 @header		NSObject+GlobalRegistry.h
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		A category extension for NSObject that provides global object registration and tracking capabilities.
 @discussion	This category extends NSObject with methods for registering and tracking object instances
 in a global registry. It provides a centralized way to manage object lifecycles and maintain
 references to objects across the application.
 
 The implementation uses a singleton BEObjectRegistry instance that is thread-safe and provides
 UUID-based tracking for registered objects. Objects can be registered, unregistered, and queried
 for their registration status with reference counting support.
 
 Key features:
 - Thread-safe singleton registry access
 - UUID-based object identification
 - Registration reference counting
 - Automatic cleanup capabilities
 - Universal object support (any NSObject subclass)
 */

#ifndef NSObject_GlobalRegistry_h
#define NSObject_GlobalRegistry_h

#import <Foundation/Foundation.h>
#import "BEObjectRegistry.h"

/*!
 @category NSObject(BEGlobalRegistry)
 @abstract A category that extends NSObject with global registry capabilities.
 @discussion This category provides a unified interface for registering and managing object instances
 in a global registry. It offers both class-level registry access and instance-level registration methods.
 
 The registry is implemented as a thread-safe singleton that persists for the lifetime of the application.
 Objects can be registered multiple times and maintain reference counts, with UUID-based identification
 for tracking purposes.
 
 All methods are designed to be safe for concurrent access and handle edge cases gracefully.
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
 @method registerGlobalInstance
 @abstract Registers this object instance in the global registry.
 @return A UUID string that uniquely identifies this registration, or nil if registration failed.
 @discussion This method registers the receiver in the global registry and returns a UUID
 that can be used to identify this specific registration. If the object is already registered,
 this increments its reference count and returns the existing UUID.
 
 The returned UUID remains valid until the object is fully unregistered (reference count reaches zero).
 Multiple registrations of the same object will return the same UUID but increment the internal
 reference count.
 
 @note This method is thread-safe and can be called from any queue.
 @note The object will be weakly referenced by the registry to prevent retain cycles.
 
 Example usage:
 @code
 NSString *uuid = [myObject registerGlobalInstance];
 if (uuid) {
	 NSLog(@"Object registered with UUID: %@", uuid);
 }
 @endcode
 */
- (NSString * _Nullable)registerGlobalInstance;

/*!
 @method unregisterGlobalInstance
 @abstract Unregisters this object instance from the global registry.
 @return An integer indicating the unregistration result: 0 = not registered, 1 = decremented count, 2 = fully unregistered.
 @discussion This method decrements the reference count for this object in the global registry.
 The return value indicates the specific outcome:
 - 0: The object was not registered in the first place
 - 1: The object's reference count was decremented but is still > 0
 - 2: The object was fully unregistered (reference count reached 0)
 
 @note This method is thread-safe and can be called from any queue.
 @note Objects are automatically cleaned up when deallocated, so manual unregistration is optional.
 
 Example usage:
 @code
 int result = [myObject unregisterGlobalInstance];
 switch (result) {
	 case 0: NSLog(@"Object was not registered"); break;
	 case 1: NSLog(@"Object count decremented"); break;
	 case 2: NSLog(@"Object fully unregistered"); break;
 }
 @endcode
 */
- (int)unregisterGlobalInstance;

@end

#endif // NSObject_GlobalRegistry_h
