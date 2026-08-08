/*!
 @file			NSDateFormatter+RFC2822.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Implements the NSDateFormatter (RFC2822) category.
 @discussion	Configures a formatter with the RFC 2822 date format, en_US_POSIX locale, and UTC
				time zone so dates round-trip the email/HTTP/RSS "Mon, 23 Jun 2025 14:45:30 +0000" form.
*/

#import "NSDateFormatter+RFC2822.h"

@implementation NSDateFormatter (RFC2822)

+ (NSDateFormatter *)rfc2822DateFormatter
{
	NSDateFormatter *rfc2822Formatter = NSDateFormatter.new;
	
	rfc2822Formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	rfc2822Formatter.dateFormat = kBEDateFormatRFC2822;
	rfc2822Formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	
	return rfc2822Formatter;
}


- (void)rfc2822Format
{
	self.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	self.dateFormat = kBEDateFormatRFC2822;
	self.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
}

@end

