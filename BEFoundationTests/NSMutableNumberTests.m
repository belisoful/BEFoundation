/*
 *   Updated 2025 by belisoful <belisoful@icloud.com> for testing new functionality
 *   conformance, and greater coverage.
 */

#import <XCTest/XCTest.h>
#import "NSMutableNumber.h"
#import "NSMockNumber.h"

@interface MNTests : XCTestCase

@end

@implementation MNTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testIncDec
{
	NSMutableNumber * mutable = [[NSMutableNumber alloc] initWithInt:0];
	XCTAssertNotNil(mutable);

	mutable.intValue++;
	XCTAssertEqual(mutable.intValue, 1);
	XCTAssertEqual(mutable.unsignedLongLongValue, 1);
	XCTAssertEqual(mutable.boolValue, YES);

	mutable.intValue--;
	XCTAssertEqual(mutable.intValue, 0);
	XCTAssertEqual(mutable.unsignedIntValue, 0);
	XCTAssertEqual(mutable.boolValue, NO);

	mutable.intValue--;
	XCTAssertEqual(mutable.intValue, -1);
	XCTAssertEqual(mutable.charValue, -1);
}

- (void) testEqualMixedTypes
{
	XCTAssertEqualObjects([NSMutableNumber numberWithBool:NO], [NSNumber numberWithChar:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithChar:CHAR_MIN], [NSNumber numberWithInteger:CHAR_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithInt:INT_MIN], [NSNumber numberWithLongLong:INT_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithInteger:NSIntegerMin], [NSNumber numberWithLongLong:NSIntegerMin]);
	XCTAssertEqualObjects([NSMutableNumber numberWithLong:LONG_MIN], [NSNumber numberWithLongLong:LONG_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithLongLong:LONG_LONG_MIN], [NSNumber numberWithLongLong:LONG_LONG_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithShort:SHRT_MIN], [NSNumber numberWithInt:SHRT_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedChar:0], [NSNumber numberWithLong:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedInt:0], [NSNumber numberWithInt:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedInteger:0], [NSNumber numberWithUnsignedLongLong:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedLong:0], [NSNumber numberWithShort:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedLongLong:0], [NSNumber numberWithChar:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedShort:0], [NSNumber numberWithShort:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnichar:0], [NSNumber numberWithUnichar:0]);
	
	XCTAssertEqualObjects([NSMutableNumber numberWithBool:YES], [NSNumber numberWithFloat:1]);
	XCTAssertEqualObjects([NSMutableNumber numberWithChar:CHAR_MAX], [NSNumber numberWithUnsignedChar:CHAR_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithInt:INT_MAX], [NSNumber numberWithUnsignedInt:INT_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithInteger:NSIntegerMax], [NSNumber numberWithUnsignedLongLong:NSIntegerMax]);
	XCTAssertEqualObjects([NSMutableNumber numberWithLong:LONG_MAX], [NSNumber numberWithUnsignedLong:LONG_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithLongLong:LONG_LONG_MAX], [NSNumber numberWithUnsignedLongLong:LONG_LONG_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithShort:SHRT_MAX], [NSNumber numberWithInt:SHRT_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedChar:UCHAR_MAX], [NSNumber numberWithShort:UCHAR_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedInt:UINT_MAX], [NSNumber numberWithUnsignedLongLong:UINT_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedInteger:NSUIntegerMax], [NSNumber numberWithUnsignedLongLong:NSUIntegerMax]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedShort:USHRT_MAX], [NSNumber numberWithInt:USHRT_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnichar:USHRT_MAX], [NSNumber numberWithUnichar:USHRT_MAX]);
}

- (void) testEqualNumbersMinRange
{
	XCTAssertEqualObjects([NSMutableNumber numberWithBool:NO], [NSNumber numberWithBool:NO]);
	XCTAssertEqualObjects([NSMutableNumber numberWithChar:CHAR_MIN], [NSNumber numberWithChar:CHAR_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithDouble:DBL_MIN], [NSNumber numberWithDouble:DBL_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithFloat:FLT_MIN], [NSNumber numberWithFloat:FLT_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithInt:INT_MIN], [NSNumber numberWithInt:INT_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithInteger:NSIntegerMin], [NSNumber numberWithInteger:NSIntegerMin]);
	XCTAssertEqualObjects([NSMutableNumber numberWithLong:LONG_MIN], [NSNumber numberWithLong:LONG_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithLongLong:LONG_LONG_MIN], [NSNumber numberWithLongLong:LONG_LONG_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithShort:SHRT_MIN], [NSNumber numberWithShort:SHRT_MIN]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedChar:0], [NSNumber numberWithUnsignedChar:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedInt:0], [NSNumber numberWithUnsignedInt:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedInteger:0], [NSNumber numberWithUnsignedInteger:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedLong:0], [NSNumber numberWithUnsignedLong:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedLongLong:0], [NSNumber numberWithUnsignedLongLong:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedShort:0], [NSNumber numberWithUnsignedShort:0]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnichar:0], [NSNumber numberWithUnichar:0]);
}

- (void) testEqualNumbersMaxRange
{
	XCTAssertEqualObjects([NSMutableNumber numberWithBool:YES], [NSNumber numberWithBool:YES]);
	XCTAssertEqualObjects([NSMutableNumber numberWithChar:CHAR_MAX], [NSNumber numberWithChar:CHAR_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithDouble:DBL_MAX], [NSNumber numberWithDouble:DBL_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithFloat:FLT_MAX], [NSNumber numberWithFloat:FLT_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithInt:INT_MAX], [NSNumber numberWithInt:INT_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithInteger:NSIntegerMax], [NSNumber numberWithInteger:NSIntegerMax]);
	XCTAssertEqualObjects([NSMutableNumber numberWithLong:LONG_MAX], [NSNumber numberWithLong:LONG_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithLongLong:LONG_LONG_MAX], [NSNumber numberWithLongLong:LONG_LONG_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithShort:SHRT_MAX], [NSNumber numberWithShort:SHRT_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedChar:UCHAR_MAX], [NSNumber numberWithUnsignedChar:UCHAR_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedInt:UINT_MAX], [NSNumber numberWithUnsignedInt:UINT_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedInteger:NSUIntegerMax], [NSNumber numberWithUnsignedInteger:NSUIntegerMax]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedLong:ULONG_MAX], [NSNumber numberWithUnsignedLong:ULONG_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedLongLong:ULONG_LONG_MAX], [NSNumber numberWithUnsignedLongLong:ULONG_LONG_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnsignedShort:USHRT_MAX], [NSNumber numberWithUnsignedShort:USHRT_MAX]);
	XCTAssertEqualObjects([NSMutableNumber numberWithUnichar:USHRT_MAX], [NSNumber numberWithUnichar:USHRT_MAX]);
}

- (void) testEqualNumbersUnsigned
{
	NSMutableNumber * mutable = [[NSMutableNumber alloc] initWithInt:1];
	XCTAssertNotNil(mutable);

	XCTAssertEqualObjects(mutable, [NSNumber numberWithBool:YES]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithInt:1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithChar:1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithDouble:1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithFloat:1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithInteger:1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithLong:1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithLongLong:1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithUnsignedChar:1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithUnsignedInt:1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithUnsignedLong:1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithUnsignedShort:1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithUnichar:1]);
}

- (void) testEqualNumbersSigned
{
	NSMutableNumber * mutable = [[NSMutableNumber alloc] initWithInt:-1];
	XCTAssertNotNil(mutable);

	XCTAssertNotEqualObjects(mutable, [NSNumber numberWithBool:NO]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithInt:-1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithChar:-1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithDouble:-1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithFloat:-1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithInteger:-1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithLong:-1]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithLongLong:-1]);
	XCTAssertNotEqualObjects(mutable, [NSNumber numberWithUnsignedChar:-1]);
	XCTAssertNotEqualObjects(mutable, [NSNumber numberWithUnsignedInt:-1]);
	XCTAssertNotEqualObjects(mutable, [NSNumber numberWithUnsignedLong:-1]);
	XCTAssertNotEqualObjects(mutable, [NSNumber numberWithUnsignedShort:-1]);
	XCTAssertNotEqualObjects(mutable, [NSNumber numberWithUnichar:-1]);
}

- (void) testEqualNumbersByZero
{
	NSMutableNumber * mutable = [[NSMutableNumber alloc] initWithInt:0];
	XCTAssertNotNil(mutable);

	XCTAssertEqualObjects(mutable, [NSNumber numberWithBool:NO]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithInt:0]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithChar:0]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithDouble:0]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithFloat:0]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithInteger:0]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithLong:0]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithLongLong:0]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithUnsignedChar:0]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithUnsignedInt:0]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithUnsignedLong:0]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithUnsignedShort:0]);
	XCTAssertEqualObjects(mutable, [NSNumber numberWithUnichar:0]);
}

- (void) testUseAsNSNumber
{
	NSNumber * number = (NSNumber *)[[NSMutableNumber alloc] initWithInt:0];
	XCTAssertEqual([number isKindOfClass:[NSNumber class]], YES);

	XCTAssertEqual([number charValue], 0);
	XCTAssertEqual([number unsignedCharValue], 0);
	XCTAssertEqual([number shortValue], 0);
	XCTAssertEqual([number unsignedShortValue], 0);
	XCTAssertEqual([number unicharValue], 0);
	XCTAssertEqual([number intValue], 0);
	XCTAssertEqual([number unsignedIntValue], 0);
	XCTAssertEqual([number longValue], 0);
	XCTAssertEqual([number unsignedLongValue], 0);
	XCTAssertEqual([number longLongValue], 0);
	XCTAssertEqual([number unsignedLongLongValue], 0);
	XCTAssertEqual([number floatValue], 0);
	XCTAssertEqual([number doubleValue], 0);
	XCTAssertEqual([number boolValue], 0);
	XCTAssertEqual([number integerValue], 0);
	XCTAssertEqual([number unsignedIntegerValue], 0);
	XCTAssertEqual([[number stringValue] isEqualToString:@"0"], YES);
}

- (void)testBEMutableNumber_getValue
{
	NSMutableNumber	*reference = [NSMutableNumber numberWithChar:INT8_MIN];
	char c = 0;
	[reference getValue:&c];
	XCTAssertEqual(c, INT8_MIN);
	
	reference = [NSMutableNumber numberWithShort:INT16_MIN];
	short s = 0;
	[reference getValue:&s];
	XCTAssertEqual(s, INT16_MIN);
	
	reference = [NSMutableNumber numberWithInt:INT32_MIN];
	int i = 0;
	[reference getValue:&i];
	XCTAssertEqual(i, INT32_MIN);
	
	reference = [NSMutableNumber numberWithLongLong:INT64_MIN];
	long long ll = 0;
	[reference getValue:&ll];
	XCTAssertEqual(ll, INT64_MIN);
	
	reference = [NSMutableNumber numberWithUnsignedChar:INT8_MAX + 20];
	unsigned char uc = 0;
	[reference getValue:&uc];
	XCTAssertEqual(uc, INT8_MAX + 20);
	
	reference = [NSMutableNumber numberWithUnsignedShort:INT16_MAX + 4];
	unsigned short us = 0;
	[reference getValue:&us];
	XCTAssertEqual(us, INT16_MAX + 4);
	
	reference = [NSMutableNumber numberWithUnsignedInt:INT32_MAX + 10];
	unsigned int ui = 0;
	[reference getValue:&ui];
	XCTAssertEqual(ui, (unsigned long long)INT32_MAX + 10);
	
	reference = [NSMutableNumber numberWithUnsignedLongLong:INT64_MAX + 2];
	unsigned long long ull = 0;
	[reference getValue:&ull];
	XCTAssertEqual(ull, (unsigned long long)INT64_MAX + 2);
	
	
	
	reference = [NSMutableNumber numberWithFloat:2.2];
	float f = 0;
	[reference getValue:&f];
	XCTAssertEqualWithAccuracy(f, 2.2, 0.0001);
	
	reference = [NSMutableNumber numberWithDouble:100.1];
	double d = 0;
	[reference getValue:&d];
	XCTAssertEqual(d, 100.1);
}

- (void)testBEMutableNumber_initWithBytes
{
	BOOL b = YES;
	NSMutableNumber *result = [NSMutableNumber.alloc initWithBytes:&b objCType:@encode(BOOL)];
	XCTAssertEqualObjects(result, @(b));
	
	char c = INT8_MIN;
	result = [NSMutableNumber.alloc initWithBytes:&c objCType:@encode(char)];
	XCTAssertEqualObjects(result, @(c));
	
	short s = INT16_MIN;
	result = [NSMutableNumber.alloc initWithBytes:&s objCType:@encode(short)];
	XCTAssertEqualObjects(result, @(s));
	
	int i = INT32_MIN;
	result = [NSMutableNumber.alloc initWithBytes:&i objCType:@encode(int)];
	XCTAssertEqualObjects(result, @(i));
	
	long long  ll = INT64_MIN;
	result = [NSMutableNumber.alloc initWithBytes:&ll objCType:@encode(long long)];
	XCTAssertEqualObjects(result, @(ll));
	
	
	
	unsigned char uc = INT8_MAX + 1;
	result = [NSMutableNumber.alloc initWithBytes:&uc objCType:@encode(unsigned char)];
	XCTAssertEqualObjects(result, @(uc));
	
	unsigned short us = INT16_MAX + 1;
	result = [NSMutableNumber.alloc initWithBytes:&us objCType:@encode(unsigned short)];
	XCTAssertEqualObjects(result, @(us));
	
	unsigned int ui = (long long)INT32_MAX + 1;
	result = [NSMutableNumber.alloc initWithBytes:&ui objCType:@encode(unsigned int)];
	XCTAssertEqualObjects(result, @(ui));
	
	unsigned long long  ull = (unsigned long long)INT64_MAX + 1;
	result = [NSMutableNumber.alloc initWithBytes:&ull objCType:@encode(unsigned long long)];
	XCTAssertEqualObjects(result, @(ull));
	
	
	
	float f = 2.3;
	result = [NSMutableNumber.alloc initWithBytes:&f objCType:@encode(float)];
	XCTAssertEqualWithAccuracy(result.floatValue, f, 0.0001);
	
	double d = 100.1;
	result = [NSMutableNumber.alloc initWithBytes:&d objCType:@encode(double)];
	XCTAssertEqualObjects(result, @(d));
}

