/*!
 @file			NSNumberBExtensionTests.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-06-23
 @abstract		Unit tests for the NSNumber+BExtension category.
 @discussion
*/

#import <XCTest/XCTest.h>
#import "NSNumber+BExtension.h"
#import "NSMockNumber.h"

@interface NSNumberBExtensionTests : XCTestCase
@end

@implementation NSNumberBExtensionTests

// Test Fixtures: Various NSNumber types to be used in tests
- (void)setUp {
	[super setUp];
	// This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
	// This method is called after the invocation of each test method in the class.
	[super tearDown];
}

- (void)testPow_int64
{
	XCTAssertEqual(pow_int64(10, 0), 1);
	XCTAssertEqual(pow_int64(0, 2), 0);
	XCTAssertEqual(pow_int64(1, 5), 1);
	XCTAssertEqual(pow_int64(-1, 5), -1);
	XCTAssertEqual(pow_int64(-1, 6), 1);
	XCTAssertEqual(pow_int64(33, 1), 33);
	
	XCTAssertEqual(pow_int64(1111, 63), 0);
	XCTAssertEqual(pow_int64(1111, 64), 0);
	
	XCTAssertEqual(pow_int64(sqrt(INT64_MAX) + 30, 2), 0);
	XCTAssertEqual(pow_int64(pow(INT64_MAX, 1.0/3.0) + 30, 3), 0);
	
	XCTAssertEqual(pow_int64(INT64_MIN, 2), 0);
	XCTAssertEqual(pow_int64(sqrt(INT64_MIN) + 30, 2), 0);
	XCTAssertEqual(pow_int64(pow(INT64_MIN, 1.0/3.0) + 30, 3), 0);
	
	XCTAssertEqual(pow_int64(55109, 4), 0);
	XCTAssertEqual(pow_int64(-55109, 5), 0);
}

- (void)testPow_uint64
{
	XCTAssertEqual(pow_uint64(10, 0), 1);
	XCTAssertEqual(pow_uint64(0, 2), 0);
	XCTAssertEqual(pow_uint64(1, 5), 1);
	XCTAssertEqual(pow_uint64(33, 1), 33);
	
	XCTAssertEqual(pow_uint64(1111, 63), 0);
	XCTAssertEqual(pow_uint64(1111, 64), 0);
}

#pragma mark - Addition Tests

- (void)testAddNumber_Basic {
	// Test adding two integers
	NSNumber *a = @5;
	NSNumber *b = @10;
	NSNumber *expected = @15;
	XCTAssertEqualObjects([a addNumber:b], expected, @"Integer addition failed.");

	// Test adding an integer and a double
	NSNumber *c = @5;
	NSNumber *d = @10.5;
	NSNumber *expectedDouble = @15.5;
	XCTAssertEqualObjects([c addNumber:d], expectedDouble, @"Integer and double addition failed. Type promotion to double should occur.");

	// Test adding two doubles
	NSNumber *e = @5.5;
	NSNumber *f = @10.5;
	NSNumber *expectedSumDouble = @16.0;
	XCTAssertEqualObjects([e addNumber:f], expectedSumDouble, @"Double addition failed.");
	
	// Test adding char and long long
	NSNumber *g = [NSNumber numberWithChar:10];
	NSNumber *h = [NSNumber numberWithLongLong:10000000000];
	NSNumber *expectedLongLong = [NSNumber numberWithLongLong:10000000010];
	XCTAssertEqualObjects([g addNumber:h], expectedLongLong, @"Char and Long Long addition failed.");
}

- (void)testAddNumber_Integers {
	// Test adding two integers
	SInt64 aInt, bInt;
	UInt64 aUInt, bUInt;
	
	aInt = -5;
	bInt = -10;
	NSNumber *a = [NSNumber numberWithLongLong:aInt];
	NSNumber *b = [NSNumber numberWithLongLong:bInt];
	NSNumber *expected = @-15;
	XCTAssertEqualObjects([a addNumber:b], expected, @"Integer addition failed.");
	XCTAssertEqual(aInt + bInt, -15);
	
	
	aUInt = 2;
	bInt = -10;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @-8;
	XCTAssertEqualObjects([a addNumber:b], expected, @"Integer addition failed.");
	XCTAssertEqual(aUInt + bInt, -8);
	
	
	aInt = -10;
	bUInt = 2;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @-8;
	XCTAssertEqualObjects([a addNumber:b], expected, @"Integer addition failed.");
	XCTAssertEqual(aInt + bUInt, -8);
	
	
	aUInt = 10;
	bUInt = 2;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @12;
	XCTAssertEqualObjects([a addNumber:b], expected, @"Integer addition failed.");
	XCTAssertEqual(aUInt + bUInt, 12);
	
	aUInt = 10;
	bUInt = -12;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:-2];
	XCTAssertEqualObjects([a addNumber:b], expected, @"Integer addition failed.");
	XCTAssertEqualObjects([b addNumber:a], expected, @"Integer addition failed.");
	XCTAssertEqual(aUInt + bUInt, -2);
	
	
	aUInt = -10;
	bUInt = -12;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:-22];
	XCTAssertEqualObjects([a addNumber:b], expected, @"Integer addition failed.");
	XCTAssertEqualObjects([b addNumber:a], expected, @"Integer addition failed.");
	XCTAssertEqual(aUInt + bUInt, -22);
}

- (void)testAddInt {
	NSNumber *a = @100;
	SInt64 b = -150;
	NSNumber *expected = @-50;
	XCTAssertEqualObjects([a addInt:b], expected, @"addInt failed.");
}

- (void)testAddUInt {
	NSNumber *a = @100;
	UInt64 b = 50;
	NSNumber *expected = @150;
	XCTAssertEqualObjects([a addUInt:b], expected, @"addUInt failed.");
}

- (void)testAddDouble {
	NSNumber *a = @100;
	double b = 50.75;
	NSNumber *expected = @150.75;
	XCTAssertEqualObjects([a addDouble:b], expected, @"addDouble failed.");
}


#pragma mark - Subtraction Tests

- (void)testSubtractNumber_Basic {
	// Test subtracting two integers
	NSNumber *a = @20;
	NSNumber *b = @5;
	NSNumber *expected = @15;
	XCTAssertEqualObjects([a subtractNumber:b], expected, @"Integer subtraction failed.");

	// Test subtracting an integer and a double
	NSNumber *c = @20;
	NSNumber *d = @4.5;
	NSNumber *expectedDouble = @15.5;
	XCTAssertEqualObjects([c subtractNumber:d], expectedDouble, @"Integer and double subtraction failed. Type promotion to double should occur.");

	// Test subtracting two doubles
	NSNumber *e = @10.5;
	NSNumber *f = @5.2;
	NSNumber *expectedSumDouble = @5.3;
	XCTAssertEqualObjects([e subtractNumber:f], expectedSumDouble, @"Double subtraction failed.");
	
	// Test subtracting char and long long
	NSNumber *g = [NSNumber numberWithLongLong:10000000000];
	NSNumber *h = [NSNumber numberWithChar:-10];
	NSNumber *expectedLongLong = [NSNumber numberWithLongLong:10000000010];
	XCTAssertEqualObjects([g subtractNumber:h], expectedLongLong, @"Char and Long Long subtraction failed.");
}

