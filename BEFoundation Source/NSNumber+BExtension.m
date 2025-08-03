/*!
 @file			NSNumber+BExtension.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract
 @discussion
*/

#import "NSNumber+BExtension.h"


// Efficient power function for Int64 using exponentiation by squaring
// Returns base^exponent, or 0 on overflow
// Note: Negative exponents are not supported (would require floating point)
int64_t pow_int64(int64_t base, uint64_t exponent)
{
	// Handle special cases
	if (exponent == 0) return 1;
	if (base == 0) return 0;
	if (base == 1) return 1;
	if (base == -1) return (exponent & 1) ? -1 : 1;  // (-1)^even = 1, (-1)^odd = -1
	if (exponent == 1) return base;
	
	// Handle negative base
	bool negative_result = (base < 0) && (exponent & 1);
	
	// Work with absolute value to avoid overflow issues during computation
	uint64_t abs_base = (base == INT64_MIN) ? (uint64_t)INT64_MAX + 1 : (base < 0) ? -base : base;
	uint64_t result = 1;
	uint64_t current_base = abs_base;
	
	// Determine overflow limits based on final sign
	uint64_t max_positive = INT64_MAX;
	uint64_t max_negative = (uint64_t)INT64_MAX + 1;  // |INT64_MIN|
	uint64_t overflow_limit = negative_result ? max_negative : max_positive;
	
	while (exponent > 0) {
		uint64_t max_factor = overflow_limit / current_base;
		
		if (exponent & 1) {
			if (result > max_factor) {
				return 0; // Overflow detected
			}
			result *= current_base;
		}
		
		exponent >>= 1;
		
		if (exponent > 0) {
			if (current_base > max_factor) {
				return 0; // Overflow detected
			}
			current_base *= current_base;
		}
	}
	
	// Final sign application
	return negative_result ? -(int64_t)result : (int64_t)result;
}

uint64_t pow_uint64(uint64_t base, uint64_t exponent)
{
	if (exponent == 0) return 1;
	if (base == 0) return 0;
	if (base == 1) return 1;
	if (exponent == 1) return base;

	uint64_t result = 1;
	uint64_t current_base = base;

	while (exponent > 0) {
		uint64_t max_factor = UINT64_MAX / current_base;
		
		if (exponent & 1) {
			if (result > max_factor) {
				return 0; // Overflow detected
			}
			result *= current_base;
		}

		exponent >>= 1;

		if (exponent > 0) {
			// Reuse the same division result for squaring check
			if (current_base > max_factor) {
				return 0; // Overflow detected
			}
			current_base *= current_base;
		}
	}

	return result;
}


@implementation NSNumber (Extension)

