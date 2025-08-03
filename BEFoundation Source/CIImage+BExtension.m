/*!
 @file			CIImage+BExtension.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract
 @discussion
*/

#import "BE_ARC.h"
#import <BEFoundation/CIImage+BExtension.h>

@implementation CIImage (BExtension)

/*!
	@class   	CIImage (BExtension)
	@abstract   This adds creating a CIImage containing attributed text and easily
				combining two images.
	@discussion	This wraps the creation of a text CIImage into a handy method and
				easily combining two images with an alpha transparency of the top image.
				These are useful for, eg, FxPlug Effects.
 */

/*!
	@method     -createImageText:fontName:fontSize:angle:color:blur:position:
	@abstract   This generates an image with the specified text, font name, font size, angle, color, blur, and position.
	@param      text		The text to render.
	@param      fontName	The font name of the font the text is rendered with.
	@param		fontSize	The font size of the font the text is rendered with.
	@param		angle		The angle of the text.
	@param      color 		The color of the text to render
	@param      blur		The blur, in pixels, applied to the text.
	@param      position	The position of the text to be rendered..
	@discussion	This is a compound function to generate text in a specific font, size, angle, color, blur, and position..
	@result     This method returns a CIImage containing the rendered text.
 */
+ (CIImage *)createImageText:(NSString *)text
					fontName:(NSString *)fontName
					fontSize:(CGFloat)fontSize
					   angle:(CGFloat)angle
					   color:(NSColor *)color
						blur:(CGFloat)blur
					position:(CGPoint)position {
	// Create an NSAttributedString with the specified font
	NSFont *font = [NSFont fontWithName:fontName size:fontSize];
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
	[textFilter setValue:@(YES) forKey:@"inputScaleFactor"];
	
	CIImage *textImage = textFilter.outputImage;
	
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
	
	return NARC_AUTORELEASE(textImage);
}

/*!
	@method     -combineImage:withImage:alpha:
	@abstract   This combines two images with the topImage having an alpha over the bottomImage.
	@param      topImage	The topImage .
 	@param		topAlpha	The font size of the font the text is rendered with.
	@param      bottomImage	The font name of the font the text is rendered with.
	@discussion	This is a compound function to generate text in a specific font, size, angle, color, blur, and position..
	@result     This method returns a CIImage containing the combined images.
 */
+ (CIImage *)combineImage:(CIImage *)topImage
					alpha:(CGFloat)topAlpha
			   withImage:(CIImage *)bottomImage {
	// Create source over compositing filter
	CIFilter *sourceOverFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
	[sourceOverFilter setValue:bottomImage forKey:kCIInputBackgroundImageKey];
	
	// Create color matrix filter for alpha adjustment
	CIFilter *colorMatrix = [CIFilter filterWithName:@"CIColorMatrix"];
	[colorMatrix setValue:topImage forKey:kCIInputImageKey];
	[colorMatrix setValue:[CIVector vectorWithX:1 Y:0 Z:0 W:0] forKey:@"inputRVector"];
	[colorMatrix setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputGVector"];
	[colorMatrix setValue:[CIVector vectorWithX:0 Y:0 Z:1 W:0] forKey:@"inputBVector"];
	[colorMatrix setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:topAlpha] forKey:@"inputAVector"];
	
	[sourceOverFilter setValue:colorMatrix.outputImage forKey:kCIInputImageKey];
	
	return NARC_AUTORELEASE(sourceOverFilter.outputImage);
}
@end
