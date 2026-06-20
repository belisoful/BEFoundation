# NSArray+BExtension

Category extensions for NSArray and NSMutableArray providing collection conversion, class introspection, array manipulation, and functional programming methods.

```objc
#import <BEFoundation/NSArray+BExtension.h>
```

## Overview

This category adds methods for converting arrays to other collection types, introspecting object classes, manipulating array contents, and functional programming operations like mapping.

## Usage

### Collection Conversion

```objc
NSArray *array = @[@"a", @"b", @"c", @"a"];

// Convert to NSOrderedSet (preserves order, removes duplicates)
NSOrderedSet *orderedSet = array.orderedSet;

// Convert to NSSet (removes duplicates, order not guaranteed)
NSSet *set = array.set;
```

### Class Introspection

```objc
NSArray *mixed = @[@"string", @42, @"another", @100];

// Get array of Class objects
NSArray<Class> *classes = mixed.objectsClasses;
// Returns: [NSString, NSNumber, NSString, NSNumber]

// Get array of class names
NSArray<NSString *> *classNames = mixed.objectsClassNames;
// Returns: [@"NSString", @"NSNumber", @"NSString", @"NSNumber"]

// Get counted set of unique classes
NSCountedSet<Class> *uniqueClasses = mixed.objectsUniqueClasses;
// Returns: {NSString: 2, NSNumber: 2}

// Get counted set of unique class names
NSCountedSet<NSString *> *uniqueClassNames = mixed.objectsUniqueClassNames;
```

### Class Name Conversion

```objc
NSArray<NSString *> *classNames = @[@"NSString", @"NSNumber", @"NSArray"];

// Convert class name strings to Class objects
NSArray<Class> *classes = [classNames toClassesFromStrings];
```

### Mapping

```objc
NSArray *numbers = @[@1, @2, @3, @4, @5];

// Map with filtering - double even numbers
NSArray *doubledEvens = [numbers mapUsingBlock:^BOOL(id *obj, NSUInteger idx, BOOL *stop) {
    NSNumber *num = *obj;
    if ([num intValue] % 2 == 0) {
        *obj = @([num intValue] * 2);
        return YES;  // Include in result
    }
    return NO;  // Exclude from result
}];
// Result: @[@4, @8]
```

### Inserting Elements

```objc
NSMutableArray *array = [NSMutableArray arrayWithArray:@[@1, @2, @3]];

// Insert elements at specific index
[array insertObjects:@[@100, @200] atIndex:1];
// Result: @[@1, @100, @200, @2, @3]
```

### Mutable Array Operations

```objc
NSMutableArray *array = [NSMutableArray arrayWithArray:@[@1, @2, @3]];

// Remove first object
[array removeFirstObject];
// Result: @[@2, @3]

// Filter in place - keep numbers greater than 1
[array filterUsingBlock:^BOOL(id *obj, NSUInteger idx, BOOL *stop) {
    NSNumber *num = *obj;
    return [num intValue] > 1;
}];
// Result: @[@2, @3]
```

### Set Conversion

```objc
NSMutableArray *array = [NSMutableArray arrayWithArray:@[@1, @2, @3]];

// Get/set from ordered set
array.orderedSet = [NSOrderedSet orderedSetWithArray:@[@4, @5]];
// array is now: @[@4, @5]

// Get/set from set
array.set = [NSSet setWithArray:@[@6, @7]];
// array is now: @[@6, @7] (order may vary)
```

## See Also

- [NSSet+BExtension](doc:NSSet_BExtension)
- [NSDictionary+BExtension](doc:NSDictionary_BExtension)
- [BEStackExtensions](doc:BEStackExtensions)
