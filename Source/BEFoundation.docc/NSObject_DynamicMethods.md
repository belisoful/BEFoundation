# NSObject+DynamicMethods

A comprehensive system for adding and managing dynamic methods to Objective-C objects at runtime using blocks.

```objc
#import <BEFoundation/NSObject+DynamicMethods.h>
```

## Overview

This category provides a powerful runtime method injection system that allows you to add methods to existing objects and classes using blocks. The system supports both instance methods (added to specific object instances) and class methods (added to all instances of a class).

![A flowchart showing how a selector resolves: object dynamic method, then protocol target (required or optional-with-respondsToSelector), then no-protocol forward target, then class dynamic method, otherwise normal forwarding.](dynamic-method-resolution)

Key features:
- Add methods to existing objects without subclassing
- Support for both instance-specific and class-wide dynamic methods
- Protocol-based method forwarding and delegation
- Automatic method signature generation from block signatures
- Optional selector capture for method implementations
- Concurrency-safe method registration and dispatch (see Thread Safety below)
- Memory management with automatic cleanup

## Usage

### Enabling Dynamic Methods

Before using dynamic methods, you must enable them for your class:

```objc
// Enable for a class
[MyClass enableDynamicMethods];

// Enable for Foundation classes (use with caution)
[NSString allowNSDynamicMethods] = YES;
[NSString enableDynamicMethods];
```

### Adding Instance Methods

Add methods available to all instances of a class:

```objc
// Enable dynamic methods first
[MyClass enableDynamicMethods];

// Add a class method (callable on the class)
[MyClass addClassMethod:@selector(greet) block:^(id self) {
    return @"Hello!";
}];

// Add a method with parameters
[MyClass addClassMethod:@selector(greet:) block:^(id self, NSString *name) {
    return [NSString stringWithFormat:@"Hello, %@!", name];
}];

// Add a method that captures the selector
[MyClass addClassMethod:@selector(identifyMethod:) block:^(id self, SEL _cmd, NSString *param) {
    NSLog(@"Method called: %@", NSStringFromSelector(_cmd));
    return param;
}];
```

### Adding Object Methods

Add methods to a specific object instance only:

```objc
// Create an instance
NSString *str = [[NSString alloc] initWithString:@"Hello"];

// Add a custom method to this specific instance
[str addObjectMethod:@selector(customMethod:) block:^(id self, NSString *param) {
    NSLog(@"Custom method called with: %@", param);
    return [self stringByAppendingString:param];
}];

// Call the dynamic method
NSString *result = [str customMethod:@" World"];  // Returns "Hello World"
```

### Protocol-Based Forwarding

Forward method calls to protocol implementations:

```objc
// Define a protocol
@protocol MyProtocol <NSObject>
- (NSString *)doSomething;
- (NSString *)doSomethingElse:(NSString *)input;
@end

// Create a handler class that implements the protocol
@interface MyHandler : NSObject <MyProtocol>
@end

@implementation MyHandler
- (NSString *)doSomething {
    return @"Done!";
}
- (NSString *)doSomethingElse:(NSString *)input {
    return [input stringByAppendingString:@" handled!"];
}
@end

// Enable dynamic methods and register the protocol
[MyClass enableDynamicMethods];
[MyClass addInstanceProtocol:@protocol(MyProtocol)];
[MyClass addInstanceProtocol:@protocol(MyProtocol) withClass:[MyHandler class]];

// Now instances of MyClass respond to MyProtocol methods
MyClass *obj = [[MyClass alloc] init];
NSString *result = [obj doSomething];  // Forwarded to MyHandler
```

### Object-Specific Protocol Forwarding

Forward protocol methods to a specific target object:

```objc
MyClass *obj = [[MyClass alloc] init];
MyHandler *handler = [[MyHandler alloc] init];

[obj addObjectProtocol:@protocol(MyProtocol)];
[obj addObjectProtocol:@protocol(MyProtocol) withTarget:handler];
```

### Removing Dynamic Methods

```objc
// Remove a class method
[MyClass removeClassMethod:@selector(greet)];

// Remove an object method from a specific instance
[obj removeObjectMethod:@selector(customMethod:)];
```

### Checking for Dynamic Methods

```objc
// Check if a class has a dynamic class method
if ([MyClass isDynamicClassMethod:@selector(greet)]) {
    NSLog(@"greet is a dynamic class method");
}

// Check if an object has a dynamic object method
if ([obj isDynamicObjectMethod:@selector(customMethod:)]) {
    NSLog(@"customMethod is a dynamic object method");
}

// Check if a selector is handled by the dynamic system
if ([obj isDynamicMethod:@selector(doSomething)]) {
    NSLog(@"doSomething is handled dynamically");
}
```

## Block Signature Requirements

Method implementation blocks must follow this format:

```objc
ReturnType (^)(id self, SEL _cmd, ...parameters)
```

The `SEL _cmd` parameter is optional. If included, the block will receive the selector of the method being called. If omitted, the system automatically adjusts the signature.

## Thread Safety

Adding, removing, replacing, and dispatching dynamic methods (object and class) are safe to
perform concurrently. The metadata is guarded by per-scope locks, and a dispatch holds a strong
reference to the method's implementation for the duration of the call, so a concurrent remove or
replace cannot free an implementation that is mid-invocation.

One caveat applies to instance-protocol forwarding: reconfiguring an instance's forwarded
protocols concurrently with dispatch on that same instance may briefly present a stale view of
the forwarded protocols. This self-corrects on the next synchronization — it does not crash or
corrupt state. If you reconfigure protocol forwarding at runtime from multiple threads, serialize
that reconfiguration externally.

## Limitations

- NSMethodSignatures cannot properly encode compiler SIMD, vector, or NEON parameter types and will fail
- Use their base types as arrays or pointers instead for arguments
- The `_Float16` type also produces errors for malformed Block Signatures

## See Also

- [NSMethodSignature+BlockSignatures](doc:NSMethodSignature_BlockSignatures)
- [BERuntime](doc:BERuntime)
- [BEObjectRegistry](doc:BEObjectRegistry)
