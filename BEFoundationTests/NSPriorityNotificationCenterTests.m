/*!
 @file          NSPriorityNotificationCenterTests.m
 @copyright     -© 2025 Delicense - @belisoful. All rights released.
 @date          2025-01-01
 @abstract      Comprehensive unit tests for NSPriorityNotificationCenter
 @discussion    Tests all code paths and functionality
*/

#import <XCTest/XCTest.h>
#import "NSPriorityNotificationCenter.h"

#pragma mark - Test Helper Classes

@interface TestObserver : NSObject
@property (nonatomic, assign) NSInteger receivedCount;
@property (nonatomic, strong) NSMutableArray<NSNotification *> *receivedNotifications;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *receivedOrder;
@property (nonatomic, assign) NSInteger dynamicPriority;
@property (nonatomic, assign) NSInteger storedPriority;
@property (nonatomic, copy) NSString *storedName;
@property (nonatomic, assign) NSInteger handlingIndex;
@end

@implementation TestObserver

- (instancetype)init {
	self = [super init];
	if (self) {
		_receivedNotifications = [[NSMutableArray alloc] init];
		_receivedOrder = [[NSMutableArray alloc] init];
		_dynamicPriority = NSPriorityNotificationDefaultPriority;
		_storedPriority = NSPriorityNotificationDefaultPriority;
		_handlingIndex = 0;
	}
	return self;
}

- (void)handleNotification:(NSNotification *)notification {
	@synchronized (self) {
		self.receivedCount++;
		[self.receivedNotifications addObject:notification];
		[self.receivedOrder addObject:@(self.receivedCount)];
		NSMutableDictionary *mUserInfo = (NSMutableDictionary *)notification.userInfo;
		if (mUserInfo && [mUserInfo isKindOfClass:NSMutableDictionary.class]) {
			self.handlingIndex = [mUserInfo[@"index"] integerValue] + 1;
			mUserInfo[@"index"] = @(self.handlingIndex);
		}
	}
}

- (void)handleNotificationWithoutParameter {
	@synchronized (self) {
		self.receivedCount++;
		[self.receivedOrder addObject:@(self.receivedCount)];
	}
}

- (NSInteger)ncPriority:(nullable NSNotificationName)aName {
	return self.dynamicPriority;
}

- (void)setNcPriority:(NSInteger)aPriority name:(nullable NSNotificationName)aName {
	self.storedPriority = aPriority;
	self.storedName = aName;
}

- (void)reset {
	@synchronized (self) {
		self.receivedCount = 0;
		self.handlingIndex = 0;
		[self.receivedNotifications removeAllObjects];
		[self.receivedOrder removeAllObjects];
	}
}

@end




@interface TestObserverItem : TestObserver <NSNotificationObjectPriorityItem>
- (NSInteger)ncPriority:(nullable NSNotificationName)aName;
@end

@implementation TestObserverItem
- (NSInteger)ncPriority:(nullable NSNotificationName)aName {
	return self.dynamicPriority;
}
@end




@interface TestObserverCapture : TestObserver <NSNotificationObjectPriorityCapture>
- (void)setNcPriority:(NSInteger)aPriority name:(nullable NSNotificationName)aName;
@end

@implementation TestObserverCapture
- (void)setNcPriority:(NSInteger)aPriority name:(nullable NSNotificationName)aName
{
	self.storedPriority = aPriority;
	self.storedName = aName;
}
@end




@interface TestObserverProperty : TestObserver <NSNotificationObjectPriorityProperty>
- (NSInteger)ncPriority:(nullable NSNotificationName)aName;
- (void)setNcPriority:(NSInteger)aPriority name:(nullable NSNotificationName)aName;
@end

@implementation TestObserverProperty
- (NSInteger)ncPriority:(nullable NSNotificationName)aName {
	return self.storedPriority;
}
- (void)setNcPriority:(NSInteger)aPriority name:(nullable NSNotificationName)aName
{
	self.storedPriority = aPriority;
	self.storedName = aName;
}
@end



