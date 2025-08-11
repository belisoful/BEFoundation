//
//  Plugin_Unit_Tests.m
//  Plugin Unit Tests
//
//  Created by ~ ~ on 3/14/24.
//

#import <XCTest/XCTest.h>
#import <BEFoundation/NSString+BExtension.h>

@interface NSStringBExtensionTests : XCTestCase

@end

@implementation NSStringBExtensionTests

- (void)setUp {
}

- (void)tearDown {
}
#pragma mark - NSString
#pragma mark stringValue Correctness Test

- (void)testStringValue {
	
	NSString *string = @"_@unique_string#$%***";
	
	XCTAssertEqual(string, string.stringValue);
}


#pragma mark Numeric Check Tests

- (void)testIsDigits {
#define testMethod isDigits
	
	XCTAssertTrue(@"0".testMethod);
	XCTAssertFalse(@"+0".testMethod);
	XCTAssertTrue(@"000".testMethod);
	XCTAssertFalse(@"-0".testMethod);
	
	XCTAssertTrue(@"1".testMethod);
	XCTAssertFalse(@"-1".testMethod);
	XCTAssertTrue(@"001".testMethod);
	XCTAssertFalse(@"-001".testMethod);
	XCTAssertTrue(@"1234567890".testMethod);
	XCTAssertFalse(@"-1234567890".testMethod);
	
	XCTAssertTrue(@"9294967295".testMethod);
	XCTAssertFalse(@"-9294967295".testMethod);
	
	// largest 32 bit int values
	XCTAssertTrue(@"2147483647".testMethod);
	XCTAssertFalse(@"-2147483648".testMethod);
	XCTAssertTrue(@"4294967295".testMethod);
	
	// largest 32 bit int values, 1 larger
	XCTAssertTrue(@"2147483648".testMethod);
	XCTAssertFalse(@"-2147483649".testMethod);
	XCTAssertTrue(@"4294967296".testMethod);
	
	// largest 64 bit long long values
	XCTAssertTrue(@"9223372036854775807".testMethod);
	XCTAssertFalse(@"-9223372036854775808".testMethod);
	XCTAssertTrue(@"18446744073709551615".testMethod);
	
	// largest 64 bit long long, 1 larger
	XCTAssertTrue(@"9223372036854775808".testMethod);
	XCTAssertFalse(@"-9223372036854775809".testMethod);
	XCTAssertTrue(@"18446744073709551616".testMethod);
	
	
	XCTAssertFalse(@"".testMethod);
	XCTAssertFalse(@"+".testMethod);
	XCTAssertFalse(@"-".testMethod);
	XCTAssertFalse(@"1a".testMethod);
	XCTAssertFalse(@"a1".testMethod);
	XCTAssertFalse(@"-123456-7890".testMethod);
	XCTAssertFalse(@"1234567890-".testMethod);
	XCTAssertFalse(@"12,345,678".testMethod);
	XCTAssertFalse(@"369.5".testMethod);
	XCTAssertFalse(@"+1.618099e-10".testMethod);
	XCTAssertFalse(@"+1.618099E+10".testMethod);
	
	//max single precision exponent
	XCTAssertFalse(@"+1.618099e-126".testMethod);
	XCTAssertFalse(@"+1.618099E+127".testMethod);
	
	// max single precision exponent, one over
	XCTAssertFalse(@"+1.618099e-127".testMethod);
	XCTAssertFalse(@"+1.618099E+128".testMethod);
	
	// Double max exponent
	XCTAssertFalse(@"+1.618099e-1022".testMethod);
	XCTAssertFalse(@"+1.618099E+1023".testMethod);
	
	//  double max exponent plus 1 larger
	XCTAssertFalse(@"+1.618099e-1023".testMethod);
	XCTAssertFalse(@"+1.618099E+1024".testMethod);
	
#undef testMethod
}


