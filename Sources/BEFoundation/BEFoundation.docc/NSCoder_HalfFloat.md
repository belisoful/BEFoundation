# NSCoder+HalfFloat

Half-precision floating-point encoding and decoding support for NSCoder.

```objc
#import <BEFoundation/NSCoder+HalfFloat.h>
```

## Overview

This category adds methods for encoding and decoding half-precision floating-point values (`_Float16`) to NSCoder. Half-precision floats are 16-bit IEEE 754 floating-point numbers commonly used in graphics programming and machine learning.

## Usage

### Encoding Half Floats

```objc
// Encode a half-precision float
[coder encodeHalf:1.0 forKey:@"halfValue"];
[coder encodeHalf:0.5 forKey:@"normalized"];
[coder encodeHalf:-2.5 forKey:@"negative"];
```

### Decoding Half Floats

```objc
// Decode a half-precision float (returns 0 if the key is absent or malformed,
// like decodeFloatForKey: and the other NSCoder scalar decoders)
_Float16 value = [coder decodeHalfForKey:@"halfValue"];

// A stored 0 is indistinguishable from a missing key — check presence explicitly if it matters:
if (![coder containsValueForKey:@"halfValue"]) {
    NSLog(@"Value was not found");
}
```

### When to Use Half Floats

Half-precision floats are ideal for:
- Graphics programming (shaders, textures)
- Machine learning (neural network weights)
- Memory-constrained environments
- Situations where full precision is unnecessary

### Precision Considerations

```objc
// Half precision has limited precision
_Float16 a = 1.0;
_Float16 b = 0.001;  // May lose precision

// Sum may not equal expected result
_Float16 sum = a + b;  // May still be 1.0 due to precision loss
```

## See Also

- [NSCoder+AtIndex](doc:NSCoder_AtIndex)
- [BEPredicateRule](doc:BEPredicateRule)
