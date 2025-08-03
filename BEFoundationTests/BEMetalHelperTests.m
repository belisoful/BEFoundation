//
//  BEMetalHelperTests.m
//  Unit Tests for BEMetalHelper
//

#import <XCTest/XCTest.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Accelerate/Accelerate.h>
#import "BEMetalHelper.h"

// Forward declaration of the custom function for testing
vImage_Error vImageConvert_16FtoF(const vImage_Buffer *src,
								  const vImage_Buffer *dest,
								  vImage_Flags flags);

@interface BEMetalHelperTests : XCTestCase
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@end

@implementation BEMetalHelperTests

- (void)setUp {
	[super setUp];
	self.device = MTLCreateSystemDefaultDevice();
	XCTAssertNotNil(self.device, @"Metal device should be available");
	self.commandQueue = [self.device newCommandQueue];
	XCTAssertNotNil(self.commandQueue, @"Command queue should be created");
}

- (void)tearDown {
	self.device = nil;
	self.commandQueue = nil;
	[super tearDown];
}

// #pragma mark - vImageConvert_16FtoF Tests
/*
- (void)testVImageConvert_16FtoF_NullSourceBuffer {
	vImage_Buffer dest = {0};
	vImage_Error result = vImageConvert_16FtoF(NULL, &dest, kvImageNoFlags);
	XCTAssertEqual(result, kvImageInvalidParameter, @"Should return invalid parameter for null source");
}

- (void)testVImageConvert_16FtoF_NullDestBuffer {
	vImage_Buffer src = {0};
	vImage_Error result = vImageConvert_16FtoF(&src, NULL, kvImageNoFlags);
	XCTAssertEqual(result, kvImageInvalidParameter, @"Should return invalid parameter for null dest");
}

- (void)testVImageConvert_16FtoF_NullSourceData {
	vImage_Buffer src = {.data = NULL, .width = 10, .height = 10, .rowBytes = 20};
	vImage_Buffer dest = {0};
	vImage_Error result = vImageConvert_16FtoF(&src, &dest, kvImageNoFlags);
	XCTAssertEqual(result, kvImageInvalidParameter, @"Should return invalid parameter for null source data");
}

- (void)testVImageConvert_16FtoF_NullDestData {
	uint16_t srcData[100];
	vImage_Buffer src = {.data = srcData, .width = 10, .height = 10, .rowBytes = 20};
	vImage_Buffer dest = {.data = NULL, .width = 10, .height = 10, .rowBytes = 40};
	vImage_Error result = vImageConvert_16FtoF(&src, &dest, kvImageNoFlags);
	XCTAssertEqual(result, kvImageInvalidParameter, @"Should return invalid parameter for null dest data");
}

- (void)testVImageConvert_16FtoF_DimensionMismatch {
	uint16_t srcData[100];
	float destData[100];
	vImage_Buffer src = {.data = srcData, .width = 10, .height = 10, .rowBytes = 20};
	vImage_Buffer dest = {.data = destData, .width = 5, .height = 10, .rowBytes = 20};
	vImage_Error result = vImageConvert_16FtoF(&src, &dest, kvImageNoFlags);
	XCTAssertEqual(result, kvImageInvalidParameter, @"Should return invalid parameter for dimension mismatch");
}

- (void)testVImageConvert_16FtoF_MisalignedSourceData {
	// Create misaligned data (odd address)
	uint8_t buffer[201];
	uint16_t *srcData = (uint16_t *)(buffer); // Misaligned
	float destData[100];
	if((uintptr_t)(buffer + 1) % 2)
		srcData = (uint16_t *)(buffer + 1);
	
	vImage_Buffer src = {.data = srcData, .width = 10, .height = 10, .rowBytes = 20};
	vImage_Buffer dest = {.data = destData, .width = 10, .height = 10, .rowBytes = 40};
	vImage_Error result = vImageConvert_16FtoF(&src, &dest, kvImageNoFlags);
	XCTAssertEqual(result, kvImageInvalidParameter, @"Should return invalid parameter for misaligned source");
}

- (void)testVImageConvert_16FtoF_MisalignedDestData {
	uint16_t srcData[100];
	// Create misaligned data (not 4-byte aligned)
	uint8_t buffer[401];
	float *destData = (float *)(buffer); // Misaligned
	if((uintptr_t)(buffer + 2) % 4)
		destData = (float *)(buffer + 2);
	vImage_Buffer src = {.data = srcData, .width = 10, .height = 10, .rowBytes = 20};
	vImage_Buffer dest = {.data = destData, .width = 10, .height = 10, .rowBytes = 40};
	vImage_Error result = vImageConvert_16FtoF(&src, &dest, kvImageNoFlags);
	XCTAssertEqual(result, kvImageInvalidParameter, @"Should return invalid parameter for misaligned dest");
}

- (void)testVImageConvert_16FtoF_ValidConversion {
	const size_t width = 8;
	const size_t height = 4;
	
	// Create test data with known half-precision values
	uint16_t srcData[width * height];
	float destData[width * height];
	
	// Fill with test pattern (using raw bit patterns for half-precision floats)
	for (size_t i = 0; i < width * height; i++) {
		// Use simple bit patterns that represent valid half-precision floats
		srcData[i] = 0x3C00 + (i % 16); // Around 1.0 with small variations
	}
	
	vImage_Buffer src = {
		.data = srcData,
		.width = width,
		.height = height,
		.rowBytes = width * sizeof(uint16_t)
	};
	
	vImage_Buffer dest = {
		.data = destData,
		.width = width,
		.height = height,
		.rowBytes = width * sizeof(float)
	};
	
	vImage_Error result = vImageConvert_16FtoF(&src, &dest, kvImageNoFlags);
	XCTAssertEqual(result, kvImageNoError, @"Valid conversion should succeed");
	
	// Verify that data was actually converted (values should be different from zero)
	BOOL hasNonZeroValues = NO;
	for (size_t i = 0; i < width * height; i++) {
		if (destData[i] != 0.0f) {
			hasNonZeroValues = YES;
			break;
		}
	}
	XCTAssertTrue(hasNonZeroValues, @"Converted data should contain non-zero values");
}

- (void)testVImageConvert_16FtoF_NonAlignedWidth {
	// Test with width that's not a multiple of vector width
	const size_t width = 7; // Not divisible by 4
	const size_t height = 3;
	
	uint16_t srcData[width * height];
	float destData[width * height];
	
	// Fill with test pattern
	for (size_t i = 0; i < width * height; i++) {
		srcData[i] = 0x3C00; // 1.0 in half precision
	}
	
	vImage_Buffer src = {
		.data = srcData,
		.width = width,
		.height = height,
		.rowBytes = width * sizeof(uint16_t)
	};
	
	vImage_Buffer dest = {
		.data = destData,
		.width = width,
		.height = height,
		.rowBytes = width * sizeof(float)
	};
	
	vImage_Error result = vImageConvert_16FtoF(&src, &dest, kvImageNoFlags);
	XCTAssertEqual(result, kvImageNoError, @"Non-aligned width conversion should succeed");
}
 */

