/*!
 @file			NSDateFormatter+RFC3339.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Implements the NSDateFormatter (RFC3339) category.
 @discussion	Configures a formatter with the RFC 3339 date format, en_US_POSIX locale, and UTC
				time zone so whole-second Internet timestamps round-trip the "2025-06-23T14:45:30Z" form.
*/

#import "NSDateFormatter+RFC3339.h"

@implementation NSDateFormatter (RFC3339)

+ (NSDateFormatter *)rfc3339DateFormatter
{
	NSDateFormatter *rfc3339Formatter = NSDateFormatter.new;
	
	rfc3339Formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	rfc3339Formatter.dateFormat = kBEDateFormatRFC3339;
	rfc3339Formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	
	return rfc3339Formatter;
}


- (void)rfc3339Format
{
	self.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	self.dateFormat = kBEDateFormatRFC3339;
	self.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
}

@end