NSNumber* numberOperation(NSNumberMathOperation operation, NSNumber *first, NSNumber *second)
{
	// Define the precedence order of types
	static NSArray<NSString *> *typeOrder = nil;
	if (!typeOrder) {
#define kOperationWithChar				0
#define kOperationWithShort				1
#define kOperationWithInt				2
#define kOperationWithLong				3
#define kOperationWithLongLong			4
#define kOperationWithBool				5
#define kOperationWithUnsignedChar		6
#define kOperationWithUnsignedShort		7
#define kOperationWithUnsignedInt		8
#define kOperationWithUnsignedLong		9
#define kOperationWithUnsignedLongLong	10
#define kOperationWithFloat				11
#define kOperationWithDouble			12
		
		typeOrder = @[
			[NSString stringWithFormat:@"%s", @encode(char)],
			[NSString stringWithFormat:@"%s", @encode(short)],
			[NSString stringWithFormat:@"%s", @encode(int)],
			(strcmp(@encode(long), @encode(long long))) ? [NSString stringWithFormat:@"%s", @encode(long)] : @"l",
			[NSString stringWithFormat:@"%s", @encode(long long)],
			
			[NSString stringWithFormat:@"%s", @encode(BOOL)],
			
			[NSString stringWithFormat:@"%s", @encode(unsigned char)],
			[NSString stringWithFormat:@"%s", @encode(unsigned short)],
			[NSString stringWithFormat:@"%s", @encode(unsigned int)],
			(strcmp(@encode(unsigned long), @encode(unsigned long long))) ? [NSString stringWithFormat:@"%s", @encode(long)] : @"L",
			[NSString stringWithFormat:@"%s", @encode(unsigned long long)],
			
			[NSString stringWithFormat:@"%s", @encode(float)],
			[NSString stringWithFormat:@"%s", @encode(double)]
		];
	}

	// Access the characters of the objCType strings
	NSString *firstType = [NSString stringWithFormat:@"%s", [first objCType]];
	NSString *secondType = [NSString stringWithFormat:@"%s", [second objCType]];

	// Determine the index of the highest precedence type
	NSUInteger firstIndex = [typeOrder indexOfObject:firstType];
	NSUInteger secondIndex = [typeOrder indexOfObject:secondType];
	NSUInteger highestIndex = MAX(firstIndex, secondIndex);
	NSUInteger lowestIndex = MIN(firstIndex, secondIndex);
	
	if (highestIndex >= 5 && highestIndex <= 9) {
		highestIndex -= 5; //convert unsigned (5..9) to next largest signed, except for largest unsigned.
		NSUInteger newHighest = MAX(highestIndex, lowestIndex);
		NSUInteger newLowest = MIN(highestIndex, lowestIndex);
		highestIndex = newHighest;
		lowestIndex = newLowest;
		
		if (highestIndex >= 5 && highestIndex <= 9) {
			highestIndex -= 5; //convert unsigned (5..9) to next largest signed, except for largest unsigned.
			newHighest = MAX(highestIndex, lowestIndex);
			newLowest = MIN(highestIndex, lowestIndex);
			highestIndex = newHighest;
			lowestIndex = newLowest;
		}
	}
	
	NSNumber *resultNumber = nil;
	if (highestIndex <= 10) {
		// Convert both numbers to the highest precedence type
		BOOL _firstUnsigned = NO, _secondUnsigned = NO, hasUnsigned;
		
		UInt64 uFirstValue = 0;
		SInt64 firstValue = 0;
		if (firstIndex <= 4) {
			firstValue = [first longLongValue];
		} else {
			uFirstValue = [first unsignedLongLongValue];
			_firstUnsigned = YES;
		}
		
		UInt64 uSecondValue = 0;
		SInt64 secondValue = 0;
		if (secondIndex <= 4) {
			secondValue = [second longLongValue];
		} else {
			uSecondValue = [second unsignedLongLongValue];
			_secondUnsigned = YES;
		}
		hasUnsigned = _firstUnsigned | _secondUnsigned;
		
		// Perform the mathematical operation
		unsigned long long ullResult = 0;
		long long llResult = 0;
		switch (operation) {
			case NSNumberMathOperationAdd:
				if (_firstUnsigned && _secondUnsigned) {
					ullResult = uFirstValue + uSecondValue;
				} else if (_secondUnsigned) {
					ullResult = firstValue + uSecondValue;
				} else if (_firstUnsigned) {
					ullResult = uFirstValue + secondValue;
				} else {
					llResult = firstValue + secondValue;
				}
				break;
			case NSNumberMathOperationSubtract:
				if (_firstUnsigned && _secondUnsigned) {
					ullResult = uFirstValue - uSecondValue;
				} else if (_secondUnsigned) {
					ullResult = firstValue - uSecondValue;
				} else if (_firstUnsigned) {
					ullResult = uFirstValue - secondValue;
				} else {
					llResult = firstValue - secondValue;
				}
				break;
			case NSNumberMathOperationMultiply:
				if (_firstUnsigned && _secondUnsigned) {
					ullResult = uFirstValue * uSecondValue;
				} else if (_secondUnsigned) {
					ullResult = firstValue * uSecondValue;
				} else if (_firstUnsigned) {
					ullResult = uFirstValue * secondValue;
				} else {
					llResult = firstValue * secondValue;
				}
				break;
			case NSNumberMathOperationDivide:
				if ((_secondUnsigned && uSecondValue == 0) || (!_secondUnsigned && secondValue == 0)) {
					return @(NAN);
				}
				if (_firstUnsigned && _secondUnsigned) {
					ullResult = uFirstValue / uSecondValue;
				} else if (_secondUnsigned) {
					ullResult = firstValue / uSecondValue;
				} else if (_firstUnsigned) {
					ullResult = uFirstValue / secondValue;
				} else {
					llResult = firstValue / secondValue;
				}
				break;
			case NSNumberMathOperationModulus:
				if (_firstUnsigned && _secondUnsigned) {
					ullResult = uFirstValue % uSecondValue;
				} else if (_secondUnsigned) {
					ullResult = firstValue % uSecondValue;
				} else if (_firstUnsigned) {
					ullResult = uFirstValue % secondValue;
				} else {
					llResult = firstValue % secondValue;
				}
				break;
			case NSNumberMathOperationPower:
				if (_firstUnsigned && _secondUnsigned) {
					ullResult = pow_uint64(uFirstValue, uSecondValue);
				} else if (_secondUnsigned) {
					llResult = pow_int64(firstValue, uSecondValue);
					hasUnsigned = NO;
				} else if (_firstUnsigned) {
					ullResult = pow_uint64(uFirstValue, secondValue);
				} else {
					llResult = pow_int64(firstValue, secondValue);
				}
				break;
			case NSNumberMathOperationXor:
				if (_firstUnsigned && _secondUnsigned) {
					ullResult = uFirstValue ^ uSecondValue;
				} else if (_secondUnsigned) {
					ullResult = firstValue ^ uSecondValue;
				} else if (_firstUnsigned) {
					ullResult = uFirstValue ^ secondValue;
				} else {
					llResult = firstValue ^ secondValue;
				}
				break;
		}
		if (highestIndex == kOperationWithChar) {	// char
			resultNumber = [NSNumber numberWithChar:(char)(hasUnsigned ? ullResult : llResult)];
		} else if (highestIndex == kOperationWithShort) {
			resultNumber = [NSNumber numberWithShort:(short)(hasUnsigned ? ullResult : llResult)];
		} else if (highestIndex == kOperationWithInt) {
			resultNumber = [NSNumber numberWithInt:(int)(hasUnsigned ? ullResult : llResult)];
		} else if (highestIndex == kOperationWithLong) {
			resultNumber = [NSNumber numberWithLong:(long)(hasUnsigned ? ullResult : llResult)];
		} else if (highestIndex == kOperationWithLongLong) {
			resultNumber = [NSNumber numberWithLongLong:(long long)(hasUnsigned ? ullResult : llResult)];
		} else if (highestIndex == kOperationWithBool) {
			resultNumber = [NSNumber numberWithBool:(BOOL)(hasUnsigned ? ullResult : llResult)];
		} else if (highestIndex == kOperationWithUnsignedChar) {
			resultNumber = [NSNumber numberWithUnsignedChar:(unsigned char)(hasUnsigned ? ullResult : llResult)];
		} else if (highestIndex == kOperationWithUnsignedShort) {
			resultNumber = [NSNumber numberWithUnsignedShort:(unsigned short)(hasUnsigned ? ullResult : llResult)];
		} else if (highestIndex == kOperationWithUnsignedInt) {
			resultNumber = [NSNumber numberWithUnsignedInt:(unsigned int)(hasUnsigned ? ullResult : llResult)];
		} else if (highestIndex == kOperationWithUnsignedLong) {
			resultNumber = [NSNumber numberWithUnsignedLong:(unsigned long)(hasUnsigned ? ullResult : llResult)];
		} else if (highestIndex == kOperationWithUnsignedLongLong) {
			resultNumber = [NSNumber numberWithUnsignedLongLong:(unsigned long long)(hasUnsigned ? ullResult : llResult)];
		}
		
	} else {
		// Convert both numbers to the highest precedence type
		double firstValue = [first doubleValue];
		double secondValue = [second doubleValue];
		
		// Perform the mathematical operation
		double result = 0;
		switch (operation) {
			case NSNumberMathOperationAdd:
				result = firstValue + secondValue;
				break;
			case NSNumberMathOperationSubtract:
				result = firstValue - secondValue;
				break;
			case NSNumberMathOperationMultiply:
				result = firstValue * secondValue;
				break;
			case NSNumberMathOperationDivide:
				if (secondValue == 0.0) {
					return @(INFINITY);
				}
				result = firstValue / secondValue;
				break;
			case NSNumberMathOperationModulus:
				result = fmod(firstValue, secondValue);
				break;
			case NSNumberMathOperationPower:
				result = pow(firstValue, secondValue);
				break;
			case NSNumberMathOperationXor:
				result = (int)firstValue ^ (int)secondValue;
				break;
		}
		if (highestIndex == kOperationWithFloat) {
			resultNumber = [NSNumber numberWithFloat:(float)result];
		} else if (highestIndex == kOperationWithDouble) {
			resultNumber = [NSNumber numberWithDouble:result];
		}
	}

	return resultNumber;
}



