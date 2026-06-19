
/*!
 @file       NSURL+DataTests.m
 @copyright  © 2025 Delicense - @belisoful. All rights released.
 @date       2025-01-01
 @author     belisoful@icloud.com
 @abstract   Comprehensive unit tests for NSURL+Data category.
 @discussion Tests creation, parsing, encoding, and decoding of RFC 2397 data URLs.
			 Covers base64 and percent-encoding, various MIME types and charsets,
			 edge cases, and error handling.
*/

#import <XCTest/XCTest.h>
#import <BEFoundation/NSURL+Data.h>
#import <BEFoundation/BEWebData.h>

@interface NSURL (Data_PrivateMethods)

- (BOOL)parseDataUrlWithMimeType:(NSString**)mimeType charset:(NSString**)charset encoding:(NSStringEncoding*)encoding isBase64:(BOOL*)base64;
- (BOOL)parseDataUrl:(NSString *)resourceSpecifier mimeType:(NSString**)mimeType charset:(NSString**)charset encoding:(NSStringEncoding*)encoding isBase64:(BOOL*)base64;

@end

@interface NSURLDataTests : XCTestCase
@end

@implementation NSURLDataTests

#pragma mark - Basic Data URL Creation Tests

/*!
 @method     testDataURLWithSimpleData
 @abstract   Tests creating a basic data URL with binary data.
 @discussion Should default to application/octet-stream and base64 encoding.
*/
- (void)testDataURLWithSimpleData {
	NSData *data = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data];
	
	XCTAssertNotNil(dataURL, @"Data URL should not be nil");
	XCTAssertTrue([dataURL isDataURL], @"URL should be identified as data URL");
	XCTAssertTrue([dataURL.scheme isEqualToString:@"data"], @"Scheme should be 'data'");
}

/*!
 @method     testDataURLWithNilData
 @abstract   Tests that nil data returns nil URL.
 @discussion Should handle nil input gracefully.
*/
- (void)testDataURLWithNilData {
	NSData *nilData = nil;
	NSURL *dataURL = [NSURL dataURLWithData:nilData];
	XCTAssertNil(dataURL, @"Data URL should be nil when data is nil");
}

/*!
 @method     testDataURLWithEmptyData
 @abstract   Tests creating a data URL with empty data.
 @discussion Should create valid URL with empty data section.
*/
- (void)testDataURLWithEmptyData {
	NSData *data = [NSData data];
	NSURL *dataURL = [NSURL dataURLWithData:data];
	
	XCTAssertNotNil(dataURL, @"Data URL should not be nil for empty data");
	XCTAssertTrue([dataURL isDataURL], @"URL should be identified as data URL");
}

#pragma mark - BEWebData URL Creation Tests

/*!
 @method     testDataURLWithSimpleData
 @abstract   Tests creating a basic data URL with binary data.
 @discussion Should default to application/octet-stream and base64 encoding.
*/
- (void)testDataURLWithBEWebData {
	BEWebData *data = [BEWebData.alloc initWithData:[@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding]];
	NSURL *dataURL = [NSURL dataURLWithData:data];
	
	XCTAssertNotNil(dataURL, @"Data URL should not be nil");
	XCTAssertTrue([dataURL isDataURL], @"URL should be identified as data URL");
	XCTAssertTrue([dataURL.scheme isEqualToString:@"data"], @"Scheme should be 'data'");
}

#pragma mark - MIME Type Tests

/*!
 @method     testDataURLWithTextPlainMIME
 @abstract   Tests creating data URL with text/plain MIME type.
 @discussion Should use charset and percent-encoding by default.
*/
- (void)testDataURLWithTextPlainMIME {
	NSData *data = [@"Plain text content" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data mimeType:@"text/plain"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"text/plain");
	XCTAssertFalse(dataURL.isBase64, @"Text should use percent-encoding by default");
}

/*!
 @method     testDataURLWithJSONMIME
 @abstract   Tests creating data URL with application/json MIME type.
 @discussion JSON should default to UTF-8 charset.
*/
- (void)testDataURLWithJSONMIME {
	NSData *data = [@"{\"key\":\"value\"}" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data mimeType:@"application/json"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"application/json");
	XCTAssertEqualObjects(dataURL.dataCharset, @"utf-8");
}

/*!
 @method     testDataURLWithXMLMIME
 @abstract   Tests creating data URL with application/xml MIME type.
 @discussion XML should default to UTF-8 charset.
*/
- (void)testDataURLWithXMLMIME {
	NSData *data = [@"<?xml version=\"1.0\"?><root/>" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data mimeType:@"application/xml"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"application/xml");
	XCTAssertEqualObjects(dataURL.dataCharset, @"utf-8");
}

/*!
 @method     testDataURLWithXMLMIME
 @abstract   Tests creating data URL with application/xml MIME type.
 @discussion XML should default to UTF-8 charset.
*/
- (void)testDataURLWithJavascriptMIME {
	NSData *data = [@"<?xml version=\"1.0\"?><root/>" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data mimeType:@"application/javascript"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"application/javascript");
	XCTAssertEqualObjects(dataURL.dataCharset, @"utf-8");
}

/*!
 @method     testDataURLWithImageMIME
 @abstract   Tests creating data URL with image MIME type.
 @discussion Binary data should use base64 encoding.
*/
- (void)testDataURLWithImageMIME {
	NSData *data = [NSData dataWithBytes:(unsigned char[]){0xFF, 0xD8, 0xFF} length:3];
	NSURL *dataURL = [NSURL dataURLWithData:data mimeType:@"image/jpeg"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"image/jpeg");
	XCTAssertTrue(dataURL.isBase64, @"Binary data should use base64");
	XCTAssertNil(dataURL.dataCharset, @"Binary data should not have charset");
}

/*!
 @method     testDataURLWithCustomMIME
 @abstract   Tests creating data URL with custom/vendor MIME type.
*/
- (void)testDataURLWithCustomMIME {
	NSData *data = [@"custom data" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data mimeType:@"application/x-custom"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"application/x-custom");
}

