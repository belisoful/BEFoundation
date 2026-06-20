# NSObject+Macroable

A simplified macro system for Objective-C inspired by Laravel's Macroable trait.

```objc
#import <BEFoundation/NSObject+Macroable.h>
```

## Overview

This category provides a lightweight, Laravel-style façade over
[NSObject+DynamicMethods](doc:NSObject_DynamicMethods): macros are blocks attached to a class (or
a single instance) that can then be called as if they were native methods. Use it when you want
the core add/replace/remove workflow without the full dynamic-methods API.

Registering a macro automatically enables macro support on the class. Passing a `nil` block to
`macro:macroBlock:` removes any existing macro for that selector.

## Usage

### Class Macros

Class macros are available on every instance of the class:

```objc
// Add a macro
[MyClass macro:@selector(greet:) macroBlock:^(id self, NSString *name) {
    return [NSString stringWithFormat:@"Hello, %@!", name];
}];

// Check and remove
BOOL has = [MyClass hasMacro:@selector(greet:)];
[MyClass removeMacro:@selector(greet:)];

// Remove all macros from the class
[MyClass flushMacros];
```

### Object Macros

Object macros are registered on a specific instance only, and override a class macro of the same
selector for that instance:

```objc
MyClass *object = [MyClass new];
[object objectMacro:@selector(tag) macroBlock:^(id self) { return @"special"; }];

BOOL has = [object hasObjectMacro:@selector(tag)];
[object removeObjectMacro:@selector(tag)];
[object flushObjectMacros];
```

### Enabling and Disabling

`enableMacros` is optional — `macro:macroBlock:` enables support automatically on first use.
Disabling keeps macros registered but not callable until macros are re-enabled:

```objc
[MyClass disableMacros];   // macros remain registered, stop responding
[MyClass enableMacros];    // previously registered macros respond again
```

## See Also

- [NSObject+DynamicMethods](doc:NSObject_DynamicMethods)