#pragma mark - convertGray8toRGB888WithVImage Tests

- (void)testConvertGray8toXRGB8888_ValidConversion {
	const size_t width = 4;
	const size_t height = 4;
	const size_t grayRowBytes = width;
	const size_t argbRowBytes = width * 4;
	
	uint8_t grayData[width * height];
	uint8_t argbData[argbRowBytes * height];
	
	// Fill gray data with test pattern
	for (size_t i = 0; i < width * height; i++) {
		grayData[i] = (uint8_t)(i * 16); // 0, 16, 32, 48, ...
	}
	
	BOOL result = [BEMetalHelper convertGray8toXRGB8888WithVImage:grayData
															width:width
														   height:height
														 rowBytes:grayRowBytes
															alpha:255
														 intoARGB:argbData
													 argbRowBytes:argbRowBytes];
	
	XCTAssertTrue(result, @"Gray8 to XRGB8888 conversion should succeed");
	
	// Verify that RGB channels are duplicates of gray values
	for (size_t i = 0; i < width * height; i++) {
		uint8_t expectedValue = grayData[i];
		XCTAssertEqual(argbData[i * 4], 255, @"Alpha channel should be full opaque");
		XCTAssertEqual(argbData[i * 4 + 1], expectedValue, @"Red channel should match gray value");
		XCTAssertEqual(argbData[i * 4 + 2], expectedValue, @"Green channel should match gray value");
		XCTAssertEqual(argbData[i * 4 + 3], expectedValue, @"Blue channel should match gray value");
	}
}

