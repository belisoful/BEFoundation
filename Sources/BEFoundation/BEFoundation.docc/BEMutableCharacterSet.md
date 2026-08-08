# ``BEMutableCharacterSet``

Mutable character set counterpart to BECharacterSet.

```objc
#import <BEFoundation/BECharacterSet.h>
```

## Overview

[BEMutableCharacterSet](doc:BEMutableCharacterSet) provides a mutable character set class that clearly distinguishes itself from [BECharacterSet](doc:BECharacterSet).

## Usage

### Creating Mutable Character Sets

```objc
// Create empty mutable character set
BEMutableCharacterSet *charset = [[BEMutableCharacterSet alloc] init];

// Create with initial characters
BEMutableCharacterSet *vowels = [BEMutableCharacterSet characterSetWithCharactersInString:@"aeiou"];
```

### Mutating Character Sets

```objc
BEMutableCharacterSet *charset = [[BEMutableCharacterSet alloc] init];

// Add characters
[charset addCharactersInString:@"abcdef"];

// Remove characters
[charset removeCharactersInString:@"aeiou"];

// Form unions
BEMutableCharacterSet *other = [BEMutableCharacterSet characterSetWithCharactersInString:@"xyz"];
[charset formUnionWithCharacterSet:other];

// Form intersections
[charset formIntersectionWithCharacterSet:other];
```

The `characterSet` property returns the backing `NSMutableCharacterSet` itself, not a copy —
mutations made through it are reflected in the BEMutableCharacterSet.

### Converting to Immutable

```objc
BEMutableCharacterSet *mutableSet = [BEMutableCharacterSet characterSetWithCharactersInString:@"hello"];

// Get an immutable version
BECharacterSet *immutable = [mutableSet copy];
// or
BECharacterSet *wrapped = [[BECharacterSet alloc] initWithSet:mutableSet];
```

## See Also

- [BECharacterSet](doc:BECharacterSet)
- [BEMutable](doc:BEMutable)