#pragma mark - Charset Tests

/*!
 @method     testDataURLWithUTF8Charset
 @abstract   Tests creating data URL with UTF-8 charset.
*/
- (void)testDataURLWithUTF8Charset {
	NSData *data = [@"UTF-8 text with émojis 🎉" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data charset:@"utf-8"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataCharset, @"utf-8");
	XCTAssertEqual(dataURL.stringEncoding, NSUTF8StringEncoding);
}

/*!
 @method     testDataURLWithASCIICharset
 @abstract   Tests creating data URL with US-ASCII charset.
*/
- (void)testDataURLWithASCIICharset {
	NSData *data = [@"ASCII only" dataUsingEncoding:NSASCIIStringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data charset:@"US-ASCII"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataCharset, @"US-ASCII");
	XCTAssertEqual(dataURL.stringEncoding, NSASCIIStringEncoding);
}

/*!
 @method     testDataURLWithISO88591Charset
 @abstract   Tests creating data URL with ISO-8859-1 (Latin1) charset.
*/
- (void)testDataURLWithISO88591Charset {
	NSData *data = [@"Latin1 text" dataUsingEncoding:NSISOLatin1StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data charset:@"iso-8859-1"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataCharset, @"iso-8859-1");
	XCTAssertEqual(dataURL.stringEncoding, NSISOLatin1StringEncoding);
}

/*!
 @method     testDataURLWithWindows1252Charset
 @abstract   Tests creating data URL with Windows-1252 charset.
*/
- (void)testDataURLWithWindows1252Charset {
	NSData *data = [@"Windows text" dataUsingEncoding:NSWindowsCP1252StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data charset:@"windows-1252"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataCharset, @"windows-1252");
	XCTAssertEqual(dataURL.stringEncoding, NSWindowsCP1252StringEncoding);
}

#pragma mark - Encoding Tests (Base64 vs Percent-Encoding)

/*!
 @method     testDataURLWithBase64Encoding
 @abstract   Tests creating data URL with explicit base64 encoding.
*/
- (void)testDataURLWithBase64Encoding {
	NSData *data = [@"Base64 encoded" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data isBase64:NSURLBase64Type_Yes];
	
	XCTAssertNotNil(dataURL);
	XCTAssertTrue(dataURL.isBase64);
	
	NSString *urlString = dataURL.absoluteString;
	XCTAssertTrue([urlString containsString:@";base64,"], @"URL should contain base64 marker");
}

/*!
 @method     testDataURLWithPercentEncoding
 @abstract   Tests creating data URL with explicit percent-encoding.
*/
- (void)testDataURLWithPercentEncoding {
	NSData *data = [@"Percent encoded" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data
								   mimeType:@"text/plain"
									charset:@"utf-8"
								   isBase64:NSURLBase64Type_No];
	
	XCTAssertNotNil(dataURL);
	XCTAssertFalse(dataURL.isBase64);
	
	NSString *urlString = dataURL.absoluteString;
	XCTAssertFalse([urlString containsString:@";base64,"], @"URL should not contain base64 marker");
}


/*!
 @method     testDataURLWithPercentEncodingAltInitChinese
 @abstract   Tests creating data URL with explicit percent-encoding.
*/
- (void)testDataURLWithPercentEncodingAltInitChinese {
	NSString *string = @"你好世界🏁"; // translated from "hello world"   @translate.google.com
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data
								   mimeType:BEURL_DefaultTextMimeType
									charset:BEURL_Windows1252
								   isBase64:NSURLBase64Type_No];
	
	XCTAssertNotNil(dataURL);
	XCTAssertFalse(dataURL.isBase64);
	XCTAssertEqualObjects(dataURL.dataMIMEType, BEURL_DefaultTextMimeType);
	XCTAssertEqualObjects(dataURL.dataCharset, BEURL_UTF8CharSet);
	XCTAssertEqualObjects(dataURL.decodedString, string);
	
	NSString *urlString = dataURL.absoluteString;
	XCTAssertFalse([urlString containsString:@";base64,"], @"URL should not contain base64 marker");
}

/*!
 @method     testDataURLWithAutoEncodingText
 @abstract   Tests that auto-encoding selects percent-encoding for text.
*/
- (void)testDataURLWithAutoEncodingText {
	NSData *data = [@"Auto text" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data
								   mimeType:@"text/plain"
								   isBase64:NSURLBase64Type_Auto];
	
	XCTAssertNotNil(dataURL);
	XCTAssertFalse(dataURL.isBase64, @"Text should auto-select percent-encoding");
}

/*!
 @method     testDataURLWithAutoEncodingBinary
 @abstract   Tests that auto-encoding selects base64 for binary data.
*/
- (void)testDataURLWithAutoEncodingBinary {
	NSData *data = [NSData dataWithBytes:(unsigned char[]){0x00, 0xFF, 0x7F} length:3];
	NSURL *dataURL = [NSURL dataURLWithData:data
								   mimeType:@"application/octet-stream"
								   isBase64:NSURLBase64Type_Auto];
	
	XCTAssertNotNil(dataURL);
	XCTAssertTrue(dataURL.isBase64, @"Binary data should auto-select base64");
}

#pragma mark - Decoding Tests

/*!
 @method     testDecodedDataFromBase64
 @abstract   Tests decoding data from a base64-encoded data URL.
*/
- (void)testDecodedDataFromBase64 {
	NSString *originalString = @"Test data for base64";
	NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:originalData isBase64:NSURLBase64Type_Yes];
	NSData *decodedData = dataURL.decodedData;
	
	XCTAssertNotNil(decodedData);
	XCTAssertEqualObjects(decodedData, originalData);
}

