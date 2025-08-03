/*!
 @file			FxTime.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract
 @discussion
*/

#import "BE_ARC.h"
#import "FxTime.h"
#import "math.h"
// $(PROJECT_DIR)/$(PROJECT_NAME)/Plugin/GuruFx-Swift-Bridging-Header.h


@implementation FxTime

@synthesize time = _time;

#pragma mark -
#pragma mark Static Initializers

+ (instancetype)time:(CMTime)time
{
	return NARC_AUTORELEASE([FxTime.alloc initWithCMTime:time]);
}

+ (instancetype)timeWithDictionary:(NSDictionary*)timeDictionary
{
	return NARC_AUTORELEASE([FxTime.alloc initWithDictionary:timeDictionary]);
}


+ (instancetype)invalid
{
	return [FxTime time:kCMTimeInvalid];
}

+ (instancetype)indefinite
{
	return [FxTime time:kCMTimeIndefinite];
}

+ (instancetype)infinity
{
	return [FxTime time:kCMTimePositiveInfinity];
}

//negativeInfinity is already taken 😕
+ (instancetype)minusInfinity
{
	return [FxTime time:kCMTimeNegativeInfinity];
}

+ (instancetype)zero
{
	return [FxTime time:kCMTimeZero];
}


#pragma mark -
#pragma mark Class Initializers


- (instancetype)initWithTime:(FxTime*)time
{
	self = [super init];
	if (self != nil)
	{
		_time = time.time;
	}
	return self;
}

- (instancetype)initWithCMTime:(CMTime)time
{
	self = [super init];
	if (self != nil)
	{
		_time = time;
	}
	return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)timeDictionary
{
	
	self = [super init];
	if (self != nil)
	{
		_time = CMTimeMakeFromDictionary((__bridge CFDictionaryRef)timeDictionary);
	}
	return self;
}

- (instancetype)initWithTime:(int64_t)value timescale:(int32_t)timescale
{
	self = [super init];
	if (self != nil)
	{
		_time = CMTimeMake(value, timescale);
	}
	return self;
}

- (instancetype)initWithTime:(int64_t)value timescale:(int32_t)timescale epoch:(int64_t)epoch
{
	self = [super init];
	if (self != nil)
	{
		_time = CMTimeMakeWithEpoch(value, timescale, epoch);
	}
	return self;
}

- (instancetype)initWithSeconds:(Float64)seconds preferredTimescale:(int32_t)preferredTimescale
{
	self = [super init];
	if (self != nil)
	{
		_time = CMTimeMakeWithSeconds(seconds, preferredTimescale);
	}
	return self;
}

#pragma mark -
#pragma mark NSCoder Functions

+ (BOOL)supportsSecureCoding
{
	return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self != nil)
	{
		NSUInteger size = 0;
		void *data = [aDecoder decodeBytesWithReturnedLength:&size];
		if (size == sizeof(CMTime)) {
			memcpy(&_time, data, size);
		}
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeBytes:&_time length:sizeof(CMTime)];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	return [[FxTime alloc] initWithCMTime:_time];
}

- (BOOL)isEqual:(NSObject<NSSecureCoding, NSCopying>*)object
{
	FxTime*    rhs = (FxTime*)object;
	return CMTimeCompare(_time, rhs.time) == 0;
}

#pragma mark -
#pragma mark Accessor Utilities

- (CMTimeValue)value
{
	return _time.value;
}
- (void)setValue:(CMTimeValue)value
{
	_time.value = value;
}
- (CMTimeScale)timescale
{
	return _time.timescale;
}
- (void)setTimescale:(CMTimeScale)timescale
{
	_time.timescale = timescale;
}
- (CMTimeFlags)flags
{
	return _time.flags;
}
- (void)setFlags:(CMTimeFlags)flags
{
	_time.flags = flags;
}
- (CMTimeEpoch)epoch
{
	return _time.epoch;
}
- (void)setEpoch:(CMTimeEpoch)epoch
{
	_time.epoch = epoch;
}

- (Float64)seconds
{
	return CMTimeGetSeconds(_time);
}

- (NSDictionary *)asDictionary
{
	CFDictionaryRef dict = CMTimeCopyAsDictionary(_time, kCFAllocatorDefault);
	NSDictionary *cmDict = CFBridgingRelease(dict);
	return cmDict;
}

- (void)show
{
	CMTimeShow(_time);
}

