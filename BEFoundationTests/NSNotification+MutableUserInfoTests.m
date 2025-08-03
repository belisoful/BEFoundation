//
//  BFoundationExtensionTests.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import "NSNotification+MutableUserInfo.h"

@interface NSNotificationMutableUserInfoTests : XCTestCase

@end

@implementation NSNotificationMutableUserInfoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testmutableUserInfo_Correctness
{
	NSObject *obj = NSObject.new;
	NSMutableDictionary *mutableUserInfo = NSMutableDictionary.new;
	NSDictionary *userInfo = NSDictionary.new;
	
	NSNotification *mutableNotification = [NSNotification.alloc initWithName:@"NonspecificName" object:obj userInfo:mutableUserInfo];
	XCTAssertEqualObjects(mutableNotification.userInfo, mutableUserInfo);
	XCTAssertEqualObjects(mutableNotification.mutableUserInfo, mutableUserInfo);
	
	XCTAssertTrue([mutableNotification.userInfo isKindOfClass:NSDictionary.class]);
	XCTAssertTrue([mutableNotification.userInfo isKindOfClass:NSMutableDictionary.class]);
	XCTAssertTrue([mutableNotification.mutableUserInfo isKindOfClass:NSDictionary.class]);
	XCTAssertTrue([mutableNotification.mutableUserInfo isKindOfClass:NSMutableDictionary.class]);
	
	
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:obj userInfo:userInfo];
	XCTAssertEqualObjects(notification.userInfo, userInfo);
	XCTAssertNil(notification.mutableUserInfo);
	
	XCTAssertTrue([notification.userInfo isKindOfClass:NSDictionary.class]);
	XCTAssertFalse([notification.userInfo isKindOfClass:NSMutableDictionary.class]);
}

- (void)testmutableUserInfo_NotDictionary
{
	NSObject *obj = NSObject.new;
	NSObject *userInfo = NSObject.new;
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:obj userInfo:(NSDictionary*)userInfo];
	XCTAssertEqualObjects(notification.userInfo, userInfo);
	XCTAssertNil(notification.mutableUserInfo);
}

@end
