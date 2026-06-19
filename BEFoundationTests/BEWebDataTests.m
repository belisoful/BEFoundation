/*!
 @file       BEWebDataTests.m
 @copyright  © 2025 Delicense - @belisoful. All rights reserved.
 @date       2025-01-01
 @author     belisoful@icloud.com
 @abstract   Comprehensive unit tests for BEWebData class.
 @discussion Tests data URL loading, metadata preservation, NSCoding, NSCopying,
			 error handling, and integration with regular URLs.
*/

#import <XCTest/XCTest.h>
#import <BEFoundation/BEWebData.h>
#import <BEFoundation/NSURL+Data.h>


#pragma mark - Mock URL Protocol

// Intercepts http/https loads so the web-URL tests never touch the real network. A host
// containing "invalid" fails with a host-not-found error; any other request returns a small
// HTML document with a "text/html; charset=utf-8" content type.
@interface BEWebDataMockURLProtocol : NSURLProtocol
@end

@implementation BEWebDataMockURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	NSString *scheme = request.URL.scheme.lowercaseString;
	return [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	return request;
}

- (void)startLoading {
	NSURL *url = self.request.URL;
	if ([url.host containsString:@"invalid"]) {
		[self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain
																		   code:NSURLErrorCannotFindHost
																	   userInfo:nil]];
		return;
	}

	NSData *body = [@"<!DOCTYPE html><html lang=\"en\"><head><title>Mock</title></head><body><p>mock</p></body></html>"
				   dataUsingEncoding:NSUTF8StringEncoding];
	NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url
															 statusCode:200
															HTTPVersion:@"HTTP/1.1"
														   headerFields:@{@"Content-Type": @"text/html; charset=utf-8"}];
	[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	[self.client URLProtocol:self didLoadData:body];
	[self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

@end


@interface BEWebDataTests : XCTestCase
@end

@implementation BEWebDataTests

- (void)setUp {
	[super setUp];
	// Route http/https loads through the mock so the web-URL tests are deterministic and offline.
	NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
	config.protocolClasses = [@[BEWebDataMockURLProtocol.class] arrayByAddingObjectsFromArray:config.protocolClasses];
	BEWebData.defaultSessionConfiguration = config;
}

- (void)tearDown {
	BEWebData.defaultSessionConfiguration = nil;
	[super tearDown];
}

#pragma mark - getBytes:range: bounds

- (void)testGetBytesRangeOutOfBoundsCopiesNothing {
	const char *bytes = "hello"; // 5 bytes
	BEWebData *data = [[BEWebData alloc] initWithBytes:bytes length:5];

	char buffer[16];
	memset(buffer, 0xAA, sizeof(buffer));

	// Location entirely past the end must copy nothing (pre-fix this read out of bounds because
	// (length - location) underflowed and MAX(...,0) was a no-op on unsigned values).
	[data getBytes:buffer range:NSMakeRange(10, 4)];
	XCTAssertEqual((unsigned char)buffer[0], 0xAA, @"out-of-range start must copy nothing");
}

- (void)testGetBytesRangeStraddlingEndClampsToAvailable {
	const char *bytes = "hello"; // 5 bytes
	BEWebData *data = [[BEWebData alloc] initWithBytes:bytes length:5];

	char buffer[16];
	memset(buffer, 0xAA, sizeof(buffer));

	// Request 10 bytes from index 3, but only 2 ('l','o') are available.
	[data getBytes:buffer range:NSMakeRange(3, 10)];
	XCTAssertEqual(buffer[0], 'l');
	XCTAssertEqual(buffer[1], 'o');
	XCTAssertEqual((unsigned char)buffer[2], 0xAA, @"only the available bytes must be copied");
}

#pragma mark - Basic Initialization Tests

/*!
 @method     testInitWithDataURL
 @abstract   Tests basic initialization from a data URL.
 @discussion Should decode the URL and set metadata properties.
*/
- (void)testInitWithDataURL {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8;base64,SGVsbG8gV29ybGQ="];
	BEWebData *webData = [[BEWebData alloc] initWithContentsOfURL:dataURL];
	
	XCTAssertNotNil(webData, @"BEWebData should not be nil");
	XCTAssertEqualObjects(webData.MIMEType, @"text/plain");
	XCTAssertEqualObjects(webData.charset, @"utf-8");
	XCTAssertEqual(webData.stringEncoding, NSUTF8StringEncoding);
	XCTAssertTrue(webData.isBase64);
	
	NSString *decodedString = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
	XCTAssertEqualObjects(decodedString, @"Hello World");
}

/*!
 @method     testInitWithNilURL
 @abstract   Tests that nil URL returns nil.
 @discussion Should handle nil input gracefully.
*/
- (void)testInitWithNilURL {
	NSURL *nilUrl = nil;
	BEWebData *webData = [[BEWebData alloc] initWithContentsOfURL:nilUrl];
	XCTAssertNil(webData, @"BEWebData should be nil when URL is nil");
}

/*!
 @method     testDataWithContentsOfURLConvenienceMethod
 @abstract   Tests the convenience class method.
 @discussion Should create autoreleased instance with same behavior as init.
*/
- (void)testDataWithContentsOfURLConvenienceMethod {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain,Hello"];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	XCTAssertNotNil(webData);
	XCTAssertEqual(webData.class, BEWebData.class);
	XCTAssertEqualObjects(webData.MIMEType, @"text/plain");
}

/*!
 @method     testDataWithContentsOfURLExtendedConvenienceMethod
 @abstract   Tests the convenience class method.
 @discussion Should create autoreleased instance with same behavior as init.
*/
- (void)testDataWithContentsOfURLExtendedConvenienceMethod {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain,Hello"];
	NSError *error = nil;
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL options:0 error:&error];
	
	XCTAssertNotNil(webData);
	XCTAssertEqual(webData.class, BEWebData.class);
	XCTAssertEqualObjects(webData.MIMEType, @"text/plain");
}

/*!
 @method     testInitWithOptionsAndError
 @abstract   Tests initialization with options and error parameter.
 @discussion Should decode data URL and ignore options.
*/
- (void)testInitWithOptionsAndError {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;base64,VGVzdA=="];
	NSError *error = nil;
	BEWebData *webData = [[BEWebData alloc] initWithContentsOfURL:dataURL
														  options:NSDataReadingMappedIfSafe
															error:&error];
	
	XCTAssertNotNil(webData);
	XCTAssertNil(error);
	XCTAssertTrue(webData.isBase64);
}

/*!
 @method     testInitWithOptionsAndError
 @abstract   Tests initialization with options and error parameter.
 @discussion Should decode data URL and ignore options.
*/
- (void)testInitWithOptionsAndError_nonData {
	NSString *tempDir = NSTemporaryDirectory();
	NSURL *tempDirUrl = [NSURL fileURLWithPath:tempDir isDirectory:YES];
	
	// Create a valid file URL in the temporary directory
	NSURL *fileURL = [tempDirUrl URLByAppendingPathComponent:
					  [NSString stringWithFormat:@"%@.txt", NSUUID.new.UUIDString]];
	
	NSError *error = nil;
	BOOL success = [@"tempData" writeToURL:fileURL atomically:YES encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertTrue(success, @"File write should succeed.");
	XCTAssertNil(error, @"Error should be nil when writing file.");

	error = nil;
	BEWebData *webData = [[BEWebData alloc] initWithContentsOfURL:fileURL
														  options:NSDataReadingMappedIfSafe
															error:&error];
	
	XCTAssertNotNil(webData, @"Should successfully initialize BEWebData from file.");
	XCTAssertNil(error, @"No error should occur when reading the file.");
	XCTAssertFalse(webData.isBase64, @"Non-base64 data should mark isBase64 = NO.");
}

/*!
 @method     testInitWithOptionsAndError
 @abstract   Tests initialization with options and error parameter.
 @discussion Should decode data URL and ignore options.
*/
- (void)testInitWithData {
	NSString *refString = @"Hello, World!";
	BEWebData *data = [BEWebData.alloc initWithData:[refString dataUsingEncoding:NSUTF8StringEncoding]];
	NSString	*roundTripString = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
	XCTAssertEqualObjects(roundTripString, refString);
}

#pragma mark - Metadata Tests

/*!
 @method     testMIMETypeExtraction
 @abstract   Tests extraction of various MIME types.
*/
- (void)testMIMETypeExtraction {
	NSArray *testCases = @[
		@[@"data:text/html,<html></html>", @"text/html"],
		@[@"data:application/json,{}", @"application/json"],
		@[@"data:image/png;base64,iVBORw0KGgo=", @"image/png"],
		@[@"data:application/xml,<?xml?>", @"application/xml"],
		@[@"data:,minimal", @"text/plain"] // Default MIME type
	];
	
	for (NSArray *testCase in testCases) {
		NSURL *url = [NSURL URLWithString:testCase[0]];
		BEWebData *webData = [BEWebData dataWithContentsOfURL:url];
		XCTAssertEqualObjects(webData.MIMEType, testCase[1], @"Failed for URL: %@", testCase[0]);
	}
}

/*!
 @method     testCharsetExtraction
 @abstract   Tests extraction of various charsets.
*/
- (void)testCharsetExtraction {
	NSArray *testCases = @[
		@[@"data:text/plain;charset=utf-8,test", @"utf-8"],
		@[@"data:text/html;charset=iso-8859-1,test", @"iso-8859-1"],
		@[@"data:text/plain;charset=windows-1252,test", @"windows-1252"],
		@[@"data:text/plain,test", @"US-ASCII"] // Default charset
	];
	
	for (NSArray *testCase in testCases) {
		NSURL *url = [NSURL URLWithString:testCase[0]];
		BEWebData *webData = [BEWebData dataWithContentsOfURL:url];
		XCTAssertEqualObjects(webData.charset, testCase[1], @"Failed for URL: %@", testCase[0]);
	}
}

/*!
 @method     testStringEncodingMapping
 @abstract   Tests that charset maps to correct NSStringEncoding.
*/
- (void)testStringEncodingMapping {
	NSURL *url1 = [NSURL URLWithString:@"data:text/plain;charset=utf-8,test"];
	BEWebData *webData1 = [BEWebData dataWithContentsOfURL:url1];
	XCTAssertEqual(webData1.stringEncoding, NSUTF8StringEncoding);
	
	NSURL *url2 = [NSURL URLWithString:@"data:text/plain;charset=US-ASCII,test"];
	BEWebData *webData2 = [BEWebData dataWithContentsOfURL:url2];
	XCTAssertEqual(webData2.stringEncoding, NSASCIIStringEncoding);
	
	NSURL *url3 = [NSURL URLWithString:@"data:text/plain;charset=iso-8859-1,test"];
	BEWebData *webData3 = [BEWebData dataWithContentsOfURL:url3];
	XCTAssertEqual(webData3.stringEncoding, NSISOLatin1StringEncoding);
}

/*!
 @method     testBase64FlagDetection
 @abstract   Tests detection of base64 encoding.
*/
- (void)testBase64FlagDetection {
	NSURL *base64URL = [NSURL URLWithString:@"data:text/plain;base64,VGVzdA=="];
	BEWebData *base64Data = [BEWebData dataWithContentsOfURL:base64URL];
	XCTAssertTrue(base64Data.isBase64);
	
	NSURL *percentURL = [NSURL URLWithString:@"data:text/plain,Test"];
	BEWebData *percentData = [BEWebData dataWithContentsOfURL:percentURL];
	XCTAssertFalse(percentData.isBase64);
}

#pragma mark - Data Decoding Tests

/*!
 @method     testBase64Decoding
 @abstract   Tests that base64-encoded data is correctly decoded.
*/
- (void)testBase64Decoding {
	NSString *originalString = @"The quick brown fox jumps over the lazy dog";
	NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];
	NSString *base64String = [originalData base64EncodedStringWithOptions:0];
	
	NSString *dataURLString = [NSString stringWithFormat:@"data:text/plain;charset=utf-8;base64,%@", base64String];
	NSURL *dataURL = [NSURL URLWithString:dataURLString];
	
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	XCTAssertNotNil(webData);
	XCTAssertEqualObjects(webData, originalData);
	
	NSString *decodedString = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
	XCTAssertEqualObjects(decodedString, originalString);
}

/*!
 @method     testPercentEncodedDecoding
 @abstract   Tests that percent-encoded data is correctly decoded.
*/
- (void)testPercentEncodedDecoding {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain,Hello%20World%21"];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	XCTAssertNotNil(webData);
	XCTAssertFalse(webData.isBase64);
	
	NSString *decodedString = [[NSString alloc] initWithData:webData encoding:webData.stringEncoding];
	XCTAssertEqualObjects(decodedString, @"Hello World!");
}

/*!
 @method     testBinaryDataDecoding
 @abstract   Tests decoding of binary data.
*/
- (void)testBinaryDataDecoding {
	unsigned char bytes[] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A}; // PNG header
	NSData *originalData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	NSString *base64 = [originalData base64EncodedStringWithOptions:0];
	
	NSString *dataURLString = [NSString stringWithFormat:@"data:image/png;base64,%@", base64];
	NSURL *dataURL = [NSURL URLWithString:dataURLString];
	
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	XCTAssertNotNil(webData);
	XCTAssertEqualObjects(webData, originalData);
	XCTAssertEqualObjects(webData.MIMEType, @"image/png");
}

