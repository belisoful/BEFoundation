/*!
 @file       BEImage+BExtension.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @author     belisoful@icloud.com
 @abstract   Implementation of the CGImage/CIImage/data/resize conveniences on BEImage.
 */

#import <BEFoundation/BEImage+BExtension.h>

static inline CGFloat BEClampQuality(CGFloat q) {
	return q < 0 ? 0 : (q > 1 ? 1 : q);
}

@implementation BEImage (BExtension)

#if TARGET_OS_OSX

#pragma mark - macOS (NSImage)

- (CGImageRef)CGImageRepresentation {
	return [self CGImageForProposedRect:NULL context:nil hints:nil];
}

- (CIImage *)CIImageRepresentation {
	CGImageRef cg = self.CGImageRepresentation;
	return cg ? [CIImage imageWithCGImage:cg] : nil;
}

+ (BEImage *)imageFromCGImage:(nullable CGImageRef)cgImage {
	if (cgImage == NULL) {
		return nil;
	}
	NSSize size = NSMakeSize(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));
	return [[NSImage alloc] initWithCGImage:cgImage size:size];
}

+ (BEImage *)imageFromCIImage:(nullable CIImage *)ciImage {
	if (ciImage == nil) {
		return nil;
	}
	NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:ciImage];
	NSImage *image = [[NSImage alloc] initWithSize:rep.size];
	[image addRepresentation:rep];
	return image;
}

- (nullable NSBitmapImageRep *)be_bitmapRep {
	CGImageRef cg = self.CGImageRepresentation;
	return cg ? [[NSBitmapImageRep alloc] initWithCGImage:cg] : nil;
}

- (NSData *)pngRepresentation {
	return [[self be_bitmapRep] representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
}

- (NSData *)jpegRepresentationWithCompressionQuality:(CGFloat)quality {
	return [[self be_bitmapRep] representationUsingType:NSBitmapImageFileTypeJPEG
											 properties:@{NSImageCompressionFactor: @(BEClampQuality(quality))}];
}

- (CGSize)pixelSize {
	CGImageRef cg = self.CGImageRepresentation;
	return cg ? CGSizeMake(CGImageGetWidth(cg), CGImageGetHeight(cg)) : self.size;
}

- (BEImage *)resizedToSize:(CGSize)size {
	if (size.width <= 0 || size.height <= 0) {
		return nil;
	}
	NSImage *source = self;
	return [NSImage imageWithSize:NSMakeSize(size.width, size.height) flipped:NO
				   drawingHandler:^BOOL(NSRect dstRect) {
		[source drawInRect:dstRect fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
		return YES;
	}];
}

#else

#pragma mark - iOS (UIImage)

- (CGImageRef)CGImageRepresentation {
	return self.CGImage;
}

- (CIImage *)CIImageRepresentation {
	CIImage *ci = self.CIImage;
	if (ci) {
		return ci;
	}
	CGImageRef cg = self.CGImage;
	return cg ? [CIImage imageWithCGImage:cg] : nil;
}

+ (BEImage *)imageFromCGImage:(nullable CGImageRef)cgImage {
	if (cgImage == NULL) {
		return nil;
	}
	return [UIImage imageWithCGImage:cgImage];
}

+ (BEImage *)imageFromCIImage:(nullable CIImage *)ciImage {
	if (ciImage == nil) {
		return nil;
	}
	return [UIImage imageWithCIImage:ciImage];
}

- (NSData *)pngRepresentation {
	return UIImagePNGRepresentation(self);
}

- (NSData *)jpegRepresentationWithCompressionQuality:(CGFloat)quality {
	return UIImageJPEGRepresentation(self, BEClampQuality(quality));
}

- (CGSize)pixelSize {
	return CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
}

- (BEImage *)resizedToSize:(CGSize)size {
	if (size.width <= 0 || size.height <= 0) {
		return nil;
	}
	UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
	format.scale = 1.0;   // produce exactly size×1 pixels for predictable cross-platform output
	UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
	return [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull context) {
		[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	}];
}

#endif

#pragma mark - Aspect resizing (shared)

- (BEImage *)resizedToFitSize:(CGSize)boundingSize {
	CGSize s = self.size;
	if (s.width <= 0 || s.height <= 0 || boundingSize.width <= 0 || boundingSize.height <= 0) {
		return nil;
	}
	CGFloat scale = MIN(boundingSize.width / s.width, boundingSize.height / s.height);
	return [self resizedToSize:CGSizeMake(s.width * scale, s.height * scale)];
}

- (BEImage *)resizedToFillSize:(CGSize)boundingSize {
	CGSize s = self.size;
	if (s.width <= 0 || s.height <= 0 || boundingSize.width <= 0 || boundingSize.height <= 0) {
		return nil;
	}
	CGFloat scale = MAX(boundingSize.width / s.width, boundingSize.height / s.height);
	return [self resizedToSize:CGSizeMake(s.width * scale, s.height * scale)];
}

@end
