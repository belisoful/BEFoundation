/*!
 @file			NSPriorityNotificationTests.m
 @copyright		Unit tests for NSPriorityNotification and NSNotification (PriorityExtension)
 @date			2025-01-01
 @abstract		Comprehensive unit tests
 @discussion	Full coverage tests for NSPriorityNotification class and NSNotification category
*/

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "NSPriorityNotification.h"
#import "NSObject+GlobalRegistry.h"

@interface GlobalObjectToTest : NSObject <BERegistryProtocol>
@end

@implementation GlobalObjectToTest
@dynamic globalRegistryUUID;
@dynamic globalRegistryCount;
@end


@interface NSPriorityNotificationTests : XCTestCase
@property (nonatomic, strong) NSString *testNotificationName;
@property (nonatomic, strong) NSObject *testObject;
@property (nonatomic, strong) NSDictionary *testUserInfo;
@end

@implementation NSPriorityNotificationTests

- (void)setUp {
	[super setUp];
	self.testNotificationName = @"TestNotification";
	self.testObject = [[NSObject alloc] init];
	self.testUserInfo = @{@"key1": @"value1", @"key2": @42};
}

- (void)tearDown {
	self.testNotificationName = nil;
	self.testObject = nil;
	self.testUserInfo = nil;
	[super tearDown];
}

#pragma mark - NSPriorityNotification Class Method Tests

- (void)testNotificationWithNameObject {
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																				  object:self.testObject];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertNil(notification.userInfo);
	XCTAssertFalse(notification.reverse);
	XCTAssertNil(notification.postBlock);
}

- (void)testNotificationWithNameObjectUserInfo {
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:self.testUserInfo];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo);
	XCTAssertFalse(notification.reverse);
	XCTAssertNil(notification.postBlock);
}

- (void)testNotificationWithNameObjectPostBlock {
	__block BOOL blockCalled = NO;
	void (^testBlock)(NSNotification *) = ^(NSNotification *note) {
		blockCalled = YES;
	};
	
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																				  object:self.testObject
																			   postBlock:testBlock];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertNil(notification.userInfo);
	XCTAssertFalse(notification.reverse);
	XCTAssertNotNil(notification.postBlock);
	
	// Test the block works
	notification.postBlock(notification);
	XCTAssertTrue(blockCalled);
}

- (void)testNotificationWithNameObjectUserInfoPostBlock {
	__block NSNotification *capturedNotification = nil;
	void (^testBlock)(NSNotification *) = ^(NSNotification *note) {
		capturedNotification = note;
	};
	
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:self.testUserInfo
																			   postBlock:testBlock];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo);
	XCTAssertFalse(notification.reverse);
	XCTAssertNotNil(notification.postBlock);
	
	// Test the block works and captures the notification
	notification.postBlock(notification);
	XCTAssertEqualObjects(capturedNotification, notification);
}

- (void)testNotificationWithNameObjectReverse {
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																				  object:self.testObject
																				 reverse:YES];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertNil(notification.userInfo);
	XCTAssertTrue(notification.reverse);
	XCTAssertNil(notification.postBlock);
}

- (void)testNotificationWithNameObjectUserInfoReverse {
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:self.testUserInfo
																				 reverse:YES];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo);
	XCTAssertTrue(notification.reverse);
	XCTAssertNil(notification.postBlock);
}

- (void)testNotificationWithNameObjectReversePostBlock {
	__block BOOL blockCalled = NO;
	void (^testBlock)(NSNotification *) = ^(NSNotification *note) {
		blockCalled = YES;
	};
	
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																				  object:self.testObject
																				 reverse:YES
																			   postBlock:testBlock];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertNil(notification.userInfo);
	XCTAssertTrue(notification.reverse);
	XCTAssertNotNil(notification.postBlock);
	
	// Test the block works
	notification.postBlock(notification);
	XCTAssertTrue(blockCalled);
}

- (void)testNotificationWithNameObjectUserInfoReversePostBlock {
	__block NSNotification *capturedNotification = nil;
	void (^testBlock)(NSNotification *) = ^(NSNotification *note) {
		capturedNotification = note;
	};
	
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:self.testUserInfo
																				 reverse:YES
																			   postBlock:testBlock];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo);
	XCTAssertTrue(notification.reverse);
	XCTAssertNotNil(notification.postBlock);
	
	// Test the block works and captures the notification
	notification.postBlock(notification);
	XCTAssertEqualObjects(capturedNotification, notification);
}