#pragma mark - Class Method Tests

/*!
 @method     testIsDataURLClassMethod
 @abstract   Tests the isDataURL: class method.
*/
- (void)testIsDataURLClassMethod {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain,test"];
	NSURL *httpURL = [NSURL URLWithString:@"https://example.com"];
	NSURL *fileURL = [NSURL fileURLWithPath:@"/tmp/test.txt"];
	NSURL *nilUrl = nil;
	NSURL *nonUrl = (NSURL*)NSObject.new;
	
	XCTAssertTrue([BEWebData isDataURL:dataURL]);
	XCTAssertFalse([BEWebData isDataURL:httpURL]);
	XCTAssertFalse([BEWebData isDataURL:fileURL]);
	XCTAssertFalse([BEWebData isDataURL:nilUrl]);
	XCTAssertFalse([BEWebData isDataURL:nonUrl]);
}

/*!
 @method     testDecodeDataURLClassMethod
 @abstract   Tests the low-level decodeDataURL: class method.
*/
- (void)testDecodeDataURLClassMethod {
	NSURL *dataURL = [NSURL URLWithString:@"data:application/json;charset=utf-8;base64,eyJrZXkiOiJ2YWx1ZSJ9"];
	
	NSString *mimeType = nil;
	NSString *charset = nil;
	NSStringEncoding encoding = 0;
	BOOL isBase64 = NO;
	
	NSData *decoded = [BEWebData decodeDataURL:dataURL
									  MIMEType:&mimeType
									   charset:&charset
									  encoding:&encoding
										base64:&isBase64];
	
	XCTAssertNotNil(decoded);
	XCTAssertEqualObjects(mimeType, @"application/json");
	XCTAssertEqualObjects(charset, @"utf-8");
	XCTAssertEqual(encoding, NSUTF8StringEncoding);
	XCTAssertTrue(isBase64);
	
	NSString *jsonString = [[NSString alloc] initWithData:decoded encoding:NSUTF8StringEncoding];
	XCTAssertEqualObjects(jsonString, @"{\"key\":\"value\"}");
}

