/*!
 @file			CIImage+BExtension.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Implementation of the CIImage text-generation and alpha-compositing conveniences.
*/

#import "BE_ARC.h"
#import <BEFoundation/CIImage+BExtension.h>

@implementation CIImage (BExtension)

/*!
	@method     +createImageText:fontName:fontSize:angle:color:blur:position:
	@abstract   Generates a CIImage containing rendered text with specified attributes.
	@param      text		The string to render into the image.
	@param      fontName	The name of the font to use for the text (e.g., "Helvetica-Bold").
	@param		fontSize	The point size of the font.
	@param		angle		The rotation angle of the text in degrees.
	@param      color 		The color of the text.
	@param      blur		The radius of the Gaussian blur to apply to the text image, in pixels.
	@param      position	The translation offset (x, y) to apply to the text image.
	@discussion	This method chains Core Image filters for text generation, transformation, and blurring.
	@return     A new CIImage containing the rendered and styled text, or nil if @c text or @c color is nil or text image generation fails. If @c fontName is nil or unrecognized, the system font of @c fontSize is used.
 */
+ (CIImage *)createImageText:(NSString *)text
					fontName:(NSString *)fontName
					fontSize:(CGFloat)fontSize
					   angle:(CGFloat)angle
					   color:(BEColor *)color
						blur:(CGFloat)blur
					position:(CGPoint)position {
	// text/color are required; a nil value in the attributes dictionary literal would raise.
	if (text == nil || color == nil) {
		return nil;
	}

	BEFont *font = [BEFont fontWithName:fontName size:fontSize];
	if (font == nil) {
		font = [BEFont systemFontOfSize:fontSize];
	}
	NSDictionary *attributes = @{
		NSFontAttributeName: font,
		NSForegroundColorAttributeName: color
	};
	NSAttributedString *attributedString = [[NSAttributedString alloc]
										  initWithString:text
										  attributes:attributes];

	CIFilter *textFilter = [CIFilter filterWithName:@"CIAttributedTextImageGenerator"];
	[textFilter setValue:attributedString forKey:@"inputText"];
	// inputScaleFactor is a scale multiplier, not a flag.
	[textFilter setValue:@(1.0) forKey:@"inputScaleFactor"];

	CIImage *textImage = textFilter.outputImage;
	if (textImage == nil) {
		return nil;
	}
	
	CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(angle * M_PI / 180.0);
	textImage = [textImage imageByApplyingTransform:rotationTransform];
	
	textImage = [textImage imageByApplyingTransform:CGAffineTransformMakeTranslation(position.x, position.y)];
	
	if (blur > 0) {
		CIFilter *gaussianBlur = [CIFilter filterWithName:@"CIGaussianBlur"];
		[gaussianBlur setValue:textImage forKey:kCIInputImageKey];
		[gaussianBlur setValue:@(blur) forKey:kCIInputRadiusKey];
		textImage = gaussianBlur.outputImage;
	}
	
	// Already autoreleased under MRC (an unmanaged expression under ARC); an extra
	// NARC_AUTORELEASE over-releases the unowned image.
	return textImage;
}

/*!
	@method     +combineImage:alpha:withImage:
	@abstract   Composites a top image over a bottom image with a specified alpha level.
	@param      topImage	The CIImage to place on top.
 	@param		topAlpha	The opacity of the topImage, from 0.0 (transparent) to 1.0 (opaque).
	@param      bottomImage	The CIImage to use as the background.
	@discussion	This method uses the CISourceOverCompositing filter to blend the two images. The
				top image's alpha channel is replaced with topAlpha via a CIColorMatrix before compositing.
	@return     A new CIImage representing the result of the composition, or nil if either image is nil. topAlpha is clamped to the range 0.0–1.0.
 */
+ (CIImage *)combineImage:(CIImage *)topImage
					alpha:(CGFloat)topAlpha
			   withImage:(CIImage *)bottomImage {
	if (topImage == nil || bottomImage == nil) {
		return nil;
	}

	// Clamp alpha to [0,1]; out-of-range values produce invalid premultiplied alpha.
	CGFloat clampedAlpha = topAlpha < 0.0 ? 0.0 : (topAlpha > 1.0 ? 1.0 : topAlpha);

	CIFilter *sourceOverFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
	[sourceOverFilter setValue:bottomImage forKey:kCIInputBackgroundImageKey];

	CIFilter *colorMatrix = [CIFilter filterWithName:@"CIColorMatrix"];
	[colorMatrix setValue:topImage forKey:kCIInputImageKey];
	[colorMatrix setValue:[CIVector vectorWithX:1 Y:0 Z:0 W:0] forKey:@"inputRVector"];
	[colorMatrix setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputGVector"];
	[colorMatrix setValue:[CIVector vectorWithX:0 Y:0 Z:1 W:0] forKey:@"inputBVector"];
	[colorMatrix setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:clampedAlpha] forKey:@"inputAVector"];

	[sourceOverFilter setValue:colorMatrix.outputImage forKey:kCIInputImageKey];

	// Already autoreleased under MRC (an unmanaged expression under ARC).
	return sourceOverFilter.outputImage;
}
@end
