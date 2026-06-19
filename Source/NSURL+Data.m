/*!
 @file       NSURL+Data.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @date       2025-11-11
 @author     belisoful@icloud.com
 @abstract   Implementation of data URL creation and parsing functionality.
 @discussion This implementation provides comprehensive support for RFC 2397 data URLs,
			 including encoding binary data into data URLs and parsing existing data URLs
			 to extract their content and metadata. Uses associated objects for caching
			 parsed metadata to improve performance on repeated access.
 @see		 https://www.rfc-editor.org/rfc/rfc2397.html
*/

#import <BEFoundation/NSURL+Data.h>
#import <BEFoundation/BEWebData.h>
#import <objc/runtime.h>

NSString * _Nonnull const BEURLDataScheme = @"data";
NSString * _Nonnull const BEURL_DefaultTextMimeType = @"text/plain";
NSString * _Nonnull const BEURL_DefaultDataMimeType = @"application/octet-stream";

NSString * _Nonnull const BEURL_DefaultCharset = @"US-ASCII";
NSString * _Nonnull const BEURL_LatinCharSet_1 = @"iso-8859-1";
NSString * _Nonnull const BEURL_LatinCharSet_2 = @"iso-8859-2";
NSString * _Nonnull const BEURL_Windows1250 = @"windows-1250";
NSString * _Nonnull const BEURL_Windows1251 = @"windows-1251";
NSString * _Nonnull const BEURL_Windows1252 = @"windows-1252";
NSString * _Nonnull const BEURL_Windows1253 = @"windows-1253";
NSString * _Nonnull const BEURL_Windows1254 = @"windows-1254";
NSString * _Nonnull const BEURL_UTF8CharSet = @"utf-8";
NSString * _Nonnull const BEURL_UTF16CharSet = @"utf-16";
NSString * _Nonnull const BEURL_UTF32CharSet = @"utf-32";
NSString * _Nonnull const BEURL_EUC_JP = @"EUC-JP";
NSString * _Nonnull const BEURL_Shift_JIS = @"Shift_JIS";
NSString * _Nonnull const BEURL_ISO_2022_JP = @"ISO-2022-JP";

/*!
 @category      NSURL (DataConstructors)
 @abstract   This category provides multiple convenience methods for creating data URLs.
 @discussion Offers both class methods (dataURLWithData:...) and instance methods
			 (initDataURLWithData:...) for flexibility. All methods ultimately call
			 the master initializer `initDataURLWithData:mimeType:charset:isBase64:`
			 which handles the complete encoding process.
*/
@implementation NSURL (DataConstructors)

+ (NSURL *)dataURLWithData:(NSData *)data {
	return [self dataURLWithData:data mimeType:nil charset:nil isBase64:NSURLBase64Type_Auto];
}
+ (NSURL *)dataURLWithData:(NSData *)data isBase64:(NSURLBase64Type)base64Type {
	return [self dataURLWithData:data mimeType:nil charset:nil isBase64:base64Type];
}
+ (NSURL *)dataURLWithData:(NSData *)data charset:(NSString *)charset {
	return [self dataURLWithData:data mimeType:nil charset:charset isBase64:NSURLBase64Type_Auto];
}
+ (NSURL *)dataURLWithData:(NSData *)data charset:(NSString *)charset isBase64:(NSURLBase64Type)base64Type {
	return [self dataURLWithData:data mimeType:nil charset:charset isBase64:base64Type];
}
+ (NSURL *)dataURLWithData:(NSData *)data mimeType:(NSString *)mimeType {
	return [self dataURLWithData:data mimeType:mimeType charset:nil isBase64:NSURLBase64Type_Auto];
}
+ (NSURL *)dataURLWithData:(NSData *)data mimeType:(NSString *)mimeType charset:(NSString *)charset {
	return [self dataURLWithData:data mimeType:mimeType charset:charset isBase64:NSURLBase64Type_Auto];
}
+ (NSURL *)dataURLWithData:(NSData *)data mimeType:(NSString *)mimeType isBase64:(NSURLBase64Type)base64Type {
	return [self dataURLWithData:data mimeType:mimeType charset:nil isBase64:base64Type];
}
+ (NSURL *)dataURLWithData:(NSData *)data mimeType:(NSString *)mimeType charset:(NSString *)charset isBase64:(NSURLBase64Type)base64Type {
	return [self.alloc initDataURLWithData:data mimeType:mimeType charset:charset isBase64:base64Type];
}


