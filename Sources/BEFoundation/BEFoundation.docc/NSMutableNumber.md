# ``NSMutableNumber``

A mutable version of NSNumber that supports thread-safe get/set operations.

```objc
#import <BEFoundation/NSMutableNumber.h>
```

## Overview

[NSMutableNumber](doc:NSMutableNumber) is a mutable implementation of NSNumber that allows modification of numeric values after creation. It inherits all NSNumber protocols and overrides required methods for duplicate NSNumber read functionality.

Key features:
- Thread-safe getters and setters using recursive mutex
- Same hash method as NSNumber for use as dictionary keys
- Detected as kindOfClass NSNumber
- Can be compared with NSNumber instances (an operand with an unrecognized type encoding compares as `NSOrderedDescending`)
- Works with maximum and minimum type value ranges
- Internal logic implemented with C++ for performance

## Usage

### Creating Mutable Numbers

```objc
// Initialize with various value types
NSMutableNumber *number = [[NSMutableNumber alloc] initWithInt:42];
NSMutableNumber *floatNum = [[NSMutableNumber alloc] initWithFloat:3.14];
NSMutableNumber *boolNum = [NSMutableNumber numberWithBool:YES];

// Using class factory methods
NSMutableNumber *zero = [NSMutableNumber zero];
NSMutableNumber *one = [NSMutableNumber one];
NSMutableNumber *infinity = [NSMutableNumber infinity];
NSMutableNumber *nan = [NSMutableNumber notANumber];
```

### Thread-Safe Value Access

All getters and setters are thread-safe:

```objc
NSMutableNumber *counter = [[NSMutableNumber alloc] initWithInt:0];

// Thread-safe increment
counter.intValue = counter.intValue + 1;

// Or use built-in operations
[counter addOne];  // Increments by 1
[counter minusOne]; // Decrements by 1

// Using the atomic properties
counter.integerValue = 100;
NSInteger val = counter.integerValue;  // Thread-safe read
```

### Value Comparison

Compare with other NSMutableNumber or NSNumber instances:

```objc
NSMutableNumber *num1 = [NSMutableNumber numberWithInt:42];
NSNumber *num2 = @42;

if ([num1 isEqualToNumber:num2]) {
    NSLog(@"Values are equal");
}

// Compare specific values
if (num1.isNegativeOne) {
    NSLog(@"Value is -1");
}

if (num1.isZero) {
    NSLog(@"Value is 0");
}

if (num1.isOne) {
    NSLog(@"Value is 1");
}
```

### Bitwise Operations

```objc
NSMutableNumber *flags = [NSMutableNumber numberWithInt:0b1100];

// Bitwise NOT
NSMutableNumber *notFlags = flags.bitNot;  // Creates new number

// In-place modification
flags.bitNotValue = flags.bitNotValue;  // Modifies existing
```

### Special Value Checks

```objc
NSMutableNumber *num = [NSMutableNumber notANumber];

if (num.isNotANumber) {
    NSLog(@"Not a number");
}

if (num.isInfinity) {
    NSLog(@"Is infinity");
}

if (num.isNegativeInfinity) {
    NSLog(@"Is negative infinity");
}
```

### Using with NSNumber

[NSMutableNumber](doc:NSMutableNumber) is fully compatible with NSNumber:

```objc
NSMutableNumber *mutableNum = [[NSMutableNumber alloc] initWithDouble:3.14];
NSNumber *immutableNum = [mutableNum copy];  // Returns NSNumber

// Use in collections
NSMutableDictionary *dict = [NSMutableDictionary dictionary];
dict[@"key"] = mutableNum;

// Works with KVC
[mutableNum setValue:@100 forKey:@"intValue"];
```

## See Also

- [NSNumber+BExtension](doc:NSNumber_BExtension)
- [NSNumber+Primes16b](doc:NSNumber_Primes16b)
- [NSCoder+HalfFloat](doc:NSCoder_HalfFloat)