/*!
 @method     testDecodeDataURLWithNullParameters
 @abstract   Tests decoding with NULL output parameters.
*/
- (void)testDecodeDataURLWithNullParameters {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain,test"];
	
	// Should not crash with NULL parameters
	NSData *decoded = [BEWebData decodeDataURL:dataURL
									  MIMEType:NULL
									   charset:NULL
									  encoding:NULL
										base64:NULL];
	
	XCTAssertNotNil(decoded);
	NSString *str = [[NSString alloc] initWithData:decoded encoding:NSASCIIStringEncoding];
	XCTAssertEqualObjects(str, @"test");
}


/*!
 @method     testDecodeDataURLWithNullParameters
 @abstract   Tests decoding with NULL output parameters.
*/
- (void)testDecodeDataURLWithNilURL {
	NSURL *dataURL = nil;
	
	// Should not crash with NULL parameters
	NSData *decoded = [BEWebData decodeDataURL:dataURL
									  MIMEType:NULL
									   charset:NULL
									  encoding:NULL
										base64:NULL];
	
	XCTAssertNil(decoded);
}

#pragma mark - NSCoding Tests

/*!
 @method     testArchivingAndUnarchiving
 @abstract   Tests that BEWebData can be archived and unarchived.
 @discussion Should preserve data and all metadata properties.
*/
- (void)testArchivingAndUnarchiving {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/html;charset=utf-8;base64,PGh0bWw+PC9odG1sPg=="];
	BEWebData *original = [BEWebData dataWithContentsOfURL:dataURL];
	
	XCTAssertNotNil(original);
	
	// Archive
	NSError *archiveError = nil;
	NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:original
												 requiringSecureCoding:YES
																 error:&archiveError];
	
	XCTAssertNotNil(archivedData, @"Archiving failed: %@", archiveError);
	XCTAssertNil(archiveError);
	
	// Unarchive
	NSError *unarchiveError = nil;
	BEWebData *restored = [NSKeyedUnarchiver unarchivedObjectOfClass:[BEWebData class]
															fromData:archivedData
															   error:&unarchiveError];
	
	XCTAssertNotNil(restored, @"Unarchiving failed: %@", unarchiveError);
	XCTAssertNil(unarchiveError);

	// Verify data
	XCTAssertEqualObjects(restored, original);

	// Verify metadata
	XCTAssertEqualObjects(restored.MIMEType, original.MIMEType);
	XCTAssertEqualObjects(restored.charset, original.charset);
	XCTAssertEqual(restored.stringEncoding, original.stringEncoding);
	XCTAssertEqual(restored.isBase64, original.isBase64);

	// An unarchived instance is a finished snapshot, not an in-flight load.
	XCTAssertTrue(restored.isComplete);
}