- (void)testBEMutableNumber_InitWithCoder
{
	NSMutableNumber	*reference = [NSMutableNumber numberWithDouble:M_PI];
	XCTAssertTrue([NSMutableNumber supportsSecureCoding]);
	
	NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:reference requiringSecureCoding:YES error:nil];
	XCTAssertNotNil(archivedData);
	NSMutableNumber *result = [NSKeyedUnarchiver unarchivedObjectOfClass:NSMutableNumber.class fromData:archivedData error:nil];
	
	XCTAssertNotNil(result);
	XCTAssertTrue([result isEqual:reference]);
}

- (void)testBEMutableNumber_InitWithCoder_BadParameter
{
	NSMutableNumber	*mutableNumber = [NSMutableNumber alloc];
	XCTAssertNil([mutableNumber initWithCoder:nil]);
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

// Unit test that actually uses NSArchiver to test classForCoder
- (void)testBEMutableNumber_ClassForCoder_OldMacOS
{
	NSMutableNumber *reference = [NSMutableNumber numberWithDouble:M_PI];
	
	// Test using NSArchiver (which uses classForCoder)
	NSData *archivedData = [NSArchiver archivedDataWithRootObject:reference];
	XCTAssertNotNil(archivedData, @"Archiving with NSArchiver should succeed");
	
	// Unarchive using NSUnarchiver
	NSMutableNumber *result = [NSUnarchiver unarchiveObjectWithData:archivedData];
	
	XCTAssertNotNil(result, @"Unarchiving should succeed");
	XCTAssertTrue([result isEqual:reference], @"Unarchived object should equal original");
	XCTAssertTrue([result isKindOfClass:[NSMutableNumber class]], @"Unarchived object should be NSMutableNumber");
	
	// Verify that classForCoder was used during archiving
	XCTAssertEqual([result class], [NSMutableNumber class], @"Result should be NSMutableNumber class");
}

#pragma clang diagnostic pop

- (void) testIsKindOfClass
{
	NSMutableNumber * mutableNumber = [[NSMutableNumber alloc] init];
	XCTAssertEqual([mutableNumber isKindOfClass:[NSValue class]], YES);
	XCTAssertEqual([mutableNumber isKindOfClass:[NSNumber class]], YES);
	XCTAssertEqual([mutableNumber isKindOfClass:[NSMutableNumber class]], YES);

	XCTAssertEqual([[[NSNumber numberWithBool:YES] mutableCopy] isKindOfClass:[NSValue class]], YES);
	XCTAssertEqual([[[NSNumber numberWithBool:YES] mutableCopy] isKindOfClass:[NSNumber class]], YES);
	XCTAssertEqual([[[NSNumber numberWithBool:YES] mutableCopy] isKindOfClass:[NSMutableNumber class]], YES);
}

- (void) testIsEqualToNumber
{
	XCTAssertEqual([[NSNumber numberWithInt:1] isEqualToNumber:(NSNumber *)[NSMutableNumber numberWithInt:0]], NO);
	XCTAssertEqual([[NSNumber numberWithInt:0] isEqualToNumber:(NSNumber *)[NSMutableNumber numberWithInt:0]], YES);
	XCTAssertEqual([[NSNumber numberWithInt:52] isEqualToNumber:(NSNumber *)[NSMutableNumber numberWithInt:52]], YES);
	XCTAssertEqual([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] isEqualToNumber:(NSNumber *)[NSMutableNumber numberWithUnsignedLongLong:ULLONG_MAX]], YES);
	
	XCTAssertEqual([[NSMutableNumber numberWithInt:1] isEqualToNumber:[NSNumber numberWithInt:0]], NO);
	XCTAssertEqual([[NSMutableNumber numberWithInt:0] isEqualToNumber:[NSNumber numberWithInt:0]], YES);
	XCTAssertEqual([[NSMutableNumber numberWithInt:52] isEqualToNumber:[NSNumber numberWithInt:52]], YES);
	XCTAssertEqual([[NSMutableNumber numberWithUnsignedLongLong:ULLONG_MAX] isEqualToNumber:[NSNumber numberWithUnsignedLongLong:ULLONG_MAX]], YES);
	
	XCTAssertEqual([[NSMutableNumber numberWithInt:1] isEqualToNumber:[NSMutableNumber numberWithInt:0]], NO);
	XCTAssertEqual([[NSMutableNumber numberWithInt:0] isEqualToNumber:[NSMutableNumber numberWithInt:0]], YES);
	XCTAssertEqual([[NSMutableNumber numberWithInt:52] isEqualToNumber:[NSMutableNumber numberWithInt:52]], YES);
	XCTAssertEqual([[NSMutableNumber numberWithUnsignedLongLong:ULLONG_MAX] isEqualToNumber:[NSMutableNumber numberWithUnsignedLongLong:ULLONG_MAX]], YES);
}

- (void) testCompareSignedTo
{
	// Compare Double against all other types.
	NSMutableNumber *leftNumber = [NSMutableNumber numberWithInteger:10];
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:9]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:10]], NSOrderedSame);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:11]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:9]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:10]], NSOrderedSame);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:11]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:9.0]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:9.9]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:10.0]], NSOrderedSame);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:10.1]], NSOrderedAscending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:11.0]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:NSMutableNumber.infinity], NSOrderedAscending);
	XCTAssertEqual([leftNumber compare:NSMutableNumber.minusInfinity], NSOrderedDescending);
	
	XCTAssertEqual([[NSMutableNumber numberWithInteger:1] compare:NSMutableNumber.notANumber], NSOrderedDescending);
	XCTAssertEqual([[NSMutableNumber numberWithInteger:0] compare:NSMutableNumber.notANumber], NSOrderedDescending);
	XCTAssertEqual([[NSMutableNumber numberWithInteger:-1] compare:NSMutableNumber.notANumber], NSOrderedAscending);
	
	NSNumber *reference = [NSNumber numberWithInteger:10];
	XCTAssertEqual([reference compare:@(INFINITY)], NSOrderedAscending);
	XCTAssertEqual([reference compare:@(-INFINITY)], NSOrderedDescending);
	XCTAssertEqual([@(1) compare:@(NAN)], NSOrderedDescending);
	XCTAssertEqual([@(0) compare:@(NAN)], NSOrderedDescending);
	XCTAssertEqual([@(-1) compare:@(NAN)], NSOrderedAscending);
	
	XCTAssertEqual(((NSInteger)INFINITY), 0);
	XCTAssertEqual(((NSInteger)-INFINITY), 0);
	XCTAssertEqual(((NSUInteger)INFINITY), 0);
	XCTAssertEqual(((NSInteger)NAN), 0);
	
	
	
	leftNumber = [NSMutableNumber numberWithInteger:-10];
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:-11]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:-10]], NSOrderedSame);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:-9]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:9]], NSOrderedAscending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:10]], NSOrderedAscending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:11]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:-11.0]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:-10.1]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:-10.0]], NSOrderedSame);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:-9.9]], NSOrderedAscending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:-9.0]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:NSMutableNumber.infinity], NSOrderedAscending);
	XCTAssertEqual([leftNumber compare:NSMutableNumber.minusInfinity], NSOrderedDescending);
	
	reference = [NSNumber numberWithInteger:-10];
	XCTAssertEqual([reference compare:@(INFINITY)], NSOrderedAscending);
	XCTAssertEqual([reference compare:@(-INFINITY)], NSOrderedDescending);
}

- (void) testCompareUnsignedTo
{
	// Compare Double against all other types.
	NSMutableNumber *leftNumber = [NSMutableNumber numberWithUnsignedInteger:10];
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:9]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:10]], NSOrderedSame);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:11]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:9]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:10]], NSOrderedSame);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:11]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:9.0]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:9.9]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:10.0]], NSOrderedSame);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:10.1]], NSOrderedAscending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:11.0]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:NSMutableNumber.infinity], NSOrderedAscending);
	XCTAssertEqual([leftNumber compare:NSMutableNumber.minusInfinity], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:NSMutableNumber.notANumber], NSOrderedDescending);
	
	XCTAssertEqual([[NSMutableNumber numberWithUnsignedInteger:0] compare:NSMutableNumber.notANumber], NSOrderedDescending);
	
	XCTAssertEqual([[NSNumber numberWithUnsignedInteger:0] compare:NSNumber.notANumber], NSOrderedDescending);
	
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:-11]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:-10]], NSOrderedDescending);
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:-11]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:-10.5]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:-10]], NSOrderedDescending);
}

- (void) testCompareRealTo
{
	// Compare Double against all other types.
	NSMutableNumber *leftNumber = [NSMutableNumber numberWithDouble:10.5];
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:10]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:11]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:10]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:11]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:10.0]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:10.5]], NSOrderedSame);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:11.0]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:NSMutableNumber.infinity], NSOrderedAscending);
	XCTAssertEqual([leftNumber compare:NSMutableNumber.minusInfinity], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:NSMutableNumber.notANumber], NSOrderedDescending);
	
	XCTAssertEqual([[NSMutableNumber numberWithDouble:INFINITY] compare:NSMutableNumber.infinity], NSOrderedSame);
	XCTAssertEqual([[NSMutableNumber numberWithDouble:-INFINITY] compare:NSMutableNumber.minusInfinity], NSOrderedSame);
	XCTAssertEqual([[NSMutableNumber numberWithDouble:NAN] compare:NSMutableNumber.notANumber], NSOrderedSame);
	
	XCTAssertEqual([[NSMutableNumber numberWithDouble:0.1] compare:NSMutableNumber.notANumber], NSOrderedDescending);
	XCTAssertEqual([[NSMutableNumber numberWithDouble:0.0] compare:NSMutableNumber.notANumber], NSOrderedDescending);
	XCTAssertEqual([[NSMutableNumber numberWithDouble:-0.0] compare:NSMutableNumber.notANumber], NSOrderedAscending);
	XCTAssertEqual([[NSMutableNumber numberWithDouble:-0.1] compare:NSMutableNumber.notANumber], NSOrderedAscending);
	
	XCTAssertEqual([NSMutableNumber.notANumber compare:[NSMutableNumber numberWithDouble:0.1]], NSOrderedAscending);
	XCTAssertEqual([NSMutableNumber.notANumber compare:[NSMutableNumber numberWithDouble:0.0]], NSOrderedAscending);
	XCTAssertEqual([NSMutableNumber.notANumber compare:[NSMutableNumber numberWithDouble:-0.0]], NSOrderedDescending);
	XCTAssertEqual([NSMutableNumber.notANumber compare:[NSMutableNumber numberWithDouble:-0.1]], NSOrderedDescending);
	XCTAssertEqual([[NSMutableNumber numberWithDouble:0.0] compare:[NSMutableNumber numberWithDouble:-0.0]], NSOrderedSame);
	
	XCTAssertEqual([NSMutableNumber.notANumber compare:[NSMutableNumber numberWithInteger:1]], NSOrderedAscending);
	XCTAssertEqual([NSMutableNumber.notANumber compare:[NSMutableNumber numberWithInteger:0]], NSOrderedAscending);
	XCTAssertEqual([NSMutableNumber.notANumber compare:[NSMutableNumber numberWithInteger:-1]], NSOrderedDescending);
	
	XCTAssertEqual([NSMutableNumber.notANumber compare:[NSMutableNumber numberWithUnsignedInteger:1]], NSOrderedAscending);
	XCTAssertEqual([NSMutableNumber.notANumber compare:[NSMutableNumber numberWithUnsignedInteger:0]], NSOrderedAscending);
	//Reference
	XCTAssertEqual([@(INFINITY) compare:@(INFINITY)], NSOrderedSame);
	XCTAssertEqual([@(-INFINITY) compare:@(-INFINITY)], NSOrderedSame);
	XCTAssertEqual([@(NAN) compare:@(NAN)], NSOrderedSame);
	XCTAssertEqual([@(0.1) compare:@(NAN)], NSOrderedDescending);
	XCTAssertEqual([@(0.0) compare:@(NAN)], NSOrderedDescending);
	XCTAssertEqual([@(-0.0) compare:@(NAN)], NSOrderedAscending);
	XCTAssertEqual([@(-0.1) compare:@(NAN)], NSOrderedAscending);
	XCTAssertEqual([@(0.0) compare:@(-0.0)], NSOrderedSame);
	
	
	leftNumber = [NSMutableNumber numberWithDouble:-10.5];
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:-11]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithInteger:-10]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:10]], NSOrderedAscending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithUnsignedInteger:11]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:-11.0]], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:-10.5]], NSOrderedSame);
	XCTAssertEqual([leftNumber compare:[NSMutableNumber numberWithDouble:-10.0]], NSOrderedAscending);
	
	XCTAssertEqual([leftNumber compare:NSMutableNumber.infinity], NSOrderedAscending);
	XCTAssertEqual([leftNumber compare:NSMutableNumber.minusInfinity], NSOrderedDescending);
	XCTAssertEqual([leftNumber compare:NSMutableNumber.notANumber], NSOrderedAscending);
	
}

- (void)testNSMutableNumber_infinity
{
	XCTAssertEqualObjects(NSMutableNumber.infinity, @(INFINITY));
	XCTAssertTrue(NSMutableNumber.infinity.isInfinity);
}

