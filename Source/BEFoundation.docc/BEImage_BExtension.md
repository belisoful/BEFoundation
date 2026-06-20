# BEImage+BExtension

`CGImage`/`CIImage`/data round-trips and resizing for `NSImage` (macOS) and `UIImage` (iOS).

```objc
#import <BEFoundation/BEImage+BExtension.h>
```

## Overview

`BEImage` is a cross-platform alias (`NSImage` / `UIImage` — see <doc:BEPlatformTypes>). `UIImage` already exposes `CGImage`, `CIImage`, `+imageWithCGImage:` and `+imageWithCIImage:`; `NSImage` does not, and getting bytes out of an `NSImage` and resizing it are both awkward. This category brings `NSImage` up to that parity (those four members are macOS-only here) and adds PNG/JPEG export, pixel size, and resizing to both platforms.

![A 240×140 source image resized into the same 132×132 box two ways: resizedToFitSize: letterboxes the whole image, while resizedToFillSize: covers the box and crops.](beimage-resize)

## Usage

### Round-trips

```objc
CGImageRef cg = image.CGImage;                 // (macOS: new; iOS: built-in)
BEImage *fromCG = [BEImage imageWithCGImage:cg];
NSData  *png = image.pngData;
NSData  *jpg = [image jpegDataWithCompressionQuality:0.8];
```

### Size and resizing

```objc
CGSize px = image.pixelSize;                          // point size × scale
BEImage *exact = [image resizedToSize:CGSizeMake(128, 128)];
BEImage *fit   = [image resizedToFitSize:CGSizeMake(256, 256)];   // aspect-preserving, fits inside
BEImage *fill  = [image resizedToFillSize:CGSizeMake(256, 256)];  // aspect-preserving, covers
```

## See Also

- <doc:BEPlatformTypes>
- <doc:CIImage_BExtension>
- <doc:CrossPlatformUI>
