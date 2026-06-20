# ``BECharacterSet``

Immutable character set with clear type distinction from mutable counterpart.

```objc
#import <BEFoundation/BECharacterSet.h>
```

## Overview

[BECharacterSet](doc:BECharacterSet) provides an immutable character set class that clearly
distinguishes itself from [BEMutableCharacterSet](doc:BEMutableCharacterSet). This addresses
Apple's implementation where `NSCharacterSet` and `NSMutableCharacterSet` are backed by the same
concrete class-cluster subclass and cannot be programmatically distinguished.

## Usage

### Creating Character Sets

```objc
// Wrap an existing NSCharacterSet (or another BECharacterSet)
BECharacterSet *charset = [[BECharacterSet alloc] initWithSet:NSCharacterSet.alphanumericCharacterSet];

// Create with custom characters
BECharacterSet *custom = [BECharacterSet characterSetWithCharactersInString:@"abcdef"];

// Predefined sets are mirrored as class properties
BECharacterSet *lowercase = BECharacterSet.lowercaseLetterCharacterSet;
```

`characterSetWithContentsOfFile:` returns `nil` when the file cannot be read.

### Using Character Sets

```objc
BECharacterSet *charset = [BECharacterSet characterSetWithCharactersInString:@"aeiou"];

// Check if a character is in the set
BOOL isVowel = [charset characterIsMember:'a'];

// Access the wrapped NSCharacterSet for APIs that require one
NSCharacterSet *nsCharset = charset.characterSet;
```

### Equality with NSCharacterSet

By default a BECharacterSet does not equal an equivalent `NSCharacterSet`. The
`isClassEqualToNSCharacterSet` class property and `isEqualToNSCharacterSet` instance property
select the comparison behavior (`BECharacterSetEquality`); the hash follows the same setting so
hash/equality stay consistent in collections.

## See Also

- [BEMutableCharacterSet](doc:BEMutableCharacterSet)
- [BEMutable](doc:BEMutable)