- (void)testSubtractNumber_Integers {
	// Test adding two integers
	SInt64 aInt, bInt;
	UInt64 aUInt, bUInt;
	
	aInt = -30;
	bInt = -10;
	NSNumber *a = [NSNumber numberWithLongLong:aInt];
	NSNumber *b = [NSNumber numberWithLongLong:bInt];
	NSNumber *expected = @-20;
	XCTAssertEqualObjects([a subtractNumber:b], expected, @"Integer subtraction failed.");
	XCTAssertEqual(aInt - bInt, -20);
	
	
	aUInt = 10;
	bInt = -20;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @30;
	XCTAssertEqualObjects([a subtractNumber:b], expected, @"Integer subtraction failed.");
	XCTAssertEqual(aUInt - bInt, 30);
	
	
	aInt = -10;
	bUInt = 2;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @-12;
	XCTAssertEqualObjects([a subtractNumber:b], expected, @"Integer subtraction failed.");
	XCTAssertEqual(aInt - bUInt, -12);
	
	
	aUInt = 10;
	bUInt = 2;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @8;
	XCTAssertEqualObjects([a subtractNumber:b], expected, @"Integer subtraction failed.");
	XCTAssertEqual(aUInt - bUInt, 8);

	
	aUInt = 10;
	bUInt = -2;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @12;
	XCTAssertEqualObjects([a subtractNumber:b], expected, @"Integer subtraction failed.");
	expected = [NSNumber numberWithUnsignedLongLong:-12];
	XCTAssertEqualObjects([b subtractNumber:a], expected, @"Integer subtraction failed.");
	XCTAssertEqual(aUInt - bUInt, 12);
	

	aUInt = -12;
	bUInt = -5;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:-7];
	XCTAssertEqualObjects([a subtractNumber:b], expected, @"Integer subtraction failed.");
	expected = @((unsigned long long)7);
	XCTAssertEqualObjects([b subtractNumber:a], expected, @"Integer subtraction failed.");
	XCTAssertEqual(aUInt - bUInt, -7);
}

- (void)testSubtractInt {
	NSNumber *a = @-100;
	SInt64 b = -75;
	NSNumber *expected = @-25;
	XCTAssertEqualObjects([a subtractInt:b], expected, @"subtractInt failed.");
}

- (void)testSubtractUInt {
	NSNumber *a = @100;
	UInt64 b = 25;
	NSNumber *expected = @75;
	XCTAssertEqualObjects([a subtractUInt:b], expected, @"subtractUInt failed.");
}

- (void)testSubtractDouble {
	NSNumber *a = @100;
	double b = 50.75;
	NSNumber *expected = @49.25;
	XCTAssertEqualObjects([a subtractDouble:b], expected, @"subtractDouble failed.");
}

#pragma mark - Multiplication Tests

- (void)testMultiplyNumber_Basic {
	
	// Test multiplying two integers
	NSNumber *a = @7;
	NSNumber *b = @6;
	NSNumber *expected = @42;
	XCTAssertEqualObjects([a multiplyNumber:b], expected, @"Integer multiply failed.");

	// Test multiplying an integer and a double
	NSNumber *c = @3;
	NSNumber *d = @4.5;
	NSNumber *expectedDouble = @13.5;
	XCTAssertEqualObjects([c multiplyNumber:d], expectedDouble, @"Integer and double multiply failed. Type promotion to double should occur.");

	// Test multiplying two doubles
	NSNumber *e = @2.5;
	NSNumber *f = @3.5;
	NSNumber *expectedSumDouble = @8.75;
	XCTAssertEqualObjects([e multiplyNumber:f], expectedSumDouble, @"Double multiply failed.");
	
	// Test multiplying char and long long
	NSNumber *g = [NSNumber numberWithLongLong:10000000000];
	NSNumber *h = [NSNumber numberWithChar:-10];
	NSNumber *expectedLongLong = [NSNumber numberWithLongLong:-100000000000];
	XCTAssertEqualObjects([g multiplyNumber:h], expectedLongLong, @"Char and Long Long multiply failed.");
}

- (void)testMultiplyNumber_Integers {
	// Test adding two integers
	SInt64 aInt, bInt;
	UInt64 aUInt, bUInt;
	
	aInt = -30;
	bInt = -10;
	NSNumber *a = [NSNumber numberWithLongLong:aInt];
	NSNumber *b = [NSNumber numberWithLongLong:bInt];
	NSNumber *expected = @300;
	XCTAssertEqualObjects([a multiplyNumber:b], expected, @"Integer multiply failed.");
	XCTAssertEqual(aInt * bInt, 300);
	
	
	aInt = -30;
	bInt = 10;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @-300;
	XCTAssertEqualObjects([a multiplyNumber:b], expected, @"Integer multiply failed.");
	XCTAssertEqual(aInt * bInt, -300);
	
	
	aUInt = 10;
	bInt = -20;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @-200;
	XCTAssertEqualObjects([a multiplyNumber:b], expected, @"Integer multiply failed.");
	XCTAssertEqual(aUInt * bInt, ((unsigned long long)-200));
	
	
	aInt = -10;
	bUInt = 2;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @-20;
	XCTAssertEqualObjects([a multiplyNumber:b], expected, @"Integer multiply failed.");
	XCTAssertEqual(aInt * bUInt, (unsigned long long)-20);
	
	
	aUInt = 10;
	bUInt = 2;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @20;
	XCTAssertEqualObjects([a multiplyNumber:b], expected, @"Integer multiply failed.");
	XCTAssertEqual(aUInt * bUInt, 20);
	
	
	aUInt = 10;
	bUInt = -2;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:-20];
	XCTAssertEqualObjects([a multiplyNumber:b], expected, @"Integer multiply failed.");
	XCTAssertEqualObjects([b multiplyNumber:a], expected, @"Integer multiply failed.");
	XCTAssertEqual(aUInt * bUInt, (unsigned long long)-20);
	
	
	aUInt = -10;
	bUInt = -2;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:20];
	XCTAssertEqualObjects([a multiplyNumber:b], expected, @"Integer multiply failed.");
	XCTAssertEqualObjects([b multiplyNumber:a], expected, @"Integer multiply failed.");
	XCTAssertEqual(aUInt * bUInt, (unsigned long long)20);
}

- (void)testMultiplyInt {
	NSNumber *a = @5;
	SInt64 b = -2;
	NSNumber *expected = @-10.0;
	XCTAssertEqualObjects([a multiplyInt:b], expected, @"multiplyInt failed.");
}

- (void)testMultiplyUInt {
	NSNumber *a = @5;
	UInt64 b = 2;
	NSNumber *expected = @10.0;
	XCTAssertEqualObjects([a multiplyUInt:b], expected, @"multiplyUInt failed.");
}

- (void)testMultiplyDouble {
	NSNumber *a = @5.5;
	double b = 2.0;
	NSNumber *expected = @11.0;
	XCTAssertEqualObjects([a multiplyDouble:b], expected, @"multiplyDouble failed.");
}

#pragma mark - Division Tests

