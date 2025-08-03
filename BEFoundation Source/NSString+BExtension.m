/*!
 @file			NSString+BExtension.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract		`NSString` Category extension to provide numeric and date validation.
 @discussion	This category adds methods for checking if the NSString is a digit, integer, floating point
 				number, or has a specific date or time.
*/

#import "NSString+BExtension.h"

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
 
 
 These methods aim to make string parsing and validation easier, especially in scenarios where the format or
 content of the string matters, such as user input validation or conversion tasks.
 */
@implementation NSString (BExtension)


/*!
 @method		-stringValue
 @abstract		Returns the string.
 @discussion	This method provides compatibility with `[NSNumber stringValue]`, specifically for
				reading plist in a more standardized way.
 @result		Returns the receiver itself.
 */
- (NSString*)stringValue
{
	return self;
}


/*!
 @method		-isDigits
 @abstract		Checks if the NSString consists only of digits.
 @discussion	This method verifies the string contains only numeric characters (0-9),
 				using the `NSCharacterSet` class to check for membership in the
 				`decimalDigitCharacterSet`.
				Numeric characters include Indic scripts and Arabic decimal digits.
 
 				This is useful for checking if a string represents a whole number
				without any spaces, punctuation, or other characters.
 @result		Returns `YES` if the string contains only digits, `NO` otherwise.
 */
- (BOOL)isDigits
{
	NSCharacterSet* nonNumerics = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	NSRange r = [self rangeOfCharacterFromSet: nonNumerics];
	return r.location == NSNotFound && self.length > 0;
}


/*!
 @method		-isIntValue
 @abstract		Checks if the NSString is a valid 32 bit int value.
 @discussion 	This method uses `NSScanner` to check if the string can be parsed as a `int`.
 @result		Returns `YES` if the string is a valid int value,`NO` otherwise.
 */
- (BOOL)isIntValue
{
	NSScanner *sc = [NSScanner scannerWithString: self];
	if ([sc scanInt:NULL]) {
		return [sc isAtEnd];
	}
	return NO;
}


/*!
 @method		-isIntegerValue
 @abstract		Checks if the NSString is a valid NSInteger value.
 @discussion 	This method uses `NSScanner` to check if the string can be parsed as a
				`NSInteger`.
 				The size of the Integer is dependent on the size of int for the binary target,
 				platform, and system/chip architecture.  It could be 32 bits or 64 bits.
 @result		Returns `YES` if the string is a valid NSInteger value,`NO` otherwise.
 */
- (BOOL)isIntegerValue
{
	NSScanner *sc = [NSScanner scannerWithString: self];
	if ( [sc scanInteger:NULL] ) {
		return [sc isAtEnd];
	}
	return NO;
}


/*!
 @method		-isLongLongValue
 @abstract		Checks if the NSString is a valid 64 bit signed long long value.
 @discussion 	This method uses `NSScanner` to check if the string can be parsed as a
				`long long`.
 @result		Returns `YES` if the string is a valid signed long long value,`NO` otherwise.
 */
- (BOOL)isLongLongValue
{
	NSScanner *sc = [NSScanner scannerWithString: self];
	if ( [sc scanLongLong:NULL] ) {
		return [sc isAtEnd];
	}
	return NO;
}


/*!
 @method		-isUnsignedLongLongValue
 @abstract		Checks if the NSString is a valid 64 bit unsigned long long value.
 @discussion 	This method uses `NSScanner` to check if the string can be parsed as an
 				`unsigned long long`.
 @result		Returns `YES` if the string is a valid unsigned long long value,
 				`NO` otherwise.
 */
- (BOOL)isUnsignedLongLongValue
{
	NSScanner *sc = [NSScanner scannerWithString: self];
	if ( [sc scanUnsignedLongLong:NULL] ) {
		return [sc isAtEnd];
	}
	return NO;
}


/*!
 @method		-isFloatValue
 @abstract		Checks if the NSString is a valid 32 bit float value.
 @discussion 	This method uses `NSScanner` to check if the string can be parsed as a `float`.
			 	This method supports all text formats of floating point numbers.
 @result		Returns `YES` if the string is a valid float value, `NO` otherwise.
 */
- (BOOL)isFloatValue
{
	NSScanner *sc = [NSScanner scannerWithString: self];
	if ( [sc scanFloat:NULL] ) {
		return [sc isAtEnd];
	}
	return NO;
}


