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
	@abstract   This generates an image with the specified text, font name, font size, angle, color, blur, and position.
	@param      text		The text to render.
	@param      fontName	The font name of the font the text is rendered with.
	@param		fontSize	The font size of the font the text is rendered with.
	@param		angle		The angle of the text.
	@param      color 		The color of the text to render
	@param      blur		The blur, in pixels, applied to the text.
	@param      position	The position of the text to be rendered.
	@discussion	This is a compound function to generate text in a specific font, size, angle, color, blur, and position.
	@result     Returns a CIImage containing the rendered text, or nil if @c text or @c color is nil or text image generation fails.
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

	// Fall back to the system font when fontName is nil or unrecognized.
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

	// Create CIAttributedText filter
	CIFilter *textFilter = [CIFilter filterWithName:@"CIAttributedTextImageGenerator"];
	[textFilter setValue:attributedString forKey:@"inputText"];
	// inputScaleFactor is a scale multiplier, not a flag.
	[textFilter setValue:@(1.0) forKey:@"inputScaleFactor"];

	CIImage *textImage = textFilter.outputImage;
	if (textImage == nil) {
		return nil;
	}
	
	// Apply rotation transform
	CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(angle * M_PI / 180.0);
	textImage = [textImage imageByApplyingTransform:rotationTransform];
	
	// Apply position transform
	textImage = [textImage imageByApplyingTransform:CGAffineTransformMakeTranslation(position.x, position.y)];
	
	// Apply Gaussian blur if blur value is not zero
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
	@abstract   This combines two images with the topImage having an alpha over the bottomImage.
	@param      topImage	The image composited on top.
 	@param		topAlpha	The opacity applied to topImage, from 0.0 (transparent) to 1.0 (opaque).
	@param      bottomImage	The background image composited underneath.
	@discussion	Adjusts the alpha of topImage via CIColorMatrix, then composites it over
				bottomImage using CISourceOverCompositing.
	@result     Returns a CIImage containing the combined images, or nil if either image is nil.
 */
+ (CIImage *)combineImage:(CIImage *)topImage
					alpha:(CGFloat)topAlpha
			   withImage:(CIImage *)bottomImage {
	if (topImage == nil || bottomImage == nil) {
		return nil;
	}

	// Clamp alpha to [0,1]; out-of-range values produce invalid premultiplied alpha.
	CGFloat clampedAlpha = topAlpha < 0.0 ? 0.0 : (topAlpha > 1.0 ? 1.0 : topAlpha);

	// Create source over compositing filter
	CIFilter *sourceOverFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
	[sourceOverFilter setValue:bottomImage forKey:kCIInputBackgroundImageKey];

	// Create color matrix filter for alpha adjustment
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
