//
//  BFoundationExtensionTests.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import "NSNotification+ExtraProperties.h"

// Cross-platform stand-in for the AppKit fixture this test used to use: a plain object
// exposing -tag and -identifier, which NSNotification+ExtraProperties reads from .object.
@interface BENotificationTestObject : NSObject
@property (nonatomic) NSInteger tag;
@property (nonatomic, nullable, strong) NSString *identifier;
@end
@implementation BENotificationTestObject @end

@interface NSNotificationExtraPropertiesTests : XCTestCase

@end

@implementation NSNotificationExtraPropertiesTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testTag_SetExtraProperties_Correctness
{
	NSInteger tag = random();
	NSString *identifier = [NSString stringWithFormat:@"%ld", tag + 1];
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:nil userInfo:nil];
	notification.tag = tag;
	notification.identifier = identifier;
	
	XCTAssertEqual(notification.tag, tag);
	XCTAssertEqual(notification.identifier, identifier);
}

- (void)testTag_ObjectProperties_Correctness
{
	NSInteger btnTag = random();
	NSString *btnIdentifier = [NSString stringWithFormat:@"%ld", btnTag + 1];
	BENotificationTestObject *btn = [BENotificationTestObject.alloc init];
	
	btn.tag = btnTag;
	btn.identifier = btnIdentifier;
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:btn userInfo:nil];
	
	XCTAssertEqual(notification.tag, btnTag);
	XCTAssertEqual(notification.identifier, btnIdentifier);
}

- (void)testTag_ObjectProperties_noExtra_Correctness
{
	BENotificationTestObject *object = (BENotificationTestObject *)NSObject.new;
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:object userInfo:nil];
	
	XCTAssertEqual(notification.tag, 0);
	XCTAssertNil(notification.identifier);
}

- (void)testTag_UserInfo_Correctness
{
	NSInteger userTag = random();
	NSString *userIdentifier = [NSString stringWithFormat:@"%ld", userTag + 1];
	NSDictionary *userInfo = @{@"tag": @(userTag), @"identifier" : userIdentifier};
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:nil userInfo:userInfo];
	
	XCTAssertEqual(notification.tag, userTag);
	XCTAssertEqual(notification.identifier, userIdentifier);
}


- (void)testTag_SetExtraAndObject_Correctness
{
	NSInteger tag = random();
	NSString *identifier = [NSString stringWithFormat:@"%ld", tag + 1];
	
	NSInteger btnTag = random();
	NSString *btnIdentifier = [NSString stringWithFormat:@"%ld", btnTag + 1];
	BENotificationTestObject *btn = [BENotificationTestObject.alloc init];
	
	btn.tag = btnTag;
	btn.identifier = btnIdentifier;
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:btn userInfo:nil];
	notification.tag = tag;
	notification.identifier = identifier;
	
	XCTAssertEqual(notification.tag, tag);
	XCTAssertEqual(notification.identifier, identifier);
	
	notification.tag = 0;
	notification.identifier = nil;
	
	XCTAssertEqual(notification.tag, btnTag);
	XCTAssertEqual(notification.identifier, btnIdentifier);
}


- (void)testTag_SetExtraAndObject_noExtra_Correctness
{
	NSInteger tag = random();
	NSString *identifier = [NSString stringWithFormat:@"%ld", tag + 1];
	
	NSObject *object = NSObject.new;
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:object userInfo:nil];
	notification.tag = tag;
	notification.identifier = identifier;
	
	XCTAssertEqual(notification.tag, tag);
	XCTAssertEqual(notification.identifier, identifier);
	
	notification.tag = 0;
	notification.identifier = nil;
	
	XCTAssertEqual(notification.tag, 0);
	XCTAssertNil(notification.identifier);
}


