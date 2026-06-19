/*!
 @file       NSData+URLDownload.m
 @copyright	 -© 2025 Delicense - @belisoful. All rights released.
 @date       2025-11-11
 @author     belisoful@icloud.com
 @abstract   Implementation for NSData+URLDownload category and BEDataDownloadHandler.
 @discussion Provides asynchronous URL downloading functionality using NSURLSession.
 */

#import "NSData+URLDownload.h"
#import <objc/runtime.h>


static NSURLSessionConfiguration *s_defaultSessionConfiguration = nil;

@interface NSData (URLDownload_Internal)
@property (nullable, nonatomic) BEDataDownloadHandler *downloadHandler;
@end

#pragma mark - BEDataDownloadHandler Implementation

@implementation BEDataDownloadHandler
{
	BOOL _isComplete;
	BOOL _hasError;
	NSError *_error;
}

@synthesize task = _task;
@synthesize isDataTask = _isDataTask;
@synthesize isDownloadTask = _isDownloadTask;
@synthesize allowBothCompletions = _allowBothCompletions;
@synthesize suppressCompletionWarnings = _suppressCompletionWarnings;
@synthesize receivedData = _receivedData;
@synthesize data = _data;
@synthesize delegate = _delegate;
@synthesize progressBlock = _progressBlock;
@synthesize dataCompletionBlock = _dataCompletionBlock;
@synthesize tempCompletionBlock = _tempCompletionBlock;
@synthesize errorBlock = _errorBlock;
@synthesize delayResume = _delayResume;
@synthesize sessionConfiguration = _sessionConfiguration;


- (instancetype)init
{
	if (self = [super init]) {
		_task = nil;
		_isDataTask = NO;
		_isDownloadTask = NO;
		_allowBothCompletions = NO;
		_suppressCompletionWarnings = NO;
		_receivedData = nil;
		_data = nil;
		_delayResume = NO;
		_hasError = NO;
		_error = nil;
		_isComplete = NO;
	}
	return self;
}

- (BOOL)isComplete
{
	return _isComplete;
}

- (void)setTask:(NSURLSessionTask *)task
{
	// Accept the first task or any later non-nil task, but never clear an assigned task back to nil.
	if (!_task || task) {
		_task = task;
		_isDataTask = [_task isKindOfClass:[NSURLSessionDataTask class]];
		_isDownloadTask = [_task isKindOfClass:[NSURLSessionDownloadTask class]];
	}
}

- (void)pause
{
	if (self.task && self.task.state == NSURLSessionTaskStateRunning) {
		[self.task suspend];
	}
}

- (void)resume
{
	if (self.task && self.task.state == NSURLSessionTaskStateSuspended) {
		[self.task resume];
	}
}

- (void)cancel
{
	if (self.task) {
		[self.task cancel];
	}
}


#pragma mark - NSURLSessionTaskDelegate (for NSURLSessionDataDelegate)

