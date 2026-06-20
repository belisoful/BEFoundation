# CIImage+BExtension

Convenience methods for creating and compositing CIImage objects.

```objc
#import <BEFoundation/CIImage+BExtension.h>
```

## Overview

This category on `CIImage` provides high-level methods for creating images from text and compositing two images together with alpha blending using Core Image filters.

![A text image created with createImageText: composited over a gradient background with combineImage:alpha:withImage:.](ciimage-text-composite)

## Usage

### Creating Text Images

```objc
// Create a text image
CIImage *textImage = [CIImage createImageText:@"Hello World"
                                   fontName:@"Helvetica-Bold"
                                   fontSize:48.0
                                      angle:0
                                      color:BEColor.whiteColor
                                       blur:2.0
                                   position:CGPointMake(0, 0)];
```

### Image Composition

```objc
// Composite two images with alpha
CIImage *topImage = /* ... */;
CIImage *bottomImage = /* ... */;

CIImage *composited = [CIImage combineImage:topImage
                                   alpha:0.5
                               withImage:bottomImage];
```

### Text Image Parameters

| Parameter | Description |
|----------|-------------|
| `text` | The string to render |
| `fontName` | Font name (e.g., "Helvetica-Bold", "Arial") |
| `fontSize` | Point size of the font |
| `angle` | Rotation angle in degrees |
| `color` | Text color |
| `blur` | Gaussian blur radius in pixels (0 for no blur) |
| `position` | Translation offset (x, y) |

## See Also

- <doc:BEMetalHelper>
