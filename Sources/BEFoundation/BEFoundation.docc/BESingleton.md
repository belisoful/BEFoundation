# ``BESingleton``

A reusable and thread-safe singleton pattern implementation.

```objc
#import <BEFoundation/BESingleton.h>
```

## Overview

The [BESingleton](doc:BESingleton) protocol and [NSObject (BESingleton)](doc:BESingleton) category provide a simple way to create singleton classes. A class must conform to the [BESingleton](doc:BESingleton) protocol and override the `isSingleton` class method to return `YES`.

## Usage

### Basic Usage

Define a singleton class:

```objc
// MyClass.h
#import <BEFoundation/BESingleton.h>

@interface MyClass : NSObject <BESingleton>
+ (instancetype)sharedInstance;
@end

// MyClass.m
#import "MyClass.h"

@implementation MyClass

+ (BOOL)isSingleton {
    return YES;
}

+ (instancetype)sharedInstance {
    return [self __BESingleton];
}

@end
```

### Using the Singleton

```objc
MyClass *instance = [MyClass sharedInstance];
```

### Custom Initialization

Implement `initForSingleton:` for custom initialization:

```objc
// MyClass.h
@interface MyClass : NSObject <BESingleton>
@property (nonatomic, strong) NSString *configValue;
+ (instancetype)sharedInstance;
@end

// MyClass.m
@implementation MyClass

+ (BOOL)isSingleton {
    return YES;
}

+ (instancetype)sharedInstance {
    return [self __BESingleton];
}

- (instancetype)initForSingleton:(NSDictionary *)initInfo {
    self = [super init];
    if (self) {
        _configValue = initInfo[@"configKey"] ?: @"default";
    }
    return self;
}

@end

// Usage: set the init info on the singleton class before the first sharedInstance call.
MyClass.singletonInitInfo = @{@"configKey": @"customValue"};
MyClass *instance = [MyClass sharedInstance];
```

## How It Works

1. The `__BESingleton` method checks that the class conforms to `BESingleton` and that `isSingleton` returns `YES`
2. If so, it creates the instance using `initForSingleton:` when implemented, or `init` otherwise
3. The instance is cached as an associated object on the class and propagated to `BESingleton`-conforming superclasses, so a subclass and its ancestors share one instance
4. Subsequent calls return the cached instance
5. Thread-safety uses double-checked locking: an unsynchronized read of the cache, then creation inside `@synchronized` on the class with a re-check
6. An `atexit` handler clears the cached instances at process exit

## See Also

- [BEObjectRegistry](doc:BEObjectRegistry)
- [NSObject+GlobalRegistry](doc:NSObject_GlobalRegistry)