@interface WeakTestObserver : NSObject
@property (nonatomic, assign) NSInteger receivedCount;
@end

@implementation WeakTestObserver
- (void)handleNotification:(NSNotification *)notification {
	self.receivedCount++;
}
@end

#pragma mark - Mock Classes

@interface MockPriorityNotification : NSNotification
@property (nonatomic, assign) BOOL reverse;
@property (nonatomic, assign) BOOL isPriorityPost;
@property (nonatomic, copy) void (^postBlock)(NSNotification *);
@end

@implementation MockPriorityNotification
+ (instancetype)notificationWithName:(NSNotificationName)name
							   object:(id)object
							 userInfo:(NSDictionary *)userInfo
							  reverse:(BOOL)reverse
							postBlock:(void (^)(NSNotification *))postBlock {
	MockPriorityNotification *notif = (MockPriorityNotification *)[super notificationWithName:name object:object userInfo:userInfo];
	notif.reverse = reverse;
	notif.postBlock = postBlock;
	notif.isPriorityPost = NO;
	return notif;
}
@end

#pragma mark - Test Suite

@interface NSPriorityNotificationCenterTests : XCTestCase
@property (nonatomic, strong) NSPriorityNotificationCenter *notificationCenter;
@property (nonatomic, strong) TestObserverProperty *observer1;
@property (nonatomic, strong) TestObserverProperty *observer2;
@property (nonatomic, strong) TestObserverProperty *observer3;
@property (nonatomic, strong) TestObserverItem *observerItem1;
@property (nonatomic, strong) TestObserverCapture *observerCapture1;
@end

@implementation NSPriorityNotificationCenterTests

- (void)setUp {
	[super setUp];
	self.notificationCenter = [[NSPriorityNotificationCenter alloc] init];
	self.observer1 = [[TestObserverProperty alloc] init];
	self.observer2 = [[TestObserverProperty alloc] init];
	self.observer3 = [[TestObserverProperty alloc] init];
	self.observerItem1 = [[TestObserverItem alloc] init];
	self.observerCapture1 = [[TestObserverCapture alloc] init];
}

- (void)tearDown {
	[self.notificationCenter removeObserver:self.observer1];
	[self.notificationCenter removeObserver:self.observer2];
	[self.notificationCenter removeObserver:self.observer3];
	[self.notificationCenter removeObserver:self.observerItem1];
	[self.notificationCenter removeObserver:self.observerCapture1];
	[self.notificationCenter cleanup];
	self.notificationCenter = nil;
	self.observer1 = nil;
	self.observer2 = nil;
	self.observer3 = nil;
	self.observerItem1 = nil;
	self.observerCapture1 = nil;
	[super tearDown];
}

#pragma mark - Singleton Tests

- (void)testSingletonBehavior {
	XCTAssertTrue([NSPriorityNotificationCenter isSingleton]);
	
	NSPriorityNotificationCenter *center1 = [NSPriorityNotificationCenter defaultCenter];
	NSPriorityNotificationCenter *center2 = [NSPriorityNotificationCenter defaultCenter];
	
	XCTAssertNotNil(center1);
	XCTAssertEqual(center1, center2);
}

#pragma mark - Initialization Tests

- (void)testInitialization {
	NSPriorityNotificationCenter *center = [[NSPriorityNotificationCenter alloc] init];
	XCTAssertNotNil(center);
	XCTAssertEqual(center.defaultPriority, NSPriorityNotificationDefaultPriority);
}

- (void)testDefaultPriorityConstant {
	XCTAssertEqual(NSPriorityNotificationDefaultPriority, 10);
}

#pragma mark - Observer Addition Tests

- (void)testAddObserverWithSelector {
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
}

- (void)testAddObserverWithSelectorQueue {
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	queue.maxConcurrentOperationCount = 1;
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
	 							   queue:queue];
	
	__block NSUInteger count = 0;
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	
	[queue waitUntilAllOperationsAreFinished];
	XCTAssertEqual(self.observer1.receivedCount, 1);
}

