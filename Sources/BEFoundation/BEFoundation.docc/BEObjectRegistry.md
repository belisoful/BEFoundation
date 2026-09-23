# ``BEObjectRegistry``

A thread-safe registry for managing object instances with UUID-based identification.

```objc
#import <BEFoundation/BEObjectRegistry.h>
```

## Overview

[BEObjectRegistry](doc:BEObjectRegistry) provides a centralized system for registering and managing object instances using UUID-based identification. The registry maintains weak references to objects and provides thread-safe operations for registration, lookup, and management.

Key features:
- Thread-safe operations using synchronized blocks
- Weak reference storage to prevent retain cycles
- Reference counting for multiple registrations of the same object
- Support for custom UUID generation through protocols
- Bulk operations for registry management
- Salt-keyed UUID namespaces that isolate registries from one another

## Contents

- Registry classes: `BEObjectRegistry`, `BEUniversalObjectRegistry`, `BEStorageObjectRegistry`
- Protocols: `BERegistryProtocol`, `CustomRegistryUUID`
- Constants: `BEUnregisterStatus`

## Usage

### Basic Registration

Create a registry and register objects with auto-generated UUIDs:

```objc
BEObjectRegistry *registry = [[BEObjectRegistry alloc] init];
MyObject *obj = [[MyObject alloc] init];
NSString *uuid = [registry registerObject:obj];
// Later retrieve the object
MyObject *retrievedObj = [registry registeredObjectForUUID:uuid];
```

### Using the Registry Protocol

Objects conforming to [BERegistryProtocol](doc:BEObjectRegistry) can register themselves:

```objc
@interface MyObject : NSObject <BERegistryProtocol>
@end

@implementation MyObject
@end

// In some code
MyObject *obj = [[MyObject alloc] init];
NSString *uuid = [obj registerGlobalInstance];
```

### Custom UUIDs

Objects can provide their own UUIDs by conforming to [CustomRegistryUUID](doc:BEObjectRegistry):

```objc
@interface MyObject : NSObject <BERegistryProtocol, CustomRegistryUUID>
@end

@implementation MyObject {
    NSString *_stableUUID;
}
- (NSString *)objectRegistryUUID:(BEObjectRegistry *)registry {
    if (!_stableUUID) {
        _stableUUID = [[NSUUID UUID] UUIDString];
    }
    return _stableUUID;  // the same value on every call
}
@end
```

### Reference Counting

Objects can be registered multiple times with reference counting:

```objc
[registry registerObject:obj];
[registry registerObject:obj];
[registry registerObject:obj];  // Count is now 3
[registry unregisterObject:obj]; // Count is now 2
[registry unregisterObject:obj]; // Count is now 1
[registry unregisterObject:obj]; // Count is now 0, object removed
```

### Universal Registry

[BEUniversalObjectRegistry](doc:BEObjectRegistry) accepts any NSObject without requiring protocol conformance:

```objc
BEUniversalObjectRegistry *registry = [[BEUniversalObjectRegistry alloc] init];
NSString *myString = @"Hello World";
NSString *uuid = [registry registerObject:myString];
```

### Storage Registry

[BEStorageObjectRegistry](doc:BEObjectRegistry) maintains strong references to prevent deallocation:

```objc
BEStorageObjectRegistry *registry = [[BEStorageObjectRegistry alloc] init];
NSMutableArray *data = [NSMutableArray arrayWithObjects:@"item1", @"item2", nil];
NSString *uuid = [registry registerObject:data];
data = nil;  // Object is still retained by registry
NSMutableArray *retrievedData = [registry registeredObjectForUUID:uuid];  // Still valid
```

## See Also

- [BESingleton](doc:BESingleton)
- [NSObject+GlobalRegistry](doc:NSObject_GlobalRegistry)