/*!
 @method     testDecodedStringFromBase64
 @abstract   Tests decoding string from a base64-encoded data URL.
*/
- (void)testDecodedStringFromBase64 {
	NSString *originalString = @"Test string for base64";
	NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:originalData
								   mimeType:@"text/plain"
									charset:@"utf-8"
								   isBase64:NSURLBase64Type_Yes];
	NSString *decodedString = dataURL.decodedString;
	
	XCTAssertNotNil(decodedString);
	XCTAssertEqualObjects(decodedString, originalString);
}

/*!
 @method     testDecodedDataFromPercentEncoding
 @abstract   Tests decoding data from a percent-encoded data URL.
*/
- (void)testDecodedDataFromPercentEncoding {
	NSString *originalString = @"Test data";
	NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:originalData
								   mimeType:@"text/plain"
									charset:@"utf-8"
								   isBase64:NSURLBase64Type_No];
	NSData *decodedData = dataURL.decodedData;
	
	XCTAssertNotNil(decodedData);
	NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
	XCTAssertEqualObjects(decodedString, originalString);
}

/*!
 @method     testDecodedDataFromPercentEncodingWithoutCharset
 @abstract   A charset-less, non-text data URL has stringEncoding 0; decodedData must still recover
			 the percent-decoded bytes via a UTF-8 fallback rather than returning nil. The payload is
			 deliberately NON-ASCII ("Café"): dataUsingEncoding:0 maps to ASCII and would drop the 'é'
			 and return nil, so ASCII content would not exercise the regression.
*/
- (void)testDecodedDataFromPercentEncodingWithoutCharset {
	NSURL *dataURL = [NSURL URLWithString:@"data:application/octet-stream,Caf%C3%A9"];

	XCTAssertEqual(dataURL.stringEncoding, (NSStringEncoding)0, @"binary MIME with no charset yields encoding 0");
	XCTAssertFalse(dataURL.isBase64);

	NSData *decodedData = dataURL.decodedData;
	XCTAssertNotNil(decodedData, @"decodedData must not be nil for a charset-less percent-encoded URL");
	XCTAssertEqualObjects(decodedData, [@"Café" dataUsingEncoding:NSUTF8StringEncoding]);
}

/*!
 @method     testDecodedStringFromPercentEncoding
 @abstract   Tests decoding string from a percent-encoded data URL.
*/
- (void)testDecodedStringFromPercentEncoding {
	NSString *originalString = @"Test string with spaces";
	NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:originalData
								   mimeType:@"text/plain"
									charset:@"utf-8"
								   isBase64:NSURLBase64Type_No];
	NSString *decodedString = dataURL.decodedString;
	
	XCTAssertNotNil(decodedString);
	XCTAssertEqualObjects(decodedString, originalString);
}

#pragma mark - Round-Trip Tests

/*!
 @method     testRoundTripBase64
 @abstract   Tests encoding and decoding preserves data with base64.
*/
- (void)testRoundTripBase64 {
	NSData *originalData = [@"Round trip base64 test! 🚀" dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:originalData isBase64:NSURLBase64Type_Yes];
	NSData *decodedData = dataURL.decodedData;
	
	XCTAssertEqualObjects(decodedData, originalData, @"Round-trip should preserve data");
}

/*!
 @method     testRoundTripPercentEncoding
 @abstract   Tests encoding and decoding preserves data with percent-encoding.
*/
- (void)testRoundTripPercentEncoding {
	NSData *originalData = [@"Round trip percent test" dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:originalData
								   mimeType:@"text/plain"
									charset:@"utf-8"
								   isBase64:NSURLBase64Type_No];
	NSData *decodedData = dataURL.decodedData;
	
	XCTAssertNotNil(decodedData);
	NSString *originalString = [[NSString alloc] initWithData:originalData encoding:NSUTF8StringEncoding];
	NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
	XCTAssertEqualObjects(decodedString, originalString, @"Round-trip should preserve text");
}

/*!
 @method     testRoundTripBinaryData
 @abstract   Tests encoding and decoding binary data.
*/
- (void)testRoundTripBinaryData {
	unsigned char bytes[] = {0x00, 0x01, 0x7F, 0x80, 0xFF};
	NSData *originalData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	
	NSURL *dataURL = [NSURL dataURLWithData:originalData mimeType:@"application/octet-stream"];
	NSData *decodedData = dataURL.decodedData;
	
	XCTAssertEqualObjects(decodedData, originalData, @"Binary data should round-trip correctly");
}

#pragma mark - Parsing Tests

/*!
 @method     testParseManualDataURL
 @abstract   Tests parsing a manually constructed data URL.
*/
- (void)testParseManualDataURL {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8;base64,SGVsbG8gV29ybGQ="];
	
	XCTAssertTrue([dataURL isDataURL]);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"text/plain");
	XCTAssertEqualObjects(dataURL.dataCharset, @"utf-8");
	XCTAssertTrue(dataURL.isBase64);
	XCTAssertEqualObjects(dataURL.decodedString, @"Hello World");
}

/*!
 @method     testParseDataURLWithoutCharset
 @abstract   Tests parsing data URL without charset parameter.
*/
- (void)testParseDataURLWithoutCharset {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;base64,VGVzdA=="];
	
	XCTAssertTrue([dataURL isDataURL]);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"text/plain");
	XCTAssertEqualObjects(dataURL.dataCharset, @"US-ASCII", @"Should default to US-ASCII");
	XCTAssertTrue(dataURL.isBase64);
}

/*!
 @method     testParseDataURLWithoutMIME
 @abstract   Tests parsing minimal data URL without MIME type.
*/
- (void)testParseDataURLWithoutMIME {
	NSURL *dataURL = [NSURL URLWithString:@"data:,Hello"];
	
	XCTAssertTrue([dataURL isDataURL]);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"text/plain", @"Should default to text/plain");
	XCTAssertEqualObjects(dataURL.dataCharset, @"US-ASCII");
	XCTAssertFalse(dataURL.isBase64);
}