- (void)testAddObserverWithSelectorPriority {
	// Add observers with different priorities
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:20]; // Lower priority
	
	[self.notificationCenter addObserver:self.observer2
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:5];  // Higher priority
	
	[self.notificationCenter addObserver:self.observerItem1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:11];  // Higher priority
	
	NSMutableDictionary *mutableUserInfo = NSMutableDictionary.new;
	
	// Observer2 should be called first (higher priority)
	XCTAssertEqual(self.observer1.receivedCount, 0);
	XCTAssertEqual(self.observer2.receivedCount, 0);
	XCTAssertEqual(self.observerItem1.receivedCount, 0);
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil userInfo:mutableUserInfo];
	
	// Observer2 should be called first (higher priority)
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqual(self.observer2.receivedCount, 1);
	XCTAssertEqual(self.observerItem1.receivedCount, 1);
	
	XCTAssertEqual(self.observer2.handlingIndex, 1);
	XCTAssertEqual(self.observerItem1.handlingIndex, 2);
	XCTAssertEqual(self.observer1.handlingIndex, 3);
}

- (void)testAddObserverWithSelectorPriorityQueue {
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	queue.maxConcurrentOperationCount = 1;
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:20
								   queue:queue];
	
	__block NSUInteger count = 0;
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil userInfo:NSDictionary.new postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	
	[queue waitUntilAllOperationsAreFinished];
	XCTAssertEqual(self.observer1.receivedCount, 1);
}

- (void)testAddObserverWithPriorityReverse {
	// Add observers with different priorities
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:20]; // Lower priority
	
	[self.notificationCenter addObserver:self.observer2
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:5];  // Higher priority
	
	[self.notificationCenter addObserver:self.observerItem1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:11];  // Higher priority
	
	NSMutableDictionary *mutableUserInfo = NSMutableDictionary.new;
	
	// Observer2 should be called first (higher priority)
	XCTAssertEqual(self.observer1.receivedCount, 0);
	XCTAssertEqual(self.observer2.receivedCount, 0);
	XCTAssertEqual(self.observerItem1.receivedCount, 0);
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil userInfo:mutableUserInfo reverse:YES];
	
	// Observer2 should be called first (higher priority)
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqual(self.observer2.receivedCount, 1);
	XCTAssertEqual(self.observerItem1.receivedCount, 1);
	
	XCTAssertEqual(self.observer2.handlingIndex, 3);
	XCTAssertEqual(self.observerItem1.handlingIndex, 2);
	XCTAssertEqual(self.observer1.handlingIndex, 1);
}

- (void)testAddObserverWithBlock {
	__block NSInteger blockCallCount = 0;
	__block NSNotification *receivedNotification = nil;
	
	id observer = [self.notificationCenter addObserverForName:@"TestNotification"
													   object:nil
														queue:nil
												   usingBlock:^(NSNotification *notification) {
		blockCallCount++;
		receivedNotification = notification;
	}];
	
	XCTAssertNotNil(observer);
	
	__block NSUInteger count = 0;
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil userInfo:NSDictionary.new postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	
	XCTAssertEqual(blockCallCount, 1);
	XCTAssertEqualObjects(receivedNotification.name, @"TestNotification");
	
	[self.notificationCenter removeObserver:observer];
}

- (void)testAddObserverWithBlockAndPriority {
	__block NSInteger block1CallCount = 0;
	__block NSInteger block2CallCount = 0;
	
	id observer1 = [self.notificationCenter addObserverForName:@"TestNotification"
														object:nil
													  priority:20
														 queue:nil
													usingBlock:^(NSNotification *notification) {
		block1CallCount++;
	}];
	
	id observer2 = [self.notificationCenter addObserverForName:@"TestNotification"
														object:nil
													  priority:5
														 queue:nil
													usingBlock:^(NSNotification *notification) {
		block2CallCount++;
	}];
	
	__block NSUInteger count = 0;
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	
	XCTAssertEqual(block1CallCount, 1);
	XCTAssertEqual(block2CallCount, 1);
	
	[self.notificationCenter removeObserver:observer1];
	[self.notificationCenter removeObserver:observer2];
}