- (void)testNSMutableNumber_minusInfinity
{
	XCTAssertEqualObjects(NSMutableNumber.minusInfinity, @(-INFINITY));
	XCTAssertTrue(NSMutableNumber.minusInfinity.isNegativeInfinity);
}

- (void)testNSMutableNumber_notANumber
{
	XCTAssertEqualObjects(NSMutableNumber.notANumber, @(NAN));
	XCTAssertTrue(NSMutableNumber.notANumber.isNotANumber);
}

- (void)testNSMutableNumber_zero
{
	XCTAssertEqualObjects(NSMutableNumber.zero, @(0));
	XCTAssertTrue(NSMutableNumber.zero.isPositiveZero);
	XCTAssertTrue(NSMutableNumber.zero.isZero);
	XCTAssertFalse(NSMutableNumber.zero.isNegativeZero);
}

- (void)testNSMutableNumber_negativeZero
{
	XCTAssertEqualObjects(NSMutableNumber.negativeZero, @(-0.0));
	XCTAssertFalse(NSMutableNumber.negativeZero.isPositiveZero);
	XCTAssertTrue(NSMutableNumber.negativeZero.isZero);
	XCTAssertTrue(NSMutableNumber.negativeZero.isNegativeZero);
}

- (void)testNSMutableNumber_one
{
	XCTAssertEqualObjects(NSMutableNumber.one, @(1));
	XCTAssertTrue(NSMutableNumber.one.isOne);
}

- (void) testNSMutableNumber_Descriptions
{
	NSMutableNumber *n = [NSMutableNumber numberWithInt:13];
	XCTAssertEqualObjects([n description], @"13");
	
	n = [NSMutableNumber numberWithInt:14];
	XCTAssertEqualObjects([n descriptionWithLocale:nil], @"14");
	
	n = [NSMutableNumber numberWithInt:15];
	XCTAssertEqualObjects([n debugDescription], @"15");
}

- (void) testNSMutableNumber_Hash
{
	XCTAssertEqual([[NSNumber numberWithBool:YES] hash], [[NSMutableNumber numberWithBool:YES] hash]);
	XCTAssertEqual([[NSNumber numberWithBool:NO] hash], [[NSMutableNumber numberWithBool:NO] hash]);

	XCTAssertEqual([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] hash], [[NSMutableNumber numberWithUnsignedLongLong:ULLONG_MAX] hash]);
	XCTAssertEqual([[NSNumber numberWithInt:-1] hash], [[NSMutableNumber numberWithInt:-1] hash]);
	NSMutableNumber *mutableNumber = [NSMutableNumber numberWithShort:2];
	XCTAssertEqual([[NSNumber numberWithInt:2] hash], [mutableNumber hash]);
	
	mutableNumber.charValue = 3;
	XCTAssertEqual([[NSNumber numberWithInt:3] hash], [mutableNumber hash]);
	
	mutableNumber.unsignedCharValue = 4;
	XCTAssertEqual([[NSNumber numberWithInt:4] hash], [mutableNumber hash]);
	
	mutableNumber.shortValue = 5;
	XCTAssertEqual([[NSNumber numberWithInt:5] hash], [mutableNumber hash]);
	
	mutableNumber.unsignedShortValue = 6;
	XCTAssertEqual([[NSNumber numberWithInt:6] hash], [mutableNumber hash]);
	
	mutableNumber.unicharValue = 10;
	XCTAssertEqual([[NSNumber numberWithInt:10] hash], [mutableNumber hash]);
	
	mutableNumber.intValue = 7;
	XCTAssertEqual([[NSNumber numberWithInt:7] hash], [mutableNumber hash]);
	
	mutableNumber.unsignedIntValue = 8;
	XCTAssertEqual([[NSNumber numberWithInt:8] hash], [mutableNumber hash]);
	
	mutableNumber.longValue = 9;
	XCTAssertEqual([[NSNumber numberWithInt:9] hash], [mutableNumber hash]);
	
	mutableNumber.unsignedLongValue = 10;
	XCTAssertEqual([[NSNumber numberWithInt:10] hash], [mutableNumber hash]);
	
	mutableNumber.longLongValue = 11;
	XCTAssertEqual([[NSNumber numberWithInt:11] hash], [mutableNumber hash]);
	
	mutableNumber.unsignedLongLongValue = 12;
	XCTAssertEqual([[NSNumber numberWithInt:12] hash], [mutableNumber hash]);
	
	mutableNumber.floatValue = 1;
	XCTAssertEqual([[NSNumber numberWithFloat:1] hash], [mutableNumber hash]);
	
	mutableNumber.doubleValue = 10;
	XCTAssertEqual([[NSNumber numberWithDouble:10] hash], [mutableNumber hash]);
	
	mutableNumber.boolValue = 1;
	XCTAssertEqual([[NSNumber numberWithBool:1] hash], [mutableNumber hash]);
	
	mutableNumber.boolValue = 0;
	XCTAssertEqual([[NSNumber numberWithBool:0] hash], [mutableNumber hash]);
	
	mutableNumber.integerValue = -2;
	XCTAssertEqual([[NSNumber numberWithInteger:-2] hash], [mutableNumber hash]);
	
	mutableNumber.unsignedIntegerValue = 3;
	XCTAssertEqual([[NSNumber numberWithUnsignedInteger:3] hash], [mutableNumber hash]);
	
	mutableNumber.unicharValue = 4;
	XCTAssertEqual([[NSNumber numberWithUnsignedInteger:4] hash], [mutableNumber hash]);
}

- (void)testNSMutableNumber_unichar
{
	NSMutableNumber *unichar = [NSMutableNumber numberWithUnichar: 0];
	XCTAssertEqual(unichar.unicharValue, 0);
	
	unichar = [NSMutableNumber numberWithUnichar: 1];
	XCTAssertEqual(unichar.unicharValue, 1);
	
	unichar = [NSMutableNumber numberWithUnichar: USHRT_MAX - 1];
	XCTAssertEqual(unichar.unicharValue, USHRT_MAX - 1);
	
	unichar = [NSMutableNumber numberWithUnichar: USHRT_MAX];
	XCTAssertEqual(unichar.unicharValue, USHRT_MAX);
}

- (void)testNSMutableNumber_copyWithZone
{
	NSMutableNumber *unichar = [NSMutableNumber numberWithUnichar: 11];
	XCTAssertTrue([unichar isKindOfClass:NSNumber.class]);
	XCTAssertTrue([unichar isKindOfClass:NSValue.class]);
	XCTAssertTrue([unichar isKindOfClass:NSMutableNumber.class]);
	XCTAssertEqual(unichar.unicharValue, 11);
	
	NSNumber *number = [unichar copy];
	XCTAssertTrue([number isKindOfClass:NSNumber.class]);
	XCTAssertTrue([number isKindOfClass:NSValue.class]);
	XCTAssertTrue([number isKindOfClass:NSMutableNumber.class]);
	XCTAssertEqual(number.unicharValue, 11);
	
	XCTAssertEqual([[NSMutableNumber numberWithChar: -1] copy].charValue, -1);
	XCTAssertEqual([[NSMutableNumber numberWithShort: -1] copy].shortValue, -1);
	XCTAssertEqual([[NSMutableNumber numberWithInt: -1] copy].intValue, -1);
	XCTAssertEqual([[NSMutableNumber numberWithLongLong: -1] copy].longLongValue, -1);
	
	XCTAssertEqual([[NSMutableNumber numberWithFloat: 10.0] copy].floatValue, 10.0);
	XCTAssertEqual([[NSMutableNumber numberWithDouble: M_PI] copy].doubleValue, M_PI);
	
	XCTAssertEqual([[NSMutableNumber numberWithUnsignedChar: 200] copy].unsignedCharValue, 200);
	XCTAssertEqual([[NSMutableNumber numberWithUnsignedShort: 34000] copy].unsignedShortValue, 34000);
	XCTAssertEqual([[NSMutableNumber numberWithUnsignedInt: 0xb0000000] copy].unsignedIntValue, 0xb0000000);
	XCTAssertEqual([[NSMutableNumber numberWithLongLong: 0xc000000000000000] copy].unsignedLongLongValue, 0xc000000000000000);
	
	long n = 535353;
	NSMutableNumber *mutableNumber =[NSMutableNumber numberWithLong:n];
	XCTAssertEqualObjects([mutableNumber copy], [NSNumber numberWithLong:n]);
	
	mutableNumber = [NSMutableNumber numberWithLong:535353];
	XCTAssertEqualObjects([mutableNumber copy], (NSNumber*)mutableNumber);
	XCTAssertEqualObjects(mutableNumber, [mutableNumber copy]);
}

- (void)testNSMutableNumber_mutableCopyWithZone
{
	NSMutableNumber *unichar = [NSMutableNumber numberWithUnichar: 11];
	XCTAssertTrue([unichar isKindOfClass:NSMutableNumber.class]);
	XCTAssertEqual(unichar.unicharValue, 11);
	
	NSMutableNumber *mutableNumber = [unichar mutableCopy];
	XCTAssertTrue([mutableNumber isMemberOfClass:NSMutableNumber.class]);
	XCTAssertEqual(mutableNumber.unicharValue, 11);
	
	XCTAssertEqualObjects(mutableNumber, unichar);
}


- (void)testNSMutableNumber_bitNot
{
	NSMutableNumber *unichar = [NSMutableNumber numberWithBool: YES];
	XCTAssertEqual(unichar.boolValue, YES);
	XCTAssertEqual(unichar.bitNot.charValue & 0x1, NO);
	
	unichar = [NSMutableNumber numberWithChar: (char)0xb9];
	XCTAssertEqual(unichar.bitNot.charValue, ~(char)0xb9);
	
	unichar = [NSMutableNumber numberWithUnsignedChar: (unsigned char)0x7b];
	XCTAssertEqual(unichar.bitNot.unsignedCharValue, (unsigned char)~0x7b);
	
	unichar = [NSMutableNumber numberWithShort: (short)0x9b5e];
	XCTAssertEqual(unichar.bitNot.shortValue, ~(short)0x9b5e);
	
	unichar = [NSMutableNumber numberWithUnsignedShort: (unsigned short)0x9b5d];
	XCTAssertEqual(unichar.bitNot.unsignedShortValue, (unsigned short)~0x9b5d);
	
	unichar = [NSMutableNumber numberWithInt: (int)0x9b5e37af];
	XCTAssertEqual(unichar.bitNot.intValue, ~(int)0x9b5e37af);
	
	unichar = [NSMutableNumber numberWithUnsignedInt: (unsigned int)0x37af9b5e];
	XCTAssertEqual(unichar.bitNot.unsignedIntValue, (unsigned int)~0x37af9b5e);
	
	unichar = [NSMutableNumber numberWithInteger: (NSInteger)0x9baf5e37];
	XCTAssertEqual(unichar.bitNot.integerValue, ~(NSInteger)0x9baf5e37);
	
	unichar = [NSMutableNumber numberWithUnsignedInteger: (NSUInteger)0xae379baf];
	XCTAssertEqual(unichar.bitNot.unsignedIntegerValue, ~(NSUInteger)0xae379baf);
	
	unichar = [NSMutableNumber numberWithLong: (long)0x7af0083937af9b5e];
	XCTAssertEqual(unichar.bitNot.longValue, ~(long)0x7af0083937af9b5e);
	
	unichar = [NSMutableNumber numberWithUnsignedLong: (unsigned long)0x37af9b5e7af00839];
	XCTAssertEqual(unichar.bitNot.unsignedLongValue, ~(unsigned long)0x37af9b5e7af00839);
	
	unichar = [NSMutableNumber numberWithLongLong: (long long)0x7af00839efdd24bf];
	XCTAssertEqual(unichar.bitNot.longLongValue, ~(long long)0x7af00839efdd24bf);
	
	unichar = [NSMutableNumber numberWithUnsignedLongLong: (unsigned long long)0x7af024bf0839efdd];
	XCTAssertEqual(unichar.bitNot.unsignedLongLongValue, ~(unsigned long long)0x7af024bf0839efdd);
	
	unichar = [NSMutableNumber numberWithFloat: 13];
	XCTAssertEqual(unichar.bitNotValue, ~13);
	
	unichar = [NSMutableNumber numberWithDouble: 28];
	XCTAssertEqual(unichar.bitNotValue, ~28);
}

- (void)testNSMutableNumber_bitNotValue
{
	NSMutableNumber *unichar = [NSMutableNumber numberWithBool: YES];
	XCTAssertEqual(unichar.bitNotValue, ~(BOOL)YES);
	
	unichar = [NSMutableNumber numberWithChar: 0xb9];
	XCTAssertEqual(unichar.bitNotValue, ~(char)0xb9);
	
	unichar = [NSMutableNumber numberWithUnsignedChar: 0x9b];
	XCTAssertEqual(unichar.bitNotValue, ~(unsigned char)0x9b);
	
	unichar = [NSMutableNumber numberWithShort: 0x9b5e];
	XCTAssertEqual(unichar.bitNotValue, ~(short)0x9b5e);
	
	unichar = [NSMutableNumber numberWithUnsignedShort: 0x9b5d];
	XCTAssertEqual(unichar.bitNotValue, ~(unsigned short)0x9b5d);
	
	unichar = [NSMutableNumber numberWithInt: 0x9b5e37af];
	XCTAssertEqual(unichar.bitNotValue, ~(int)0x9b5e37af);
	
	unichar = [NSMutableNumber numberWithUnsignedInt: 0x37af9b5e];
	XCTAssertEqual(unichar.bitNotValue, ~(unsigned int)0x37af9b5e);
	
	unichar = [NSMutableNumber numberWithInteger: 0x9baf5e37];
	XCTAssertEqual(unichar.bitNotValue, ~(NSInteger)0x9baf5e37);
	
	unichar = [NSMutableNumber numberWithUnsignedInteger: 0x5e379baf];
	XCTAssertEqual(unichar.bitNotValue, ~(NSUInteger)0x5e379baf);
	
	unichar = [NSMutableNumber numberWithLong: 0x7af0083937af9b5e];
	XCTAssertEqual(unichar.bitNotValue, ~(long)0x7af0083937af9b5e);
	
	unichar = [NSMutableNumber numberWithUnsignedLong: 0x37af9b5e7af00839];
	XCTAssertEqual(unichar.bitNotValue, ~(unsigned long)0x37af9b5e7af00839);
	
	unichar = [NSMutableNumber numberWithLongLong: 0x7af00839efdd24bf];
	XCTAssertEqual(unichar.bitNotValue, ~(long long)0x7af00839efdd24bf);
	
	unichar = [NSMutableNumber numberWithUnsignedLongLong: 0x7af024bf0839efdd];
	XCTAssertEqual(unichar.bitNotValue, ~(unsigned long long)0x7af024bf0839efdd);
	
	unichar = [NSMutableNumber numberWithFloat: 13];
	XCTAssertEqual(unichar.bitNot.unsignedLongLongValue, ~13);
	
	unichar = [NSMutableNumber numberWithDouble: 28];
	XCTAssertEqual(unichar.bitNot.unsignedLongLongValue, ~28);
}

