/*!
 @file       BEWebData.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @date       2025-11-11
 @author     belisoful@icloud.com
 @abstract   Implementation of BEWebData subclass of NSData.
 @discussion This class extends NSData to support loading data from data URLs
			 and preserving metadata (MIME type, charset, encoding) from those URLs.
			 Supports NSCoding for archiving and unarchiving.
 @see		 https://www.rfc-editor.org/rfc/rfc2397.html
*/

#import <BEFoundation/BEWebData.h>
#import <BEFoundation/NSURL+Data.h>
#import <objc/runtime.h>

NSDataReadingOptions const BEDataReadingAsynchronous = (1 << 20);
NSDataReadingOptions const BEDataReadingSynchronous = (0);

@implementation BEWebData
{
	NSData	*_data;
	BOOL	_isComplete;
}

@synthesize MIMEType = _MIMEType;
@synthesize charset = _charset;
@synthesize stringEncoding = _stringEncoding;
@synthesize base64 = _base64;
// Custom @synchronized getters below suppress auto-synthesis, so back these explicitly.
@synthesize dataTask = _dataTask;
@synthesize dataTaskResponse = _dataTaskResponse;
@synthesize dataTaskError = _dataTaskError;

static NSURLSessionConfiguration *s_defaultSessionConfiguration = nil;

#pragma mark - Class methods

/*!
 @method     defaultSessionConfiguration
 @abstract   The session configuration used for @c http / @c https loads.
 @discussion When @c nil (the default), loads use @c +[NSURLSession sharedSession]. Set a
             configuration to route loads through a custom @c NSURLSession, for example to
             inject a mock @c NSURLProtocol in tests. Introduced in 1.1.
 @return     The injected configuration, or @c nil.
*/
+ (nullable NSURLSessionConfiguration *)defaultSessionConfiguration
{
	return s_defaultSessionConfiguration;
}

+ (void)setDefaultSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration
{
	s_defaultSessionConfiguration = [configuration copy];
}

/*!
 @method     isDataURL:
 @abstract   Class method to check if a URL is a data URL.
 @param      url The URL to check.
 @discussion Convenience wrapper around NSURL's isDataURL: method.
 @return     YES if the URL uses the "data:" scheme, NO otherwise.
*/
+ (BOOL)isDataURL:(NSURL*)url
{
	if (!url || ![url isKindOfClass:NSURL.class]) {
		return NO;
	}
	return [url.scheme.lowercaseString isEqualToString:BEURLDataScheme];
}

/*!
 @method     dataWithContentsOfURL:
 @abstract   Creates a new BEWebData instance from a URL.
 @param      url The URL to load data from (supports data URLs and regular URLs).
 @discussion Convenience constructor that calls the designated initializer.
 @return     A new BEWebData instance, or nil if loading fails.
*/
+ (instancetype)dataWithContentsOfURL:(NSURL *)url {
	return [self.alloc initWithContentsOfURL:url];
}

/*!
 @method     dataWithContentsOfURL:options:error:
 @abstract   Creates a new BEWebData instance from a URL with options.
 @param      url The URL to load data from.
 @param      options Options for reading data (applies to regular URLs only).
 @param      error Pointer to receive any error that occurs.
 @discussion For data URLs, options are ignored. For regular URLs, options are passed to NSData.
 @return     A new BEWebData instance, or nil if loading fails.
*/
+ (instancetype)dataWithContentsOfURL:(NSURL *)url
							  options:(NSDataReadingOptions)options
								error:(NSError **)error
{
	return [self.alloc initWithContentsOfURL:url options:options error:error];
}

#pragma mark - BEWebData Properties


/*!
 @method     setCharset:
 @abstract   Sets the charset of the BEWebData.
 @param      charset	The charset of the data.
 @discussion charset is used in NSURL (Data).
*/
/* - (void)setCharset:(NSString *)charset
{
	_charset = charset;
	_stringEncoding = [NSURL stringEncodingFromCharset:charset];
}

- (void)setStringEncoding:(NSStringEncoding)stringEncoding
{
	_stringEncoding = stringEncoding;
	_charset = [NSURL charsetFromStringEncoding:stringEncoding];
}
 */


