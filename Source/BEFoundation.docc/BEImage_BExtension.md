# BEImage+BExtension

`CGImage`/`CIImage`/data round-trips and resizing for `NSImage` (macOS) and `UIImage` (iOS).

```objc
#import <BEFoundation/BEImage+BExtension.h>
```

## Overview

`BEImage` is a cross-platform alias (`NSImage` / `UIImage` — see <doc:BEPlatformTypes>). `UIImage` exposes `CGImage`, `CIImage`, `+imageWithCGImage:`, `+imageWithCIImage:`, and PNG/JPEG encoding; `NSImage` does not, and getting bytes out of an `NSImage` and resizing it are both awkward. This category provides one API for those operations, plus pixel size and resizing, on both platforms.

The round-trip and data members use representation-style names (`imageFromCGImage:`, `pngRepresentation`, following the `TIFFRepresentation` idiom) rather than UIImage's spellings, renamed in 1.1 from the 1.0 UIImage-parity names. Apple frameworks attach private same-named category methods to these classes at runtime (PencilKit, when loaded, adds `+[NSImage imageWithCGImage:]` and `-CGImage`), and which duplicate method wins is undefined, so a category on a framework class must not reuse Apple's method names. The factories return `nil` for a `NULL`/`nil` input on both platforms.

![A 240×140 source image resized into the same 132×132 box two ways: resizedToFitSize: letterboxes the whole image, while resizedToFillSize: covers the box and crops.](beimage-resize)

## Usage

### Round-trips

```objc
CGImageRef cg = image.CGImageRepresentation;
BEImage *fromCG = [BEImage imageFromCGImage:cg];
NSData  *png = image.pngRepresentation;
NSData  *jpg = [image jpegRepresentationWithCompressionQuality:0.8];
```

### Size and resizing

```objc
CGSize px = image.pixelSize;                          // CGImage pixels (macOS) or point size × scale (iOS)
BEImage *exact = [image resizedToSize:CGSizeMake(128, 128)];
BEImage *fit   = [image resizedToFitSize:CGSizeMake(256, 256)];   // aspect-preserving, fits inside
BEImage *fill  = [image resizedToFillSize:CGSizeMake(256, 256)];  // aspect-preserving, covers
```

## See Also

- <doc:BEPlatformTypes>
- <doc:CIImage_BExtension>
- <doc:CrossPlatformUI>