- (void)testNSMutableNumber_plusOne
{
	NSMutableNumber *unichar = [NSMutableNumber numberWithBool: NO];
	XCTAssertEqual(unichar.plusOne.boolValue, YES);
	
	unichar = [NSMutableNumber numberWithBool: YES];
	XCTAssertEqual(unichar.plusOne.boolValue, YES);
	
	unichar = [NSMutableNumber numberWithChar: 0xb9];
	XCTAssertEqual(unichar.plusOne.charValue, (signed char)0xba);
	
	unichar = [NSMutableNumber numberWithUnsignedChar: 0x9b];
	XCTAssertEqual(unichar.plusOne.unsignedCharValue, 0x9c);
	
	unichar = [NSMutableNumber numberWithShort: 0x9b5e];
	XCTAssertEqual(unichar.plusOne.shortValue, (signed short)0x9b5f);
	
	unichar = [NSMutableNumber numberWithUnsignedShort: 0x9b5d];
	XCTAssertEqual(unichar.plusOne.unsignedShortValue, 0x9b5e);
	
	unichar = [NSMutableNumber numberWithInt: 0x9b5e37af];
	XCTAssertEqual(unichar.plusOne.intValue, 0x9b5e37b0);
	
	unichar = [NSMutableNumber numberWithUnsignedInt: 0x37af9b5e];
	XCTAssertEqual(unichar.plusOne.unsignedIntValue, 0x37af9b5f);
	
	unichar = [NSMutableNumber numberWithInteger: 0x9baf5e37];
	XCTAssertEqual(unichar.plusOne.integerValue, 0x9baf5e38);
	
	unichar = [NSMutableNumber numberWithUnsignedInteger: 0x5e379baf];
	XCTAssertEqual(unichar.plusOne.unsignedIntegerValue, 0x5e379bb0);
	
	unichar = [NSMutableNumber numberWithLong: 0x7af0083937af9b5e];
	XCTAssertEqual(unichar.plusOne.longValue, 0x7af0083937af9b5f);
	
	unichar = [NSMutableNumber numberWithUnsignedLong: 0x37af9b5e7af00839];
	XCTAssertEqual(unichar.plusOne.unsignedLongValue, 0x37af9b5e7af0083a);
	
	unichar = [NSMutableNumber numberWithLongLong: 0x7af00839efdd24bf];
	XCTAssertEqual(unichar.plusOne.longLongValue, 0x7af00839efdd24c0);
	
	unichar = [NSMutableNumber numberWithUnsignedLongLong: 0x7af024bf0839efdd];
	XCTAssertEqual(unichar.plusOne.unsignedLongLongValue, 0x7af024bf0839efde);
	
	unichar = [NSMutableNumber numberWithFloat: 3.5];
	XCTAssertEqual(unichar.plusOne.floatValue, 4.5);
	
	unichar = [NSMutableNumber numberWithDouble: 10.5];
	XCTAssertEqual(unichar.plusOne.doubleValue, 11.5);
}

- (void)testNSMutableNumber_subtractOne
{
	NSMutableNumber *unichar = [NSMutableNumber numberWithBool: NO];
	XCTAssertEqual(unichar.subtractOne.boolValue, YES);
	
	unichar = [NSMutableNumber numberWithBool: YES];
	XCTAssertEqual(unichar.subtractOne.boolValue, NO);
	
	unichar = [NSMutableNumber numberWithChar: 0xb9];
	XCTAssertEqual(unichar.subtractOne.charValue, (signed char)0xb8);
	
	unichar = [NSMutableNumber numberWithUnsignedChar: 0x9b];
	XCTAssertEqual(unichar.subtractOne.unsignedCharValue, 0x9a);
	
	unichar = [NSMutableNumber numberWithShort: 0x7b5e];
	XCTAssertEqual(unichar.subtractOne.shortValue, 0x7b5d);
	
	unichar = [NSMutableNumber numberWithShort: 0x9b5e];
	XCTAssertEqual(unichar.subtractOne.shortValue, (signed short)0x9b5d);
	
	unichar = [NSMutableNumber numberWithUnsignedShort: 0x9b5d];
	XCTAssertEqual(unichar.subtractOne.unsignedShortValue, 0x9b5c);
	
	unichar = [NSMutableNumber numberWithInt: 0x9b5e37af];
	XCTAssertEqual(unichar.subtractOne.intValue, 0x9b5e37ae);
	
	unichar = [NSMutableNumber numberWithUnsignedInt: 0x37af9b5e];
	XCTAssertEqual(unichar.subtractOne.unsignedIntValue, 0x37af9b5d);
	
	unichar = [NSMutableNumber numberWithInteger: 0x9baf5e37];
	XCTAssertEqual(unichar.subtractOne.integerValue, 0x9baf5e36);
	
	unichar = [NSMutableNumber numberWithUnsignedInteger: 0x5e379baf];
	XCTAssertEqual(unichar.subtractOne.unsignedIntegerValue, 0x5e379bae);
	
	unichar = [NSMutableNumber numberWithLong: 0x7af0083937af9b5e];
	XCTAssertEqual(unichar.subtractOne.longValue, 0x7af0083937af9b5d);
	
	unichar = [NSMutableNumber numberWithUnsignedLong: 0x37af9b5e7af00839];
	XCTAssertEqual(unichar.subtractOne.unsignedLongValue, 0x37af9b5e7af00838);
	
	unichar = [NSMutableNumber numberWithLongLong: 0x7af00839efdd24bf];
	XCTAssertEqual(unichar.subtractOne.longLongValue, 0x7af00839efdd24be);
	
	unichar = [NSMutableNumber numberWithUnsignedLongLong: 0x7af024bf0839efdd];
	XCTAssertEqual(unichar.subtractOne.unsignedLongLongValue, 0x7af024bf0839efdc);
	
	unichar = [NSMutableNumber numberWithFloat: 3.5];
	XCTAssertEqual(unichar.subtractOne.floatValue, 2.5);
	
	unichar = [NSMutableNumber numberWithDouble: 10.5];
	XCTAssertEqual(unichar.subtractOne.doubleValue, 9.5);
}

- (void)testNSMutableNumber_addOne
{
	NSMutableNumber *unichar = [NSMutableNumber numberWithBool: NO];
	XCTAssertEqual([unichar addOne].boolValue, YES);
	XCTAssertEqual([unichar addOne], unichar);
	
	unichar = [NSMutableNumber numberWithBool: YES];
	XCTAssertEqual([unichar addOne].boolValue, YES);
	
	unichar = [NSMutableNumber numberWithChar: 0xb9];
	XCTAssertEqual([unichar addOne].charValue, (signed char)0xba);
	
	unichar = [NSMutableNumber numberWithUnsignedChar: 0x9b];
	XCTAssertEqual([unichar addOne].unsignedCharValue, 0x9c);
	
	unichar = [NSMutableNumber numberWithShort: 0x9b5e];
	XCTAssertEqual([unichar addOne].shortValue, (signed short)0x9b5f);
	
	unichar = [NSMutableNumber numberWithUnsignedShort: 0x9b5d];
	XCTAssertEqual([unichar addOne].unsignedShortValue, 0x9b5e);
	
	unichar = [NSMutableNumber numberWithInt: 0x9b5e37af];
	XCTAssertEqual([unichar addOne].intValue, 0x9b5e37b0);
	
	unichar = [NSMutableNumber numberWithUnsignedInt: 0x37af9b5e];
	XCTAssertEqual([unichar addOne].unsignedIntValue, 0x37af9b5f);
	
	unichar = [NSMutableNumber numberWithInteger: 0x9baf5e37];
	XCTAssertEqual([unichar addOne].integerValue, 0x9baf5e38);
	
	unichar = [NSMutableNumber numberWithUnsignedInteger: 0x5e379baf];
	XCTAssertEqual([unichar addOne].unsignedIntegerValue, 0x5e379bb0);
	
	unichar = [NSMutableNumber numberWithLong: 0x7af0083937af9b5e];
	XCTAssertEqual([unichar addOne].longValue, 0x7af0083937af9b5f);
	
	unichar = [NSMutableNumber numberWithUnsignedLong: 0x37af9b5e7af00839];
	XCTAssertEqual([unichar addOne].unsignedLongValue, 0x37af9b5e7af0083a);
	
	unichar = [NSMutableNumber numberWithLongLong: 0x7af00839efdd24bf];
	XCTAssertEqual([unichar addOne].longLongValue, 0x7af00839efdd24c0);
	
	unichar = [NSMutableNumber numberWithUnsignedLongLong: 0x7af024bf0839efdd];
	XCTAssertEqual([unichar addOne].unsignedLongLongValue, 0x7af024bf0839efde);
	
	unichar = [NSMutableNumber numberWithFloat: 1.5];
	XCTAssertEqual([unichar addOne].floatValue, 2.5);
	
	unichar = [NSMutableNumber numberWithDouble: 3.5];
	XCTAssertEqual([unichar addOne].doubleValue, 4.5);
}

- (void)testNSMutableNumber_minusOne
{
	NSMutableNumber *unichar = [NSMutableNumber numberWithBool: NO];
	XCTAssertEqual([unichar minusOne].boolValue, YES);
	XCTAssertEqual([unichar minusOne], unichar);
	
	unichar = [NSMutableNumber numberWithBool: YES];
	XCTAssertEqual([unichar minusOne].boolValue, NO);
	
	unichar = [NSMutableNumber numberWithChar: 0xb9];
	XCTAssertEqual([unichar minusOne].charValue, (signed char)0xb8);
	
	unichar = [NSMutableNumber numberWithUnsignedChar: 0x9b];
	XCTAssertEqual([unichar minusOne].unsignedCharValue, 0x9a);
	
	unichar = [NSMutableNumber numberWithShort: 0x7b5e];
	XCTAssertEqual([unichar minusOne].shortValue, 0x7b5d);
	
	unichar = [NSMutableNumber numberWithShort: 0x9b5e];
	XCTAssertEqual([unichar minusOne].shortValue, (signed short)0x9b5d);
	
	unichar = [NSMutableNumber numberWithUnsignedShort: 0x9b5d];
	XCTAssertEqual([unichar minusOne].unsignedShortValue, 0x9b5c);
	
	unichar = [NSMutableNumber numberWithInt: 0x9b5e37af];
	XCTAssertEqual([unichar minusOne].intValue, 0x9b5e37ae);
	
	unichar = [NSMutableNumber numberWithUnsignedInt: 0x37af9b5e];
	XCTAssertEqual([unichar minusOne].unsignedIntValue, 0x37af9b5d);
	
	unichar = [NSMutableNumber numberWithInteger: 0x9baf5e37];
	XCTAssertEqual([unichar minusOne].integerValue, 0x9baf5e36);
	
	unichar = [NSMutableNumber numberWithUnsignedInteger: 0x5e379baf];
	XCTAssertEqual([unichar minusOne].unsignedIntegerValue, 0x5e379bae);
	
	unichar = [NSMutableNumber numberWithLong: 0x7af0083937af9b5e];
	XCTAssertEqual([unichar minusOne].longValue, 0x7af0083937af9b5d);
	
	unichar = [NSMutableNumber numberWithUnsignedLong: 0x37af9b5e7af00839];
	XCTAssertEqual([unichar minusOne].unsignedLongValue, 0x37af9b5e7af00838);
	
	unichar = [NSMutableNumber numberWithLongLong: 0x7af00839efdd24bf];
	XCTAssertEqual([unichar minusOne].longLongValue, 0x7af00839efdd24be);
	
	unichar = [NSMutableNumber numberWithUnsignedLongLong: 0x7af024bf0839efdd];
	XCTAssertEqual([unichar minusOne].unsignedLongLongValue, 0x7af024bf0839efdc);
	
	unichar = [NSMutableNumber numberWithFloat: 1.5];
	XCTAssertEqual([unichar minusOne].floatValue, 0.5);
	
	unichar = [NSMutableNumber numberWithDouble: 3.5];
	XCTAssertEqual([unichar minusOne].doubleValue, 2.5);
}

- (void)testNSMutableNumber_isNegativeOne
{
	XCTAssertFalse([NSMutableNumber numberWithBool:-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithBool:NO].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithBool:YES].isNegativeOne);
	
	XCTAssertTrue([NSMutableNumber numberWithChar:-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithChar:0].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:(unsigned char)-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:0].isNegativeOne);
	
	XCTAssertTrue([NSMutableNumber numberWithShort:-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithShort:0].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:(unsigned short)-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:0].isNegativeOne);
	
	XCTAssertFalse([NSMutableNumber numberWithUnichar:(unichar)-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnichar:0].isNegativeOne);
	
	XCTAssertTrue([NSMutableNumber numberWithInt:-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithInt:0].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:(unsigned int)-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:0].isNegativeOne);
	
	XCTAssertTrue([NSMutableNumber numberWithInteger:-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithInteger:0].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:0].isNegativeOne);
	
	XCTAssertTrue([NSMutableNumber numberWithLong:-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithLong:0].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:0].isNegativeOne);
	
	XCTAssertTrue([NSMutableNumber numberWithLongLong:-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithLongLong:0].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:(unsigned long long)-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:0].isNegativeOne);
	
	XCTAssertTrue([NSMutableNumber numberWithFloat:-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithFloat:0].isNegativeOne);
	XCTAssertTrue([NSMutableNumber numberWithDouble:-1].isNegativeOne);
	XCTAssertFalse([NSMutableNumber numberWithDouble:0].isNegativeOne);
}