/*!
 @method     testArchivingWithoutMetadata
 @abstract   Tests archiving BEWebData loaded from regular URL (no metadata).
*/
- (void)testArchivingWithoutMetadata {
	// Create BEWebData without metadata (would need a real file URL in production)
	// For testing, we'll create one from a data URL then verify nil metadata behavior
	NSData *plainData = [@"test data" dataUsingEncoding:NSUTF8StringEncoding];
	BEWebData *webData = [BEWebData dataWithBytes:plainData.bytes length:plainData.length];
	
	// Archive and unarchive
	NSError *error = nil;
	NSData *archived = [NSKeyedArchiver archivedDataWithRootObject:webData
											 requiringSecureCoding:YES
															 error:&error];
	XCTAssertNotNil(archived);
	
	BEWebData *restored = [NSKeyedUnarchiver unarchivedObjectOfClass:[BEWebData class]
															fromData:archived
															   error:&error];
	
	XCTAssertNotNil(restored);
	XCTAssertEqualObjects(restored, webData);
	XCTAssertNil(restored.MIMEType);
	XCTAssertNil(restored.charset);
}

/*!
 @method     testSupportsSecureCoding
 @abstract   Tests that the class properly supports secure coding.
*/
- (void)testSupportsSecureCoding {
	XCTAssertTrue([BEWebData supportsSecureCoding]);
}

