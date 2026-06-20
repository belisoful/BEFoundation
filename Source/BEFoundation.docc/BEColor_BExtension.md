# BEColor+BExtension

Hex parsing/formatting and appearance-aware colors for `NSColor` (macOS) and `UIColor` (iOS).

```objc
#import <BEFoundation/BEColor+BExtension.h>
```

## Overview

`BEColor` is a cross-platform alias (`NSColor` on macOS, `UIColor` on iOS — see <doc:BEPlatformTypes>). This category adds hex support, which neither platform ships, and a one-call light/dark dynamic color. Because it is a category on the real class, the methods are available on every `NSColor`/`UIColor` — system colors, asset-catalog colors, and your own — through either name.

![Hex parsing of 3/4/6/8-digit strings into color swatches, and a dynamic color that resolves to a different swatch in light and dark appearances.](becolor-hex)

## Usage

### Hex colors

```objc
// Parse: optional # or 0x, 3/4/6/8 digits (alpha last, CSS-style), case- and whitespace-tolerant.
BEColor *red   = [BEColor colorWithHexString:@"#FF0000"];
BEColor *green = [BEColor colorWithHexString:@"0f0"];          // shorthand → #00FF00
BEColor *amber = [BEColor colorWithHexString:@"#FFBF0080"];    // 50% alpha

// Format (always via sRGB, never raises on non-RGB colors):
NSString *hex      = red.hexString;             // "#FF0000"
NSString *hexAlpha = amber.hexStringWithAlpha;  // "#FFBF0080"
```

### Appearance-aware colors

```objc
// Resolves automatically to the right variant in light vs. dark mode when drawn.
BEColor *label = [BEColor dynamicColorWithLight:[BEColor colorWithHexString:@"#111111"]
                                           dark:[BEColor colorWithHexString:@"#EEEEEE"]];
```

## See Also

- <doc:BEPlatformTypes>
- <doc:CrossPlatformUI>
