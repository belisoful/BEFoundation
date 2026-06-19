//
//  ObjectRegistryTests.m
//  ObjectRegistryTests
//
//  Created on 2025-01-01.
//  Copyright © 2025 Delicense. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+GlobalRegistry.h"

// Test class that conforms to ObjectRegistryProtocol
@interface NSObjectGlobalRegistryObject : NSObject <BERegistryProtocol>
@property (nonatomic, strong) NSString *testValue;
//- (NSString *)registerGlobalInstance;
//- (BOOL)unregisterGlobalInstance;
@end

@implementation NSObjectGlobalRegistryObject
@dynamic globalRegistryCount, globalRegistryUUID, isGlobalRegistered;
- (instancetype)initWithTestValue:(NSString *)value {
	self = [super init];
	if (self) {
		_testValue = value;
	}
	return self;
}

@end

// Test class that does NOT conform to ObjectRegistryProtocol
@interface NSObjectNonConformingTestObject : NSObject
@property (nonatomic, strong) NSString *testValue;
@end

@implementation NSObjectNonConformingTestObject
@end

@interface GlobalRegistryTests : XCTestCase
@property (nonatomic, strong) BEObjectRegistry *registry;
@property (nonatomic, strong) NSObjectGlobalRegistryObject *testObject1;
@property (nonatomic, strong) NSObjectGlobalRegistryObject *testObject2;
@property (nonatomic, strong) NSObjectNonConformingTestObject *nonConformingObject;

//@property (nonatomic) SEL lastCalledStart;
//@property (nonatomic) SEL lastCalledEnd;
@end

@implementation GlobalRegistryTests

- (void)setUp {
	[super setUp];
	self.testObject1 = nil;
	
	self.testObject1 = [[NSObjectGlobalRegistryObject alloc] initWithTestValue:@"test1"];
	self.nonConformingObject = [[NSObjectNonConformingTestObject alloc] init];
}

- (void)tearDown {
	self.testObject1 = nil;
	self.nonConformingObject = nil;
	[NSObject.globalRegistry clearAllRegisteredObjects];
	[super tearDown];
}


#pragma mark - NSObject Category Tests

- (void)testIsGlobalRegistered {
	@synchronized (NSObject.globalRegistry) {
		//self.lastCalledStart = _cmd;
		XCTAssertFalse(self.testObject1.isGlobalRegistered, @"Object should not be registered initially");
		
		[self.testObject1 registerGlobalInstance];
		XCTAssertTrue(self.testObject1.isGlobalRegistered, @"Object should be registered after registration");
	}
}

- (void)testObjectRegistryClass {
	@synchronized (NSObject.globalRegistry) {
		//self.lastCalledStart = _cmd;
		BEObjectRegistry *registry1 = [NSObject globalRegistry];
		BEObjectRegistry *registry2 = [NSObject globalRegistry];
		
		XCTAssertTrue([registry1 isKindOfClass:BEObjectRegistry.class]);
		XCTAssertNotNil(registry1, @"Global registry should not be nil");
		XCTAssertEqualObjects(registry1, registry2, @"Global registry should be singleton");
	}
}

- (void)testObjectRegistryCount {
	@synchronized (NSObject.globalRegistry) {
		if (self.testObject1.globalRegistryCount) {
			NSLog (@" ** [%@::%@] WARNING: testObject1 should not be registered '%@'", NSStringFromClass(self.class), NSStringFromSelector(_cmd), self.testObject1.globalRegistryUUID);
			
			[self.testObject1 unregisterGlobalInstance];
		}
		//self.lastCalledStart = _cmd;
		XCTAssertEqual(self.testObject1.globalRegistryCount, 0, @"Initial count should be 0");
		
		[self.testObject1 registerGlobalInstance];
		XCTAssertEqual(self.testObject1.globalRegistryCount, 1, @"Count should be 1 after registration");
	}
}


- (void)testObjectRegistryUUID {
	@synchronized (NSObject.globalRegistry) {
		//self.lastCalledStart = _cmd;
		NSString *uuid = self.testObject1.globalRegistryUUID;
		XCTAssertNotNil(uuid, @"Global registry UUID should not be nil");
	}
}

- (void)testRegisterGlobalInstance {
	@synchronized (NSObject.globalRegistry) {
		//self.lastCalledStart = _cmd;
		NSString *uuid = [self.testObject1 registerGlobalInstance];
		
		XCTAssertNotNil(uuid, @"Registration should return UUID");
		XCTAssertTrue(self.testObject1.isGlobalRegistered, @"Object should be registered");
	}
}

- (void)testUnregisterGlobalInstance {
	@synchronized (NSObject.globalRegistry) {
	
		if (self.testObject1.globalRegistryCount) {
			NSLog (@" ** [%@::%@] WARNING: testObject1 should not be registered '%@'", NSStringFromClass(self.class), NSStringFromSelector(_cmd), self.testObject1.globalRegistryUUID);
			
			[self.testObject1 unregisterGlobalInstance];
		}
		
		[self.testObject1 registerGlobalInstance];
		
		XCTAssertTrue(self.testObject1.isGlobalRegistered, @"Object should be registered");
		XCTAssertEqual(self.testObject1.globalRegistryCount, 1);
		
		BEUnregisterStatus success = [self.testObject1 unregisterGlobalInstance];
		XCTAssertEqual(success, BEUnregisterStatus_Unregistered, @"Unregistration should succeed");
		XCTAssertFalse(self.testObject1.isGlobalRegistered, @"Object should not be registered");
	}
}

- (void)testUnregister_ReferenceCounting {
	@synchronized (NSObject.globalRegistry) {
		[self.testObject1 registerGlobalInstance];
		[self.testObject1 registerGlobalInstance];
		XCTAssertEqual(self.testObject1.globalRegistryCount, 2, @"Two registrations should yield count 2");

		BEUnregisterStatus first = [self.testObject1 unregisterGlobalInstance];
		XCTAssertEqual(first, BEUnregisterStatus_Decremented, @"First unregister decrements, count still > 0");
		XCTAssertTrue(self.testObject1.isGlobalRegistered, @"Object still registered after one unregister");
		XCTAssertEqual(self.testObject1.globalRegistryCount, 1);

		BEUnregisterStatus second = [self.testObject1 unregisterGlobalInstance];
		XCTAssertEqual(second, BEUnregisterStatus_Unregistered, @"Second unregister fully removes the object");
		XCTAssertFalse(self.testObject1.isGlobalRegistered);
		XCTAssertEqual(self.testObject1.globalRegistryCount, 0);
	}
}

- (void)testUnregister_NeverRegistered_ReturnsNotRegistered {
	@synchronized (NSObject.globalRegistry) {
		XCTAssertFalse(self.testObject1.isGlobalRegistered);
		BEUnregisterStatus status = [self.testObject1 unregisterGlobalInstance];
		XCTAssertEqual(status, BEUnregisterStatus_NotRegistered,
					   @"Unregistering a never-registered object returns NotRegistered");
	}
}

- (void)testRegister_MultipleTimes_ReturnsSameUUID {
	@synchronized (NSObject.globalRegistry) {
		NSString *uuid1 = [self.testObject1 registerGlobalInstance];
		NSString *uuid2 = [self.testObject1 registerGlobalInstance];
		XCTAssertNotNil(uuid1);
		XCTAssertEqualObjects(uuid1, uuid2, @"Re-registering the same object returns the same UUID");

		[self.testObject1 unregisterGlobalInstance];
		[self.testObject1 unregisterGlobalInstance];
	}
}

@end
