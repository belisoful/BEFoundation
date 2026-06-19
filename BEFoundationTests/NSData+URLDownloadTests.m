/*!
 @file       NSData+URLDownloadTests.m
 @copyright  © 2025 Delicense - @belisoful. All rights released.
 @date       2025-11-11
 @author     belisoful@icloud.com
 @abstract   Comprehensive unit tests for NSData+URLDownload category and BEDataDownloadHandler.
 @discussion Tests cover data downloads, file downloads, error handling, progress tracking,
			 delegate callbacks, block callbacks, pause/resume/cancel operations, and edge cases.
 
 Test Categories:
 - BEDataDownloadHandler Basic Tests: Initialization, properties, task assignment
 - Data Download Tests (Block-based): Success, error, progress, invalid URLs
 - Data Download Tests (Delegate-based): Delegate callbacks and events
 - File Download Tests (Block-based): File downloads with various scenarios
 - File Download Tests (Delegate-based): Delegate-based file downloads
 - Handler Control Tests: Pause, resume, cancel, delay resume
 - allowBothCompletions Tests: Testing dual completion handlers
 - suppressCompletionWarnings Tests: Warning suppression functionality
 - Unknown Content Length Tests: Downloads without Content-Length header
 - Associated Objects Tests: downloadHandler property management
 - Edge Cases and Error Handling: Nil parameters, empty data, large files
 - HTTP Status Code Tests: Non-200 responses
 - Multiple Simultaneous Downloads: Concurrent download handling
 - Block Retention Tests: Memory management verification
 - Task State Tests: Task lifecycle and states
 - Response Headers Tests: HTTP header accessibility
 - Completion State Tests: isComplete property verification
 - Data Property Tests: Data accumulation and access
 - Auxiliary Error Tests: Secondary error handling
 - Thread Safety Tests: Main queue callback verification
 
 MockURLProtocol:
 A custom NSURLProtocol implementation is used to intercept and mock network requests,
 allowing tests to run without actual network calls. This provides deterministic,
 fast, and reliable test execution.
 */

#import <XCTest/XCTest.h>
#import "NSData+URLDownload.h"

#pragma mark - Mock HTTP Server Helper

/*!
 @class      MockURLProtocol
 @abstract   Custom NSURLProtocol subclass for mocking network responses in tests.
 @discussion Allows tests to run without actual network calls by intercepting URL requests
			 and providing predefined responses.
 */
@interface MockURLProtocol : NSURLProtocol
+ (void)setMockResponse:(NSData *)data statusCode:(NSInteger)statusCode headers:(NSDictionary *)headers;
+ (void)setMockError:(NSError *)error;
+ (void)setProgressSimulation:(BOOL)enabled chunkSize:(NSUInteger)chunkSize;
+ (void)reset;
@end

static NSData *mockResponseData = nil;
static NSInteger mockStatusCode = 200;
static NSDictionary *mockHeaders = nil;
static NSError *mockError = nil;
static BOOL simulateProgress = NO;
static NSUInteger progressChunkSize = 1024;

@implementation MockURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	return request;
}

+ (void)setMockResponse:(NSData *)data statusCode:(NSInteger)statusCode headers:(NSDictionary *)headers {
	mockResponseData = data;
	mockStatusCode = statusCode;
	mockHeaders = headers ?: @{@"Content-Type": @"application/octet-stream"};
	mockError = nil;
}

+ (void)setMockError:(NSError *)error {
	mockError = error;
	mockResponseData = nil;
}

+ (void)setProgressSimulation:(BOOL)enabled chunkSize:(NSUInteger)chunkSize {
	simulateProgress = enabled;
	progressChunkSize = chunkSize;
}

+ (void)reset {
	mockResponseData = nil;
	mockStatusCode = 200;
	mockHeaders = nil;
	mockError = nil;
	simulateProgress = NO;
	progressChunkSize = 1024;
}