/*!
 @method     setDataTaskCompletionHandler:
 @abstract   Sets the completion handler for downloading content.
 @param      completionBlock	`BEWebDataCompletionBlock` callback on completing the web content.
 @discussion When the data isComplete, this automatically calls the completionBlock thus is called immediately for file and data urls.
*/
- (void)setDataTaskCompletionHandler:(BEWebDataCompletionBlock)completionBlock
{
	BEWebDataCompletionBlock handler = [completionBlock copy];
	BOOL callNow = NO;
	NSURLResponse *response = nil;
	NSError *taskError = nil;
	@synchronized (self) {
		_dataTaskCompletionHandler = handler;
		// Coordinated with the download completion block (which also sets _isComplete and reads
		// _dataTaskCompletionHandler under this lock) so the handler fires exactly once.
		if (_isComplete) {
			callNow = YES;
			response = _dataTaskResponse;
			taskError = _dataTaskError;
		}
	}
	if (callNow && handler) {
		handler(self, response, taskError);
	}
}

- (BOOL)isComplete {
	@synchronized (self) { return _isComplete; }
}

// The metadata and task results below are filled by the asynchronous download completion block
// (which writes them under @synchronized(self)); read them under the same lock so a caller that
// inspects an in-flight HTTP/HTTPS load before isComplete is YES never races the background write.
- (nullable NSString *)MIMEType {
	@synchronized (self) { return _MIMEType; }
}

- (nullable NSString *)charset {
	@synchronized (self) { return _charset; }
}

- (NSStringEncoding)stringEncoding {
	@synchronized (self) { return _stringEncoding; }
}

- (nullable NSURLResponse *)dataTaskResponse {
	@synchronized (self) { return _dataTaskResponse; }
}

- (nullable NSError *)dataTaskError {
	@synchronized (self) { return _dataTaskError; }
}

- (nullable NSURLSessionDataTask *)dataTask {
	@synchronized (self) { return _dataTask; }
}

#pragma mark - Base Implementation


/*!
 @method     initWithBytes:length:
 @abstract   Initialize the BEWebData with bytes of a length.
 @param      bytes	The bytes to encapsulate.
 @param      length	The length of the bytes to encapsulate.
 @discussion This uses an internal "data" to implement the container.
*/
- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length {
	self = [super init];
	if (self) {
		_data = [NSData dataWithBytes:bytes length:length];
		_isComplete = YES;
	}
	return self;
}


/*!
 @method     initWithBytes:length:copy: deallocator
 @abstract   Initialize the BEWebData with bytes of a length.
 @param      bytes	The bytes to encapsulate.
 @param      length	The length of the bytes to encapsulate.
 @discussion This is the method needed to implement abstract initializers of NSData. NSData's
			 class-cluster initializers (e.g. -initWithData:, +dataWithData:) dispatch to it at
			 runtime even though no caller names it directly, so it must remain implemented.
*/
- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length copy:(void*)copyBlock deallocator:(nullable void (^)(void *bytes, NSUInteger length))deallocator {
	self = [super init];
	if (self) {
		_data = [NSData dataWithBytes:bytes length:length];
		_isComplete = YES;
	}
	return self;
}

- (void)dealloc {
	_data = nil;
}

- (const void *)bytes {
	@synchronized (self) { return _data.bytes; }
}

