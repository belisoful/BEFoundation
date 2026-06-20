# ``FxTime``

An Objective-C wrapper for CoreMedia's CMTime structure providing convenient time manipulation and arithmetic operations.

```objc
#import <BEFoundation/FxTime.h>
```

## Overview

[FxTime](doc:FxTime) encapsulates CoreMedia's `CMTime` structure in an Objective-C object, providing a more convenient and object-oriented interface for time-based operations in media applications.

## Usage

### Creating Time Objects

```objc
// Create from CMTime
CMTime time = CMTimeMakeWithSeconds(3.5, 600);
FxTime *fxTime = [FxTime time:time];

// Create from dictionary
FxTime *fromDict = [FxTime timeWithDictionary:timeDictionary];

// Factory methods for special values
FxTime *zero = [FxTime zero];
FxTime *invalid = [FxTime invalid];
FxTime *infinity = [FxTime infinity];
FxTime *minusInfinity = [FxTime minusInfinity];
FxTime *indefinite = [FxTime indefinite];

// Create with time value and timescale
FxTime *time1 = [[FxTime alloc] initWithTime:100 timescale:30];  // 100/30 seconds

// Create with seconds and preferred timescale
FxTime *time2 = [[FxTime alloc] initWithSeconds:3.5 preferredTimescale:600];
```

### Time Properties

```objc
FxTime *time = [[FxTime alloc] initWithSeconds:3.5 preferredTimescale:600];

// Access components
CMTimeValue value = time.value;
CMTimeScale timescale = time.timescale;
CMTimeFlags flags = time.flags;
CMTimeEpoch epoch = time.epoch;

// Get time in seconds
Float64 seconds = time.seconds;

// Check time properties
BOOL valid = time.isValid;
BOOL numeric = time.isNumeric;
BOOL inf = time.isInfinity;
BOOL negInf = time.isNegativeInfinity;
BOOL indefinite = time.isIndefinite;
BOOL rounded = time.isRounded;
```

### Arithmetic Operations

```objc
// Arithmetic mutates the receiver, so use FxMutableTime.
FxMutableTime *time1 = [[FxMutableTime alloc] initWithSeconds:1.0 preferredTimescale:600];
FxTime *time2 = [[FxTime alloc] initWithSeconds:2.5 preferredTimescale:600];

// Add times (modifies receiver)
[time1 add:time2];
// time1 is now 3.5 seconds

// Subtract times
[time1 subtract:time2];

// Multiply
[time1 multiply:2];          // Multiply by integer
[time1 multiplyByFloat64:1.5];  // Multiply by double
[time1 multiplyByRatio:3 divisor:2];  // Multiply by 3/2
```

### Comparison

```objc
FxTime *time1 = [[FxTime alloc] initWithSeconds:1.0 preferredTimescale:600];
FxTime *time2 = [[FxTime alloc] initWithSeconds:2.0 preferredTimescale:600];

// Compare times
int32_t result = [time1 compare:time2];
// Returns: -1 if time1 < time2, 0 if equal, 1 if time1 > time2

// Compare with CMTime
int32_t result2 = [time1 compareTime:kCMTimeZero];
```

### Min/Max Operations

```objc
// minimum:/maximum: mutate the receiver, so use FxMutableTime.
FxMutableTime *time = [[FxMutableTime alloc] initWithSeconds:5.0 preferredTimescale:600];
FxTime *limit = [[FxTime alloc] initWithSeconds:3.0 preferredTimescale:600];

// Set to minimum of time and limit
[time minimum:limit];  // time is now 3.0 seconds

// Set to maximum of time and limit
[time maximum:limit];  // time is now 5.0 seconds
```

### Time Conversion

```objc
FxTime *time = [[FxTime alloc] initWithSeconds:3.5 preferredTimescale:600];

// Convert to different timescale
[time convertTimeScale:30 roundingMethod:kCMTimeRoundingMethod_Default];

// Get as dictionary
NSDictionary *dict = [time asDictionary];
```

### Absolute Value

```objc
FxTime *negative = [[FxTime alloc] initWithSeconds:-5.0 preferredTimescale:600];

// Get absolute value
FxTime *absolute = negative.absoluteValue;  // 5.0 seconds

// Get as CMTime
CMTime absTime = negative.absoluteValueTime;
```

## See Also

- [NSDateFormatterRFC3339](doc:NSDateFormatterRFC3339)
