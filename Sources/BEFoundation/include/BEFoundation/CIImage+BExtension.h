/*!
 @header     CIImage+BExtension.h
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @date       2025-01-01
 @author	 belisoful@icloud.com
 @abstract   Provides convenience methods for creating and compositing `CIImage` objects.
 @discussion This category on `CIImage` simplifies common image processing tasks,
			 such as generating a `CIImage` from text with various attributes and
			 compositing two images together with alpha blending.
*/

#ifndef CIImage_BExtension_h
#define CIImage_BExtension_h

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <BEFoundation/BEPlatformTypes.h> // BEColor / BEFont

NS_ASSUME_NONNULL_BEGIN

/*!
 @category   CIImage (BExtension)
 @abstract   Adds methods for text generation and image compositing.
 @discussion This category wraps Core Image filters to provide high-level methods for
			 creating an image from an `NSAttributedString` and for blending two
			 images using a source-over composite operation.

			 @code
			 // Render a label, then composite it at 80% over a background image.
			 CIImage *label = [CIImage createImageText:@"Frame 01"
											  fontName:@"Helvetica-Bold"
											  fontSize:48.0
												 angle:0.0
												 color:BEColor.whiteColor
												  blur:0.0
											  position:CGPointMake(40, 40)];

			 CIImage *result = [CIImage combineImage:label
											   alpha:0.8
										   withImage:background];
			 @endcode
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
 @discussion This method chains Core Image filters for text generation, transformation,
			 and blurring.

			 Geometry note: rotation is applied about the image origin (0,0), not the text
			 center, and `position` is then applied as a translation in image space after the
			 rotation. For a non-zero `angle`, the final placement is therefore the rotated
			 bounding box offset by `position`. For predictable placement with rotation, rotate
			 about the text center yourself before calling, or use `angle:0` and position the
			 result.
 @return     A new `CIImage` object containing the rendered and styled text, or nil if
			 text image generation fails. `text` and `color` are nonnull; a nil value passed
			 anyway returns nil. If `fontName` is nil
			 or unrecognized, the system font of `fontSize` is used.
*/
+ (nullable CIImage *)createImageText:(NSString *)text
							 fontName:(nullable NSString *)fontName
							 fontSize:(CGFloat)fontSize
								angle:(CGFloat)angle
								color:(BEColor *)color
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

			 The top image's alpha channel is replaced with `topAlpha` (via a
			 CIColorMatrix whose A-vector is `(0,0,0,topAlpha)`). This is intended for opaque
			 source images (the common effect-compositing case). If `topImage` is already
			 translucent, its per-pixel alpha is discarded and the
			 whole image is composited at the uniform `topAlpha`.
 @return     A new `CIImage` object representing the result of the composition. The image
			 parameters are nonnull; a nil value passed anyway returns nil. `topAlpha` is
			 clamped to the range 0.0 to 1.0.
*/
+ (nullable CIImage *)combineImage:(CIImage *)topImage
							alpha:(CGFloat)topAlpha
						withImage:(CIImage *)bottomImage;

@end

NS_ASSUME_NONNULL_END

#endif /* CIImage_BExtension_h */
