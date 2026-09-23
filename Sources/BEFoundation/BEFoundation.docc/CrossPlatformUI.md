# Cross-Platform UI

Color, view, and image conveniences that work on both macOS and iOS.

## Overview

Built on the type aliases in <doc:BEPlatformTypes>, these categories extend the real platform classes (`NSColor`/`UIColor`, `NSView`/`UIView`, `NSImage`/`UIImage`), so the same call sites compile and behave on both platforms. They cover hex colors, Auto Layout constraint helpers, and image round-trips and resizing.

`BEDotView` is a `BEView` subclass; one status-indicator dot renders on every supported platform.

## Articles

- <doc:BEPlatformTypes>
- <doc:BEColor_BExtension>
- <doc:BEColor_BEWebColor>
- <doc:BEView_BExtension>
- <doc:BEImage_BExtension>
- <doc:BEDotView>

## See Also

- <doc:ImagesAndMetal>
- <doc:AppKit>
