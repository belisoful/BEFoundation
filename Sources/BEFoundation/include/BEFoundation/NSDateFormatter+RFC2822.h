/*!
 @header		NSDateFormatter+RFC2822.h
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Category extension for NSDateFormatter providing RFC 2822 date formatting support.
 @discussion	This header provides a category extension for NSDateFormatter that adds convenience
				methods for working with RFC 2822 formatted dates. RFC 2822 (Internet Message Format)
				defines the date format used in email headers, derived from RFC 822. HTTP and RSS
				use a near-identical format. It is unrelated to ISO 8601; for ISO 8601 / Internet
				timestamps use the RFC 3339 category instead. The category documentation below
				lists the formatter settings and parsing limits.
 */

#ifndef NSDateFormatterRFC2822_h
#define NSDateFormatterRFC2822_h

#import <Foundation/Foundation.h>

#define kBEDateFormatRFC2822		(@"EEE, dd MMM yyyy HH:mm:ss Z")

NS_ASSUME_NONNULL_BEGIN

/*!
 @category		NSDateFormatter (RFC2822)
 @abstract		Category extension for NSDateFormatter providing RFC 2822 date formatting capabilities.
 @discussion	This category adds a class method that creates a configured formatter and an
				instance method that configures an existing formatter. Both apply the same
				RFC 2822 settings:
				- Date format: EEE, dd MMM yyyy HH:mm:ss Z  (e.g. "Mon, 23 Jun 2025 14:45:30 +0000")
				- Timezone: UTC (GMT+0)
				- Locale: en_US_POSIX, so the English weekday and month names RFC 2822 requires are used

				Parsing note: this fixed format requires the leading weekday and a numeric zone offset.
				A string without the weekday ("23 Jun 2025 …") or with an obsolete alphabetic zone
				("… GMT"/"… EST") does not parse, and dateFromString: returns nil. The weekday must be
				present but is not validated against the date. An inconsistent weekday (e.g. "Tue" for
				a Monday) is accepted, and the day/month/year fields determine the instant.
				Comments and folding whitespace (CFWS) are not supported either: a real email header such
				as "… +0000 (UTC)" does not parse, so strip any trailing comment before parsing.
 @code
	NSDateFormatter *fmt = [NSDateFormatter rfc2822DateFormatter];
	NSString *s = [fmt stringFromDate:NSDate.date];   // "Mon, 23 Jun 2025 14:45:30 +0000"
	NSDate *d = [fmt dateFromString:@"Mon, 23 Jun 2025 14:45:30 -0800"]; // offset honored -> 22:45:30 UTC
 @endcode

 @since 1.1
 */
@interface NSDateFormatter (RFC2822)

/*!
 @method		+rfc2822DateFormatter
 @abstract		Creates and returns a new NSDateFormatter configured for RFC 2822 date formatting.
 @discussion	This class method creates a new NSDateFormatter instance and configures it for
				RFC 2822 parsing and formatting:
				- Date format: "EEE, dd MMM yyyy HH:mm:ss Z"
				- Locale: en_US_POSIX
				- Timezone: UTC (GMT+0)

				Performance: each call allocates and configures a fresh NSDateFormatter, which is
				relatively expensive. If you format or parse many dates, keep one formatter and reuse
				it. A configured NSDateFormatter is safe to use (format/parse) concurrently from
				multiple threads as long as its properties are not mutated.
 @result		A new NSDateFormatter instance configured for RFC 2822 date formatting.
 @see			rfc2822Format
 */
+ (NSDateFormatter *)rfc2822DateFormatter;

/*!
 @method		-rfc2822Format
 @abstract		Configures the receiver to use RFC 2822 date formatting settings.
 @discussion	This instance method configures an existing NSDateFormatter for RFC 2822
				parsing and formatting. It sets the following properties on the receiver,
				replacing their previous values:
				- dateFormat: "EEE, dd MMM yyyy HH:mm:ss Z"
				- locale: en_US_POSIX locale identifier
				- timeZone: UTC timezone (GMT+0)
 @see			rfc2822DateFormatter
 */
- (void)rfc2822Format;

@end

NS_ASSUME_NONNULL_END

#endif // NSDateFormatterRFC2822_h
