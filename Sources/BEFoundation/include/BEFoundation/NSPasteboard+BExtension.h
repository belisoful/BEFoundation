/*!
 @header     NSPasteboard+BExtension.h
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @author     belisoful@icloud.com
 @abstract   Typed read/write convenience for @c NSPasteboard (macOS only).
 @discussion NSPasteboard's API works in UTIs, @c declareTypes:, and
             @c readObjectsForClasses:options: . These helpers cover the common cases: putting a
             string, URL, or image on the pasteboard, reading it back, and checking availability.
             Each writer clears the pasteboard and writes the value; each reader returns the first
             value of that type, or @c nil. This is macOS only. @c UIPasteboard is a separate API
             and is not bridged here.

             @code
             // Write a string, then read it back.
             NSPasteboard *pb = NSPasteboard.generalPasteboard;
             [pb writeString:@"Frame 01"];
             NSString *value = [pb readString];
             @endcode
 @since      1.1
 */

#ifndef NSPasteboard_BExtension_h
#define NSPasteboard_BExtension_h

#import <TargetConditionals.h>

#if TARGET_OS_OSX

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPasteboard (BExtension)

#pragma mark - Write (clears existing contents, then writes)

/*! @method writeString:  Clears the pasteboard and writes @c string. Returns @c NO for a nil @c string passed despite the nonnull parameter. */
- (BOOL)writeString:(NSString *)string;

/*! @method writeURL:  Clears the pasteboard and writes @c url. Returns @c NO for a nil @c url passed despite the nonnull parameter. */
- (BOOL)writeURL:(NSURL *)url;

/*! @method writeURLs:  Clears the pasteboard and writes @c urls. Returns @c NO if @c urls is empty. */
- (BOOL)writeURLs:(NSArray<NSURL *> *)urls;

/*! @method writeImage:  Clears the pasteboard and writes @c image. Returns @c NO for a nil @c image passed despite the nonnull parameter. */
- (BOOL)writeImage:(NSImage *)image;

#pragma mark - Typed reads

/*! @method readString  The first string on the pasteboard, or @c nil. */
- (nullable NSString *)readString;

/*! @method readURL  The first URL on the pasteboard, or @c nil. */
- (nullable NSURL *)readURL;

/*! @method readURLs  All URLs on the pasteboard, or @c nil if there are none. */
- (nullable NSArray<NSURL *> *)readURLs;

/*! @method readImage  The first image on the pasteboard, or @c nil. */
- (nullable NSImage *)readImage;

@end

NS_ASSUME_NONNULL_END

#endif // TARGET_OS_OSX

#endif // !NSPasteboard_BExtension_h