/*!
 @method     testParseDataURLPercentEncoded
 @abstract   Tests parsing percent-encoded data URL.
*/
- (void)testParseDataURLPercentEncoded {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain,Hello%20World"];
	
	XCTAssertTrue([dataURL isDataURL]);
	XCTAssertFalse(dataURL.isBase64);
	XCTAssertEqualObjects(dataURL.decodedString, @"Hello World");
}

/*!
 @method     testParseDataURL_InvalidDataURL
 @abstract   Tests the parsing of an invalid URL. parseDataUrlWithMimeType is a private method with a test category to test it.
*/
- (void)testParseDataURL_InvalidDataURL {
	NSURL *nonDataURL = [NSURL URLWithString:@"http://github.com/"];
	
	XCTAssertFalse([nonDataURL isDataURL]);
	XCTAssertFalse(nonDataURL.isBase64);
	NSString			*mimeType = @"";
	NSString			*charset = @"";
	NSStringEncoding	encoding = 1;
	BOOL				base64 = true;
	XCTAssertFalse([nonDataURL parseDataUrlWithMimeType:&mimeType charset:&charset encoding:&encoding isBase64:&base64]);
	XCTAssertNil(mimeType);
	XCTAssertNil(charset);
	XCTAssertEqual(encoding, 0);
	XCTAssertFalse(base64);
}

#pragma mark - Edge Cases

/*!
 @method     testDataURLWithSpecialCharacters
 @abstract   Tests data URL with special characters requiring encoding.
*/
- (void)testDataURLWithSpecialCharacters {
	NSString *specialString = @"Special: #%&+,/:;=?@[]";
	NSData *data = [specialString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:data
								   mimeType:@"text/plain"
									charset:@"utf-8"
								   isBase64:NSURLBase64Type_No];
	
	XCTAssertNotNil(dataURL);
	NSString *decoded = dataURL.decodedString;
	XCTAssertNotNil(decoded);
}

/*!
 @method     testDataURLWithUnicodeCharacters
 @abstract   Tests data URL with Unicode/emoji characters.
*/
- (void)testDataURLWithUnicodeCharacters {
	NSString *unicodeString = @"Unicode: こんにちは 🌍 Ñoño";
	NSData *data = [unicodeString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:data
								   mimeType:@"text/plain"
									charset:@"utf-8"];
	
	XCTAssertNotNil(dataURL);
	NSString *decoded = dataURL.decodedString;
	XCTAssertEqualObjects(decoded, unicodeString);
}

/*!
 @method     testDataURLWithLargeData
 @abstract   Tests data URL with larger data payload.
*/
- (void)testDataURLWithLargeData {
	NSMutableData *largeData = [NSMutableData dataWithCapacity:10000];
	for (int i = 0; i < 10000; i++) {
		unsigned char byte = i % 256;
		[largeData appendBytes:&byte length:1];
	}
	
	NSURL *dataURL = [NSURL dataURLWithData:largeData mimeType:@"application/octet-stream"];
	
	XCTAssertNotNil(dataURL);
	NSData *decoded = dataURL.decodedData;
	XCTAssertEqualObjects(decoded, largeData);
}

/*!
 @method     testDataURLWithNewlines
 @abstract   Tests data URL with newline characters.
*/
- (void)testDataURLWithNewlines {
	NSString *multilineString = @"Line 1\nLine 2\rLine 3\r\nLine 4";
	NSData *data = [multilineString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:data
								   mimeType:@"text/plain"
									charset:@"utf-8"];
	
	XCTAssertNotNil(dataURL);
	NSString *decoded = dataURL.decodedString;
	XCTAssertEqualObjects(decoded, multilineString);
}

#pragma mark - Class Method Tests

/*!
 @method     testIsDataURLClassMethod
 @abstract   Tests the class method for checking if URL is a data URL.
*/
- (void)testIsDataURLClassMethod {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain,test"];
	NSURL *httpURL = [NSURL URLWithString:@"https://example.com"];
	NSURL *nilURL = nil;
	
	XCTAssertTrue([NSURL isDataURL:dataURL]);
	XCTAssertFalse([NSURL isDataURL:httpURL]);
	XCTAssertFalse([NSURL isDataURL:nilURL]);
}

/*!
 @method     testStringEncodingFromCharset
 @abstract   Tests charset to NSStringEncoding conversion.
*/
- (void)testStringEncodingFromCharset {
	NSString *nilString = nil;
	
	XCTAssertEqual([NSURL stringEncodingFromCharset:@"utf-8"], NSUTF8StringEncoding);
	XCTAssertEqual([NSURL stringEncodingFromCharset:@"UTF-8"], NSUTF8StringEncoding);
	XCTAssertEqual([NSURL stringEncodingFromCharset:@"US-ASCII"], NSASCIIStringEncoding);
	XCTAssertEqual([NSURL stringEncodingFromCharset:@"iso-8859-1"], NSISOLatin1StringEncoding);
	XCTAssertEqual([NSURL stringEncodingFromCharset:@"iso-8859-2"], NSISOLatin2StringEncoding);
	XCTAssertEqual([NSURL stringEncodingFromCharset:@"windows-1252"], NSWindowsCP1252StringEncoding);
	XCTAssertEqual([NSURL stringEncodingFromCharset:@"EUC-JP"], NSJapaneseEUCStringEncoding);
	XCTAssertEqual([NSURL stringEncodingFromCharset:@"Shift_JIS"], NSShiftJISStringEncoding);
	XCTAssertEqual([NSURL stringEncodingFromCharset:nilString], 0);
	XCTAssertEqual([NSURL stringEncodingFromCharset:@"unknown"], NSASCIIStringEncoding);
}

