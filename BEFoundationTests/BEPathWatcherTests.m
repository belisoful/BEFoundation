#import <XCTest/XCTest.h>
#import "BEPathWatcher.h"

// A mock class to test the target-selector mechanism.
// This class has methods that match the various signatures now supported by BEPathWatcher.
@interface MockTarget : NSObject
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, assign) unsigned long lastReceivedFlags;
@property (nonatomic, weak) BEPathWatcher *lastReceivedWatcher;
@property (nonatomic, assign) BOOL zeroArgMethodCalled;
@property (nonatomic, assign) BOOL oneArgMethodCalled;
@property (nonatomic, assign) BOOL twoArgMethodCalled;

- (void)pathDidChange; // Zero arguments
- (void)pathDidChange:(BEPathWatcher *)watcher; // One argument
- (void)pathDidChange:(BEPathWatcher *)watcher withFlags:(unsigned long)flags; // Two arguments
@end

@implementation MockTarget
- (void)pathDidChange {
	self.zeroArgMethodCalled = YES;
	if (self.expectation)
		[self.expectation fulfill];
}

- (void)pathDidChange:(BEPathWatcher *)watcher {
	self.oneArgMethodCalled = YES;
	self.lastReceivedWatcher = watcher;
	if (self.expectation)
		[self.expectation fulfill];
}

- (void)pathDidChangeWithFlags:(unsigned long)flags {
	self.oneArgMethodCalled = YES;
	self.lastReceivedFlags = flags;
	if (self.expectation)
		[self.expectation fulfill];
}

- (void)pathDidChange:(BEPathWatcher *)watcher withFlags:(unsigned long)flags {
	self.twoArgMethodCalled = YES;
	self.lastReceivedWatcher = watcher;
	self.lastReceivedFlags = flags;
	if (self.expectation)
		[self.expectation fulfill];
}
@end

// A mock subclass that conforms to the BEPathWatcher protocol to test the hook method.
@interface ConformingSubclassWatcher : BEPathWatcher
@property (nonatomic, strong) XCTestExpectation *hookExpectation;
@property (nonatomic, assign) BOOL hookWasCalled;
@end

@implementation ConformingSubclassWatcher
// This is the implementation of the optional protocol method.
- (void)pathDidChangeWithFlags:(unsigned long)flags {
	self.hookWasCalled = YES;
	[self.hookExpectation fulfill];
}
@end


@interface BEPathWatcherTests : XCTestCase

@property (nonatomic, strong) BEPathWatcher *watcher;
@property (nonatomic, strong) NSString *tempDirectory;
@property (nonatomic, strong) NSString *testFilePath;
@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation BEPathWatcherTests