#pragma mark - NSCopying Tests

/*!
 @method     testCopying
 @abstract   Tests that BEWebData can be copied with metadata.
*/
- (void)testCopying {
	NSURL *dataURL = [NSURL URLWithString:@"data:application/xml;charset=utf-8,<?xml version=\"1.0\"?>"];
	BEWebData *original = [BEWebData dataWithContentsOfURL:dataURL];
	
	BEWebData *copy = [original copy];
	
	XCTAssertNotNil(copy);
	XCTAssertEqualObjects(copy, original);
	
	// Verify metadata is copied
	XCTAssertEqualObjects(copy.MIMEType, original.MIMEType);
	XCTAssertEqualObjects(copy.charset, original.charset);
	XCTAssertEqual(copy.stringEncoding, original.stringEncoding);
	XCTAssertEqual(copy.isBase64, original.isBase64);

	// A copy is a finished snapshot, not an in-flight load.
	XCTAssertTrue(copy.isComplete);
}

/*!
 @method     testCopyIsImmutable
 @abstract   Tests that copied metadata is independent.
*/
- (void)testCopyIsImmutable {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8,test"];
	BEWebData *original = [BEWebData dataWithContentsOfURL:dataURL];
	BEWebData *copy = [original copy];
	
	// Since properties are readonly and copied, they should be independent
	XCTAssertNotNil(copy.MIMEType);
	XCTAssertNotNil(original.MIMEType);
	XCTAssertEqualObjects(copy.MIMEType, original.MIMEType);
}

#pragma mark - Error Handling Tests

/*!
 @method     testMalformedDataURL
 @abstract   Tests handling of malformed data URLs.
*/
- (void)testMalformedDataURL {
	NSURL *malformedURL = [NSURL URLWithString:@"data:text/plainNoComma"];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:malformedURL];
	
	XCTAssertNil(webData, @"Should return nil for malformed data URL");
}

/*!
 @method     testErrorReporting
 @abstract   Tests that errors are properly reported.
*/
- (void)testErrorReporting {
	NSURL *nilUrl = nil;
	NSError *error = nil;
	BEWebData *webData = [[BEWebData alloc] initWithContentsOfURL:nilUrl
														  options:0
															error:&error];
	
	XCTAssertNil(webData);
	XCTAssertNotNil(error);
	XCTAssertEqual(error.code, NSFileReadInvalidFileNameError);
}

/*!
 @method     testInvalidBase64Error
 @abstract   Tests handling of invalid base64 data.
*/
- (void)testInvalidBase64Error {
	NSURL *invalidURL = [NSURL URLWithString:@"data:text/plain;base64,Invalid!!!Base64"];
	NSError *error = nil;
	BEWebData *webData = [[BEWebData alloc] initWithContentsOfURL:invalidURL
														  options:0
															error:&error];
	
	// May return nil or partial data depending on base64 decoder behavior
	// At minimum, should not crash
	XCTAssertNil(webData.bytes);
}



#pragma mark - Integration with Regular URLs