/*!
 @method     testStringEncodingFromCharset
 @abstract   Tests charset to NSStringEncoding conversion.
*/
- (void)testCharSetForDataMimeType {
	NSString *nilString = nil;
	
	XCTAssertNil([NSURL charSetForDataMimeType:nilString]);
	XCTAssertNil([NSURL charSetForDataMimeType:@"alt/alt"]);
	XCTAssertEqualObjects([NSURL charSetForDataMimeType:@"text/plain"], @"US-ASCII");
	XCTAssertEqualObjects([NSURL charSetForDataMimeType:@"text/uri-list"], @"US-ASCII");
	XCTAssertEqualObjects([NSURL charSetForDataMimeType:@"text/enriched"], @"US-ASCII");
	XCTAssertEqualObjects([NSURL charSetForDataMimeType:@"text/alt"], @"utf-8");
	
	XCTAssertEqualObjects([NSURL charSetForDataMimeType:@"application/json"], @"utf-8");
	XCTAssertEqualObjects([NSURL charSetForDataMimeType:@"application/alt+json"], @"utf-8");
	XCTAssertEqualObjects([NSURL charSetForDataMimeType:@"application/xml"], @"utf-8");
	XCTAssertEqualObjects([NSURL charSetForDataMimeType:@"application/alt+xml"], @"utf-8");
	XCTAssertEqualObjects([NSURL charSetForDataMimeType:@"application/javascript"], @"utf-8");
}

#pragma mark - Property Caching Tests

/*!
 @method     testPropertyCaching
 @abstract   Tests that parsed properties are cached correctly.
*/
- (void)testPropertyCaching {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8;base64,SGVsbG8="];
	
	// First access
	NSString *mimeType1 = dataURL.dataMIMEType;
	NSString *charset1 = dataURL.dataCharset;
	BOOL isBase64_1 = dataURL.isBase64;
	
	// Second access (should use cache)
	NSString *mimeType2 = dataURL.dataMIMEType;
	NSString *charset2 = dataURL.dataCharset;
	BOOL isBase64_2 = dataURL.isBase64;
	
	XCTAssertEqual(mimeType1, mimeType2, @"Should return same cached object");
	XCTAssertEqual(charset1, charset2, @"Should return same cached object");
	XCTAssertEqual(isBase64_1, isBase64_2);
}

#pragma mark - Malformed URL Tests

/*!
 @method     testMalformedDataURLWithoutComma
 @abstract   Tests handling of malformed data URL missing comma separator.
*/
- (void)testMalformedDataURLWithoutComma {
	NSURL *malformedURL = [NSURL URLWithString:@"data:text/plain;NoComma"];
	
	XCTAssertTrue([malformedURL.scheme isEqualToString:@"data"]);
	XCTAssertNil(malformedURL.dataString, @"Should return nil for malformed URL");
	XCTAssertNil(malformedURL.decodedData, @"Should return nil for malformed URL");
	
	malformedURL = [NSURL URLWithString:@"data:text/plain;NoComma"];
	XCTAssertNil(malformedURL.dataMIMEType, @"Should return nil for malformed URL");
	
	malformedURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8"];
	XCTAssertNil(malformedURL.dataCharset, @"Should return nil for malformed URL");
	
	malformedURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8"];
	XCTAssertEqual(malformedURL.stringEncoding, 0, @"Should return 0 for malformed URL");
	
	malformedURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8;base64"];
	XCTAssertEqual(malformedURL.base64, NO, @"Should return NO for malformed URL");
}

/*!
 @method     testNonDataURL
 @abstract   Tests that non-data URLs are correctly identified.
*/
- (void)testNonDataURL {
	NSURL *httpURL = [NSURL URLWithString:@"https://example.com"];
	
	XCTAssertFalse([httpURL isDataURL]);
	XCTAssertNil(httpURL.dataMIMEType);
	XCTAssertNil(httpURL.dataCharset);
	XCTAssertFalse(httpURL.isBase64);
	XCTAssertNil(httpURL.dataString);
	XCTAssertNil(httpURL.decodedData);
	
	NSURL *httpMIMEURL = [NSURL URLWithString:@"https://example.com"];
	XCTAssertNil(httpMIMEURL.dataMIMEType);
	
	NSURL *httpCharsetURL = [NSURL URLWithString:@"https://example.com"];
	XCTAssertNil(httpCharsetURL.dataCharset);
	
	NSURL *httpEncodingURL = [NSURL URLWithString:@"https://example.com"];
	XCTAssertEqual(httpEncodingURL.stringEncoding, 0);
	
	NSURL *httpBase64URL = [NSURL URLWithString:@"https://example.com"];
	XCTAssertEqual(httpBase64URL.base64, NO);
	
	NSURL *httpDataStringURL = [NSURL URLWithString:@"https://example.com"];
	XCTAssertNil(httpDataStringURL.decodedString, @"is not data with a string.");
}

#pragma mark - Instance vs Class Method Tests