// 32 bit
- (void)testIsIntValue {
#define testMethod isIntValue
	XCTAssertTrue(@"0".testMethod);
	XCTAssertTrue(@"+0".testMethod);
	XCTAssertTrue(@"000".testMethod);
	XCTAssertTrue(@"-0".testMethod);
	
	XCTAssertTrue(@"1".testMethod);
	XCTAssertTrue(@"-1".testMethod);
	XCTAssertTrue(@"001".testMethod);
	XCTAssertTrue(@"-001".testMethod);
	XCTAssertTrue(@"1234567890".testMethod);
	XCTAssertTrue(@"-1234567890".testMethod);
	
	XCTAssertTrue(@"9294967295".testMethod);
	XCTAssertTrue(@"-9294967295".testMethod);
	
	// largest 32 bit int values
	XCTAssertTrue(@"2147483647".testMethod);
	XCTAssertTrue(@"-2147483648".testMethod);
	XCTAssertTrue(@"4294967295".testMethod);
	
	// largest 32 bit int values, 1 larger
	XCTAssertTrue(@"2147483648".testMethod);
	XCTAssertTrue(@"-2147483649".testMethod);
	XCTAssertTrue(@"4294967296".testMethod);
	
	// largest 64 bit long long values
	XCTAssertTrue(@"9223372036854775807".testMethod);
	XCTAssertTrue(@"-9223372036854775808".testMethod);
	XCTAssertTrue(@"18446744073709551615".testMethod);
	
	// largest 64 bit long long, 1 larger
	XCTAssertTrue(@"9223372036854775808".testMethod);
	XCTAssertTrue(@"-9223372036854775809".testMethod);
	XCTAssertTrue(@"18446744073709551616".testMethod);
	
	
	XCTAssertFalse(@"".testMethod);
	XCTAssertFalse(@"+".testMethod);
	XCTAssertFalse(@"-".testMethod);
	XCTAssertFalse(@"1a".testMethod);
	XCTAssertFalse(@"a1".testMethod);
	XCTAssertFalse(@"-123456-7890".testMethod);
	XCTAssertFalse(@"1234567890-".testMethod);
	XCTAssertFalse(@"12,345,678".testMethod);
	XCTAssertFalse(@"369.5".testMethod);
	XCTAssertFalse(@"+1.618099e-10".testMethod);
	XCTAssertFalse(@"+1.618099E+10".testMethod);
	
	//max single precision exponent
	XCTAssertFalse(@"+1.618099e-126".testMethod);
	XCTAssertFalse(@"+1.618099E+127".testMethod);
	
	// max single precision exponent, one over
	XCTAssertFalse(@"+1.618099e-127".testMethod);
	XCTAssertFalse(@"+1.618099E+128".testMethod);
	
	// Double max exponent
	XCTAssertFalse(@"+1.618099e-1022".testMethod);
	XCTAssertFalse(@"+1.618099E+1023".testMethod);
	
	//  double max exponent plus 1 larger
	XCTAssertFalse(@"+1.618099e-1023".testMethod);
	XCTAssertFalse(@"+1.618099E+1024".testMethod);
#undef testMethod
}

// 32 or 64 bit
- (void)testIsIntegerValue {
#define testMethod isIntegerValue
	
	XCTAssertTrue(@"0".testMethod);
	XCTAssertTrue(@"+0".testMethod);
	XCTAssertTrue(@"000".testMethod);
	XCTAssertTrue(@"-0".testMethod);
	
	XCTAssertTrue(@"1".testMethod);
	XCTAssertTrue(@"-1".testMethod);
	XCTAssertTrue(@"001".testMethod);
	XCTAssertTrue(@"-001".testMethod);
	XCTAssertTrue(@"1234567890".testMethod);
	XCTAssertTrue(@"-1234567890".testMethod);
	
	XCTAssertTrue(@"9294967295".testMethod);
	XCTAssertTrue(@"-9294967295".testMethod);
	
	// largest 32 bit int values
	XCTAssertTrue(@"2147483647".testMethod);
	XCTAssertTrue(@"-2147483648".testMethod);
	XCTAssertTrue(@"4294967295".testMethod);
	
	// largest 32 bit int values, 1 larger
	XCTAssertTrue(@"2147483648".testMethod);
	XCTAssertTrue(@"-2147483649".testMethod);
	XCTAssertTrue(@"4294967296".testMethod);
	
	// largest 64 bit long long values
	XCTAssertTrue(@"9223372036854775807".testMethod);
	XCTAssertTrue(@"-9223372036854775808".testMethod);
	XCTAssertTrue(@"18446744073709551615".testMethod);
	
	// largest 64 bit long long, 1 larger
	XCTAssertTrue(@"9223372036854775808".testMethod);
	XCTAssertTrue(@"-9223372036854775809".testMethod);
	XCTAssertTrue(@"18446744073709551616".testMethod);
	
	
	XCTAssertFalse(@"".testMethod);
	XCTAssertFalse(@"+".testMethod);
	XCTAssertFalse(@"-".testMethod);
	XCTAssertFalse(@"1a".testMethod);
	XCTAssertFalse(@"a1".testMethod);
	XCTAssertFalse(@"-123456-7890".testMethod);
	XCTAssertFalse(@"1234567890-".testMethod);
	XCTAssertFalse(@"12,345,678".testMethod);
	XCTAssertFalse(@"369.5".testMethod);
	XCTAssertFalse(@"+1.618099e-10".testMethod);
	XCTAssertFalse(@"+1.618099E+10".testMethod);
	
	//max single precision exponent
	XCTAssertFalse(@"+1.618099e-126".testMethod);
	XCTAssertFalse(@"+1.618099E+127".testMethod);
	
	// max single precision exponent, one over
	XCTAssertFalse(@"+1.618099e-127".testMethod);
	XCTAssertFalse(@"+1.618099E+128".testMethod);
	
	// Double max exponent
	XCTAssertFalse(@"+1.618099e-1022".testMethod);
	XCTAssertFalse(@"+1.618099E+1023".testMethod);
	
	//  double max exponent plus 1 larger
	XCTAssertFalse(@"+1.618099e-1023".testMethod);
	XCTAssertFalse(@"+1.618099E+1024".testMethod);
#undef testMethod
}