- (void)testDivideNumber {
	
	// Test divide two integers
	NSNumber *a = @20;
	NSNumber *b = @4;
	NSNumber *expected = @5;
	XCTAssertEqualObjects([a divideNumber:b], expected, @"Integer division failed.");

	// Test divide an integer and a double
	NSNumber *c = @2.22;
	NSNumber *d = @0.1;
	NSNumber *expectedDouble = @22.2;
	XCTAssertEqualObjects([c divideNumber:d], expectedDouble, @"Integer and double division failed. Type promotion to double should occur.");

	// Test divide two doubles
	NSNumber *e = @3.25;
	NSNumber *f = @0.1;
	NSNumber *expectedSumDouble = @32.5;
	XCTAssertEqualObjects([e divideNumber:f], expectedSumDouble, @"Double division failed.");
	
	// Test divide char and long long
	NSNumber *g = [NSNumber numberWithLongLong:10000000000];
	NSNumber *h = [NSNumber numberWithChar:-10];
	NSNumber *expectedLongLong = [NSNumber numberWithLongLong:-1000000000];
	XCTAssertEqualObjects([g divideNumber:h], expectedLongLong, @"Char and Long Long division failed.");
}

- (void)testDivideNumber_ByZero {
	// Test division by zero for integer types
	NSNumber *g = @10;
	NSNumber *h = @0;
	NSNumber *result = [g divideNumber:h];
	XCTAssertTrue(isnan([result doubleValue]), @"Division by zero should result in NAN.");
	XCTAssertEqualObjects(result, @(NAN) );
	
	// Test division by zero for floating point types
	NSNumber *i = @10.1;
	NSNumber *j = @0.0;
	NSNumber *fpResult = [i divideNumber:j];
	XCTAssertTrue(isinf([fpResult doubleValue]), @"Floating point division by zero should be infinity.");
}

- (void)testDivideNumber_Integers {
	// Test adding two integers
	SInt64 aInt, bInt;
	UInt64 aUInt, bUInt;
	
	aInt = -30;
	bInt = -10;
	NSNumber *a = [NSNumber numberWithLongLong:aInt];
	NSNumber *b = [NSNumber numberWithLongLong:bInt];
	NSNumber *expected = @3;
	XCTAssertEqualObjects([a divideNumber:b], expected, @"Integer divide failed.");
	XCTAssertEqual(aInt / bInt, 3);
	
	
	aInt = -30;
	bInt = 10;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @-3;
	XCTAssertEqualObjects([a divideNumber:b], expected, @"Integer divide failed.");
	XCTAssertEqual(aInt / bInt, -3);
	
	
	aUInt = 20;
	bInt = -10;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @-2;
	XCTAssertEqualObjects([a divideNumber:b], expected, @"Integer divide failed.");
	XCTAssertEqual(aUInt / bInt, (0), @"bInt (as -10) is converted into unsigned, which is huge, thus result is 0");
	
	
	aInt = -10;
	bUInt = 2;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @-5;
	XCTAssertEqualObjects([a divideNumber:b], expected, @"Integer divide failed.");
	//XCTAssertEqual(aInt / bUInt, ((unsigned long long)(-5 << 1)) >> 1);
	
	
	aUInt = 10;
	bUInt = 2;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @5;
	XCTAssertEqualObjects([a divideNumber:b], expected, @"Integer divide failed.");
	XCTAssertEqual(aUInt / bUInt, 5);
	
	
	aUInt = 10;
	bUInt = -2;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:0];
	XCTAssertEqualObjects([a divideNumber:b], expected, @"Integer divide failed. negative unsigned is HUGE, result is 0.");
	XCTAssertEqual(aUInt / bUInt, (unsigned long long)0);
	
	
	aUInt = -1;
	bUInt = INT64_MAX;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:2];
	XCTAssertEqualObjects([a divideNumber:b], expected, @"Integer divide failed. -1 (UINT64_MAX) / INT64_MAX, result is 2.");
	XCTAssertEqual(aUInt / bUInt, (unsigned long long)2);
	
	
	aUInt = -1;
	bUInt = (unsigned long long)INT64_MAX + 1;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:1];
	XCTAssertEqualObjects([a divideNumber:b], expected, @"Integer divide failed. -1 (UINT64_MAX) / INT64_MAX, result is 1.");
	XCTAssertEqual(aUInt / bUInt, (unsigned long long)1);
}

- (void)testDivideInt {
	NSNumber *a = @100;
	SInt64 b = -4;
	NSNumber *expected = @-25;
	XCTAssertEqualObjects([a divideInt:b], expected, @"divideInt failed.");
	
	a = @-100;
	b = -4;
	expected = @25;
	XCTAssertEqualObjects([a divideInt:b], expected, @"divideInt failed.");
}

- (void)testDivideUInt {
	NSNumber *a = @100;
	UInt64 b = 4;
	NSNumber *expected = @25;
	XCTAssertEqualObjects([a divideUInt:b], expected, @"divideUInt failed.");
}

- (void)testDivideDouble {
	NSNumber *a = @125.25;
	double b = 2.5;
	NSNumber *expected = @50.1;
	XCTAssertEqualObjects([a divideDouble:b], expected, @"divideDouble failed.");
}

#pragma mark - Modulus Tests

- (void)testModulusNumber_Basic {
	
	// Test divide two integers
	NSNumber *a = @23;
	NSNumber *b = @4;
	NSNumber *expected = @3;
	XCTAssertEqualObjects([a modulusNumber:b], expected, @"Integer modulus failed.");

	// Test divide an integer and a double
	NSNumber *c = @4;
	NSNumber *d = @1.2;
	NSNumber *expectedDouble = @0.4;
	XCTAssertEqualWithAccuracy([c modulusNumber:d].doubleValue, expectedDouble.doubleValue, 0.00000000001, @"Integer and double modulus failed. Type promotion to double should occur.");

	// Test divide two doubles
	NSNumber *e = @3.5;
	NSNumber *f = @1.2;
	NSNumber *expectedSumDouble = @1.1;
	XCTAssertEqualObjects([e modulusNumber:f], expectedSumDouble, @"Double modulus failed.");
	
	// Test divide char and long long
	NSNumber *g = [NSNumber numberWithLongLong:333];
	NSNumber *h = [NSNumber numberWithChar:-10];
	NSNumber *expectedLongLong = [NSNumber numberWithLongLong:3];
	XCTAssertEqualObjects([g modulusNumber:h], expectedLongLong, @"Char and Long Long modulus failed.");
}