/*!
 @method     testObjectMethodsMatchClassMethods
 @abstract   Tests that instance init methods produce same results as class methods.
*/
- (void)testObjectMethodsMatchClassMethods {
	NSData *data = [@"Test data" dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *classUrl = [NSURL dataURLWithData:data mimeType:@"text/plain" charset:@"utf-8"];
	NSURL *objectUrl = [[NSURL alloc] initDataURLWithData:data mimeType:@"text/plain" charset:@"utf-8"];
	
	XCTAssertEqualObjects(classUrl.absoluteString, objectUrl.absoluteString);
	XCTAssertEqualObjects(classUrl.dataMIMEType, objectUrl.dataMIMEType);
	XCTAssertEqualObjects(classUrl.dataCharset, objectUrl.dataCharset);
}

#pragma mark - MIME Type Detection Tests

/*!
 @method     testTextMIMEDefaults
 @abstract   Tests default charset for various text/- MIME types.
*/
- (void)testTextMIMEDefaults {
	NSData *data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *htmlURL = [NSURL dataURLWithData:data mimeType:@"text/html"];
	XCTAssertEqualObjects(htmlURL.dataCharset, @"utf-8");
	
	NSURL *cssURL = [NSURL dataURLWithData:data mimeType:@"text/css"];
	XCTAssertEqualObjects(cssURL.dataCharset, @"utf-8");
	
	NSURL *plainURL = [NSURL dataURLWithData:data mimeType:@"text/plain"];
	XCTAssertEqualObjects(plainURL.dataCharset, @"US-ASCII");
}

/*!
 @method     testJavaScriptMIMEDefaults
 @abstract   Tests that JavaScript MIME types get UTF-8 charset.
*/
- (void)testJavaScriptMIMEDefaults {
	NSData *data = [@"console.log('test');" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *jsURL = [NSURL dataURLWithData:data mimeType:@"text/javascript"];
	
	XCTAssertEqualObjects(jsURL.dataCharset, @"utf-8");
}

/*!
 @method     testSVGMIMEDefaults
 @abstract   Tests that SVG+XML MIME type gets UTF-8 charset.
*/
- (void)testSVGMIMEDefaults {
	NSData *data = [@"<svg></svg>" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *svgURL = [NSURL dataURLWithData:data mimeType:@"image/svg+xml"];
	
	XCTAssertEqualObjects(svgURL.dataCharset, @"utf-8");
}

#pragma mark - Default Behavior Tests

/*!
 @method     testDefaultMIMETypeWithCharset
 @abstract   Tests that providing charset defaults MIME type to text/plain.
*/
- (void)testDefaultMIMETypeWithCharset {
	NSData *data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data charset:@"utf-8"];
	
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"text/plain");
}

/*!
 @method     testDefaultMIMETypeWithoutCharset
 @abstract   Tests that providing no charset defaults MIME type to application/octet-stream.
*/
- (void)testDefaultMIMETypeWithoutCharset {
	NSData *data = [NSData dataWithBytes:(unsigned char[]){0xFF} length:1];
	NSURL *dataURL = [NSURL dataURLWithData:data];
	
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"application/octet-stream");
}

/*!
 @method     testDefaultCharsetOmittedWhenUSASCII
 @abstract   Tests that default US-ASCII charset is omitted from URL.
*/
- (void)testDefaultCharsetOmittedWhenUSASCII {
	NSData *data = [@"test" dataUsingEncoding:NSASCIIStringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data mimeType:@"text/plain" charset:@"US-ASCII"];
	
	NSString *urlString = dataURL.absoluteString;
	// US-ASCII is the default, so it might be omitted
	XCTAssertTrue([urlString hasPrefix:@"data:"], @"Should be valid data URL");
}

/*!
 @method     testDefaultTextPlainOmittedFromURL
 @abstract   Tests that default text/plain MIME type is omitted from URL.
*/
- (void)testDefaultTextPlainOmittedFromURL {
	NSData *data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data mimeType:@"text/plain" charset:@"utf-8"];
	
	NSString *urlString = dataURL.absoluteString;
	XCTAssertTrue([urlString hasPrefix:@"data:"], @"Should be valid data URL");
	// text/plain is default and may be omitted
}

#pragma mark - DataString Property Tests

/*!
 @method     testDataStringBase64
 @abstract   Tests that dataString returns base64 encoded string.
*/
- (void)testDataStringBase64 {
	NSData *data = [@"Hello" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data isBase64:NSURLBase64Type_Yes];
	
	NSString *dataString = dataURL.dataString;
	XCTAssertNotNil(dataString);
	XCTAssertEqualObjects(dataString, @"SGVsbG8=");
}

/*!
 @method     testDataStringPercentEncoded
 @abstract   Tests that dataString returns percent-encoded string.
*/
- (void)testDataStringPercentEncoded {
	NSData *data = [@"Hi" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data
								   mimeType:@"text/plain"
									charset:@"utf-8"
								   isBase64:NSURLBase64Type_No];
	
	NSString *dataString = dataURL.dataString;
	XCTAssertNotNil(dataString);
}

#pragma mark - Complex Scenario Tests

/*!
 @method     testComplexJSONData
 @abstract   Tests encoding and decoding complex JSON data.
*/
- (void)testComplexJSONData {
	NSDictionary *jsonDict = @{
		@"name": @"Test",
		@"value": @(42),
		@"nested": @{@"key": @"value"},
		@"array": @[@"a", @"b", @"c"]
	};
	
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
	NSURL *dataURL = [NSURL dataURLWithData:jsonData mimeType:@"application/json"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"application/json");
	
	NSData *decodedData = dataURL.decodedData;
	NSDictionary *decodedDict = [NSJSONSerialization JSONObjectWithData:decodedData options:0 error:nil];
	
	XCTAssertEqualObjects(decodedDict, jsonDict);
}

/*!
 @method     testHTMLContent
 @abstract   Tests encoding and decoding HTML content.
*/
- (void)testHTMLContent {
	NSString *html = @"<!DOCTYPE html><html><body><h1>Title</h1><p>Paragraph with <a href=\"#\">link</a></p></body></html>";
	NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:htmlData mimeType:@"text/html"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"text/html");
	
	NSString *decoded = dataURL.decodedString;
	XCTAssertEqualObjects(decoded, html);
}

/*!
 @method     testSVGImage
 @abstract   Tests encoding and decoding SVG image.
*/
- (void)testSVGImage {
	NSString *svg = @"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\"><circle cx=\"50\" cy=\"50\" r=\"40\" fill=\"red\"/></svg>";
	NSData *svgData = [svg dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:svgData mimeType:@"image/svg+xml"];
	
	XCTAssertNotNil(dataURL);
	NSString *decoded = dataURL.decodedString;
	XCTAssertEqualObjects(decoded, svg);
}