- (void)setUp {
	[super setUp];
	// Set up a temporary directory and a file for testing file system events.
	self.fileManager = [NSFileManager defaultManager];
	NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
	self.tempDirectory = tempDir;
	self.testFilePath = [tempDir stringByAppendingPathComponent:@"test.txt"];

	// Create the temporary directory and a file inside it.
	NSError *error = nil;
	[self.fileManager createDirectoryAtPath:self.tempDirectory withIntermediateDirectories:YES attributes:nil error:&error];
	XCTAssertNil(error, "Failed to create temporary directory.");

	[@"initial content" writeToFile:self.testFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
	XCTAssertNil(error, "Failed to create test file.");
}

- (void)tearDown {
	// Stop the watcher and remove the temporary directory after each test.
	[self.watcher stopMonitoring];
	self.watcher = nil;

	NSError *error = nil;
	[self.fileManager removeItemAtPath:self.tempDirectory error:&error];
	// We don't assert nil here because some tests might have already deleted the directory.

	[super tearDown];
}

#pragma mark - Factory Method Tests


- (void)testFactoryWatcherForPathWithBlock {
	XCTestExpectation *blockExpectation = [self expectationWithDescription:@"Block callback expectation"];
	
	self.watcher = [BEPathWatcher watcherForPath:self.testFilePath withBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		[blockExpectation fulfill];
	}];
	
	[self.watcher startMonitoring];
	XCTAssertTrue(self.watcher.isActive);

	// Trigger an event
	[@"new content" writeToFile:self.testFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	[self waitForExpectationsWithTimeout:1.0 handler:nil];
}


- (void)testFactoryWatcherForPathMaskWithBlock {
	XCTestExpectation *blockExpectation = [self expectationWithDescription:@"Block callback expectation"];
	
	self.watcher = [BEPathWatcher watcherForPath:self.testFilePath eventMask:DISPATCH_VNODE_WRITE withBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		[blockExpectation fulfill];
	}];
	
	[self.watcher startMonitoring];
	XCTAssertTrue(self.watcher.isActive);
	XCTAssertEqual(self.watcher.eventMask, DISPATCH_VNODE_WRITE);

	// Trigger an event
	[@"new content" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	[self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testFactoryWatcherForPathWithTargetSelector {
	XCTestExpectation *selectorExpectation = [self expectationWithDescription:@"Target-selector callback expectation"];
	MockTarget *target = [[MockTarget alloc] init];
	target.expectation = selectorExpectation;
	
	self.watcher = [BEPathWatcher watcherForPath:self.testFilePath target:target selector:@selector(pathDidChange:withFlags:)];
	XCTAssertTrue(self.watcher.isActive);

	// Trigger an event
	[@"new content" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	XCTAssertNotNil(target.lastReceivedWatcher);
	XCTAssertTrue(target.lastReceivedFlags & DISPATCH_VNODE_WRITE);
}

- (void)testFactoryWatcherForPathWithMaskTargetSelector {
	XCTestExpectation *noAttribExpectation = [self expectationWithDescription:@"Target-selector callback no expectation"];
	noAttribExpectation.inverted = YES;
	MockTarget *target = [[MockTarget alloc] init];
	target.expectation = noAttribExpectation;
	
	self.watcher = [BEPathWatcher watcherForPath:self.testFilePath eventMask:DISPATCH_VNODE_REVOKE target:target selector:@selector(pathDidChange:withFlags:)];
	XCTAssertTrue(self.watcher.isActive);
	XCTAssertEqual(self.watcher.eventMask, DISPATCH_VNODE_REVOKE);

	// Trigger an event
	[@"new content" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	XCTestExpectation *delay = [self expectationWithDescription:@"Wait for event to process"];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[delay fulfill];
	});
	[self waitForExpectations:@[delay, noAttribExpectation] timeout:1.0];
	XCTAssertNil(target.lastReceivedWatcher);
	XCTAssertEqual(target.lastReceivedFlags, 0);
	
	self.watcher.eventMask = DISPATCH_VNODE_ATTRIB;
	XCTestExpectation *attribExpectation = [self expectationWithDescription:@"Target-selector callback no expectation"];
	target.expectation = attribExpectation;
	
	// Trigger an attribute change event
	NSDictionary *attributes = @{NSFileModificationDate: [NSDate date]};
	[self.fileManager setAttributes:attributes ofItemAtPath:self.testFilePath error:nil];
	
	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	XCTAssertNotNil(target.lastReceivedWatcher);
	XCTAssertTrue(target.lastReceivedFlags & DISPATCH_VNODE_ATTRIB);
}


- (void)testFactoryWatcherForPathWithTargetWithoutSelector {
	MockTarget *target = [[MockTarget alloc] init];
	
	SEL nilSelector = nil;
	self.watcher = [BEPathWatcher watcherForPath:self.testFilePath target:target selector:nilSelector];
	XCTAssertFalse(self.watcher.isActive);
}


#pragma mark - Initialization and Factory Method Tests

- (void)testDefaultInit {
	self.watcher = [[BEPathWatcher alloc] init];
	XCTAssertNotNil(self.watcher, "Default init should create a non-nil watcher.");
	XCTAssertNil(self.watcher.path, "Path should be nil after default init.");
	XCTAssertEqual(self.watcher.eventMask, DISPATCH_VNODE_WRITE | DISPATCH_VNODE_DELETE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_RENAME, "Mask should have the default value.");
	XCTAssertFalse(self.watcher.isActive, "Watcher should not be active after default init.");
}

- (void)testInitWithPath {
	self.watcher = [[BEPathWatcher alloc] initWithPath:self.testFilePath];
	XCTAssertNotNil(self.watcher, "Watcher should not be nil.");
	XCTAssertEqualObjects(self.watcher.path, self.testFilePath, "Path should be set correctly.");
	XCTAssertFalse(self.watcher.isActive, "Watcher should not be active after init.");
}

- (void)testInitWithInvalidPath {
	NSString *invalidPath = @"/non_existent_path/file.txt";
	// This initializer doesn't start monitoring, so it should succeed.
	self.watcher = [[BEPathWatcher alloc] initWithPath:invalidPath];
	XCTAssertNotNil(self.watcher);
	XCTAssertEqualObjects(self.watcher.path, invalidPath);
	XCTAssertFalse(self.watcher.isActive);
	
	// Starting monitoring should fail
	XCTAssertFalse([self.watcher startMonitoring]);
	XCTAssertFalse(self.watcher.isActive);
}

- (void)testInitWithPathAndStartMonitoring {
	self.watcher = [[BEPathWatcher alloc] initWithPath:self.testFilePath];
	XCTAssertFalse([self.watcher startMonitoring], @"Not a subclass of BEPathWatcher, no target/selector, no block");
	XCTAssertFalse(self.watcher.isActive, @"not active due to no handlers");
}

- (void)testInitWithPathEventMaskAndBlockFailsWithInvalidPath {
	NSString *invalidPath = @"/non_existent_path/file.txt";
	self.watcher = [[BEPathWatcher alloc] initWithPath:invalidPath eventMask:DISPATCH_VNODE_WRITE withBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		XCTFail("Block should not be called for a failed watcher.");
	}];
	// This specific initializer tries to start watching immediately, so it should return nil for an invalid path.
	XCTAssertNil(self.watcher, "Initializer should fail and return nil for an invalid path.");
}

- (void)testInitWithTargetSelector {
	MockTarget *target = [[MockTarget alloc] init];
	
	self.watcher = [[BEPathWatcher alloc] initWithTarget:target selector:@selector(pathDidChange:withFlags:)];
	XCTAssertNotNil(self.watcher, "Watcher should not be nil.");
	XCTAssertNil(self.watcher.path, "Path should be nil.");
	XCTAssertFalse(self.watcher.isActive, "Watcher should not be active after init.");
	XCTAssertEqual(self.watcher.target, target, "Watcher target should not be nil.");
	XCTAssertTrue(self.watcher.selector == @selector(pathDidChange:withFlags:), "Watcher selector should not be nil.");
	XCTAssertNil(self.watcher.eventHandler, "Watcher eventHandler should be nil.");
}

- (void)testInitWithBlock {
	__block int count = 0;
	self.watcher = [[BEPathWatcher alloc] initWithBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		count++;
	}];
	XCTAssertNotNil(self.watcher, "Watcher should not be nil.");
	XCTAssertNil(self.watcher.path, "Path should be nil.");
	XCTAssertFalse(self.watcher.isActive, "Watcher should not be active after init.");
	XCTAssertNil(self.watcher.target, "Watcher target should be nil.");
	XCTAssertTrue(self.watcher.selector == nil, "Watcher selector should be nil.");
	XCTAssertNotNil(self.watcher.eventHandler, "Watcher eventHandler should not be nil.");
	XCTAssertEqual(count, 0, "Event Handler should not be called");
}



#pragma mark - Property Setter Tests

- (void)testSetPathWhenActive {
	XCTestExpectation *expectation1 = [self expectationWithDescription:@"Callback for new path"];
	
	self.watcher = [[BEPathWatcher alloc] init];
	[self.watcher watchPath:self.testFilePath withBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		XCTAssertEqualObjects(watcher.path, self.testFilePath);
		[expectation1 fulfill];
	}];
	XCTAssertTrue(self.watcher.isActive, "Watcher should be active.");
	[@"updated test file" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	[self waitForExpectations:@[expectation1] timeout:1.0];
	
	NSString *newPath = [self.tempDirectory stringByAppendingPathComponent:@"newfile.txt"];
	[@"new" writeToFile:newPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	self.watcher.path = newPath;
	XCTAssertEqualObjects(self.watcher.path, newPath, "Path should be updated.");
	XCTAssertTrue(self.watcher.isActive, "Watcher should remain active after path change.");
	self.watcher.path = self.watcher.path;
	XCTAssertEqualObjects(self.watcher.path, self.watcher.path, "Path should be the same.");
	
	// Test that the new path is being watched
	XCTestExpectation *expectation2 = [self expectationWithDescription:@"Callback for new path"];
	[self.watcher watchWithBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		XCTAssertEqualObjects(watcher.path, newPath);
		[expectation2 fulfill];
	}];
	XCTAssertTrue(self.watcher.isActive, "Watcher should remain active after path change.");
	
	[@"more content" writeToFile:newPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	[self waitForExpectations:@[expectation2] timeout:3.0];
	
	self.watcher.path = nil;
	XCTAssertFalse(self.watcher.isActive, "Watcher should remain active after path change.");
	XCTAssertNil(self.watcher.path, "Path should be nil.");
}

- (void)testSetMaskWhenActive {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Callback with new mask"];
	self.watcher = [[BEPathWatcher alloc] initWithPath:self.testFilePath];
	[self.watcher watchWithBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		XCTAssertTrue(event & DISPATCH_VNODE_ATTRIB, "Event should include attribute changes.");
		[expectation fulfill];
	}];
	
	XCTAssertTrue(self.watcher.isActive);

	// Change the mask to include attribute changes
	self.watcher.eventMask = DISPATCH_VNODE_ATTRIB;
	XCTAssertTrue(self.watcher.isActive, "Watcher should remain active after mask change.");

	// Trigger an attribute change event
	NSDictionary *attributes = @{NSFileModificationDate: [NSDate date]};
	[self.fileManager setAttributes:attributes ofItemAtPath:self.testFilePath error:nil];

	[self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testSetIsActive {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Callback with new mask"];
	expectation.inverted = YES;
	self.watcher = [[BEPathWatcher alloc] initWithPath:self.testFilePath];
	XCTAssertFalse(self.watcher.isActive);
	
	self.watcher.eventHandler = ^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		XCTAssertTrue(event & DISPATCH_VNODE_ATTRIB, "Event should include attribute changes.");
		[expectation fulfill];
	};
	XCTAssertFalse(self.watcher.isActive);
	
	self.watcher.isActive = YES;
	XCTAssertTrue(self.watcher.isActive, "Setting isActive to YES should start monitoring.");
	
	XCTestExpectation *delay = [self expectationWithDescription:@"Wait for event to process"];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[delay fulfill];
	});
	[self waitForExpectations:@[delay, expectation] timeout:1.0];
	
	self.watcher.isActive = NO;
	XCTAssertFalse(self.watcher.isActive, "Setting isActive to NO should stop monitoring.");
}