- (void)testNotificationWithNilPostBlock {
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:self.testUserInfo
																				 reverse:NO
																			   postBlock:nil];
	
	XCTAssertNotNil(notification);
	XCTAssertNil(notification.postBlock);
}

#pragma mark - NSPriorityNotification Instance Method Tests

- (void)testInitWithNameObject {
	NSPriorityNotification *notification = [[NSPriorityNotification alloc] initWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:nil];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertNil(notification.userInfo);
	XCTAssertFalse(notification.reverse);
	XCTAssertNil(notification.postBlock);
}

- (void)testInitWithNameObjectUserInfo {
	NSPriorityNotification *notification = [[NSPriorityNotification alloc] initWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:self.testUserInfo];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo);
	XCTAssertFalse(notification.reverse);
	XCTAssertNil(notification.postBlock);
}

- (void)testInitWithNameObjectUserInfoReverse {
	NSPriorityNotification *notification = [[NSPriorityNotification alloc] initWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:self.testUserInfo
																				 reverse:YES];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo);
	XCTAssertTrue(notification.reverse);
	XCTAssertNil(notification.postBlock);
}

- (void)testInitWithNameObjectUserInfoPostBlock {
	__block BOOL blockCalled = NO;
	void (^testBlock)(NSNotification *) = ^(NSNotification *note) {
		blockCalled = YES;
	};
	
	NSPriorityNotification *notification = [[NSPriorityNotification alloc] initWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:self.testUserInfo
																			   postBlock:testBlock];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo);
	XCTAssertFalse(notification.reverse);
	XCTAssertNotNil(notification.postBlock);
	
	// Test the block works
	notification.postBlock(notification);
	XCTAssertTrue(blockCalled);
}

- (void)testInitWithNameObjectUserInfoReversePostBlock {
	__block NSNotification *capturedNotification = nil;
	void (^testBlock)(NSNotification *) = ^(NSNotification *note) {
		capturedNotification = note;
	};
	
	NSPriorityNotification *notification = [[NSPriorityNotification alloc] initWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:self.testUserInfo
																				 reverse:YES
																			   postBlock:testBlock];
	
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo);
	XCTAssertTrue(notification.reverse);
	XCTAssertNotNil(notification.postBlock);
	
	// Test the block works and captures the notification
	notification.postBlock(notification);
	XCTAssertEqualObjects(capturedNotification, notification);
}

- (void)testInitWithNilPostBlock {
	id nilBlock = nil;
	NSPriorityNotification *notification = [[NSPriorityNotification alloc] initWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:self.testUserInfo
																				 reverse:NO
																			   postBlock:nilBlock];
	
	XCTAssertNotNil(notification);
	XCTAssertNil(notification.postBlock);
}

#pragma mark - NSCoding Tests

- (void)testNSCoding_EncodingAndDecodingKeyed {
	NSPriorityNotification *originalNotification = [NSPriorityNotification notificationWithName:self.testNotificationName
																						  object:self.testObject
																						userInfo:self.testUserInfo
																						 reverse:YES];
	
	// Encode
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
	[archiver encodeObject:originalNotification forKey:@"notification"];
	[archiver finishEncoding];
	NSData *data = [archiver encodedData];
	
	XCTAssertNotNil(data);
	
	// Decode
	NSError *error = nil;
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
	XCTAssertNil(error);
	XCTAssertNotNil(unarchiver);
	XCTAssertTrue(unarchiver.requiresSecureCoding);
	
	unarchiver.requiresSecureCoding = NO;
	
	NSPriorityNotification *decodedNotification = [unarchiver decodeObjectForKey:@"notification"];
	[unarchiver finishDecoding];
	
	// Verify
	XCTAssertNotNil(decodedNotification);
	XCTAssertEqualObjects(decodedNotification.name, originalNotification.name);
	XCTAssertNil(decodedNotification.object, @"The object is does not conform to GlobalRegistryProtocol so should return nil");
	XCTAssertEqualObjects(decodedNotification.userInfo, originalNotification.userInfo);
	XCTAssertEqual(decodedNotification.reverse, originalNotification.reverse);
}