- (void)startLoading {
	if (mockError) {
		[self.client URLProtocol:self didFailWithError:mockError];
		return;
	}
	
	NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
															  statusCode:mockStatusCode
															 HTTPVersion:@"HTTP/1.1"
															headerFields:mockHeaders];
	
	[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	
	if (simulateProgress && mockResponseData.length > progressChunkSize) {
		// Simulate chunked data delivery
		NSUInteger offset = 0;
		while (offset < mockResponseData.length) {
			NSUInteger length = MIN(progressChunkSize, mockResponseData.length - offset);
			NSData *chunk = [mockResponseData subdataWithRange:NSMakeRange(offset, length)];
			[self.client URLProtocol:self didLoadData:chunk];
			offset += length;
			usleep(1000);
		}
	} else {
		[self.client URLProtocol:self didLoadData:mockResponseData];
	}
	
	[self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
	// Nothing to do
}

@end

#pragma mark - Test Delegate

/*!
 @class      TestDownloadDelegate
 @abstract   Test delegate for capturing download events.
 */
@interface TestDownloadDelegate : NSObject <BEDataDownloadDelegate>
@property (nonatomic) NSInteger progressCallCount;
@property (nonatomic) int64_t lastBytesReceived;
@property (nonatomic) int64_t lastBytesExpected;
@property (nonatomic, strong, nullable) NSData *completedData;
@property (nonatomic, strong, nullable) NSURL *completedFileURL;
@property (nonatomic, strong, nullable) NSURLResponse *response;
@property (nonatomic, strong, nullable) NSError *error;
@property (nonatomic) BOOL errorIsAuxiliary;
@property (nonatomic) XCTestExpectation *completionExpectation;
@property (nonatomic) XCTestExpectation *errorExpectation;
@property (nonatomic) XCTestExpectation *progressExpectation;
@end

@implementation TestDownloadDelegate

- (void)downloadReceived:(int64_t)totalBytesReceived totalBytes:(int64_t)totalBytesExpected {
	self.progressCallCount++;
	self.lastBytesReceived = totalBytesReceived;
	self.lastBytesExpected = totalBytesExpected;
	if (self.progressExpectation) {
		[self.progressExpectation fulfill];
		self.progressExpectation = nil;
	}
}

- (void)downloadDataComplete:(NSData *)data urlResponse:(NSURLResponse *)response {
	self.completedData = data;
	self.response = response;
	if (self.completionExpectation) {
		[self.completionExpectation fulfill];
	}
}

- (void)downloadFileComplete:(NSURL *)tempFileLocation urlResponse:(NSURLResponse *)response {
	self.completedFileURL = tempFileLocation;
	self.response = response;
	if (self.completionExpectation) {
		[self.completionExpectation fulfill];
	}
}

- (void)downloadError:(NSError *)error auxiliary:(BOOL)auxiliary {
	self.error = error;
	self.errorIsAuxiliary = auxiliary;
	if (self.errorExpectation) {
		[self.errorExpectation fulfill];
	}
}

@end

#pragma mark - Main Test Suite

@interface NSDataURLDownloadTests : XCTestCase
@property (nonatomic, strong) NSURLSessionConfiguration *testConfiguration;
@end

static NSLock *nsdata_lock = nil;

@implementation NSDataURLDownloadTests

- (void)setUp {
	
	{	// Serialize the NSData+URLDownload tests.
		if (!nsdata_lock) {
			nsdata_lock = NSLock.new;
		}
		[nsdata_lock lock];
	}
	
	[super setUp];
	
	// 1. Create a custom configuration (using ephemeral configuration is common for testing)
	NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
	
	// 2. Explicitly inject MockURLProtocol into the configuration's protocol classes
	// This is the CRITICAL step to make your mock work with a delegate-based NSURLSession.
	NSMutableArray *protocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
	[protocolClasses insertObject:MockURLProtocol.class atIndex:0];
	config.protocolClasses = protocolClasses;
	
	// 3. Apply the configuration app-wide so every download path (including the convenience
	//    methods, which build their handler internally) routes through MockURLProtocol.
	NSData.defaultSessionConfiguration = config;
	self.testConfiguration = config;

	// Ensure any previous mock state is cleared
	[MockURLProtocol reset];
}

- (void)tearDown {
	NSData.defaultSessionConfiguration = nil;
	[NSURLProtocol unregisterClass:[MockURLProtocol class]];
	[MockURLProtocol reset];

	NSLog (@"End NSData+URLDownload");
	[nsdata_lock unlock];
	[super tearDown];
}

#pragma mark - BEDataDownloadHandler Basic Tests

- (void)testHandlerInitialization {
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	
	XCTAssertNotNil(handler);
	XCTAssertNil(handler.task);
	XCTAssertFalse(handler.isDataTask);
	XCTAssertFalse(handler.isDownloadTask);
	XCTAssertFalse(handler.isComplete);
	XCTAssertFalse(handler.allowBothCompletions);
	XCTAssertFalse(handler.suppressCompletionWarnings);
	XCTAssertNil(handler.receivedData);
	XCTAssertNil(handler.data);
	XCTAssertNil(handler.delegate);
	XCTAssertNil(handler.progressBlock);
	XCTAssertNil(handler.dataCompletionBlock);
	XCTAssertNil(handler.tempCompletionBlock);
	XCTAssertNil(handler.errorBlock);
	XCTAssertFalse(handler.delayResume);
}

- (void)testHandlerTaskAssignment {
	// Note: task is readonly and set internally by the download methods
	NSData *testData = [@"Task assignment test" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {};
	
	NSURLSessionDataTask *task = [NSData dataDownloadWithContentsOfURL:url handler:handler];
	
	XCTAssertNotNil(handler.task);
	XCTAssertEqual(handler.task, task);
	XCTAssertTrue(handler.isDataTask);
	XCTAssertFalse(handler.isDownloadTask);
}

- (void)testHandlerDownloadTaskAssignment {
	// Note: task is readonly and set internally by the download methods
	NSData *testData = [@"Download task test" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.bin"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.tempCompletionBlock = ^(NSURL *tempFileLocation, NSURLResponse *response) {};
	
	NSURLSessionDownloadTask *task = [NSData downloadFileWithURL:url handler:handler];
	
	XCTAssertNotNil(handler.task);
	XCTAssertEqual(handler.task, task);
	XCTAssertFalse(handler.isDataTask);
	XCTAssertTrue(handler.isDownloadTask);
}

#pragma mark - Session Configuration Tests

- (void)testHandlerSessionConfigurationOverride {
	NSData *testData = [@"Per-handler config" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];

	// Clear the app-wide default so the handler's own configuration is the path exercised.
	NSData.defaultSessionConfiguration = nil;

	XCTestExpectation *expectation = [self expectationWithDescription:@"Download via handler configuration"];

	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.sessionConfiguration = self.testConfiguration;
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
		XCTAssertEqualObjects(data, testData);
		[expectation fulfill];
	};

	NSURLSessionDataTask *task = [NSData dataDownloadWithContentsOfURL:url handler:handler];
	XCTAssertNotNil(task);
	XCTAssertNotNil(handler.sessionConfiguration);

	[self waitForExpectations:@[expectation] timeout:5.0];
	XCTAssertTrue(handler.isComplete);
}

- (void)testDefaultSessionConfigurationProperty {
	NSURLSessionConfiguration *fromSetup = NSData.defaultSessionConfiguration;
	XCTAssertNotNil(fromSetup);

	NSData.defaultSessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
	XCTAssertNotNil(NSData.defaultSessionConfiguration);

	NSData.defaultSessionConfiguration = nil;
	XCTAssertNil(NSData.defaultSessionConfiguration);
}

- (void)testDownloadUsesSystemDefaultWhenUnconfigured {
	// Neither the handler nor the app-wide default supplies a configuration: the funnel must
	// fall back to the system default. delayResume keeps the task off the real network.
	NSData.defaultSessionConfiguration = nil;

	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.delayResume = YES;
	XCTAssertNil(handler.sessionConfiguration);

	NSURLSessionDataTask *task = [NSData dataDownloadWithContentsOfURL:url handler:handler];
	XCTAssertNotNil(task);
	[handler cancel];
}

#pragma mark - Data Download Tests (Block-based)

- (void)testDataDownloadWithCompletionSuccess {
	NSString *testString = @"Hello, World!";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Data download completes"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		XCTAssertEqualObjects(data, testData);
		XCTAssertNotNil(response);
		[expectation fulfill];
	} error:^(NSError *error, BOOL auxiliary) {
		XCTFail(@"Should not call error block");
	}];
	
	XCTAssertNotNil(handler);
	XCTAssertNotNil(handler.task);
	XCTAssertTrue(handler.isDataTask);
	
	[self waitForExpectations:@[expectation] timeout:5.0];
	
	XCTAssertTrue(handler.isComplete);
	XCTAssertEqualObjects(handler.data, testData);
}

