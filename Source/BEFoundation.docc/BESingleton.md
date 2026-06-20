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
// MyClass.m
@interface MyClass : NSObject <BESingleton>
@property (nonatomic, strong) NSString *configValue;
@end

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

// Usage
[NSObject singletonInitInfo] = @{@"configKey": @"customValue"};
MyClass *instance = [MyClass sharedInstance];
```

## How It Works

1. The `__BESingleton` method checks if `isSingleton` returns `YES`
2. If yes, it creates the instance once using `init` or `initForSingleton:`
3. Subsequent calls return the cached instance
4. Thread-safety is handled internally using dispatch_once

## See Also

- [BEObjectRegistry](doc:BEObjectRegistry)
- [NSObject+GlobalRegistry](doc:NSObject_GlobalRegistry)