- (void)testModulusNumber_Integers {
	// Test adding two integers
	SInt64 aInt, bInt;
	UInt64 aUInt, bUInt;
	
	aInt = -33;
	bInt = -10;
	NSNumber *a = [NSNumber numberWithLongLong:aInt];
	NSNumber *b = [NSNumber numberWithLongLong:bInt];
	NSNumber *expected = @-3;
	XCTAssertEqualObjects([a modulusNumber:b], expected, @"Integer modulus failed.");
	XCTAssertEqual(aInt % bInt, -3);
	
	
	aInt = -33;
	bInt = 10;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @-3;
	XCTAssertEqualObjects([a modulusNumber:b], expected, @"Integer modulus failed.");
	XCTAssertEqual(aInt % bInt, -3);
	
	
	aUInt = 23;
	bInt = -10;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @3;
	XCTAssertEqualObjects([a modulusNumber:b], expected, @"Integer modulus failed.");
	XCTAssertEqual(aUInt % bInt, 23, @"modulus is converted to unsigned, which is huge.");
	
	
	aInt = -33;
	bUInt = 10;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @-3;
	XCTAssertEqualObjects([a modulusNumber:b], expected, @"Integer modulus failed.");
	XCTAssertEqual(aInt % bUInt, 3);
	
	
	aUInt = 34;
	bUInt = 10;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @4;
	XCTAssertEqualObjects([a modulusNumber:b], expected, @"Integer modulus failed.");
	XCTAssertEqual(aUInt % bUInt, 4);
	
	
	aUInt = 35;
	bUInt = -10;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:35];
	XCTAssertEqualObjects([a modulusNumber:b], expected, @"Integer modulus failed.");
	XCTAssertEqual(aUInt % bUInt, 35, @"modulus number is 'negative' thus huge as unsigned.");
	
	aUInt = -11;
	bUInt = 3;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:2];
	XCTAssertEqualObjects([a modulusNumber:b], expected, @"Integer modulus failed.");
	XCTAssertEqual(aUInt % bUInt, 2, @"modulus number is 'negative' thus huge as unsigned.");
	
	
	aUInt = -1;
	bUInt = (unsigned long long)INT64_MAX + 1;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:INT64_MAX];
	XCTAssertEqualObjects([a modulusNumber:b], expected, @"Integer modulus failed.");
	XCTAssertEqual(aUInt % bUInt, INT64_MAX, @"modulus number is 'negative' thus huge as unsigned.");
}

- (void)testModulusInt {
	NSNumber *a = @111;
	SInt64 b = -9;
	NSNumber *expected = @3;
	XCTAssertEqualObjects([a modulusInt:b], expected, @"Integer modulus failed.");
	XCTAssertEqual(a.longLongValue % b, expected.longLongValue);
	
	a = @-111;
	b = -9;
	expected = @-3;
	XCTAssertEqualObjects([a modulusInt:b], expected, @"Integer modulus failed.");
	XCTAssertEqual(a.longLongValue % b, expected.longLongValue);
	
	a = @-111;
	b = 9;
	expected = @-3;
	XCTAssertEqualObjects([a modulusInt:b], expected, @"Integer modulus failed.");
	XCTAssertEqual(a.longLongValue % b, expected.longLongValue);
}

- (void)testModulusUInt {
	NSNumber *a = @111;
	UInt64 b = 9;
	NSNumber *expected = @3;
	XCTAssertEqualObjects([a modulusUInt:b], expected, @"modulusUInt failed.");
}

- (void)testModulusDouble {
	NSNumber *a = @111.25;
	double b = 9.5;
	NSNumber *expected = @6.75;
	XCTAssertEqualObjects([a modulusDouble:b], expected, @"modulusDouble failed.");
}

#pragma mark - Power Tests

- (void)testPowerNumber_Basic {
	
	// Test power two integers
	NSNumber *a = @2;
	NSNumber *b = @8;
	NSNumber *expected = @256;
	XCTAssertEqualObjects([a powerNumber:b], expected, @"Integer power failed.");

	// Test power an integer and a double
	NSNumber *c = @4;
	NSNumber *d = @2.5;
	NSNumber *expectedDouble = @32;
	XCTAssertEqualWithAccuracy([c powerNumber:d].doubleValue, expectedDouble.doubleValue, 0.00000000001, @"Integer and double power failed. Type promotion to double should occur.");
	
	// Test power an integer and a double
	c = @4;
	d = @0.5;
	expected = @2;
	XCTAssertEqualObjects([c powerNumber:d], expected, @"Integer and double power failed. Type promotion to double should occur.");

	// Test power two doubles
	NSNumber *e = @4;
	NSNumber *f = @0.5;
	NSNumber *expectedSumDouble = @2;
	XCTAssertEqualObjects([e powerNumber:f], expectedSumDouble, @"Double power failed.");
	
	// Test power char and long long
	NSNumber *g = [NSNumber numberWithLongLong:2];
	NSNumber *h = [NSNumber numberWithChar:16];
	NSNumber *expectedLongLong = [NSNumber numberWithLongLong:65536];
	XCTAssertEqualObjects([g powerNumber:h], expectedLongLong, @"Char and Long Long power failed.");
}

- (void)testPowerNumber_Integers {
	// Test adding two integers
	SInt64 aInt, bInt;
	UInt64 aUInt, bUInt;
	
	aInt = -2;
	bInt = 7;
	NSNumber *a = [NSNumber numberWithLongLong:aInt];
	NSNumber *b = [NSNumber numberWithLongLong:bInt];
	NSNumber *expected = @-128;
	XCTAssertEqualObjects([a powerNumber:b], expected, @"Integer power failed.");
	XCTAssertEqual(pow_int64(aInt, bInt), -128);
	
	
	aInt = -2;
	bInt = 8;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @256;
	XCTAssertEqualObjects([a powerNumber:b], expected, @"Integer power failed.");
	XCTAssertEqual(pow_int64(aInt, bInt), 256);
	
	
	aUInt = 2;
	bInt = 6;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @64;
	XCTAssertEqualObjects([a powerNumber:b], expected, @"Integer power failed.");
	XCTAssertEqual(pow_uint64(aUInt, bInt), 64);
	
	
	aInt = -2;
	bUInt = 5;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @-32;
	XCTAssertEqualObjects([a powerNumber:b], expected, @"Integer power failed.");
	XCTAssertEqual(pow_int64(aInt, bUInt), -32);
	
	aInt = -2;
	bUInt = 6;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @64;
	XCTAssertEqualObjects([a powerNumber:b], expected, @"Integer power failed.");
	XCTAssertEqual(pow_int64(aInt, bUInt), 64);
	
	
	aUInt = 2;
	bUInt = 16;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @65536;
	XCTAssertEqualObjects([a powerNumber:b], expected, @"Integer power failed.");
	XCTAssertEqual(pow_int64(aUInt, bUInt), 65536);
	
	
	aUInt = 2;
	bUInt = 16;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @65536;
	XCTAssertEqualObjects([a powerNumber:b], expected, @"Integer power failed.");
	XCTAssertEqual(pow_int64(aUInt, bUInt), 65536);
	
	
	aUInt = ((unsigned long long )INT64_MAX) + 1;
	bUInt = 1;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @(((unsigned long long )INT64_MAX) + 1);
	XCTAssertEqualObjects([a powerNumber:b], expected, @"Integer power failed.");
	
	
	aUInt = 1;
	bUInt = ((unsigned long long )INT64_MAX) + 1;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @(1);
	XCTAssertEqualObjects([a powerNumber:b], expected, @"Integer power failed.");
	
	
	aUInt = -1;
	bUInt = ((unsigned long long )INT64_MAX) + 1;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @(0);
	XCTAssertEqualObjects([a powerNumber:b], expected, @"Integer power failed.");
}

- (void)testPowerUInt {
	NSNumber *a = @111;
	UInt64 b = 3;
	NSNumber *expected = @1367631;
	XCTAssertEqualObjects([a powerUInt:b], expected, @"powerUInt failed.");
}

