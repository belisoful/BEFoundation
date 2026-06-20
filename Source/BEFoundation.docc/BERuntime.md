# BERuntime

Runtime utility functions for Objective-C class and method introspection.

```objc
#import <BEFoundation/BERuntime.h>
```

## Overview

This header provides utility functions for working with the Objective-C runtime, including metaclass resolution and method existence checking within a specific class.

## Usage

### Functions

- `metaclass_getClass` — resolve a metaclass back to its class
- `class_hasMethod` — check whether a class itself defines a method

### Getting a Class from a Metaclass

Given a metaclass, retrieve the corresponding class instance:

```objc
Class metaClass = objc_getMetaClass("MyClass");
Class class = metaclass_getClass(metaClass);
```

### Checking for Method Existence

Check if a class defines a specific method (not inherited):

```objc
if (class_hasMethod([MyClass class], @selector(myMethod:))) {
    NSLog(@"MyClass implements myMethod:");
}
```

## See Also

- [NSObject+DynamicMethods](doc:NSObject_DynamicMethods)
- [NSMethodSignature+BlockSignatures](doc:NSMethodSignature_BlockSignatures)