- (void)testDataDownloadWithProgress {
	NSMutableData *testData = [NSMutableData data];
	for (int i = 0; i < 10000; i++) {
		[testData appendBytes:"X" length:1];
	}
	
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:@{@"Content-Length": @"10000"}];
	[MockURLProtocol setProgressSimulation:YES chunkSize:1000];
	
	XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Download completes"];
	XCTestExpectation *progressExpectation = [self expectationWithDescription:@"Progress reported"];
	
	__block NSInteger progressCallCount = 0;
	__block int64_t lastBytesReceived = 0;
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/large.dat"];
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		XCTAssertEqual(data.length, testData.length);
		[completionExpectation fulfill];
	} error:^(NSError *error, BOOL auxiliary) {
		XCTFail(@"Should not call error block");
	} progress:^(int64_t totalBytesReceived, int64_t totalBytesExpected) {
		progressCallCount++;
		lastBytesReceived = totalBytesReceived;
		if (progressCallCount == 1) {
			[progressExpectation fulfill];
		}
	}];
	
	XCTAssertNotNil(handler);
	
	[self waitForExpectations:@[completionExpectation, progressExpectation] timeout:5.0];
	
	XCTAssertGreaterThan(progressCallCount, 0);
	XCTAssertEqual(lastBytesReceived, (int64_t)testData.length);
}

- (void)testDataDownloadWithError {
	NSError *testError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
	[MockURLProtocol setMockError:testError];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Error handled"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		XCTFail(@"Should not call completion block");
	} error:^(NSError *error, BOOL auxiliary) {
		XCTAssertEqualObjects(error.domain, testError.domain);
		XCTAssertEqual(error.code, testError.code);
		XCTAssertFalse(auxiliary);
		[expectation fulfill];
	}];
	
	XCTAssertNotNil(handler);
	
	[self waitForExpectations:@[expectation] timeout:5.0];
	
	XCTAssertTrue(handler.isComplete);
}

- (void)testDataDownloadWithInvalidURL {
	NSURL *nilURL = nil;
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:nilURL
																completion:^(NSData *data, NSURLResponse *response) {
		XCTFail(@"Should not be called");
	} error:^(NSError *error, BOOL auxiliary) {
		XCTFail(@"Should not be called");
	}];
	
	XCTAssertNil(handler);
}

- (void)testDataDownloadWithNilErrorBlock {
	NSString *testString = @"Test data";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Completion without error block"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		XCTAssertEqualObjects(data, testData);
		[expectation fulfill];
	} error:nil];
	
	XCTAssertNotNil(handler);
	
	[self waitForExpectations:@[expectation] timeout:5.0];
}

#pragma mark - Data Download Tests (Delegate-based)

- (void)testDataDownloadWithDelegate {
	NSString *testString = @"Delegate test data";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	TestDownloadDelegate *delegate = [[TestDownloadDelegate alloc] init];
	delegate.completionExpectation = [self expectationWithDescription:@"Delegate completion"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url delegate:delegate];
	
	XCTAssertNotNil(handler);
	XCTAssertEqual(handler.delegate, delegate);
	
	[self waitForExpectations:@[delegate.completionExpectation] timeout:5.0];
	
	XCTAssertEqualObjects(delegate.completedData, testData);
	XCTAssertNotNil(delegate.response);
}

- (void)testDataDownloadWithDelegateProgress {
	NSMutableData *testData = [NSMutableData dataWithLength:5000];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:@{@"Content-Length": @"5000"}];
	[MockURLProtocol setProgressSimulation:YES chunkSize:500];
	
	TestDownloadDelegate *delegate = [[TestDownloadDelegate alloc] init];
	delegate.completionExpectation = [self expectationWithDescription:@"Delegate completion"];
	delegate.progressExpectation = [self expectationWithDescription:@"Delegate progress"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/data.bin"];
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url delegate:delegate];
	
	XCTAssertNotNil(handler);
	
	[self waitForExpectations:@[delegate.completionExpectation, delegate.progressExpectation] timeout:5.0];
	
	XCTAssertGreaterThan(delegate.progressCallCount, 0);
	XCTAssertEqual(delegate.lastBytesReceived, (int64_t)testData.length);
}