- (NSURL *)initDataURLWithData:(NSData *)data {
	return [self initDataURLWithData:data mimeType:nil charset:nil isBase64:NSURLBase64Type_Auto];
}
- (NSURL *)initDataURLWithData:(NSData *)data isBase64:(NSURLBase64Type)base64Type {
	return [self initDataURLWithData:data mimeType:nil charset:nil isBase64:base64Type];
}
- (NSURL *)initDataURLWithData:(NSData *)data charset:(NSString *)charset {
	return [self initDataURLWithData:data mimeType:nil charset:charset isBase64:NSURLBase64Type_Auto];
}
- (NSURL *)initDataURLWithData:(NSData *)data charset:(NSString *)charset isBase64:(NSURLBase64Type)base64Type {
	return [self initDataURLWithData:data mimeType:nil charset:charset isBase64:base64Type];
}
- (NSURL *)initDataURLWithData:(NSData *)data mimeType:(NSString *)mimeType {
	return [self initDataURLWithData:data mimeType:mimeType charset:nil isBase64:NSURLBase64Type_Auto];
}
- (NSURL *)initDataURLWithData:(NSData *)data mimeType:(NSString *)mimeType charset:(NSString *)charset {
	return [self initDataURLWithData:data mimeType:mimeType charset:charset isBase64:NSURLBase64Type_Auto];
}
- (NSURL *)initDataURLWithData:(NSData *)data mimeType:(NSString *)mimeType isBase64:(NSURLBase64Type)base64Type {
	return [self initDataURLWithData:data mimeType:mimeType charset:nil isBase64:base64Type];
}


/*!
 @method     initDataURLWithData:mimeType:charset:isBase64:
 @abstract   Master initialization method for creating data URLs from binary data.
 @param      data The binary data to encode.
 @param      mimeType The MIME type (optional, defaults based on charset).
 @param      charset The character set name (optional, defaults based on MIME type).
 @param      base64Type Encoding preference (auto, base64, or percent-encoding).
 @discussion This method performs the following steps:
			 1. Validates input data (returns nil if data is nil)
			 2. Determines appropriate MIME type and charset based on parameters
			 3. Selects encoding method (base64 vs percent-encoding)
			 4. Encodes the data appropriately
			 5. Constructs the complete data URL string
			 
			 The method follows RFC 2397 format:
			 data:[<mediatype>][;charset=<charset>][;base64],<data>
			 
			 Default behaviors:
			 - If charset is provided, MIME type defaults to "text/plain"
			 - If no charset, MIME type defaults to "application/octet-stream"
			 - Text-based MIME types get charset and prefer percent-encoding
			 - Binary MIME types prefer base64 encoding
			 - Auto mode intelligently selects encoding based on content type
 @return     An initialized NSURL object, or nil if encoding fails.
*/
- (NSURL *)initDataURLWithData:(NSData *)data mimeType:(NSString *)mimeType charset:(NSString *)charset isBase64:(NSURLBase64Type)base64Type
{
	if (!data) {
		return nil;
	} else if ([data isKindOfClass:BEWebData.class]) {
		BEWebData *webData = (BEWebData*)data;
		if (!mimeType) {
			mimeType = webData.MIMEType;
		}
		if (!charset) {
			charset = webData.charset;
		}
	}
	if (mimeType == nil) {
		// Initialize mimeType
		if (charset) {
			mimeType = BEURL_DefaultTextMimeType;
		} else {
			mimeType = BEURL_DefaultDataMimeType;
		}
	}
	
	if ([self.class hasCharSetForMIMEType:mimeType]) {
		if (!charset) {
			charset = [self.class charSetForDataMimeType:mimeType];
		}
		if (base64Type == NSURLBase64Type_Auto) {
			base64Type = NSURLBase64Type_No;
		}
	} else if (base64Type == NSURLBase64Type_Auto) {
		charset = nil;
		base64Type = NSURLBase64Type_Yes;
	}
	NSUInteger infoSize =
		5 + // "data:"
		(mimeType.length > 0 && ![mimeType isEqualToString:BEURL_DefaultTextMimeType] ? mimeType.length : 0) +
		(charset.length > 0 && ![charset isEqualToString:BEURL_DefaultCharset] ? charset.length + 9 : 0) + // ";charset="
		(base64Type == NSURLBase64Type_Yes ? 7 : 0) + // ";base64"
		1; // comma
	
	NSString *dataString = nil;
	
	NSUInteger encodedLength = (base64Type == NSURLBase64Type_Yes)
		? ((4 * ((data.length + 2) / 3))) + 8
		: ((NSUInteger)(data.length * 5.0 / 3.0)); // URL percent-encoding expansion estimate for natural language
		
	if (base64Type == NSURLBase64Type_Yes) {
		dataString = [data base64EncodedStringWithOptions:0];
		encodedLength = dataString.length;
	} else {
		NSStringEncoding encoding = [self.class stringEncodingFromCharset:charset];
		BOOL triedUTF8 = (encoding == NSUTF8StringEncoding);
		dataString = [NSString.alloc initWithData:data encoding:encoding];
		
		if (!dataString) {
			/*
			if (!dataString) {
				encoding = NSNonLossyASCIIStringEncoding;
				dataString = [NSString.alloc initWithData:data encoding:encoding];
				if (dataString) {
					charset = BEURL_DefaultCharset;
				}
			}
			*/
			if (!dataString && !triedUTF8) {
				triedUTF8 = YES;
				encoding = NSUTF8StringEncoding;
				dataString = [NSString.alloc initWithData:data encoding:encoding];
				if (dataString) {
					charset = BEURL_UTF8CharSet;
				}
			}
		}
		if (!dataString) {
			return nil;
		}
		encodedLength = (dataString.length * 5) / 3;
	}
	
	
	
	NSMutableString *urlString = [NSMutableString.alloc initWithCapacity:infoSize + encodedLength];
	
	[urlString appendString:BEURLDataScheme];
	[urlString appendString:@":"];
	
	if (![mimeType isEqualToString:BEURL_DefaultTextMimeType]) {
		[urlString appendString:mimeType];
	}
	if (charset && ![charset isEqualToString:BEURL_DefaultCharset]) {
		[urlString appendString:@";charset="];
		[urlString appendString:charset];
	}
	
	if (base64Type == NSURLBase64Type_Yes) {
		[urlString appendString:@";base64,"];
		[urlString appendString:dataString];
	} else {
		//NSString *dataString = nil;
		NSMutableCharacterSet *urlCharacters = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
		[urlCharacters addCharactersInString:@"-._~"];
		
		[urlString appendString:@","];
		[urlString appendString:[dataString stringByAddingPercentEncodingWithAllowedCharacters:urlCharacters]];
	}
	
	return [self initWithString:urlString];
}