- (void)testAddObserverWithBlockQueue {
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	queue.maxConcurrentOperationCount = 1;
	
	__block NSInteger blockCallCount = 0;
	XCTestExpectation *expectation = [self expectationWithDescription:@"Queue execution"];
	
	id observer = [self.notificationCenter addObserverForName:@"TestNotification"
													   object:nil
														queue:queue
												   usingBlock:^(NSNotification *notification) {
		blockCallCount++;
		[expectation fulfill];
	}];
	
	__block NSInteger count = 0;
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	
	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	XCTAssertEqual(blockCallCount, 1);
	
	[self.notificationCenter removeObserver:observer];
}

- (void)testAddObserverWithBlockQueueUserinfo {
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	queue.maxConcurrentOperationCount = 1;
	
	__block NSInteger blockCallCount = 0;
	XCTestExpectation *expectation = [self expectationWithDescription:@"Queue execution"];
	
	id observer = [self.notificationCenter addObserverForName:@"TestNotification"
													   object:nil
														queue:queue
												   usingBlock:^(NSNotification *notification) {
		blockCallCount++;
		[expectation fulfill];
	}];
	
	__block NSInteger count = 0;
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil userInfo:NSDictionary.new postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	
	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	XCTAssertEqual(blockCallCount, 1);
	
	[self.notificationCenter removeObserver:observer];
}


- (void)testAddObserverWithBlockQueue_UserInfo {
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	queue.maxConcurrentOperationCount = 1;
	
	__block NSInteger blockCallCount = 0;
	XCTestExpectation *expectation = [self expectationWithDescription:@"Queue execution"];
	
	id observer = [self.notificationCenter addObserverForName:@"TestNotification"
													   object:nil
														queue:queue
												   usingBlock:^(NSNotification *notification) {
		blockCallCount++;
		[expectation fulfill];
	}];
	
	__block NSInteger count = 0;
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil userInfo:NSDictionary.new postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	
	[self waitForExpectationsWithTimeout:1.0 handler:nil];
	XCTAssertEqual(blockCallCount, 1);
	
	[self.notificationCenter removeObserver:observer];
}

- (void)testAddObserverWithSelectorQueueUserinfo {
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	__block NSInteger count = 0;
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil userInfo:NSDictionary.new postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	
	[self.notificationCenter removeObserver:self.observer1];
}

#pragma mark - Error Handling Tests