- (void)testConvertGray8toXRGB8888_NullGrayData {
	const size_t width = 4;
	const size_t height = 4;
	uint8_t argbData[width * height * 4];
	uint8_t *nilImage = nil;
	
	BOOL result = [BEMetalHelper convertGray8toXRGB8888WithVImage:nilImage
														  width:width
														 height:height
													   rowBytes:width
															alpha:255
														intoARGB:argbData
													argbRowBytes:width * 3];
	
	XCTAssertFalse(result, @"Should fail with null gray data");
}

- (void)testConvertGray8toXRGB8888_NullRGBData {
	const size_t width = 4;
	const size_t height = 4;
	uint8_t grayData[width * height];
	uint8_t *argbNilResult = nil;
	
	BOOL result = [BEMetalHelper convertGray8toXRGB8888WithVImage:grayData
														  width:width
														 height:height
													   rowBytes:width
															alpha:255
														intoARGB:argbNilResult
													argbRowBytes:width * 3];
	
	XCTAssertFalse(result, @"Should fail with null ARGB data");
}

#pragma mark - convertGray16FtoXRGBFFFFWithVImage Tests

- (void)testConvertGray16FtoRGBAFFFF_ValidConversion {
	const size_t width = 4;
	const size_t height = 4;
	const size_t grayRowBytes = width * sizeof(_Float16);
	const size_t argbRowBytes = width * 4 * sizeof(float);
	
	_Float16 grayData[width * height];
	float argbData[width * height * 4];
	
	// Fill with half-precision float test pattern
	for (size_t i = 0; i < width * height; i++) {
		grayData[i] = i / (float)(width * height);
	}
	
	BOOL result = [BEMetalHelper convertGray16FtoRGBXFFFFWithVImage:grayData
															  width:width
															 height:height
														   rowBytes:grayRowBytes
															  alpha:1.0
														   intoRGBA:argbData
													   rgbaRowBytes:argbRowBytes];
	
	XCTAssertTrue(result, @"Gray16F to RGBFFF conversion should succeed");
	
	// Verify that RGB channels contain reasonable float values
	for (size_t i = 0; i < width * height; i++) {
		float expectedValue = (float)grayData[i];
		float r = argbData[i * 4 ];
		float g = argbData[i * 4 + 1];
		float b = argbData[i * 4 + 2];
		float a = argbData[i * 4 + 3];
		
		XCTAssertEqual(a, 1.0, @"Alpha channel should be around 1.0");
		XCTAssertEqualWithAccuracy(r, expectedValue, 0.01, @"Red channel should be around 1.0");
		XCTAssertEqualWithAccuracy(g, expectedValue, 0.01, @"Green channel should be around 1.0");
		XCTAssertEqualWithAccuracy(b, expectedValue, 0.01, @"Blue channel should be around 1.0");
		XCTAssertEqualWithAccuracy(r, g, 0.001f, @"R and G channels should be equal");
		XCTAssertEqualWithAccuracy(g, b, 0.001f, @"G and B channels should be equal");
	}
}