/*!
 @method     hasCharSetForMIMEType:
 @abstract   Determines if a MIME type typically requires a charset parameter.
 @param      mimeType The MIME type to check.
 @discussion Text-based MIME types (text/-, -/xml, -/json, -/javascript) should
			 include charset information. This method identifies such types.
 @return     YES if the MIME type is text-based and should have a charset, NO otherwise.
*/
+ (BOOL)hasCharSetForMIMEType:(NSString*)mimeType
{
	if ([mimeType hasPrefix:@"text/"] ||
		[mimeType hasSuffix:@"/json"] ||
		[mimeType hasSuffix:@"+json"] ||
		[mimeType hasSuffix:@"/xml"] ||
		[mimeType hasSuffix:@"+xml"] ||
		[mimeType hasSuffix:@"/javascript"]) {
		return YES;
	}
	return NO;
}


/*!
 @method     charSetForMimeType:
 @abstract   Returns the default charset for a given MIME type.
 @param      mimeType The MIME type.
 @discussion Provides sensible defaults:
			 - Plain text types (text/plain, text/uri-list, text/enriched): US-ASCII
			 - Other text/- types: UTF-8
			 - JSON, XML, JavaScript: UTF-8
			 - Other types: nil (no charset)
 @return     The default charset name, or nil if not applicable.
*/
+ (NSString *)charSetForDataMimeType:(NSString*)mimeType
{
	if (!mimeType) {
		return nil;
	}
	if ([mimeType isEqualToString:@"text/plain"] ||
		[mimeType isEqualToString:@"text/uri-list"] ||
		[mimeType isEqualToString:@"text/enriched"]) {
		return BEURL_DefaultCharset; // US-ASCII
	} else if ([mimeType hasPrefix:@"text/"]) {
		return BEURL_UTF8CharSet;
	}

	// Common text-based types default to UTF-8
	if ([mimeType hasSuffix:@"/json"] ||
		[mimeType hasSuffix:@"+json"] ||
		[mimeType hasSuffix:@"/xml"] ||
		[mimeType hasSuffix:@"+xml"] ||
		[mimeType hasSuffix:@"/javascript"]) {
		return BEURL_UTF8CharSet;
	}

	return nil;
}