- (void)testNSMutableNumber_isZero
{
	XCTAssertFalse([NSMutableNumber numberWithBool:-1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithBool:NO].isZero);
	
	XCTAssertFalse([NSMutableNumber numberWithBool:YES].isZero);
	XCTAssertFalse([NSMutableNumber numberWithChar:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithChar:0].isZero);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedChar:0].isZero);
	
	XCTAssertFalse([NSMutableNumber numberWithShort:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithShort:0].isZero);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedShort:0].isZero);
	
	XCTAssertFalse([NSMutableNumber numberWithUnichar:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithUnichar:0].isZero);
	
	XCTAssertFalse([NSMutableNumber numberWithInt:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithInt:0].isZero);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInt:0].isZero);
	
	XCTAssertFalse([NSMutableNumber numberWithInteger:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithInteger:0].isZero);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInteger:0].isZero);
	
	XCTAssertFalse([NSMutableNumber numberWithLong:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithLong:0].isZero);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLong:0].isZero);
	
	XCTAssertFalse([NSMutableNumber numberWithLongLong:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithLongLong:0].isZero);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLongLong:0].isZero);
	
	XCTAssertFalse([NSMutableNumber numberWithFloat:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithFloat:0].isZero);
	XCTAssertFalse([NSMutableNumber numberWithDouble:1].isZero);
	XCTAssertTrue([NSMutableNumber numberWithDouble:0].isZero);
}

- (void)testNSMutableNumber_isOne
{
	XCTAssertTrue([NSMutableNumber numberWithBool:-1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithBool:NO].isOne);
	
	XCTAssertTrue([NSMutableNumber numberWithBool:YES].isOne);
	XCTAssertTrue([NSMutableNumber numberWithChar:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithChar:0].isOne);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedChar:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:0].isOne);
	
	XCTAssertTrue([NSMutableNumber numberWithShort:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithShort:0].isOne);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedShort:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:0].isOne);
	
	XCTAssertTrue([NSMutableNumber numberWithUnichar:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithUnichar:0].isOne);
	
	XCTAssertTrue([NSMutableNumber numberWithInt:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithInt:0].isOne);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInt:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:0].isOne);
	
	XCTAssertTrue([NSMutableNumber numberWithInteger:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithInteger:0].isOne);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInteger:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:0].isOne);
	
	XCTAssertTrue([NSMutableNumber numberWithLong:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithLong:0].isOne);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLong:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:0].isOne);
	
	XCTAssertTrue([NSMutableNumber numberWithLongLong:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithLongLong:0].isOne);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLongLong:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:0].isOne);
	
	XCTAssertTrue([NSMutableNumber numberWithFloat:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithFloat:0].isOne);
	XCTAssertTrue([NSMutableNumber numberWithDouble:1].isOne);
	XCTAssertFalse([NSMutableNumber numberWithDouble:0].isOne);
	
	XCTAssertTrue(NSMutableNumber.one.isOne);
}


- (void)testNSMutableNumber_isTwo
{
	XCTAssertFalse([NSMutableNumber numberWithBool:-1].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithBool:NO].isTwo);
	
	XCTAssertFalse([NSMutableNumber numberWithBool:YES].isTwo);
	XCTAssertTrue([NSMutableNumber numberWithChar:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithChar:0].isTwo);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedChar:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:0].isTwo);
	
	XCTAssertTrue([NSMutableNumber numberWithShort:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithShort:0].isTwo);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedShort:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:0].isTwo);
	
	XCTAssertTrue([NSMutableNumber numberWithUnichar:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithUnichar:0].isTwo);
	
	XCTAssertTrue([NSMutableNumber numberWithInt:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithInt:0].isTwo);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInt:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:0].isTwo);
	
	XCTAssertTrue([NSMutableNumber numberWithInteger:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithInteger:0].isTwo);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInteger:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:0].isTwo);
	
	XCTAssertTrue([NSMutableNumber numberWithLong:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithLong:0].isTwo);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLong:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:0].isTwo);
	
	XCTAssertTrue([NSMutableNumber numberWithLongLong:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithLongLong:0].isTwo);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLongLong:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:0].isTwo);
	
	XCTAssertTrue([NSMutableNumber numberWithFloat:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithFloat:0].isTwo);
	XCTAssertTrue([NSMutableNumber numberWithDouble:2].isTwo);
	XCTAssertFalse([NSMutableNumber numberWithDouble:0].isTwo);
}

- (void)testNSMutableNumber_isThree
{
	XCTAssertFalse([NSMutableNumber numberWithBool:-1].isThree);
	XCTAssertFalse([NSMutableNumber numberWithBool:NO].isThree);
	
	XCTAssertFalse([NSMutableNumber numberWithBool:YES].isThree);
	XCTAssertTrue([NSMutableNumber numberWithChar:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithChar:0].isThree);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedChar:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:0].isThree);
	
	XCTAssertTrue([NSMutableNumber numberWithShort:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithShort:0].isThree);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedShort:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:0].isThree);
	
	XCTAssertTrue([NSMutableNumber numberWithUnichar:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithUnichar:0].isThree);
	
	XCTAssertTrue([NSMutableNumber numberWithInt:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithInt:0].isThree);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInt:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:0].isThree);
	
	XCTAssertTrue([NSMutableNumber numberWithInteger:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithInteger:0].isThree);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInteger:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:0].isThree);
	
	XCTAssertTrue([NSMutableNumber numberWithLong:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithLong:0].isThree);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLong:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:0].isThree);
	
	XCTAssertTrue([NSMutableNumber numberWithLongLong:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithLongLong:0].isThree);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLongLong:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:0].isThree);
	
	XCTAssertTrue([NSMutableNumber numberWithFloat:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithFloat:0].isThree);
	XCTAssertTrue([NSMutableNumber numberWithDouble:3].isThree);
	XCTAssertFalse([NSMutableNumber numberWithDouble:0].isThree);
}


- (void)testNSMutableNumber_isFour
{
	XCTAssertFalse([NSMutableNumber numberWithBool:-1].isFour);
	XCTAssertFalse([NSMutableNumber numberWithBool:NO].isFour);
	
	XCTAssertFalse([NSMutableNumber numberWithBool:YES].isFour);
	XCTAssertTrue([NSMutableNumber numberWithChar:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithChar:0].isFour);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedChar:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:0].isFour);
	
	XCTAssertTrue([NSMutableNumber numberWithShort:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithShort:0].isFour);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedShort:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:0].isFour);
	
	XCTAssertTrue([NSMutableNumber numberWithUnichar:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithUnichar:0].isFour);
	
	XCTAssertTrue([NSMutableNumber numberWithInt:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithInt:0].isFour);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInt:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:0].isFour);
	
	XCTAssertTrue([NSMutableNumber numberWithInteger:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithInteger:0].isFour);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInteger:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:0].isFour);
	
	XCTAssertTrue([NSMutableNumber numberWithLong:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithLong:0].isFour);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLong:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:0].isFour);
	
	XCTAssertTrue([NSMutableNumber numberWithLongLong:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithLongLong:0].isFour);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLongLong:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:0].isFour);
	
	XCTAssertTrue([NSMutableNumber numberWithFloat:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithFloat:0].isFour);
	XCTAssertTrue([NSMutableNumber numberWithDouble:4].isFour);
	XCTAssertFalse([NSMutableNumber numberWithDouble:0].isFour);
}

- (void)testNSMutableNumber_isFive
{
	XCTAssertFalse([NSMutableNumber numberWithBool:-1].isFive);
	XCTAssertFalse([NSMutableNumber numberWithBool:NO].isFive);
	
	XCTAssertFalse([NSMutableNumber numberWithBool:YES].isFive);
	XCTAssertTrue([NSMutableNumber numberWithChar:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithChar:0].isFive);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedChar:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:0].isFive);
	
	XCTAssertTrue([NSMutableNumber numberWithShort:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithShort:0].isFive);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedShort:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:0].isFive);
	
	XCTAssertTrue([NSMutableNumber numberWithUnichar:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithUnichar:0].isFive);
	
	XCTAssertTrue([NSMutableNumber numberWithInt:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithInt:0].isFive);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInt:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:0].isFive);
	
	XCTAssertTrue([NSMutableNumber numberWithInteger:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithInteger:0].isFive);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedInteger:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:0].isFive);
	
	XCTAssertTrue([NSMutableNumber numberWithLong:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithLong:0].isFive);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLong:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:0].isFive);
	
	XCTAssertTrue([NSMutableNumber numberWithLongLong:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithLongLong:0].isFive);
	XCTAssertTrue([NSMutableNumber numberWithUnsignedLongLong:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:0].isFive);
	
	XCTAssertTrue([NSMutableNumber numberWithFloat:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithFloat:0].isFive);
	XCTAssertTrue([NSMutableNumber numberWithDouble:5].isFive);
	XCTAssertFalse([NSMutableNumber numberWithDouble:0].isFive);
}

- (void)testNSMutableNumber_isNotANumber
{
	XCTAssertFalse([NSMutableNumber numberWithBool:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithBool:NO].isNotANumber);
	
	XCTAssertFalse([NSMutableNumber numberWithChar:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithChar:0].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:0].isNotANumber);
	
	XCTAssertFalse([NSMutableNumber numberWithShort:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithShort:0].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:0].isNotANumber);
	
	XCTAssertFalse([NSMutableNumber numberWithUnichar:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnichar:0].isNotANumber);
	
	XCTAssertFalse([NSMutableNumber numberWithInt:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithInt:0].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:0].isNotANumber);
	
	XCTAssertFalse([NSMutableNumber numberWithInteger:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithInteger:0].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:0].isNotANumber);
	
	XCTAssertFalse([NSMutableNumber numberWithLong:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithLong:0].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:0].isNotANumber);
	
	XCTAssertFalse([NSMutableNumber numberWithLongLong:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithLongLong:0].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:0].isNotANumber);
	
	XCTAssertTrue([NSMutableNumber numberWithFloat:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithFloat:0].isNotANumber);
	XCTAssertTrue([NSMutableNumber numberWithDouble:NAN].isNotANumber);
	XCTAssertFalse([NSMutableNumber numberWithDouble:0].isNotANumber);
}


- (void)testNSMutableNumber_isInfinity
{
	XCTAssertFalse([NSMutableNumber numberWithBool:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithBool:NO].isInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithChar:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithChar:0].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:0].isInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithShort:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithShort:0].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:0].isInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithUnichar:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnichar:0].isInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithInt:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithInt:0].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:0].isInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithInteger:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithInteger:0].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:0].isInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithLong:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithLong:0].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:0].isInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithLongLong:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithLongLong:0].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:0].isInfinity);
	
	XCTAssertTrue([NSMutableNumber numberWithFloat:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithFloat:0].isInfinity);
	XCTAssertTrue([NSMutableNumber numberWithDouble:INFINITY].isInfinity);
	XCTAssertFalse([NSMutableNumber numberWithDouble:0].isInfinity);
}


- (void)testNSMutableNumber_isNegativeInfinity
{
	XCTAssertFalse([NSMutableNumber numberWithBool:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithBool:NO].isNegativeInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithChar:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithChar:0].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedChar:0].isNegativeInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithShort:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithShort:0].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedShort:0].isNegativeInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithUnichar:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnichar:0].isNegativeInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithInt:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithInt:0].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInt:0].isNegativeInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithInteger:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithInteger:0].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedInteger:0].isNegativeInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithLong:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithLong:0].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLong:0].isNegativeInfinity);
	
	XCTAssertFalse([NSMutableNumber numberWithLongLong:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithLongLong:0].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithUnsignedLongLong:0].isNegativeInfinity);
	
	XCTAssertTrue([NSMutableNumber numberWithFloat:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithFloat:INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithFloat:0].isNegativeInfinity);
	XCTAssertTrue([NSMutableNumber numberWithDouble:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithDouble:INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSMutableNumber numberWithDouble:0].isNegativeInfinity);
}

