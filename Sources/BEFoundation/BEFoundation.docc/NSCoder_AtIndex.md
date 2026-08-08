# NSCoder+AtIndex

Index-based encoding and decoding methods for NSCoder.

```objc
#import <BEFoundation/NSCoder+AtIndex.h>
```

## Overview

This category extends NSCoder to support encoding and decoding operations using integer indices instead of string keys. Each index is internally converted to a string representation for use with the underlying NSCoder key-based methods.

## Usage

### Encoding with Indices

```objc
// Encode objects at numeric indices
[coder encodeObject:object1 atIndex:0];
[coder encodeObject:object2 atIndex:1];
[coder encodeBool:YES atIndex:2];
[coder encodeInt:42 atIndex:3];
[coder encodeFloat:3.14 atIndex:4];
[coder encodeDouble:2.718 atIndex:5];
```

### Decoding with Indices

```objc
// Decode objects by index
id obj1 = [coder decodeObjectAtIndex:0];
id obj2 = [coder decodeObjectAtIndex:1];
BOOL flag = [coder decodeBoolAtIndex:2];
int num = [coder decodeIntAtIndex:3];
float f = [coder decodeFloatAtIndex:4];
double d = [coder decodeDoubleAtIndex:5];
```

### Secure Coding Support

```objc
// Decode with class restriction
MyClass *obj = [coder decodeObjectOfClass:[MyClass class] atIndex:0];

// Decode array of objects
NSArray *array = [coder decodeArrayOfObjectsOfClass:[NSString class] atIndex:1];

// Decode dictionary
NSDictionary *dict = [coder decodeDictionaryWithKeysOfClass:[NSString class] 
                                              objectsOfClass:[NSNumber class] 
                                                     atIndex:2];
```

### Checking for Values

```objc
if ([coder containsValueAtIndex:0]) {
    id value = [coder decodeObjectAtIndex:0];
}
```

## See Also

- [NSCoder+HalfFloat](doc:NSCoder_HalfFloat)
- [BEPredicateRule](doc:BEPredicateRule)