- (void)testSetTargetSelector {
	__block int count = 0;
	
	self.watcher = [[BEPathWatcher alloc] initWithBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		count++;
	}];
	
	XCTAssertNil(self.watcher.target);
	XCTAssertTrue(self.watcher.selector == nil);
	
	
	MockTarget *target = [[MockTarget alloc] init];
	
	SEL selector = @selector(pathDidChange:);
	[self.watcher setTarget:target selector:selector];
	
	XCTAssertEqual(self.watcher.target, target);
	XCTAssertTrue(self.watcher.selector == selector);
	XCTAssertNil(self.watcher.eventHandler);
}


- (void)testSetEventHandler {
	MockTarget *target = [[MockTarget alloc] init];
	
	self.watcher = [[BEPathWatcher alloc] initWithTarget:target selector:@selector(pathDidChange:)];
	
	XCTAssertNil(self.watcher.eventHandler);
	
	__block int count = 0;
	self.watcher.eventHandler = ^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		count++;
	};
	
	XCTAssertNil(self.watcher.target);
	XCTAssertTrue(self.watcher.selector == nil);
	XCTAssertNotNil(self.watcher.eventHandler);
}

#pragma mark - Core Logic and Callback Tests

- (void)testStartAndStopMonitoring {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Callback with new mask"];
	expectation.inverted = YES;
	
	self.watcher = [[BEPathWatcher alloc] initWithPath:self.testFilePath];
	XCTAssertFalse(self.watcher.isActive);
	self.watcher.eventHandler = ^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		XCTAssertTrue(event & DISPATCH_VNODE_ATTRIB, "Event should include attribute changes.");
		[expectation fulfill];
	};
	XCTAssertFalse(self.watcher.isActive);
	
	BOOL success = [self.watcher startMonitoring];
	XCTAssertTrue(success, "startMonitoring should succeed for a valid path.");
	XCTAssertTrue(self.watcher.isActive, "Watcher should be active after starting.");
	
	XCTestExpectation *delay = [self expectationWithDescription:@"Wait for event to process"];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[delay fulfill];
	});
	[self waitForExpectations:@[delay, expectation] timeout:1.0];
	
	[self.watcher stopMonitoring];
	XCTAssertFalse(self.watcher.isActive, "Watcher should be inactive after stopping.");
}

