# NSNumber+BExtension

Mathematical operations extension for NSNumber with type-safe arithmetic operations.

```objc
#import <BEFoundation/NSNumber+BExtension.h>
```

## Overview

This category extends NSNumber with convenient methods for performing mathematical operations with other NSNumber instances or primitive types. All operations preserve type precision and handle overflow conditions appropriately.

## Usage

### Operations with NSNumber

```objc
NSNumber *a = @10;
NSNumber *b = @3;

// Basic arithmetic
NSNumber *sum = [a addNumber:b];          // 13
NSNumber *diff = [a subtractNumber:b];    // 7
NSNumber *prod = [a multiplyNumber:b];     // 30
NSNumber *quot = [a divideNumber:b];       // 3 (integer operands divide as integers)
NSNumber *mod = [a modulusNumber:b];       // 1
NSNumber *pow = [a powerNumber:b];         // 1000

// Bitwise XOR
NSNumber *xor = [a xorNumber:b];          // 9

// Promote to floating point by making either operand a double
NSNumber *fquot = [a divideNumber:@3.0];  // 3.333...
```

### Operations with Primitive Types

```objc
NSNumber *num = @10;

// With signed 64-bit integers
NSNumber *result1 = [num addInt:5];       // 15
NSNumber *result2 = [num subtractInt:3];  // 7
NSNumber *result3 = [num multiplyInt:2];  // 20
NSNumber *result4 = [num divideInt:4];    // 2

// With unsigned 64-bit integers
NSNumber *result5 = [num addUInt:100];    // 110

// With doubles
NSNumber *result6 = [num addDouble:0.5];   // 10.5
NSNumber *result7 = [num powerDouble:0.5]; // sqrt(10)
```

### Division and Modulus by Zero

Integer division or modulus by zero returns `NaN` instead of trapping; floating-point division by
zero returns infinity (matching IEEE semantics through `fmod`/`pow` for the other operations).

### Type Precedence

When performing operations between different types, the result type follows this precedence (lowest to highest):
- `char`
- `short`
- `int`
- `long`
- `long long`
- `BOOL`
- `unsigned char`
- `unsigned short`
- `unsigned int`
- `unsigned long`
- `unsigned long long`
- `float`
- `double`

### Configurable Float Encoding

`floatToFpXX()` encodes a double into a packed integer using a configurable IEEE 754-style format
(1 sign bit, configurable exponent and mantissa widths). With the defaults it produces standard
fp16/half-float encoding; other widths cover formats such as bfloat16:

```objc
int64_t fp16 = floatToFpXX(1.0, 0, 0, INT_MIN, YES);   // 0x3C00 (defaults: 5 exp, 10 mantissa)
int64_t bf16 = floatToFpXX(1.0, 8, 7, INT_MIN, YES);   // 0x3F80 (bfloat16)
```

Pass `0` for exponent/mantissa bits to use the defaults, `INT_MIN` to auto-compute the bias, and
`NO` for IEEE conformance to saturate instead of producing subnormals and infinities. Invalid
format parameters return `0`.

### Integer Power Helpers

`pow_int64()` and `pow_uint64()` compute integer powers by exponentiation-by-squaring with
overflow detection, returning `0` on overflow.

## See Also

- [NSMutableNumber](doc:NSMutableNumber)
- [NSNumber+Primes16b](doc:NSNumber_Primes16b)
