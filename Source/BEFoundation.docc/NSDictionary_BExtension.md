# NSDictionary+BExtension

Extensions to NSDictionary and NSMutableDictionary providing advanced collection manipulation, indexed subscripting, and recursive merging capabilities.

```objc
#import <BEFoundation/NSDictionary+BExtension.h>
```

## Overview

This category adds methods for indexed subscripting, extracting class information from dictionary values, transforming dictionaries through mapping operations, and creating new dictionaries by combining existing ones.

## Usage

### Indexed Subscript Access

```objc
NSDictionary *dict = @{@0: @"zero", @1: @"one", @"key": @"value"};

// Access with numeric index (tries NSNumber key first, then string)
NSString *val0 = dict[0];  // @"zero"
NSString *val1 = dict[1];  // @"one"
NSString *valKey = dict[@"key"];  // @"value"
```

### Class Introspection

```objc
NSDictionary *dict = @{@"str": @"hello", @"num": @42, @"arr": @[@1, @2]};

// Get classes of all values
NSDictionary *classes = dict.objectsClasses;
// Result: {@"str": [NSString class], @"num": [NSNumber class], @"arr": [NSArray class]}

// Get class names of all values
NSDictionary *classNames = dict.objectsClassNames;
// Result: {@"str": @"NSString", @"num": @"NSNumber", @"arr": @"NSArray"}

// Get counted set of unique classes
NSCountedSet<Class> *uniqueClasses = dict.objectsUniqueClasses;

// Get counted set of unique class names
NSCountedSet<NSString *> *uniqueClassNames = dict.objectsUniqueClassNames;
```

### Mapping

```objc
NSDictionary *dict = @{@"a": @1, @"b": @2, @"c": @3};

// Transform dictionary - double all values
NSDictionary *doubled = [dict mapUsingBlock:^BOOL(id *key, id *obj, BOOL *stop) {
    NSNumber *num = *obj;
    *obj = @([num intValue] * 2);
    return YES;
}];
// Result: {@"a": @2, @"b": @4, @"c": @6}
```

### Swapping Keys and Values

```objc
NSDictionary *dict = @{@"key1": @"value1", @"key2": @"value2"};

// Swap keys and values
NSDictionary *swapped = [dict swapped];
// Result: {@"value1": @"key1", @"value2": @"key2"}
// Note: Only values conforming to NSCopying can become keys
```

### Combining Dictionaries

```objc
NSDictionary *dict1 = @{@"a": @1, @"b": @2};
NSDictionary *dict2 = @{@"b": @3, @"c": @4};

// Add (overwrites existing keys)
NSDictionary *added = [dict1 dictionaryByAddingDictionary:dict2];
// Result: {@"a": @1, @"b": @3, @"c": @4}

// Merge (preserves existing keys)
NSDictionary *merged = [dict1 dictionaryByMergingDictionary:dict2];
// Result: {@"a": @1, @"b": @2, @"c": @4}
```

### Mutable Dictionary Operations

```objc
NSMutableDictionary *dict = [NSMutableDictionary dictionary];

// Configure indexed subscript to use numeric keys
dict.isIndexedSubscriptNumeric = YES;
dict[0] = @"first";
dict[1] = @"second";

// Swap in place
[dict swap];

// Filter in place
[dict filterUsingBlock:^BOOL(id *key, id *obj, BOOL *stop) {
    // Keep entries where value is not @"second"
    return ![(*obj) isEqualToString:@"second"];
}];
```

### Recursive Merging

```objc
NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithDictionary:@{
    @"a": @{@"x": @1, @"y": @2},
    @"b": @3
}];
NSDictionary *dict2 = @{
    @"a": @{@"y": @20, @"z": @30},
    @"c": @4
};

// Merge entries recursively (preserves existing keys at all levels)
[dict1 mergeEntriesFromDictionaryRecursive:dict2];
// dict1 is now: {@"a": @{@"x": @1, @"y": @2, @"z": @30}, @"b": @3, @"c": @4}

// Add entries recursively (overwrites existing keys at all levels)
[dict1 addEntriesFromDictionaryRecursive:dict2];
// dict1 is now: {@"a": @{@"x": @1, @"y": @20, @"z": @30}, @"b": @3, @"c": @4}
```

### Combine Flags

The [BEDictionaryCombineFlags](doc:NSDictionary_BExtension) enum controls recursive merge behavior:

```objc
typedef NS_ENUM(NSInteger, BEDictionaryCombineFlags) {
    BEDictionaryDefaultCombineFlags = 0,
    BEDictionaryMergeEntriesFlag = (1 << 0),        // Preserve existing entries
    BEDictionarySelfMutableCollectionFlag = (1 << 1), // Convert immutable to mutable
    BEDictionaryMutableCollectionCopyFlag = (1 << 2), // Copy mutable collections
    BEDictionaryMutableCopyFlag = (1 << 3),          // Copy NSMutableCopying objects
};
```

## See Also

- [NSArray+BExtension](doc:NSArray_BExtension)
- [NSSet+BExtension](doc:NSSet_BExtension)
- [BEMutable](doc:BEMutable)