/*!
 @method     testLoadingFromFileURL
 @abstract   Tests that BEWebData works with regular file URLs.
 @discussion Should behave like NSData for non-data URLs.
*/
- (void)testLoadingFromFileURL {
	// Create a temporary file
	NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.txt"];
	NSString *content = @"File content";
	[content writeToFile:tempPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	NSURL *fileURL = [NSURL fileURLWithPath:tempPath];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:fileURL];
	
	XCTAssertNotNil(webData);
	XCTAssertTrue(webData.isComplete);
	XCTAssertTrue(webData.complete);
	
	NSString *loadedContent = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
	XCTAssertEqualObjects(loadedContent, content);
	
	// Metadata should be nil for non-data URLs
	XCTAssertNil(webData.MIMEType);
	XCTAssertNil(webData.charset);
	XCTAssertEqual(webData.stringEncoding, 0);
	XCTAssertFalse(webData.isBase64);
	
	__block BOOL calledCompletion = NO;
	__block NSData *fData = nil;
	__block NSURLResponse *fResponse = nil;
	__block NSError *fError = nil;
	
	webData.dataTaskCompletionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		calledCompletion = YES;
		fData = data;
		fResponse = response;
		fError = error;
	};
	
	XCTAssertTrue(calledCompletion);
	XCTAssertNotNil(fData);
	XCTAssertEqual(fData, webData);
	XCTAssertNil(fResponse);
	XCTAssertNil(fError);
	
	// Clean up
	[[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
}

/*!
 @method     testLoadingFromFileURL
 @abstract   Tests that BEWebData works with regular file URLs.
 @discussion Should behave like NSData for non-data URLs.
*/
- (void)testLoadingFromWebURL_synchronous {
	// Create a temporary file
	
	NSURL *webURL = [NSURL URLWithString:@"https://github.com"];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:webURL];
	
	XCTAssertNotNil(webData);
	XCTAssertTrue(webData.isComplete);
	XCTAssertTrue(webData.complete);
	XCTAssertNil(webData.dataTask);
	const void* bytes = webData.bytes;
	XCTAssertNotEqual(bytes, (void*)0);
	
	NSString *webPageString =  [NSString.alloc initWithData:webData encoding:NSUTF8StringEncoding];
	XCTAssertTrue([webPageString containsString:@"<html"]);
	XCTAssertTrue([webPageString containsString:@"<head>"]);
	XCTAssertTrue([webPageString containsString:@"</head>"]);
	XCTAssertTrue([webPageString containsString:@"<body"]);
	
	// Metadata should be nil for non-data URLs
	XCTAssertEqualObjects(webData.MIMEType, @"text/html");
	XCTAssertEqualObjects(webData.charset.lowercaseString, @"utf-8");
	XCTAssertEqual(webData.stringEncoding, NSUTF8StringEncoding);
	XCTAssertFalse(webData.isBase64);
}

/*!
 @method     testLoadingFromFileURL
 @abstract   Tests that BEWebData works with regular file URLs.
 @discussion Should behave like NSData for non-data URLs.
*/
- (void)testLoadingFromWebURL_synchronous_badurl {
	// Create a temporary file
	
	NSURL *webURL = [NSURL URLWithString:@"https://invalid.not-a-website.invalid"];
	NSError *error = nil;
	BEWebData *webData = [BEWebData dataWithContentsOfURL:webURL options:BEDataReadingSynchronous error:&error];
	
	XCTAssertNil(webData);
	XCTAssertNotNil(error);
}


/*!
 @method     testLoadingFromFileURL
 @abstract   Tests that BEWebData works with regular file URLs.
 @discussion Should behave like NSData for non-data URLs.
*/
- (void)testLoadingFromWebURL_asynchronous {
	// Create a temporary file
	
	NSURL *webURL = [NSURL URLWithString:@"https://github.com"];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:webURL options:BEDataReadingAsynchronous error:nil];
	
	XCTAssertFalse(webData.isComplete);
	XCTAssertFalse(webData.complete);
	XCTAssertNotNil(webData.dataTask);
	XCTAssertNil(webData.bytes);
	
	__block BOOL calledCompletion = NO;
	__block NSData *fData = nil;
	__block NSURLResponse *fResponse = nil;
	__block NSError *fError = nil;
	
	webData.dataTaskCompletionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		calledCompletion = YES;
		fData = data;
		fResponse = response;
		fError = error;
	};
	XCTAssertFalse(calledCompletion);
	
	dispatch_semaphore_wait(webData.dataTaskSemaphore, DISPATCH_TIME_FOREVER);
	
	XCTAssertTrue(calledCompletion);
	XCTAssertNotNil(fData);
	XCTAssertEqual(fData, webData);
	XCTAssertNotNil(fResponse);
	XCTAssertNil(fError);
}


/*!
 @method     testLoadingFromFileURL
 @abstract   Tests that BEWebData works with regular file URLs.
 @discussion Should behave like NSData for non-data URLs.
*/
- (void)testLoadingFromWebURL_asynchronous_badurl {
	NSURL *webURL = [NSURL URLWithString:@"https://invalid.not-a-website.invalid"];
	NSError *error = nil;
	BEWebData *webData = [BEWebData dataWithContentsOfURL:webURL options:BEDataReadingAsynchronous error:&error];

	XCTAssertNotNil(webData);
	XCTAssertNil(error);
	// The async load signals its semaphore on completion, whether it succeeds or fails.
	dispatch_semaphore_wait(webData.dataTaskSemaphore, DISPATCH_TIME_FOREVER);
	XCTAssertNotNil(webData.dataTaskError);
}

