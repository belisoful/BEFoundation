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
@synthesize dataTaskCompletionHandler = _dataTaskCompletionHandler;

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

- (nullable BEWebDataCompletionBlock)dataTaskCompletionHandler {
	@synchronized (self) { return _dataTaskCompletionHandler; }
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
 @method     initWithBytes:length:copy:deallocator:
 @abstract   Initialize the BEWebData with bytes of a length.
 @param      bytes	The bytes to encapsulate.
 @param      length	The length of the bytes to encapsulate.
 @param      shouldCopy	Ignored. The bytes are always copied into private storage.
 @param      deallocator	Called once with @c bytes and @c length after the copy, so a caller
			 that hands over ownership (for example @c dataWithBytesNoCopy:length:freeWhenDone:)
			 has its buffer released.
 @discussion This is the method needed to implement abstract initializers of NSData. NSData's
			 class-cluster initializers (e.g. -initWithData:, +dataWithData:,
			 -initWithBytesNoCopy:length:deallocator:) dispatch to it at runtime even though no
			 caller names it directly, so it must remain implemented.
*/
- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length copy:(BOOL)shouldCopy deallocator:(nullable void (^)(void *bytes, NSUInteger length))deallocator {
	self = [super init];
	if (self) {
		_data = [NSData dataWithBytes:bytes length:length];
		_isComplete = YES;
	}
	if (deallocator) {
		deallocator((void *)bytes, length);
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
	// Copy from one snapshot: -bytes and -length take the lock separately, so an async
	// load publishing between the two calls pairs a NULL pointer with a non-zero length.
	NSData *data = nil;
	@synchronized (self) { data = _data; }
	memcpy(buffer, data.bytes, MIN(length, data.length));
}

- (void)getBytes:(void *)buffer range:(NSRange)range {
	// Clamp to the available bytes. range.location and range.length are unsigned, so
	// (length - range.location) underflows for an out-of-range location, making MAX(...,0) a
	// no-op and reading out of bounds. Guard the location first, then clamp the length.
	// One snapshot: -bytes and -length lock separately, so reading them apart can pair a
	// stale pointer with a newer length.
	NSData *data = nil;
	@synchronized (self) { data = _data; }
	NSUInteger length = data.length;
	if (range.location >= length) {
		return;
	}
	NSUInteger copyLength = MIN(range.length, length - range.location);
	memcpy(buffer, (const uint8_t *)data.bytes + range.location, copyLength);
}
#pragma mark - Instance initializers

/*!
 @method     initWithContentsOfURL:
 @abstract   Initializes BEWebData from a URL.
 @param      url The URL to load data from.
 @discussion If the URL is a data URL, parses and decodes it, storing metadata.
			 If it is a regular URL, uses NSData's standard loading mechanism.
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
			if (!_data) {
				return nil;    // *error is already populated; match every other branch
			}
			_isComplete = YES;
		} else if ([url.scheme.lowercaseString isEqualToString:@"http"] ||
				   [url.scheme.lowercaseString isEqualToString:@"https"]) {
			mime = BEURL_DefaultDataMimeType;

			// A test or host app may inject a session configuration (e.g. a mock NSURLProtocol)
			// through +setDefaultSessionConfiguration:. When unset, the shared session is used.
			NSURLSessionConfiguration *sessionConfiguration = s_defaultSessionConfiguration;
			NSURLSession *session = sessionConfiguration ? [NSURLSession sessionWithConfiguration:sessionConfiguration] : [NSURLSession sharedSession];
			_dataTaskSemaphore = dispatch_semaphore_create(0);
			
			__weak typeof(self) weakSelf = self;
			
			_dataTask = [session dataTaskWithURL:url
							   completionHandler:^(NSData * _Nullable data,
												   NSURLResponse * _Nullable response,
												   NSError * _Nullable error) {
				__strong typeof (weakSelf) _self = weakSelf;
				if (!_self) {
					return;
				}

				// Publish all state under the per-object lock and set _isComplete last, so a reader
				// that observes isComplete == YES (also read under the lock) is guaranteed, via the
				// lock's barrier, to see the fully-written data and metadata. The user completion
				// block is invoked outside the lock to avoid calling out while holding it.
				BEWebDataCompletionBlock completionHandler = nil;
				@synchronized (_self) {
					_self->_data = data;
					_self->_dataTaskResponse = response;
					_self->_dataTaskError = error;

					if (!error && [response isKindOfClass:[NSHTTPURLResponse class]]) {
						NSString *contentType = ((NSHTTPURLResponse *)response).allHeaderFields[@"Content-Type"];
						if (contentType.length > 0) {
							_self->_MIMEType = [contentType componentsSeparatedByString:@";"].firstObject;
							NSString *charset = [NSURL charsetFromMediaType:contentType];
							if (charset) {
								_self->_charset = charset;
								_self->_stringEncoding = [NSURL stringEncodingFromCharset:charset];
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

				// Signal only. Do not nil the ivar here: the synchronous path below reads
				// _dataTaskSemaphore to pass to dispatch_semaphore_wait, and releasing it from
				// this (possibly concurrent) completion would either hand wait() a NULL semaphore
				// or deallocate it mid-wait (a use-after-free). The ivar keeps it alive until the
				// entry deallocates.
				dispatch_semaphore_signal(_self->_dataTaskSemaphore);
			}];
			
			[_dataTask resume];

			if (sessionConfiguration) {
				// A per-call session was created above; release it once the task finishes.
				[session finishTasksAndInvalidate];
			}

			if (!(options & BEDataReadingAsynchronous)) {
				
				dispatch_semaphore_wait(_dataTaskSemaphore, DISPATCH_TIME_FOREVER);
				
				if (error && self.dataTaskError) {
					*error = self.dataTaskError;
				}
				
				if (!_data) {
					return nil;
				}
			}
			
		} else {
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
	self = [super init];
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
	// if an asynchronous load is concurrently writing them (recursive lock; the getters re-enter).
	@synchronized (self) {
		[coder encodeBytes:self.bytes length:self.length forKey:@"bytes"];
		[coder encodeObject:_MIMEType forKey:@"MIMEType"];
		[coder encodeObject:_charset forKey:@"charset"];
		[coder encodeInteger:_stringEncoding forKey:@"stringEncoding"];
		[coder encodeBool:_base64 forKey:@"base64"];
	}
}


#pragma mark Concrete Unarchiver Overrides

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
 @discussion Parsing and decoding run through the NSURL (Data) category, so this method and
			 the NSURL properties (@c dataMIMEType, @c dataCharset, @c stringEncoding,
			 @c isBase64, @c decodedData) return identical results for the same URL. The out
			 parameters are left untouched when decoding fails.
 @return     The decoded NSData, or nil if parsing fails.
*/
+ (NSData *)decodeDataURL:(NSURL *)url
				 MIMEType:(NSString * __autoreleasing *)outMIMEType
				  charset:(NSString * __autoreleasing *)outCharset
				 encoding:(NSStringEncoding * _Nullable)outEncoding
				   base64:(BOOL *_Nullable)outBase64
{
	if (![self isDataURL:url]) {
		return nil;
	}
	NSData *decodedData = url.decodedData;
	if (!decodedData) {
		return nil;
	}

	if (outMIMEType) {
		*outMIMEType = url.dataMIMEType;
	}
	if (outCharset) {
		*outCharset = url.dataCharset;
	}
	if (outEncoding) {
		*outEncoding = url.stringEncoding;
	}
	if (outBase64) {
		*outBase64 = url.isBase64;
	}
	return decodedData;
}

#pragma mark - Overridden Methods

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

	// Read through the locked getters; an in-flight asynchronous load writes the metadata
	// ivars on a background thread.
	NSString *MIMEType = self.MIMEType;
	if (MIMEType) {
		[desc appendFormat:@"; MIMEType = %@", MIMEType];
	}
	NSString *charset = self.charset;
	if (charset) {
		[desc appendFormat:@"; charset = %@", charset];
	}
	if (self.isBase64) {
		[desc appendString:@"; base64 = YES"];
	}

	[desc appendString:@">"];
	return desc;
}

@end