- (void)testDataDownloadWithDelegateError {
	NSError *testError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
	[MockURLProtocol setMockError:testError];
	
	TestDownloadDelegate *delegate = [[TestDownloadDelegate alloc] init];
	delegate.errorExpectation = [self expectationWithDescription:@"Delegate error"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	[NSData dataDownloadWithContentsOfURL:url delegate:delegate];
	
	[self waitForExpectations:@[delegate.errorExpectation] timeout:5.0];
	
	XCTAssertEqualObjects(delegate.error.domain, testError.domain);
	XCTAssertEqual(delegate.error.code, testError.code);
	XCTAssertFalse(delegate.errorIsAuxiliary);
}



- (void)testDataDownloadWithBlockWriteError {
	
	XCTestExpectation *blockExpectation = [self expectationWithDescription:@"Error handled"];
	
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	
	handler.allowBothCompletions = YES;
	handler.errorBlock = ^(NSError * _Nonnull error, BOOL auxiliary) {
		XCTAssertNotNil(error);
		XCTAssertTrue(auxiliary);
		[blockExpectation fulfill];
	};
	
	handler.tempCompletionBlock = ^(NSURL * _Nonnull tempFileLocation, NSURLResponse * _Nonnull response) {
	};
	
	// hack to trigger bad file write
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	[handler URLSession:nil task:nil didCompleteWithError:nil];
#pragma clang diagnostic pop

	[self waitForExpectations:@[blockExpectation] timeout:5.0];
}



- (void)testDataDownloadWithDelegateWriteError {
	
	XCTestExpectation *blockExpectation = [self expectationWithDescription:@"Error handled"];
	
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	
	handler.allowBothCompletions = YES;
	handler.errorBlock = ^(NSError * _Nonnull error, BOOL auxiliary) {
		XCTAssertTrue(auxiliary);
		[blockExpectation fulfill];
	};
	
	TestDownloadDelegate *delegate = [[TestDownloadDelegate alloc] init];
	delegate.errorExpectation = [self expectationWithDescription:@"Delegate error"];
	
	handler.delegate = delegate;
	
	// hack to trigger bad file write
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	[handler URLSession:nil task:nil didCompleteWithError:nil];
#pragma clang diagnostic pop

	[self waitForExpectations:@[blockExpectation, delegate.errorExpectation] timeout:5.0];
	
	XCTAssertNotNil(delegate.error);
	XCTAssertTrue(delegate.errorIsAuxiliary);
}

#pragma mark - File Download Tests (Block-based)

- (void)testFileDownloadWithCompletion {
	NSString *testString = @"File download test";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"File download completes"];
	
	
	__block int completionCount = 0;
	NSURL *url = [NSURL URLWithString:@"http://example.com/file.dat"];
	BEDataDownloadHandler *handler = [NSData downloadFileWithURL:url
													  completion:^(NSURL *tempFileLocation, NSURLResponse *response) {
		completionCount++;
		XCTAssertNotNil(tempFileLocation);
		XCTAssertNotNil(response);
		
		NSData *fileData = [NSData dataWithContentsOfURL:tempFileLocation];
		XCTAssertEqualObjects(fileData, testData);
		
		[expectation fulfill];
	} error:^(NSError *error, BOOL auxiliary) {
		XCTFail(@"Should not call error block");
	}];
	
	XCTAssertNotNil(handler);
	XCTAssertTrue(handler.isDownloadTask);
	
	[self waitForExpectations:@[expectation] timeout:5.0];
	
	XCTAssertTrue(handler.isComplete);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	[handler URLSession:nil downloadTask:nil didFinishDownloadingToURL:nil];
#pragma clang diagnostic pop

	XCTAssertEqual(completionCount, 1);
}

- (void)testFileDownloadWithProgress {
	NSMutableData *testData = [NSMutableData dataWithLength:8000];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:@{@"Content-Length": @"8000"}];
	[MockURLProtocol setProgressSimulation:YES chunkSize:800];
	
	XCTestExpectation *completionExpectation = [self expectationWithDescription:@"File download completes"];
	XCTestExpectation *progressExpectation = [self expectationWithDescription:@"Progress reported"];
	
	__block NSInteger progressCallCount = 0;
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/largefile.bin"];
	BEDataDownloadHandler *handler = [NSData downloadFileWithURL:url
													  completion:^(NSURL *tempFileLocation, NSURLResponse *response) {
		[completionExpectation fulfill];
	} error:^(NSError *error, BOOL auxiliary) {
		XCTFail(@"Should not call error block");
	} progress:^(int64_t totalBytesReceived, int64_t totalBytesExpected) {
		progressCallCount++;
		if (progressCallCount == 1) {
			[progressExpectation fulfill];
		}
	}];
	
	XCTAssertNotNil(handler);
	
	[self waitForExpectations:@[completionExpectation, progressExpectation] timeout:5.0];
	
	XCTAssertGreaterThan(progressCallCount, 0);
}

- (void)testFileDownloadWithInvalidURL {
	NSURL *nilURL = nil;
	BEDataDownloadHandler *handler = [NSData downloadFileWithURL:nilURL
													  completion:^(NSURL *tempFileLocation, NSURLResponse *response) {
		XCTFail(@"Should not be called");
	} error:^(NSError *error, BOOL auxiliary) {
		XCTFail(@"Should not be called");
	}];
	
	XCTAssertNil(handler);
}

#pragma mark - File Download Tests (Delegate-based)