- (void)testNSCoding_EncodingAndDecodingKeyedWithReverseNo_GlobalObject
{
	@synchronized (NSObject.globalRegistry) {
		[NSObject.globalRegistry clearAllRegisteredObjects];
		GlobalObjectToTest *globalizedObject = GlobalObjectToTest.new;
		NSPriorityNotification *originalNotification = [NSPriorityNotification notificationWithName:self.testNotificationName
																							 object:globalizedObject
																						   userInfo:self.testUserInfo
																							reverse:NO];
		
		// Encode
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
		[archiver encodeObject:originalNotification forKey:@"notification"];
		[archiver finishEncoding];
		NSData *data = [archiver encodedData];
		
		XCTAssertNotNil(data);
		XCTAssertEqual(NSObject.globalRegistry.registeredObjectsCount, 1);
		
		// Decode
		NSError *error = nil;
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
		XCTAssertNil(error);
		
		unarchiver.requiresSecureCoding = NO;
		
		NSPriorityNotification *decodedNotification = [unarchiver decodeObjectForKey:@"notification"];
		[unarchiver finishDecoding];
		
		// Verify
		XCTAssertNotNil(decodedNotification);
		XCTAssertFalse(decodedNotification.reverse);
		XCTAssertEqual(decodedNotification.object, globalizedObject);
		[NSObject.globalRegistry clearAllRegisteredObjects];
	}
}



#pragma mark - NSSecureCoding Tests

- (void)testNSSecureCoding_EncodingAndDecodingKeyed {
	NSPriorityNotification *originalNotification = [NSPriorityNotification notificationWithName:self.testNotificationName
																						  object:self.testObject
																						userInfo:self.testUserInfo
																						 reverse:YES];
	
	// Encode
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
	[archiver encodeObject:originalNotification forKey:@"notification"];
	[archiver finishEncoding];
	NSData *data = [archiver encodedData];
	
	XCTAssertNotNil(data);
	
	// Decode
	NSError *error = nil;
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
	XCTAssertNil(error);
	XCTAssertNotNil(unarchiver);
	XCTAssertTrue(unarchiver.requiresSecureCoding);
	
	NSPriorityNotification *decodedNotification = [unarchiver decodeObjectOfClass:[NSPriorityNotification class]
																		   forKey:@"notification"];
	[unarchiver finishDecoding];
	
	// Verify
	XCTAssertNotNil(decodedNotification);
	XCTAssertEqualObjects(decodedNotification.name, originalNotification.name);
	XCTAssertNil(decodedNotification.object, @"The object is does not conform to GlobalRegistryProtocol so should return nil");
	XCTAssertEqualObjects(decodedNotification.userInfo, originalNotification.userInfo);
	XCTAssertEqual(decodedNotification.reverse, originalNotification.reverse);
}