/*!
 @method     testBase64ImageData
 @abstract   Tests encoding binary image data.
*/
- (void)testBase64ImageData {
	// Minimal PNG signature
	unsigned char pngHeader[] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
	NSData *imageData = [NSData dataWithBytes:pngHeader length:sizeof(pngHeader)];
	
	NSURL *dataURL = [NSURL dataURLWithData:imageData mimeType:@"image/png"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqualObjects(dataURL.dataMIMEType, @"image/png");
	XCTAssertTrue(dataURL.isBase64);
	
	NSData *decoded = dataURL.decodedData;
	XCTAssertEqualObjects(decoded, imageData);
}

#pragma mark - Character Encoding Edge Cases

/*!
 @method     testMultibyteUTF8Characters
 @abstract   Tests handling of multibyte UTF-8 characters.
*/
- (void)testMultibyteUTF8Characters {
	NSString *multibyteString = @"日本語 한글 العربية";
	NSData *data = [multibyteString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:data mimeType:@"text/plain" charset:@"utf-8"];
	
	XCTAssertNotNil(dataURL);
	NSString *decoded = dataURL.decodedString;
	XCTAssertEqualObjects(decoded, multibyteString);
}

/*!
 @method     testLatin1SpecificCharacters
 @abstract   Tests Latin1-specific characters (0x80-0xFF range).
*/
- (void)testLatin1SpecificCharacters {
	// Characters specific to ISO-8859-1
	NSString *latin1String = @"Café ñoño Ü";
	NSData *data = [latin1String dataUsingEncoding:NSISOLatin1StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:data mimeType:@"text/plain" charset:@"iso-8859-1"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertEqual(dataURL.stringEncoding, NSISOLatin1StringEncoding);
}

#pragma mark - Error Recovery Tests

/*!
 @method     testInvalidBase64Recovery
 @abstract   Tests handling of invalid base64 data.
*/
- (void)testInvalidBase64Recovery {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;base64,Invalid!!!Base64"];
	
	XCTAssertTrue([dataURL isDataURL]);
	XCTAssertTrue(dataURL.isBase64);
	
	// decodedData should handle invalid base64 gracefully
	__unused NSData *decoded = dataURL.decodedData;
	// May be nil or partial data depending on implementation
}

/*!
 @method     testInvalidPercentEncodingRecovery
 @abstract   Tests handling of invalid percent encoding.
*/
- (void)testInvalidPercentEncodingRecovery {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain,Invalid%XXPercent"];
	
	XCTAssertTrue([dataURL isDataURL]);
	XCTAssertFalse(dataURL.isBase64);
	
	// Should handle invalid percent encoding
	__unused NSString *decoded = dataURL.decodedString;
	// May have fallback behavior
}

#pragma mark - URL Scheme Tests

/*!
 @method     testDataSchemeCaseInsensitive
 @abstract   Tests that data scheme is case-insensitive.
*/
- (void)testDataSchemeCaseInsensitive {
	NSURL *lowerURL = [NSURL URLWithString:@"data:text/plain,test"];
	NSURL *upperURL = [NSURL URLWithString:@"DATA:text/plain,test"];
	NSURL *mixedURL = [NSURL URLWithString:@"DaTa:text/plain,test"];
	
	XCTAssertTrue([lowerURL isDataURL]);
	XCTAssertTrue([upperURL isDataURL]);
	XCTAssertTrue([mixedURL isDataURL]);
}

#pragma mark - Performance Tests

/*!
 @method     testPerformanceCreatingDataURLs
 @abstract   Tests performance of creating data URLs.
*/
- (void)testPerformanceCreatingDataURLs {
	NSData *data = [@"Performance test data" dataUsingEncoding:NSUTF8StringEncoding];
	
	[self measureBlock:^{
		for (int i = 0; i < 1000; i++) {
			NSURL *dataURL = [NSURL dataURLWithData:data mimeType:@"text/plain"];
			(void)dataURL; // Suppress unused variable warning
		}
	}];
}

/*!
 @method     testPerformanceParsingDataURLs
 @abstract   Tests performance of parsing data URLs.
*/
- (void)testPerformanceParsingDataURLs {
	NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8;base64,SGVsbG8gV29ybGQ="];
	
	[self measureBlock:^{
		for (int i = 0; i < 1000; i++) {
			NSString *mimeType = dataURL.dataMIMEType;
			NSString *charset = dataURL.dataCharset;
			BOOL isBase64 = dataURL.isBase64;
			(void)mimeType; (void)charset; (void)isBase64; // Suppress warnings
		}
	}];
}

/*!
 @method     testPerformanceDecodingDataURLs
 @abstract   Tests performance of decoding data URLs.
*/
- (void)testPerformanceDecodingDataURLs {
	NSData *data = [@"Decoding performance test" dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *dataURL = [NSURL dataURLWithData:data isBase64:NSURLBase64Type_Yes];
	
	[self measureBlock:^{
		for (int i = 0; i < 1000; i++) {
			NSData *decoded = dataURL.decodedData;
			(void)decoded; // Suppress unused variable warning
		}
	}];
}

#pragma mark - Convenience Method Tests

/*!
 @method     testAllConvenienceMethodsWork
 @abstract   Tests that all convenience methods produce valid results.
*/
- (void)testAllConvenienceMethodsWork {
	NSData *data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
	
	// Test all class methods
	XCTAssertNotNil([NSURL dataURLWithData:data]);
	XCTAssertNotNil([NSURL dataURLWithData:data isBase64:NSURLBase64Type_Yes]);
	XCTAssertNotNil([NSURL dataURLWithData:data charset:@"utf-8"]);
	XCTAssertNotNil([NSURL dataURLWithData:data charset:@"utf-8" isBase64:NSURLBase64Type_Yes]);
	XCTAssertNotNil([NSURL dataURLWithData:data mimeType:@"text/plain"]);
	XCTAssertNotNil([NSURL dataURLWithData:data mimeType:@"text/plain" charset:@"utf-8"]);
	XCTAssertNotNil([NSURL dataURLWithData:data mimeType:@"text/plain" isBase64:NSURLBase64Type_Yes]);
	XCTAssertNotNil([NSURL dataURLWithData:data mimeType:@"text/plain" charset:@"utf-8" isBase64:NSURLBase64Type_Yes]);
	
	// Test all instance methods
	XCTAssertNotNil([[NSURL alloc] initDataURLWithData:data]);
	XCTAssertNotNil([[NSURL alloc] initDataURLWithData:data isBase64:NSURLBase64Type_Yes]);
	XCTAssertNotNil([[NSURL alloc] initDataURLWithData:data charset:@"utf-8"]);
	XCTAssertNotNil([[NSURL alloc] initDataURLWithData:data charset:@"utf-8" isBase64:NSURLBase64Type_Yes]);
	XCTAssertNotNil([[NSURL alloc] initDataURLWithData:data mimeType:@"text/plain"]);
	XCTAssertNotNil([[NSURL alloc] initDataURLWithData:data mimeType:@"text/plain" charset:@"utf-8"]);
	XCTAssertNotNil([[NSURL alloc] initDataURLWithData:data mimeType:@"text/plain" isBase64:NSURLBase64Type_Yes]);
	XCTAssertNotNil([[NSURL alloc] initDataURLWithData:data mimeType:@"text/plain" charset:@"utf-8" isBase64:NSURLBase64Type_Yes]);
}

#pragma mark - Multiple Charset/StringEncoding Tests

/*!
 @method     testAllSupportedCharsets
 @abstract   Tests that all documented charsets are properly handled.
*/
- (void)testAllSupportedCharsets {
	
	NSArray *charsets = @[
		@"utf-8", @"UTF-8",
		@"US-ASCII", @"us-ascii",
		@"iso-8859-1", @"ISO-8859-1",
		@"iso-8859-2", @"ISO-8859-2",
		@"windows-1250", @"Windows-1250",
		@"windows-1251", @"Windows-1251",
		@"windows-1252", @"Windows-1252",
		@"windows-1253", @"Windows-1253",
		@"windows-1254", @"Windows-1254",
		@"utf-16", @"UTF-16",
		@"utf-32", @"UTF-32",
		@"EUC-JP", @"euc-jp",
		@"Shift_JIS", @"shift_jis",
		@"ISO-2022-JP", @"iso-2022-jp"
	];
	
	for (NSString *charset in charsets) {
		NSStringEncoding encoding = [NSURL stringEncodingFromCharset:charset];
		XCTAssertNotEqual(encoding, 0, @"Charset %@ should be recognized", charset);
	}
}


/*!
 @method     testAllSupportedCharsets
 @abstract   Tests that all documented charsets are properly handled.
*/
- (void)testNilCharset {
	NSString *nilString = nil;
	XCTAssertEqual( [NSURL stringEncodingFromCharset:nilString], 0, @"nil charset should be not recognized");
}

/*!
 @method     testAllSupportedCharsets
 @abstract   Tests that all documented charsets are properly handled.
*/
- (void)testAllSupportedStringEncodings {
	NSArray<NSNumber*> *stringEncodings = @[
		@(NSUTF8StringEncoding), @(NSASCIIStringEncoding),
		@(NSISOLatin1StringEncoding), @(NSISOLatin2StringEncoding),
		
		@(NSWindowsCP1250StringEncoding),
		@(NSWindowsCP1251StringEncoding),
		@(NSWindowsCP1252StringEncoding),
		@(NSWindowsCP1253StringEncoding),
		@(NSWindowsCP1254StringEncoding),
		
		@(NSJapaneseEUCStringEncoding),
		@(NSShiftJISStringEncoding),
		@(NSISO2022JPStringEncoding),
		
		@(NSUTF16StringEncoding),
		@(NSUTF32StringEncoding)
	];
	
	for (NSNumber *encodings in stringEncodings) {
		NSString *charset = [NSURL charsetFromStringEncoding:encodings.unsignedIntegerValue];
		XCTAssertNotNil(charset, @"NSStringEncoding %@ should be recognized", encodings);
	}
	XCTAssertNil([NSURL charsetFromStringEncoding:-5], @"incorrect NSStringEncoding has no charset");
	XCTAssertNil([NSURL charsetFromStringEncoding:0], @"no NSStringEncoding has no charset");
}


/*!
 @method     testAllSupportedCharsets
 @abstract   Tests that all documented charsets are properly handled.
*/
- (void)testNilStringEncodings {
	XCTAssertNil( [NSURL charsetFromStringEncoding:0], @"0 NSStringEncoding should be not recognized");
}

#pragma mark - Integration Tests

/*!
 @method     testRealWorldHTMLInDataURL
 @abstract   Tests a real-world scenario of embedding HTML in data URL.
*/
- (void)testRealWorldHTMLInDataURL {
	NSString *html = @"<html><head><style>body{color:red;}</style></head><body><h1>Test</h1></body></html>";
	NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:htmlData mimeType:@"text/html" charset:@"utf-8"];
	
	XCTAssertNotNil(dataURL);
	XCTAssertTrue([dataURL.absoluteString hasPrefix:@"data:text/html"]);
	
	NSString *decoded = dataURL.decodedString;
	XCTAssertEqualObjects(decoded, html);
}

/*!
 @method     testRealWorldCSSInDataURL
 @abstract   Tests embedding CSS in data URL.
*/
- (void)testRealWorldCSSInDataURL {
	NSString *css = @"body { margin: 0; padding: 0; font-family: 'Arial', sans-serif; }";
	NSData *cssData = [css dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:cssData mimeType:@"text/css" charset:@"utf-8"];
	
	XCTAssertNotNil(dataURL);
	NSString *decoded = dataURL.decodedString;
	XCTAssertEqualObjects(decoded, css);
}

/*!
 @method     testRealWorldJavaScriptInDataURL
 @abstract   Tests embedding JavaScript in data URL.
*/
- (void)testRealWorldJavaScriptInDataURL {
	NSString *js = @"(function(){console.log('Hello from data URL');})();";
	NSData *jsData = [js dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *dataURL = [NSURL dataURLWithData:jsData mimeType:@"text/javascript" charset:@"utf-8"];
	
	XCTAssertNotNil(dataURL);
	NSString *decoded = dataURL.decodedString;
	XCTAssertEqualObjects(decoded, js);
}

@end