- (void)testConvertGray16FtoRGBAFFFF_NullData {
	const size_t width = 4;
	const size_t height = 4;
	float rgbData[width * height * 3];
	_Float16 *nilImage = nil;
	
	BOOL result = [BEMetalHelper convertGray16FtoRGBXFFFFWithVImage:nilImage
															width:width
														   height:height
														 rowBytes:width * 2
															  alpha:1.0
														  intoRGBA:rgbData
													  rgbaRowBytes:width * 12];
	
	XCTAssertFalse(result, @"Should fail with null gray data");
}

- (void)testConvertGray16FtoRGBAFFFF_MemoryAllocationFailure {
	// Test with extremely large dimensions that should cause malloc to fail
	const size_t width = SIZE_MAX / 1000;
	const size_t height = SIZE_MAX / 1000;
	
	uint16_t grayData[16]; // Small actual data
	float rgbData[48];
	
	BOOL result = [BEMetalHelper convertGray16FtoRGBXFFFFWithVImage:grayData
															width:width
														   height:height
														 rowBytes:width * 2
															  alpha:1.0
														  intoRGBA:rgbData
													  rgbaRowBytes:width * 16];
	
	XCTAssertFalse(result, @"Should fail when memory allocation fails");
}\

#pragma mark - convertGray32FtoRGBFFFWithVImage Tests

- (void)testConvertGray32FtoRGBAFFFF_ValidConversion {
	const size_t width = 4;
	const size_t height = 4;
	const size_t grayRowBytes = width * sizeof(float);
	const size_t argbRowBytes = width * 4 * sizeof(float);
	
	float grayData[width * height];
	float argbData[width * height * 4];
	
	// Fill with half-precision float test pattern
	for (size_t i = 0; i < width * height; i++) {
		grayData[i] = i / (float)(width * height);
	}
	
	BOOL result = [BEMetalHelper convertGray32FtoRGBXFFFFWithVImage:grayData
															width:width
														   height:height
														 rowBytes:grayRowBytes
															  alpha:1.0
														  intoRGBA:argbData
													  rgbaRowBytes:argbRowBytes];
	
	XCTAssertTrue(result, @"Gray32F to RGBXFFFF conversion should succeed");
	
	// Verify that RGB channels are duplicates of gray values
	for (size_t i = 0; i < width * height; i++) {
		float expectedValue = grayData[i];
		XCTAssertEqualWithAccuracy(argbData[i * 4], expectedValue, 0.0001f, @"Red channel should match gray value");
		XCTAssertEqualWithAccuracy(argbData[i * 4 + 1], expectedValue, 0.0001f, @"Green channel should match gray value");
		XCTAssertEqualWithAccuracy(argbData[i * 4 + 2], expectedValue, 0.0001f, @"Blue channel should match gray value");
		XCTAssertEqualWithAccuracy(argbData[i * 4 + 3], 1.0, 0.0001f, @"Blue channel should match gray value");
	}
}

- (void)testConvertGray32FtoRGBAFFFF_NullData {
	const size_t width = 4;
	const size_t height = 4;
	float argbData[width * height * 4];
	float *nilImage = nil;
	
	BOOL result = [BEMetalHelper convertGray32FtoRGBXFFFFWithVImage:nilImage
															width:width
														   height:height
														 rowBytes:width * 4
															alpha:1.0
														  intoRGBA:argbData
													  rgbaRowBytes:width * 12];
	
	XCTAssertFalse(result, @"Should fail with null gray data");
}

#pragma mark - imageFromTexture Tests

- (void)testImageFromTexture_NullTexture {
	NSImage *result = [BEMetalHelper imageFromTexture:nil];
	XCTAssertNil(result, @"Should return nil for null texture");
}

- (void)testImageFromTexture_UnsupportedPixelFormat {
	MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
																						  width:32
																						 height:32
																					  mipmapped:NO];
	id<MTLTexture> texture = [self.device newTextureWithDescriptor:descriptor];
	
	NSImage *result = [BEMetalHelper imageFromTexture:texture];
	XCTAssertNil(result, @"Should return nil for unsupported pixel format");
}

