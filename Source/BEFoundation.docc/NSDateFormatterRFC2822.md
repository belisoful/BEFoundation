# NSDateFormatterRFC2822

RFC 2822 date formatting support for NSDateFormatter.

```objc
#import <BEFoundation/NSDateFormatter+RFC2822.h>
```

## Overview

This category adds convenience methods to `NSDateFormatter` for working with RFC 2822 formatted dates. RFC 2822 (Internet Message Format) defines the date format used in email headers — and, near-identically, in HTTP and RSS — derived from RFC 822. It is unrelated to ISO 8601; for ISO 8601 / Internet timestamps use <doc:NSDateFormatterRFC3339> instead.

## Usage

### Creating RFC 2822 Formatters

```objc
// Create a new RFC 2822 formatter
NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];

// Configure an existing formatter
NSDateFormatter *existing = [[NSDateFormatter alloc] init];
[existing rfc2822Format];
```

### Formatting Dates

```objc
NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];

// Format a date
NSDate *date = [NSDate date];
NSString *formatted = [formatter stringFromDate:date];
// Output: @"Mon, 23 Jun 2025 14:45:30 +0000"
```

### Parsing Dates

```objc
NSDateFormatter *formatter = [NSDateFormatter rfc2822DateFormatter];

// Parse an RFC 2822 string (the offset is honored: -0800 -> 22:45:30 UTC)
NSDate *date = [formatter dateFromString:@"Mon, 23 Jun 2025 14:45:30 -0800"];
```

> Note: This fixed format requires the leading weekday and a numeric zone offset. A string without
> the weekday (`23 Jun 2025 …`) or with an obsolete alphabetic zone (`… GMT` / `… EST`) will not
> parse (`dateFromString:` returns `nil`). The weekday is required but not validated against the
> date — an inconsistent weekday (e.g. `Tue` for a Monday) is silently accepted. Comments / folding
> whitespace (CFWS) are not supported: a real email header like `… +0000 (UTC)` will not parse, so
> strip any trailing comment first.

### RFC 2822 Format Details

The RFC 2822 format uses:
- Date format: `EEE, dd MMM yyyy HH:mm:ss Z`
- Timezone: UTC (GMT+0)
- Locale: en_US_POSIX (ensures the English weekday/month names RFC 2822 requires)

Example formats:
- `Mon, 23 Jun 2025 14:45:30 +0000`
- `Mon, 23 Jun 2025 06:45:30 -0800`

## See Also

- <doc:NSDateFormatterRFC3339>
