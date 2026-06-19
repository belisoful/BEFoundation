//  NSDateFormatterRFC2822Tests.m
//  Copyright © 2025 Delicense - @belisoful. All rights released.

#import <XCTest/XCTest.h>
#import "NSDateFormatter+RFC2822.h" // Import your category header

// Define the expected RFC2822 date format string for convenience in tests
#define kExpectedRFC2822_DateFormat @"EEE, dd MMM yyyy HH:mm:ss Z"

@interface NSDateFormatterRFC2822Tests : XCTestCase

@end

@implementation NSDateFormatterRFC2822Tests

- (void)setUp {
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

#pragma mark - Tests for + (NSDateFormatter *)rfc2822DateFormatter

/**
 * @brief Tests that the +rfc2822DateFormatter method returns a non-nil formatter.
 */
- (void)testRfc2822DateFormatterReturnsNonNull {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];
	XCTAssertNotNil(formatter, @"The RFC2822 date formatter should not be nil.");
}

/**
 * @brief Tests that the +rfc2822DateFormatter method sets the correct locale.
 */
- (void)testRfc2822DateFormatterSetsCorrectLocale {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];
	XCTAssertEqualObjects(formatter.locale.localeIdentifier, @"en_US_POSIX", @"The RFC2822 date formatter locale should be 'en_US_POSIX'.");
}

/**
 * @brief Tests that the +rfc2822DateFormatter method sets the correct date format.
 */
- (void)testRfc2822DateFormatterSetsCorrectDateFormat {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];
	XCTAssertEqualObjects(formatter.dateFormat, kExpectedRFC2822_DateFormat, @"The RFC2822 date formatter date format should be '%@'.", kExpectedRFC2822_DateFormat);
}

/**
 * @brief Tests that the +rfc2822DateFormatter method sets the correct time zone (GMT/UTC).
 */
- (void)testRfc2822DateFormatterSetsCorrectTimeZone {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];
	// Check if the timeZone is UTC/GMT with 0 seconds from GMT
	XCTAssertEqualObjects(formatter.timeZone, [NSTimeZone timeZoneForSecondsFromGMT:0], @"The RFC2822 date formatter time zone should be UTC/GMT.");
	XCTAssertEqual(formatter.timeZone.secondsFromGMT, 0, @"The RFC2822 date formatter time zone should have 0 seconds from GMT.");
}

/**
 * @brief Tests that the +rfc2822DateFormatter correctly formats a specific date.
 */
- (void)testRfc2822DateFormatterFormatsDateCorrectly {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];

	// Create a known date in UTC
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.year = 2025;
	components.month = 6;
	components.day = 23;
	components.hour = 10;
	components.minute = 30;
	components.second = 0;
	components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0]; // Ensure components are in UTC

	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0]; // Ensure calendar interprets components in UTC
	NSDate *date = [calendar dateFromComponents:components];

	XCTAssertNotNil(date, @"Test date should not be nil.");

	NSString *expectedFormattedString = @"Mon, 23 Jun 2025 10:30:00 +0000";
	NSString *actualFormattedString = [formatter stringFromDate:date];

	XCTAssertEqualObjects(actualFormattedString, expectedFormattedString, @"The formatted date string should match the expected RFC2822 format.");
}

#pragma mark - Tests for - (void)rfc2822Format

/**
 * @brief Tests that the -rfc2822Format method correctly sets the locale of an existing formatter.
 */
- (void)testRfc2822FormatSetsCorrectLocale {
	NSDateFormatter *formatter = NSDateFormatter.new;
	// Set some initial values to ensure they are overwritten
	formatter.locale = [NSLocale localeWithLocaleIdentifier:@"fr_FR"];
	formatter.dateFormat = @"MM/dd/yyyy";
	formatter.timeZone = [NSTimeZone localTimeZone];

	[formatter rfc2822Format]; // Apply the RFC2822 format

	XCTAssertEqualObjects(formatter.locale.localeIdentifier, @"en_US_POSIX", @"The RFC2822 date formatter locale should be 'en_US_POSIX' after applying rfc2822Format.");
}

/**
 * @brief Tests that the -rfc2822Format method correctly sets the date format of an existing formatter.
 */
- (void)testRfc2822FormatSetsCorrectDateFormat {
	NSDateFormatter *formatter = NSDateFormatter.new;
	// Set some initial values to ensure they are overwritten
	formatter.locale = [NSLocale localeWithLocaleIdentifier:@"fr_FR"];
	formatter.dateFormat = @"MM/dd/yyyy";
	formatter.timeZone = [NSTimeZone localTimeZone];

	[formatter rfc2822Format]; // Apply the RFC2822 format

	XCTAssertEqualObjects(formatter.dateFormat, kExpectedRFC2822_DateFormat, @"The RFC2822 date formatter date format should be '%@' after applying rfc2822Format.", kExpectedRFC2822_DateFormat);
}

