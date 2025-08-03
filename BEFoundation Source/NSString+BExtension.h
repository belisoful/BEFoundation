/*!
 @header		NSString+BExtension.h
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract		`NSString` Category extension to provide numeric and date validation.
 @discussion	This category adds methods for checking if the NSString is a digit, integer, floating point
				number, or has a specific date or time.
*/

#ifndef NSString_BExtension_h
#define NSString_BExtension_h

#import <Foundation/Foundation.h>

/*!
 @category		BExtension
 @abstract		Adds numeric checking and date/time checking.
 @discussion	This category adds several utility methods to the `NSString` class for checking
 whether the string contains specific types of data (e.g., digits, integers, floats, dates, and times). These
 methods provide convenient ways to validate or convert strings based on their content.
 
 It also adds `stringValue` to mimic NSNumber for consisstency in reading plist Dictionaries.
 
 The following methods are provided by this category:
 
 `-stringValue`: Returns the string representation of the receiver, similar to `NSNumber`'s `stringValue`.
 
 `-isDigits`: Checks if the string consists only of digits.
 
 `-isIntValue`: Checks if the string can be interpreted as an integer.
 
 `-isIntegerValue`: Similar to `-isIntValue`, checks if the string can be interpreted as a valid integer.
 
 `-isLongLongValue`: Checks if the string can be interpreted as a valid `long long` integer.
 
 `-isUnsignedLongLongValue`: Checks if the string can be interpreted as a valid unsigned `long long` integer.
 
 `-isFloatValue`: Checks if the string can be interpreted as a valid float.
 
 `-isDoubleValue`: Checks if the string can be interpreted as a valid double.
 
 `-isSystemDateTimeValue`: Checks if the string is a valid system date time.
 
 `-isSystemDateValue`: Checks if the string is a valid system date.
 
 `-isSystemTimeValue`: Checks if the string is a valid system time.
 
 `-isDateStyle:`: Checks if the string is a valid style of date.
 
 `-isTimeStyle:`: Checks if the string is a valid style of time.
 
 `-isDateStyle:timeStyle:`: Checks if the string is a valid style of date and time.
 
 `-isDateTimeString:`: Checks if the string is date and/or time conforming to the format.
 
 And in NSMutableString:
 
 `-deleteAtIndex:`: Deletes the character at an index.
 
 These methods aim to make string parsing and validation easier, especially in scenarios where the format or
 content of the string matters, such as user input validation or conversion tasks.
 */
@interface NSString (BExtension)

/*!
 @property		stringValue
 @abstract		Returns the string.
 @discussion	This method provides compatibility with `[NSNumber stringValue]`, specifically for
				reading plist in a more standardized way.
 @result		Returns the receiver itself.
 */
@property (readonly, strong, nonatomic, nonnull) NSString* stringValue;

/*!
 @property		isDigits
 @abstract		Checks if the string is all digits.
 @result		Returns `YES`  if all digits.
 */
@property (readonly, assign, nonatomic) BOOL isDigits;

/*!
 @property		isIntValue
 @abstract		Checks if the string is a valid 32 bit int.
 @result		Returns `YES`  if the string is an `int`.
 */
@property (readonly, assign, nonatomic) BOOL isIntValue;

/*!
 @property		isIntegerValue
 @abstract		Checks if the string is a valid system sized (32 or 64 bit) long.
 @result		Returns `YES`  if the string is an `long`.
 */
@property (readonly, assign, nonatomic) BOOL isIntegerValue;

/*!
 @property		isLongLongValue
 @abstract		Checks if the string is a valid 64 bit long long.
 @result		Returns `YES`  if the string is an `long long`.
 */
@property (readonly, assign, nonatomic) BOOL isLongLongValue;

/*!
 @property		isUnsignedLongLongValue
 @abstract		Checks if the string is a valid 64 bit unsigned long long.
 @result		Returns `YES`  if the string is an `unsigned long long`.
 */
@property (readonly, assign, nonatomic) BOOL isUnsignedLongLongValue;

/*!
 @property		isFloatValue
 @abstract		Checks if the string is a valid 32 bit float.
 @result		Returns `YES`  if the string is an `float`.
 */
@property (readonly, assign, nonatomic) BOOL isFloatValue;

/*!
 @property		isDoubleValue
 @abstract		Checks if the string is a valid 64 bit double.
 @result		Returns `YES`  if the string is an `double`.
 */
@property (readonly, assign, nonatomic) BOOL isDoubleValue;

/*!
 @property		isSystemDateTimeValue
 @abstract		Checks if the string is a valid system date and time.
 @result		Returns `YES`  if the string is valid system date and time.
 */
