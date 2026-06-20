# NSDateFormatterRFC3339

RFC 3339 date formatting support for NSDateFormatter.

```objc
#import <BEFoundation/NSDateFormatter+RFC3339.h>
```

## Overview

This category adds convenience methods to `NSDateFormatter` for working with RFC 3339 formatted dates. RFC 3339 is a profile of ISO 8601 commonly used in web APIs and JSON data interchange.

## Usage

### Creating RFC 3339 Formatters

```objc
// Create a new RFC 3339 formatter
NSDateFormatter *formatter = [NSDateFormatter rfc3339DateFormatter];

// Configure an existing formatter
NSDateFormatter *existing = [[NSDateFormatter alloc] init];
[existing rfc3339Format];
```

### Formatting Dates

```objc
NSDateFormatter *formatter = [NSDateFormatter rfc3339DateFormatter];

// Format a date
NSDate *date = [NSDate date];
NSString *formatted = [formatter stringFromDate:date];
// Output: @"2024-01-15T10:30:00Z"
```

### Parsing Dates

```objc
NSDateFormatter *formatter = [NSDateFormatter rfc3339DateFormatter];

// Parse an RFC 3339 string
NSString *rfc3339String = @"2024-01-15T10:30:00Z";
NSDate *date = [formatter dateFromString:rfc3339String];
```

> Note: The fixed format accepts whole-second timestamps with a `Z` (upper or lower case) or a
> numeric offset (`+00:00`, `-08:00`). It does **not** accept three optional RFC 3339 productions —
> each returns `nil` from `dateFromString:`:
>
> - **Fractional seconds** — `2024-01-15T10:30:00.5Z`. Append `.SSS` to the format if you need
>   sub-second precision.
> - **§5.6 separator alternatives** — a space or a lowercase `t` for the `T`: `2024-01-15 10:30:00Z`,
>   `2024-01-15t10:30:00Z`. (The zone designator *is* case-insensitive, so lowercase `z` works.)
> - **Leap second** (`:60`) — `2016-12-31T23:59:60Z`.
>
> Hours are restricted to `00`–`23` (no ISO 8601 `24:00`), and trailing content after the timestamp
> is rejected.

### RFC 3339 Format Details

The RFC 3339 format uses:
- Date format: `yyyy-MM-dd'T'HH:mm:ssZZZZZ`
- Timezone: UTC (GMT+0)
- Locale: en_US_POSIX (prevents localization issues)

Example formats:
- `2024-01-15T10:30:00Z`
- `2024-01-15T10:30:00+00:00`
- `2024-01-15T10:30:00-05:00`

## See Also

- [FxTime](doc:FxTime)