/**
 * @brief Tests that the -rfc2822Format method correctly sets the time zone of an existing formatter.
 */
- (void)testRfc2822FormatSetsCorrectTimeZone {
	NSDateFormatter *formatter = NSDateFormatter.new;
	// Set some initial values to ensure they are overwritten
	formatter.locale = [NSLocale localeWithLocaleIdentifier:@"fr_FR"];
	formatter.dateFormat = @"MM/dd/yyyy";
	formatter.timeZone = [NSTimeZone localTimeZone];

	[formatter rfc2822Format]; // Apply the RFC2822 format

	XCTAssertEqualObjects(formatter.timeZone, [NSTimeZone timeZoneForSecondsFromGMT:0], @"The RFC2822 date formatter time zone should be UTC/GMT after applying rfc2822Format.");
	XCTAssertEqual(formatter.timeZone.secondsFromGMT, 0, @"The RFC2822 date formatter time zone should have 0 seconds from GMT after applying rfc2822Format.");
}

/**
 * @brief Tests that an existing NSDateFormatter, after calling -rfc2822Format, correctly formats a specific date.
 */
- (void)testRfc2822FormatFormatsDateCorrectly {
	NSDateFormatter *formatter = NSDateFormatter.new;
	[formatter rfc2822Format]; // Apply the RFC2822 format

	// Create a known date in UTC
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.year = 2025;
	components.month = 6;
	components.day = 23;
	components.hour = 14;
	components.minute = 45;
	components.second = 30;
	components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0]; // Ensure components are in UTC

	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0]; // Ensure calendar interprets components in UTC
	NSDate *date = [calendar dateFromComponents:components];

	XCTAssertNotNil(date, @"Test date should not be nil.");

	NSString *expectedFormattedString = @"Mon, 23 Jun 2025 14:45:30 +0000";
	NSString *actualFormattedString = [formatter stringFromDate:date];

	XCTAssertEqualObjects(actualFormattedString, expectedFormattedString, @"The formatted date string should match the expected RFC2822 format after applying rfc2822Format.");
}

#pragma mark - Parsing

- (void)testRfc2822ParsesUTCRoundTrip {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];
	NSString *rfc = @"Mon, 23 Jun 2025 14:45:30 +0000";
	NSDate *date = [formatter dateFromString:rfc];
	XCTAssertNotNil(date);
	XCTAssertEqualObjects([formatter stringFromDate:date], rfc);
}

- (void)testRfc2822ParsesNonUTCOffsetToCorrectInstant {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];
	NSDate *minus8 = [formatter dateFromString:@"Mon, 23 Jun 2025 14:45:30 -0800"];
	NSDate *utc = [formatter dateFromString:@"Mon, 23 Jun 2025 22:45:30 +0000"];
	XCTAssertNotNil(minus8);
	XCTAssertEqualObjects(minus8, utc, @"-0800 must resolve to the same UTC instant as 22:45:30 +0000");
}

// The fixed format requires the leading weekday; a string without it does not parse.
- (void)testRfc2822RejectsMissingWeekday {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];
	XCTAssertNil([formatter dateFromString:@"23 Jun 2025 14:45:30 +0000"]);
}

// Gotcha: the weekday is required syntactically but is NOT validated against the date. An
// inconsistent weekday ("Tue" for a Monday) is silently accepted; the date fields win.
- (void)testRfc2822DoesNotValidateWeekday {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];
	NSDate *wrongWeekday = [formatter dateFromString:@"Tue, 23 Jun 2025 14:45:30 +0000"];
	NSDate *correctWeekday = [formatter dateFromString:@"Mon, 23 Jun 2025 14:45:30 +0000"];
	XCTAssertNotNil(wrongWeekday);
	XCTAssertEqualObjects(wrongWeekday, correctWeekday);
}

// RFC 2822 permits a 1- or 2-digit day; the "dd" field still parses the single-digit form.
- (void)testRfc2822ParsesSingleDigitDay {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];
	NSDate *oneDigit = [formatter dateFromString:@"Sun, 1 Jun 2025 14:45:30 +0000"];
	NSDate *twoDigit = [formatter dateFromString:@"Sun, 01 Jun 2025 14:45:30 +0000"];
	XCTAssertNotNil(oneDigit);
	XCTAssertEqualObjects(oneDigit, twoDigit);
}

- (void)testRfc2822RejectsMalformedString {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];
	XCTAssertNil([formatter dateFromString:@"not a date"]);
	XCTAssertNil([formatter dateFromString:@""]);
}

// Real email Date: headers may carry a trailing zone comment / CFWS, e.g. "+0000 (UTC)".
// The fixed format does not accept it — strip comments before parsing actual headers.
- (void)testRfc2822RejectsTrailingComment {
	NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];
	XCTAssertNil([formatter dateFromString:@"Mon, 23 Jun 2025 14:45:30 +0000 (UTC)"]);
}

@end