@end



/*!
 @category      NSURL (Data)
 @abstract   This category provides parsing and decoding functionality for data URLs.
 @discussion Extracts metadata (MIME type, charset, encoding method) and content from
			 data URLs. Uses Objective-C associated objects to cache parsed values,
			 ensuring that expensive parsing operations are only performed once per URL.
			 
			 All properties are read-only and lazily evaluated. The first access to
			 any property triggers parsing of the data URL, and results are cached
			 for subsequent accesses.
*/
@implementation NSURL (Data)

/*!
 @method     parseDataUrl:charset:encoding:isBase64:
 @abstract   Internal method to parse data URL metadata for the current URL.
 @param      mimeType Pointer to receive the parsed MIME type.
 @param      charset Pointer to receive the parsed charset.
 @param      encoding Pointer to receive the NSStringEncoding.
 @param      base64 Pointer to receive the base64 encoding flag.
 @discussion Calls the full parsing method with the URL's resource specifier.
*/
- (BOOL)parseDataUrlWithMimeType:(NSString**)mimeType charset:(NSString**)charset encoding:(NSStringEncoding*)encoding isBase64:(BOOL*)base64
{
	return [self parseDataUrl:self.resourceSpecifier mimeType:mimeType charset:charset encoding:encoding isBase64:base64];
}


/*!
 @method     parseDataUrl:mimeType:charset:encoding:isBase64:
 @abstract   Parses data URL metadata and caches the results using associated objects.
 @param      resourceSpecifier The portion of the URL after "data:".
 @param      mimeType Pointer to receive the parsed MIME type.
 @param      charset Pointer to receive the parsed charset.
 @param      encoding Pointer to receive the NSStringEncoding.
 @param      base64 Pointer to receive the base64 encoding flag.
 @discussion Implements RFC 2397 parsing:
			 1. Verifies this is a data URL
			 2. Locates the comma separator between metadata and data
			 3. Parses semicolon-separated metadata components
			 4. Extracts MIME type (defaults to "text/plain")
			 5. Extracts charset parameter (defaults to "US-ASCII")
			 6. Detects ";base64" flag
			 7. Caches all parsed values using associated objects
			 
			 If parsing fails (malformed URL), marks the URL as not a data URL.
*/
- (BOOL)parseDataUrl:(NSString *)resourceSpecifier mimeType:(NSString**)mimeType charset:(NSString**)charset encoding:(NSStringEncoding*)encoding isBase64:(BOOL*)base64
{
	if (!self.isDataURL) {
		if (mimeType)	*mimeType = nil;
		if (charset)	*charset = nil;
		if (encoding)	*encoding = 0;
		if (base64)		*base64 = NO;
		return NO;
	}
	// 2. Locate the comma separating metadata from data
	NSRange commaRange = [resourceSpecifier rangeOfString:@","];
	if (commaRange.location == NSNotFound) {
		// Malformed data URL
		objc_setAssociatedObject(self, @selector(isDataURL), @(NO), OBJC_ASSOCIATION_RETAIN);
		if (mimeType)	*mimeType = nil;
		if (charset)	*charset = nil;
		if (encoding)	*encoding = 0;
		if (base64)		*base64 = NO;
		return NO;
	}
	
	// 3. Extract meta info and payload
	NSString *meta = [resourceSpecifier substringToIndex:commaRange.location];
	
	// 5. Split meta into parts
	NSArray<NSString *> *parts = [meta componentsSeparatedByString:@";"];
	
	// 6. Default values
	NSString *dataMimeType = @"text/plain";
	NSString *dataCharset = nil;
	BOOL isBase64 = NO;
	
	// 7. Parse MIME type and parameters
	if (parts.count > 0) {
		if (parts[0].length > 0) {
			dataMimeType = parts[0]; // first part is MIME type if present
		}
		for (NSUInteger i = 1; i < parts.count; i++) {
			NSString *p = parts[i];
			if ([p isEqualToString:@"base64"]) {
				isBase64 = YES;
			} else if ([p hasPrefix:@"charset="]) {
				dataCharset = [p substringFromIndex:8];
			}
		}
	}
	if (!dataCharset && [self.class hasCharSetForMIMEType:dataMimeType]) {
		dataCharset = BEURL_DefaultCharset;
	}
	NSStringEncoding dataEncoding = [self.class stringEncodingFromCharset:dataCharset];
	
	objc_setAssociatedObject(self, @selector(dataMIMEType), dataMimeType, OBJC_ASSOCIATION_RETAIN);
	objc_setAssociatedObject(self, @selector(dataCharset), dataCharset, OBJC_ASSOCIATION_RETAIN);
	objc_setAssociatedObject(self, @selector(stringEncoding), @(dataEncoding), OBJC_ASSOCIATION_RETAIN);
	objc_setAssociatedObject(self, @selector(isBase64), @(isBase64), OBJC_ASSOCIATION_RETAIN);
	
	if (mimeType)	*mimeType = dataMimeType;
	if (charset)	*charset = dataCharset;
	if (encoding)	*encoding = dataEncoding;
	if (base64)		*base64 = isBase64;
	
	return YES;
}