- (void)testPowerDouble {
	NSNumber *a = @1.5;
	double b = 2.5;
	NSNumber *expected = @2.755675960631075;
	XCTAssertEqualWithAccuracy([a powerDouble:b].doubleValue, expected.doubleValue, 0.0000000001, @"powerDouble failed.");
}

#pragma mark - XOR Tests

- (void)testXorNumber {
	// 1010 ^ 1100 = 0110 (10 ^ 12 = 6)
	NSNumber *a = @10;
	NSNumber *b = @12;
	NSNumber *expected = @6;
	XCTAssertEqualObjects([a xorNumber:b], expected, @"Integer XOR failed.");

	// XOR with different types
	NSNumber *c = [NSNumber numberWithChar:'A']; // 65
	NSNumber *d = @32;
	// 01000001 ^ 00100000 = 01100001 (97, which is 'a')
	NSNumber *expectedChar = [NSNumber numberWithInt:97];
	XCTAssertEqualObjects([c xorNumber:d], expectedChar, @"Char and Int XOR failed.");
}


- (void)testXorNumber_Integers {
	// Test adding two integers
	SInt64 aInt, bInt;
	UInt64 aUInt, bUInt;
	
	aInt = 15;
	bInt = 9;
	NSNumber *a = [NSNumber numberWithLongLong:aInt];
	NSNumber *b = [NSNumber numberWithLongLong:bInt];
	NSNumber *expected = @6;
	XCTAssertEqualObjects([a xorNumber:b], expected, @"Integer XOR failed.");
	XCTAssertEqual(aInt ^ bInt, 6);
	
	
	aInt = 15;
	bInt = -9;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @-8;
	XCTAssertEqualObjects([a xorNumber:b], expected, @"Integer XOR failed.");
	XCTAssertEqual(aInt ^ bInt, -8);
	
	
	aUInt = 2;
	bInt = 6;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithLongLong:bInt];
	expected = @4;
	XCTAssertEqualObjects([a xorNumber:b], expected, @"Integer XOR failed.");
	XCTAssertEqual(aUInt ^ bInt, 4);
	
	
	aInt = -3;
	bUInt = 15;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @-14;
	XCTAssertEqualObjects([a xorNumber:b], expected, @"Integer XOR failed.");
	XCTAssertEqual(aInt ^ bUInt, (unsigned long long)-14);
	
	aInt = -2;
	bUInt = 6;
	a = [NSNumber numberWithLongLong:aInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @-8;
	XCTAssertEqualObjects([a xorNumber:b], expected, @"Integer XOR failed.");
	XCTAssertEqual(aInt ^ bUInt, -8);
	
	
	aUInt = 7;
	bUInt = 16;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = @23;
	XCTAssertEqualObjects([a xorNumber:b], expected, @"Integer XOR failed.");
	XCTAssertEqual(aUInt ^ bUInt, 23);
	
	aUInt = 7;
	bUInt = -17;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:-24];
	XCTAssertEqualObjects([a xorNumber:b], expected, @"Integer XOR failed.");
	XCTAssertEqualObjects([b xorNumber:a], expected, @"Integer XOR failed.");
	XCTAssertEqual(aUInt ^ bUInt, (unsigned long long)-24);
	
	aUInt = -1;
	bUInt = -24;
	a = [NSNumber numberWithUnsignedLongLong:aUInt];
	b = [NSNumber numberWithUnsignedLongLong:bUInt];
	expected = [NSNumber numberWithUnsignedLongLong:23];
	XCTAssertEqualObjects([a xorNumber:b], expected, @"Integer XOR failed.");
	XCTAssertEqualObjects([b xorNumber:a], expected, @"Integer XOR failed.");
	XCTAssertEqual(aUInt ^ bUInt, (unsigned long long)23);
}


- (void)testXorNumber_Double {
	double aDbl, bDbl;
	aDbl = 15;
	bDbl = 9;
	NSNumber *a = [NSNumber numberWithDouble:aDbl];
	NSNumber *b = [NSNumber numberWithDouble:bDbl];
	NSNumber *expected = @(((UInt64)aDbl) ^ ((UInt64)bDbl));
	XCTAssertEqualObjects([a xorNumber:b], expected, @"Double XOR failed.");
}

- (void)testXorInt {
	NSNumber *a = @15; // 1111
	SInt64 b = 9;      // 1001
	// 1111 ^ 1001 = 0110 (6)
	NSNumber *expected = @6;
	XCTAssertEqualObjects([a xorInt:b], expected, @"xorInt failed.");
}

- (void)testXorUInt {
	NSNumber *a = @15;
	UInt64 b = 9;
	NSNumber *expected = @6;
	XCTAssertEqualObjects([a xorUInt:b], expected, @"xorUInt failed.");
}

#pragma mark - Type Precedence Tests

- (void)testTypePrecedence {
	// int ('i') vs double ('d'). double has higher precedence.
	NSNumber *a = @5;
	NSNumber *b = @2.5;
	NSNumber *resultAdd = [a addNumber:b];
	XCTAssertTrue(strcmp([resultAdd objCType], @encode(double)) == 0, @"Type precedence failed for add. Expected double, got %s", [resultAdd objCType]);
	XCTAssertEqualObjects(resultAdd, @7.5);

	// long long ('q') vs unsigned int ('I'). long long ('q') should be chosen.
	NSNumber *c = [NSNumber numberWithLongLong:100];
	NSNumber *d = [NSNumber numberWithUnsignedInt:50];
	NSNumber *resultSub = [c subtractNumber:d];
	 XCTAssertTrue(strcmp([resultSub objCType], @encode(long long)) == 0, @"Type precedence failed for subtract. Expected long long, got %s", [resultSub objCType]);
	XCTAssertEqualObjects(resultSub, @50LL);
	
	// char ('c') vs float ('f'). float has higher precedence.
	NSNumber *e = [NSNumber numberWithChar:10];
	NSNumber *f = [NSNumber numberWithFloat:2.5f];
	NSNumber *resultMul = [e multiplyNumber:f];
	XCTAssertTrue(strcmp([resultMul objCType], @encode(float)) == 0, @"Type precedence failed for multiply. Expected float, got %s", [resultMul objCType]);
	XCTAssertEqualWithAccuracy([resultMul floatValue], 25.0f, 0.001);
}


