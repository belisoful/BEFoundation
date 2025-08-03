/*!
 @file			BEMetalHelper.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/

#import "BEMetalHelper.h"



@implementation BEMetalHelper


+ (BOOL)convertGray8toXRGB8888WithVImage:(const uint8_t *)grayData
								   width:(size_t)width
								  height:(size_t)height
								rowBytes:(size_t)grayRowBytes
								   alpha:(uint8_t)alpha
								intoARGB:(uint8_t *)argbData
							argbRowBytes:(size_t)argbRowBytes
{
	if (!grayData || !argbData || width <= 0 || height <= 0 || grayRowBytes <= 0 || argbRowBytes <= 0) {
		return NO;
	}
	
	// Prepare vImage buffers
	vImage_Buffer srcGray = {
		.data = (void *)grayData,
		.height = height,
		.width = width,
		.rowBytes = grayRowBytes
	};

	// All channels are duplicated from gray, except alpha
	vImage_Buffer dstARGB = {
		.data = argbData,
		.height = height,
		.width = width,
		.rowBytes = argbRowBytes
	};

	// Grayscale duplicated to R, G, B channels
	vImage_Error err = vImageConvert_Planar8ToXRGB8888(
		alpha,
		&srcGray, // Red
		&srcGray, // Green
		&srcGray, // Blue
		&dstARGB,
		kvImageNoFlags
	);

	return err == kvImageNoError;
}

+ (BOOL)convertGray16FtoRGBXFFFFWithVImage:(const void *)grayData
									 width:(size_t)width
									height:(size_t)height
								  rowBytes:(size_t)grayRowBytes
									 alpha:(float)alpha
								  intoRGBA:(float *)rgbaData
							  rgbaRowBytes:(size_t)rgbaRowBytes
{
	if (!grayData || !rgbaData || width <= 0 || height <= 0 || grayRowBytes <= 0 || rgbaRowBytes <= 0) {
		return NO;
	}
	
	// Create intermediate 32-bit float buffer
	size_t float32RowBytes = width * sizeof(float);
	float *tempFloat32 = malloc(height * float32RowBytes);
	if (!tempFloat32) return NO;
	
	// Step 1: Convert 16F to 32F
	vImage_Buffer src16F = {
		.data = (void *)grayData,
		.height = height,
		.width = width,
		.rowBytes = grayRowBytes
	};
	
	vImage_Buffer temp32F = {
		.data = tempFloat32,
		.height = height,
		.width = width,
		.rowBytes = float32RowBytes
	};
	
	vImage_Error err = vImageConvert_Planar16FtoPlanarF(&src16F, &temp32F, kvImageNoFlags);
	if (err != kvImageNoError) {
		free(tempFloat32);
		return NO;
	}
	
	// Step 2: Convert single channel 32F to RGB 32F
	vImage_Buffer dstRGBA = {
		.data = rgbaData,
		.height = height,
		.width = width,
		.rowBytes = rgbaRowBytes
	};
	
	err = vImageConvert_PlanarFToRGBXFFFF(
		&temp32F, // Red channel
		&temp32F, // Green channel
		&temp32F, // Blue channel
		alpha,
		&dstRGBA,
		kvImageNoFlags
	);
	
	free(tempFloat32);
	return err == kvImageNoError;
}

+ (BOOL)convertGray32FtoRGBXFFFFWithVImage:(const void *)grayData
									 width:(size_t)width
									height:(size_t)height
								  rowBytes:(size_t)grayRowBytes
									 alpha:(float)alpha
								  intoRGBA:(float *)rgbaData
							  rgbaRowBytes:(size_t)rgbaRowBytes
{
	if (!grayData || !rgbaData || width <= 0 || height <= 0 || grayRowBytes <= 0 || rgbaRowBytes <= 0) {
		return NO;
	}
	vImage_Buffer src32F = {
		.data = (void *)grayData,
		.height = height,
		.width = width,
		.rowBytes = grayRowBytes
	};
	
	// Step 2: Convert single channel 32F to RGB 32F
	vImage_Buffer dstARGB = {
		.data = rgbaData,
		.height = height,
		.width = width,
		.rowBytes = rgbaRowBytes
	};
	
	vImage_Error err = vImageConvert_PlanarFToRGBXFFFF(
		&src32F, // Red channel
		&src32F, // Green channel
		&src32F, // Blue channel
		alpha,
		&dstARGB,
		kvImageNoFlags
	);
	
	return err == kvImageNoError;
}


+ (nullable NSImage *)imageFromTexture:(id<MTLTexture>)texture
{
	if (!texture) {
		return nil;
	}

	NSUInteger width = texture.width;
	NSUInteger height = texture.height;

	NSUInteger bytesPerPixel = 0;
	NSUInteger bitsPerComponent = 0;
	CGBitmapInfo bitmapInfo = 0;
	BOOL needsConversion = NO;
	BOOL isFloat = NO;

	void *imageBytes = NULL;
	NSUInteger imageBytesPerRow = 0;

	switch (texture.pixelFormat) {
		case MTLPixelFormatBGRA8Unorm:
			bitsPerComponent = 8;
			bytesPerPixel = 4;
			bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little;
			break;

		case MTLPixelFormatRGBA8Unorm:
			bitsPerComponent = 8;
			bytesPerPixel = 4;
			bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
			break;

		case MTLPixelFormatRGBA32Float:
			bitsPerComponent = 32;
			bytesPerPixel = 16;	// R G B A
			bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapFloatComponents;
			isFloat = YES;
			break;

			
		case MTLPixelFormatR8Unorm:
			bitsPerComponent = 8;
			bytesPerPixel = 1;
			bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
			needsConversion = YES;
			break;
		case MTLPixelFormatR16Float:
			bitsPerComponent = 16;
			bytesPerPixel = 2;
			bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapFloatComponents;
			needsConversion = YES;
			break;
		case MTLPixelFormatR32Float:
			bitsPerComponent = 32;
			bytesPerPixel = 4;
			bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapFloatComponents;
			needsConversion = YES;
			break;

		default:
			NSLog(@"Unsupported texture format: %lu", (unsigned long)texture.pixelFormat);
			return nil;
	}

	imageBytesPerRow = bytesPerPixel * width;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear);
	if (!colorSpace) {
		return nil;
	}
	
	imageBytes = malloc(height * imageBytesPerRow);
	if (!imageBytes) {
		return nil;
	}
	
	[texture getBytes:imageBytes
			 bytesPerRow:imageBytesPerRow
			  fromRegion:MTLRegionMake2D(0, 0, width, height)
			 mipmapLevel:0];
	
	NSUInteger argbBytesPerRow;
	void *argbBytes;
	switch (texture.pixelFormat) {
		case MTLPixelFormatR8Unorm:
			argbBytesPerRow = 4 * width;
			argbBytes = malloc(height * argbBytesPerRow);
			[BEMetalHelper convertGray8toXRGB8888WithVImage:imageBytes
													  width:width
													 height:height
												   rowBytes:imageBytesPerRow
													  alpha:255
													intoARGB:argbBytes
												argbRowBytes:argbBytesPerRow];
			free(imageBytes);
			imageBytes = argbBytes;
			imageBytesPerRow = argbBytesPerRow;
			bytesPerPixel = 4;
			break;
		case MTLPixelFormatR16Float:
			argbBytesPerRow = 16 * width;
			argbBytes = malloc(height * argbBytesPerRow);
			[BEMetalHelper convertGray16FtoRGBXFFFFWithVImage:imageBytes
													  width:width
													 height:height
												   rowBytes:imageBytesPerRow
													  alpha:1.0
												    intoRGBA:argbBytes
											    rgbaRowBytes:argbBytesPerRow];
			free(imageBytes);
			imageBytes = argbBytes;
			imageBytesPerRow = argbBytesPerRow;
			bitsPerComponent = 32;
			bytesPerPixel = 16;
			break;
		case MTLPixelFormatR32Float:
			argbBytesPerRow = 16 * width;
			argbBytes = malloc(height * argbBytesPerRow);
			[BEMetalHelper convertGray32FtoRGBXFFFFWithVImage:imageBytes
													  width:width
													 height:height
												   rowBytes:imageBytesPerRow
													  alpha:1.0
													intoRGBA:argbBytes
												rgbaRowBytes:argbBytesPerRow];
			free(imageBytes);
			imageBytes = argbBytes;
			imageBytesPerRow = argbBytesPerRow;
			bitsPerComponent = 32;
			bytesPerPixel = 16;
			break;
		default: break;
	}

	CGContextRef context = CGBitmapContextCreate(imageBytes,
												 width,
												 height,
												 bitsPerComponent,
												 imageBytesPerRow,
												 colorSpace,
												 bitmapInfo);
	CGColorSpaceRelease(colorSpace);

	if (!context) {
		NSLog(@"Failed to create CGContext.");
		free(imageBytes);
		return nil;
	}

	CGImageRef cgImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	free(imageBytes);
 
	if (!cgImage) {
		return nil;
	}
	
	NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size:NSMakeSize(width, height)];
	CGImageRelease(cgImage);
	return image;
}


@end
