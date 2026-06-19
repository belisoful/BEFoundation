/*!
 @header     BEImage+BExtension.h
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @author     belisoful@icloud.com
 @abstract   CGImage/CIImage/data round-trips and resizing for @c BEImage
             (@c NSImage on macOS, @c UIImage on iOS).
 @discussion @c UIImage already exposes @c CGImage, @c CIImage, @c +imageWithCGImage: and
             @c +imageWithCIImage:; @c NSImage does not, and getting bytes out of an @c NSImage
             (via @c TIFFRepresentation and @c NSBitmapImageRep) and resizing it are both
             awkward. This category brings @c NSImage up to that parity (those four members are
             macOS-only here) and adds @c pngData / @c jpegData / pixel size / resizing to both
             platforms, so the same call sites compile and behave on each.

             @code
             // CGImage/CIImage parity is macOS-only; pngData and resizing are cross-platform.
             CIImage *ci = source.CIImage;
             BEImage *rebuilt = [BEImage imageWithCIImage:ci];
             BEImage *thumb = [rebuilt resizedToFitSize:CGSizeMake(128, 128)];
             NSData *png = thumb.pngData;
             @endcode
 */

#ifndef BEImage_BExtension_h
#define BEImage_BExtension_h

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <BEFoundation/BEPlatformTypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface BEImage (BExtension)

#if TARGET_OS_OSX
#pragma mark - CGImage / CIImage parity (UIImage already provides these)

/*! @property CGImage The image rendered as a @c CGImage, or @c NULL if it cannot be represented. */
@property (nonatomic, readonly, nullable) CGImageRef CGImage;

/*! @property CIImage The image as a @c CIImage, or @c nil if it cannot be represented. */
@property (nonatomic, readonly, nullable) CIImage *CIImage;

/*! @method imageWithCGImage: Creates an image from a @c CGImage at its pixel dimensions.  Returns @c nil for a @c NULL image. */
+ (nullable BEImage *)imageWithCGImage:(nullable CGImageRef)cgImage;

/*! @method imageWithCIImage: Creates an image backed by a @c CIImage.  Returns @c nil for a @c nil image. */
+ (nullable BEImage *)imageWithCIImage:(nullable CIImage *)ciImage;
#endif

#pragma mark - Data

/*! @property pngData PNG-encoded data for the image, or @c nil on failure. */
@property (nonatomic, readonly, nullable) NSData *pngData;

/*!
 @method     jpegDataWithCompressionQuality:
 @abstract   JPEG-encoded data for the image.
 @param      quality 0.0 (smallest) to 1.0 (best). Values outside the range are clamped.
 @return     JPEG data, or @c nil on failure.
 */
- (nullable NSData *)jpegDataWithCompressionQuality:(CGFloat)quality;

#pragma mark - Size & resizing

/*! @property pixelSize The image's size in pixels (point size × scale), as opposed to its logical
    point @c size. */
@property (nonatomic, readonly) CGSize pixelSize;

/*!
 @method     resizedToSize:
 @abstract   A new image drawn at exactly @c size (logical points), ignoring aspect ratio.
 @return     The resized image, or @c nil if @c size is empty or rendering fails.
 */
- (nullable BEImage *)resizedToSize:(CGSize)size;

/*!
 @method     resizedToFitSize:
 @abstract   A new image scaled to fit within @c boundingSize, preserving aspect ratio
             (the whole image fits; letterboxing is the caller's concern).
 */
- (nullable BEImage *)resizedToFitSize:(CGSize)boundingSize;

/*!
 @method     resizedToFillSize:
 @abstract   A new image scaled to fill @c boundingSize, preserving aspect ratio
             (the image covers the box; overflow extends past it).
 */
- (nullable BEImage *)resizedToFillSize:(CGSize)boundingSize;

@end

NS_ASSUME_NONNULL_END

#endif // !BEImage_BExtension_h