- (void)testTypeChecks_char {
	NSMockNumber *boolNONumber = [NSMockNumber numberWithBool:NO];
	NSMockNumber *boolYESNumber = [NSMockNumber numberWithBool:YES];
	
	NSMockNumber *cNumber = [NSMockNumber numberWithChar:-11];
	NSMockNumber *ucNumber = [NSMockNumber numberWithUnsignedChar:10];
	
	NSMockNumber *sNumber = [NSMockNumber numberWithShort:-111];
	NSMockNumber *usNumber = [NSMockNumber numberWithUnsignedShort:110];
	
	NSMockNumber *iNumber = [NSMockNumber numberWithInt:-1111];
	NSMockNumber *uiNumber = [NSMockNumber numberWithUnsignedInt:1110];
	
	NSMockNumber *lNumber = [NSMockNumber numberWithLong:-11111];
	NSMockNumber *ulNumber = [NSMockNumber numberWithUnsignedLong:11110];
	
	NSMockNumber *llNumber = [NSMockNumber numberWithLongLong:-111111];
	NSMockNumber *ullNumber = [NSMockNumber numberWithUnsignedLongLong:111110];
	
	NSNumber *checkNumber = cNumber;
	
	NSNumber *result = [checkNumber addNumber:boolNONumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolNONumber.longLongValue);
	
	result = [checkNumber addNumber:boolYESNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolYESNumber.longLongValue);
	
	result = [checkNumber addNumber:cNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + cNumber.longLongValue);
	
	result = [checkNumber addNumber:ucNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ucNumber.longLongValue);
	
	result = [checkNumber addNumber:sNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + sNumber.longLongValue);
	
	result = [checkNumber addNumber:usNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + usNumber.longLongValue);
	
	result = [checkNumber addNumber:iNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + iNumber.longLongValue);
	
	result = [checkNumber addNumber:uiNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + uiNumber.longLongValue);
	
	result = [checkNumber addNumber:lNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + lNumber.longLongValue);
	
	result = [checkNumber addNumber:ulNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ulNumber.longLongValue);
	
	result = [checkNumber addNumber:llNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + llNumber.longLongValue);
	
	result = [checkNumber addNumber:ullNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ullNumber.longLongValue);
}


- (void)testTypeChecks_unsignedChar {
	NSMockNumber *boolNONumber = [NSMockNumber numberWithBool:NO];
	NSMockNumber *boolYESNumber = [NSMockNumber numberWithBool:YES];
	
	NSMockNumber *cNumber = [NSMockNumber numberWithChar:-11];
	NSMockNumber *ucNumber = [NSMockNumber numberWithUnsignedChar:10];
	
	NSMockNumber *sNumber = [NSMockNumber numberWithShort:-111];
	NSMockNumber *usNumber = [NSMockNumber numberWithUnsignedShort:110];
	
	NSMockNumber *iNumber = [NSMockNumber numberWithInt:-1111];
	NSMockNumber *uiNumber = [NSMockNumber numberWithUnsignedInt:1110];
	
	NSMockNumber *lNumber = [NSMockNumber numberWithLong:-11111];
	NSMockNumber *ulNumber = [NSMockNumber numberWithUnsignedLong:11110];
	
	NSMockNumber *llNumber = [NSMockNumber numberWithLongLong:-111111];
	NSMockNumber *ullNumber = [NSMockNumber numberWithUnsignedLongLong:111110];
	
	NSNumber *checkNumber = ucNumber;
	
	NSNumber *result = [checkNumber addNumber:boolNONumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolNONumber.longLongValue);
	
	result = [checkNumber addNumber:boolYESNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolYESNumber.longLongValue);
	
	result = [checkNumber addNumber:cNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + cNumber.longLongValue);
	
	result = [checkNumber addNumber:ucNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ucNumber.longLongValue);
	
	result = [checkNumber addNumber:sNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + sNumber.longLongValue);
	
	result = [checkNumber addNumber:usNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + usNumber.longLongValue);
	
	result = [checkNumber addNumber:iNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + iNumber.longLongValue);
	
	result = [checkNumber addNumber:uiNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + uiNumber.longLongValue);
	
	result = [checkNumber addNumber:lNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + lNumber.longLongValue);
	
	result = [checkNumber addNumber:ulNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ulNumber.longLongValue);
	
	result = [checkNumber addNumber:llNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + llNumber.longLongValue);
	
	result = [checkNumber addNumber:ullNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ullNumber.longLongValue);
}


- (void)testTypeChecks_short {
	NSMockNumber *boolNONumber = [NSMockNumber numberWithBool:NO];
	NSMockNumber *boolYESNumber = [NSMockNumber numberWithBool:YES];
	
	NSMockNumber *cNumber = [NSMockNumber numberWithChar:-11];
	NSMockNumber *ucNumber = [NSMockNumber numberWithUnsignedChar:10];
	
	NSMockNumber *sNumber = [NSMockNumber numberWithShort:-111];
	NSMockNumber *usNumber = [NSMockNumber numberWithUnsignedShort:110];
	
	NSMockNumber *iNumber = [NSMockNumber numberWithInt:-1111];
	NSMockNumber *uiNumber = [NSMockNumber numberWithUnsignedInt:1110];
	
	NSMockNumber *lNumber = [NSMockNumber numberWithLong:-11111];
	NSMockNumber *ulNumber = [NSMockNumber numberWithUnsignedLong:11110];
	
	NSMockNumber *llNumber = [NSMockNumber numberWithLongLong:-111111];
	NSMockNumber *ullNumber = [NSMockNumber numberWithUnsignedLongLong:111110];
	
	NSNumber *checkNumber = sNumber;
	
	NSNumber *result = [checkNumber addNumber:boolNONumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolNONumber.longLongValue);
	
	result = [checkNumber addNumber:boolYESNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolYESNumber.longLongValue);
	
	result = [checkNumber addNumber:cNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + cNumber.longLongValue);
	
	result = [checkNumber addNumber:ucNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ucNumber.longLongValue);
	
	result = [checkNumber addNumber:sNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + sNumber.longLongValue);
	
	result = [checkNumber addNumber:usNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + usNumber.longLongValue);
	
	result = [checkNumber addNumber:iNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + iNumber.longLongValue);
	
	result = [checkNumber addNumber:uiNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + uiNumber.longLongValue);
	
	result = [checkNumber addNumber:lNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + lNumber.longLongValue);
	
	result = [checkNumber addNumber:ulNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ulNumber.longLongValue);
	
	result = [checkNumber addNumber:llNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + llNumber.longLongValue);
	
	result = [checkNumber addNumber:ullNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ullNumber.longLongValue);
}


- (void)testTypeChecks_unsignedShort {
	NSMockNumber *boolNONumber = [NSMockNumber numberWithBool:NO];
	NSMockNumber *boolYESNumber = [NSMockNumber numberWithBool:YES];
	
	NSMockNumber *cNumber = [NSMockNumber numberWithChar:-11];
	NSMockNumber *ucNumber = [NSMockNumber numberWithUnsignedChar:10];
	
	NSMockNumber *sNumber = [NSMockNumber numberWithShort:-111];
	NSMockNumber *usNumber = [NSMockNumber numberWithUnsignedShort:110];
	
	NSMockNumber *iNumber = [NSMockNumber numberWithInt:-1111];
	NSMockNumber *uiNumber = [NSMockNumber numberWithUnsignedInt:1110];
	
	NSMockNumber *lNumber = [NSMockNumber numberWithLong:-11111];
	NSMockNumber *ulNumber = [NSMockNumber numberWithUnsignedLong:11110];
	
	NSMockNumber *llNumber = [NSMockNumber numberWithLongLong:-111111];
	NSMockNumber *ullNumber = [NSMockNumber numberWithUnsignedLongLong:111110];
	
	NSNumber *checkNumber = usNumber;
	
	NSNumber *result = [checkNumber addNumber:boolNONumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolNONumber.longLongValue);
	
	result = [checkNumber addNumber:boolYESNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolYESNumber.longLongValue);
	
	result = [checkNumber addNumber:cNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + cNumber.longLongValue);
	
	result = [checkNumber addNumber:ucNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ucNumber.longLongValue);
	
	result = [checkNumber addNumber:sNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + sNumber.longLongValue);
	
	result = [checkNumber addNumber:usNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + usNumber.longLongValue);
	
	result = [checkNumber addNumber:iNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + iNumber.longLongValue);
	
	result = [checkNumber addNumber:uiNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + uiNumber.longLongValue);
	
	result = [checkNumber addNumber:lNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + lNumber.longLongValue);
	
	result = [checkNumber addNumber:ulNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ulNumber.longLongValue);
	
	result = [checkNumber addNumber:llNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + llNumber.longLongValue);
	
	result = [checkNumber addNumber:ullNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ullNumber.longLongValue);
}