- (void)testWatchPathBlock_CallbackOnWrite {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Block callback on write"];
	__block unsigned long receivedFlags = 0;
	
	self.watcher = [[BEPathWatcher alloc] init];
	XCTAssertTrue([self.watcher watchPath:self.testFilePath withBlock:^(BEPathWatcher *watcher, unsigned long flags) {
		receivedFlags = flags;
		[expectation fulfill];
	}]);
	
	XCTAssertTrue(self.watcher.isActive);
	
	// Trigger a write event
	NSError *error;
	[@"some new data" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:&error];
	XCTAssertNil(error);
	
	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	XCTAssertTrue(receivedFlags & DISPATCH_VNODE_WRITE, "The correct event flag should be received.");
}

- (void)testWatchEventMaskBlock_CallbackOnWrite {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Block callback on write"];
	__block unsigned long receivedFlags = 0;

	self.watcher = [[BEPathWatcher alloc] initWithPath:self.testFilePath];
	XCTAssertTrue([self.watcher watchWithEventMask:DISPATCH_VNODE_WRITE withBlock:^(BEPathWatcher *watcher, unsigned long flags) {
		receivedFlags = flags;
		[expectation fulfill];
	}]);
	
	XCTAssertTrue(self.watcher.isActive);
	XCTAssertEqual(self.watcher.eventMask, DISPATCH_VNODE_WRITE);
	XCTAssertEqualObjects(self.watcher.path, self.testFilePath);
	
	// Trigger a write event
	NSError *error;
	[@"some new data" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:&error];
	XCTAssertNil(error);

	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	XCTAssertTrue(receivedFlags & DISPATCH_VNODE_WRITE, "The correct event flag should be received.");
}

