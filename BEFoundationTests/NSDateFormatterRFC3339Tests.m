//  NSDateFormatterRFC3339Tests.m
//  Copyright © 2025 Delicense - @belisoful. All rights released.

#import <XCTest/XCTest.h>
#import "NSDateFormatterRFC3339.h" // Import your category header

// Define the expected RFC3339 date format string for convenience in tests
#define kExpectedRFC3339_DateFormat @"yyyy-MM-dd'T'HH:mm:ssZZZZZ"

@interface NSDateFormatterRFC3339Tests : XCTestCase

@end

@implementation NSDateFormatterRFC3339Tests

- (void)setUp {
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

#pragma mark - Tests for + (NSDateFormatter *)rfc3339DateFormatter

/**
 * @brief Tests that the +rfc3339DateFormatter method returns a non-nil formatter.
 */
- (void)testRfc3339DateFormatterReturnsNonNull {
	NSDateFormatter *formatter = [NSDateFormatter rfc3339DateFormatter];
	XCTAssertNotNil(formatter, @"The RFC3339 date formatter should not be nil.");
}

/**
 * @brief Tests that the +rfc3339DateFormatter method sets the correct locale.
 */
- (void)testRfc3339DateFormatterSetsCorrectLocale {
	NSDateFormatter *formatter = [NSDateFormatter rfc3339DateFormatter];
	XCTAssertEqualObjects(formatter.locale.localeIdentifier, @"en_US_POSIX", @"The RFC3339 date formatter locale should be 'en_US_POSIX'.");
}

/**
 * @brief Tests that the +rfc3339DateFormatter method sets the correct date format.
 */
- (void)testRfc3339DateFormatterSetsCorrectDateFormat {
	NSDateFormatter *formatter = [NSDateFormatter rfc3339DateFormatter];
	XCTAssertEqualObjects(formatter.dateFormat, kExpectedRFC3339_DateFormat, @"The RFC3339 date formatter date format should be '%@'.", kExpectedRFC3339_DateFormat);
}

/**
 * @brief Tests that the +rfc3339DateFormatter method sets the correct time zone (GMT/UTC).
 */
- (void)testRfc3339DateFormatterSetsCorrectTimeZone {
	NSDateFormatter *formatter = [NSDateFormatter rfc3339DateFormatter];
	// Check if the timeZone is UTC/GMT with 0 seconds from GMT
	XCTAssertEqualObjects(formatter.timeZone, [NSTimeZone timeZoneForSecondsFromGMT:0], @"The RFC3339 date formatter time zone should be UTC/GMT.");
	XCTAssertEqual(formatter.timeZone.secondsFromGMT, 0, @"The RFC3339 date formatter time zone should have 0 seconds from GMT.");
}

/**
 * @brief Tests that the +rfc3339DateFormatter correctly formats a specific date.
 */
- (void)testRfc3339DateFormatterFormatsDateCorrectly {
	NSDateFormatter *formatter = [NSDateFormatter rfc3339DateFormatter];

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

	NSString *expectedFormattedString = @"2025-06-23T10:30:00Z"; // Z indicates UTC/GMT
	NSString *actualFormattedString = [formatter stringFromDate:date];

	XCTAssertEqualObjects(actualFormattedString, expectedFormattedString, @"The formatted date string should match the expected RFC3339 format.");
}

#pragma mark - Tests for - (void)rfc3339Format

/**
 * @brief Tests that the -rfc3339Format method correctly sets the locale of an existing formatter.
 */
- (void)testRfc3339FormatSetsCorrectLocale {
	NSDateFormatter *formatter = NSDateFormatter.new;
	// Set some initial values to ensure they are overwritten
	formatter.locale = [NSLocale localeWithLocaleIdentifier:@"fr_FR"];
	formatter.dateFormat = @"MM/dd/yyyy";
	formatter.timeZone = [NSTimeZone localTimeZone];

	[formatter rfc3339Format]; // Apply the RFC3339 format

	XCTAssertEqualObjects(formatter.locale.localeIdentifier, @"en_US_POSIX", @"The RFC3339 date formatter locale should be 'en_US_POSIX' after applying rfc3339Format.");
}

/**
 * @brief Tests that the -rfc3339Format method correctly sets the date format of an existing formatter.
 */
- (void)testRfc3339FormatSetsCorrectDateFormat {
	NSDateFormatter *formatter = NSDateFormatter.new;
	// Set some initial values to ensure they are overwritten
	formatter.locale = [NSLocale localeWithLocaleIdentifier:@"fr_FR"];
	formatter.dateFormat = @"MM/dd/yyyy";
	formatter.timeZone = [NSTimeZone localTimeZone];

	[formatter rfc3339Format]; // Apply the RFC3339 format

	XCTAssertEqualObjects(formatter.dateFormat, kExpectedRFC3339_DateFormat, @"The RFC3339 date formatter date format should be '%@' after applying rfc3339Format.", kExpectedRFC3339_DateFormat);
}

/**
 * @brief Tests that the -rfc3339Format method correctly sets the time zone of an existing formatter.
 */
- (void)testRfc3339FormatSetsCorrectTimeZone {
	NSDateFormatter *formatter = NSDateFormatter.new;
	// Set some initial values to ensure they are overwritten
	formatter.locale = [NSLocale localeWithLocaleIdentifier:@"fr_FR"];
	formatter.dateFormat = @"MM/dd/yyyy";
	formatter.timeZone = [NSTimeZone localTimeZone];

	[formatter rfc3339Format]; // Apply the RFC3339 format

	XCTAssertEqualObjects(formatter.timeZone, [NSTimeZone timeZoneForSecondsFromGMT:0], @"The RFC3339 date formatter time zone should be UTC/GMT after applying rfc3339Format.");
	XCTAssertEqual(formatter.timeZone.secondsFromGMT, 0, @"The RFC3339 date formatter time zone should have 0 seconds from GMT after applying rfc3339Format.");
}

/**
 * @brief Tests that an existing NSDateFormatter, after calling -rfc3339Format, correctly formats a specific date.
 */
- (void)testRfc3339FormatFormatsDateCorrectly {
	NSDateFormatter *formatter = NSDateFormatter.new;
	[formatter rfc3339Format]; // Apply the RFC3339 format

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

	NSString *expectedFormattedString = @"2025-06-23T14:45:30Z"; // Z indicates UTC/GMT
	NSString *actualFormattedString = [formatter stringFromDate:date];

	XCTAssertEqualObjects(actualFormattedString, expectedFormattedString, @"The formatted date string should match the expected RFC3339 format after applying rfc3339Format.");
}

@end
