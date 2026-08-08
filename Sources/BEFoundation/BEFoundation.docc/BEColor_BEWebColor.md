# BEColor+BEWebColor

The 141 CSS/SVG color keywords, as constants, colors, and name lookups on `BEColor`.

## Overview

```objc
#import <BEFoundation/BEColor+BEWebColor.h>
```

Every keyword is available three ways — a class property, a lookup by name, and a string
constant to pass around:

```objc
BEColor *sky  = BEColor.webDeepSkyBlue;                              // class property
BEColor *same = [BEColor webColorNamed:@"deepskyblue"];              // lookup
BEColor *also = [BEColor webColorNamed:BEWebColorNameDeepSkyBlue];   // constant
```

Prefer the `BEWebColorName…` constants over string literals: a typo in a literal is a runtime
`nil`, a typo in a constant is a compile error.

Colors are built through ``BEColor/colorWithHexString:``, so each is opaque sRGB and
round-trips through ``BEColor/hexString`` exactly.

## The `web` prefix

The prefix is not decoration. `NSColor` and `UIColor` already own `redColor`, `blueColor`,
and the rest, and Swift maps those to `NSColor.red` and friends — so a bare `+red` on a
category would collide with the name Swift already uses. Prefixing every accessor keeps the
whole set unambiguous on both platforms and in both languages. The repository's
`CATEGORY_NAMING.md` records the wider policy and why it exists.

## Looking a color up by name

Matching ignores case and surrounding whitespace, so a value read from a file or a user
setting resolves without normalizing it first. Inner spaces are not part of a keyword.

```objc
[BEColor webColorNamed:@"Tomato"];      // the color
[BEColor webColorNamed:@"  tOmAtO \n"]; // the same color
[BEColor webColorNamed:@"deep sky blue"];  // nil — not a keyword
[BEColor webColorNamed:@"NotAColor"];      // nil
```

## Naming a color

``BEColor/webColorNameForColor:`` goes the other way. The match is exact, not nearest: a
color one component away from a keyword returns `nil`.

```objc
[BEColor webColorNameForColor:BEColor.webRebeccaPurple];                  // @"RebeccaPurple"
[BEColor webColorNameForColor:[BEColor colorWithHexString:@"#010203"]];   // nil
```

Four keywords are aliases of two values — `Aqua`/`Cyan` and `Fuchsia`/`Magenta`. The earlier
keyword in ``BEColor/webColorNames`` wins, so the answer is stable across calls.

## Enumerating the set

```objc
for (NSString *name in BEColor.webColorNames) {
    BEColor *color = BEColor.webColors[name];
}
```

`webColorNames` is ordered as the CSS specification lists the keywords: the 16 original HTML
names first, then the extended set grouped by hue.

## Topics

### Lookup

- ``BEColor/webColorNamed:``
- ``BEColor/webColorNameForColor:``
- ``BEColor/webColorNames``
- ``BEColor/webColors``

## See Also

- <doc:BEColor_BExtension>
- <doc:BEDotView>
- <doc:CrossPlatformUI>