- (void)testTypeChecks_int {
	NSMockNumber *boolNONumber = [NSMockNumber numberWithBool:NO];
	NSMockNumber *boolYESNumber = [NSMockNumber numberWithBool:YES];
	
	NSMockNumber *cNumber = [NSMockNumber numberWithChar:-11];
	NSMockNumber *ucNumber = [NSMockNumber numberWithUnsignedChar:10];
	
	NSMockNumber *sNumber = [NSMockNumber numberWithShort:-111];
	NSMockNumber *usNumber = [NSMockNumber numberWithUnsignedShort:110];
	
	NSMockNumber *iNumber = [NSMockNumber numberWithInt:-1111];
	NSMockNumber *uiNumber = [NSMockNumber numberWithUnsignedInt:1110];
	
	NSMockNumber *lNumber = [NSMockNumber numberWithLong:-11111];
	NSMockNumber *ulNumber = [NSMockNumber numberWithUnsignedLong:11110];
	
	NSMockNumber *llNumber = [NSMockNumber numberWithLongLong:-111111];
	NSMockNumber *ullNumber = [NSMockNumber numberWithUnsignedLongLong:111110];
	
	NSNumber *checkNumber = iNumber;
	
	NSNumber *result = [checkNumber addNumber:boolNONumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolNONumber.longLongValue);
	
	result = [checkNumber addNumber:boolYESNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolYESNumber.longLongValue);
	
	result = [checkNumber addNumber:cNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + cNumber.longLongValue);
	
	result = [checkNumber addNumber:ucNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ucNumber.longLongValue);
	
	result = [checkNumber addNumber:sNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + sNumber.longLongValue);
	
	result = [checkNumber addNumber:usNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + usNumber.longLongValue);
	
	result = [checkNumber addNumber:iNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + iNumber.longLongValue);
	
	result = [checkNumber addNumber:uiNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + uiNumber.longLongValue);
	
	result = [checkNumber addNumber:lNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + lNumber.longLongValue);
	
	result = [checkNumber addNumber:ulNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ulNumber.longLongValue);
	
	result = [checkNumber addNumber:llNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + llNumber.longLongValue);
	
	result = [checkNumber addNumber:ullNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ullNumber.longLongValue);
}


- (void)testTypeChecks_unsignedInt {
	NSMockNumber *boolNONumber = [NSMockNumber numberWithBool:NO];
	NSMockNumber *boolYESNumber = [NSMockNumber numberWithBool:YES];
	
	NSMockNumber *cNumber = [NSMockNumber numberWithChar:-11];
	NSMockNumber *ucNumber = [NSMockNumber numberWithUnsignedChar:10];
	
	NSMockNumber *sNumber = [NSMockNumber numberWithShort:-111];
	NSMockNumber *usNumber = [NSMockNumber numberWithUnsignedShort:110];
	
	NSMockNumber *iNumber = [NSMockNumber numberWithInt:-1111];
	NSMockNumber *uiNumber = [NSMockNumber numberWithUnsignedInt:1110];
	
	NSMockNumber *lNumber = [NSMockNumber numberWithLong:-11111];
	NSMockNumber *ulNumber = [NSMockNumber numberWithUnsignedLong:11110];
	
	NSMockNumber *llNumber = [NSMockNumber numberWithLongLong:-111111];
	NSMockNumber *ullNumber = [NSMockNumber numberWithUnsignedLongLong:111110];
	
	NSNumber *checkNumber = uiNumber;
	
	NSNumber *result = [checkNumber addNumber:boolNONumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolNONumber.longLongValue);
	
	result = [checkNumber addNumber:boolYESNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolYESNumber.longLongValue);
	
	result = [checkNumber addNumber:cNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + cNumber.longLongValue);
	
	result = [checkNumber addNumber:ucNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ucNumber.longLongValue);
	
	result = [checkNumber addNumber:sNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + sNumber.longLongValue);
	
	result = [checkNumber addNumber:usNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + usNumber.longLongValue);
	
	result = [checkNumber addNumber:iNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + iNumber.longLongValue);
	
	result = [checkNumber addNumber:uiNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + uiNumber.longLongValue);
	
	result = [checkNumber addNumber:lNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + lNumber.longLongValue);
	
	result = [checkNumber addNumber:ulNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ulNumber.longLongValue);
	
	result = [checkNumber addNumber:llNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + llNumber.longLongValue);
	
	result = [checkNumber addNumber:ullNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ullNumber.longLongValue);
}


- (void)testTypeChecks_long {
	NSMockNumber *boolNONumber = [NSMockNumber numberWithBool:NO];
	NSMockNumber *boolYESNumber = [NSMockNumber numberWithBool:YES];
	
	NSMockNumber *cNumber = [NSMockNumber numberWithChar:-11];
	NSMockNumber *ucNumber = [NSMockNumber numberWithUnsignedChar:10];
	
	NSMockNumber *sNumber = [NSMockNumber numberWithShort:-111];
	NSMockNumber *usNumber = [NSMockNumber numberWithUnsignedShort:110];
	
	NSMockNumber *iNumber = [NSMockNumber numberWithInt:-1111];
	NSMockNumber *uiNumber = [NSMockNumber numberWithUnsignedInt:1110];
	
	NSMockNumber *lNumber = [NSMockNumber numberWithLong:-11111];
	NSMockNumber *ulNumber = [NSMockNumber numberWithUnsignedLong:11110];
	
	NSMockNumber *llNumber = [NSMockNumber numberWithLongLong:-111111];
	NSMockNumber *ullNumber = [NSMockNumber numberWithUnsignedLongLong:111110];
	
	NSNumber *checkNumber = lNumber;
	
	NSNumber *result = [checkNumber addNumber:boolNONumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolNONumber.longLongValue);
	
	result = [checkNumber addNumber:boolYESNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolYESNumber.longLongValue);
	
	result = [checkNumber addNumber:cNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + cNumber.longLongValue);
	
	result = [checkNumber addNumber:ucNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ucNumber.longLongValue);
	
	result = [checkNumber addNumber:sNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + sNumber.longLongValue);
	
	result = [checkNumber addNumber:usNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + usNumber.longLongValue);
	
	result = [checkNumber addNumber:iNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + iNumber.longLongValue);
	
	result = [checkNumber addNumber:uiNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + uiNumber.longLongValue);
	
	result = [checkNumber addNumber:lNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + lNumber.longLongValue);
	
	result = [checkNumber addNumber:ulNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ulNumber.longLongValue);
	
	result = [checkNumber addNumber:llNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + llNumber.longLongValue);
	
	result = [checkNumber addNumber:ullNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ullNumber.longLongValue);
}


