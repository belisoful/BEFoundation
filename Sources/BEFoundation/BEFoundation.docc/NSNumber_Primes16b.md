# NSNumber+Primes16b

Prime number operations within the 16-bit range using a precomputed lookup table.

```objc
#import <BEFoundation/NSNumber+Primes16b.h>
```

## Overview

This category provides efficient prime number operations using a precomputed lookup table containing all 6542 primes from 2 to 65521 (the largest 16-bit prime).

## Usage

### Constants

```objc
// Total number of primes in 16-bit range
NSLog(@"Prime count: %d", NSPrimeNumbers16BitCount);  // 6542

// Smallest prime
NSLog(@"Smallest: %d", UInt16SmallestPrime);  // 2

// Largest 16-bit prime
NSLog(@"Largest: %d", UInt16LargestPrime);  // 65521
```

### Finding Prime Values

```objc
// Round to nearest prime
NSUInteger rounded = [NSNumber roundPrimeValue16:1000];  // 997

// Floor (largest prime <= value)
NSUInteger floored = [NSNumber floorPrimeValue16:1000];  // 997

// Ceiling (smallest prime >= value)
NSUInteger ceiled = [NSNumber ceilPrimeValue16:1000];    // 1009
```

### Offset Operations

```objc
// Get prime at offset from floor
NSUInteger offset = [NSNumber floorPrimeValue16:1000 offset:1];  // Next prime after 997
NSUInteger prev = [NSNumber floorPrimeValue16:1000 offset:-1];    // Previous prime before 997
```

### Index-Based Access

```objc
// Find index of ceiling prime
NSInteger idx = [NSNumber ceilPrimeIndex16:1000];  // Index of 1009

// Find index of floor prime
NSInteger floorIdx = [NSNumber floorPrimeIndex16:1000];  // Index of 997

// Round to nearest prime by index
NSInteger roundIdx = [NSNumber roundPrimeIndex16:1000];
```

### Instance Methods

```objc
NSNumber *num = @1000;

// Using instance methods
NSNumber *rounded = [num roundPrime16];   // @997
NSNumber *floored = [num floorPrime16];  // @997
NSNumber *ceiled = [num ceilPrime16];    // @1009
```

## How It Works

The implementation holds a precomputed table of all 6542 sixteen-bit primes. Ceiling, floor, and rounding operations binary-search that table in O(log n).

## See Also

- [NSMutableNumber](doc:NSMutableNumber)
- [NSNumber+BExtension](doc:NSNumber_BExtension)