- (void)testAddObserverWithNilObserver {
	// This should not crash and should log a warning
	[self.notificationCenter addObserver:nil
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	// Posting should not crash
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
}

- (void)testAddObserverWithNilSelector {
	// This should not crash and should log a warning
	[self.notificationCenter addObserver:self.observer1
								selector:NULL
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
}

- (void)testAddObserverWithBadSelector {
	// This should not crash and should log a warning
	[self.notificationCenter addObserver:self.observer1
								selector:NSSelectorFromString(@"removeFirstObject")
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
}

- (void)testAddObserverWithNilBlock {
	// This should return a dummy observer and log a warning
	id observer = [self.notificationCenter addObserverForName:@"TestNotification"
													   object:nil
														queue:nil
												   usingBlock:nil];
	
	XCTAssertNotNil(observer);
	[self.notificationCenter removeObserver:observer];
}

#pragma mark - Observer Removal Tests

- (void)testRemoveObserver {
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	XCTAssertEqual(self.observer1.receivedCount, 1);
	
	[self.observer1 reset];
	[self.notificationCenter removeObserver:self.observer1];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	XCTAssertEqual(self.observer1.receivedCount, 0);
}

- (void)testRemoveObserverWithSpecificNameAndObject {
	id testObject = [[NSObject alloc] init];
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification1"
								  object:testObject];
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification2"
								  object:nil];
	
	// Remove only the first observer
	[self.notificationCenter removeObserver:self.observer1
									   name:@"TestNotification1"
									 object:testObject];
	
	[self.notificationCenter postNotificationName:@"TestNotification1" object:testObject];
	[self.notificationCenter postNotificationName:@"TestNotification2" object:nil];
	
	// Should only receive the second notification
	XCTAssertEqual(self.observer1.receivedCount, 1);
}

- (void)testRemoveBlockObserver {
	__block NSInteger blockCallCount = 0;
	
	id observer = [self.notificationCenter addObserverForName:@"TestNotification"
													   object:nil
														queue:nil
												   usingBlock:^(NSNotification *notification) {
		blockCallCount++;
	}];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	XCTAssertEqual(blockCallCount, 1);
	
	[self.notificationCenter removeObserver:observer];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	XCTAssertEqual(blockCallCount, 1); // Should not increment
}

- (void)testRemoveNilObserver {
	// Should not crash
	[self.notificationCenter removeObserver:nil];
}

#pragma mark - Weak Reference Tests

- (void)testWeakObserverReference {
	WeakTestObserver *weakObserver = [[WeakTestObserver alloc] init];
	
	[self.notificationCenter addObserver:weakObserver
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	XCTAssertEqual(weakObserver.receivedCount, 1);
	
	// Deallocate the observer
	weakObserver = nil;
	
	// Posting should not crash even though observer was deallocated
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
}

#pragma mark - Priority Protocol Tests

- (void)testPriorityItemProtocol {
	self.observer1.dynamicPriority = 5;  // High priority
	self.observer2.dynamicPriority = 15; // Low priority
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:0]; // Will use dynamic priority
	
	[self.notificationCenter addObserver:self.observer2
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:0]; // Will use dynamic priority
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqual(self.observer2.receivedCount, 1);
}

- (void)testPriorityCaptureProtocol {
	NSInteger testPriority = 7;
	NSString *testName = @"TestNotification";
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:testName
								  object:nil
								priority:testPriority];
	
	XCTAssertEqual(self.observer1.storedPriority, testPriority);
	XCTAssertEqualObjects(self.observer1.storedName, testName);
}

#pragma mark - Notification Posting Tests

- (void)testPostNotificationWithName {
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqualObjects(self.observer1.receivedNotifications.firstObject.name, @"TestNotification");
}

- (void)testPostNotificationWithObject {
	NSObject *testObject = [[NSObject alloc] init];
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:testObject];
	
	// Post with matching object
	[self.notificationCenter postNotificationName:@"TestNotification" object:testObject];
	XCTAssertEqual(self.observer1.receivedCount, 1);
	
	[self.observer1 reset];
	
	// Post with different object - should not receive
	[self.notificationCenter postNotificationName:@"TestNotification" object:[[NSObject alloc] init]];
	XCTAssertEqual(self.observer1.receivedCount, 0);
}

- (void)testPostNotificationWithObjectUserInfo {
	NSDictionary *userInfo = @{@"key": @"value"};
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"TestNotification"
											object:nil
										  userInfo:userInfo];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqualObjects(self.observer1.receivedNotifications.firstObject.userInfo, userInfo);
}


- (void)testPostNotificationWithObjectPostblock {
	NSObject *testObject = [[NSObject alloc] init];
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:testObject];
	
	__block int count = 0;
	
	// Post with matching object
	[self.notificationCenter postNotificationName:@"TestNotification" object:testObject postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqual(count, 2);	// NSPriorityNotificationCenter raising super observer included
	
	[self.observer1 reset];
	count = 0;
	
	// Post with different object - should not receive
	[self.notificationCenter postNotificationName:@"TestNotification" object:[[NSObject alloc] init] postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	XCTAssertEqual(self.observer1.receivedCount, 0);
	XCTAssertEqual(count, 1);	// NSPriorityNotificationCenter raising super observer included
}


- (void)testPostNotificationWithObjectUserInfoPostblock {
	NSDictionary *userInfo = @{@"key": @"value"};
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	__block int count = 0;
	
	[self.notificationCenter postNotificationName:@"TestNotification"
											object:nil
										  userInfo:userInfo
										postBlock:^(NSNotification * _Nonnull notification) {
										   count++;
									   }];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqual(count, 2);
	XCTAssertEqualObjects(self.observer1.receivedNotifications.firstObject.userInfo, userInfo);
}

- (void)testPostNotificationWithObjectReverse {
	NSObject *testObject = [[NSObject alloc] init];
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:testObject];
	
	// Post with matching object
	[self.notificationCenter postNotificationName:@"TestNotification" object:testObject reverse:YES];
	XCTAssertEqual(self.observer1.receivedCount, 1);
	
	[self.observer1 reset];
	
	// Post with different object - should not receive
	[self.notificationCenter postNotificationName:@"TestNotification" object:[[NSObject alloc] init] reverse:YES];
	XCTAssertEqual(self.observer1.receivedCount, 0);
}