- (void)testwatchPathTargetSelector_CallbackWithTwoArgumentsOnWrite {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Target-selector callback on write (2 args)"];
	MockTarget *target = [[MockTarget alloc] init];
	target.expectation = expectation;

	self.watcher = [[BEPathWatcher alloc] init];
	XCTAssertTrue([self.watcher watchPath:self.testFilePath target:target selector:@selector(pathDidChange:withFlags:)]);
	
	XCTAssertTrue(self.watcher.isActive);

	// Trigger a write event
	[@"some new data" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];

	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	XCTAssertTrue(target.twoArgMethodCalled);
	XCTAssertFalse(target.oneArgMethodCalled);
	XCTAssertFalse(target.zeroArgMethodCalled);
	XCTAssertEqual(target.lastReceivedWatcher, self.watcher, "The watcher instance should be passed to the target.");
	XCTAssertTrue(target.lastReceivedFlags & DISPATCH_VNODE_WRITE, "The correct event flag should be received.");
}

- (void)testwatchPathTargetSelector_CallbackWithOneArgumentWatcherOnWrite {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Target-selector callback on write (1 arg)"];
	MockTarget *target = [[MockTarget alloc] init];
	target.expectation = expectation;

	self.watcher = [[BEPathWatcher alloc] init];
	XCTAssertTrue([self.watcher watchPath:self.testFilePath target:target selector:@selector(pathDidChange:)]);
	
	XCTAssertTrue(self.watcher.isActive);

	// Trigger a write event
	[@"some new data" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];

	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	XCTAssertTrue(target.oneArgMethodCalled);
	XCTAssertFalse(target.twoArgMethodCalled);
	XCTAssertFalse(target.zeroArgMethodCalled);
	XCTAssertEqual(target.lastReceivedWatcher, self.watcher, "The watcher instance should be passed to the target.");
}

