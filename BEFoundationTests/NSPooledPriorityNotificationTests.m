/*!
@file NSPooledPriorityNotificationTests.m
@copyright Test file for NSPooledPriorityNotification
@date 2025-01-01
@abstract Comprehensive unit tests for NSPooledPriorityNotification class
*/

#import <XCTest/XCTest.h>
#import "NSPooledPriorityNotification.h"
#import <Foundation/Foundation.h>

@interface NSPooledPriorityNotificationTests : XCTestCase
@property (nonatomic, strong) NSString *testName;
@property (nonatomic, strong) NSObject *testObject;
@property (nonatomic, strong) NSDictionary *testUserInfo;
@end

@implementation NSPooledPriorityNotificationTests

#pragma mark - Setup and Teardown

- (void)setUp {
	[super setUp];
	self.testName = @"TestNotificationName";
	self.testObject = [[NSObject alloc] init];
	self.testUserInfo = @{@"key1": @"value1", @"key2": @42};
}

- (void)tearDown {
	self.testName = nil;
	self.testObject = nil;
	self.testUserInfo = nil;
	[super tearDown];
}

#pragma mark - Factory Method Tests

- (void)testNewTempNotificationWithValidParameters {
	// Test creating notification with all valid parameters
	NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:self.testName
																									 object:self.testObject
																								   userInfo:self.testUserInfo
																									reverse:YES];
	
	XCTAssertNotNil(notification, @"Notification should not be nil");
	XCTAssertEqualObjects(notification.name, self.testName, @"Name should match");
	XCTAssertEqualObjects(notification.object, self.testObject, @"Object should match");
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo, @"UserInfo should match");
	XCTAssertTrue(notification.reverse, @"Reverse should be YES");
	
	[notification recycle];
}

- (void)testNewTempNotificationWithNilName {
	// Test creating notification with nil name
	NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:nil
																									 object:self.testObject
																								   userInfo:self.testUserInfo
																									reverse:NO];
	
	XCTAssertNotNil(notification, @"Notification should not be nil even with nil name");
	XCTAssertNil(notification.name, @"Name should be nil");
	XCTAssertEqualObjects(notification.object, self.testObject, @"Object should match");
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo, @"UserInfo should match");
	XCTAssertFalse(notification.reverse, @"Reverse should be NO");
	
	[notification recycle];
}

- (void)testNewTempNotificationWithNilObject {
	// Test creating notification with nil object
	NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:self.testName
																									 object:nil
																								   userInfo:self.testUserInfo
																									reverse:YES];
	
	XCTAssertNotNil(notification, @"Notification should not be nil");
	XCTAssertEqualObjects(notification.name, self.testName, @"Name should match");
	XCTAssertNil(notification.object, @"Object should be nil");
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo, @"UserInfo should match");
	XCTAssertTrue(notification.reverse, @"Reverse should be YES");
	
	[notification recycle];
}

- (void)testNewTempNotificationWithNilUserInfo {
	// Test creating notification with nil userInfo
	NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:self.testName
																									 object:self.testObject
																								   userInfo:nil
																									reverse:NO];
	
	XCTAssertNotNil(notification, @"Notification should not be nil");
	XCTAssertEqualObjects(notification.name, self.testName, @"Name should match");
	XCTAssertEqualObjects(notification.object, self.testObject, @"Object should match");
	XCTAssertNil(notification.userInfo, @"UserInfo should be nil");
	XCTAssertFalse(notification.reverse, @"Reverse should be NO");
	
	[notification recycle];
}

- (void)testNewTempNotificationWithAllNilParameters {
	// Test creating notification with all nil parameters
	NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:nil
																									 object:nil
																								   userInfo:nil
																									reverse:YES];
	
	XCTAssertNotNil(notification, @"Notification should not be nil even with all nil parameters");
	XCTAssertNil(notification.name, @"Name should be nil");
	XCTAssertNil(notification.object, @"Object should be nil");
	XCTAssertNil(notification.userInfo, @"UserInfo should be nil");
	XCTAssertTrue(notification.reverse, @"Reverse should be YES");
	
	[notification recycle];
}

- (void)testNewTempNotificationWithEmptyStrings {
	// Test creating notification with empty strings
	NSString *emptyName = @"";
	NSDictionary *emptyUserInfo = @{};
	
	NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:emptyName
																									 object:self.testObject
																								   userInfo:emptyUserInfo
																									reverse:NO];
	
	XCTAssertNotNil(notification, @"Notification should not be nil");
	XCTAssertEqualObjects(notification.name, emptyName, @"Name should be empty string");
	XCTAssertEqualObjects(notification.object, self.testObject, @"Object should match");
	XCTAssertEqualObjects(notification.userInfo, emptyUserInfo, @"UserInfo should be empty dictionary");
	XCTAssertFalse(notification.reverse, @"Reverse should be NO");
	
	[notification recycle];
}