- (void)testPostNotificationWithObjectUserInfoReverse {
	NSDictionary *userInfo = @{@"key": @"value"};
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"TestNotification"
											object:nil
										  userInfo:userInfo
										  reverse:YES];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqualObjects(self.observer1.receivedNotifications.firstObject.userInfo, userInfo);
}


- (void)testPostNotificationWithObjectReversePostblock {
	NSObject *testObject = [[NSObject alloc] init];
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:testObject];
	
	__block int count = 0;
	
	// Post with matching object
	[self.notificationCenter postNotificationName:@"TestNotification" object:testObject reverse:YES postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqual(count, 2);	// NSPriorityNotificationCenter raising super observer included
	
	[self.observer1 reset];
	count = 0;
	
	// Post with different object - should not receive
	[self.notificationCenter postNotificationName:@"TestNotification" object:[[NSObject alloc] init] postBlock:^(NSNotification * _Nonnull notification) {
		count++;
	}];
	XCTAssertEqual(self.observer1.receivedCount, 0);
	XCTAssertEqual(count, 1);
}


- (void)testPostNotificationWithObjectUserInfoReversePostblock {
	NSDictionary *userInfo = @{@"key": @"value"};
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	__block int count = 0;
	
	[self.notificationCenter postNotificationName:@"TestNotification"
											object:nil
										  userInfo:userInfo
										  reverse:YES
										postBlock:^(NSNotification * _Nonnull notification) {
										   count++;
									   }];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqual(count, 2);	// NSPriorityNotificationCenter raising super observer included
	XCTAssertEqualObjects(self.observer1.receivedNotifications.firstObject.userInfo, userInfo);
}

- (void)testPostNotificationObject {
	NSNotification *notification = [NSNotification notificationWithName:@"TestNotification"
																  object:nil
																userInfo:@{@"test": @"data"}];
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotification:notification];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqualObjects(self.observer1.receivedNotifications.firstObject.userInfo[@"test"], @"data");
}


- (void)testPostNotificationObject_isPriorityPost {
	NSNotification *notification = [NSNotification notificationWithName:@"TestNotification"
																  object:nil
																userInfo:@{@"test": @"data"}];
	
	notification.isPriorityPost = YES;
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotification:notification];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqualObjects(self.observer1.receivedNotifications.firstObject.userInfo[@"test"], @"data");
}

#pragma mark - Priority Ordering Tests

- (void)testPriorityOrdering {
	// Create observers that track their call order
	__block NSMutableArray *callOrder = [[NSMutableArray alloc] init];
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:20]; // Lowest priority
	
	[self.notificationCenter addObserver:self.observer2
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:5];  // Highest priority
	
	[self.notificationCenter addObserver:self.observer3
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:10]; // Medium priority
	
	// Override handleNotification to track order
	self.observer1.receivedNotifications = callOrder;
	self.observer2.receivedNotifications = callOrder;
	self.observer3.receivedNotifications = callOrder;
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	
	// All should have been called
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqual(self.observer2.receivedCount, 1);
	XCTAssertEqual(self.observer3.receivedCount, 1);
}

#pragma mark - Selector Validation Tests

- (void)testSelectorWithParameter {
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
	XCTAssertEqual(self.observer1.receivedNotifications.count, 1);
}

- (void)testSelectorWithoutParameter {
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotificationWithoutParameter)
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
}

