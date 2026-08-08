# NSSet+BExtension

NSSet and NSMutableSet category providing mapping, filtering, and object metadata methods.

```objc
#import <BEFoundation/NSSet+BExtension.h>
```

## Overview

This category adds set mapping, filtering, and objects meta-data methods to NSSet and NSMutableSet.

## Usage

### Class Introspection

```objc
NSSet *set = [NSSet setWithArray:@[@"a", @1, @"b", @2]];

// Get classes of all objects
NSCountedSet<Class> *classes = set.objectsClasses;
// Returns count of each class type

// Get class names of all objects
NSCountedSet<NSString *> *classNames = set.objectsClassNames;
// Returns count of each class name

// Get unique classes
NSCountedSet<Class> *uniqueClasses = set.objectsUniqueClasses;

// Get unique class names
NSCountedSet<NSString *> *uniqueClassNames = set.objectsUniqueClassNames;
```

### Class Name Conversion

```objc
NSSet<NSString *> *classNames = [NSSet setWithArray:@[@"NSString", @"NSNumber", @"NSArray"]];

// Convert class name strings to Class objects
NSSet *classes = [classNames toClassesFromStrings];
```

### Mapping

```objc
NSSet *numbers = [NSSet setWithArray:@[@1, @2, @3, @4, @5]];

// Map with filtering - double even numbers
NSSet *doubledEvens = [numbers mapUsingBlock:^BOOL(id *obj, BOOL *stop) {
    NSNumber *num = *obj;
    if ([num intValue] % 2 == 0) {
        *obj = @([num intValue] * 2);
        return YES;  // Include in result
    }
    return NO;  // Exclude from result
}];
// Result: @{@4, @8}
```

### Mutable Set Filtering

```objc
NSMutableSet *set = [NSMutableSet setWithArray:@[@1, @2, @3, @4, @5]];

// Filter in place - keep numbers greater than 2
[set filterUsingBlock:^BOOL(id *obj, BOOL *stop) {
    NSNumber *num = *obj;
    return [num intValue] > 2;
}];
// Result: @{@3, @4, @5}
```

## See Also

- [NSOrderedSet+BExtension](doc:NSOrderedSet_BExtension)
- [NSArray+BExtension](doc:NSArray_BExtension)
- [NSDictionary+BExtension](doc:NSDictionary_BExtension)