#pragma mark - Pool Management Tests

- (void)testPoolingBehavior {
	
	[NSPooledPriorityNotification clearNotificationPool];
	
	// Test that recycled notifications are reused from the pool
	NSPooledPriorityNotification *notification1 = [NSPooledPriorityNotification newTempNotificationWithName:@"Test1"
																									  object:nil
																									userInfo:nil
																									 reverse:NO];
	
	// Store the pointer to verify reuse
	NSPooledPriorityNotification *originalPointer = notification1;
	
	// Recycle the notification
	[notification1 recycle];
	
	// Create a new notification - should reuse the recycled one
	NSPooledPriorityNotification *notification2 = [NSPooledPriorityNotification newTempNotificationWithName:@"Test2"
																									  object:self.testObject
																									userInfo:self.testUserInfo
																									 reverse:YES];
	
	// Verify the same object was reused
	XCTAssertEqual(notification2, originalPointer, @"Should reuse recycled notification from pool");
	
	// Verify the new values are set correctly
	XCTAssertEqualObjects(notification2.name, @"Test2", @"Name should be updated");
	XCTAssertEqualObjects(notification2.object, self.testObject, @"Object should be updated");
	XCTAssertEqualObjects(notification2.userInfo, self.testUserInfo, @"UserInfo should be updated");
	XCTAssertTrue(notification2.reverse, @"Reverse should be updated");
	
	[notification2 recycle];
}

- (void)testMultipleNotificationsFromPool {
	// Test creating multiple notifications and recycling them
	NSMutableArray *notifications = [NSMutableArray array];
	
	// Create multiple notifications
	for (int i = 0; i < 5; i++) {
		NSString *name = [NSString stringWithFormat:@"Test%d", i];
		NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:name
																										 object:@(i)
																									   userInfo:@{@"index": @(i)}
																										reverse:(i % 2 == 0)];
		[notifications addObject:notification];
	}
	
	// Verify all notifications are created
	XCTAssertEqual(notifications.count, 5, @"Should create 5 notifications");
	
	// Recycle all notifications
	for (NSPooledPriorityNotification *notification in notifications) {
		[notification recycle];
	}
	
	// Create new notifications - should reuse some from pool
	NSMutableArray *newNotifications = [NSMutableArray array];
	for (int i = 0; i < 3; i++) {
		NSString *name = [NSString stringWithFormat:@"NewTest%d", i];
		NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:name
																										 object:@(i + 100)
																									   userInfo:@{@"newIndex": @(i)}
																										reverse:YES];
		[newNotifications addObject:notification];
	}
	
	XCTAssertEqual(newNotifications.count, 3, @"Should create 3 new notifications");
	
	// Clean up
	for (NSPooledPriorityNotification *notification in newNotifications) {
		[notification recycle];
	}
}

- (void)testPoolCountAndClear {
	
	[NSPooledPriorityNotification clearNotificationPool];
	XCTAssertEqual([NSPooledPriorityNotification unusedNotificationCount], 0);
	
	NSPooledPriorityNotification *notification1 = [NSPooledPriorityNotification newTempNotificationWithName:@"Test1"
																									  object:nil
																									userInfo:nil
																									 reverse:NO];
	XCTAssertEqual([NSPooledPriorityNotification unusedNotificationCount], 0);
	[notification1 recycle];
	XCTAssertEqual([NSPooledPriorityNotification unusedNotificationCount], 1);
	[NSPooledPriorityNotification clearNotificationPool];
	XCTAssertEqual([NSPooledPriorityNotification unusedNotificationCount], 0);
	
}

#pragma mark - Concurrency Tests

- (void)testConcurrentPoolAccess {
	// Test thread safety of pool access
	dispatch_group_t group = dispatch_group_create();
	NSMutableArray *allNotifications = [NSMutableArray array];
	NSLock *arrayLock = [[NSLock alloc] init];
	
	// Create notifications concurrently
	for (int i = 0; i < 10; i++) {
		dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSString *name = [NSString stringWithFormat:@"ConcurrentTest%d", i];
			NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:name
																											 object:@(i)
																										   userInfo:@{@"threadIndex": @(i)}
																											reverse:(i % 2 == 0)];
			
			[arrayLock lock];
			[allNotifications addObject:notification];
			[arrayLock unlock];
		});
	}
	
	// Wait for all notifications to be created
	dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
	
	XCTAssertEqual(allNotifications.count, 10, @"Should create 10 notifications concurrently");
	XCTAssertEqual(allNotifications.count, 10, @"Should create 10 notifications concurrently");
	
	// Recycle all notifications concurrently
	dispatch_group_t recycleGroup = dispatch_group_create();
	for (NSPooledPriorityNotification *notification in allNotifications) {
		dispatch_group_async(recycleGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[notification recycle];
		});
	}
	
	
	dispatch_group_wait(recycleGroup, DISPATCH_TIME_FOREVER);
}

