//
//  Plugin_Unit_Tests.m
//  Plugin Unit Tests
//
//  Created by ~ ~ on 3/14/24.
//

#import <XCTest/XCTest.h>
#import "FxTime.h"

@interface FxTimeTests : XCTestCase

@end

@implementation FxTimeTests

- (void)setUp {
}

- (void)tearDown {
}


- (void)testStaticInitializers {
	// Test static initializers
	FxTime *validTime = [FxTime time:CMTimeMake(10, 1)];
	XCTAssertTrue(CMTimeGetSeconds(validTime.time) == 10.0);
	
	FxTime *invalidTime = [FxTime invalid];
	XCTAssertTrue(CMTIME_IS_INVALID(invalidTime.time));
	
	FxTime *indefiniteTime = [FxTime indefinite];
	XCTAssertTrue(CMTIME_IS_INDEFINITE(indefiniteTime.time));
	
	FxTime *infinityTime = [FxTime infinity];
	XCTAssertTrue(CMTIME_IS_POSITIVE_INFINITY(infinityTime.time));
	
	FxTime *minusInfinityTime = [FxTime minusInfinity];
	XCTAssertTrue(CMTIME_IS_NEGATIVE_INFINITY(minusInfinityTime.time));
	
	FxTime *zeroTime = [FxTime zero];
	XCTAssertTrue(CMTimeGetSeconds(zeroTime.time) == 0.0);
}

- (void)testClassInitializers {
	// Test class initializers
	FxTime *timeWithCMTime = [[FxTime alloc] initWithCMTime:CMTimeMake(20, 2)];
	XCTAssertTrue(CMTimeGetSeconds(timeWithCMTime.time) == 10.0);
	XCTAssertEqual(timeWithCMTime.epoch, 0);
	
	NSDictionary *timeDictionary = @{
		(__bridge NSString *)kCMTimeValueKey: @30,
		(__bridge NSString *)kCMTimeScaleKey: @3,
		(__bridge NSString *)kCMTimeFlagsKey: @ (kCMTimeFlags_Valid),
		(__bridge NSString *)kCMTimeEpochKey: @0
	};
	FxTime *timeWithDictionary = [[FxTime alloc] initWithDictionary:timeDictionary];
	XCTAssertTrue(CMTimeGetSeconds(timeWithDictionary.time) == 10.0);
	
	FxTime *staticTimeWithDictionary = [FxTime timeWithDictionary:timeDictionary];
	XCTAssertTrue(CMTimeGetSeconds(staticTimeWithDictionary.time) == 10.0);
	
	FxTime *timeWithValue = [[FxTime alloc] initWithTime:40 timescale:4];
	XCTAssertTrue(CMTimeGetSeconds(timeWithValue.time) == 10.0);
	
	FxTime *timeWithEpoch = [[FxTime alloc] initWithTime:50 timescale:5 epoch:10];
	XCTAssertTrue(CMTimeGetSeconds(timeWithEpoch.time) == 10.0);
	XCTAssertEqual(timeWithEpoch.epoch, 10);
	
	FxTime *timeWithSeconds = [[FxTime alloc] initWithSeconds:10.0 preferredTimescale:1];
	XCTAssertTrue(CMTimeGetSeconds(timeWithSeconds.time) == 10.0);
	
	FxTime *timeWithTime = [FxTime.alloc initWithTime:timeWithSeconds];
	XCTAssertTrue(CMTimeGetSeconds(timeWithTime.time) == 10.0);
}

- (void)testNSCoding {
	// Test NSCoding
	FxTime *time = [FxTime time:CMTimeMake(100, 10)];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:time requiringSecureCoding:YES error:nil];
	FxTime *decodedTime = [NSKeyedUnarchiver unarchivedObjectOfClass:[FxTime class] fromData:data error:nil];
	XCTAssertEqualObjects(time, decodedTime);
}

- (void)testCopying {
	// Test copying
	FxTime *time = [FxTime time:CMTimeMake(200, 20)];
	FxTime *copiedTime = [time copy];
	XCTAssertTrue(CMTimeCompare(time.time, copiedTime.time) == 0);
}

- (void)testEquality {
	// Test equality
	FxTime *time1 = [FxTime time:CMTimeMake(300, 30)];
	FxTime *time2 = [FxTime time:CMTimeMake(300, 30)];
	FxTime *time3 = [FxTime time:CMTimeMake(400, 40)];
	FxTime *time4 = [FxTime time:CMTimeMake(400, 30)];
	
	XCTAssertTrue([time1 isEqual:time2]);
	XCTAssertTrue([time1 isEqual:time3]);
	XCTAssertFalse([time1 isEqual:time4]);
}

