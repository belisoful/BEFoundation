/*!
 @header     CIImage+BExtension.h
 @copyright  © 2025 Delicense - @belisoful. All rights reserved.
 @date       2025-01-01
 @abstract   Provides convenience methods for creating and compositing `CIImage` objects.
 @discussion This category on `CIImage` simplifies common image processing tasks,
			 such as generating a `CIImage` from text with various attributes and
			 compositing two images together with alpha blending.
*/

#ifndef CIImage_BExtension_h
#define CIImage_BExtension_h

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <AppKit/AppKit.h> // For NSColor and NSFont

/*!
 @category   CIImage (BExtension)
 @abstract   Adds methods for text generation and image compositing.
 @discussion This category wraps Core Image filters to provide high-level methods for
			 creating an image from an `NSAttributedString` and for blending two
			 images using a source-over composite operation.
*/
@interface CIImage (BExtension)

/*!
 @method     createImageText:fontName:fontSize:angle:color:blur:position:
 @abstract   Generates a `CIImage` containing rendered text with specified attributes.
 @param      text The string to render into the image.
 @param      fontName The name of the font to use for the text (e.g., "Helvetica-Bold").
 @param      fontSize The point size of the font.
 @param      angle The rotation angle of the text in degrees.
 @param      color The color of the text.
 @param      blur The radius of the Gaussian blur to apply to the text image, in pixels.
 @param      position The translation offset (x, y) to apply to the text image.
 @discussion This method provides a convenient way to create a complex text-based image
			 by chaining together multiple Core Image filters for text generation,
			 transformation, and blurring.
 @return     A new `CIImage` object containing the rendered and styled text.
*/
+ (CIImage *)createImageText:(NSString *)text
					fontName:(NSString *)fontName
					fontSize:(CGFloat)fontSize
					   angle:(CGFloat)angle
					   color:(NSColor *)color
						blur:(CGFloat)blur
					position:(CGPoint)position;

/*!
 @method     combineImage:alpha:withImage:
 @abstract   Composites a top image over a bottom image with a specified alpha level.
 @param      topImage The `CIImage` to place on top.
 @param      topAlpha The opacity of the `topImage`, from 0.0 (transparent) to 1.0 (opaque).
 @param      bottomImage The `CIImage` to use as the background.
 @discussion This method uses the `CISourceOverCompositing` filter to blend the two
			 images. The alpha of the `topImage` is adjusted before compositing.
 @return     A new `CIImage` object representing the result of the composition.
*/
+ (CIImage *)combineImage:(CIImage *)topImage
					alpha:(CGFloat)topAlpha
				withImage:(CIImage *)bottomImage;

@end

#endif /* CIImage_BExtension_h */