- (void)testTag_SetExtraAndUserInfo_Correctness
{
	NSInteger tag = random();
	NSString *identifier = [NSString stringWithFormat:@"%ld", tag + 1];
	
	NSInteger userTag = random();
	NSString *userIdentifier = [NSString stringWithFormat:@"%ld", userTag + 1];
	NSDictionary *userInfo = @{@"tag": @(userTag), @"identifier" : userIdentifier};
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:nil userInfo:userInfo];
	notification.tag = tag;
	notification.identifier = identifier;
	
	XCTAssertEqual(notification.tag, tag);
	XCTAssertEqual(notification.identifier, identifier);
	
	notification.tag = 0;
	notification.identifier = nil;
	
	XCTAssertEqual(notification.tag, userTag);
	XCTAssertEqual(notification.identifier, userIdentifier);
}


- (void)testTag_ObjectAndUserInfo_Correctness
{
	NSInteger btnTag = random();
	NSString *btnIdentifier = [NSString stringWithFormat:@"%ld", btnTag + 1];
	BENotificationTestObject *btn = [BENotificationTestObject.alloc init];
	
	btn.tag = btnTag;
	btn.identifier = btnIdentifier;
	
	NSInteger userTag = random();
	NSString *userIdentifier = [NSString stringWithFormat:@"%ld", userTag + 1];
	NSDictionary *userInfo = @{@"tag": @(userTag), @"identifier" : userIdentifier};
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:btn userInfo:userInfo];
	
	XCTAssertEqual(notification.tag, btnTag);
	XCTAssertEqual(notification.identifier, btnIdentifier);
	
	// no way to default to the userInfo if the object has
}


- (void)testTag_ObjectAndUserInfo_noExtra_Correctness
{
	NSObject *object = NSObject.new;
	
	NSInteger userTag = random();
	NSString *userIdentifier = [NSString stringWithFormat:@"%ld", userTag + 1];
	NSDictionary *userInfo = @{@"tag": @(userTag), @"identifier" : userIdentifier};
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:object userInfo:userInfo];
	
	XCTAssertEqual(notification.tag, userTag);
	XCTAssertEqual(notification.identifier, userIdentifier);
}


- (void)testTag_SetExtraAndObjectAndUserInfo_Correctness
{
	NSInteger tag = random();
	NSString *identifier = [NSString stringWithFormat:@"%ld", tag + 1];
	
	NSInteger btnTag = random();
	NSString *btnIdentifier = [NSString stringWithFormat:@"%ld", btnTag + 1];
	BENotificationTestObject *btn = [BENotificationTestObject.alloc init];
	
	btn.tag = btnTag;
	btn.identifier = btnIdentifier;
	
	NSInteger userTag = random();
	NSString *userIdentifier = [NSString stringWithFormat:@"%ld", userTag + 1];
	NSDictionary *userInfo = @{@"tag": @(userTag), @"identifier" : userIdentifier};
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:btn userInfo:userInfo];
	notification.tag = tag;
	notification.identifier = identifier;
	
	XCTAssertEqual(notification.tag, tag);
	XCTAssertEqual(notification.identifier, identifier);
	
	notification.tag = 0;
	notification.identifier = nil;
	
	XCTAssertEqual(notification.tag, btnTag);
	XCTAssertEqual(notification.identifier, btnIdentifier);
}


- (void)testTag_SetExtraAndObjectAndUserInfo_noExtra_Correctness
{
	NSInteger tag = random();
	NSString *identifier = [NSString stringWithFormat:@"%ld", tag + 1];
	
	NSObject *object = NSObject.new;
	
	NSInteger userTag = random();
	NSString *userIdentifier = [NSString stringWithFormat:@"%ld", userTag + 1];
	NSDictionary *userInfo = @{@"tag": @(userTag), @"identifier" : userIdentifier};
	
	NSNotification *notification = [NSNotification.alloc initWithName:@"NonspecificName" object:object userInfo:userInfo];
	notification.tag = tag;
	notification.identifier = identifier;
	
	XCTAssertEqual(notification.tag, tag);
	XCTAssertEqual(notification.identifier, identifier);
	
	notification.tag = 0;
	notification.identifier = nil;
	
	XCTAssertEqual(notification.tag, userTag);
	XCTAssertEqual(notification.identifier, userIdentifier);
}

@end