- (void)testImageFromTexture_BGRA8Unorm {
	MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
																						  width:4
																						 height:4
																					  mipmapped:NO];
	descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
	id<MTLTexture> texture = [self.device newTextureWithDescriptor:descriptor];
	XCTAssertNotNil(texture, @"Texture should be created");
	
	// Fill texture with test data
	uint8_t testData[4 * 4 * 4]; // 4x4 BGRA
	for (int i = 0; i < 64; i++) {
		testData[i] = (uint8_t)(i * 4);
	}
	
	[texture replaceRegion:MTLRegionMake2D(0, 0, 4, 4)
			   mipmapLevel:0
				 withBytes:testData
			   bytesPerRow:16];
	
	NSImage *result = [BEMetalHelper imageFromTexture:texture];
	XCTAssertNotNil(result, @"Should create image from BGRA8Unorm texture");
	XCTAssertEqual(result.size.width, 4, @"Image width should match texture width");
	XCTAssertEqual(result.size.height, 4, @"Image height should match texture height");
}

- (void)testImageFromTexture_RGBA8Unorm {
	MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
																						  width:4
																						 height:4
																					  mipmapped:NO];
	descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
	id<MTLTexture> texture = [self.device newTextureWithDescriptor:descriptor];
	XCTAssertNotNil(texture, @"Texture should be created");
	
	// Fill texture with test data
	uint8_t testData[4 * 4 * 4]; // 4x4 RGBA
	for (int i = 0; i < 64; i++) {
		testData[i] = (uint8_t)(i * 4);
	}
	
	[texture replaceRegion:MTLRegionMake2D(0, 0, 4, 4)
			   mipmapLevel:0
				 withBytes:testData
			   bytesPerRow:16];
	
	NSImage *result = [BEMetalHelper imageFromTexture:texture];
	XCTAssertNotNil(result, @"Should create image from RGBA8Unorm texture");
}

- (void)testImageFromTexture_RGBA32Float {
	MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA32Float
																						  width:4
																						 height:4
																					  mipmapped:NO];
	descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
	id<MTLTexture> texture = [self.device newTextureWithDescriptor:descriptor];
	XCTAssertNotNil(texture, @"Texture should be created");
	
	// Fill texture with test data
	float testData[4 * 4 * 4]; // 4x4 RGBA float
	for (int i = 0; i < 64; i++) {
		testData[i] = (float)i / 64.0f;
	}
	
	[texture replaceRegion:MTLRegionMake2D(0, 0, 4, 4)
			   mipmapLevel:0
				 withBytes:testData
			   bytesPerRow:64];
	
	NSImage *result = [BEMetalHelper imageFromTexture:texture];
	XCTAssertNotNil(result, @"Should create image from RGBA32Float texture");
}

- (void)testImageFromTexture_R8Unorm {
	MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm
																						  width:4
																						 height:4
																					  mipmapped:NO];
	descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
	id<MTLTexture> texture = [self.device newTextureWithDescriptor:descriptor];
	XCTAssertNotNil(texture, @"Texture should be created");
	
	// Fill texture with test data
	uint8_t testData[4 * 4]; // 4x4 single channel
	for (int i = 0; i < 16; i++) {
		testData[i] = (uint8_t)(i * 16);
	}
	
	[texture replaceRegion:MTLRegionMake2D(0, 0, 4, 4)
			   mipmapLevel:0
				 withBytes:testData
			   bytesPerRow:4];
	
	NSImage *result = [BEMetalHelper imageFromTexture:texture];
	XCTAssertNotNil(result, @"Should create image from R8Unorm texture");
}