/*!
 @method     URLSession:task:didCompleteWithError:
 @abstract   Called when a data task completes (successfully or with error).
 @discussion This is the completion delegate method for NSURLSessionDataTask. It handles
			 both success and error cases, invoking appropriate completion blocks.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
	if (_isComplete) {
		return;
	}
	
	id<BEDataDownloadDelegate> delegate = self.delegate;
	_isComplete = YES;
	
	if (error) {
		_hasError = YES;
		_error = error;
		
		if (self.errorBlock) {
			self.errorBlock(error, NO);
		}
		if ([delegate respondsToSelector:@selector(downloadError:auxiliary:)]) {
			[delegate downloadError:error auxiliary:NO];
		}
		return;
	}
	
	
	// Success - copy the accumulated data
	_data = [_receivedData copy];
	
	if (self.dataCompletionBlock) {
		self.dataCompletionBlock(_data, task.response);
	}
	if ([delegate respondsToSelector:@selector(downloadDataComplete:urlResponse:)]) {
		[delegate downloadDataComplete:_data urlResponse:task.response];
	}
	
	// Handle allowBothCompletions: write data to temp file
	if (self.allowBothCompletions) {
		NSURL *tempDirectoryUrl = [NSURL fileURLWithPath:NSTemporaryDirectory()];
		NSUUID *fileUUID = [NSUUID UUID];
		NSURL *location = [tempDirectoryUrl URLByAppendingPathComponent:fileUUID.UUIDString];
		
		NSError *writeError = nil;
		BOOL writtenToTemp = NO;
		
		if (self.tempCompletionBlock) {
			if (_data) {
				[_data writeToURL:location options:NSDataWritingAtomic error:&writeError];
			} else {
				writeError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:@{NSLocalizedDescriptionKey: @"No downloaded data was available to write to the temporary file."}];
			}
			if (!writeError) {
				writtenToTemp = YES;
				self.tempCompletionBlock(location, task.response);
			}
		}
		if (!writeError && [delegate respondsToSelector:@selector(downloadFileComplete:urlResponse:)]) {
			if (!writtenToTemp) {
				if (_data) {
					[_data writeToURL:location options:NSDataWritingAtomic error:&writeError];
				} else {
					writeError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:@{NSLocalizedDescriptionKey: @"No downloaded data was available to write to the temporary file."}];
				}
			}
			if (!writeError) {
				writtenToTemp = YES;
				[delegate downloadFileComplete:location urlResponse:task.response];
			}
		}
		
		// Report any write errors as auxiliary errors
		if (writeError) {
			_hasError = YES;
			_error = writeError;

			if (self.errorBlock) {
				self.errorBlock(writeError, YES);
			}
			if ([delegate respondsToSelector:@selector(downloadError:auxiliary:)]) {
				[delegate downloadError:writeError auxiliary:YES];
			}
		}

		// This temp file is synthesized only to feed the file-style callbacks; its lifetime
		// matches NSURLSessionDownloadDelegate's location (valid only for the callback). The
		// callbacks have now returned, so remove it rather than leaking it into NSTemporaryDirectory().
		if (writtenToTemp) {
			[[NSFileManager defaultManager] removeItemAtURL:location error:NULL];
		}
	} else if (self.tempCompletionBlock && !self.suppressCompletionWarnings) {
#ifdef DEBUG
		NSLog(@"WARNING: Data download task has a temp file completion handler but allowBothCompletions is NO");
#endif
	}
}


#pragma mark - NSURLSessionDataDelegate (for in-memory data tasks)

/*!
 @method     URLSession:dataTask:didReceiveData:
 @abstract   Called when data is received during a data task.
 @discussion Accumulates received data into the receivedData buffer and reports progress.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
	BOOL unknownExpectedLength = NO;
	int64_t expectedLength = dataTask.response.expectedContentLength;
	
	if (expectedLength == NSURLSessionTransferSizeUnknown) {
		unknownExpectedLength = YES;
		expectedLength = 1024 * 10; // Initial capacity estimate
	}
	
	if (!_receivedData) {
		_receivedData = [[NSMutableData alloc] initWithCapacity:(NSUInteger)expectedLength];
	}
	[_receivedData appendData:data];
	
	// Report progress
	if (_receivedData.length > 0) {
		if (unknownExpectedLength) {
			expectedLength = -1; // Signal unknown length to callbacks
		}
		if (self.progressBlock) {
			self.progressBlock((int64_t)_receivedData.length, expectedLength);
		}
		if ([self.delegate respondsToSelector:@selector(downloadReceived:totalBytes:)]) {
			[self.delegate downloadReceived:(int64_t)_receivedData.length totalBytes:expectedLength];
		}
	}
}

#pragma mark - NSURLSessionDownloadDelegate (for file tasks)

/*!
 @method     URLSession:downloadTask:didFinishDownloadingToURL:
 @abstract   Required delegate method called when a download task completes successfully.
 @discussion Provides the temporary file location where the downloaded content was saved.
			 If allowBothCompletions is enabled, also loads the file into memory.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
	if (_isComplete) {
		return;
	}
	
	id<BEDataDownloadDelegate> delegate = self.delegate;
	
	_isComplete = YES;
	
	// File download success callback
	if (self.tempCompletionBlock) {
		self.tempCompletionBlock(location, downloadTask.response);
	}
	
	if ([delegate respondsToSelector:@selector(downloadFileComplete:urlResponse:)]) {
		[delegate downloadFileComplete:location urlResponse:downloadTask.response];
	}
	
	// Handle allowBothCompletions: load file into memory
	if (self.allowBothCompletions) {
		if (self.dataCompletionBlock) {
			_data = [NSData dataWithContentsOfURL:location];
			if (_data) {
				self.dataCompletionBlock(_data, downloadTask.response);
			}
		}
		if ([delegate respondsToSelector:@selector(downloadDataComplete:urlResponse:)]) {
			if (!_data) {
				_data = [NSData dataWithContentsOfURL:location];
			}
			if (_data) {
				[delegate downloadDataComplete:_data urlResponse:downloadTask.response];
			}
		}
	} else if (self.dataCompletionBlock && !self.suppressCompletionWarnings) {
#ifdef DEBUG
		NSLog(@"WARNING: File download task has a data completion handler but allowBothCompletions is NO");
#endif
	}
}

/*!
 @method     URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:
 @abstract   Optional delegate method called periodically during file download to report progress.
 @discussion Reports the total bytes written and expected total size to progress callbacks.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
	if (self.progressBlock) {
		self.progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
	}
	if ([self.delegate respondsToSelector:@selector(downloadReceived:totalBytes:)]) {
		[self.delegate downloadReceived:totalBytesWritten totalBytes:totalBytesExpectedToWrite];
	}
}


/*!
 @method     URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:
 @abstract   Optional delegate method for handling download resume operations.
 @discussion This implementation does not support resuming downloads, but the method
			 must be present to satisfy the NSURLSessionDownloadDelegate protocol.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
	// Resume is not supported by this simple wrapper, but the delegate method must exist.
}

@end


#pragma mark - NSData (URLDownload)

@implementation NSData (URLDownload)

#pragma mark - Associated Object Property

- (BEDataDownloadHandler *)downloadHandler
{
	return objc_getAssociatedObject(self, @selector(downloadHandler));
}

- (void)setDownloadHandler:(BEDataDownloadHandler *)downloadHandler
{
	objc_setAssociatedObject(self, @selector(downloadHandler), downloadHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - Default Session Configuration

+ (nullable NSURLSessionConfiguration *)defaultSessionConfiguration
{
	return s_defaultSessionConfiguration;
}

+ (void)setDefaultSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration
{
	s_defaultSessionConfiguration = [configuration copy];
}


#pragma mark - Data Download (Data Task)

+ (BEDataDownloadHandler *)dataDownloadWithContentsOfURL:(NSURL *)url
											  completion:(NSDataCompletionBlock)completionBlock
												   error:(NSDataErrorBlock)errorBlock
{
	return [self dataDownloadWithContentsOfURL:url completion:completionBlock error:errorBlock progress:nil];
}

+ (BEDataDownloadHandler *)dataDownloadWithContentsOfURL:(NSURL *)url
											  completion:(NSDataCompletionBlock)completionBlock
												   error:(NSDataErrorBlock)errorBlock
												progress:(NSDataProgressBlock)progressBlock
{
	if (!url) {
		return nil;
	}
	
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.dataCompletionBlock = completionBlock;
	handler.errorBlock = errorBlock;
	handler.progressBlock = progressBlock;
	
	[self dataDownloadWithContentsOfURL:url handler:handler];
	
	return handler;
}

+ (BEDataDownloadHandler *)dataDownloadWithContentsOfURL:(NSURL *)url
												delegate:(id<BEDataDownloadDelegate>)delegate
{
	if (!url) {
		return nil;
	}
	
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.delegate = delegate;
	
	[self dataDownloadWithContentsOfURL:url handler:handler];
	return handler;
}

+ (nullable NSURLSessionDataTask *)dataDownloadWithContentsOfURL:(nonnull NSURL *)url
														 handler:(nullable BEDataDownloadHandler *)handler
{
	if (!url || !handler) {
		return nil;
	}
	
	NSURLSessionConfiguration *config = handler.sessionConfiguration ?: s_defaultSessionConfiguration ?: [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:config
														  delegate:handler
													 delegateQueue:[NSOperationQueue mainQueue]];

	NSURLSessionDataTask *task = [session dataTaskWithURL:url];
	handler.task = task;

	// Note: receivedData will be created lazily when data arrives
	// We don't need to set the handler association here since receivedData doesn't exist yet

	if (!handler.delayResume) {
		[task resume];
	}

	// A delegate session retains its delegate (the handler) strongly until invalidated. Without
	// this the session and handler would leak after the one-shot task completes. finishTasksAndInvalidate
	// lets this task run to completion, then tears the session down and releases the delegate.
	[session finishTasksAndInvalidate];

	return task;
}


#pragma mark - File Download (Download Task)

+ (BEDataDownloadHandler *)downloadFileWithURL:(NSURL *)url
									completion:(NSTempFileCompletionBlock)completionBlock
										 error:(NSDataErrorBlock)errorBlock
{
	return [self downloadFileWithURL:url completion:completionBlock error:errorBlock progress:nil];
}

+ (BEDataDownloadHandler *)downloadFileWithURL:(NSURL *)url
									completion:(NSTempFileCompletionBlock)completionBlock
										 error:(NSDataErrorBlock)errorBlock
									  progress:(NSDataProgressBlock)progressBlock
{
	if (!url) {
		return nil;
	}
	
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.tempCompletionBlock = completionBlock;
	handler.errorBlock = errorBlock;
	handler.progressBlock = progressBlock;
	
	[self downloadFileWithURL:url handler:handler];
	
	return handler;
}

+ (BEDataDownloadHandler *)downloadFileWithURL:(NSURL *)url
									  delegate:(id<BEDataDownloadDelegate>)delegate
{
	if (!url) {
		return nil;
	}
	
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.delegate = delegate;
	
	[self downloadFileWithURL:url handler:handler];
	return handler;
}

+ (nullable NSURLSessionDownloadTask *)downloadFileWithURL:(nonnull NSURL *)url
												   handler:(nullable BEDataDownloadHandler *)handler
{
	if (!url || !handler) {
		return nil;
	}

	NSURLSessionConfiguration *config = handler.sessionConfiguration ?: s_defaultSessionConfiguration ?: [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:config
														  delegate:handler
													 delegateQueue:[NSOperationQueue mainQueue]];

	NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
	handler.task = task;

	// Note: receivedData is not used for download tasks

	if (!handler.delayResume) {
		[task resume];
	}

	// A delegate session retains its delegate (the handler) strongly until invalidated. Without
	// this the session and handler would leak after the one-shot task completes. finishTasksAndInvalidate
	// lets this task run to completion, then tears the session down and releases the delegate.
	[session finishTasksAndInvalidate];

	return task;
}

@end
