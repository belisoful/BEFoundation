/*!
 @header		NSDateFormatterRFC3339.h
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract		Category extension for NSDateFormatter providing RFC 3339 date formatting support.
 @discussion	This header provides a category extension for NSDateFormatter that adds convenience
				methods for working with RFC 3339 formatted dates. RFC 3339 is a profile of the
				ISO 8601 standard that defines a date and time format for use in Internet protocols.
				
				The RFC 3339 format (yyyy-MM-dd'T'HH:mm:ssZZZZZ) is commonly used in web APIs,
				JSON data interchange, and other Internet-based applications where standardized
				date representation is required. This extension simplifies the creation and
				configuration of NSDateFormatter instances for RFC 3339 compliance.
				
				Key features of RFC 3339 formatting:
				- Uses UTC timezone (GMT+0) for consistency
				- Employs en_US_POSIX locale to avoid localization issues
				- Follows the standard yyyy-MM-dd'T'HH:mm:ssZZZZZ format
				- Ensures reliable parsing and formatting across different locales and timezones
 */

#ifndef NSDateFormatterRFC3339_h
#define NSDateFormatterRFC3339_h

#import <Foundation/Foundation.h>

/*!
 @category		NSDateFormatter (RFC3339)
 @abstract		Category extension for NSDateFormatter providing RFC 3339 date formatting capabilities.
 @discussion	This category adds methods to NSDateFormatter for easy creation and configuration
				of formatters that comply with RFC 3339 date format specifications. RFC 3339 is
				a standardized date and time format commonly used in web services and APIs.
				
				The category provides both a class method for creating a pre-configured formatter
				and an instance method for configuring an existing formatter to use RFC 3339
				format settings. All methods ensure proper locale, timezone, and format string
				configuration for RFC 3339 compliance.
				
				RFC 3339 format characteristics:
				- Date format: yyyy-MM-dd'T'HH:mm:ssZZZZZ
				- Timezone: UTC (GMT+0)
				- Locale: en_US_POSIX (prevents localization issues)
				- Compatible with ISO 8601 standard
 */
@interface NSDateFormatter (RFC3339)

/*!
 @method		+rfc3339DateFormatter
 @abstract		Creates and returns a new NSDateFormatter configured for RFC 3339 date formatting.
 @discussion	This class method creates a new NSDateFormatter instance and configures it with
				the proper settings for RFC 3339 date format compliance. The returned formatter
				is ready to use for parsing and formatting dates in RFC 3339 format.
				
				The formatter is configured with:
				- Date format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
				- Locale: en_US_POSIX (prevents localization issues)
				- Timezone: UTC (GMT+0)
				
				This method is convenient when you need a one-time formatter for RFC 3339 dates
				and don't want to manually configure the formatter settings. The returned formatter
				can be used immediately for date parsing and formatting operations.
 @result		A new NSDateFormatter instance configured for RFC 3339 date formatting.
				The formatter is autoreleased and ready for immediate use.
 @see			rfc3339Format
 */
+ (NSDateFormatter *)rfc3339DateFormatter;

/*!
 @method		-rfc3339Format
 @abstract		Configures the receiver to use RFC 3339 date formatting settings.
 @discussion	This instance method configures an existing NSDateFormatter to use RFC 3339
				date format settings. This is useful when you have an existing formatter that
				you want to reconfigure for RFC 3339 compliance, or when you want to modify
				a formatter's settings without creating a new instance.
				
				The method sets the following properties on the receiver:
				- dateFormat: "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
				- locale: en_US_POSIX locale identifier
				- timeZone: UTC timezone (GMT+0)
				
				After calling this method, the formatter will be properly configured for
				parsing and formatting RFC 3339 compliant date strings. Any previous format
				settings will be overridden.
 @see			rfc3339DateFormatter
 */
- (void)rfc3339Format;

@end

#endif // NSRFC3339DateFormatter_h