- (NSUInteger)length {
	@synchronized (self) { return _data.length; }
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length {
	memcpy(buffer, self.bytes, MIN(length, self.length));
}

- (void)getBytes:(void *)buffer range:(NSRange)range {
	// Clamp to the available bytes. range.location and range.length are unsigned, so the original
	// (self.length - range.location) underflowed for an out-of-range location, making MAX(...,0) a
	// no-op and reading out of bounds. Guard the location first, then clamp the length.
	NSUInteger length = self.length;
	if (range.location >= length) {
		return;
	}
	NSUInteger copyLength = MIN(range.length, length - range.location);
	memcpy(buffer, self.bytes + range.location, copyLength);
}
#pragma mark - Instance initializers

/*!
 @method     initWithContentsOfURL:
 @abstract   Initializes BEWebData from a URL.
 @param      url The URL to load data from.
 @discussion If the URL is a data URL, parses and decodes it, storing metadata.
			 If it's a regular URL, uses NSData's standard loading mechanism.
 @return     An initialized BEWebData instance, or nil if loading fails.
*/
- (instancetype)initWithContentsOfURL:(NSURL *)url
{
	return [self initWithContentsOfURL:url options:0 error:nil];
}

/*!
 @method     initWithContentsOfURL:options:error:
 @abstract   Initializes BEWebData from a URL with options and error handling.
 @param      url The URL to load data from.
 @param      options Options for reading data (applies to regular URLs only).
 @param      error Pointer to receive any error that occurs.
 @discussion For data URLs, decodes and stores metadata. For regular URLs,
			 uses NSData's standard loading with options.
 @return     An initialized BEWebData instance, or nil if loading fails.
*/
- (instancetype)initWithContentsOfURL:(NSURL *)url
							  options:(NSDataReadingOptions)options
								error:(NSError **)error
{
	if (!url) {
		if (error) {
			*error = [NSError errorWithDomain:NSCocoaErrorDomain
										 code:NSFileReadInvalidFileNameError
									 userInfo:@{NSLocalizedDescriptionKey: @"URL is nil"}];
		}
		return nil;
	}
	self = [super init];
	if (self) {
		_isComplete = NO;
		_dataTask = nil;
		_dataTaskResponse = nil;
		_dataTaskError = nil;
		
		NSString *mime = nil;
		NSString *charset = nil;
		NSStringEncoding encoding = 0;
		BOOL base64 = NO;
		
		if ([[self class] isDataURL:url]) {
			_data = [self.class decodeDataURL:url
									 MIMEType:&mime
									  charset:&charset
									 encoding:&encoding
									   base64:&base64];
			if (!_data) {
				if (error) {
					*error = [NSError errorWithDomain:NSCocoaErrorDomain
												 code:NSFileReadCorruptFileError
											 userInfo:@{NSLocalizedDescriptionKey: @"Failed to decode data URL"}];
				}
				return nil;
			}
			_MIMEType = [mime copy];
			_charset = [charset copy];
			_stringEncoding = encoding;
			_base64 = base64;
			
			_isComplete = YES;
		} else if (url.isFileURL) {
			_data = [NSData dataWithContentsOfURL:url options:options error:error];
			_isComplete = YES;
		} else if ([url.scheme.lowercaseString isEqualToString:@"http"] ||
				   [url.scheme.lowercaseString isEqualToString:@"https"]) {
			mime = BEURL_DefaultDataMimeType;

			// A test or host app may inject a session configuration (e.g. a mock NSURLProtocol)
			// through +setDefaultSessionConfiguration:. When unset, the shared session is used.
			NSURLSessionConfiguration *sessionConfiguration = s_defaultSessionConfiguration;
			NSURLSession *session = sessionConfiguration ? [NSURLSession sessionWithConfiguration:sessionConfiguration] : [NSURLSession sharedSession];
			_dataTaskSemaphore = dispatch_semaphore_create(0);
			
			//__block NSURLResponse *response = nil;
			__weak typeof(self) weakSelf = self;
			
			_dataTask = [session dataTaskWithURL:url
							   completionHandler:^(NSData * _Nullable data,
												   NSURLResponse * _Nullable response,
												   NSError * _Nullable error) {
				__strong typeof (weakSelf) _self = weakSelf;
				if (!_self) {
					return;
				}

				// Publish all state under the per-object lock and set _isComplete LAST, so a reader
				// that observes isComplete == YES (also read under the lock) is guaranteed — via the
				// lock's barrier — to see the fully-written data and metadata. The user completion
				// block is invoked OUTSIDE the lock to avoid calling out while holding it.
				BEWebDataCompletionBlock completionHandler = nil;
				@synchronized (_self) {
					_self->_data = data;
					_self->_dataTaskResponse = response;
					_self->_dataTaskError = error;

					if (!error && [response isKindOfClass:[NSHTTPURLResponse class]]) {
						NSString *contentType = ((NSHTTPURLResponse *)response).allHeaderFields[@"Content-Type"];
						if (contentType.length > 0) {
							NSArray<NSString *> *parts = [contentType componentsSeparatedByString:@";"];
							_self->_MIMEType = parts[0];
							for(int i = 1; i < parts.count; i++) {
								NSString *part = [parts[i] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
								if ([part hasPrefix:@"charset="]) {
									_self->_charset = [part substringFromIndex:8];
									_self->_stringEncoding = [NSURL stringEncodingFromCharset:_self->_charset];
								}
							}
						}
					}
					_self->_dataTask = nil;
					_self->_isComplete = YES;
					completionHandler = _self->_dataTaskCompletionHandler;
				}

				if (completionHandler) {
					completionHandler(_self, response, error);
				}

				// Signal only. Do NOT nil the ivar here: the synchronous path below reads
				// _dataTaskSemaphore to pass to dispatch_semaphore_wait, and releasing it from
				// this (possibly concurrent) completion would either hand wait() a NULL semaphore
				// or deallocate it mid-wait — a use-after-free. The ivar keeps it alive until the
				// entry deallocates.
				dispatch_semaphore_signal(_self->_dataTaskSemaphore);
			}];
			
			[_dataTask resume];

			if (sessionConfiguration) {
				// A per-call session was created above; release it once the task finishes.
				[session finishTasksAndInvalidate];
			}

			if (!(options & BEDataReadingAsynchronous)) {
				
				// Block the current thread until completion
				dispatch_semaphore_wait(_dataTaskSemaphore, DISPATCH_TIME_FOREVER);
				
				if (error && self.dataTaskError) {
					*error = self.dataTaskError;
				}
				
				if (!_data) {
					return nil;
				}
			}
			
		} else {
			// Unsupported scheme
			if (error) {
				*error = [NSError errorWithDomain:NSCocoaErrorDomain
											 code:NSFileReadUnsupportedSchemeError
										 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unsupported URL scheme %@", url.scheme]}];
			}
			return nil;
		}
	}
	return self;
}

#pragma mark - NSCoding Support

/*!
 @method     initWithCoder:
 @abstract   Initializes BEWebData from an archived representation.
 @param      coder The coder to read data from.
 @discussion Decodes the data bytes and metadata properties. Supports archiving
			 of BEWebData instances with their associated metadata.
 @return     An initialized BEWebData instance, or nil if decoding fails.
*/
- (instancetype)initWithCoder:(NSCoder *)coder
{
	if (self) {
		NSUInteger decodedLength = 0;
		const void *decodedBytes = [coder decodeBytesForKey:@"bytes" returnedLength:&decodedLength];
		
		_data = [NSData dataWithBytes:decodedBytes length:decodedLength];
		_MIMEType = [coder decodeObjectOfClass:[NSString class] forKey:@"MIMEType"];
		_charset = [coder decodeObjectOfClass:[NSString class] forKey:@"charset"];
		_stringEncoding = [coder decodeIntegerForKey:@"stringEncoding"];
		_base64 = [coder decodeBoolForKey:@"base64"];
		_isComplete = YES; // An unarchived instance is a finished snapshot, not an in-flight load.
	}
	return self;
}

/*!
 @method     encodeWithCoder:
 @abstract   Archives BEWebData to a coder.
 @param      coder The coder to write data to.
 @discussion Encodes the raw data bytes and the metadata properties (MIME type, charset,
			 encoding, base64 flag). Allows BEWebData instances to be archived with full fidelity.
*/
- (void)encodeWithCoder:(NSCoder *)coder
{
	// Take the lock once so the archived bytes and metadata are a single consistent snapshot even
	// if an asynchronous load is concurrently writing them (recursive lock — the getters re-enter).
	@synchronized (self) {
		[coder encodeBytes:self.bytes length:self.length forKey:@"bytes"];
		[coder encodeObject:_MIMEType forKey:@"MIMEType"];
		[coder encodeObject:_charset forKey:@"charset"];
		[coder encodeInteger:_stringEncoding forKey:@"stringEncoding"];
		[coder encodeBool:_base64 forKey:@"base64"];
	}
}


#pragma mark Contrete Unarchiver Overrides

- (id)replacementObjectForCoder:(NSCoder *)coder {
	return self; // Force archiving as this subclass
}
- (Class)classForCoder {
	return self.class;
}
+ (Class)classForKeyedUnarchiver {
	return self.class;
}



/*!
 @method     supportsSecureCoding
 @abstract   Indicates that BEWebData supports secure coding.
 @discussion Required for NSSecureCoding compliance. Returns YES to indicate
			 that this class properly validates types during decoding.
 @return     YES, indicating secure coding support.
*/
+ (BOOL)supportsSecureCoding
{
	return YES;
}

#pragma mark - NSCopying Support

/*!
 @method     copyWithZone:
 @abstract   Creates a copy of the BEWebData instance.
 @param      zone The memory zone to use for allocation (usually ignored).
 @discussion Creates a new BEWebData instance with the same data and metadata.
			 Required for proper NSCopying support in the subclass.
 @return     A new BEWebData instance with copied data and metadata.
*/
- (id)copyWithZone:(NSZone *)zone
{
	BEWebData *copy = [[self.class allocWithZone:zone] init];
	if (copy) {
		// Snapshot self's state under the lock in case an asynchronous load is still writing it.
		// The copy has no data task, so it is a finished, standalone object regardless.
		@synchronized (self) {
			copy->_data = [_data copy];
			copy->_MIMEType = [_MIMEType copy];
			copy->_charset = [_charset copy];
			copy->_stringEncoding = _stringEncoding;
			copy->_base64 = _base64;
		}
		copy->_isComplete = YES; // A copy is a finished snapshot, not an in-flight load.
	}
	return copy;
}

#pragma mark - Data URL decoding

/*!
 @method     decodeDataURL:MIMEType:charset:encoding:base64:
 @abstract   Decodes a data URL and extracts its metadata.
 @param      url The data URL to decode.
 @param      outMIMEType Pointer to receive the MIME type.
 @param      outCharset Pointer to receive the charset.
 @param      outEncoding Pointer to receive the NSStringEncoding.
 @param      outBase64 Pointer to receive the base64 flag.
 @discussion This method parses the data URL according to RFC 2397:
			 1. Verifies the URL is a data URL
			 2. Locates the comma separator
			 3. Parses metadata (MIME type, charset, base64 flag)
			 4. Decodes the data (base64 or percent-encoding)
			 5. Returns the decoded data and populates out parameters
			 
			 Default values:
			 - MIME type: "text/plain"
			 - Charset: "US-ASCII"
			 - Base64: NO
 @return     The decoded NSData, or nil if parsing fails.
*/
+ (NSData *)decodeDataURL:(NSURL *)url
				 MIMEType:(NSString * __autoreleasing *)outMIMEType
				  charset:(NSString * __autoreleasing *)outCharset
				 encoding:(NSStringEncoding * _Nullable)outEncoding
				   base64:(BOOL *_Nullable)outBase64
{
	// 1. Only handle valid data URLs
	if (![self isDataURL:url]) {
		return nil;
	}
	
	NSString *resourceSpecifier = url.resourceSpecifier;
	
	// 2. Locate the comma separating metadata from data
	NSRange commaRange = [resourceSpecifier rangeOfString:@","];
	if (commaRange.location == NSNotFound) {
		return nil; // Malformed data URL
	}
	
	// 3. Extract meta info and payload
	NSString *meta = [resourceSpecifier substringToIndex:commaRange.location];
	NSString *dataPart = [resourceSpecifier substringFromIndex:commaRange.location + 1];
	
	// 4. Split meta into parts
	NSArray<NSString *> *parts = [meta componentsSeparatedByString:@";"];
	
	// 5. Default values per RFC 2397
	NSString *mimeType = BEURL_DefaultTextMimeType;
	NSString *charset = BEURL_DefaultCharset;
	BOOL isBase64 = NO;
	
	// 6. Parse MIME type and parameters
	if (parts.count > 0) {
		if (parts[0].length > 0) {
			mimeType = parts[0]; // first part is MIME type if present
		}
		for (NSUInteger i = 1; i < parts.count; i++) {
			NSString *p = parts[i];
			if ([p isEqualToString:@"base64"]) {
				isBase64 = YES;
			} else if ([p hasPrefix:@"charset="]) {
				charset = [p substringFromIndex:8];
			}
		}
	}
	
	NSStringEncoding encoding = [NSURL stringEncodingFromCharset:charset];
	
	// 7. Decode payload
	NSData *decodedData = nil;
	if (isBase64) {
		decodedData = [[NSData alloc] initWithBase64EncodedString:dataPart options:NSDataBase64DecodingIgnoreUnknownCharacters];
	} else {
		NSString *decodedString = [dataPart stringByRemovingPercentEncoding];
		if (decodedString) {
			decodedData = [decodedString dataUsingEncoding:encoding];
		}
	}
	
	// 8. Set out parameters
	if (outMIMEType) {
		*outMIMEType = mimeType;
	}
	if (outCharset) {
		*outCharset = charset;
	}
	if (outEncoding) {
		*outEncoding = encoding;
	}
	if (outBase64) {
		*outBase64 = isBase64;
	}

	return decodedData;
}

#pragma mark - Overridden Methods

/*!
 @method     class
 @abstract   Returns the class object for BEWebData.
 @discussion Ensures proper class identification for instances.
 @return     The BEWebData class object.
*/
- (Class)class {
	return [BEWebData class];
}

/*!
 @method     description
 @abstract   Returns a string description of the BEWebData instance.
 @discussion Provides information about the instance including its length
			 and metadata if available.
 @return     A string description of the instance.
*/
- (NSString *)description {
	NSMutableString *desc = [NSMutableString stringWithFormat:@"<BEWebData %p; length = %lu",
							 self, (unsigned long)self.length];
	
	if (_MIMEType) {
		[desc appendFormat:@"; MIMEType = %@", _MIMEType];
	}
	if (_charset) {
		[desc appendFormat:@"; charset = %@", _charset];
	}
	if (_base64) {
		[desc appendString:@"; base64 = YES"];
	}
	
	[desc appendString:@">"];
	return desc;
}

@end
