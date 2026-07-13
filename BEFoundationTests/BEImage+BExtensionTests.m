/*!
 @file       BEImage+BExtensionTests.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @abstract   Cross-platform tests for the BEImage round-trip / resize conveniences.
 */

#import <XCTest/XCTest.h>
#import <BEFoundation/BEImage+BExtension.h>

@interface BEImageBExtensionTests : XCTestCase
@end

@implementation BEImageBExtensionTests

// A solid-red CGImage of the given pixel dimensions (caller releases).
- (CGImageRef)makeCGImageWidth:(size_t)w height:(size_t)h CF_RETURNS_RETAINED {
	CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(NULL, w, h, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
	CGContextSetRGBFillColor(ctx, 1, 0, 0, 1);
	CGContextFillRect(ctx, CGRectMake(0, 0, w, h));
	CGImageRef img = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	CGColorSpaceRelease(cs);
	return img;
}

- (BEImage *)imageWidth:(size_t)w height:(size_t)h {
	CGImageRef cg = [self makeCGImageWidth:w height:h];
	BEImage *img = [BEImage imageFromCGImage:cg];
	CGImageRelease(cg);
	return img;
}

#pragma mark - Data

- (void)testPngData_hasPNGSignature {
	NSData *png = [self imageWidth:4 height:4].pngRepresentation;
	XCTAssertNotNil(png);
	const unsigned char sig[4] = {0x89, 'P', 'N', 'G'};
	XCTAssertGreaterThan(png.length, 8u);
	XCTAssertEqual(memcmp(png.bytes, sig, 4), 0);
}

- (void)testJpegData_hasJPEGSignature {
	NSData *jpeg = [[self imageWidth:8 height:8] jpegRepresentationWithCompressionQuality:0.8];
	XCTAssertNotNil(jpeg);
	const unsigned char soi[2] = {0xFF, 0xD8};
	XCTAssertGreaterThan(jpeg.length, 2u);
	XCTAssertEqual(memcmp(jpeg.bytes, soi, 2), 0);
}

- (void)testJpegData_qualityClampedDoesNotCrash {
	XCTAssertNotNil([[self imageWidth:8 height:8] jpegRepresentationWithCompressionQuality:5.0]);   // clamped to 1
	XCTAssertNotNil([[self imageWidth:8 height:8] jpegRepresentationWithCompressionQuality:-3.0]);  // clamped to 0
}

#pragma mark - Size

- (void)testPixelSize {
	BEImage *img = [self imageWidth:10 height:20];
	XCTAssertEqual(img.pixelSize.width, 10);
	XCTAssertEqual(img.pixelSize.height, 20);
}

#pragma mark - Resize

- (void)testResizedToSize {
	BEImage *resized = [[self imageWidth:10 height:10] resizedToSize:CGSizeMake(8, 6)];
	XCTAssertNotNil(resized);
	XCTAssertEqual(resized.size.width, 8);
	XCTAssertEqual(resized.size.height, 6);
	// Force a render so the (lazy, on macOS) drawing actually executes.
	XCTAssertNotNil(resized.pngRepresentation);
}

- (void)testResizedToSize_emptyReturnsNil {
	XCTAssertNil([[self imageWidth:10 height:10] resizedToSize:CGSizeZero]);
	XCTAssertNil([[self imageWidth:10 height:10] resizedToSize:CGSizeMake(-4, 4)]);
}

- (void)testResizedToFit_preservesAspect {
	// 10×20 into 10×10  → scale 0.5  → 5×10
	BEImage *fit = [[self imageWidth:10 height:20] resizedToFitSize:CGSizeMake(10, 10)];
	XCTAssertEqual(fit.size.width, 5);
	XCTAssertEqual(fit.size.height, 10);
}

- (void)testResizedToFill_preservesAspect {
	// 10×20 into 30×30  → scale 3  → 30×60
	BEImage *fill = [[self imageWidth:10 height:20] resizedToFillSize:CGSizeMake(30, 30)];
	XCTAssertEqual(fill.size.width, 30);
	XCTAssertEqual(fill.size.height, 60);
}

- (void)testAspectResize_emptyBoundsReturnNil {
	XCTAssertNil([[self imageWidth:10 height:10] resizedToFitSize:CGSizeZero]);
	XCTAssertNil([[self imageWidth:10 height:10] resizedToFillSize:CGSizeZero]);
}

#pragma mark - CGImage/CIImage round-trips

- (void)testCGImageRoundTrip {
	BEImage *img = [self imageWidth:4 height:4];
	CGImageRef cg = img.CGImageRepresentation;
	XCTAssertTrue(cg != NULL);
	XCTAssertEqual(CGImageGetWidth(cg), 4u);
}

- (void)testCIImage_notNil {
	XCTAssertNotNil([self imageWidth:4 height:4].CIImageRepresentation);
}

- (void)testImageWithCIImage {
	CIImage *ci = [[CIImage imageWithColor:CIColor.redColor] imageByCroppingToRect:CGRectMake(0, 0, 4, 4)];
	BEImage *img = [BEImage imageFromCIImage:ci];
	XCTAssertNotNil(img);
	XCTAssertEqual(img.size.width, 4);
}

- (void)testNilInputsReturnNil {
	CGImageRef nilCGImage = NULL;
	CIImage *nilCIImage = nil;
	XCTAssertNil([BEImage imageFromCGImage:nilCGImage]);
	XCTAssertNil([BEImage imageFromCIImage:nilCIImage]);
}

#if TARGET_OS_OSX
- (void)testEmptyImageGracefullyNil {
	NSImage *empty = [[NSImage alloc] init];
	XCTAssertNil(empty.pngRepresentation);   // no bitmap rep
	XCTAssertTrue(empty.CGImageRepresentation == NULL);
	XCTAssertNil(empty.CIImageRepresentation);
	// CGImageRepresentation is NULL, so pixelSize falls back to self.size.
	XCTAssertEqual(empty.pixelSize.width, empty.size.width);
	XCTAssertEqual(empty.pixelSize.height, empty.size.height);
}

/*!
 @testcase testNilFactories_returnNilWithPencilKitLoaded
 @abstract The nil-input factory contract holds with PencilKit loaded.
 @discussion PencilKit attaches a private @c +[NSImage imageWithCGImage:] and @c -CGImage
			 category when it loads, and AppKit loads PencilKit lazily during window machinery
			 setup. The 1.0 members used those same UIImage spellings and were shadowed under
			 some load orders, returning a non-nil empty image for @c NULL in full-suite runs.
			 The 1.1 names do not overlap Apple's; this pins the contract in the shadowing
			 scenario.
 */
- (void)testNilFactories_returnNilWithPencilKitLoaded {
	NSBundle *pencilKit = [NSBundle bundleWithPath:@"/System/Library/Frameworks/PencilKit.framework"];
	XCTSkipIf(pencilKit == nil || ![pencilKit load], @"PencilKit unavailable on this system");
	XCTAssertNil([BEImage imageFromCGImage:NULL]);
	XCTAssertNil([BEImage imageFromCIImage:nil]);
}
#else

/*!
 @testcase testCIImageRepresentation_returnsBackingCIImage
 @abstract A CIImage-backed UIImage exposes its own CIImage through @c CIImageRepresentation.
 @discussion @c imageWithCIImage: yields a UIImage whose @c CIImage property is non-nil, so
			 @c CIImageRepresentation returns it directly rather than rebuilding one from a CGImage.
 */
- (void)testCIImageRepresentation_returnsBackingCIImage {
	CIImage *ci = [[CIImage imageWithColor:CIColor.redColor] imageByCroppingToRect:CGRectMake(0, 0, 4, 4)];
	UIImage *img = [UIImage imageFromCIImage:ci];
	XCTAssertNotNil(img.CIImage);
	XCTAssertEqualObjects(img.CIImageRepresentation, img.CIImage);
}
#endif

@end