// 64 bit
- (void)testIsLongLongValue {
#define testMethod isLongLongValue
	XCTAssertTrue(@"0".testMethod);
	XCTAssertTrue(@"+0".testMethod);
	XCTAssertTrue(@"000".testMethod);
	XCTAssertTrue(@"-0".testMethod);
	
	XCTAssertTrue(@"1".testMethod);
	XCTAssertTrue(@"-1".testMethod);
	XCTAssertTrue(@"001".testMethod);
	XCTAssertTrue(@"-001".testMethod);
	XCTAssertTrue(@"1234567890".testMethod);
	XCTAssertTrue(@"-1234567890".testMethod);
	
	XCTAssertTrue(@"9294967295".testMethod);
	XCTAssertTrue(@"-9294967295".testMethod);
	
	// largest 32 bit int values
	XCTAssertTrue(@"2147483647".testMethod);
	XCTAssertTrue(@"-2147483648".testMethod);
	XCTAssertTrue(@"4294967295".testMethod);
	
	// largest 32 bit int values, 1 larger
	XCTAssertTrue(@"2147483648".testMethod);
	XCTAssertTrue(@"-2147483649".testMethod);
	XCTAssertTrue(@"4294967296".testMethod);
	
	// largest 64 bit long long values
	XCTAssertTrue(@"9223372036854775807".testMethod);
	XCTAssertTrue(@"-9223372036854775808".testMethod);
	XCTAssertTrue(@"18446744073709551615".testMethod);
	
	// largest 64 bit long long, 1 larger
	XCTAssertTrue(@"9223372036854775808".testMethod);
	XCTAssertTrue(@"-9223372036854775809".testMethod);
	XCTAssertTrue(@"18446744073709551616".testMethod);
	
	
	XCTAssertFalse(@"".testMethod);
	XCTAssertFalse(@"+".testMethod);
	XCTAssertFalse(@"-".testMethod);
	XCTAssertFalse(@"1a".testMethod);
	XCTAssertFalse(@"a1".testMethod);
	XCTAssertFalse(@"-123456-7890".testMethod);
	XCTAssertFalse(@"1234567890-".testMethod);
	XCTAssertFalse(@"12,345,678".testMethod);
	XCTAssertFalse(@"369.5".testMethod);
	XCTAssertFalse(@"+1.618099e-10".testMethod);
	XCTAssertFalse(@"+1.618099E+10".testMethod);
	
	//max single precision exponent
	XCTAssertFalse(@"+1.618099e-126".testMethod);
	XCTAssertFalse(@"+1.618099E+127".testMethod);
	
	// max single precision exponent, one over
	XCTAssertFalse(@"+1.618099e-127".testMethod);
	XCTAssertFalse(@"+1.618099E+128".testMethod);
	
	// Double max exponent
	XCTAssertFalse(@"+1.618099e-1022".testMethod);
	XCTAssertFalse(@"+1.618099E+1023".testMethod);
	
	//  double max exponent plus 1 larger
	XCTAssertFalse(@"+1.618099e-1023".testMethod);
	XCTAssertFalse(@"+1.618099E+1024".testMethod);
#undef testMethod
}


