# ``BEMutable``

Protocols and categories for object mutability detection and recursive copying of collections.

```objc
#import <BEFoundation/BEMutable.h>
```

## Overview

This header provides a comprehensive framework for determining object mutability and performing recursive copying operations on Foundation collections. It defines protocols to categorize objects based on their mutability characteristics.

![A protocol hierarchy: the base protocols BEHasMutable, BECollectionAbstract, and BEMutable, with BECollection conforming to BECollectionAbstract and BEHasMutable, and BEMutableCollection conforming to BECollectionAbstract and BEMutable.](bemutable-protocols)

## Usage

### Mutability Protocols

- [BEHasMutable](doc:BEMutable) — For classes that have mutable counterparts
- [BEMutable](doc:BEMutable) — For classes that are inherently mutable
- [BECollectionAbstract](doc:BEMutable) — For all collection classes with recursive copying
- [BECollection](doc:BEMutable) — For immutable collection classes
- [BEMutableCollection](doc:BEMutable) — For mutable collection classes

### Checking Mutability

```objc
// Class-level check
BOOL isMutable = [NSMutableArray isMutable];     // YES
BOOL isMutable = [NSArray isMutable];           // NO

// Instance-level check
NSMutableArray *mutable = [NSMutableArray array];
NSArray *immutable = [NSArray array];

BOOL canMutate = [mutable isMutable];  // YES
BOOL canMutate = [immutable isMutable];  // NO
```

### Recursive Copying

```objc
// Create nested structure
NSDictionary *nested = @{
    @"array": @[@1, @2, @3],
    @"dict": @{@"key": @"value"},
    @"string": @"hello"
};

// Complete immutable recursive copy
NSDictionary *immutableCopy = [nested copyRecursive];
// All nested collections are deeply copied as immutable

// Complete mutable recursive copy
NSDictionary *mutableCopy = [nested mutableCopyRecursive];
// All nested collections are deeply copied as mutable

// Collection-only immutable copy
NSDictionary *collectionOnlyCopy = [nested copyCollectionRecursive];
// Only collection objects are copied; primitives are retained

// Collection-only mutable copy
NSDictionary *collectionMutableCopy = [nested mutableCopyCollectionRecursive];
// Only collection objects are copied as mutable; primitives are retained
```

### Classes with Mutable Counterparts

The following classes conform to [BEHasMutable](doc:BEMutable):
- `NSSet` / `NSMutableSet`
- `NSOrderedSet` / `NSMutableOrderedSet`
- `NSArray` / `NSMutableArray`
- `NSDictionary` / `NSMutableDictionary`
- `NSIndexSet` / `NSMutableIndexSet`
- `NSString` / `NSMutableString`
- `NSData` / `NSMutableData`
- `NSAttributedString` / `NSMutableAttributedString`
- `NSURLRequest` / `NSMutableURLRequest`
- [BECharacterSet](doc:BECharacterSet) / [BEMutableCharacterSet](doc:BEMutableCharacterSet)

### Character Set Distinction

[BECharacterSet](doc:BECharacterSet) and [BEMutableCharacterSet](doc:BEMutableCharacterSet) provide clear type distinction, addressing Apple's implementation where `NSCharacterSet` and `NSMutableCharacterSet` share the same object hierarchy.

```objc
// Use BECharacterSet for immutable character sets
BECharacterSet *charset = [[BECharacterSet alloc] init];
BOOL isMutable = [charset isMutable];  // NO

// Use BEMutableCharacterSet for mutable character sets
BEMutableCharacterSet *mutableCharset = [[BEMutableCharacterSet alloc] init];
isMutable = [mutableCharset isMutable];  // YES
```

## See Also

- [NSArray+BExtension](doc:NSArray_BExtension)
- [NSDictionary+BExtension](doc:NSDictionary_BExtension)
- [BEStackExtensions](doc:BEStackExtensions)
