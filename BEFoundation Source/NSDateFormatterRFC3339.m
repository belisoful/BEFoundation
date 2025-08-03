/*!
 @file			NSDateFormatterRFC3339.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract
 @discussion
*/

#import "NSDateFormatterRFC3339.h"

#define kRFC3339_DateFormat		@"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

@implementation NSDateFormatter (RFC3339)

+ (NSDateFormatter *)rfc3339DateFormatter
{
	NSDateFormatter *rfc3339Formatter = NSDateFormatter.new;
	
	rfc3339Formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	rfc3339Formatter.dateFormat = kRFC3339_DateFormat;
	rfc3339Formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	
	return rfc3339Formatter;
}


- (void)rfc3339Format
{
	self.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	self.dateFormat = kRFC3339_DateFormat;
	self.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
}

@end

