# BEPlatformTypes

Cross-platform aliases for the AppKit/UIKit types BEFoundation uses on both macOS and iOS.

```objc
#import <BEFoundation/BEPlatformTypes.h>
```

## Overview

BEFoundation builds for both macOS (AppKit) and iOS (UIKit). A handful of types are spelled differently on each platform. These `@compatibility_alias` declarations give each a single BEFoundation spelling that resolves to the right platform class at compile time — so the same source compiles and runs on both, and a category declared on `BEColor` is really a category on `NSColor` (macOS) or `UIColor` (iOS).

| BEFoundation | macOS | iOS |
| --- | --- | --- |
| `BEColor` | `NSColor` | `UIColor` |
| `BEImage` | `NSImage` | `UIImage` |
| `BEFont` | `NSFont` | `UIFont` |
| `BEView` | `NSView` | `UIView` |
| `BEEdgeInsets` | `NSEdgeInsets` | `UIEdgeInsets` |

Because these are compile-time aliases (not wrapper classes), they produce no extra runtime types and can be used interchangeably with the native names: `[NSColor colorWithHexString:…]` and `[BEColor colorWithHexString:…]` are the same method on macOS.

## Usage

```objc
BEColor *c = [BEColor colorWithHexString:@"#3498DB"];
BEImage *thumb = [icon resizedToFitSize:CGSizeMake(64, 64)];
[panel pinEdgesToSuperviewWithInsets:BEEdgeInsetsMake(12, 12, 12, 12)];
```

## See Also

- <doc:CrossPlatformUI>
- <doc:BEColor_BExtension>
- <doc:BEImage_BExtension>
- <doc:BEView_BExtension>