- (void)testFileDownloadWithDelegate {
	NSString *testString = @"File delegate test";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	TestDownloadDelegate *delegate = [[TestDownloadDelegate alloc] init];
	delegate.completionExpectation = [self expectationWithDescription:@"Delegate file completion"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/file.dat"];
	BEDataDownloadHandler *handler = [NSData downloadFileWithURL:url delegate:delegate];
	
	XCTAssertNotNil(handler);
	XCTAssertEqual(handler.delegate, delegate);
	
	[self waitForExpectations:@[delegate.completionExpectation] timeout:5.0];
	
	XCTAssertNotNil(delegate.completedFileURL);
	XCTAssertNotNil(delegate.response);
	
	NSData *fileData = [NSData dataWithContentsOfURL:delegate.completedFileURL];
	XCTAssertEqualObjects(fileData, testData);
}

#pragma mark - Handler Control Tests
/*!
 @method     testHandlerPauseResume
 @abstract   Tests the pause and resume functionality of BEDataDownloadHandler.
 @discussion This test verifies that a download task can be paused and resumed multiple times,
			 and that it completes successfully after being resumed. It tests:
			 - Task starts in suspended state when delayResume is YES
			 - Handler can resume a suspended task
			 - Handler can pause a running task
			 - Task can be resumed again after being paused
			 - Download completes successfully after pause/resume cycle
			 - Handler's isComplete property is set correctly
 */
- (void)testHandlerPauseResume {
	// Setup mock response
	NSData *testData = [@"Pause resume test" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	// Create expectation for async completion
	XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Download completes after pause/resume"];
	
	// Create URL and handler
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.delayResume = YES; // Start in suspended state
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
		XCTAssertEqualObjects(data, testData, @"Downloaded data should match test data");
		[completionExpectation fulfill];
	};
	
	// Start the download task (will be suspended due to delayResume)
	NSURLSessionDataTask *task = [NSData dataDownloadWithContentsOfURL:url handler:handler];
	
	// Verify initial state
	XCTAssertNotNil(task, @"Task should be created");
	XCTAssertNotNil(handler.task, @"Handler should have task reference");
	XCTAssertEqual(handler.task, task, @"handler task should be the output task");
	XCTAssertEqual(task.state, NSURLSessionTaskStateSuspended, @"Task should start suspended");
	
	// Test resume functionality
	[handler resume];
	XCTAssertEqual(task.state, NSURLSessionTaskStateRunning, @"Task should be running after resume");
	
	// Test pause functionality
	[handler pause];
	// Note: State may be NSURLSessionTaskStateSuspended, but in mock environment
	// the task might complete before pause takes effect
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	[handler URLSession:nil downloadTask:nil didResumeAtOffset:50 expectedTotalBytes:100];
#pragma clang diagnostic pop
	// Resume again to ensure completion
	[handler resume];
	
	// Wait for completion
	[self waitForExpectations:@[completionExpectation] timeout:5.0];
	
	// Verify final state
	XCTAssertTrue(handler.isComplete, @"Handler should be marked as complete");
	XCTAssertNotNil(handler.data, @"Handler should have downloaded data");
	XCTAssertEqualObjects(handler.data, testData, @"Handler's data should match test data");
}

#pragma mark - Unknown Content Length Tests

- (void)testDataDownloadWithUnknownContentLength {
	NSData *testData = [@"Unknown length data" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:@{}]; // No Content-Length header
	
	XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Download completes"];
	
	__block int64_t reportedExpectedLength = 0;
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		XCTAssertEqualObjects(data, testData);
		[completionExpectation fulfill];
	} error:nil progress:^(int64_t totalBytesReceived, int64_t totalBytesExpected) {
		reportedExpectedLength = totalBytesExpected;
	}];
	
	XCTAssertNotNil(handler);
	
	[self waitForExpectations:@[completionExpectation] timeout:5.0];
	
	// Should report -1 for unknown length
	XCTAssertEqual(reportedExpectedLength, -1);
}

#pragma mark - Associated Objects Tests

- (void)testDownloadHandlerAssociatedObject {
	NSData *data = [@"Test" dataUsingEncoding:NSUTF8StringEncoding];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	
	XCTAssertNil(data.downloadHandler);
	
	data.downloadHandler = handler;
	
	XCTAssertEqual(data.downloadHandler, handler);
	
	data.downloadHandler = nil;
	
	XCTAssertNil(data.downloadHandler);
}

#pragma mark - Edge Cases and Error Handling

- (void)testHandlerWithNilURLAndDelegate {
	NSURL *nilURL = nil;
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:nilURL delegate:nil];
	
	XCTAssertNil(handler);
}

- (void)testHandlerWithNilURLAndHandler {
	NSURL *nilURL = nil;
	NSURLSessionDataTask *task = [NSData dataDownloadWithContentsOfURL:nilURL handler:nil];
	
	XCTAssertNil(task);
}

- (void)testHandlerWithValidURLButNilHandler {
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	NSURLSessionDataTask *task = [NSData dataDownloadWithContentsOfURL:url handler:nil];
	
	XCTAssertNil(task);
}

- (void)testFileDownloadWithNilURLAndDelegate {
	NSURL *nilURL = nil;
	BEDataDownloadHandler *handler = [NSData downloadFileWithURL:nilURL delegate:nil];
	
	XCTAssertNil(handler);
}

- (void)testFileDownloadWithNilURLAndHandler {
	NSURL *nilURL = nil;
	NSURLSessionDownloadTask *task = [NSData downloadFileWithURL:nilURL handler:nil];
	
	XCTAssertNil(task);
}

- (void)testFileDownloadWithValidURLButNilHandler {
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	NSURLSessionDownloadTask *task = [NSData downloadFileWithURL:url handler:nil];
	
	XCTAssertNil(task);
}

- (void)testNilDelegateDoesNotCrash {
	NSData *testData = [@"Nil delegate test" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Completion with nil delegate"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.delegate = nil;
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
		[expectation fulfill];
	};
	
	[NSData dataDownloadWithContentsOfURL:url handler:handler];
	
	[self waitForExpectations:@[expectation] timeout:5.0];
}

- (void)testEmptyDataDownload {
	NSData *emptyData = [NSData data];
	[MockURLProtocol setMockResponse:emptyData statusCode:200 headers:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Empty data download"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/empty.txt"];
	__unused BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		XCTAssertEqual(data.length, 0);
		[expectation fulfill];
	} error:nil];
	
	[self waitForExpectations:@[expectation] timeout:5.0];
}

- (void)testLargeDataDownload {
	// Create 1MB of data
	NSMutableData *largeData = [NSMutableData dataWithLength:1024 * 1024];
	[MockURLProtocol setMockResponse:largeData statusCode:200 headers:@{@"Content-Length": @"1048576"}];
	[MockURLProtocol setProgressSimulation:YES chunkSize:10240];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Large data download"];
	
	__block NSInteger progressCount = 0;
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/large.bin"];
	__unused BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		XCTAssertEqual(data.length, largeData.length);
		[expectation fulfill];
	}
																	 error:nil
																  progress:^(int64_t totalBytesReceived, int64_t totalBytesExpected) {
		progressCount++;
	}];
	
	[self waitForExpectations:@[expectation] timeout:10.0];
	
	XCTAssertGreaterThan(progressCount, 1); // Should have many progress callbacks
}