- (void)testAccessorUtilities {
	// Test accessor utilities
	FxTime *time = [FxTime time:CMTimeMake(500, 50)];
	
	XCTAssertTrue(time.value == 500);
	time.value = 600;
	XCTAssertTrue(time.value == 600);
	
	XCTAssertTrue(time.timescale == 50);
	time.timescale = 60;
	XCTAssertTrue(time.timescale == 60);
	
	XCTAssertTrue(time.flags == kCMTimeFlags_Valid);
	time.flags = kCMTimeFlags_HasBeenRounded;
	XCTAssertTrue(time.flags == kCMTimeFlags_HasBeenRounded);
	time.flags = kCMTimeFlags_Valid;
	
	XCTAssertTrue(time.epoch == 0);
	time.epoch = 100;
	XCTAssertTrue(time.epoch == 100);
	XCTAssertTrue(time.seconds == 10.0);
	
	NSDictionary *dictionary = time.asDictionary;
	XCTAssertNotNil(dictionary);
	
	NSDictionary *reference = @{@"flags": @(kCMTimeFlags_Valid), @"value":@((long)600), @"timescale":@60, @"epoch": @((long)100)};
	XCTAssertTrue([dictionary isEqualToDictionary:reference]);
	
	
	XCTAssertTrue(time.isValid);
	XCTAssertFalse(time.isInfinity);
	XCTAssertFalse(time.isNegativeInfinity);
	XCTAssertFalse(time.isIndefinite);
	XCTAssertTrue(time.isNumeric);
	XCTAssertFalse(time.isRounded);
}

- (void)testShow {
	// Test NSCoding
	FxTime *time = [FxTime time:CMTimeMake(100, 10)];
	[time show];
}

- (void)testMathFunctions {
	// Test math functions
	FxTime *time = [FxTime time:CMTimeMake(700, 70)];
	FxTime *negativeTime = [FxTime time:CMTimeMake(-700, 70)];
	
	[time convertTimeScale:80 roundingMethod:kCMTimeRoundingMethod_Default];
	XCTAssertTrue(CMTimeGetSeconds(time.time) == 10.0);
	XCTAssertTrue(time.value == 800);
	XCTAssertTrue(time.timescale == 80);
	
	FxTime *time2 = [FxTime time:CMTimeMake(100, 10)];
	[time addTime:time2.time];
	XCTAssertTrue(CMTimeGetSeconds(time.time) == 20.0);
	
	[time add:time2];
	XCTAssertTrue(CMTimeGetSeconds(time.time) == 30.0);
	
	[time subtract:time2];
	XCTAssertTrue(CMTimeGetSeconds(time.time) == 20.0);
	
	[time subtractTime:time2.time];
	XCTAssertTrue(CMTimeGetSeconds(time.time) == 10.0);
	
	[time multiply:4];
	XCTAssertTrue(CMTimeGetSeconds(time.time) == 40.0);
	
	[time multiplyByFloat64:0.25];
	XCTAssertTrue(CMTimeGetSeconds(time.time) == 10.0);
	
	[time multiplyByRatio:3 divisor:2];
	XCTAssertTrue(CMTimeGetSeconds(time.time) == 15.0);
	
	FxTime *time3 = [FxTime time:CMTimeMake(2000, 100)];
	XCTAssertTrue([time compare:time3] == 1);
	XCTAssertTrue([time compare:time] == 0);
	XCTAssertTrue([time compare:negativeTime] == -1);
	
	XCTAssertTrue([time compareTime:time3.time] == 1);
	XCTAssertTrue([time compareTime:time.time] == 0);
	XCTAssertTrue([time compareTime:negativeTime.time] == -1);
	
	FxTime *minTime = [FxTime time:CMTimeMake(500, 70)];
	[time minimum:time3];
	XCTAssertTrue(CMTimeGetSeconds(time.time) == 15.0);
	[time minimumTime:time3.time];
	XCTAssertTrue(CMTimeGetSeconds(time.time) == 15.0);
	
	minTime = [FxTime time:CMTimeMake(560, 70)];
	[time minimum:minTime];
	XCTAssertEqualWithAccuracy(CMTimeGetSeconds(time.time), 8.0, 0.01);
	
	minTime = [FxTime time:CMTimeMake(500, 70)];
	[time minimumTime:minTime.time];
	XCTAssertEqualWithAccuracy(CMTimeGetSeconds(time.time), 7.14, 0.01);
	
	FxTime *maxTime = [FxTime time:CMTimeMake(900, 70)];
	[time maximum:negativeTime];
	XCTAssertEqualWithAccuracy(CMTimeGetSeconds(time.time), 7.14, 0.01);
	[time maximumTime:negativeTime.time];
	XCTAssertEqualWithAccuracy(CMTimeGetSeconds(time.time), 7.14, 0.01);
	
	maxTime = [FxTime time:CMTimeMake(700, 70)];
	[time maximum:maxTime];
	XCTAssertEqualWithAccuracy(CMTimeGetSeconds(time.time), 10.0, 0.01);
	
	maxTime = [FxTime time:CMTimeMake(900, 70)];
	[time maximumTime:maxTime.time];
	XCTAssertEqualWithAccuracy(CMTimeGetSeconds(time.time), 12.86, 0.01);
	
	XCTAssertTrue(CMTimeGetSeconds(negativeTime.time) == -10.0);
	FxTime *absTime = negativeTime.absoluteValue;
	XCTAssertTrue(CMTimeGetSeconds(absTime.time) == 10.0);
	
	CMTime absTime2 = [negativeTime absoluteValueTime];
	XCTAssertTrue(CMTimeGetSeconds(absTime2) == 10.0);
}