/*!
 @method     isDataURL
 @abstract   Checks if this URL uses the "data:" scheme.
 @discussion Uses associated objects to cache the result. Case-insensitive comparison.
 @return     YES if the URL scheme is "data", NO otherwise.
*/
- (BOOL)isDataURL
{
	NSNumber *isDataUrlNumber = objc_getAssociatedObject(self, @selector(isDataURL));
	BOOL isDataURL;
	
	if (!isDataUrlNumber) {
		isDataURL = [self.scheme.lowercaseString isEqualToString:BEURLDataScheme];
		objc_setAssociatedObject(self, @selector(isDataURL), @(isDataURL), OBJC_ASSOCIATION_RETAIN);
	} else {
		isDataURL = isDataUrlNumber.boolValue;
	}
	
	return isDataURL;
}


/*!
 @method     isDataURL:
 @abstract   Class method to check if any URL is a data URL.
 @param      url The URL to check.
 @discussion Convenience method for checking URLs without an instance.
			 Performs nil check before testing scheme.
 @return     YES if url is non-nil and uses "data:" scheme, NO otherwise.
*/
+ (BOOL)isDataURL:(NSURL*)url
{
	if (!url) {
		return NO;
	}
	return [url.scheme.lowercaseString isEqualToString:BEURLDataScheme];
}


/*!
 @method     dataMIMEType
 @abstract   Returns the MIME type from the data URL.
 @discussion Lazily parses and caches the MIME type. Defaults to "text/plain"
			 if not explicitly specified in the data URL.
 @return     The MIME type string, or nil for non-data URLs.
*/
- (NSString *)dataMIMEType
{
	if (!self.isDataURL) {
		return nil;
	}
	
	NSString *dataMIMEType = objc_getAssociatedObject(self, @selector(dataMIMEType));
	
	if (!dataMIMEType) {
		NSString *mimeType = nil;
		[self parseDataUrlWithMimeType:&mimeType charset:nil encoding:nil isBase64:nil];
		dataMIMEType = mimeType;
	}
	return dataMIMEType;
}


/*!
 @method     dataCharset
 @abstract   Returns the charset from the data URL.
 @discussion Lazily parses and caches the charset. Defaults to "US-ASCII"
			 if not explicitly specified in the data URL.
 @return     The charset string, or nil for non-data URLs.
*/
- (NSString *)dataCharset
{
	if (!self.isDataURL) {
		return nil;
	}
	
	NSString *dataCharset = objc_getAssociatedObject(self, @selector(dataCharset));
	
	if (!dataCharset) {
		NSString *charset = nil;
		[self parseDataUrlWithMimeType:nil charset:&charset encoding:nil isBase64:nil];
		dataCharset = charset;
	}
	return dataCharset;
}


/*!
 @method     stringEncoding
 @abstract   Returns the NSStringEncoding corresponding to the charset.
 @discussion Lazily parses the charset and converts it to NSStringEncoding.
			 Uses the stringEncodingFromCharset: class method for conversion.
 @return     The NSStringEncoding value, or 0 for non-data URLs.
*/
- (NSStringEncoding)stringEncoding
{
	if (!self.isDataURL) {
		return 0;
	}
	
	NSNumber *stringEncoding = objc_getAssociatedObject(self, @selector(stringEncoding));
	
	NSStringEncoding encoding = 0;
	if (!stringEncoding) {
		[self parseDataUrlWithMimeType:nil charset:nil encoding:&encoding isBase64:nil];
	} else {
		encoding = stringEncoding.integerValue;
	}
	return encoding;
}


