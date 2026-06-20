# NSOrderedSet+BExtension

NSOrderedSet and NSMutableOrderedSet category providing mapping, filtering, and object metadata methods.

```objc
#import <BEFoundation/NSOrderedSet+BExtension.h>
```

## Overview

This category adds set mapping, filtering, and objects meta-data methods to NSOrderedSet and NSMutableOrderedSet.

## Usage

### Class Introspection

```objc
NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:@[@"a", @1, @"b", @2]];

// Get classes of all objects
NSOrderedSet<Class> *classes = orderedSet.objectsClasses;

// Get class names of all objects
NSOrderedSet<NSString *> *classNames = orderedSet.objectsClassNames;

// Get unique classes as counted set
NSCountedSet<Class> *uniqueClasses = orderedSet.objectsUniqueClasses;

// Get unique class names as counted set
NSCountedSet<NSString *> *uniqueClassNames = orderedSet.objectsUniqueClassNames;
```

### Class Name Conversion

```objc
NSOrderedSet<NSString *> *classNames = [NSOrderedSet orderedSetWithArray:@[@"NSString", @"NSNumber"]];

// Convert class name strings to Class objects
NSOrderedSet *classes = [classNames toClassesFromStrings];
```

### Mapping

```objc
NSOrderedSet *numbers = [NSOrderedSet orderedSetWithArray:@[@1, @2, @3, @4, @5]];

// Map with filtering - double even numbers
NSOrderedSet *doubledEvens = [numbers mapUsingBlock:^BOOL(id *obj, NSUInteger idx, BOOL *stop) {
    NSNumber *num = *obj;
    if ([num intValue] % 2 == 0) {
        *obj = @([num intValue] * 2);
        return YES;
    }
    return NO;
}];
// Result: @{@2, @4} in order
```

### Mutable Ordered Set Operations

```objc
NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithArray:@[@1, @2, @3]];

// Remove first object
[orderedSet removeFirstObject];
// Result: @{@2, @3}

// Remove last object
[orderedSet removeLastObject];
// Result: @{@2}

// Filter in place
[orderedSet filterUsingBlock:^BOOL(id *obj, NSUInteger idx, BOOL *stop) {
    NSNumber *num = *obj;
    return [num intValue] > 1;
}];
// Result: @{@2}
```

### Set Conversion

```objc
NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithArray:@[@1, @2, @3]];

// Set from array
orderedSet.array = @[@4, @5, @6];
// Result: @{@4, @5, @6}

// Set from set
orderedSet.set = [NSSet setWithArray:@[@7, @8]];
// Result: @{@7, @8} (order may vary)

// Intersect with array
[orderedSet intersectArray:@[@8, @9]];
// Result: @{@8}
```

## See Also

- [NSSet+BExtension](doc:NSSet_BExtension)
- [NSArray+BExtension](doc:NSArray_BExtension)
- [BEStackExtensions](doc:BEStackExtensions)