#pragma mark - HTTP Status Code Tests

- (void)testDownloadWith404Response {
	NSData *errorData = [@"Not Found" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:errorData statusCode:404 headers:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"404 response handled"];
	
	NSURL *url = [NSURL URLWithString:@"http://github.com/file_not_found.txt.txt"];
	__unused BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		// Note: NSURLSession doesn't treat HTTP errors as task errors by default
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		XCTAssertEqual(httpResponse.statusCode, 404);
		[expectation fulfill];
	} error:nil];
	
	[self waitForExpectations:@[expectation] timeout:5.0];
}

- (void)testDownloadWith500Response {
	NSData *errorData = [@"Server Error" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:errorData statusCode:500 headers:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"500 response handled"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/error.txt"];
	__unused BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		XCTAssertEqual(httpResponse.statusCode, 500);
		[expectation fulfill];
	} error:nil];
	
	[self waitForExpectations:@[expectation] timeout:5.0];
}

#pragma mark - Multiple Simultaneous Downloads

- (void)testMultipleSimultaneousDownloads {
	NSData *testData1 = [@"Download 1" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData1 statusCode:200 headers:nil];
	
	XCTestExpectation *expectation1 = [self expectationWithDescription:@"Download 1"];
	XCTestExpectation *expectation2 = [self expectationWithDescription:@"Download 2"];
	
	NSURL *url1 = [NSURL URLWithString:@"http://example.com/file1.txt"];
	NSURL *url2 = [NSURL URLWithString:@"http://example.com/file2.txt"];
	
	BEDataDownloadHandler *handler1 = [NSData dataDownloadWithContentsOfURL:url1
																  completion:^(NSData *data, NSURLResponse *response) {
		[expectation1 fulfill];
	} error:nil];
	
	BEDataDownloadHandler *handler2 = [NSData dataDownloadWithContentsOfURL:url2
																  completion:^(NSData *data, NSURLResponse *response) {
		[expectation2 fulfill];
	} error:nil];
	
	XCTAssertNotNil(handler1);
	XCTAssertNotNil(handler2);
	XCTAssertNotEqual(handler1, handler2);
	
	[self waitForExpectations:@[expectation1, expectation2] timeout:5.0];
}

#pragma mark - Block Retention Tests

- (void)testBlocksAreRetained {
	NSData *testData = [@"Block retention" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Block executed"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	
	@autoreleasepool {
		BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
		
		NSDataCompletionBlock completionBlock = ^(NSData *data, NSURLResponse *response) {
			[completionExpectation fulfill];
		};
		
		handler.dataCompletionBlock = completionBlock;
		
		[NSData dataDownloadWithContentsOfURL:url handler:handler];
		
		// Handler and blocks should be retained by the session
	}
	
	[self waitForExpectations:@[completionExpectation] timeout:5.0];
}

#pragma mark - Task State Tests

- (void)testTaskStateAfterCreation {
	NSData *testData = [@"Task state test" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {};
	
	NSURLSessionDataTask *task = [NSData dataDownloadWithContentsOfURL:url handler:handler];
	
	XCTAssertNotNil(task);
	XCTAssertEqual(task.state, NSURLSessionTaskStateRunning);
}

- (void)testTaskStateWithDelayResume {
	NSData *testData = [@"Delayed task" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.delayResume = YES;
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {};
	
	NSURLSessionDataTask *task = [NSData dataDownloadWithContentsOfURL:url handler:handler];
	
	XCTAssertNotNil(task);
	XCTAssertEqual(task.state, NSURLSessionTaskStateSuspended);
}

#pragma mark - Response Headers Tests

- (void)testResponseHeadersAccessible {
	NSData *testData = [@"Headers test" dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *headers = @{
		@"Content-Type": @"text/plain",
		@"Content-Length": @"12",
		@"X-Custom-Header": @"CustomValue"
	};
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:headers];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Headers accessible"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	__unused BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		XCTAssertTrue([response isKindOfClass:[NSHTTPURLResponse class]]);
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		XCTAssertEqualObjects(httpResponse.allHeaderFields[@"Content-Type"], @"text/plain");
		XCTAssertEqualObjects(httpResponse.allHeaderFields[@"X-Custom-Header"], @"CustomValue");
		[expectation fulfill];
	} error:nil];
	
	[self waitForExpectations:@[expectation] timeout:5.0];
}

#pragma mark - Completion State Tests

- (void)testIsCompletePropertyAfterSuccess {
	NSData *testData = [@"Complete test" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Completion state"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		[expectation fulfill];
	} error:nil];
	
	XCTAssertFalse(handler.isComplete);
	
	[self waitForExpectations:@[expectation] timeout:5.0];
	
	XCTAssertTrue(handler.isComplete);
}

- (void)testIsCompletePropertyAfterError {
	NSError *testError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNetworkConnectionLost userInfo:nil];
	[MockURLProtocol setMockError:testError];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Error completion state"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		XCTFail(@"Should not succeed");
	} error:^(NSError *error, BOOL auxiliary) {
		[expectation fulfill];
	}];
	
	XCTAssertFalse(handler.isComplete);
	
	[self waitForExpectations:@[expectation] timeout:5.0];
	
	XCTAssertTrue(handler.isComplete);
}

#pragma mark - Data Property Tests

- (void)testDataPropertyPopulatedAfterCompletion {
	NSData *testData = [@"Data property test" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Data property"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		[expectation fulfill];
	} error:nil];
	
	XCTAssertNil(handler.data);
	
	[self waitForExpectations:@[expectation] timeout:5.0];
	
	XCTAssertNotNil(handler.data);
	XCTAssertEqualObjects(handler.data, testData);
}

