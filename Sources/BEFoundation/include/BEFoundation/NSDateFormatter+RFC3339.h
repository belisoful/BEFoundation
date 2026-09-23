/*!
 @header		NSDateFormatter+RFC3339.h
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Category extension for NSDateFormatter providing RFC 3339 date formatting support.
 @discussion	This header provides a category extension for NSDateFormatter that adds convenience
				methods for working with RFC 3339 formatted dates. RFC 3339 is a profile of the
				ISO 8601 standard that defines a date and time format for use in Internet protocols.
				The category documentation below lists the formatter settings and parsing limits.
 */

#ifndef NSDateFormatterRFC3339_h
#define NSDateFormatterRFC3339_h

#import <Foundation/Foundation.h>

#define kBEDateFormatRFC3339		(@"yyyy-MM-dd'T'HH:mm:ssZZZZZ")

NS_ASSUME_NONNULL_BEGIN

/*!
 @category		NSDateFormatter (RFC3339)
 @abstract		Category extension for NSDateFormatter providing RFC 3339 date formatting capabilities.
 @discussion	This category adds a class method that creates a configured formatter and an
				instance method that configures an existing formatter. Both apply the same
				RFC 3339 settings:
				- Date format: yyyy-MM-dd'T'HH:mm:ssZZZZZ  (e.g. "2025-06-23T14:45:30Z")
				- Timezone: UTC (GMT+0)
				- Locale: en_US_POSIX
				- Compatible with ISO 8601 standard

				Conformance / parsing note: this fixed format parses a full-string, whole-second
				timestamp with an uppercase 'T' separator and a "Z"/"z" or numeric offset (e.g.
				"+00:00", "-08:00"). The zone designator is case-insensitive ('z' works), but the
				separator is a format literal and stays case-sensitive. These optional RFC 3339
				productions are not accepted, and dateFromString: returns nil for them:
				- fractional seconds ("2025-06-23T14:45:30.5Z"); add ".SSS" to the format to accept them;
				- the §5.6 separator alternatives, a space or a lowercase 't' for the 'T'
				  ("2025-06-23 10:30:00Z", "2025-06-23t10:30:00Z");
				- a leap second (":60", e.g. "2025-06-30T23:59:60Z").
				Hours are restricted to 00-23 (no ISO 8601 "24:00") and any trailing content is rejected.
 @code
	NSDateFormatter *fmt = [NSDateFormatter rfc3339DateFormatter];
	NSString *s = [fmt stringFromDate:NSDate.date];   // "2025-06-23T14:45:30Z"
	NSDate *d = [fmt dateFromString:@"2025-06-23T14:45:30-08:00"]; // offset honored -> 22:45:30 UTC
 @endcode
 */
@interface NSDateFormatter (RFC3339)

/*!
 @method		+rfc3339DateFormatter
 @abstract		Creates and returns a new NSDateFormatter configured for RFC 3339 date formatting.
 @discussion	This class method creates a new NSDateFormatter instance and configures it for
				RFC 3339 parsing and formatting:
				- Date format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
				- Locale: en_US_POSIX
				- Timezone: UTC (GMT+0)

				Performance: each call allocates and configures a fresh NSDateFormatter, which is
				relatively expensive. If you format or parse many dates, keep one formatter and reuse
				it. A configured NSDateFormatter is safe to use (format/parse) concurrently from
				multiple threads as long as its properties are not mutated.
 @result		A new NSDateFormatter instance configured for RFC 3339 date formatting.
 @see			rfc3339Format
 */
+ (NSDateFormatter *)rfc3339DateFormatter;

/*!
 @method		-rfc3339Format
 @abstract		Configures the receiver to use RFC 3339 date formatting settings.
 @discussion	This instance method configures an existing NSDateFormatter for RFC 3339
				parsing and formatting. It sets the following properties on the receiver,
				replacing their previous values:
				- dateFormat: "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
				- locale: en_US_POSIX locale identifier
				- timeZone: UTC timezone (GMT+0)
 @see			rfc3339DateFormatter
 */
- (void)rfc3339Format;

@end

NS_ASSUME_NONNULL_END

#endif // NSDateFormatterRFC3339_h