- (NSNumber*)addNumber:(NSNumber *)second
{
	return numberOperation(NSNumberMathOperationAdd, self, second);
}

- (NSNumber*)subtractNumber:(NSNumber *)second
{
	return numberOperation(NSNumberMathOperationSubtract, self, second);
}

- (NSNumber*)multiplyNumber:(NSNumber *)second
{
	return numberOperation(NSNumberMathOperationMultiply, self, second);
}

- (NSNumber*)divideNumber:(NSNumber *)second
{
	return numberOperation(NSNumberMathOperationDivide, self, second);
}

- (NSNumber*)modulusNumber:(NSNumber *)second
{
	return numberOperation(NSNumberMathOperationModulus, self, second);
}

- (NSNumber*)powerNumber:(NSNumber *)second
{
	return numberOperation(NSNumberMathOperationPower, self, second);
}

- (NSNumber*)xorNumber:(NSNumber *)second
{
	return numberOperation(NSNumberMathOperationXor, self, second);
}





- (NSNumber*)addInt:(SInt64)second
{
	return numberOperation(NSNumberMathOperationAdd, self, [NSNumber numberWithLongLong:second]);
}

- (NSNumber*)addUInt:(UInt64)second
{
	return numberOperation(NSNumberMathOperationAdd, self, [NSNumber numberWithUnsignedLongLong:second]);
}