// unsigned 64 bit
- (void)testIsUnsignedLongLongValue {
#define testMethod isUnsignedLongLongValue
	XCTAssertTrue(@"0".testMethod);
	XCTAssertTrue(@"+0".testMethod);
	XCTAssertTrue(@"000".testMethod);
	XCTAssertFalse(@"-0".testMethod);
	
	XCTAssertTrue(@"1".testMethod);
	XCTAssertFalse(@"-1".testMethod);
	XCTAssertTrue(@"001".testMethod);
	XCTAssertFalse(@"-001".testMethod);
	XCTAssertTrue(@"1234567890".testMethod);
	XCTAssertFalse(@"-1234567890".testMethod);
	
	XCTAssertTrue(@"9294967295".testMethod);
	XCTAssertFalse(@"-9294967295".testMethod);
	
	// largest 32 bit int values
	XCTAssertTrue(@"2147483647".testMethod);
	XCTAssertFalse(@"-2147483648".testMethod);
	XCTAssertTrue(@"4294967295".testMethod);
	
	// largest 32 bit int values, 1 larger
	XCTAssertTrue(@"2147483648".testMethod);
	XCTAssertFalse(@"-2147483649".testMethod);
	XCTAssertTrue(@"4294967296".testMethod);
	
	// largest 64 bit long long values
	XCTAssertTrue(@"9223372036854775807".testMethod);
	XCTAssertFalse(@"-9223372036854775808".testMethod);
	XCTAssertTrue(@"18446744073709551615".testMethod);
	
	// largest 64 bit long long, 1 larger
	XCTAssertTrue(@"9223372036854775808".testMethod);
	XCTAssertFalse(@"-9223372036854775809".testMethod);
	XCTAssertTrue(@"18446744073709551616".testMethod);
	
	
	XCTAssertFalse(@"".testMethod);
	XCTAssertFalse(@"+".testMethod);
	XCTAssertFalse(@"-".testMethod);
	XCTAssertFalse(@"1a".testMethod);
	XCTAssertFalse(@"a1".testMethod);
	XCTAssertFalse(@"-123456-7890".testMethod);
	XCTAssertFalse(@"1234567890-".testMethod);
	XCTAssertFalse(@"12,345,678".testMethod);
	XCTAssertFalse(@"369.5".testMethod);
	XCTAssertFalse(@"+1.618099e-10".testMethod);
	XCTAssertFalse(@"+1.618099E+10".testMethod);
	
	//max single precision exponent
	XCTAssertFalse(@"+1.618099e-126".testMethod);
	XCTAssertFalse(@"+1.618099E+127".testMethod);
	
	// max single precision exponent, one over
	XCTAssertFalse(@"+1.618099e-127".testMethod);
	XCTAssertFalse(@"+1.618099E+128".testMethod);
	
	// Double max exponent
	XCTAssertFalse(@"+1.618099e-1022".testMethod);
	XCTAssertFalse(@"+1.618099E+1023".testMethod);
	
	//  double max exponent plus 1 larger
	XCTAssertFalse(@"+1.618099e-1023".testMethod);
	XCTAssertFalse(@"+1.618099E+1024".testMethod);
#undef testMethod
}



// 32 bit float
- (void)testIsFloatValue {
#define testMethod isFloatValue
	XCTAssertTrue(@"0".testMethod);
	XCTAssertTrue(@"+0".testMethod);
	XCTAssertTrue(@"000".testMethod);
	XCTAssertTrue(@"-0".testMethod);
	
	XCTAssertTrue(@"1".testMethod);
	XCTAssertTrue(@"-1".testMethod);
	XCTAssertTrue(@"001".testMethod);
	XCTAssertTrue(@"-001".testMethod);
	XCTAssertTrue(@"1234567890".testMethod);
	XCTAssertTrue(@"-1234567890".testMethod);
	
	XCTAssertTrue(@"9294967295".testMethod);
	XCTAssertTrue(@"-9294967295".testMethod);
	
	// largest 32 bit int values
	XCTAssertTrue(@"2147483647".testMethod);
	XCTAssertTrue(@"-2147483648".testMethod);
	XCTAssertTrue(@"4294967295".testMethod);
	
	// largest 32 bit int values, 1 larger
	XCTAssertTrue(@"2147483648".testMethod);
	XCTAssertTrue(@"-2147483649".testMethod);
	XCTAssertTrue(@"4294967296".testMethod);
	
	// largest 64 bit long long values
	XCTAssertTrue(@"9223372036854775807".testMethod);
	XCTAssertTrue(@"-9223372036854775808".testMethod);
	XCTAssertTrue(@"18446744073709551615".testMethod);
	
	// largest 64 bit long long, 1 larger
	XCTAssertTrue(@"9223372036854775808".testMethod);
	XCTAssertTrue(@"-9223372036854775809".testMethod);
	XCTAssertTrue(@"18446744073709551616".testMethod);
	
	
	XCTAssertFalse(@"".testMethod);
	XCTAssertFalse(@"+".testMethod);
	XCTAssertFalse(@"-".testMethod);
	XCTAssertFalse(@"1a".testMethod);
	XCTAssertFalse(@"a1".testMethod);
	XCTAssertFalse(@"-123456-7890".testMethod);
	XCTAssertFalse(@"1234567890-".testMethod);
	XCTAssertFalse(@"12,345,678".testMethod);
	XCTAssertTrue(@"369.5".testMethod);
	XCTAssertTrue(@"+1.618099e-10".testMethod);
	XCTAssertTrue(@"+1.618099E+10".testMethod);
	
	//max single precision exponent
	XCTAssertTrue(@"+1.618099e-126".testMethod);
	XCTAssertTrue(@"+1.618099E+127".testMethod);
	
	// max single precision exponent, one over
	XCTAssertTrue(@"+1.618099e-127".testMethod);
	XCTAssertTrue(@"+1.618099E+128".testMethod);
	
	// Double max exponent
	XCTAssertTrue(@"+1.618099e-1022".testMethod);
	XCTAssertTrue(@"+1.618099E+1023".testMethod);
	
	//  double max exponent plus 1 larger
	XCTAssertTrue(@"+1.618099e-1023".testMethod);
	XCTAssertTrue(@"+1.618099E+1024".testMethod);
#undef testMethod
}