- (void)testNSSecureCoding_EncodingAndDecodingKeyedWithReverseNo_GlobalObject
{
	@synchronized (NSObject.globalRegistry) {
		[NSObject.globalRegistry clearAllRegisteredObjects];
		GlobalObjectToTest *globalizedObject = GlobalObjectToTest.new;
		NSPriorityNotification *originalNotification = [NSPriorityNotification notificationWithName:self.testNotificationName
																							 object:globalizedObject
																						   userInfo:self.testUserInfo
																							reverse:NO];
		
		// Encode
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
		[archiver encodeObject:originalNotification forKey:@"notification"];
		[archiver finishEncoding];
		NSData *data = [archiver encodedData];
		
		XCTAssertNotNil(data);
		XCTAssertEqual(NSObject.globalRegistry.registeredObjectsCount, 1);
		
		// Decode
		NSError *error = nil;
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
		XCTAssertNil(error);
		
		NSPriorityNotification *decodedNotification = [unarchiver decodeObjectOfClass:[NSPriorityNotification class]
																			   forKey:@"notification"];
		[unarchiver finishDecoding];
		
		// Verify
		XCTAssertNotNil(decodedNotification);
		XCTAssertFalse(decodedNotification.reverse);
		XCTAssertEqual(decodedNotification.object, globalizedObject);
		[NSObject.globalRegistry clearAllRegisteredObjects];
	}
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

// Unit test that actually uses NSArchiver to test classForCoder
- (void)testBEMutableNumber_ClassForCoder_OldMacOS
{
	@synchronized (NSObject.globalRegistry) {
		[NSObject.globalRegistry clearAllRegisteredObjects];
		GlobalObjectToTest *globalizedObject = GlobalObjectToTest.new;
		NSPriorityNotification *originalNotification = [NSPriorityNotification notificationWithName:self.testNotificationName
																							 object:globalizedObject
																						   userInfo:self.testUserInfo
																							reverse:NO];
		
		// Test using NSArchiver (which uses classForCoder)
		NSData *archivedData = [NSArchiver archivedDataWithRootObject:originalNotification];
		XCTAssertNotNil(archivedData, @"Archiving with NSArchiver should succeed");
		
		// Unarchive using NSUnarchiver
		NSPriorityNotification *result = [NSUnarchiver unarchiveObjectWithData:archivedData];
		
		XCTAssertNotNil(result, @"Unarchiving should succeed");
		XCTAssertTrue([result isEqual:originalNotification], @"Unarchived object should equal original");
		XCTAssertTrue([result isKindOfClass:[NSPriorityNotification class]], @"Unarchived object should be NSPriorityNotification");
		
		// Verify that classForCoder was used during archiving
		XCTAssertEqual([result class], [NSPriorityNotification class], @"Result should be NSMutableNumber class");
	}
}
#pragma clang diagnostic pop

#pragma mark - Edge Cases and Error Handling


- (void)testNotificationWithNilObject {
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName object:nil];
	XCTAssertNotNil(notification);
	XCTAssertNil(notification.object);
}

- (void)testNotificationWithEmptyUserInfo {
	NSDictionary *emptyUserInfo = @{};
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:emptyUserInfo];
	XCTAssertNotNil(notification);
	XCTAssertEqualObjects(notification.userInfo, emptyUserInfo);
}

#pragma mark - Block Memory Management Tests

- (void)testBlockRetainAndRelease {
	@autoreleasepool {
		__weak NSPriorityNotification *weakNotification = nil;
		__block BOOL blockExecuted = NO;
		
		@autoreleasepool {
			void (^testBlock)(NSNotification *) = ^(NSNotification *note) {
				blockExecuted = YES;
			};
			
			NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																						  object:self.testObject
																					   postBlock:testBlock];
			weakNotification = notification;
			
			// Block should be retained
			XCTAssertNotNil(notification.postBlock);
			
			// Execute the block to verify it works
			notification.postBlock(notification);
			XCTAssertTrue(blockExecuted);
		}
		
		// After autoreleasepool, notification should be deallocated
		// This is a weak test as ARC behavior can vary
		XCTAssertNil(weakNotification);
	}
}

#pragma mark - NSNotification (PriorityExtension) Category Tests

- (void)testStandardNotificationReverse {
	NSNotification *notification = [NSNotification notificationWithName:self.testNotificationName object:self.testObject];
	XCTAssertFalse(notification.reverse);
}

- (void)testStandardNotificationPostBlock {
	NSNotification *notification = [NSNotification notificationWithName:self.testNotificationName object:self.testObject];
	XCTAssertNil(notification.postBlock);
}

- (void)testStandardNotificationIsPriorityPostDefault {
	NSNotification *notification = [NSNotification notificationWithName:self.testNotificationName object:self.testObject];
	XCTAssertFalse(notification.isPriorityPost);
}

- (void)testStandardNotificationSetIsPriorityPostYES {
	NSNotification *notification = [NSNotification notificationWithName:self.testNotificationName object:self.testObject];
	[notification setIsPriorityPost:YES];
	XCTAssertTrue(notification.isPriorityPost);
}

- (void)testStandardNotificationSetIsPriorityPostNO {
	NSNotification *notification = [NSNotification notificationWithName:self.testNotificationName object:self.testObject];
	[notification setIsPriorityPost:YES];
	XCTAssertTrue(notification.isPriorityPost);
	
	[notification setIsPriorityPost:NO];
	XCTAssertFalse(notification.isPriorityPost);
}

