# NSString+BExtension

NSString Category extension providing numeric and date validation and stringValue compatibility.

```objc
#import <BEFoundation/NSString+BExtension.h>
```

## Overview

This category adds methods for checking if the string contains specific types of data (digits, integers, floats, dates, times) and provides `stringValue` to align with `NSNumber` for reading plist dictionaries.

## Usage

### String Value Compatibility

```objc
NSString *str = @"hello";

// Get string value (same as self for NSString)
NSString *value = str.stringValue;  // @"hello"

// Useful for generic dictionary reading
NSDictionary *dict = @{@"stringKey": @"stringValue", @"numberKey": @42};
// When iterating, you can safely call stringValue on both
```

### Numeric Validation

```objc
// Check if string is all digits
@"12345".isDigits;      // YES
@"12345a".isDigits;     // NO

// Check if string is a valid integer
@"42".isIntValue;       // YES
@"42.5".isIntValue;     // NO
@"-42".isIntValue;       // YES

// Check if string is a valid long
@"-9223372036854775807".isLongLongValue;  // YES

// Check if string is a valid unsigned long long
@"18446744073709551615".isUnsignedLongLongValue;  // YES

// Check if string is a valid float
@"3.14".isFloatValue;   // YES
@"3.14e10".isFloatValue;  // YES

// Check if string is a valid double
@"3.14159265358979".isDoubleValue;  // YES
```

### Date and Time Validation

```objc
// Check if string is a valid system date/time
@"2024-01-15 10:30:00".isSystemDateTimeValue;  // YES

// Get the date value
NSDate *date = @"2024-01-15 10:30:00".systemDateTimeValue;

// Check for specific date styles
NSDate *date = [@"01/15/2024" dateWithStyle:NSDateFormatterShortStyle];

// Check for specific time styles
NSDate *time = [@"10:30 AM" timeWithStyle:NSDateFormatterShortStyle];

// Check for date and time with specific styles
NSDate *dateTime = [@"01/15/2024 at 10:30 AM" dateWithStyle:NSDateFormatterMediumStyle 
                                                        timeStyle:NSDateFormatterShortStyle];

// Check for custom format
NSDate *custom = [@"2024-01-15" dateWithFormat:@"yyyy-MM-dd"];
```

### Character Counting

```objc
NSString *str = @"Hello World";

// Count characters in a character set
NSUInteger letterCount = [str countCharactersInSet:[NSCharacterSet letterCharacterSet]];

// Count in a range
NSUInteger count = [str countCharactersInSet:[NSCharacterSet whitespaceCharacterSet]
                                       range:NSMakeRange(0, 5)];
```

### Mutable String Operations

```objc
NSMutableString *str = [NSMutableString stringWithString:@"Hello"];

// Prepend strings
[str prependString:@"Say: "];
// str is now @"Say: Hello"

[str prependFormat:@"%@ ", @"Complete:"];
// str is now @"Complete: Say: Hello"

// Delete all characters
[str deleteAll];
// str is now @""

// Delete at index
[str setString:@"Hello World"];
[str deleteAtIndex:5];
// str is now @"Hello"
```

## See Also

- [NSDictionary+BExtension](doc:NSDictionary_BExtension)
- [NSArray+BExtension](doc:NSArray_BExtension)