- (void)testExample
{
	NSNumber * n = [[NSNumber alloc] initWithInt:1]; // 1, i
	NSMutableNumber * m = [[NSMutableNumber alloc] initWithInt:1];
	NSLog(@"initWithInt %@, %s", n, n.objCType);
	NSLog(@"initWithInt %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithFloat:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithFloat:1];
	NSLog(@"initWithFloat %@, %s", n, n.objCType);
	NSLog(@"initWithFloat %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithChar:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithChar:1];
	NSLog(@"initWithChar %@, %s", n, n.objCType);
	NSLog(@"initWithChar %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithUnsignedChar:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithUnsignedChar:1];
	NSLog(@"initWithUnsignedChar %@, %s", n, n.objCType);
	NSLog(@"initWithUnsignedChar %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithShort:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithShort:1];
	NSLog(@"initWithShort %@, %s", n, n.objCType);
	NSLog(@"initWithShort %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithUnsignedShort:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithUnsignedShort:1];
	NSLog(@"initWithUnsignedShort %@, %s", n, n.objCType);
	NSLog(@"initWithUnsignedShort %@, %s", m, m.objCType);
	
	n = [[NSNumber alloc] initWithUnichar:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithUnichar:1];
	NSLog(@"initWithUnsignedShort %@, %s", n, n.objCType);
	NSLog(@"initWithUnsignedShort %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithUnsignedInt:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithUnsignedInt:1];
	NSLog(@"initWithUnsignedInt %@, %s", n, n.objCType);
	NSLog(@"initWithUnsignedInt %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithLong:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithLong:1];
	NSLog(@"initWithLong %@, %s", n, n.objCType);
	NSLog(@"initWithLong %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithUnsignedLong:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithUnsignedLong:1];
	NSLog(@"initWithUnsignedLong %@, %s", n, n.objCType);
	NSLog(@"initWithUnsignedLong %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithLongLong:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithLongLong:1];
	NSLog(@"initWithLongLong %@, %s", n, n.objCType);
	NSLog(@"initWithLongLong %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithUnsignedLongLong:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithUnsignedLongLong:1];
	NSLog(@"initWithUnsignedLongLong %@, %s", n, n.objCType);
	NSLog(@"initWithUnsignedLongLong %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithDouble:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithDouble:1];
	NSLog(@"initWithDouble %@, %s", n, n.objCType);
	NSLog(@"initWithDouble %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithBool:YES]; // 1, f
	m = [[NSMutableNumber alloc] initWithBool:YES];
	NSLog(@"initWithBool %@, %s, [%@]", n, n.objCType, n.stringValue);
	NSLog(@"initWithBool %@, %s, [%@]", m, m.objCType, m.stringValue);

	n = [[NSNumber alloc] initWithInteger:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithInteger:1];
	NSLog(@"initWithInteger %@, %s", n, n.objCType);
	NSLog(@"initWithInteger %@, %s", m, m.objCType);

	n = [[NSNumber alloc] initWithUnsignedInteger:1]; // 1, f
	m = [[NSMutableNumber alloc] initWithUnsignedInteger:1];
	NSLog(@"initWithUnsignedInteger %@, %s", n, n.objCType);
	NSLog(@"initWithUnsignedInteger %@, %s", m, m.objCType);


	n = [[NSNumber alloc] initWithDouble:3.14159346564465]; //
	NSMutableNumber * n1 = [n mutableCopy];
	NSLog(@"%@", n1);

	n1 = [@(8.7654321) mutableCopy];
	NSLog(@"%@", n1);

	NSMutableDictionary * d = [NSMutableDictionary dictionary];
	d[[NSMutableNumber numberWithDouble:3.14]] = @"PI string";
	NSString * val = d[[NSMutableNumber numberWithDouble:3.14]];
	NSLog(@"%@", val);

	NSLog(@"%@", [NSNumber numberWithUnsignedLongLong:ULLONG_MAX]);
	NSLog(@"%@", [NSMutableNumber numberWithUnsignedLongLong:ULLONG_MAX]);
}

- (void) testCreateN
{
	[self measureBlock:^{
		for (int i = 0; i < 10000; i++)
		{
			NSNumber * n = [[NSNumber alloc] initWithUnsignedInteger:1];
			n = nil;
		}
    }];
}

- (void) testCreateM
{
	[self measureBlock:^{
		for (int i = 0; i < 10000; i++)
		{
			NSMutableNumber * n = [[NSMutableNumber alloc] initWithUnsignedInteger:1];
			XCTAssert(n);
			n = nil;
		}
	}];
}

- (void) testCompareN
{
	[self measureBlock:^{
		for (int i = 0; i < 10000; i++)
		{
			NSNumber * n1 = [[NSNumber alloc] initWithUnsignedInteger:1];
			NSNumber * n2 = [[NSNumber alloc] initWithDouble:1];
			XCTAssert(n1);
			XCTAssert(n2);
			XCTAssert([n1 compare:n2] == NSOrderedSame);
		}
	}];
}

- (void) testCompareM
{
	[self measureBlock:^{
		for (int i = 0; i < 10000; i++)
		{
			NSMutableNumber * n1 = [[NSMutableNumber alloc] initWithUnsignedInteger:1];
			NSMutableNumber * n2 = [[NSMutableNumber alloc] initWithDouble:1];
			XCTAssert(n1);
			XCTAssert(n2);
			XCTAssert([n1 compare:n2] == NSOrderedSame);
		}
	}];
}


#pragma - NSNumber Extension Tests

- (void)testNSNumber_infinity
{
	XCTAssertEqualObjects(NSNumber.infinity, @(INFINITY));
	XCTAssertTrue(NSNumber.infinity.isInfinity);
}

- (void)testNSNumber_minusInfinity
{
	XCTAssertEqualObjects(NSNumber.minusInfinity, @(-INFINITY));
	XCTAssertTrue(NSNumber.minusInfinity.isNegativeInfinity);
}

- (void)testNSNumber_notANumber
{
	XCTAssertEqualObjects(NSNumber.notANumber, @(NAN));
	XCTAssertTrue(NSNumber.notANumber.isNotANumber);
}

- (void)testNSNumber_zero
{
	XCTAssertEqualObjects(NSNumber.zero, @(0));
	XCTAssertTrue(NSNumber.zero.isPositiveZero);
	XCTAssertTrue(NSNumber.zero.isZero);
	XCTAssertFalse(NSNumber.zero.isNegativeZero);
}

- (void)testNSNumber_negativeZero
{
	XCTAssertEqualObjects(NSNumber.negativeZero, @(-0.0));
	XCTAssertFalse(NSNumber.negativeZero.isPositiveZero);
	XCTAssertTrue(NSNumber.negativeZero.isZero);
	XCTAssertTrue(NSNumber.negativeZero.isNegativeZero);
}

- (void)testNSNumber_one
{
	XCTAssertEqualObjects(NSNumber.one, @(1));
	XCTAssertTrue(NSNumber.one.isOne);
}

- (void)testNSNumber_unichar
{
	NSNumber *unichar = [NSNumber numberWithUnichar: 0];
	XCTAssertEqual(unichar.unicharValue, 0);
	
	unichar = [NSNumber numberWithUnichar: 1];
	XCTAssertEqual(unichar.unicharValue, 1);
	
	unichar = [NSNumber numberWithUnichar: USHRT_MAX - 1];
	XCTAssertEqual(unichar.unicharValue, USHRT_MAX - 1);
	
	unichar = [NSNumber numberWithUnichar: USHRT_MAX];
	XCTAssertEqual(unichar.unicharValue, USHRT_MAX);
}

- (void)testNSNumber_mutableCopyWithZone
{
	NSNumber *unichar = [NSNumber numberWithUnichar: 11];
	XCTAssertTrue([unichar isKindOfClass:NSNumber.class]);
	XCTAssertFalse([unichar isKindOfClass:NSMutableNumber.class]);
	XCTAssertEqual(unichar.unicharValue, 11);
	
	NSMutableNumber *mutableNumber = [unichar mutableCopy];
	XCTAssertTrue([mutableNumber isMemberOfClass:NSMutableNumber.class]);
	XCTAssertEqual(unichar.unicharValue, 11);
	
	NSNumber *number = [NSNumber numberWithLong:535353];
	XCTAssertEqualObjects([number mutableCopy], number);
}

- (void)testNSNumber_bitNot
{
	NSNumber *unichar = [NSMockNumber numberWithBool: YES];
	
	XCTAssertEqual(unichar.boolValue, YES);
	XCTAssertEqual(unichar.bitNot.charValue & 0x1, NO);
	
	unichar = [NSMockNumber numberWithChar: (char)0xb9];
	XCTAssertEqual(unichar.bitNot.charValue, ~(char)0xb9);
	
	unichar = [NSMockNumber numberWithUnsignedChar: (unsigned char)0x7b];
	XCTAssertEqual(unichar.bitNot.unsignedCharValue, (unsigned char)~0x7b);
	
	unichar = [NSMockNumber numberWithShort: (short)0x9b5e];
	XCTAssertEqual(unichar.bitNot.shortValue, ~(short)0x9b5e);
	
	unichar = [NSMockNumber numberWithUnsignedShort: (unsigned short)0x9b5d];
	XCTAssertEqual(unichar.bitNot.unsignedShortValue, (unsigned short)~0x9b5d);
	
	unichar = [NSMockNumber numberWithInt: (int)0x9b5e37af];
	XCTAssertEqual(unichar.bitNot.intValue, ~(int)0x9b5e37af);
	
	unichar = [NSMockNumber numberWithUnsignedInt: (unsigned int)0x37af9b5e];
	XCTAssertEqual(unichar.bitNot.unsignedIntValue, (unsigned int)~0x37af9b5e);
	
	unichar = [NSMockNumber numberWithInteger: (NSInteger)0x9baf5e37];
	XCTAssertEqual(unichar.bitNot.integerValue, ~(NSInteger)0x9baf5e37);
	
	unichar = [NSMockNumber numberWithUnsignedInteger: (NSUInteger)0xae379baf];
	XCTAssertEqual(unichar.bitNot.unsignedIntegerValue, ~(NSUInteger)0xae379baf);
	
	unichar = [NSMockNumber numberWithLong: (long)0x7af0083937af9b5e];
	XCTAssertEqual(unichar.bitNot.longValue, ~(long)0x7af0083937af9b5e);
	
	unichar = [NSMockNumber numberWithUnsignedLong: (unsigned long)0x37af9b5e7af00839];
	XCTAssertEqual(unichar.bitNot.unsignedLongValue, ~(unsigned long)0x37af9b5e7af00839);
	
	unichar = [NSMockNumber numberWithLongLong: (long long)0x7af00839efdd24bf];
	XCTAssertEqual(unichar.bitNot.longLongValue, ~(long long)0x7af00839efdd24bf);
	
	unichar = [NSMockNumber numberWithUnsignedLongLong: (unsigned long long)0x7af024bf0839efdd];
	XCTAssertEqual(unichar.bitNot.unsignedLongLongValue, ~(unsigned long long)0x7af024bf0839efdd);
	
	unichar = [NSMockNumber numberWithFloat: 54321.0];
	XCTAssertEqual(unichar.bitNot.floatValue, ~(long long)54321.0);
	
	unichar = [NSMockNumber numberWithDouble: 987654321.0];
	XCTAssertEqual(unichar.bitNot.doubleValue, ~(long long)987654321.0);
}

- (void)testNSNumber_bitNotValue
{
	NSNumber *unichar = [NSMockNumber numberWithBool: YES];
	XCTAssertEqual(unichar.bitNotValue, ~(BOOL)YES);
	
	unichar = [NSMockNumber numberWithChar: 0xb9];
	XCTAssertEqual(unichar.bitNotValue, ~(char)0xb9);
	
	unichar = [NSMockNumber numberWithUnsignedChar: 0x9b];
	XCTAssertEqual(unichar.bitNotValue, ~(unsigned char)0x9b);
	
	unichar = [NSMockNumber numberWithShort: 0x9b5e];
	XCTAssertEqual(unichar.bitNotValue, ~(short)0x9b5e);
	
	unichar = [NSMockNumber numberWithUnsignedShort: 0x9b5d];
	XCTAssertEqual(unichar.bitNotValue, ~(unsigned short)0x9b5d);
	
	unichar = [NSMockNumber numberWithInt: 0x9b5e37af];
	XCTAssertEqual(unichar.bitNotValue, ~(int)0x9b5e37af);
	
	unichar = [NSMockNumber numberWithUnsignedInt: 0x37af9b5e];
	XCTAssertEqual(unichar.bitNotValue, (unsigned int)~0x37af9b5e);
	
	unichar = [NSMockNumber numberWithInteger: 0x9baf5e37];
	XCTAssertEqual(unichar.bitNotValue, ~(NSInteger)0x9baf5e37);
	
	unichar = [NSMockNumber numberWithUnsignedInteger: 0x5e379baf];
	XCTAssertEqual(unichar.bitNotValue, ~(NSUInteger)0x5e379baf);
	
	unichar = [NSMockNumber numberWithLong: 0x7af0083937af9b5e];
	XCTAssertEqual(unichar.bitNotValue, ~(long)0x7af0083937af9b5e);
	
	unichar = [NSMockNumber numberWithUnsignedLong: 0x37af9b5e7af00839];
	XCTAssertEqual(unichar.bitNotValue, ~(unsigned long)0x37af9b5e7af00839);
	
	unichar = [NSMockNumber numberWithLongLong: 0x7af00839efdd24bf];
	XCTAssertEqual(unichar.bitNotValue, ~(long long)0x7af00839efdd24bf);
	
	unichar = [NSMockNumber numberWithUnsignedLongLong: 0x7af024bf0839efdd];
	XCTAssertEqual(unichar.bitNotValue, ~(unsigned long long)0x7af024bf0839efdd);
	
	
	unichar = [NSMockNumber numberWithFloat: 54321.0];
	XCTAssertEqual(unichar.bitNotValue, ~(long long)54321.0);
	
	unichar = [NSMockNumber numberWithDouble: 987654321.0];
	XCTAssertEqual(unichar.bitNotValue, ~(long long)987654321.0);
}

- (void)testNSNumber_plusOne
{
	NSNumber *unichar = [NSMockNumber numberWithBool: NO];
	XCTAssertEqual(unichar.plusOne.boolValue, YES);
	
	unichar = [NSMockNumber numberWithBool: YES];
	XCTAssertEqual(unichar.plusOne.boolValue, YES);
	
	unichar = [NSMockNumber numberWithChar: 0xb9];
	XCTAssertEqual(unichar.plusOne.charValue, (signed char)0xba);
	
	unichar = [NSMockNumber numberWithUnsignedChar: 0x9b];
	XCTAssertEqual(unichar.plusOne.unsignedCharValue, 0x9c);
	
	unichar = [NSMockNumber numberWithShort: 0x9b5e];
	XCTAssertEqual(unichar.plusOne.shortValue, (signed short)0x9b5f);
	
	unichar = [NSMockNumber numberWithUnsignedShort: 0x9b5d];
	XCTAssertEqual(unichar.plusOne.unsignedShortValue, 0x9b5e);
	
	unichar = [NSMockNumber numberWithInt: 0x9b5e37af];
	XCTAssertEqual(unichar.plusOne.intValue, 0x9b5e37b0);
	
	unichar = [NSMockNumber numberWithUnsignedInt: 0x37af9b5e];
	XCTAssertEqual(unichar.plusOne.unsignedIntValue, 0x37af9b5f);
	
	unichar = [NSMockNumber numberWithInteger: 0x9baf5e37];
	XCTAssertEqual(unichar.plusOne.integerValue, 0x9baf5e38);
	
	unichar = [NSMockNumber numberWithUnsignedInteger: 0x5e379baf];
	XCTAssertEqual(unichar.plusOne.unsignedIntegerValue, 0x5e379bb0);
	
	unichar = [NSMockNumber numberWithLong: 0x7af0083937af9b5e];
	XCTAssertEqual(unichar.plusOne.longValue, 0x7af0083937af9b5f);
	
	unichar = [NSMockNumber numberWithUnsignedLong: 0x37af9b5e7af00839];
	XCTAssertEqual(unichar.plusOne.unsignedLongValue, 0x37af9b5e7af0083a);
	
	unichar = [NSMockNumber numberWithLongLong: 0x7af00839efdd24bf];
	XCTAssertEqual(unichar.plusOne.longLongValue, 0x7af00839efdd24c0);
	
	unichar = [NSMockNumber numberWithUnsignedLongLong: 0x7af024bf0839efdd];
	XCTAssertEqual(unichar.plusOne.unsignedLongLongValue, 0x7af024bf0839efde);
	
	unichar = [NSNumber numberWithFloat: 2.5];
	XCTAssertEqual(unichar.plusOne.floatValue, 3.5);
	
	unichar = [NSNumber numberWithDouble:5.5];
	XCTAssertEqual(unichar.plusOne.doubleValue, 6.5);
}

- (void)testNSNumber_subtractOne
{
	NSNumber *unichar = [NSMockNumber numberWithBool: NO];
	XCTAssertEqual(unichar.subtractOne.boolValue, YES);
	
	unichar = [NSMockNumber numberWithBool: YES];
	XCTAssertEqual(unichar.subtractOne.boolValue, NO);
	
	unichar = [NSMockNumber numberWithChar: 0xb9];
	XCTAssertEqual(unichar.subtractOne.charValue, (signed char)0xb8);
	
	unichar = [NSMockNumber numberWithUnsignedChar: 0x9b];
	XCTAssertEqual(unichar.subtractOne.unsignedCharValue, 0x9a);
	
	unichar = [NSMockNumber numberWithShort: 0x7b5e];
	XCTAssertEqual(unichar.subtractOne.shortValue, 0x7b5d);
	
	unichar = [NSMockNumber numberWithShort: 0x9b5e];
	XCTAssertEqual(unichar.subtractOne.shortValue, (signed short)0x9b5d);
	
	unichar = [NSMockNumber numberWithUnsignedShort: 0x9b5d];
	XCTAssertEqual(unichar.subtractOne.unsignedShortValue, 0x9b5c);
	
	unichar = [NSMockNumber numberWithInt: 0x9b5e37af];
	XCTAssertEqual(unichar.subtractOne.intValue, 0x9b5e37ae);
	
	unichar = [NSMockNumber numberWithUnsignedInt: 0x37af9b5e];
	XCTAssertEqual(unichar.subtractOne.unsignedIntValue, 0x37af9b5d);
	
	unichar = [NSMockNumber numberWithInteger: 0x9baf5e37];
	XCTAssertEqual(unichar.subtractOne.integerValue, 0x9baf5e36);
	
	unichar = [NSMockNumber numberWithUnsignedInteger: 0x5e379baf];
	XCTAssertEqual(unichar.subtractOne.unsignedIntegerValue, 0x5e379bae);
	
	unichar = [NSMockNumber numberWithLong: 0x7af0083937af9b5e];
	XCTAssertEqual(unichar.subtractOne.longValue, 0x7af0083937af9b5d);
	
	unichar = [NSMockNumber numberWithUnsignedLong: 0x37af9b5e7af00839];
	XCTAssertEqual(unichar.subtractOne.unsignedLongValue, 0x37af9b5e7af00838);
	
	unichar = [NSMockNumber numberWithLongLong: 0x7af00839efdd24bf];
	XCTAssertEqual(unichar.subtractOne.longLongValue, 0x7af00839efdd24be);
	
	unichar = [NSMockNumber numberWithUnsignedLongLong: 0x7af024bf0839efdd];
	XCTAssertEqual(unichar.subtractOne.unsignedLongLongValue, 0x7af024bf0839efdc);
	
	unichar = [NSNumber numberWithFloat: 2.5];
	XCTAssertEqual(unichar.subtractOne.floatValue, 1.5);
	
	unichar = [NSNumber numberWithDouble:5.5];
	XCTAssertEqual(unichar.subtractOne.doubleValue, 4.5);
}

- (void)testNSNumber_isNegativeOne
{
	XCTAssertFalse([NSNumber numberWithBool:-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithBool:NO].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithBool:YES].isNegativeOne);
	
	XCTAssertTrue([NSNumber numberWithChar:-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithChar:0].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:(unsigned char)-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:0].isNegativeOne);
	
	XCTAssertTrue([NSNumber numberWithShort:-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithShort:0].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:(unsigned short)-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:0].isNegativeOne);
	
	XCTAssertFalse([NSNumber numberWithUnichar:(unichar)-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnichar:0].isNegativeOne);
	
	XCTAssertTrue([NSNumber numberWithInt:-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithInt:0].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:(unsigned int)-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:0].isNegativeOne);
	
	XCTAssertTrue([NSNumber numberWithInteger:-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithInteger:0].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:0].isNegativeOne);
	
	XCTAssertTrue([NSNumber numberWithLong:-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithLong:0].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:0].isNegativeOne);
	
	XCTAssertTrue([NSNumber numberWithLongLong:-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithLongLong:0].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:(unsigned long long)-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:0].isNegativeOne);
	
	XCTAssertTrue([NSNumber numberWithFloat:-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithFloat:0].isNegativeOne);
	XCTAssertTrue([NSNumber numberWithDouble:-1].isNegativeOne);
	XCTAssertFalse([NSNumber numberWithDouble:0].isNegativeOne);
}


- (void)testNSNumber_isZero
{
	XCTAssertFalse([NSNumber numberWithBool:-1].isZero);
	XCTAssertTrue([NSNumber numberWithBool:NO].isZero);
	
	XCTAssertFalse([NSNumber numberWithBool:YES].isZero);
	XCTAssertFalse([NSNumber numberWithChar:1].isZero);
	XCTAssertTrue([NSNumber numberWithChar:0].isZero);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:1].isZero);
	XCTAssertTrue([NSNumber numberWithUnsignedChar:0].isZero);
	
	XCTAssertFalse([NSNumber numberWithShort:1].isZero);
	XCTAssertTrue([NSNumber numberWithShort:0].isZero);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:1].isZero);
	XCTAssertTrue([NSNumber numberWithUnsignedShort:0].isZero);
	
	XCTAssertFalse([NSNumber numberWithUnichar:1].isZero);
	XCTAssertTrue([NSNumber numberWithUnichar:0].isZero);
	
	XCTAssertFalse([NSNumber numberWithInt:1].isZero);
	XCTAssertTrue([NSNumber numberWithInt:0].isZero);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:1].isZero);
	XCTAssertTrue([NSNumber numberWithUnsignedInt:0].isZero);
	
	XCTAssertFalse([NSNumber numberWithInteger:1].isZero);
	XCTAssertTrue([NSNumber numberWithInteger:0].isZero);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:1].isZero);
	XCTAssertTrue([NSNumber numberWithUnsignedInteger:0].isZero);
	
	XCTAssertFalse([NSNumber numberWithLong:1].isZero);
	XCTAssertTrue([NSNumber numberWithLong:0].isZero);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:1].isZero);
	XCTAssertTrue([NSNumber numberWithUnsignedLong:0].isZero);
	
	XCTAssertFalse([NSNumber numberWithLongLong:1].isZero);
	XCTAssertTrue([NSNumber numberWithLongLong:0].isZero);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:1].isZero);
	XCTAssertTrue([NSNumber numberWithUnsignedLongLong:0].isZero);
	
	XCTAssertFalse([NSNumber numberWithFloat:1].isZero);
	XCTAssertTrue([NSNumber numberWithFloat:0].isZero);
	XCTAssertTrue([NSNumber numberWithFloat:-0.0].isZero);
	XCTAssertFalse([NSNumber numberWithDouble:1].isZero);
	XCTAssertTrue([NSNumber numberWithDouble:0].isZero);
	XCTAssertTrue([NSNumber numberWithDouble:-0.0].isZero);
}