- (void)testTypeChecks_unsignedLong {
	NSMockNumber *boolNONumber = [NSMockNumber numberWithBool:NO];
	NSMockNumber *boolYESNumber = [NSMockNumber numberWithBool:YES];
	
	NSMockNumber *cNumber = [NSMockNumber numberWithChar:-11];
	NSMockNumber *ucNumber = [NSMockNumber numberWithUnsignedChar:10];
	
	NSMockNumber *sNumber = [NSMockNumber numberWithShort:-111];
	NSMockNumber *usNumber = [NSMockNumber numberWithUnsignedShort:110];
	
	NSMockNumber *iNumber = [NSMockNumber numberWithInt:-1111];
	NSMockNumber *uiNumber = [NSMockNumber numberWithUnsignedInt:1110];
	
	NSMockNumber *lNumber = [NSMockNumber numberWithLong:-11111];
	NSMockNumber *ulNumber = [NSMockNumber numberWithUnsignedLong:11110];
	
	NSMockNumber *llNumber = [NSMockNumber numberWithLongLong:-111111];
	NSMockNumber *ullNumber = [NSMockNumber numberWithUnsignedLongLong:111110];
	
	NSNumber *checkNumber = ulNumber;
	
	NSNumber *result = [checkNumber addNumber:boolNONumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolNONumber.longLongValue);
	
	result = [checkNumber addNumber:boolYESNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolYESNumber.longLongValue);
	
	result = [checkNumber addNumber:cNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + cNumber.longLongValue);
	
	result = [checkNumber addNumber:ucNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ucNumber.longLongValue);
	
	result = [checkNumber addNumber:sNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + sNumber.longLongValue);
	
	result = [checkNumber addNumber:usNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + usNumber.longLongValue);
	
	result = [checkNumber addNumber:iNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + iNumber.longLongValue);
	
	result = [checkNumber addNumber:uiNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + uiNumber.longLongValue);
	
	result = [checkNumber addNumber:lNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + lNumber.longLongValue);
	
	result = [checkNumber addNumber:ulNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ulNumber.longLongValue);
	
	result = [checkNumber addNumber:llNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + llNumber.longLongValue);
	
	result = [checkNumber addNumber:ullNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ullNumber.longLongValue);
}


- (void)testTypeChecks_longLong {
	NSMockNumber *boolNONumber = [NSMockNumber numberWithBool:NO];
	NSMockNumber *boolYESNumber = [NSMockNumber numberWithBool:YES];
	
	NSMockNumber *cNumber = [NSMockNumber numberWithChar:-11];
	NSMockNumber *ucNumber = [NSMockNumber numberWithUnsignedChar:10];
	
	NSMockNumber *sNumber = [NSMockNumber numberWithShort:-111];
	NSMockNumber *usNumber = [NSMockNumber numberWithUnsignedShort:110];
	
	NSMockNumber *iNumber = [NSMockNumber numberWithInt:-1111];
	NSMockNumber *uiNumber = [NSMockNumber numberWithUnsignedInt:1110];
	
	NSMockNumber *lNumber = [NSMockNumber numberWithLong:-11111];
	NSMockNumber *ulNumber = [NSMockNumber numberWithUnsignedLong:11110];
	
	NSMockNumber *llNumber = [NSMockNumber numberWithLongLong:-111111];
	NSMockNumber *ullNumber = [NSMockNumber numberWithUnsignedLongLong:111110];
	
	NSNumber *checkNumber = llNumber;
	
	NSNumber *result = [checkNumber addNumber:boolNONumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolNONumber.longLongValue);
	
	result = [checkNumber addNumber:boolYESNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolYESNumber.longLongValue);
	
	result = [checkNumber addNumber:cNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + cNumber.longLongValue);
	
	result = [checkNumber addNumber:ucNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ucNumber.longLongValue);
	
	result = [checkNumber addNumber:sNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + sNumber.longLongValue);
	
	result = [checkNumber addNumber:usNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + usNumber.longLongValue);
	
	result = [checkNumber addNumber:iNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + iNumber.longLongValue);
	
	result = [checkNumber addNumber:uiNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + uiNumber.longLongValue);
	
	result = [checkNumber addNumber:lNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + lNumber.longLongValue);
	
	result = [checkNumber addNumber:ulNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ulNumber.longLongValue);
	
	result = [checkNumber addNumber:llNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + llNumber.longLongValue);
	
	result = [checkNumber addNumber:ullNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ullNumber.longLongValue);
}


- (void)testTypeChecks_unsignedLongLong {
	NSMockNumber *boolNONumber = [NSMockNumber numberWithBool:NO];
	NSMockNumber *boolYESNumber = [NSMockNumber numberWithBool:YES];
	
	NSMockNumber *cNumber = [NSMockNumber numberWithChar:-11];
	NSMockNumber *ucNumber = [NSMockNumber numberWithUnsignedChar:10];
	
	NSMockNumber *sNumber = [NSMockNumber numberWithShort:-111];
	NSMockNumber *usNumber = [NSMockNumber numberWithUnsignedShort:110];
	
	NSMockNumber *iNumber = [NSMockNumber numberWithInt:-1111];
	NSMockNumber *uiNumber = [NSMockNumber numberWithUnsignedInt:1110];
	
	NSMockNumber *lNumber = [NSMockNumber numberWithLong:-11111];
	NSMockNumber *ulNumber = [NSMockNumber numberWithUnsignedLong:11110];
	
	NSMockNumber *llNumber = [NSMockNumber numberWithLongLong:-111111];
	NSMockNumber *ullNumber = [NSMockNumber numberWithUnsignedLongLong:111110];
	
	NSNumber *checkNumber = ullNumber;
	
	NSNumber *result = [checkNumber addNumber:boolNONumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolNONumber.longLongValue);
	
	result = [checkNumber addNumber:boolYESNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + boolYESNumber.longLongValue);
	
	result = [checkNumber addNumber:cNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + cNumber.longLongValue);
	
	result = [checkNumber addNumber:ucNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ucNumber.longLongValue);
	
	result = [checkNumber addNumber:sNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + sNumber.longLongValue);
	
	result = [checkNumber addNumber:usNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + usNumber.longLongValue);
	
	result = [checkNumber addNumber:iNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + iNumber.longLongValue);
	
	result = [checkNumber addNumber:uiNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + uiNumber.longLongValue);
	
	result = [checkNumber addNumber:lNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + lNumber.longLongValue);
	
	result = [checkNumber addNumber:ulNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ulNumber.longLongValue);
	
	result = [checkNumber addNumber:llNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + llNumber.longLongValue);
	
	result = [checkNumber addNumber:ullNumber];
	XCTAssertEqual(result.longLongValue, checkNumber.longLongValue + ullNumber.longLongValue);
}

@end