// 64 bit float
- (void)testIsDoubleValue {
#define testMethod isDoubleValue
	XCTAssertTrue(@"0".testMethod);
	XCTAssertTrue(@"+0".testMethod);
	XCTAssertTrue(@"000".testMethod);
	XCTAssertTrue(@"-0".testMethod);
	
	XCTAssertTrue(@"1".testMethod);
	XCTAssertTrue(@"-1".testMethod);
	XCTAssertTrue(@"001".testMethod);
	XCTAssertTrue(@"-001".testMethod);
	XCTAssertTrue(@"1234567890".testMethod);
	XCTAssertTrue(@"-1234567890".testMethod);
	
	XCTAssertTrue(@"9294967295".testMethod);
	XCTAssertTrue(@"-9294967295".testMethod);
	
	// largest 32 bit int values
	XCTAssertTrue(@"2147483647".testMethod);
	XCTAssertTrue(@"-2147483648".testMethod);
	XCTAssertTrue(@"4294967295".testMethod);
	
	// largest 32 bit int values, 1 larger
	XCTAssertTrue(@"2147483648".testMethod);
	XCTAssertTrue(@"-2147483649".testMethod);
	XCTAssertTrue(@"4294967296".testMethod);
	
	// largest 64 bit long long values
	XCTAssertTrue(@"9223372036854775807".testMethod);
	XCTAssertTrue(@"-9223372036854775808".testMethod);
	XCTAssertTrue(@"18446744073709551615".testMethod);
	
	// largest 64 bit long long, 1 larger
	XCTAssertTrue(@"9223372036854775808".testMethod);
	XCTAssertTrue(@"-9223372036854775809".testMethod);
	XCTAssertTrue(@"18446744073709551616".testMethod);
	
	
	XCTAssertFalse(@"".testMethod);
	XCTAssertFalse(@"+".testMethod);
	XCTAssertFalse(@"-".testMethod);
	XCTAssertFalse(@"1a".testMethod);
	XCTAssertFalse(@"a1".testMethod);
	XCTAssertFalse(@"-123456-7890".testMethod);
	XCTAssertFalse(@"1234567890-".testMethod);
	XCTAssertFalse(@"12,345,678".testMethod);
	XCTAssertTrue(@"369.5".testMethod);
	XCTAssertTrue(@"+1.618099e-10".testMethod);
	XCTAssertTrue(@"+1.618099E+10".testMethod);
	
	//max single precision exponent
	XCTAssertTrue(@"+1.618099e-126".testMethod);
	XCTAssertTrue(@"+1.618099E+127".testMethod);
	
	// max single precision exponent, one over
	XCTAssertTrue(@"+1.618099e-127".testMethod);
	XCTAssertTrue(@"+1.618099E+128".testMethod);
	
	// Double max exponent
	XCTAssertTrue(@"+1.618099e-1022".testMethod);
	XCTAssertTrue(@"+1.618099E+1023".testMethod);
	
	//  double max exponent plus 1 larger
	XCTAssertTrue(@"+1.618099e-1023".testMethod);
	XCTAssertTrue(@"+1.618099E+1024".testMethod);
#undef testMethod
}

#pragma mark System Date/Time Value

- (void)testIsSystemDateTimeValue
{
	NSString *input = @"10/28/2025, 2:30 PM";
	XCTAssertTrue(input.isSystemDateTimeValue);
	
	input = @"10/28/2025";
	XCTAssertFalse(input.isSystemDateTimeValue);
	
	input = @"2:30PM";
	XCTAssertFalse(input.isSystemDateTimeValue);
	
	input = @"";
	XCTAssertFalse(input.isSystemDateTimeValue);
	
}

- (void)testSystemDateTimeValue
{
	NSDateFormatter *formatter = NSDateFormatter.new;
	
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	
	NSString *input = @"11/26/2025, 2:30 PM";
	XCTAssertNotNil(input.systemDateTimeValue);
	XCTAssertEqualObjects(input.systemDateTimeValue, [formatter dateFromString:@"11/26/2025, 2:30 PM"]);
	
	
	input = @"10/28/2025";
	XCTAssertNil(input.systemDateTimeValue);
	
	input = @"2:30PM";
	XCTAssertNil(input.systemDateTimeValue);
	
	input = @"";
	XCTAssertNil(input.systemDateTimeValue);
	
}

- (void)testIsSystemDateValue
{
	NSString *input = @"10/28/2025";
	XCTAssertTrue(input.isSystemDateValue);
	
	input = @"10/28/2025, 2:30 PM";
	XCTAssertFalse(input.isSystemDateValue);
	
	input = @"2:30PM";
	XCTAssertFalse(input.isSystemDateValue);
	
	input = @"";
	XCTAssertFalse(input.isSystemDateValue);
}