- (void)testNSNumber_isPositiveZero
{
	XCTAssertFalse([NSNumber numberWithFloat:-0.0].isPositiveZero);
	XCTAssertFalse([NSNumber numberWithDouble:-0.0].isPositiveZero);
	
	XCTAssertFalse([NSNumber numberWithBool:-1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithBool:NO].isPositiveZero);
	
	XCTAssertFalse([NSNumber numberWithBool:YES].isPositiveZero);
	XCTAssertFalse([NSNumber numberWithChar:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithChar:0].isPositiveZero);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithUnsignedChar:0].isPositiveZero);
	
	XCTAssertFalse([NSNumber numberWithShort:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithShort:0].isPositiveZero);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithUnsignedShort:0].isPositiveZero);
	
	XCTAssertFalse([NSNumber numberWithUnichar:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithUnichar:0].isPositiveZero);
	
	XCTAssertFalse([NSNumber numberWithInt:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithInt:0].isPositiveZero);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithUnsignedInt:0].isPositiveZero);
	
	XCTAssertFalse([NSNumber numberWithInteger:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithInteger:0].isPositiveZero);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithUnsignedInteger:0].isPositiveZero);
	
	XCTAssertFalse([NSNumber numberWithLong:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithLong:0].isPositiveZero);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithUnsignedLong:0].isPositiveZero);
	
	XCTAssertFalse([NSNumber numberWithLongLong:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithLongLong:0].isPositiveZero);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithUnsignedLongLong:0].isPositiveZero);
	
	XCTAssertFalse([NSNumber numberWithFloat:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithFloat:0].isPositiveZero);
	XCTAssertFalse([NSNumber numberWithDouble:1].isPositiveZero);
	XCTAssertTrue([NSNumber numberWithDouble:0].isPositiveZero);
}



- (void)testNSNumber_isNegativeZero
{
	XCTAssertTrue([NSNumber numberWithFloat:-0.0].isNegativeZero);
	XCTAssertTrue([NSNumber numberWithDouble:-0.0].isNegativeZero);
	
	XCTAssertFalse([NSNumber numberWithBool:-1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithBool:NO].isNegativeZero);
	
	XCTAssertFalse([NSNumber numberWithBool:YES].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithChar:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithChar:0].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:0].isNegativeZero);
	
	XCTAssertFalse([NSNumber numberWithShort:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithShort:0].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:0].isNegativeZero);
	
	XCTAssertFalse([NSNumber numberWithUnichar:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnichar:0].isNegativeZero);
	
	XCTAssertFalse([NSNumber numberWithInt:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithInt:0].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:0].isNegativeZero);
	
	XCTAssertFalse([NSNumber numberWithInteger:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithInteger:0].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:0].isNegativeZero);
	
	XCTAssertFalse([NSNumber numberWithLong:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithLong:0].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:0].isNegativeZero);
	
	XCTAssertFalse([NSNumber numberWithLongLong:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithLongLong:0].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:0].isNegativeZero);
	
	XCTAssertFalse([NSNumber numberWithFloat:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithFloat:0].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithDouble:1].isNegativeZero);
	XCTAssertFalse([NSNumber numberWithDouble:0].isNegativeZero);
}

- (void)testNSNumber_isOne
{
	XCTAssertTrue([NSNumber numberWithBool:-1].isOne);
	XCTAssertFalse([NSNumber numberWithBool:NO].isOne);
	
	XCTAssertTrue([NSNumber numberWithBool:YES].isOne);
	XCTAssertTrue([NSNumber numberWithChar:1].isOne);
	XCTAssertFalse([NSNumber numberWithChar:0].isOne);
	XCTAssertTrue([NSNumber numberWithUnsignedChar:1].isOne);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:0].isOne);
	
	XCTAssertTrue([NSNumber numberWithShort:1].isOne);
	XCTAssertFalse([NSNumber numberWithShort:0].isOne);
	XCTAssertTrue([NSNumber numberWithUnsignedShort:1].isOne);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:0].isOne);
	
	XCTAssertTrue([NSNumber numberWithUnichar:1].isOne);
	XCTAssertFalse([NSNumber numberWithUnichar:0].isOne);
	
	XCTAssertTrue([NSNumber numberWithInt:1].isOne);
	XCTAssertFalse([NSNumber numberWithInt:0].isOne);
	XCTAssertTrue([NSNumber numberWithUnsignedInt:1].isOne);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:0].isOne);
	
	XCTAssertTrue([NSNumber numberWithInteger:1].isOne);
	XCTAssertFalse([NSNumber numberWithInteger:0].isOne);
	XCTAssertTrue([NSNumber numberWithUnsignedInteger:1].isOne);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:0].isOne);
	
	XCTAssertTrue([NSNumber numberWithLong:1].isOne);
	XCTAssertFalse([NSNumber numberWithLong:0].isOne);
	XCTAssertTrue([NSNumber numberWithUnsignedLong:1].isOne);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:0].isOne);
	
	XCTAssertTrue([NSNumber numberWithLongLong:1].isOne);
	XCTAssertFalse([NSNumber numberWithLongLong:0].isOne);
	XCTAssertTrue([NSNumber numberWithUnsignedLongLong:1].isOne);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:0].isOne);
	
	XCTAssertTrue([NSNumber numberWithFloat:1].isOne);
	XCTAssertFalse([NSNumber numberWithFloat:0].isOne);
	XCTAssertTrue([NSNumber numberWithDouble:1].isOne);
	XCTAssertFalse([NSNumber numberWithDouble:0].isOne);
	
	XCTAssertTrue(NSNumber.one.isOne);
}