- (void)testStandardNotificationIsPriorityPostToggle {
	NSNotification *notification = [NSNotification notificationWithName:self.testNotificationName object:self.testObject];
	
	// Initially false
	XCTAssertFalse(notification.isPriorityPost);
	
	// Set to true
	[notification setIsPriorityPost:YES];
	XCTAssertTrue(notification.isPriorityPost);
	
	// Set back to false
	[notification setIsPriorityPost:NO];
	XCTAssertFalse(notification.isPriorityPost);
	
	// Set to true again
	[notification setIsPriorityPost:YES];
	XCTAssertTrue(notification.isPriorityPost);
}

- (void)testPriorityNotificationIsPriorityPost {
	NSPriorityNotification *notification = [NSPriorityNotification notificationWithName:self.testNotificationName
																				  object:self.testObject];
	
	// Should work with NSPriorityNotification too (inherits from NSNotification)
	XCTAssertFalse(notification.isPriorityPost);
	[notification setIsPriorityPost:YES];
	XCTAssertTrue(notification.isPriorityPost);
}

#pragma mark - Associated Object Memory Management Tests

- (void)testAssociatedObjectMemoryManagement {
	@autoreleasepool {
		NSNotification *notification = [NSNotification notificationWithName:self.testNotificationName object:self.testObject];
		
		// Set isPriorityPost multiple times to test memory management
		for (int i = 0; i < 100; i++) {
			[notification setIsPriorityPost:(i % 2 == 0)];
			XCTAssertEqual(notification.isPriorityPost, (i % 2 == 0));
		}
	}
	// Should not crash or leak memory
}

#pragma mark - Property Consistency Tests

- (void)testPropertyConsistencyAfterInit {
	__block BOOL blockCalled = NO;
	void (^testBlock)(NSNotification *) = ^(NSNotification *note) {
		blockCalled = YES;
	};
	
	NSPriorityNotification *notification = [[NSPriorityNotification alloc] initWithName:self.testNotificationName
																				  object:self.testObject
																				userInfo:self.testUserInfo
																				 reverse:YES
																			   postBlock:testBlock];
	
	// Test that all properties remain consistent
	XCTAssertEqualObjects(notification.name, self.testNotificationName);
	XCTAssertEqualObjects(notification.object, self.testObject);
	XCTAssertEqualObjects(notification.userInfo, self.testUserInfo);
	XCTAssertTrue(notification.reverse);
	XCTAssertNotNil(notification.postBlock);
	
	// Test multiple times to ensure consistency
	for (int i = 0; i < 10; i++) {
		XCTAssertEqualObjects(notification.name, self.testNotificationName);
		XCTAssertEqualObjects(notification.object, self.testObject);
		XCTAssertEqualObjects(notification.userInfo, self.testUserInfo);
		XCTAssertTrue(notification.reverse);
		XCTAssertNotNil(notification.postBlock);
	}
	
	// Test block still works
	notification.postBlock(notification);
	XCTAssertTrue(blockCalled);
}

- (void)testMultipleNotificationsIndependence {
	NSPriorityNotification *notification1 = [NSPriorityNotification notificationWithName:@"Test1"
																				   object:nil
																				  reverse:YES];
	
	NSPriorityNotification *notification2 = [NSPriorityNotification notificationWithName:@"Test2"
																				   object:nil
																				  reverse:NO];
	
	// Test that notifications are independent
	XCTAssertTrue(notification1.reverse);
	XCTAssertFalse(notification2.reverse);
	XCTAssertNotEqualObjects(notification1.name, notification2.name);
	
	// Test isPriorityPost independence for regular notifications
	NSNotification *stdNotification1 = [NSNotification notificationWithName:@"Std1" object:nil];
	NSNotification *stdNotification2 = [NSNotification notificationWithName:@"Std2" object:nil];
	
	[stdNotification1 setIsPriorityPost:YES];
	[stdNotification2 setIsPriorityPost:NO];
	
	XCTAssertTrue(stdNotification1.isPriorityPost);
	XCTAssertFalse(stdNotification2.isPriorityPost);
}

@end