- (BOOL)isValid
{
	return CMTIME_IS_VALID(_time);
}

- (BOOL)isInfinity
{
	return CMTIME_IS_POSITIVE_INFINITY(_time);
}
- (BOOL)isNegativeInfinity
{
	return CMTIME_IS_NEGATIVE_INFINITY(_time);
}

- (BOOL)isIndefinite
{
	return CMTIME_IS_INDEFINITE(_time);
}

- (BOOL)isNumeric
{
	return CMTIME_IS_NUMERIC(_time);
}

- (BOOL)isRounded
{
	return CMTIME_HAS_BEEN_ROUNDED(_time);
}


#pragma mark -
#pragma mark Math Functions

- (void) convertTimeScale:(int32_t)newTimescale roundingMethod:(CMTimeRoundingMethod)method
{
	_time = CMTimeConvertScale(_time, newTimescale, method);
}

- (void)add:(FxTime *)time
{
	_time = CMTimeAdd(_time, time.time);
}

- (void)addTime:(CMTime)time
{
	_time = CMTimeAdd(_time, time);
}

- (void)subtract:(FxTime *)time
{
	_time = CMTimeSubtract(_time, time.time);
}

- (void)subtractTime:(CMTime)time
{
	_time = CMTimeSubtract(_time, time);
}

- (void)multiply:(int32_t)multiplier
{
	_time = CMTimeMultiply(_time, multiplier);
}

- (void)multiplyByFloat64:(Float64)multiplier
{
	_time = CMTimeMultiplyByFloat64(_time, multiplier);
}
- (void)multiplyByRatio:(int32_t)multiplier divisor:(int32_t)divisor
{
	_time = CMTimeMultiplyByRatio(_time, multiplier, divisor);
}


// Creates the multiplier and divisor from a float
+ (SRational32)rationalize:(Float64)number
{
	const double DEFAULT_TOLERANCE = 1.0e-6;
	return [self rationalize:number tolerance:DEFAULT_TOLERANCE];
}

+ (SRational32)rationalize:(Float64)number tolerance:(double)tolerance
{
	SRational32 result = {1, 1};
	if (number == INFINITY) {
		result.multiplier = 0x7FFFFFFF;
		return result;
	} else if (number == -INFINITY) {
		result.multiplier = 0x80000000;
		return result;
	} else if (isnan(number)) {
		result.multiplier = 0;
		return result;
	}
	BOOL negativeMultiplier = number < 0.0;
	
	double offset = (negativeMultiplier) ? 1.0 : 0.0; // Negative values go to +1 max over positive max.
	number = fabs(number);
	
	double h = 1.0, lh = 0.0;
	double k = 0.0, lk = 1.0;
	double b = 1.0 / number;
	tolerance *= number;
	do {
		b = 1.0 / b;
		double intVal = floor(b);
		double tmp = h;
		h = intVal * h + lh;
		lh = tmp;
		
		tmp = k;
		k = intVal * k + lk;
		lk = tmp;
		
		if (h > ((double)(0x7FFFFFFF) + offset) || k > (double)0x7FFFFFFF) {
			h = lh;
			k = lk;
			break;
		}
		b = b - intVal;
	} while (b != 0.0 && fabs(number - h / k) > tolerance);
	
	if (negativeMultiplier) {
		h *= -1.0;
	}
	int32_t multiplier = (int32_t)h;
	result.multiplier = multiplier;
	result.divisor = (int) k;
	
	return result;
}


//tells if the input time is over, equal or below interal time
- (int32_t)compare:(FxTime *)time1
{
	return CMTimeCompare(time1.time, _time);
}

//tells if the input time is over, equal or below interal time
- (int32_t)compareTime:(CMTime)time1
{
	return CMTimeCompare(time1, _time);
}

- (void)minimum:(FxTime *)time
{
	_time = CMTimeMinimum(time.time, _time);
}

- (void)minimumTime:(CMTime)time
{
	_time = CMTimeMinimum(time, _time);
}

- (void)maximum:(FxTime *)time
{
	_time = CMTimeMaximum(time.time, _time);
}

- (void)maximumTime:(CMTime)time
{
	_time = CMTimeMaximum(time, _time);
}

- (FxTime *)absoluteValue
{
	return [FxTime time:CMTimeAbsoluteValue(_time)];
}

- (CMTime)absoluteValueTime
{
	return CMTimeAbsoluteValue(_time);
}


@end