@property (readonly, assign, nonatomic) BOOL isSystemDateTimeValue;

/*!
 @property		systemDateTimeValue
 @abstract		Checks if the string is a valid system date and time.
 @result		Returns `YES`  if the string is valid system date and time.
 */
@property (readonly, nullable, nonatomic) NSDate* systemDateTimeValue;

/*!
 @property		isSystemDateValue
 @abstract		Checks if the string is a valid system date.
 @result		Returns `YES`  if the string is valid system date.
 */
@property (readonly, assign, nonatomic) BOOL isSystemDateValue;

/*!
 @property		isSystemDateValue
 @abstract		Checks if the string is a valid system date.
 @result		Returns `YES`  if the string is valid system date.
 */
@property (readonly, nullable, nonatomic) NSDate* systemDateValue;

/*!
 @property		isSystemTimeValue
 @abstract		Checks if the string is a valid system time.
 @result		Returns `YES`  if the string is valid system time.
 */
@property (readonly, assign, nonatomic) BOOL isSystemTimeValue;

/*!
 @property		isSystemTimeValue
 @abstract		Checks if the string is a valid system time.
 @result		Returns `YES`  if the string is valid system time.
 */
@property (readonly, assign, nullable, nonatomic) NSDate * systemTimeValue;

#pragma mark -

/*!
 @method		-isDateStyle:
 @abstract		Checks if the NSString is a date of a specific style.
 @discussion	Forwards to isDateStyle:timeStyle: with no timeStyle.
 @param			dateStyle	The style of date to check the string against.
 @result		Returns `YES` if the string is a valid date in the provided format, `NO` otherwise.
 */
- (nullable NSDate *)dateWithStyle:(NSDateFormatterStyle)dateStyle;

/*!
 @method		-isTimeStyle:
 @abstract		Checks if the NSString is a time of a specific style.
 @discussion	Forwards to @c isDateStyle:timeStyle:  with no dateStyle.
 @param			timeStyle	The style of time to check the string against.
 @result		Returns `YES` if the string is a valid time in the provided format, `NO` otherwise.
 */
- (nullable NSDate *)timeWithStyle:(NSDateFormatterStyle)timeStyle;

/*!
 @method		-isDateStyle: timeStyle:
 @abstract		Checks if the NSString is a date and time with specified styles.
 @discussion	This method attempts to parse the string using a specified date time format and returns
				if it is successful or not
 @param	dateStyle	The date style to use for parsing the string.
 @param	timeStyle	The time style to use for parsing the string.
  
 @result		Returns `YES` if the string is a valid date time in the provided format,
				 `NO` otherwise.
 */
- (nullable NSDate *)dateWithStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

/*!
 @method		-isDateTimeString:
 @abstract		Checks if the NSString is a date time of a specific format.
 @discussion	This methods checks if the string conforms to the date string format as a
				`NSDateFormatter`.
				If `nil` is passed, the system date format without time is used.
 @param		strFormat	The date format string to use for parsing the string. If `nil`, the system's
						default date format is used.
 @result		Returns `YES` if the string is a valid date in the provided format, `NO` otherwise.
 */
- (nullable NSDate *)dateWithFormat:(nullable NSString *)strFormat;

- (nullable NSNumber *)objectAtIndexedSubscript:(NSUInteger)index;

- (nonnull NSString *)stringByInsertingString:(nonnull NSString*)aString atIndex:(NSUInteger)location;

- (nonnull NSString *)stringByPrependingString:(NSString * _Nonnull)aString;
- (nonnull NSString *)stringByPrependingFormat:(NSString * _Nonnull)format, ...;

@end




@interface NSMutableString (BExtension)


/*!
 @method		-prependString
 @abstract		Adds to the start of the receiver the characters of a given string.
 @param			aString The string to prepend to the receiver. aString must not be nil
 */
- (void)prependString:(nonnull NSString *)aString;

/*!
 @method		-prependFormat
 @abstract		Adds a constructed string to the start of the receiver.
 @param			format	A format string. See Formatting String Objects for more
						information. This value must not be nil.
 
 @param			...		A comma-separated list of arguments to substitute into
						format.
 */
- (void)prependFormat:(nonnull NSString *)format, ...;

/*!
 @method		-deleteAll
 @abstract		Removes all the characters and resets the string to @""
 */
- (void)deleteAll;

/*!
 @method		-deleteAtIndex
 @abstract		Deletes the character in the string at the index
 @param			index The index of the character to delete.
 */
- (void)deleteAtIndex:(NSUInteger)index;

@end

#endif	//	NSString_BExtension_h