#pragma mark - Edge Cases

/*!
 @method     testEmptyDataURL
 @abstract   Tests data URL with empty data section.
*/
- (void)testEmptyDataURL {
	NSURL *emptyURL = [NSURL URLWithString:@"data:text/plain,"];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:emptyURL];
	
	XCTAssertNotNil(webData);
	XCTAssertEqual(webData.length, 0);
	XCTAssertEqualObjects(webData.MIMEType, @"text/plain");
}

/*!
 @method     testMinimalDataURL
 @abstract   Tests minimal data URL format.
*/
- (void)testMinimalDataURL {
	NSURL *minimalURL = [NSURL URLWithString:@"data:,test"];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:minimalURL];
	
	XCTAssertNotNil(webData);
	XCTAssertEqualObjects(webData.MIMEType, @"text/plain");
	XCTAssertEqualObjects(webData.charset, @"US-ASCII");
	XCTAssertFalse(webData.isBase64);
}

/*!
 @method     testLargeDataURL
 @abstract   Tests data URL with large payload.
*/
- (void)testLargeDataURL {
	// Create 10KB of data
	NSMutableData *largeData = [NSMutableData dataWithCapacity:10000];
	for (int i = 0; i < 10000; i++) {
		unsigned char byte = i % 256;
		[largeData appendBytes:&byte length:1];
	}
	
	NSString *base64 = [largeData base64EncodedStringWithOptions:0];
	NSString *urlString = [NSString stringWithFormat:@"data:application/octet-stream;base64,%@", base64];
	NSURL *largeURL = [NSURL URLWithString:urlString];
	
	BEWebData *webData = [BEWebData dataWithContentsOfURL:largeURL];
	
	XCTAssertNotNil(webData);
	XCTAssertEqual(webData.length, largeData.length);
	XCTAssertEqualObjects(webData, largeData);
}

/*!
 @method     testUnicodeInDataURL
 @abstract   Tests data URL with Unicode characters.
*/
- (void)testUnicodeInDataURL {
	NSString *unicodeString = @"Hello 世界 🌍";
	NSData *unicodeData = [unicodeString dataUsingEncoding:NSUTF8StringEncoding];
	NSString *base64 = [unicodeData base64EncodedStringWithOptions:0];
	
	NSString *urlString = [NSString stringWithFormat:@"data:text/plain;charset=utf-8;base64,%@", base64];
	NSURL *dataURL = [NSURL URLWithString:urlString];
	
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	XCTAssertNotNil(webData);
	NSString *decoded = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
	XCTAssertEqualObjects(decoded, unicodeString);
}


/*!
 @method     testLoadingFromFileURL
 @abstract   Tests that BEWebData works with regular file URLs.
 @discussion Should behave like NSData for non-data URLs.
*/
- (void)testLoadingFromWebURL_differentURLScheme {
	// Create a temporary file
	
	NSURL *webURL = [NSURL URLWithString:@"scheme://github.com"];
	NSError *error = nil;
	BEWebData *webData = [BEWebData dataWithContentsOfURL:webURL options:0 error:&error];
	
	XCTAssertNotNil(error);
	XCTAssertNil(webData);
}

#pragma mark - Description Tests

/*!
 @method     testDescription
 @abstract   Tests the description method output.
*/
- (void)testDescription {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8;base64,VGVzdA=="];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	NSString *description = [webData description];
	
	XCTAssertNotNil(description);
	XCTAssertTrue([description containsString:@"BEWebData"]);
	XCTAssertTrue([description containsString:@"length"]);
	XCTAssertTrue([description containsString:@"MIMEType = text/plain"]);
	XCTAssertTrue([description containsString:@"charset = utf-8"]);
	XCTAssertTrue([description containsString:@"base64 = YES"]);
}

/*!
 @method     testDescriptionWithoutMetadata
 @abstract   Tests description for BEWebData without metadata.
*/
- (void)testDescriptionWithoutMetadata {
	NSData *plainData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
	BEWebData *webData = [BEWebData dataWithBytes:plainData.bytes length:plainData.length];
	
	NSString *description = [webData description];
	
	XCTAssertNotNil(description);
	XCTAssertTrue([description containsString:@"BEWebData"]);
	XCTAssertTrue([description containsString:@"length"]);
}

#pragma mark - Real-World Scenario Tests

