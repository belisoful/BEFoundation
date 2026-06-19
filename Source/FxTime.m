/*!
 @file			FxTime.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/

#import "BE_ARC.h"
#import "FxTime.h"
#import <math.h>
// $(PROJECT_DIR)/$(PROJECT_NAME)/Plugin/GuruFx-Swift-Bridging-Header.h


@implementation FxTime

@synthesize time = _time;

#pragma mark -
#pragma mark Static Initializers

+ (instancetype)time:(CMTime)time
{
	// Use [self alloc] (not FxTime.alloc) so +[FxMutableTime time:] yields an FxMutableTime.
	return NARC_AUTORELEASE([[self alloc] initWithCMTime:time]);
}

+ (instancetype)timeWithDictionary:(NSDictionary*)timeDictionary
{
	return NARC_AUTORELEASE([[self alloc] initWithDictionary:timeDictionary]);
}


+ (instancetype)invalid
{
	return [self time:kCMTimeInvalid];
}

+ (instancetype)indefinite
{
	return [self time:kCMTimeIndefinite];
}

+ (instancetype)infinity
{
	return [self time:kCMTimePositiveInfinity];
}

//negativeInfinity is already taken 😕
+ (instancetype)minusInfinity
{
	return [self time:kCMTimeNegativeInfinity];
}

+ (instancetype)zero
{
	return [self time:kCMTimeZero];
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

- (id)copyWithZone:(NSZone *)zone
{
	// -copy yields an immutable FxTime even for an FxMutableTime receiver.
	return [[FxTime alloc] initWithCMTime:_time];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
	return [[FxMutableTime alloc] initWithCMTime:_time];
}

- (BOOL)isEqual:(id)object
{
	if (self == object) {
		return YES;
	}
	if (![object isKindOfClass:[FxTime class]]) {
		return NO;
	}
	FxTime *rhs = (FxTime *)object;
	return CMTimeCompare(_time, rhs.time) == 0;
}

- (NSUInteger)hash
{
	// Must match -isEqual:, which is value-based (CMTimeCompare), so hash by value (seconds),
	// not by struct bytes. Special values get stable per-category constants.
	if (CMTIME_IS_NUMERIC(_time)) {
		Float64 secs = CMTimeGetSeconds(_time);
		// Degenerate numerics (timescale 0 → non-finite seconds) collapse to one constant;
		// NaN != NaN would otherwise break the equal-objects-hash-equal contract.
		if (!isfinite(secs)) {
			return (NSUInteger)0x0DEFACED;
		}
		return [@(secs) hash];
	}
	if (CMTIME_IS_POSITIVE_INFINITY(_time)) {
		return (NSUInteger)0x7F71F171;
	}
	if (CMTIME_IS_NEGATIVE_INFINITY(_time)) {
		return (NSUInteger)0x8F71F171;
	}
	if (CMTIME_IS_INDEFINITE(_time)) {
		return (NSUInteger)0x1DEF1DEF;
	}
	return (NSUInteger)0x12AD12AD; // invalid
}

#pragma mark -
#pragma mark Accessor Utilities

// Component getters are read-only on the immutable base; the matching setters live on
// FxMutableTime below.
- (CMTimeValue)value
{
	return _time.value;
}
- (CMTimeScale)timescale
{
	return _time.timescale;
}
- (CMTimeFlags)flags
{
	return _time.flags;
}
- (CMTimeEpoch)epoch
{
	return _time.epoch;
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
#pragma mark Math Functions (non-mutating)

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
		result.multiplier = INT32_MIN;
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
	result.divisor = (int32_t)k;
	
	return result;
}


// NSComparisonResult convention: result describes the receiver relative to time1.
- (int32_t)compare:(FxTime *)time1
{
	return CMTimeCompare(_time, time1.time);
}

- (int32_t)compareTime:(CMTime)time1
{
	return CMTimeCompare(_time, time1);
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

#pragma mark -
#pragma mark FxMutableTime

@implementation FxMutableTime

// These properties are redeclared read-write here; their getters are inherited from the
// immutable base and their setters are implemented below, so suppress auto-synthesis.
@dynamic time, value, timescale, flags, epoch;

// All methods here mutate the inherited (protected) _time ivar in place. The base
// FxTime is immutable; this subclass is the only place where _time changes after init.

#pragma mark - Read-write Component Accessors

- (void)setTime:(CMTime)time
{
	_time = time;
}

- (void)setValue:(CMTimeValue)value
{
	_time.value = value;
}

- (void)setTimescale:(CMTimeScale)timescale
{
	_time.timescale = timescale;
}

- (void)setFlags:(CMTimeFlags)flags
{
	_time.flags = flags;
}

- (void)setEpoch:(CMTimeEpoch)epoch
{
	_time.epoch = epoch;
}

#pragma mark - Time Conversion

- (void)convertTimeScale:(int32_t)newTimescale roundingMethod:(CMTimeRoundingMethod)method
{
	_time = CMTimeConvertScale(_time, newTimescale, method);
}

#pragma mark - Arithmetic Operations

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

#pragma mark - Min/Max Operations

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

@end
