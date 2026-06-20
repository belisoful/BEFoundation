# NSObject+GlobalRegistry

Global registry integration for objects conforming to BERegistryProtocol.

```objc
#import <BEFoundation/NSObject+GlobalRegistry.h>
```

## Overview

This category adds convenience methods to NSObject for interacting with the global object registry. Objects conforming to [BERegistryProtocol](doc:BEObjectRegistry) can register and unregister themselves from the global registry.

## Usage

### Global Registration

```objc
@interface MyObject : NSObject <BERegistryProtocol>
@end

@implementation MyObject
@end

// Register an object globally
MyObject *obj = [[MyObject alloc] init];
NSString *uuid = [obj registerGlobalInstance];

// Check if registered
if (obj.isGlobalRegistered) {
    NSLog(@"Object is registered with UUID: %@", obj.globalRegistryUUID);
}

// Unregister
[obj unregisterGlobalInstance];
```

## See Also

- [BEObjectRegistry](doc:BEObjectRegistry)
- [BERegistryProtocol](doc:BEObjectRegistry)