/*!
 @method     testJSONDataURL
 @abstract   Tests loading JSON from a data URL.
*/
- (void)testJSONDataURL {
	NSDictionary *jsonDict = @{@"name": @"Test", @"value": @(42)};
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
	NSString *base64 = [jsonData base64EncodedStringWithOptions:0];
	
	NSString *urlString = [NSString stringWithFormat:@"data:application/json;charset=utf-8;base64,%@", base64];
	NSURL *dataURL = [NSURL URLWithString:urlString];
	
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	XCTAssertNotNil(webData);
	XCTAssertEqualObjects(webData.MIMEType, @"application/json");
	
	NSDictionary *decoded = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
	XCTAssertEqualObjects(decoded, jsonDict);
}

/*!
 @method     testHTMLDataURL
 @abstract   Tests loading HTML from a data URL.
*/
- (void)testHTMLDataURL {
	NSString *html = @"<!DOCTYPE html><html><body><h1>Test</h1></body></html>";
	NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:htmlData mimeType:@"text/html" charset:@"utf-8"];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	XCTAssertNotNil(webData);
	XCTAssertEqualObjects(webData.MIMEType, @"text/html");
	
	NSString *decoded = [[NSString alloc] initWithData:webData encoding:webData.stringEncoding];
	XCTAssertEqualObjects(decoded, html);
}

/*!
 @method     testSVGDataURL
 @abstract   Tests loading SVG from a data URL.
*/
- (void)testSVGDataURL {
	NSString *svg = @"<svg xmlns=\"http://www.w3.org/2000/svg\"><circle r=\"50\"/></svg>";
	NSData *svgData = [svg dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:svgData mimeType:@"image/svg+xml" charset:@"utf-8"];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	XCTAssertNotNil(webData);
	XCTAssertEqualObjects(webData.MIMEType, @"image/svg+xml");
	
	NSString *decoded = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
	XCTAssertEqualObjects(decoded, svg);
}

#pragma mark - Subclass Behavior Tests

/*!
 @method     testClassIdentity
 @abstract   Tests that instances identify as BEWebData class.
*/
- (void)testClassIdentity {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain,test"];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	XCTAssertEqual([webData class], [BEWebData class]);
	XCTAssertTrue([webData isKindOfClass:[BEWebData class]]);
	XCTAssertTrue([webData isKindOfClass:[NSData class]]);
}

/*!
 @method     testNSDataCompatibility
 @abstract   Tests that BEWebData works with NSData APIs.
*/
- (void)testNSDataCompatibility {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain,test"];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	// Should work with NSData methods
	XCTAssertEqual(webData.length, 4);
	
	const void *bytes = webData.bytes;
	XCTAssertNotEqual(bytes, NULL);
	
	NSData *subdata = [webData subdataWithRange:NSMakeRange(0, 2)];
	XCTAssert([subdata isKindOfClass:NSData.class]);
	XCTAssertNotNil(subdata);
	
	char myBytes[6];
	
	memset(myBytes, 0, 6);
	[webData getBytes:myBytes length:sizeof(myBytes)];
	XCTAssertEqual(strcmp(myBytes, "test"), 0, @"webData should be \"test\".");
	
	memset(myBytes, 0, 6);
	[webData getBytes:myBytes length:3];
	XCTAssertEqual(strcmp(myBytes, "tes"), 0, @"webData [0 to 2] should be \"tes\".");
	
	
	memset(myBytes, 0, 6);
	[webData getBytes:myBytes range:NSMakeRange(1, 2)];
	XCTAssertEqual(strcmp(myBytes, "es"), 0, @"webData [1 to 2] should be \"es\".");
	
}

#pragma mark - Performance Tests

/*!
 @method     testPerformanceLoadingDataURLs
 @abstract   Tests performance of loading data URLs.
*/
- (void)testPerformanceLoadingDataURLs {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;base64,VGVzdCBkYXRh"];
	
	[self measureBlock:^{
		for (int i = 0; i < 100; i++) {
			BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
			(void)webData; // Suppress unused variable warning
		}
	}];
}

/*!
 @method     testPerformanceMetadataAccess
 @abstract   Tests performance of accessing metadata properties.
*/
- (void)testPerformanceMetadataAccess {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8;base64,VGVzdA=="];
	BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];
	
	[self measureBlock:^{
		for (int i = 0; i < 1000; i++) {
			NSString *mime = webData.MIMEType;
			NSString *charset = webData.charset;
			NSStringEncoding encoding = webData.stringEncoding;
			BOOL base64 = webData.isBase64;
			(void)mime; (void)charset; (void)encoding; (void)base64;
		}
	}];
}

@end
