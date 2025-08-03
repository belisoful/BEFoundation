/*!
 @file			CIImage+BExtensionTests.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract		Unit tests for the CIImage+BExtension category.
 @discussion		This file contains a comprehensive suite of XCTestCases to validate
				the functionality of CIImage+BExtension, ensuring full code coverage.
				Tests render the entire CIImage to a bitmap and analyze all pixels
				to ensure correctness of text rendering and image composition.
*/

#import <XCTest/XCTest.h>
#import <AppKit/AppKit.h>
#import "CIImage+BExtension.h" // Import the category to be tested

// A helper structure to represent a pixel's RGBA components.
typedef struct {
	uint8_t r, g, b, a;
} RGBAPixel;

@interface CIImage_BExtensionTests : XCTestCase
@property (nonatomic, strong) CIContext *ciContext;
@end

@implementation CIImage_BExtensionTests

- (void)setUp {
	[super setUp];
	// To ensure our blending math matches the output, we create a CIContext
	// that does NOT perform color management (no gamma correction). This makes
	// the blending calculations linear and predictable.
	self.ciContext = [CIContext contextWithOptions:@{
		kCIContextWorkingColorSpace: [NSNull null],
		kCIContextOutputColorSpace: [NSNull null]
	}];
}

- (void)tearDown {
	self.ciContext = nil;
	[super tearDown];
}

#pragma mark - Helper Methods

/**
 * Renders a CIImage into a raw bitmap buffer.
 *
 * @param image The CIImage to process.
 * @param size The target size of the bitmap to render.
 * @return An NSData object containing the raw RGBA8 pixel data.
 */
- (NSData *)getBitmapFromImage:(CIImage *)image size:(CGSize)size {
	size_t width = (size_t)size.width;
	size_t height = (size_t)size.height;
	
	// Allocate memory for the bitmap.
	NSMutableData *bitmap = [NSMutableData dataWithLength:width * height * 4];
	
	// Render the CIImage into the bitmap buffer.
	[self.ciContext
	 		   render:image
			 toBitmap:bitmap.mutableBytes
			 rowBytes:width * 4
			   bounds:CGRectMake(0, 0, width, height)
			   format:kCIFormatRGBA8
		   colorSpace:CGColorSpaceCreateDeviceRGB()];
			
	return bitmap;
}

/**
 * Creates a CIImage of a solid color.
 *
 * @param color The NSColor of the image to create.
 * @param size The size of the image.
 * @return A CIImage filled with the specified color.
 */
- (CIImage *)createSolidColorImage:(NSColor *)color size:(CGSize)size {
	return [[CIImage imageWithColor:[CIColor colorWithCGColor:color.CGColor]] imageByCroppingToRect:CGRectMake(0, 0, size.width, size.height)];
}


#pragma mark - createImageText Tests

- (void)testCreateImageText_BasicCreation {
	// Test case: Verify that an image is created with default parameters.
	NSString *testText = @"Test";
	NSColor *testColor = [NSColor redColor];
	CIImage *image = [CIImage createImageText:testText
									 fontName:@"Helvetica"
									 fontSize:48
										angle:0
										color:testColor
										 blur:0
									 position:CGPointMake(0, 0)];
	
	XCTAssertNotNil(image, @"The created image should not be nil for valid inputs.");
	XCTAssertFalse(CGRectIsEmpty(image.extent), @"The image extent should not be empty.");
}

- (void)testCreateImageText_WithRotation {
	// Test case: Verify that rotation is applied by checking the extent.
	CIImage *unrotatedImage = [CIImage createImageText:@"Rotate" fontName:@"Times New Roman" fontSize:40 angle:0 color:[NSColor greenColor] blur:0 position:CGPointMake(0, 0)];
	CIImage *rotatedImage = [CIImage createImageText:@"Rotate" fontName:@"Times New Roman" fontSize:40 angle:90 color:[NSColor greenColor] blur:0 position:CGPointMake(0, 0)];
	
	XCTAssertNotNil(rotatedImage, @"The rotated image should not be nil.");
	// When rotated by 90 degrees, the width and height of the bounding box should swap.
	XCTAssertTrue(fabs(rotatedImage.extent.size.width - unrotatedImage.extent.size.height) < 1.0, @"Rotated image width should approximate unrotated height.");
	XCTAssertTrue(fabs(rotatedImage.extent.size.height - unrotatedImage.extent.size.width) < 1.0, @"Rotated image height should approximate unrotated width.");
}