- (void)testReceivedDataPropertyDuringDownload {
	NSMutableData *testData = [NSMutableData dataWithLength:5000];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:@{@"Content-Length": @"5000"}];
	[MockURLProtocol setProgressSimulation:YES chunkSize:500];
	
	XCTestExpectation *progressExpectation = [self expectationWithDescription:@"Progress with receivedData"];
	XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Completion"];
	
	__block BEDataDownloadHandler *handlerRef = nil;
	__block int progressCount = 0;
	NSURL *url = [NSURL URLWithString:@"http://example.com/data.bin"];
	handlerRef = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		[completionExpectation fulfill];
	} error:nil progress:^(int64_t totalBytesReceived, int64_t totalBytesExpected) {
		if (handlerRef.receivedData.length > 0 && !progressExpectation.isInverted) {
			XCTAssertNotNil(handlerRef.receivedData);
			XCTAssertGreaterThan(handlerRef.receivedData.length, 0);
			if (!progressCount++)
				[progressExpectation fulfill];
		}
	}];
	
	[self waitForExpectations:@[progressExpectation, completionExpectation] timeout:5.0];
}

#pragma mark - Auxiliary Error Tests

- (void)testBothCompletionsEnabledWithOnlyDataConsumer {
	// allowBothCompletions is YES but no file consumer (tempCompletionBlock or delegate) is set,
	// so only the data callback fires and no temp file is written. The auxiliary write-error path
	// is covered by testDataDownloadWithBlockWriteError / testDataDownloadWithDelegateWriteError.
	NSData *testData = [@"Both completions, data consumer only" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];

	XCTestExpectation *dataExpectation = [self expectationWithDescription:@"Data completion"];

	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.allowBothCompletions = YES;
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
		[dataExpectation fulfill];
	};

	[NSData dataDownloadWithContentsOfURL:url handler:handler];

	[self waitForExpectations:@[dataExpectation] timeout:5.0];
}

#pragma mark - Thread Safety Tests
/*!
 @method     testCallbacksOnMainQueue
 @abstract   Tests that all callbacks are executed on the main queue.
 @discussion This test verifies that both completion and progress callbacks are delivered
			 on the main thread, as specified by the NSOperationQueue mainQueue configuration
			 in the implementation. This is important for UI updates and thread-safe operation.
			 
			 Tests:
			 - Completion block is called on main thread
			 - Progress block is called on main thread
			 - Download completes successfully
 */
- (void)testCallbacksOnMainQueue {
	// Setup mock response
	NSData *testData = [@"Main queue test" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	// Create expectation for async completion
	XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Main queue callback"];
	
	// Create URL and start download
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:url
																completion:^(NSData *data, NSURLResponse *response) {
		// Verify completion is on main thread
		XCTAssertTrue([NSThread isMainThread], @"Completion block should be called on main thread");
		XCTAssertNotNil(data, @"Data should not be nil");
		XCTAssertEqualObjects(data, testData, @"Downloaded data should match test data");
		[completionExpectation fulfill];
	} error:^(NSError *error, BOOL auxiliary) {
		XCTFail(@"Error block should not be called: %@", error);
	} progress:^(int64_t totalBytesReceived, int64_t totalBytesExpected) {
		// Verify progress is on main thread
		XCTAssertTrue([NSThread isMainThread], @"Progress block should be called on main thread");
		XCTAssertGreaterThan(totalBytesReceived, 0, @"Should have received some bytes");
	}];
	
	// Verify handler was created
	XCTAssertNotNil(handler, @"Handler should be created");
	
	// Wait for completion
	[self waitForExpectations:@[completionExpectation] timeout:5.0];
	
	// Verify final state
	XCTAssertTrue(handler.isComplete, @"Handler should be marked as complete");
}

- (void)testHandlerCancel {
	NSData *testData = [@"Cancel test" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.delayResume = YES;
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
		XCTFail(@"Should not complete after cancel");
	};
	
	NSURLSessionDataTask *task = [NSData dataDownloadWithContentsOfURL:url handler:handler];
	
	XCTAssertNotNil(task);
	
	[handler cancel];
	// Task should be cancelled
}

- (void)testDelayResumeProperty {
	NSData *testData = [@"Delay resume" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Manual resume completion"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.delayResume = YES;
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
		[expectation fulfill];
	};
	
	NSURLSessionDataTask *task = [NSData dataDownloadWithContentsOfURL:url handler:handler];
	
	XCTAssertNotNil(task);
	XCTAssertEqual(task.state, NSURLSessionTaskStateSuspended);
	
	[handler resume];
	
	[self waitForExpectations:@[expectation] timeout:5.0];
}

#pragma mark - allowBothCompletions Tests

- (void)testDataDownloadWithBothCompletionsEnabled {
	NSString *testString = @"Both completions test";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *dataExpectation = [self expectationWithDescription:@"Data completion"];
	XCTestExpectation *fileExpectation = [self expectationWithDescription:@"File completion"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.allowBothCompletions = YES;
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
		XCTAssertEqualObjects(data, testData);
		[dataExpectation fulfill];
	};
	handler.tempCompletionBlock = ^(NSURL *tempFileLocation, NSURLResponse *response) {
		NSData *fileData = [NSData dataWithContentsOfURL:tempFileLocation];
		XCTAssertEqualObjects(fileData, testData);
		[fileExpectation fulfill];
	};
	
	[NSData dataDownloadWithContentsOfURL:url handler:handler];

	[self waitForExpectations:@[dataExpectation, fileExpectation] timeout:5.0];
}

- (void)testDataDownloadBothCompletionsDeletesTempFileAfterCallback {
	NSData *testData = [@"temp cleanup test" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];

	XCTestExpectation *fileExpectation = [self expectationWithDescription:@"File completion"];
	__block NSURL *capturedLocation = nil;

	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.allowBothCompletions = YES;
	handler.tempCompletionBlock = ^(NSURL *tempFileLocation, NSURLResponse *response) {
		capturedLocation = tempFileLocation;
		// The synthesized temp file must be present for the duration of the callback.
		XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:tempFileLocation.path]);
		[fileExpectation fulfill];
	};

	[NSData dataDownloadWithContentsOfURL:url handler:handler];

	[self waitForExpectations:@[fileExpectation] timeout:5.0];

	// The deletion runs in the same didCompleteWithError: callout, right after the block returns,
	// so by the time the wait unblocks the synthesized temp file is gone (its lifetime matches a
	// download task's location — valid only for the callback, not the caller's to keep).
	XCTAssertNotNil(capturedLocation);
	XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:capturedLocation.path],
				   @"Synthesized temp file should be deleted after the completion callback returns");
}