- (void)testwatchPathTargetSelector_CallbackWithOneArgumentFlagsOnWrite {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Target-selector callback on write (1 arg)"];
	MockTarget *target = [[MockTarget alloc] init];
	target.expectation = expectation;

	self.watcher = [[BEPathWatcher alloc] init];
	XCTAssertTrue([self.watcher watchPath:self.testFilePath target:target selector:@selector(pathDidChangeWithFlags:)]);
	
	XCTAssertTrue(self.watcher.isActive);

	// Trigger a write event
	[@"some new data" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];

	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	XCTAssertTrue(target.oneArgMethodCalled);
	XCTAssertFalse(target.twoArgMethodCalled);
	XCTAssertFalse(target.zeroArgMethodCalled);
	XCTAssertNil(target.lastReceivedWatcher, "The watcher instance should be nil.");
	XCTAssertTrue(target.lastReceivedFlags & DISPATCH_VNODE_WRITE, "The correct event flag should be received.");
}

- (void)testwatchPathTargetSelector_CallbackWithZeroArgumentsOnWrite {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Target-selector callback on write (0 args)"];
	MockTarget *target = [[MockTarget alloc] init];
	target.expectation = expectation;

	self.watcher = [[BEPathWatcher alloc] init];
	XCTAssertTrue([self.watcher watchPath:self.testFilePath target:target selector:@selector(pathDidChange)]);
	
	XCTAssertTrue(self.watcher.isActive);

	// Trigger a write event
	[@"some new data" writeToFile:self.testFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	XCTAssertTrue(target.zeroArgMethodCalled);
	XCTAssertFalse(target.oneArgMethodCalled);
	XCTAssertFalse(target.twoArgMethodCalled);
}

- (void)testwatchPathEventMaskBlock_AutomaticStopOnDelete {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Callback on delete"];
	self.watcher = [[BEPathWatcher alloc] init];
	XCTAssertTrue([self.watcher watchPath:self.testFilePath eventMask:DISPATCH_VNODE_DELETE withBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		XCTAssertTrue(event & DISPATCH_VNODE_DELETE);
		[expectation fulfill];
	}]);
	
	XCTAssertTrue(self.watcher.isActive);
	
	// Trigger delete event
	[self.fileManager removeItemAtPath:self.testFilePath error:nil];
	
	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	
	// The watcher should have stopped automatically. We need to wait briefly for the cancellation handler to run.
	XCTestExpectation *stopExpectation = [self expectationWithDescription:@"Watcher stopped expectation"];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		XCTAssertFalse(self.watcher.isActive, "Watcher should automatically stop after the path is deleted.");
		[stopExpectation fulfill];
	});
	
	[self waitForExpectations:@[stopExpectation] timeout:1.0];
}

- (void)testwatchPathEventMaskBlock_AutomaticStopOnRename {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Callback on rename"];
	self.watcher = [[BEPathWatcher alloc] init];
	XCTAssertTrue([self.watcher watchPath:self.testFilePath eventMask:DISPATCH_VNODE_RENAME withBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		XCTAssertTrue(event & DISPATCH_VNODE_RENAME);
		[expectation fulfill];
	}]);
	
	XCTAssertTrue(self.watcher.isActive);
	
	// Trigger rename event
	NSString *newPath = [self.tempDirectory stringByAppendingPathComponent:@"renamed.txt"];
	[self.fileManager moveItemAtPath:self.testFilePath toPath:newPath error:nil];
	
	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	
	// The watcher should have stopped automatically.
	XCTestExpectation *stopExpectation = [self expectationWithDescription:@"Watcher stopped expectation"];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		XCTAssertFalse(self.watcher.isActive, "Watcher should automatically stop after the path is renamed.");
		[stopExpectation fulfill];
	});
	
	[self waitForExpectations:@[stopExpectation] timeout:1.0];
}