#pragma mark - Description Tests

- (void)testDescriptionMethod {
	// Test the description method output
	NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:self.testName
																									 object:self.testObject
																								   userInfo:self.testUserInfo
																									reverse:YES];
	
	NSString *description = [notification description];
	
	XCTAssertNotNil(description, @"Description should not be nil");
	XCTAssertTrue([description containsString:self.testName], @"Description should contain notification name");
	XCTAssertTrue([description containsString:@"reverse:1"], @"Description should contain reverse value");
	
	// Note: The original code has a bug with dereferencing pointers (*name, *object, *userInfo)
	// This test assumes the description method works as intended
	
	[notification recycle];
}

- (void)testDescriptionWithNilValues {
	// Test description with nil values
	NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:nil
																									 object:nil
																								   userInfo:nil
																									reverse:NO];
	
	NSString *description = [notification description];
	
	XCTAssertNotNil(description, @"Description should not be nil even with nil values");
	XCTAssertTrue([description containsString:@"reverse:0"], @"Description should contain reverse value");
	
	[notification recycle];
}

#pragma mark - Memory Management Tests

- (void)testMemoryManagement {
	[NSPooledPriorityNotification clearNotificationPool];
	
	// Test that objects are properly retained and released
	@autoreleasepool {
		NSString *testName = [[NSString alloc] initWithFormat:@"TestName"];
		NSObject *testObject = [[NSObject alloc] init];
		NSDictionary *testUserInfo = @{@"test": @"value"};
		
		NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:testName
																										 object:testObject
																									   userInfo:testUserInfo
																										reverse:YES];
		
		XCTAssertNotNil(notification, @"Notification should be created");
		
		// Recycle the notification
		[notification recycle];
		
		
		// Objects should be released after recycling
	}
}

#pragma mark - Edge Cases

- (void)testLargeUserInfo {
	// Test with large userInfo dictionary
	NSMutableDictionary *largeUserInfo = [NSMutableDictionary dictionary];
	for (int i = 0; i < 1000; i++) {
		largeUserInfo[[NSString stringWithFormat:@"key%d", i]] = [NSString stringWithFormat:@"value%d", i];
	}
	
	NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:@"LargeTest"
																									 object:nil
																								   userInfo:largeUserInfo
																									reverse:NO];
	
	XCTAssertNotNil(notification, @"Notification should handle large userInfo");
	XCTAssertEqual(notification.userInfo.count, 1000, @"UserInfo should contain all entries");
	
	[notification recycle];
}

- (void)testComplexObjectTypes {
	// Test with complex object types
	NSArray *complexObject = @[@"string", @42, @{@"nested": @"dict"}, [NSDate date]];
	NSDictionary *complexUserInfo = @{
		@"array": @[@1, @2, @3],
		@"dict": @{@"inner": @"value"},
		@"date": [NSDate date],
		@"data": [@"test" dataUsingEncoding:NSUTF8StringEncoding]
	};
	
	NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:@"ComplexTest"
																									 object:complexObject
																								   userInfo:complexUserInfo
																									reverse:YES];
	
	XCTAssertNotNil(notification, @"Notification should handle complex objects");
	XCTAssertEqualObjects(notification.object, complexObject, @"Complex object should be preserved");
	XCTAssertEqualObjects(notification.userInfo, complexUserInfo, @"Complex userInfo should be preserved");
	
	[notification recycle];
}

#pragma mark - Performance Tests

- (void)testPerformanceOfPoolOperations {
	[NSPooledPriorityNotification clearNotificationPool];
	XCTAssertEqual([NSPooledPriorityNotification unusedNotificationCount], 0);
	// Test performance of creating and recycling notifications
	[self measureBlock:^{
		NSMutableArray *notifications = [NSMutableArray array];
		
		// Create 1000 notifications
		for (int i = 0; i < 1000; i++) {
			NSPooledPriorityNotification *notification = [NSPooledPriorityNotification newTempNotificationWithName:@"PerfTest"
																											 object:@(i)
																										   userInfo:@{@"index": @(i)}
																											reverse:(i % 2 == 0)];
			[notifications addObject:notification];
		}
		
		// Recycle all notifications
		for (NSPooledPriorityNotification *notification in notifications) {
			[notification recycle];
		}
	}];
	XCTAssertEqual([NSPooledPriorityNotification unusedNotificationCount], 1000);
	[NSPooledPriorityNotification clearNotificationPool];
	XCTAssertEqual([NSPooledPriorityNotification unusedNotificationCount], 0);
}

@end