/*!
 @method		-isDoubleValue
 @abstract		Checks if the NSString is a valid 64 bit double value.
 @discussion	This method uses `NSScanner` to check if the string can be parsed as a `double`.
				This method supports all text formats of floating point numbers.
 @result		Returns `YES` if the string is a valid double value, `NO` otherwise.
 */
- (BOOL)isDoubleValue
{
	NSScanner *sc = [NSScanner scannerWithString: self];
	if ( [sc scanDouble:NULL] ) {
		return [sc isAtEnd];
	}
	return NO;
}


/*!
 @method		-isSystemDateTimeValue
 @abstract		Checks if the NSString is a valid system date and time.
 @discussion	This method attempts to parse the string using the current system's default date format
 				(as determined by locale settings).
 @result		Returns `YES` if the string is a valid date in the system's default format, `NO` otherwise.
 */
- (BOOL)isSystemDateTimeValue
{
	return [self dateWithStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle] != nil;
}

/*!
 @method		-systemDateTimeValue
 @abstract		A  date and time.
 @discussion	This method attempts to parse the string using the current system's default date format
				(as determined by locale settings).
 @result		Returns `YES` if the string is a valid date in the system's default format, `NO` otherwise.
 */
- (NSDate *)systemDateTimeValue
{
	return [self dateWithStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}


/*!
 @method		-isSystemDateValue
 @abstract		Checks if the NSString is a valid system date.
 @discussion	This method attempts to parse the string using the current system's default date format
				(as determined by locale settings).
 @result		Returns `YES` if the string is a valid date in the system's default format, `NO` otherwise.
 */
- (BOOL)isSystemDateValue
{
	return [self dateWithStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle] != nil;
}


/*!
 @method		-systemDateValue
 @abstract		Checks if the NSString is a valid system date.
 @discussion	This method attempts to parse the string using the current system's default date format
				(as determined by locale settings).
 @result		Returns `YES` if the string is a valid date in the system's default format, `NO` otherwise.
 */
- (NSDate *)systemDateValue
{
	return [self dateWithStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}


/*!
 @method		-isSystemTimeValue
 @abstract		Checks if the NSString is a valid system time.
 @discussion	This method attempts to parse the string using the current system's default time format
 				(as determined by locale settings).
 @result		Returns `YES` if the string is a valid date in the system's default format, `NO` otherwise.
 */
- (BOOL)isSystemTimeValue
{
	return [self dateWithStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle] != nil;
}


/*!
 @method		-systemTimeValue
 @abstract		Checks if the NSString is a valid system time.
 @discussion	This method attempts to parse the string using the current system's default time format
				(as determined by locale settings).
 @result		Returns `YES` if the string is a valid date in the system's default format, `NO` otherwise.
 */
- (NSDate *)systemTimeValue
{
	return [self dateWithStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}




/*!
 @method		-dateWithStyle:
 @abstract		Checks if the NSString is a date of a specific style.
 @discussion	Forwards to isDateStyle:timeStyle: with no timeStyle.
 @param			dateStyle	The style of date to check the string against.
 @result		Returns `YES` if the string is a valid date in the provided format, `NO` otherwise.
 */
- (NSDate *)dateWithStyle:(NSDateFormatterStyle)dateStyle
{
	return [self dateWithStyle:dateStyle timeStyle:NSDateFormatterNoStyle];
}


/*!
 @method		-isTimeStyle:
 @abstract		Checks if the NSString is a time of a specific style.
 @discussion	Forwards to @c isDateStyle:timeStyle:  with no dateStyle.
 @param			timeStyle	The style of time to check the string against.
 @result		Returns `YES` if the string is a valid time in the provided format, `NO` otherwise.
 */
- (NSDate *)timeWithStyle:(NSDateFormatterStyle)timeStyle
{
	return [self dateWithStyle:NSDateFormatterNoStyle timeStyle:timeStyle];
}


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
- (NSDate *)dateWithStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
	NSDateFormatter *formatter = NSDateFormatter.new;
	
	[formatter setDateStyle:dateStyle];
	[formatter setTimeStyle:timeStyle];
	
	// Return YES if the string is a valid date and matches the given format
	return [formatter dateFromString:self];
}


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
- (NSDate*)dateWithFormat:(nullable NSString *)strFormat
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	// Use the provided format or the system's default if format is nil
	if (strFormat) {
		[formatter setDateFormat:strFormat];
	} else {
		// Use the system's default date format
		[formatter setDateStyle:NSDateFormatterShortStyle];
		[formatter setTimeStyle:NSDateFormatterNoStyle];
	}
	
	// Attempt to parse the string as a date
	return [formatter dateFromString:self];
}

/*!
 @method		-objectAtIndexedSubscript
 @abstract		Provides Indexed Subscript for easy access to individual
				characters.
 @param			index The index of the character to access.
 @discussion	This makes NSStrings act more like C-Strings for accessing
				characters.
 @result		Returns a `unichar` of the character at that `index`.
 */
- (nullable NSNumber *)objectAtIndexedSubscript:(NSUInteger)index
{
	if (index < 0 || index >= self.length) {
		return nil;
	}
	return @([self characterAtIndex:index]);
}


- (nonnull NSString *)stringByInsertingString:(nonnull NSString*)aString atIndex:(NSUInteger)location
{
	return [self stringByReplacingCharactersInRange:NSMakeRange(location, 0) withString:aString];
}


- (nonnull NSString *)stringByPrependingString:(NSString * _Nonnull)aString
{
	if(!aString) {
		[NSException raise:NSInvalidArgumentException
								format:@"*** -[%@ %@]: nil argument",
									   NSString.className, NSStringFromSelector(_cmd)];
	} else if(![aString isKindOfClass:NSString.class]) {
		[NSException raise:NSInvalidArgumentException
								format:@"*** -[%@ %@]: Argument is not an NSString",
									   NSString.className, NSStringFromSelector(_cmd)];
	}
	return [aString stringByAppendingString:self];
}


- (nonnull NSString *)stringByPrependingFormat:(NSString * _Nonnull)format, ...
{
	if(!format) {
		[NSException raise:NSInvalidArgumentException
								format:@"*** -[%@ %@]: nil argument",
									   NSString.className, NSStringFromSelector(_cmd)];
	} else if(![format isKindOfClass:NSString.class]) {
		[NSException raise:NSInvalidArgumentException
								format:@"*** -[%@ %@]: Argument is not an NSString",
									   NSString.className, NSStringFromSelector(_cmd)];
	}
	va_list	args;
	va_start(args, format);
	NSString *aString = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	return [aString stringByAppendingString:self];
	
}
 
@end





@implementation NSMutableString (BExtension)

/*!
 @method		-prependString
 @abstract		Adds to the start of the receiver the characters of a given string.
 @param			aString The string to prepend to the receiver. aString must not be nil
 */
- (void)prependString:(nonnull NSString *)aString
{
	if(!aString) {
		[NSException raise:NSInvalidArgumentException
								format:@"*** -[%@ %@]: nil argument",
									   NSString.className, NSStringFromSelector(_cmd)];
	} else if(![aString isKindOfClass:NSString.class]) {
		[NSException raise:NSInvalidArgumentException
								format:@"*** -[%@ %@]: Argument is not an NSString",
									   NSString.className, NSStringFromSelector(_cmd)];
	}
	[self insertString:aString atIndex:0];
}


/*!
 @method		-prependFormat
 @abstract		Adds a constructed string to the start of the receiver.
 @param			format	A format string. See Formatting String Objects for more
 						information. This value must not be nil.
 
 @param			...		A comma-separated list of arguments to substitute into
 						format.
 */
- (void)prependFormat:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
	if(!format) {
		[NSException raise:NSInvalidArgumentException
								format:@"*** -[%@ %@]: nil argument",
									   NSString.className, NSStringFromSelector(_cmd)];
	} else if(![format isKindOfClass:NSString.class]) {
		[NSException raise:NSInvalidArgumentException
								format:@"*** -[%@ %@]: Argument is not an NSString",
									   NSString.className, NSStringFromSelector(_cmd)];
	}
	va_list args;
	va_start(args, format);
	NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
	[self insertString:formattedString atIndex:0];
}

/*!
 @method		-deleteAllCharacters
 @abstract		Removes all the characters and resets the string to @""
 */
- (void)deleteAll
{
	[self setString:@""];
}


/*!
 @method		-deleteAtIndex
 @abstract		Deletes the character in the string at the index
 @param			index The index of the character to delete.
 */
- (void)deleteAtIndex:(NSUInteger)index
{
	if (index < 0 || index >= self.length) {
		return;
	}
	[self deleteCharactersInRange:NSMakeRange(index, 1)];
}


@end