/*!
 @method     isBase64
 @abstract   Indicates whether the data URL uses base64 encoding.
 @discussion Lazily parses and caches the encoding flag. Checks for the ";base64"
			 parameter in the data URL metadata.
 @return     YES if base64-encoded, NO if percent-encoded or for non-data URLs.
*/
- (BOOL)isBase64
{
	if (!self.isDataURL) {
		return NO;
	}
	
	NSNumber	*isBase64Number = objc_getAssociatedObject(self, @selector(isBase64));

	BOOL	isBase64 = NO;
	if (!isBase64Number) {
		[self parseDataUrlWithMimeType:nil charset:nil encoding:nil isBase64:&isBase64];
	} else {
		isBase64 = isBase64Number.boolValue;
	}
	return isBase64;
}


/*!
 @method     dataString
 @abstract   Returns the raw encoded data portion of the data URL.
 @discussion Extracts the string after the comma separator. This is the actual
			 encoded data, either in base64 or percent-encoded format, without
			 any decoding applied.
 @return     The encoded data string, or nil for malformed or non-data URLs.
*/
- (NSString *)dataString
{
	if (!self.isDataURL) {
		return nil;
	}
	
	NSString *resourceSpecifier = self.resourceSpecifier;
	
	[self parseDataUrl:resourceSpecifier mimeType:nil charset:nil encoding:nil isBase64:nil];
	
	NSRange commaRange = [resourceSpecifier rangeOfString:@","];
	if (commaRange.location == NSNotFound) {
		return nil;
	}
	return [resourceSpecifier substringFromIndex:commaRange.location + 1];
}


/*!
 @method     decodedData
 @abstract   Returns the decoded binary data from the data URL.
 @discussion Decodes the data URL content based on its encoding:
			 - For base64: Uses base64 decoding
			 - For percent-encoding: Removes percent encoding and converts to NSString by self.stringEncoding
 @return     The decoded NSData, or nil if decoding fails or for non-data URLs.
*/
- (NSData *)decodedData
{
	NSString *dataString = [self dataString];
	if (!dataString) {
		return nil;
	}
	
	NSData *decodedData = nil;
	if (self.isBase64) {
		decodedData = [[NSData alloc] initWithBase64EncodedString:dataString options:0];
	} else {
		NSString *decodedString = [dataString stringByRemovingPercentEncoding];
		// stringEncoding is 0 for a charset-less, non-text data URL (e.g. application/octet-stream).
		// dataUsingEncoding:0 falls back to a deprecated ASCII mapping that drops non-ASCII bytes (and
		// Foundation warns it is going away), so use UTF-8 to recover the percent-decoded content.
		NSStringEncoding encoding = self.stringEncoding ?: NSUTF8StringEncoding;
		decodedData = [decodedString dataUsingEncoding:encoding];
	}
	return decodedData;
}


/*!
 @method     decodedString
 @abstract   Returns the decoded string content from the data URL.
 @discussion Decodes the data URL and interprets the result as a string:
			 - For base64: Decodes base64, then converts to self.stringEncoding string
			 - For percent-encoding: Removes percent encoding directly
 @return     The decoded string, or nil if decoding fails or for non-data URLs.
*/
- (NSString *)decodedString
{
	NSString *dataString = [self dataString];
	if (!dataString) {
		return nil;
	}
	
	NSString *decodedString = nil;
	if (self.isBase64) {
		NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:dataString options:0];
		// Same charset-less fallback as -decodedData: encoding 0 would make initWithData: return nil.
		NSStringEncoding encoding = self.stringEncoding ?: NSUTF8StringEncoding;
		decodedString = [NSString.alloc initWithData:decodedData encoding:encoding];
	} else {
		decodedString = [dataString stringByRemovingPercentEncoding];
	}
	return decodedString;
}