- (NSNumber*)addDouble:(double)second
{
	return numberOperation(NSNumberMathOperationAdd, self, [NSNumber numberWithDouble:second]);
}


- (NSNumber*)subtractInt:(SInt64)second
{
	return numberOperation(NSNumberMathOperationSubtract, self, [NSNumber numberWithLongLong:second]);
}
- (NSNumber*)subtractUInt:(UInt64)second
{
	return numberOperation(NSNumberMathOperationSubtract, self, [NSNumber numberWithUnsignedLongLong:second]);
}
- (NSNumber*)subtractDouble:(double)second
{
	return numberOperation(NSNumberMathOperationSubtract, self, [NSNumber numberWithDouble:second]);
}


- (NSNumber*)multiplyInt:(SInt64)second
{
	return numberOperation(NSNumberMathOperationMultiply, self, [NSNumber numberWithLongLong:second]);
}
- (NSNumber*)multiplyUInt:(UInt64)second
{
	return numberOperation(NSNumberMathOperationMultiply, self, [NSNumber numberWithUnsignedLongLong:second]);
}
- (NSNumber*)multiplyDouble:(double)second
{
	return numberOperation(NSNumberMathOperationMultiply, self, [NSNumber numberWithDouble:second]);
}


- (NSNumber*)divideInt:(SInt64)second
{
	return numberOperation(NSNumberMathOperationDivide, self, [NSNumber numberWithLongLong:second]);
}
- (NSNumber*)divideUInt:(UInt64)second
{
	return numberOperation(NSNumberMathOperationDivide, self, [NSNumber numberWithUnsignedLongLong:second]);
}
- (NSNumber*)divideDouble:(double)second
{
	return numberOperation(NSNumberMathOperationDivide, self, [NSNumber numberWithDouble:second]);
}


- (NSNumber*)modulusInt:(SInt64)second
{
	return numberOperation(NSNumberMathOperationModulus, self, [NSNumber numberWithLongLong:second]);
}
- (NSNumber*)modulusUInt:(UInt64)second
{
	return numberOperation(NSNumberMathOperationModulus, self, [NSNumber numberWithUnsignedLongLong:second]);
}
- (NSNumber*)modulusDouble:(double)second
{
	return numberOperation(NSNumberMathOperationModulus, self, [NSNumber numberWithDouble:second]);
}


- (NSNumber*)powerUInt:(UInt64)second
{
	return numberOperation(NSNumberMathOperationPower, self, [NSNumber numberWithUnsignedLongLong:second]);
}
- (NSNumber*)powerDouble:(double)second
{
	return numberOperation(NSNumberMathOperationPower, self, [NSNumber numberWithDouble:second]);
}


- (NSNumber*)xorInt:(SInt64)second
{
	return numberOperation(NSNumberMathOperationXor, self, [NSNumber numberWithLongLong:second]);
}
- (NSNumber*)xorUInt:(UInt64)second
{
	return numberOperation(NSNumberMathOperationXor, self, [NSNumber numberWithUnsignedLongLong:second]);
}

@end