- (NSString *)binaryRepresentation:(int)value
{
	long nibbleCount = sizeof(value) * 2;
	NSMutableString *bitString = [NSMutableString stringWithCapacity:nibbleCount * 5];

	for (long index = 4 * nibbleCount - 1; index >= 0; index--)
	{
		[bitString appendFormat:@"%i", value & (1 << index) ? 1 : 0];
		if (index % 4 == 0)
		{
			[bitString appendString:@" "];
		}
	}

	return bitString;
}

- (void)testRationalize32 {
	// Test rationalize
	SRational32 rational;
	
	rational = [FxTime rationalize:0.5];
	XCTAssertTrue(rational.multiplier == 1);
	XCTAssertTrue(rational.divisor == 2);
	
	rational = [FxTime rationalize:INFINITY];
	XCTAssertTrue(rational.multiplier == 0x7FFFFFFF);
	XCTAssertTrue(rational.divisor == 1);
	
	rational = [FxTime rationalize:-INFINITY];
	XCTAssertTrue(rational.multiplier == 0x80000000);
	XCTAssertTrue(rational.divisor == 1);
	
	rational = [FxTime rationalize:NAN];
	XCTAssertTrue(rational.multiplier == 0);
	XCTAssertTrue(rational.divisor == 1);
	
	rational = [FxTime rationalize:0.0];
	XCTAssertTrue(rational.multiplier == 0);
	XCTAssertTrue(rational.divisor == 1);
	
	rational = [FxTime rationalize:1.0];
	XCTAssertTrue(rational.multiplier == 1);
	XCTAssertTrue(rational.divisor == 1);
	
	rational = [FxTime rationalize:2.0];
	XCTAssertTrue(rational.multiplier == 2);
	XCTAssertTrue(rational.divisor == 1);
	
	rational = [FxTime rationalize:0x7FFFFFFF];
	XCTAssertTrue(rational.multiplier == 0x7FFFFFFF);
	XCTAssertTrue(rational.divisor == 1);
	
	rational = [FxTime rationalize:((float)((int32_t)0x80000000))];
	XCTAssertTrue(rational.multiplier == (int32_t)0x80000000);
	XCTAssertTrue(rational.divisor == 1);
	
	rational = [FxTime rationalize:-0.5];
	XCTAssertTrue(rational.multiplier == -1);
	XCTAssertTrue(rational.divisor == 2);
	
	rational = [FxTime rationalize:-1.0];
	XCTAssertTrue(rational.multiplier == -1);
	XCTAssertTrue(rational.divisor == 1);
	
	rational = [FxTime rationalize:(1.0 + sqrt(5.0)) / 2.0]; // Phi
	XCTAssertTrue(rational.multiplier == 987);
	XCTAssertTrue(rational.divisor == 610);
	
	rational = [FxTime rationalize:(1.0 + sqrt(5.0)) / 2.0 tolerance:1.0e-80]; // Phi
	XCTAssertEqual(rational.multiplier, 165580141);
	XCTAssertEqual(rational.divisor, 102334155);
	
	rational = [FxTime rationalize:sqrt(5.0) / 2.0 tolerance:0]; // Phi
	XCTAssertEqual(rational.multiplier, 193470546);
	XCTAssertEqual(rational.divisor, 173045317);
	
	rational = [FxTime rationalize:2000000000.0 + sqrt(5) tolerance:0]; // Phi
	XCTAssertEqual(rational.multiplier, 2000000002);
	XCTAssertEqual(rational.divisor, 1);
	
}

@end