/*!
 @method     stringEncodingFromCharset:
 @abstract   Converts charset names to NSStringEncoding values.
 @param      charset The charset name (case-insensitive).
 @discussion Supports common charset names including:
			 - UTF-8, UTF-16, UTF-32
			 - US-ASCII
			 - ISO-8859-1, ISO-8859-2 (Latin1/Latin2)
			 - Windows code pages (1250-1254)
			 - Japanese encodings (EUC-JP, Shift_JIS, ISO-2022-JP)
			 
			 All comparisons are case-insensitive. Returns NSASCIIStringEncoding
			 for unrecognized charsets.
 @return     The corresponding NSStringEncoding for the charset, or NSASCIIStringEncoding as fallback.
*/
+ (NSStringEncoding)stringEncodingFromCharset:(NSString*)charset
{
	if (!charset) {
		return 0;
	}
	NSString *lowerCharset = charset.lowercaseString;
	if ([lowerCharset isEqualToString:BEURL_UTF8CharSet]) {
		return NSUTF8StringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_DefaultCharset.lowercaseString]) {
		return NSASCIIStringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_LatinCharSet_1.lowercaseString]) {
		return NSISOLatin1StringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_LatinCharSet_2.lowercaseString]) {
		return NSISOLatin2StringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_Windows1250.lowercaseString]) {
		return NSWindowsCP1250StringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_Windows1251.lowercaseString]) {
		return NSWindowsCP1251StringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_Windows1252.lowercaseString]) {
		return NSWindowsCP1252StringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_Windows1253.lowercaseString]) {
		return NSWindowsCP1253StringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_Windows1254.lowercaseString]) {
		return NSWindowsCP1254StringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_EUC_JP.lowercaseString]) {
		return NSJapaneseEUCStringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_Shift_JIS.lowercaseString]) {
		return NSShiftJISStringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_ISO_2022_JP.lowercaseString]) {
		return NSISO2022JPStringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_UTF16CharSet.lowercaseString]) {
		return NSUTF16StringEncoding;
	} else if ([lowerCharset isEqualToString:BEURL_UTF32CharSet.lowercaseString]) {
		return NSUTF32StringEncoding;
	}
	return NSASCIIStringEncoding;
}


/*!
 @method     charsetFromStringEncoding:
 @abstract   Converts NSStringEncoding values to charset names .
 @param      stringEncoding The NSStringEncoding to produce the charset names.
 @discussion Supports common charset names including:
			 - NSUTF8StringEncoding, NSUTF16StringEncoding, NSUTF32StringEncoding
			 - NSASCIIStringEncoding
			 - NSISOLatin1StringEncoding, NSISOLatin2StringEncoding
			 - NSWindowsCP1250StringEncoding - NSWindowsCP1254StringEncoding
			 - Japanese encodings (NSJapaneseEUCStringEncoding, NSShiftJISStringEncoding, NSISO2022JPStringEncoding)
 @return     The corresponding charset for the NSStringEncoding , or nil as fallback.
*/
+ (NSString*)charsetFromStringEncoding:(NSStringEncoding)stringEncoding
{
	if (!stringEncoding) {
		return nil;
	}
	NSString *returnValue = nil;
	switch (stringEncoding) {
		case NSUTF8StringEncoding:
			returnValue = BEURL_UTF8CharSet;		break;
		case NSASCIIStringEncoding:
			returnValue = BEURL_DefaultCharset;	break;
		case NSISOLatin1StringEncoding:
			returnValue = BEURL_LatinCharSet_1;	break;
		case NSISOLatin2StringEncoding:
			returnValue = BEURL_LatinCharSet_2;	break;
			
		case NSWindowsCP1250StringEncoding:
			returnValue = BEURL_Windows1250;		break;
		case NSWindowsCP1251StringEncoding:
			returnValue = BEURL_Windows1251;		break;
		case NSWindowsCP1252StringEncoding:
			returnValue = BEURL_Windows1252;		break;
		case NSWindowsCP1253StringEncoding:
			returnValue = BEURL_Windows1253;		break;
		case NSWindowsCP1254StringEncoding:
			returnValue =  BEURL_Windows1254;		break;
			
		case NSJapaneseEUCStringEncoding:
			returnValue = BEURL_EUC_JP;			break;
		case NSShiftJISStringEncoding:
			returnValue = BEURL_Shift_JIS;			break;
		case NSISO2022JPStringEncoding:
			returnValue = BEURL_ISO_2022_JP;		break;
			
		case NSUTF16StringEncoding:
			returnValue = BEURL_UTF16CharSet;		break;
		case NSUTF32StringEncoding:
			returnValue =  BEURL_UTF32CharSet;		break;
	}
	return returnValue;
}

@end