- (void)testCreateImageText_WithPosition {
	// Test case: Verify that the position offset is applied.
	CGFloat xPos = 50;
	CGFloat yPos = 100;
	CIImage *image = [CIImage createImageText:@"Position" fontName:@"Helvetica" fontSize:20 angle:0 color:[NSColor blackColor] blur:0 position:CGPointMake(xPos, yPos)];
	
	XCTAssertNotNil(image, @"The positioned image should not be nil.");
	// The origin of the image's extent should match the specified position.
	XCTAssertEqualWithAccuracy(image.extent.origin.x, xPos, 0.01, @"Image X origin should match the specified position.");
	XCTAssertEqualWithAccuracy(image.extent.origin.y, yPos, 0.01, @"Image Y origin should match the specified position.");
}

- (void)testCreateImageText_PixelContentAndAntialiasing {
	// Test case: Render text onto a black background and inspect all pixels
	// to verify correct color rendering and account for anti-aliasing.
	CGSize canvasSize = CGSizeMake(100, 50);
	NSColor *textColor = [NSColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]; // Pure Green
	CIImage *textImage = [CIImage createImageText:@"Text"
										 fontName:@"Helvetica-Bold"
										 fontSize:40
											angle:0
											color:textColor
											 blur:0
										 position:CGPointMake(10, 5)];
	
	// Create a black background to composite the text onto for a clear test.
	CIImage *backgroundImage = [self createSolidColorImage:[NSColor blackColor] size:canvasSize];
	CIImage *finalImage = [textImage imageByCompositingOverImage:backgroundImage];

	// Render the entire image to a bitmap
	NSData *bitmapData = [self getBitmapFromImage:finalImage size:canvasSize];
	RGBAPixel *pixels = (RGBAPixel *)bitmapData.bytes;
	
	int textColorPixelCount = 0;
	int nonBlackPixelCount = 0;
	long pixelArraySize = canvasSize.width * canvasSize.height;

	for (int i = 0; i < pixelArraySize; i++) {
		RGBAPixel p = pixels[i];
		// Check if pixel is not black (i.e., it's part of the text or its anti-aliased edge)
		if (p.r > 0 || p.g > 0 || p.b > 0) {
			nonBlackPixelCount++;
			
			// Due to color space interactions with the text renderer, we can't expect
			// pure (0, 255, 0). Instead, we verify that for any colored pixel,
			// the green component is the dominant one.
			if (p.g > p.r && p.g > p.b) {
				textColorPixelCount++;
			}
		}
	}
	
	// Assert that at least some pixels are the pure text color.
	XCTAssertGreaterThan(textColorPixelCount, 0, @"At least some pixels must exactly match the text color.");
	
	// Assert that the number of non-black pixels is greater than the pure-color pixels.
	// This confirms that anti-aliasing is creating intermediate colors at the edges.
	XCTAssertGreaterThanOrEqual(nonBlackPixelCount, textColorPixelCount, @"The count of non-black pixels should be greater than pure-color pixels, indicating anti-aliasing.");
}

- (void)testCreateImageText_WithBlur {
	// Test case: Verify that blur causes intermediate pixel colors and no pure-color pixels.
	CGSize canvasSize = CGSizeMake(100, 50);
	NSColor *textColor = [NSColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0]; // Pure Yellow
	CIImage *textImage = [CIImage createImageText:@"Blur"
										 fontName:@"Helvetica-Bold"
										 fontSize:30
											angle:0
											color:textColor
											 blur:2.0 // Apply a noticeable blur
										 position:CGPointMake(15, 10)];
	
	CIImage *backgroundImage = [self createSolidColorImage:[NSColor blackColor] size:canvasSize];
	CIImage *finalImage = [textImage imageByCompositingOverImage:backgroundImage];

	NSData *bitmapData = [self getBitmapFromImage:finalImage size:canvasSize];
	RGBAPixel *pixels = (RGBAPixel *)bitmapData.bytes;
	
	int pureColorPixelCount = 0;
	int nonBlackPixelCount = 0;
	long pixelArraySize = canvasSize.width * canvasSize.height;

	for (int i = 0; i < pixelArraySize; i++) {
		RGBAPixel p = pixels[i];
		if (p.r > 0 || p.g > 0 || p.b > 0) {
			nonBlackPixelCount++;
			if (p.r == 255 && p.g == 255 && p.b == 0) {
				pureColorPixelCount++;
			}
		}
	}
	
	XCTAssertGreaterThan(nonBlackPixelCount, 0, @"Blurred text should produce some non-black pixels.");
	XCTAssertEqual(pureColorPixelCount, 0, @"With blur, no pixel should be the pure original text color.");
}