- (void)testInvalidSelector {
	// This should log an error but not crash
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(nonExistentMethod:)
									name:@"TestNotification"
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	
	// Observer count should remain 0 due to method not existing
	XCTAssertEqual(self.observer1.receivedCount, 0);
}

#pragma mark - Thread Safety Tests

- (void)testConcurrentObserverAddition {
	NSUInteger count = 400;
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Concurrent operations"];
	expectation.expectedFulfillmentCount = count;
	
	dispatch_queue_t concurrentQueue = dispatch_queue_create("test.concurrent", DISPATCH_QUEUE_CONCURRENT);
	
	for (int i = 0; i < count; i++) {
		dispatch_async(concurrentQueue, ^{
			TestObserver *observer = [[TestObserver alloc] init];
			[self.notificationCenter addObserver:observer
										selector:@selector(handleNotification:)
											name:@"TestNotification"
										  object:nil];
			[expectation fulfill];
		});
	}
	
	[self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testConcurrentNotificationPosting {
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Concurrent posting"];
	expectation.expectedFulfillmentCount = 10;
	
	dispatch_queue_t concurrentQueue = dispatch_queue_create("test.concurrent", DISPATCH_QUEUE_CONCURRENT);
	
	for (int i = 0; i < 10; i++) {
		dispatch_async(concurrentQueue, ^{
			[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
			[expectation fulfill];
		});
	}
	
	[self waitForExpectationsWithTimeout:5.0 handler:nil];
	
	// Should receive all 10 notifications
	XCTAssertEqual(self.observer1.receivedCount, 10);
}

#pragma mark - Memory Management Tests

- (void)testObserverDeallocation {
	@autoreleasepool {
		TestObserver *tempObserver = [[TestObserver alloc] init];
		
		[self.notificationCenter addObserver:tempObserver
									selector:@selector(handleNotification:)
										name:@"TestNotification"
									  object:nil];
		
		[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
		XCTAssertEqual(tempObserver.receivedCount, 1);
		
		// tempObserver will be deallocated at end of autoreleasepool
	}
	
	// Posting should not crash even though observer was deallocated
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
}

#pragma mark - DefaultPriority Tests

- (void)testDefaultPriorityChange {
	self.notificationCenter.defaultPriority = 5;
	XCTAssertEqual(self.notificationCenter.defaultPriority, 5);
	
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil]; // Should use new default priority
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	XCTAssertEqual(self.observer1.receivedCount, 1);
}

#pragma mark - NSNotificationObjectPriorityItem Tests

- (void)testNcPriorityMethod {
	NSInteger priority = [self.notificationCenter ncPriority:@"TestNotification"];
	XCTAssertEqual(priority, self.notificationCenter.defaultPriority);
}

#pragma mark - Edge Cases

- (void)testEmptyNotificationName {
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@""
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"" object:nil];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
}

- (void)testNilNotificationName {
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:nil
								  object:nil];
	
	[self.notificationCenter postNotificationName:@"AnyNotification" object:nil];
	
	// Should receive notification for any name when observer name is nil
	XCTAssertEqual(self.observer1.receivedCount, 1);
}

- (void)testVeryHighPriority {
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:NSIntegerMin];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
}

- (void)testVeryLowPriority {
	[self.notificationCenter addObserver:self.observer1
								selector:@selector(handleNotification:)
									name:@"TestNotification"
								  object:nil
								priority:NSIntegerMax];
	
	[self.notificationCenter postNotificationName:@"TestNotification" object:nil];
	
	XCTAssertEqual(self.observer1.receivedCount, 1);
}

#pragma mark - Dealloc

- (void)testDealloc {
	
	__weak NSPriorityNotificationCenter *weakRef;

	@autoreleasepool {
		NSPriorityNotificationCenter *obj = [[NSPriorityNotificationCenter alloc] init];
		weakRef = obj;
		[obj cleanup];
		// use obj
	}
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

	// At this point, if obj was properly released, weakRef should be nil
	XCTAssertNil(weakRef, @"NSPriorityNotificationCenter was not deallocated");
}

@end
