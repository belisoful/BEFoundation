/*!
 @file       NSPasteboard+BExtension.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @author     belisoful@icloud.com
 @abstract   Implementation of the NSPasteboard typed read/write conveniences (macOS only).
 */

#import <BEFoundation/NSPasteboard+BExtension.h>

#if TARGET_OS_OSX

@implementation NSPasteboard (BExtension)

#pragma mark - Write

- (BOOL)writeString:(NSString *)string {
	if (string == nil) {
		return NO;
	}
	[self clearContents];
	return [self writeObjects:@[string]];
}

- (BOOL)writeURL:(NSURL *)url {
	if (url == nil) {
		return NO;
	}
	[self clearContents];
	return [self writeObjects:@[url]];
}

- (BOOL)writeURLs:(NSArray<NSURL *> *)urls {
	if (urls.count == 0) {
		return NO;
	}
	[self clearContents];
	return [self writeObjects:urls];
}

- (BOOL)writeImage:(NSImage *)image {
	if (image == nil) {
		return NO;
	}
	[self clearContents];
	return [self writeObjects:@[image]];
}

#pragma mark - Read

- (nullable NSString *)readString {
	return [[self readObjectsForClasses:@[NSString.class] options:nil] firstObject];
}

- (nullable NSURL *)readURL {
	return [[self readObjectsForClasses:@[NSURL.class] options:nil] firstObject];
}

- (nullable NSArray<NSURL *> *)readURLs {
	NSArray<NSURL *> *urls = [self readObjectsForClasses:@[NSURL.class] options:nil];
	return urls.count ? urls : nil;
}

- (nullable NSImage *)readImage {
	return [[self readObjectsForClasses:@[NSImage.class] options:nil] firstObject];
}

@end

#endif // TARGET_OS_OSX