- (void)testNSNumber_isTwo
{
	XCTAssertFalse([NSNumber numberWithBool:-1].isTwo);
	XCTAssertFalse([NSNumber numberWithBool:NO].isTwo);
	
	XCTAssertFalse([NSNumber numberWithBool:YES].isTwo);
	XCTAssertTrue([NSNumber numberWithChar:2].isTwo);
	XCTAssertFalse([NSNumber numberWithChar:0].isTwo);
	XCTAssertTrue([NSNumber numberWithUnsignedChar:2].isTwo);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:0].isTwo);
	
	XCTAssertTrue([NSNumber numberWithShort:2].isTwo);
	XCTAssertFalse([NSNumber numberWithShort:0].isTwo);
	XCTAssertTrue([NSNumber numberWithUnsignedShort:2].isTwo);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:0].isTwo);
	
	XCTAssertTrue([NSNumber numberWithUnichar:2].isTwo);
	XCTAssertFalse([NSNumber numberWithUnichar:0].isTwo);
	
	XCTAssertTrue([NSNumber numberWithInt:2].isTwo);
	XCTAssertFalse([NSNumber numberWithInt:0].isTwo);
	XCTAssertTrue([NSNumber numberWithUnsignedInt:2].isTwo);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:0].isTwo);
	
	XCTAssertTrue([NSNumber numberWithInteger:2].isTwo);
	XCTAssertFalse([NSNumber numberWithInteger:0].isTwo);
	XCTAssertTrue([NSNumber numberWithUnsignedInteger:2].isTwo);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:0].isTwo);
	
	XCTAssertTrue([NSNumber numberWithLong:2].isTwo);
	XCTAssertFalse([NSNumber numberWithLong:0].isTwo);
	XCTAssertTrue([NSNumber numberWithUnsignedLong:2].isTwo);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:0].isTwo);
	
	XCTAssertTrue([NSNumber numberWithLongLong:2].isTwo);
	XCTAssertFalse([NSNumber numberWithLongLong:0].isTwo);
	XCTAssertTrue([NSNumber numberWithUnsignedLongLong:2].isTwo);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:0].isTwo);
	
	XCTAssertTrue([NSNumber numberWithFloat:2].isTwo);
	XCTAssertFalse([NSNumber numberWithFloat:0].isTwo);
	XCTAssertTrue([NSNumber numberWithDouble:2].isTwo);
	XCTAssertFalse([NSNumber numberWithDouble:0].isTwo);
}

- (void)testNSNumber_isThree
{
	XCTAssertFalse([NSNumber numberWithBool:-1].isThree);
	XCTAssertFalse([NSNumber numberWithBool:NO].isThree);
	
	XCTAssertFalse([NSNumber numberWithBool:YES].isThree);
	XCTAssertTrue([NSNumber numberWithChar:3].isThree);
	XCTAssertFalse([NSNumber numberWithChar:0].isThree);
	XCTAssertTrue([NSNumber numberWithUnsignedChar:3].isThree);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:0].isThree);
	
	XCTAssertTrue([NSNumber numberWithShort:3].isThree);
	XCTAssertFalse([NSNumber numberWithShort:0].isThree);
	XCTAssertTrue([NSNumber numberWithUnsignedShort:3].isThree);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:0].isThree);
	
	XCTAssertTrue([NSNumber numberWithUnichar:3].isThree);
	XCTAssertFalse([NSNumber numberWithUnichar:0].isThree);
	
	XCTAssertTrue([NSNumber numberWithInt:3].isThree);
	XCTAssertFalse([NSNumber numberWithInt:0].isThree);
	XCTAssertTrue([NSNumber numberWithUnsignedInt:3].isThree);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:0].isThree);
	
	XCTAssertTrue([NSNumber numberWithInteger:3].isThree);
	XCTAssertFalse([NSNumber numberWithInteger:0].isThree);
	XCTAssertTrue([NSNumber numberWithUnsignedInteger:3].isThree);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:0].isThree);
	
	XCTAssertTrue([NSNumber numberWithLong:3].isThree);
	XCTAssertFalse([NSNumber numberWithLong:0].isThree);
	XCTAssertTrue([NSNumber numberWithUnsignedLong:3].isThree);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:0].isThree);
	
	XCTAssertTrue([NSNumber numberWithLongLong:3].isThree);
	XCTAssertFalse([NSNumber numberWithLongLong:0].isThree);
	XCTAssertTrue([NSNumber numberWithUnsignedLongLong:3].isThree);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:0].isThree);
	
	XCTAssertTrue([NSNumber numberWithFloat:3].isThree);
	XCTAssertFalse([NSNumber numberWithFloat:0].isThree);
	XCTAssertTrue([NSNumber numberWithDouble:3].isThree);
	XCTAssertFalse([NSNumber numberWithDouble:0].isThree);
}


- (void)testNSNumber_isFour
{
	XCTAssertFalse([NSNumber numberWithBool:-1].isFour);
	XCTAssertFalse([NSNumber numberWithBool:NO].isFour);
	
	XCTAssertFalse([NSNumber numberWithBool:YES].isFour);
	XCTAssertTrue([NSNumber numberWithChar:4].isFour);
	XCTAssertFalse([NSNumber numberWithChar:0].isFour);
	XCTAssertTrue([NSNumber numberWithUnsignedChar:4].isFour);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:0].isFour);
	
	XCTAssertTrue([NSNumber numberWithShort:4].isFour);
	XCTAssertFalse([NSNumber numberWithShort:0].isFour);
	XCTAssertTrue([NSNumber numberWithUnsignedShort:4].isFour);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:0].isFour);
	
	XCTAssertTrue([NSNumber numberWithUnichar:4].isFour);
	XCTAssertFalse([NSNumber numberWithUnichar:0].isFour);
	
	XCTAssertTrue([NSNumber numberWithInt:4].isFour);
	XCTAssertFalse([NSNumber numberWithInt:0].isFour);
	XCTAssertTrue([NSNumber numberWithUnsignedInt:4].isFour);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:0].isFour);
	
	XCTAssertTrue([NSNumber numberWithInteger:4].isFour);
	XCTAssertFalse([NSNumber numberWithInteger:0].isFour);
	XCTAssertTrue([NSNumber numberWithUnsignedInteger:4].isFour);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:0].isFour);
	
	XCTAssertTrue([NSNumber numberWithLong:4].isFour);
	XCTAssertFalse([NSNumber numberWithLong:0].isFour);
	XCTAssertTrue([NSNumber numberWithUnsignedLong:4].isFour);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:0].isFour);
	
	XCTAssertTrue([NSNumber numberWithLongLong:4].isFour);
	XCTAssertFalse([NSNumber numberWithLongLong:0].isFour);
	XCTAssertTrue([NSNumber numberWithUnsignedLongLong:4].isFour);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:0].isFour);
	
	XCTAssertTrue([NSNumber numberWithFloat:4].isFour);
	XCTAssertFalse([NSNumber numberWithFloat:0].isFour);
	XCTAssertTrue([NSNumber numberWithDouble:4].isFour);
	XCTAssertFalse([NSNumber numberWithDouble:0].isFour);
}

- (void)testNSNumber_isFive
{
	XCTAssertFalse([NSNumber numberWithBool:-1].isFive);
	XCTAssertFalse([NSNumber numberWithBool:NO].isFive);
	
	XCTAssertFalse([NSNumber numberWithBool:YES].isFive);
	XCTAssertTrue([NSNumber numberWithChar:5].isFive);
	XCTAssertFalse([NSNumber numberWithChar:0].isFive);
	XCTAssertTrue([NSNumber numberWithUnsignedChar:5].isFive);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:0].isFive);
	
	XCTAssertTrue([NSNumber numberWithShort:5].isFive);
	XCTAssertFalse([NSNumber numberWithShort:0].isFive);
	XCTAssertTrue([NSNumber numberWithUnsignedShort:5].isFive);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:0].isFive);
	
	XCTAssertTrue([NSNumber numberWithUnichar:5].isFive);
	XCTAssertFalse([NSNumber numberWithUnichar:0].isFive);
	
	XCTAssertTrue([NSNumber numberWithInt:5].isFive);
	XCTAssertFalse([NSNumber numberWithInt:0].isFive);
	XCTAssertTrue([NSNumber numberWithUnsignedInt:5].isFive);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:0].isFive);
	
	XCTAssertTrue([NSNumber numberWithInteger:5].isFive);
	XCTAssertFalse([NSNumber numberWithInteger:0].isFive);
	XCTAssertTrue([NSNumber numberWithUnsignedInteger:5].isFive);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:0].isFive);
	
	XCTAssertTrue([NSNumber numberWithLong:5].isFive);
	XCTAssertFalse([NSNumber numberWithLong:0].isFive);
	XCTAssertTrue([NSNumber numberWithUnsignedLong:5].isFive);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:0].isFive);
	
	XCTAssertTrue([NSNumber numberWithLongLong:5].isFive);
	XCTAssertFalse([NSNumber numberWithLongLong:0].isFive);
	XCTAssertTrue([NSNumber numberWithUnsignedLongLong:5].isFive);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:0].isFive);
	
	XCTAssertTrue([NSNumber numberWithFloat:5].isFive);
	XCTAssertFalse([NSNumber numberWithFloat:0].isFive);
	XCTAssertTrue([NSNumber numberWithDouble:5].isFive);
	XCTAssertFalse([NSNumber numberWithDouble:0].isFive);
}

- (void)testNSNumber_isNotANumber
{
	XCTAssertFalse([NSNumber numberWithBool:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithBool:NO].isNotANumber);
	
	XCTAssertFalse([NSNumber numberWithChar:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithChar:0].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:0].isNotANumber);
	
	XCTAssertFalse([NSNumber numberWithShort:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithShort:0].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:0].isNotANumber);
	
	XCTAssertFalse([NSNumber numberWithUnichar:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnichar:0].isNotANumber);
	
	XCTAssertFalse([NSNumber numberWithInt:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithInt:0].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:0].isNotANumber);
	
	XCTAssertFalse([NSNumber numberWithInteger:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithInteger:0].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:0].isNotANumber);
	
	XCTAssertFalse([NSNumber numberWithLong:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithLong:0].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:0].isNotANumber);
	
	XCTAssertFalse([NSNumber numberWithLongLong:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithLongLong:0].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:0].isNotANumber);
	
	XCTAssertTrue([NSNumber numberWithFloat:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithFloat:0].isNotANumber);
	XCTAssertTrue([NSNumber numberWithDouble:NAN].isNotANumber);
	XCTAssertFalse([NSNumber numberWithDouble:0].isNotANumber);
}


- (void)testNSNumber_isInfinity
{
	XCTAssertFalse([NSNumber numberWithBool:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithBool:NO].isInfinity);
	
	XCTAssertFalse([NSNumber numberWithChar:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithChar:0].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:0].isInfinity);
	
	XCTAssertFalse([NSNumber numberWithShort:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithShort:0].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:0].isInfinity);
	
	XCTAssertFalse([NSNumber numberWithUnichar:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnichar:0].isInfinity);
	
	XCTAssertFalse([NSNumber numberWithInt:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithInt:0].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:0].isInfinity);
	
	XCTAssertFalse([NSNumber numberWithInteger:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithInteger:0].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:0].isInfinity);
	
	XCTAssertFalse([NSNumber numberWithLong:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithLong:0].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:0].isInfinity);
	
	XCTAssertFalse([NSNumber numberWithLongLong:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithLongLong:0].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:0].isInfinity);
	
	XCTAssertTrue([NSNumber numberWithFloat:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithFloat:0].isInfinity);
	XCTAssertTrue([NSNumber numberWithDouble:INFINITY].isInfinity);
	XCTAssertFalse([NSNumber numberWithDouble:0].isInfinity);
}


- (void)testNSNumber_isNegativeInfinity
{
	XCTAssertFalse([NSNumber numberWithBool:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithBool:NO].isNegativeInfinity);
	
	XCTAssertFalse([NSNumber numberWithChar:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithChar:0].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedChar:0].isNegativeInfinity);
	
	XCTAssertFalse([NSNumber numberWithShort:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithShort:0].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedShort:0].isNegativeInfinity);
	
	XCTAssertFalse([NSNumber numberWithUnichar:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnichar:0].isNegativeInfinity);
	
	XCTAssertFalse([NSNumber numberWithInt:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithInt:0].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedInt:0].isNegativeInfinity);
	
	XCTAssertFalse([NSNumber numberWithInteger:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithInteger:0].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedInteger:0].isNegativeInfinity);
	
	XCTAssertFalse([NSNumber numberWithLong:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithLong:0].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedLong:0].isNegativeInfinity);
	
	XCTAssertFalse([NSNumber numberWithLongLong:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithLongLong:0].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithUnsignedLongLong:0].isNegativeInfinity);
	
	XCTAssertTrue([NSNumber numberWithFloat:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithFloat:INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithFloat:0].isNegativeInfinity);
	XCTAssertTrue([NSNumber numberWithDouble:-INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithDouble:INFINITY].isNegativeInfinity);
	XCTAssertFalse([NSNumber numberWithDouble:0].isNegativeInfinity);
}



@end