- (void)testDownloadSessionReleasesHandlerAfterCompletion {
	NSData *testData = [@"release test" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];

	XCTestExpectation *completion = [self expectationWithDescription:@"completion"];
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];

	__weak BEDataDownloadHandler *weakHandler = nil;
	@autoreleasepool {
		BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
		weakHandler = handler;
		handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
			[completion fulfill];
		};
		[NSData dataDownloadWithContentsOfURL:url handler:handler];
		// Drop our only strong reference. A delegate session retains its delegate until invalidated;
		// the factory's -finishTasksAndInvalidate must let it go once the task completes.
		handler = nil;
	}

	[self waitForExpectations:@[completion] timeout:5.0];

	// Spin the runloop briefly to let session invalidation propagate, then the handler must be gone.
	// Without the -finishTasksAndInvalidate fix the session would retain it for the process lifetime.
	NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:2.0];
	while (weakHandler != nil && [deadline timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.02]];
	}
	XCTAssertNil(weakHandler, @"Download session must release the handler after completion (no leak)");
}

- (void)testDataDownloadWithBothCompletionsDisable {
	NSString *testString = @"Both completions test";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *dataExpectation = [self expectationWithDescription:@"Data completion"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.allowBothCompletions = NO;
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
		XCTAssertEqualObjects(data, testData);
		[dataExpectation fulfill];
	};
	handler.tempCompletionBlock = ^(NSURL *tempFileLocation, NSURLResponse *response) {
		XCTFail(@"tempCompletionBlock should not fire when allowBothCompletions is NO");
	};

	[NSData dataDownloadWithContentsOfURL:url handler:handler];
	
	[self waitForExpectations:@[dataExpectation] timeout:5.0];
}

- (void)testFileDownloadWithBothCompletionsEnabled {
	NSString *testString = @"File both completions";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *dataExpectation = [self expectationWithDescription:@"Data completion"];
	XCTestExpectation *fileExpectation = [self expectationWithDescription:@"File completion"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.dat"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	// Download file to temp
	handler.tempCompletionBlock = ^(NSURL *tempFileLocation, NSURLResponse *response) {
		[fileExpectation fulfill];
	};
	
	handler.allowBothCompletions = YES;
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
		XCTAssertEqualObjects(data, testData);
		[dataExpectation fulfill];
	};
	
	[NSData downloadFileWithURL:url handler:handler];
	
	[self waitForExpectations:@[dataExpectation, fileExpectation] timeout:5.0];
}

- (void)testFileDownloadWithBothCompletionsDisabled {
	NSString *testString = @"File both completions";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *fileExpectation = [self expectationWithDescription:@"File completion"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.dat"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	// Download file to temp
	handler.tempCompletionBlock = ^(NSURL *tempFileLocation, NSURLResponse *response) {
		[fileExpectation fulfill];
	};
	
	handler.allowBothCompletions = NO;
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
		XCTFail(@"dataCompletionBlock should not fire when allowBothCompletions is NO");
	};

	[NSData downloadFileWithURL:url handler:handler];
	
	[self waitForExpectations:@[fileExpectation] timeout:5.0];
}

- (void)testDataDelegateWithBothCompletions {
	NSString *testString = @"Delegate both completions";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	TestDownloadDelegate *delegate = [[TestDownloadDelegate alloc] init];
	delegate.completionExpectation = [self expectationWithDescription:@"Delegate completions"];
	delegate.completionExpectation.expectedFulfillmentCount = 2; // Both data and file
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.allowBothCompletions = YES;
	handler.delegate = delegate;
	
	[NSData dataDownloadWithContentsOfURL:url handler:handler];
	
	[self waitForExpectations:@[delegate.completionExpectation] timeout:5.0];
	
	XCTAssertNotNil(delegate.completedData);
	XCTAssertNotNil(delegate.completedFileURL);
}



- (void)testFileDelegateWithBothCompletions {
	NSString *testString = @"Delegate both completions";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	TestDownloadDelegate *delegate = [[TestDownloadDelegate alloc] init];
	delegate.completionExpectation = [self expectationWithDescription:@"Delegate completions"];
	delegate.completionExpectation.expectedFulfillmentCount = 2; // Both data and file
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.allowBothCompletions = YES;
	handler.delegate = delegate;
	
	[NSData downloadFileWithURL:url handler:handler];
	
	[self waitForExpectations:@[delegate.completionExpectation] timeout:5.0];
	
	XCTAssertNotNil(delegate.completedData);
	XCTAssertNotNil(delegate.completedFileURL);
}

#pragma mark - suppressCompletionWarnings Tests

- (void)testSuppressCompletionWarnings {
	NSData *testData = [@"Warning suppression" dataUsingEncoding:NSUTF8StringEncoding];
	[MockURLProtocol setMockResponse:testData statusCode:200 headers:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Completion with suppressed warnings"];
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/test.txt"];
	BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
	handler.suppressCompletionWarnings = YES;
	handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
		XCTAssertEqualObjects(data, testData);
		[expectation fulfill];
	};
	// Setting a mismatched completion handler (file on data task) - should not warn
	handler.tempCompletionBlock = ^(NSURL *tempFileLocation, NSURLResponse *response) {
		XCTFail(@"Should not be called");
	};
	
	[NSData dataDownloadWithContentsOfURL:url handler:handler];
	
	[self waitForExpectations:@[expectation] timeout:5.0];
}


@end
