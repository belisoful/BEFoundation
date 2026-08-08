# ``BEMetalHelper``

Utilities for Metal texture processing and image conversion operations.

```objc
#import <BEFoundation/BEMetalHelper.h>
```

## Overview

[BEMetalHelper](doc:BEMetalHelper) provides static methods for converting Metal textures to `BEImage` objects (`NSImage` on macOS, `UIImage` on iOS — see <doc:BEPlatformTypes>) and performing efficient grayscale to RGB color space conversions using Apple's vImage framework.

## Usage

### Converting Textures to Images

```objc
#import <Metal/Metal.h>

// Get a Metal texture from your rendering pipeline
id<MTLTexture> texture = /* ... */;

// Convert to a BEImage (NSImage on macOS, UIImage on iOS)
BEImage *image = [BEMetalHelper imageFromTexture:texture];
```

### Supported Pixel Formats

The `imageFromTexture:` method supports:
- `BGRA8Unorm`
- `RGBA8Unorm`
- `RGBA32Float`
- `R8Unorm` (converted to RGB)
- `R16Float` (converted to RGB)
- `R32Float` (converted to RGB)

### Grayscale Conversion

```objc
// Convert 8-bit grayscale to XRGB8888
uint8_t *grayData = /* ... */;
size_t width = 1920;
size_t height = 1080;
size_t grayRowBytes = width;

uint8_t *argbData = malloc(width * height * 4);
size_t argbRowBytes = width * 4;

BOOL success = [BEMetalHelper convertGray8toXRGB8888WithVImage:grayData
                                                        width:width
                                                       height:height
                                                     rowBytes:grayRowBytes
                                                        alpha:255
                                                     intoARGB:argbData
                                                 argbRowBytes:argbRowBytes];
```

### Half-Float Conversion

```objc
// Convert 16-bit half-precision float grayscale to RGBX FFFF
const void *grayData = /* ... */;
float *rgbaData = malloc(width * height * 16);

BOOL success = [BEMetalHelper convertGray16FtoRGBXFFFFWithVImage:grayData
                                                           width:width
                                                          height:height
                                                        rowBytes:grayRowBytes
                                                           alpha:1.0
                                                        intoRGBA:rgbaData
                                                    rgbaRowBytes:rgbaRowBytes];
```

### Float Conversion

```objc
// Convert 32-bit float grayscale to RGBX FFFF
const void *grayData = /* ... */;
float *rgbaData = malloc(width * height * 16);

BOOL success = [BEMetalHelper convertGray32FtoRGBXFFFFWithVImage:grayData
                                                           width:width
                                                          height:height
                                                        rowBytes:grayRowBytes
                                                           alpha:1.0
                                                        intoRGBA:rgbaData
                                                    rgbaRowBytes:rgbaRowBytes];
```

## See Also

- [CIImage+BExtension](doc:CIImage_BExtension)