- (void)testSystemDateValue
{
	NSDateFormatter *formatter = NSDateFormatter.new;
	
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	
	NSString *input;
	
	input = @"10/28/2025";
	XCTAssertNotNil(input.systemDateValue);
	XCTAssertEqualObjects(input.systemDateValue, [formatter dateFromString:@"10/28/2025"]);
	
	input = @"11/26/2025, 2:30 PM EST";
	XCTAssertNil(input.systemDateValue);
	
	input = @"2:30PM";
	XCTAssertNil(input.systemDateValue);
	
	input = @"";
	XCTAssertNil(input.systemDateValue);
}

- (void)testIsSystemTimeValue
{
	NSString *input = @"2:30PM";
	XCTAssertTrue(input.isSystemTimeValue);
	
	input = @"10/28/2025, 2:30 PM";
	XCTAssertFalse(input.isSystemTimeValue);
	
	input = @"10/28/2025";
	XCTAssertFalse(input.isSystemTimeValue);
	
	input = @"";
	XCTAssertFalse(input.isSystemTimeValue);
}

- (void)testSystemTimeValue
{
	NSDateFormatter *formatter = NSDateFormatter.new;
	
	[formatter setDateStyle:NSDateFormatterNoStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	
	NSString *input;
	
	input = @"2:30PM";
	XCTAssertNotNil(input.systemTimeValue);
	XCTAssertEqualObjects(input.systemTimeValue, [formatter dateFromString:@"2:30pm"]);
	
	input = @"11/26/2025, 2:30 PM EST";
	XCTAssertNil(input.systemTimeValue);
	
	input = @"10/28/2025";
	XCTAssertNil(input.systemTimeValue);
	
	input = @"";
	XCTAssertNil(input.systemTimeValue);
}

#pragma mark date/time with style

- (void)testDateWithStyle
{
	NSDateFormatter *formatter = NSDateFormatter.new;
	
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	
	NSString *aString;
	
	aString = @"";
	[formatter setDateStyle:NSDateFormatterNoStyle];
	
	XCTAssertNotNil([aString dateWithStyle:NSDateFormatterNoStyle]);
	XCTAssertEqualObjects([aString dateWithStyle:NSDateFormatterNoStyle], [formatter dateFromString:@""]);
	XCTAssertNil([aString dateWithStyle:NSDateFormatterShortStyle]);
	XCTAssertNil([aString dateWithStyle:NSDateFormatterFullStyle]);
	
	
	aString = @"12/30/2025";
	[formatter setDateStyle:NSDateFormatterShortStyle];
	
	XCTAssertNil([aString dateWithStyle:NSDateFormatterNoStyle]);
	XCTAssertNotNil([aString dateWithStyle:NSDateFormatterShortStyle]);
	XCTAssertEqualObjects([aString dateWithStyle:NSDateFormatterShortStyle], [formatter dateFromString:@"12/30/2025"]);
	XCTAssertNil([aString dateWithStyle:NSDateFormatterFullStyle]);
	
	aString = @"Tuesday, December 30, 2025";
	[formatter setDateStyle:NSDateFormatterShortStyle];
	
	XCTAssertNil([aString dateWithStyle:NSDateFormatterNoStyle]);
	XCTAssertNil([aString dateWithStyle:NSDateFormatterShortStyle]);
	XCTAssertNotNil([aString dateWithStyle:NSDateFormatterFullStyle]);
	XCTAssertEqualObjects([aString dateWithStyle:NSDateFormatterFullStyle], [formatter dateFromString:@"12/30/2025"]);
	
	aString = @"Not a Date";
	XCTAssertNil([aString dateWithStyle:NSDateFormatterNoStyle]);
	XCTAssertNil([aString dateWithStyle:NSDateFormatterShortStyle]);
	XCTAssertNil([aString dateWithStyle:NSDateFormatterFullStyle]);
}

- (void)testTimeWithStyle
{
	NSDateFormatter *formatter = NSDateFormatter.new;
	
	[formatter setDateStyle:NSDateFormatterNoStyle];
	
	NSString *aString;
	
	aString = @"";
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	
	XCTAssertNotNil([aString timeWithStyle:NSDateFormatterNoStyle]);
	XCTAssertEqualObjects([aString timeWithStyle:NSDateFormatterNoStyle], [formatter dateFromString:@""]);
	XCTAssertNil([aString timeWithStyle:NSDateFormatterShortStyle]);
	XCTAssertNil([aString timeWithStyle:NSDateFormatterFullStyle]);
	
	
	aString = @"3:40 PM";
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	
	XCTAssertNil([aString timeWithStyle:NSDateFormatterNoStyle]);
	XCTAssertNotNil([aString timeWithStyle:NSDateFormatterShortStyle]);
	XCTAssertEqualObjects([aString timeWithStyle:NSDateFormatterShortStyle], [formatter dateFromString:@"3:40 PM"]);
	XCTAssertNil([aString timeWithStyle:NSDateFormatterFullStyle]);
	
	aString = @"11:45:32 PM Pacific Daylight Time";
	[formatter setTimeStyle:NSDateFormatterFullStyle];
	
	XCTAssertNil([aString timeWithStyle:NSDateFormatterNoStyle]);
	XCTAssertNil([aString timeWithStyle:NSDateFormatterShortStyle]);
	XCTAssertNotNil([aString timeWithStyle:NSDateFormatterFullStyle]);
	XCTAssertEqualObjects([aString timeWithStyle:NSDateFormatterFullStyle], [formatter dateFromString:@"11:45:32 PM Pacific Daylight Time"]);
	
	aString = @"Not a Time";
	XCTAssertNil([aString timeWithStyle:NSDateFormatterNoStyle]);
	XCTAssertNil([aString timeWithStyle:NSDateFormatterShortStyle]);
	XCTAssertNil([aString timeWithStyle:NSDateFormatterFullStyle]);
}

// dateWithStyle:timeStyle: is already tested with the dateWithStyle and timeWithStyle

- (void)testDateWithFormat
{
	NSDateFormatter *formatter = NSDateFormatter.new;
	formatter.dateFormat = @"";
	
	NSString *aString;
	
	aString = @"";
	XCTAssertEqualObjects([aString dateWithFormat:@""], [formatter dateFromString:@""]);
	XCTAssertNil([aString dateWithFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"]);
	
	
	formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
	
	aString = @"1996-12-19T16:39:57-08:00";
	XCTAssertNil([aString dateWithFormat:@""]);
	XCTAssertNotNil([aString dateWithFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"]);
	XCTAssertEqualObjects([aString dateWithFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"], [formatter dateFromString:@"1996-12-19T16:39:57-08:00"]);
	
	
	aString = @"5/20/2025";
	
	XCTAssertNotNil([aString dateWithFormat:nil]);
}

#pragma mark -objectAtIndexedSubscript

- (void)testObjectAtIndexedSubscript
{
	NSString *numberStr = @"0123456789";
	
	XCTAssertEqual(numberStr[0].charValue, '0');
	XCTAssertEqual(numberStr[1].charValue, '1');
	XCTAssertEqual(numberStr[9].charValue, '9');
	
	XCTAssertNil(numberStr[-1]);
	XCTAssertNil(numberStr[10]);
}

#pragma mark stringByInsertingString

- (void)testStringByInsertingString
{
	NSString *numbers = @"0123456789";
	
	XCTAssertEqualObjects([numbers stringByInsertingString:@"abc" atIndex:0], @"abc0123456789");
	XCTAssertEqualObjects([numbers stringByInsertingString:@"abc" atIndex:1], @"0abc123456789");
	XCTAssertEqualObjects([numbers stringByInsertingString:@"abc" atIndex:9], @"012345678abc9");
	XCTAssertEqualObjects([numbers stringByInsertingString:@"abc" atIndex:10], @"0123456789abc");
	
	XCTAssertThrowsSpecificNamed([numbers stringByInsertingString:@"abc" atIndex:11], NSException,
								 NSInvalidArgumentException);
}

#pragma mark stringByPrepending

- (void)testStringByPrependingString
{
	NSString *root = @"root";
	
	XCTAssertEqualObjects([root stringByPrependingString:@"abc_"], @"abc_root");
	XCTAssertEqualObjects([root stringByPrependingString:@""], @"root");
}

- (void)testStringByPrependingString_errors
{
	NSString *root = @"root";
	NSString *nilString = nil;
	
	XCTAssertThrowsSpecificNamed([root stringByPrependingString:nilString], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([root stringByPrependingString:(NSString*)NSObject.new], NSException, NSInvalidArgumentException);
	
	//Check error of existing method to match it.
	XCTAssertThrowsSpecificNamed([root stringByAppendingString:nilString], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([root stringByAppendingString:(NSString*)NSObject.new], NSException, NSInvalidArgumentException);
}

- (void)testStringByPrependingFormat
{
	NSString *root = @"root";
	
	NSString *result = [root stringByPrependingFormat:@"abc_%d_", 11];
	XCTAssertEqualObjects(result, @"abc_11_root");
	
	result = [root stringByPrependingFormat:@"", 11];
	XCTAssertEqualObjects(result, @"root");
}



- (void)testStringByPrependingFormat_error
{
	NSString *root = @"root";
	NSString *nilString = nil;
	NSString *result;
	
	@try {
		result = [root stringByPrependingFormat:nilString, 11];
		XCTAssertTrue(false, @"Did not throw NSException: NSInvalidArgumentException");
	} @catch (NSException *e) {}
	
	@try {
		result = [root stringByPrependingFormat:(NSString*)NSObject.new, 11];
		XCTAssertTrue(false, @"Did not throw NSException: NSInvalidArgumentException");
	} @catch (NSException *e) {
	}
	
	
	//Check error of existing method to match it.
	@try {
		result = [root stringByAppendingFormat:nilString, 11];
		XCTAssertTrue(false, @"Did not throw NSException: NSInvalidArgumentException");
	} @catch (NSException *e) {}
	
	
	@try {
		result = [root stringByAppendingFormat:(NSString*)NSObject.new, 11];
		XCTAssertTrue(false, @"Did not throw NSException: NSInvalidArgumentException");
	} @catch (NSException *e) {}
}



#pragma mark - NSMutableString
#pragma mark prepend

- (void)testPrependString {
	NSMutableString *string = NSMutableString.new;
	
	[string prependString:@""];
	XCTAssertEqualObjects(string, @"");
	
	[string prependString:@"abc"];
	XCTAssertEqualObjects(string, @"abc");
	
	[string prependString:@"-"];
	XCTAssertEqualObjects(string, @"-abc");
}

- (void)testPrependString_error {
	NSMutableString *string = NSMutableString.new;
	NSString *nilString = nil;
	
	XCTAssertThrowsSpecificNamed([string prependString:nilString], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([string prependString:(NSString*)NSObject.new], NSException, NSInvalidArgumentException);
	
	//Check error of existing method to match it.
	XCTAssertThrowsSpecificNamed([string appendString:nilString], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([string appendString:(NSString*)NSObject.new], NSException, NSInvalidArgumentException);
}

- (void)testPrependFormat
{
	NSMutableString *string = NSMutableString.new;
	
	[string prependFormat:@""];
	XCTAssertEqualObjects(string, @"");
	
	[string prependFormat:@"abc"];
	XCTAssertEqualObjects(string, @"abc");
	
	[string prependFormat:@"-"];
	XCTAssertEqualObjects(string, @"-abc");
	
	
	
	string = NSMutableString.new;
	
	[string prependFormat:@"", @"x"];
	XCTAssertEqualObjects(string, @"");
	
	[string prependFormat:@"abc", @"x"];
	XCTAssertEqualObjects(string, @"abc");
	
	[string prependFormat:@"-", @"x"];
	XCTAssertEqualObjects(string, @"-abc");
	
	
	
	string = NSMutableString.new;
	
	[string prependFormat:@"%@", @"x"];
	XCTAssertEqualObjects(string, @"x");
	
	[string prependFormat:@"%@", @"abc"];
	XCTAssertEqualObjects(string, @"abcx");
	
	[string prependFormat:@"%@", @"-"];
	XCTAssertEqualObjects(string, @"-abcx");
}


- (void)testPrependFormat_error
{
	NSMutableString *string = NSMutableString.new;
	NSString *nilString = nil;
	
	XCTAssertThrowsSpecificNamed([string prependFormat:nilString], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([string prependFormat:(NSString*)NSObject.new], NSException, NSInvalidArgumentException);
	
	@try {
		[string prependFormat:nilString, 11];
		XCTAssertTrue(false, @"Did not throw NSException: NSInvalidArgumentException");
	} @catch (NSException *e) {}
	
	@try {
		[string prependFormat:(NSString*)NSObject.new, 11];
		XCTAssertTrue(false, @"Did not throw NSException: NSInvalidArgumentException");
	} @catch (NSException *e) {
	}
	
	
	//Check error of existing method to match it.
	
	/*	// This throws EXC_BAD_ACCESS for being a nil String.
	 XCTAssertThrowsSpecificNamed([string appendFormat:nilString], NSException, NSInvalidArgumentException); //BAD_ACCESS
	
	@try {
		[string appendFormat:nilString, 11];
		XCTAssertTrue(false, @"Did not throw NSException: NSInvalidArgumentException");
	} @catch (NSException *e) {}
	 */
	
	XCTAssertThrowsSpecificNamed([string appendFormat:(NSString*)NSObject.new], NSException, NSInvalidArgumentException);
	@try {
		[string appendFormat:(NSString*)NSObject.new, 11];
		XCTAssertTrue(false, @"Did not throw NSException: NSInvalidArgumentException");
	} @catch (NSException *e) {
	}
}


#pragma mark deleteAll

- (void)testDeleteAll {
	
	NSMutableString *string = [NSMutableString stringWithString:@"my string"];
	
	[string deleteAll];
	
	XCTAssertEqualObjects(string, @"");
}


#pragma mark - -deleteAtIndex

- (void)testDeleteAtIndex {
	
	NSMutableString *string = [NSMutableString stringWithString:@"abcde"];
	
	[string deleteAtIndex:-1];
	XCTAssertEqualObjects(string, @"abcde");
	
	[string deleteAtIndex:5];
	XCTAssertEqualObjects(string, @"abcde");
	
	[string deleteAtIndex:2];
	XCTAssertEqualObjects(string, @"abde");
	
	[string deleteAtIndex:3];
	XCTAssertEqualObjects(string, @"abd");
	
	[string deleteAtIndex:0];
	XCTAssertEqualObjects(string, @"bd");
	
	[string deleteAtIndex:2];
	XCTAssertEqualObjects(string, @"bd");
}

@end
