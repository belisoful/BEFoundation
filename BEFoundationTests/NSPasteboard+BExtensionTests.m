/*!
 @file       NSPasteboard+BExtensionTests.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @abstract   Tests for the NSPasteboard typed read/write conveniences (macOS only).
 */

#import <XCTest/XCTest.h>
#import <TargetConditionals.h>

#if TARGET_OS_OSX

#import <BEFoundation/NSPasteboard+BExtension.h>

@interface NSPasteboardBExtensionTests : XCTestCase
@property (nonatomic, strong) NSPasteboard *pasteboard;   // a private, unique pasteboard — never the real clipboard
@end

@implementation NSPasteboardBExtensionTests

- (void)setUp {
	self.pasteboard = [NSPasteboard pasteboardWithUniqueName];
}

- (void)tearDown {
	[self.pasteboard releaseGlobally];
	self.pasteboard = nil;
}

- (NSImage *)greenImage {
	CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(NULL, 4, 4, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
	CGContextSetRGBFillColor(ctx, 0, 1, 0, 1);
	CGContextFillRect(ctx, CGRectMake(0, 0, 4, 4));
	CGImageRef cg = CGBitmapContextCreateImage(ctx);
	NSImage *image = [[NSImage alloc] initWithCGImage:cg size:NSMakeSize(4, 4)];
	CGImageRelease(cg);
	CGContextRelease(ctx);
	CGColorSpaceRelease(cs);
	return image;
}

#pragma mark - Round-trips

- (void)testWriteReadString {
	XCTAssertTrue([self.pasteboard writeString:@"hello world"]);
	XCTAssertEqualObjects([self.pasteboard readString], @"hello world");
}

- (void)testWriteReadURL {
	NSURL *url = [NSURL URLWithString:@"https://example.com/a"];
	XCTAssertTrue([self.pasteboard writeURL:url]);
	XCTAssertEqualObjects([self.pasteboard readURL].absoluteString, url.absoluteString);
}

- (void)testWriteReadURLs {
	NSArray<NSURL *> *urls = @[[NSURL URLWithString:@"https://a.com"], [NSURL URLWithString:@"https://b.com"]];
	XCTAssertTrue([self.pasteboard writeURLs:urls]);
	NSArray<NSURL *> *read = [self.pasteboard readURLs];
	XCTAssertEqual(read.count, 2u);
	XCTAssertEqualObjects(read.firstObject.absoluteString, @"https://a.com");
}

- (void)testWriteReadImage {
	XCTAssertTrue([self.pasteboard writeImage:[self greenImage]]);
	NSImage *read = [self.pasteboard readImage];
	XCTAssertNotNil(read);
	XCTAssertGreaterThan(read.size.width, 0);
}

#pragma mark - Guards

- (void)testWriteNilOrEmptyReturnsNO {
	XCTAssertFalse([self.pasteboard writeString:(NSString * _Nonnull)nil]);
	XCTAssertFalse([self.pasteboard writeURL:(NSURL * _Nonnull)nil]);
	XCTAssertFalse([self.pasteboard writeURLs:@[]]);
	XCTAssertFalse([self.pasteboard writeImage:(NSImage * _Nonnull)nil]);
}

- (void)testReadEmptyReturnsNil {
	XCTAssertNil([self.pasteboard readString]);
	XCTAssertNil([self.pasteboard readURL]);
	XCTAssertNil([self.pasteboard readURLs]);
	XCTAssertNil([self.pasteboard readImage]);
}

@end

#endif // TARGET_OS_OSX