- (void)testWatchPath_WithoutInitialPath {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Directory watcher callback"];
	self.watcher = [[BEPathWatcher alloc] initWithBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		XCTAssertTrue(event & DISPATCH_VNODE_WRITE);
		[expectation fulfill];
	}];
	
	XCTAssertNil(self.watcher.path, @"Path not initialized");
	XCTAssertNotNil(self.watcher.eventHandler, @"eventHandler should filled in");
	
	XCTAssertTrue([self.watcher watchPath:self.testFilePath], @"Should be watching with an event handler and path");
	
	// Trigger a write event
	[@"some new data" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	[self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testWatchWithTargetSelector {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Target-selector callback on write (0 args)"];
	MockTarget *target = [[MockTarget alloc] init];
	target.expectation = expectation;
	
	self.watcher = [[BEPathWatcher alloc] initWithPath:self.testFilePath];
	
	XCTAssertEqualObjects(self.watcher.path, self.testFilePath, @"Path not initialized");
	
	XCTAssertTrue([self.watcher watchWithTarget:target selector:@selector(pathDidChange)], @"Should be watching with an event handler and path");
	
	XCTAssertEqualObjects(self.watcher.target, target, @"Target should be set and not be nil");
	XCTAssertTrue(self.watcher.selector == @selector(pathDidChange), @"Selector should be set and not be nil");
	
	// Trigger a write event
	[@"some new data" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	[self waitForExpectations:@[expectation] timeout:1.0];
}


- (void)testWatchWithEventMaskTargetSelector {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Target-selector callback on write (0 args)"];
	MockTarget *target = [[MockTarget alloc] init];
	target.expectation = expectation;
	
	self.watcher = [[BEPathWatcher alloc] initWithPath:self.testFilePath];
	
	XCTAssertEqualObjects(self.watcher.path, self.testFilePath, @"Path not initialized");
	
	XCTAssertTrue([self.watcher watchWithEventMask:DISPATCH_VNODE_WRITE target:target selector:@selector(pathDidChange)], @"Should be watching with an event handler and path");
	
	XCTAssertEqualObjects(self.watcher.target, target, @"Target should be set and not be nil");
	XCTAssertTrue(self.watcher.selector == @selector(pathDidChange), @"Selector should be set and not be nil");
	XCTAssertEqual(self.watcher.eventMask, DISPATCH_VNODE_WRITE, @"Selector should be set and not be nil");
	
	// Trigger a write event
	[@"some new data" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	[self waitForExpectations:@[expectation] timeout:1.0];
}

#pragma mark - Protocol Hook Test

- (void)testProtocolHookIsCalledOnConformingSubclass {
	XCTestExpectation *hookExpectation = [self expectationWithDescription:@"Protocol hook was called"];
	XCTestExpectation *blockExpectation = [self expectationWithDescription:@"Public block was called"];

	ConformingSubclassWatcher *subclassedWatcher = [[ConformingSubclassWatcher alloc] init];
	subclassedWatcher.hookExpectation = hookExpectation;
	self.watcher = subclassedWatcher;

	[self.watcher watchPath:self.testFilePath withBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		// We check here that the hook has already been called
		XCTAssertTrue(((ConformingSubclassWatcher *)watcher).hookWasCalled, "Protocol hook should be called before the public block.");
		[blockExpectation fulfill];
	}];

	// Trigger an event
	[@"data for subclass test" writeToFile:self.testFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

	[self waitForExpectations:@[hookExpectation, blockExpectation] timeout:2.0];
	XCTAssertTrue(subclassedWatcher.hookWasCalled);
}

#pragma mark - Edge Case Tests

- (void)testStartMonitoring_EventMaskZeroFails {
	self.watcher = [[BEPathWatcher alloc] initWithPath:self.testFilePath];
	XCTAssertFalse(self.watcher.isActive);
	self.watcher.eventHandler = ^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
	};
	self.watcher.eventMask = 0;
	XCTAssertFalse(self.watcher.isActive);
	
	BOOL success = [self.watcher startMonitoring];
	XCTAssertFalse(success, "startMonitoring should fail for a zero Event Mask.");
}


- (void)testWatchingADirectory {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Directory watcher callback"];
	self.watcher = [[BEPathWatcher alloc] init];
	
	// Watch the directory itself
	[self.watcher watchPath:self.tempDirectory withBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
		// Creating a file in the directory triggers a WRITE event on the directory
		XCTAssertTrue(event & DISPATCH_VNODE_WRITE);
		[expectation fulfill];
	}];
	
	XCTAssertTrue(self.watcher.isActive);
	
	// Create a new file in the directory to trigger the event
	NSString *newFileInDir = [self.tempDirectory stringByAppendingPathComponent:@"anotherfile.txt"];
	[@"hello" writeToFile:newFileInDir atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	[self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testWeakTargetDeallocation {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Event triggered"];
	expectation.inverted = YES;
	
	__weak MockTarget *weakTarget;

	@autoreleasepool {
		MockTarget *strongTarget = [[MockTarget alloc] init];
		weakTarget = strongTarget;
		strongTarget.expectation = expectation; // This will never be fulfilled
		
		self.watcher = [[BEPathWatcher alloc] init];
		[self.watcher watchPath:self.testFilePath target:strongTarget selector:@selector(pathDidChange:withFlags:)];
		
		// Target is deallocated here as it goes out of scope
	}
	
	XCTAssertNil(weakTarget, "Target should have been deallocated.");
	
	// Trigger an event. The app should not crash.
	[@"content after target dealloc" writeToFile:self.testFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	// We expect the expectation NOT to be fulfilled. We'll use an inverted expectation.
	// However, a simpler way is just to wait for a short period and ensure no crash occurs.
	// This isn't a perfect test, but it's a pragmatic way to check for crashes on weak delegate patterns.
	XCTestExpectation *delay = [self expectationWithDescription:@"Wait for event to process"];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[delay fulfill];
	});
	[self waitForExpectations:@[delay, expectation] timeout:1.0];
	
	// If we reach here without crashing, the test is considered passed.
}


- (void)testWeakWatcherDeallocation {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Event triggered"];
	expectation.inverted = YES;
	
	NSString *newPath = [self.tempDirectory stringByAppendingPathComponent:@"newfile.txt"];
	[@"new" writeToFile:newPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	__weak BEPathWatcher *weakWatcher;

	@autoreleasepool {
		__strong BEPathWatcher *strongWatcher = [[BEPathWatcher alloc] init];
		weakWatcher = strongWatcher;
		
		[strongWatcher watchPath:newPath withBlock:^(BEPathWatcher * _Nonnull watcher, unsigned long event) {
			XCTAssertTrue(event & DISPATCH_VNODE_WRITE);
			[expectation fulfill];
		}];
		
		// Watcher is deallocated here as it goes out of scope
	}
	
	//[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	
	XCTAssertNil(weakWatcher, "Watcher should have been deallocated.");
	
	// Trigger an event. The app should not crash.
	[@"content after target dealloc" writeToFile:newPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	// We expect the expectation NOT to be fulfilled. We'll use an inverted expectation.
	// However, a simpler way is just to wait for a short period and ensure no crash occurs.
	// This isn't a perfect test, but it's a pragmatic way to check for crashes on weak delegate patterns.
	XCTestExpectation *delay = [self expectationWithDescription:@"Wait for event to process"];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[delay fulfill];
	});
	[self waitForExpectations:@[delay, expectation] timeout:1.0];
	
	// If we reach here without crashing, the test is considered passed.
}

@end