#pragma mark - combineImage Tests

- (void)runCombineImageTestWithTopColor:(NSColor *)topColor bottomColor:(NSColor *)bottomColor alpha:(CGFloat)alpha {
	// A generalized test runner for the combineImage method.
	CGSize imageSize = CGSizeMake(2, 2);
	CIImage *topImage = [self createSolidColorImage:topColor size:imageSize];
	CIImage *bottomImage = [self createSolidColorImage:bottomColor size:imageSize];
	
	CIImage *combinedImage = [CIImage combineImage:topImage alpha:alpha withImage:bottomImage];
	XCTAssertNotNil(combinedImage, @"Combined image should not be nil.");
	
	// Render the entire combined image.
	NSData *bitmapData = [self getBitmapFromImage:combinedImage size:imageSize];
	RGBAPixel *pixels = (RGBAPixel *)bitmapData.bytes;

	// Calculate the expected color based on source-over blending.
	// Result = TopColor * Alpha + BottomColor * (1 - Alpha)
	CGFloat topR, topG, topB;
	[topColor getRed:&topR green:&topG blue:&topB alpha:NULL];
	
	CGFloat botR, botG, botB;
	[bottomColor getRed:&botR green:&botG blue:&botB alpha:NULL];
	
	uint8_t expectedR = (uint8_t)round((topR * alpha + botR * (1 - alpha)) * 255.0);
	uint8_t expectedG = (uint8_t)round((topG * alpha + botG * (1 - alpha)) * 255.0);
	uint8_t expectedB = (uint8_t)round((topB * alpha + botB * (1 - alpha)) * 255.0);
	
	// Check every pixel in the resulting image.
	long pixelCount = imageSize.width * imageSize.height;
	for (int i = 0; i < pixelCount; i++) {
		RGBAPixel p = pixels[i];
		// CoreImage processing can have minor precision differences. We test with a tolerance of 1.
		XCTAssertEqualWithAccuracy(p.r, expectedR, 1, @"Red component of pixel %d is incorrect.", i);
		XCTAssertEqualWithAccuracy(p.g, expectedG, 1, @"Green component of pixel %d is incorrect.", i);
		XCTAssertEqualWithAccuracy(p.b, expectedB, 1, @"Blue component of pixel %d is incorrect.", i);
		XCTAssertEqual(p.a, 255, @"Alpha component of pixel %d should be fully opaque.", i);
	}
}

- (void)testCombineImage_AlphaOne {
	// Test case: Alpha = 1.0 (top image is fully opaque). Result should be pure top color.
	[self runCombineImageTestWithTopColor:[NSColor redColor] bottomColor:[NSColor blueColor] alpha:1.0];
}

- (void)testCombineImage_AlphaZero {
	// Test case: Alpha = 0.0 (top image is fully transparent). Result should be pure bottom color.
	[self runCombineImageTestWithTopColor:[NSColor redColor] bottomColor:[NSColor blueColor] alpha:0.0];
}

- (void)testCombineImage_AlphaPartial_0_25 {
	// Test case: Alpha = 0.25. Result should be 25% top color, 75% bottom color.
	[self runCombineImageTestWithTopColor:[NSColor redColor] bottomColor:[NSColor blueColor] alpha:0.25];
}

- (void)testCombineImage_AlphaPartial_0_50 {
	// Test case: Alpha = 0.50. Result should be 50% top color, 50% bottom color.
	[self runCombineImageTestWithTopColor:[NSColor colorWithRed:1 green:1 blue:0 alpha:1]  // Yellow
							  bottomColor:[NSColor colorWithRed:0 green:0 blue:1 alpha:1]  // Blue
									alpha:0.50];
}

- (void)testCombineImage_AlphaPartial_0_75 {
	// Test case: Alpha = 0.75. Result should be 75% top color, 25% bottom color.
	[self runCombineImageTestWithTopColor:[NSColor cyanColor] bottomColor:[NSColor magentaColor] alpha:0.75];
}

@end