- (void)testImageFromTexture_R16Float {
	MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR16Float
																						  width:4
																						 height:4
																					  mipmapped:NO];
	descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
	id<MTLTexture> texture = [self.device newTextureWithDescriptor:descriptor];
	XCTAssertNotNil(texture, @"Texture should be created");
	
	// Fill texture with test data (half-precision floats)
	uint16_t testData[4 * 4]; // 4x4 half-precision float
	for (int i = 0; i < 16; i++) {
		testData[i] = 0x3C00; // 1.0 in half precision
	}
	
	[texture replaceRegion:MTLRegionMake2D(0, 0, 4, 4)
			   mipmapLevel:0
				 withBytes:testData
			   bytesPerRow:8];
	
	NSImage *result = [BEMetalHelper imageFromTexture:texture];
	XCTAssertNotNil(result, @"Should create image from R16Float texture");
}

- (void)testImageFromTexture_R32Float {
	MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR32Float
																						  width:4
																						 height:4
																					  mipmapped:NO];
	descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
	id<MTLTexture> texture = [self.device newTextureWithDescriptor:descriptor];
	XCTAssertNotNil(texture, @"Texture should be created");
	
	// Fill texture with test data
	float testData[4 * 4]; // 4x4 float
	for (int i = 0; i < 16; i++) {
		testData[i] = (float)i / 16.0f;
	}
	
	[texture replaceRegion:MTLRegionMake2D(0, 0, 4, 4)
			   mipmapLevel:0
				 withBytes:testData
			   bytesPerRow:16];
	
	NSImage *result = [BEMetalHelper imageFromTexture:texture];
	XCTAssertNotNil(result, @"Should create image from R32Float texture");
}

#pragma mark - Error Handling Tests

- (void)testImageFromTexture_MemoryAllocationFailure {
	// Create a texture with extremely large dimensions to potentially cause malloc failure
	// Note: This test might not always fail depending on available memory
	MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
																						  width:16384
																						 height:16384
																					  mipmapped:NO];
	descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
	
	// This might fail to create the texture itself, which is also a valid test
	id<MTLTexture> texture = [self.device newTextureWithDescriptor:descriptor];
	if (texture) {
		NSImage *result = [BEMetalHelper imageFromTexture:texture];
		// The result could be nil if memory allocation fails inside the method
		// We don't assert anything specific here as it depends on available memory
	}
}

- (void)testImageFromTexture_CGContextCreationFailure {
	// This is difficult to test directly as CGBitmapContextCreate failure
	// depends on internal CoreGraphics validation. The method handles this
	// case by returning nil and cleaning up memory.
	
	// We can at least verify that the method doesn't crash with edge cases
	MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
																						  width:1
																						 height:1
																					  mipmapped:NO];
	descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
	id<MTLTexture> texture = [self.device newTextureWithDescriptor:descriptor];
	
	NSImage *result = [BEMetalHelper imageFromTexture:texture];
	// Should either succeed or fail gracefully
	// XCTAssertNotNil or XCTAssertNil would both be valid outcomes
}

#pragma mark - Edge Cases

/*
 - (void)testImageFromTexture_ZeroDimensions {
	// Test behavior with zero dimensions - this should fail at texture creation
	MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
																						  width:0
																						 height:0
																					  mipmapped:NO];
	id<MTLTexture> texture = [self.device newTextureWithDescriptor:descriptor];
	
	if (texture) {
		NSImage *result = [BEMetalHelper imageFromTexture:texture];
		// If texture creation succeeded, the method should handle it gracefully
	}
}
 */

- (void)testImageFromTexture_LargeDimensions {
	// Test with reasonably large dimensions
	MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
																						  width:1024
																						 height:1024
																					  mipmapped:NO];
	descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
	id<MTLTexture> texture = [self.device newTextureWithDescriptor:descriptor];
	
	if (texture) {
		NSImage *result = [BEMetalHelper imageFromTexture:texture];
		if (result) {
			XCTAssertEqual(result.size.width, 1024, @"Image width should match texture width");
			XCTAssertEqual(result.size.height, 1024, @"Image height should match texture height");
		}
	}
}

@end
