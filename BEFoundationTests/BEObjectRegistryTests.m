//
//  ObjectRegistryTests.m
//  ObjectRegistryTests
//
//  Created on 2025-01-01.
//  Copyright © 2025 Delicense. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BEObjectRegistry.h"
#import "NSObject+GlobalRegistry.h"

// Test class that conforms to ObjectRegistryProtocol
@interface TestObjectRegistryObject : NSObject <BERegistryProtocol>
@property (nonatomic, strong) NSString *testValue;
@end

@implementation TestObjectRegistryObject
@dynamic globalRegistryCount, globalRegistryUUID, isGlobalRegistered;
- (instancetype)initWithTestValue:(NSString *)value {
	self = [super init];
	if (self) {
		_testValue = value;
	}
	return self;
}
@end



@interface TestCustomUUIDObject : TestObjectRegistryObject <CustomRegistryUUID>
@end
@implementation TestCustomUUIDObject

- (NSString*)objectRegistryUUID:(BEObjectRegistry *)registry
{
	return @"Custom-Registry-UUID";
}

@end



// Test class that does NOT conform to ObjectRegistryProtocol
@interface ObjectNonConformingTestObject : NSObject
@property (nonatomic, strong) NSString *testValue;
@end

@implementation ObjectNonConformingTestObject
@end




@interface BEObjectRegistryTests : XCTestCase
@property (nonatomic, strong) BEObjectRegistry	*registry;
@property (nonatomic, strong) TestObjectRegistryObject	*testObject1;
@property (nonatomic, strong) TestObjectRegistryObject	*testObject2;
@property (nonatomic, strong) TestCustomUUIDObject		*testCustomObject1;
@property (nonatomic, strong) ObjectNonConformingTestObject *nonConformingObject1;
@property (nonatomic, strong) ObjectNonConformingTestObject *nonConformingObject2;
@end

@implementation BEObjectRegistryTests

- (void)setUp {
	[super setUp];
	self.registry = [[BEObjectRegistry alloc] init];
	self.testObject1 = [[TestObjectRegistryObject alloc] initWithTestValue:@"test1"];
	self.testObject2 = [[TestObjectRegistryObject alloc] initWithTestValue:@"test2"];
	self.testCustomObject1 = [[TestCustomUUIDObject alloc] initWithTestValue:@"test3"];

	self.nonConformingObject1 = [[ObjectNonConformingTestObject alloc] init];
	self.nonConformingObject1.testValue = @"nonConforming1";
	
	self.nonConformingObject2 = [[ObjectNonConformingTestObject alloc] init];
	self.nonConformingObject2.testValue = @"nonConforming2";
}

- (void)tearDown {
	[self.registry clearAllRegisteredObjects];
	self.registry = nil;
	self.testObject1 = nil;
	self.testObject2 = nil;
	self.testCustomObject1 = nil;
	self.nonConformingObject1 = nil;
	[super tearDown];
}

#pragma mark - Initializers

- (void)testInit
{
	BEObjectRegistry *registry = [[BEObjectRegistry alloc] init];
	
	XCTAssertNotNil(registry);
	XCTAssertEqual(registry.keySalt, 0);
	XCTAssertTrue(registry.requireRegistryProtocol);
}

- (void)testInitWithkeySalt
{
	unsigned long salt = random();
	BEObjectRegistry *registry = [[BEObjectRegistry alloc] initWithKeySalt:salt];
	
	XCTAssertNotNil(registry);
	XCTAssertEqual(registry.keySalt, salt);
	XCTAssertTrue(registry.requireRegistryProtocol);
}



#pragma mark - Basic Registration Tests

- (void)testGlobalRegistry_NotLocal {
	@synchronized(NSObject.globalRegistry) {
		[NSObject.globalRegistry clearAllRegisteredObjects];
		NSString *guid1 = [self.testObject1 registerGlobalInstance];
		NSString *uuid1 = [self.registry registerObject:self.testObject1];
		NSString *uuid2 = [self.registry registerObject:self.testObject2];
		
		XCTAssertNotNil(guid1, @"UUID should not be nil after registration");
		XCTAssertNotNil(uuid1, @"UUID should not be nil after registration");
		XCTAssertNotNil(uuid2, @"UUID should not be nil after registration");
		XCTAssertEqualObjects(guid1, uuid1, @"global and local instance uuid are the same for the same object");
		XCTAssertNotEqualObjects(guid1, uuid2, @"global and local instances are not the same");
		XCTAssertEqual(self.registry.registeredObjectsCount, 2, @"Registry should contain one object");
		XCTAssertTrue([self.registry isObjectRegistered:self.testObject1], @"Object should be registered");
		
		XCTAssertEqual(NSObject.globalRegistry.registeredObjectsCount, 1, @"Registry should contain one object");
	}
}

- (void)testRegisterObject {
	NSString *uuid = [self.registry registerObject:self.testObject1];
	
	XCTAssertNotNil(uuid, @"UUID should not be nil after registration");
	XCTAssertTrue([uuid isKindOfClass:[NSString class]], @"UUID should be a string");
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should contain one object");
	XCTAssertTrue([self.registry isObjectRegistered:self.testObject1], @"Object should be registered");
}

- (void)testRegisterMultipleObjects {
	NSString *uuid1 = [self.registry registerObject:self.testObject1];
	NSString *uuid2 = [self.registry registerObject:self.testObject2];
	
	XCTAssertNotNil(uuid1, @"First UUID should not be nil");
	XCTAssertNotNil(uuid2, @"Second UUID should not be nil");
	XCTAssertNotEqual(uuid1, uuid2, @"UUIDs should be different");
	XCTAssertNotEqualObjects(uuid1, uuid2, @"UUIDs should be different");
	XCTAssertEqual(self.registry.registeredObjectsCount, 2, @"Registry should contain two objects");
}

- (void)testRegisterSameObjectTwice {
	NSString *uuid1 = [self.registry registerObject:self.testObject1];
	NSString *uuid2 = [self.registry registerObject:self.testObject1];
	
	XCTAssertEqualObjects(uuid1, uuid2, @"Same object should return same UUID when registered twice");
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should still contain only one object");
	XCTAssertEqual([self.registry registeredObjectForUUID:uuid1], self.testObject1, @"Registry should contain testObject1");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 2, @"Registered count should be 2");
	XCTAssertEqual([self.registry registeredObjectForUUID:uuid2], self.testObject1, @"Registry should contain testObject1");
}

- (void)testRegisterDifferentObjectWithSameUUID {
	NSString *staticUUID = [[NSUUID UUID] UUIDString];
	
	[self.registry setRegistryUUID:staticUUID forObject:self.testObject1];
	[self.registry setRegistryUUID:staticUUID forObject:self.testObject2];
	
	[self.registry registerObject:self.testObject1];
	XCTAssertThrowsSpecificNamed([self.registry registerObject:self.testObject2],
								NSException,
								NSDuplicateUUIDException,
								@"Should throw exception for non-conforming object");
}

- (void)testRegistryCustomObject {
	NSString *referenceUUID = [self.testCustomObject1 objectRegistryUUID:nil];
	NSString *uuid = [self.registry registerObject:self.testCustomObject1];
	NSString *retrievedUUID = [self.registry registryUUIDForObject:self.testCustomObject1];
	
	XCTAssertEqualObjects(uuid, referenceUUID, @"Custom Object UUID should match registered UUID");
	XCTAssertEqualObjects(uuid, retrievedUUID, @"Retrieved UUID should match registered UUID");
}

- (void)testRegisterObject_nonConformingObject1 {
	XCTAssertThrowsSpecificNamed([self.registry registerObject:self.nonConformingObject1],
								NSException,
								NSInvalidArgumentException,
								@"Should throw exception for non-conforming object");
}

- (void)testRegisterObject_nonConformingObject1_NotRequired {
	self.registry.requireRegistryProtocol = NO;
	NSString *uuid = [self.registry registerObject:self.nonConformingObject1];
	
	XCTAssertNotNil(uuid, @"UUID should not be nil after registration");
	XCTAssertTrue([uuid isKindOfClass:[NSString class]], @"UUID should be a string");
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should contain one object");
	XCTAssertTrue([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
	XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Non-conforming object count should be one");
}

- (void)testRegisterNilObject {
	id nilObject = nil;
	XCTAssertThrowsSpecificNamed([self.registry registerObject:nilObject],
								NSException,
								NSInvalidArgumentException,
								@"Should throw exception for non-conforming object");
	
	XCTAssertFalse([self.registry isObjectRegistered:nilObject], @"Object should be registered");
}

#pragma mark - UUID Management Tests


- (void)testkeySalt {
	unsigned long salt = 1;
	BEObjectRegistry *registry = [[BEObjectRegistry alloc] initWithKeySalt:salt];
	BEObjectRegistry *registry2 = [[BEObjectRegistry alloc] initWithKeySalt:salt];
	XCTAssertEqual(self.registry.keySalt, 0);
	XCTAssertNotEqual(self.registry.keySalt, salt);
	XCTAssertEqual(registry.keySalt, salt);
	XCTAssertEqual(registry2.keySalt, salt);
	
	XCTAssertNotEqual(registry.uuidKey, self.registry.uuidKey, @"The different salt should be the same uuidKey");
	XCTAssertNotEqual(registry.uuidKey, self.registry.uuidKey + salt, @"salt of 1 shouldn't be sequential up");
	XCTAssertNotEqual(registry.uuidKey, self.registry.uuidKey - salt, @"salt of 1 shouldn't be sequential down");
	XCTAssertEqual(registry2.uuidKey, registry.uuidKey, @"The same salt should be the same uuidKey");
}

- (void)testRegistryUUIDForObject_RegisteredObject {
	NSString *uuid = [self.registry registerObject:self.testObject1];
	NSString *retrievedUUID = [self.registry registryUUIDForObject:self.testObject1];
	
	XCTAssertEqualObjects(uuid, retrievedUUID, @"Retrieved UUID should match registered UUID");
}

- (void)testRegistryUUIDForObject_UnregisteredObject {
	NSString *uuid = [self.registry registryUUIDForObject:self.testObject1];
	
	XCTAssertNotNil(uuid, @"UUID should be generated for unregistered object");
	XCTAssertTrue([uuid isKindOfClass:[NSString class]], @"UUID should be a string");
}

- (void)testRegistryUUIDForObject_nonConformingObject1 {
	NSString *uuid = [self.registry registryUUIDForObject:(id)self.nonConformingObject1];
	XCTAssertNil(uuid, @"UUID should be nil for non-conforming object");
}


- (void)testRegistryUUIDForObject_nonConformingObject1_NotRequired {
	self.registry.requireRegistryProtocol = NO;
	NSString *uuid = [self.registry registryUUIDForObject:(id)self.nonConformingObject1];
	XCTAssertNotNil(uuid, @"UUID should be generated for non-conforming object");
}

- (void)testSetRegistryUUID {
	NSString *customUUID = @"custom-uuid-12345";
	[self.registry setRegistryUUID:customUUID forObject:self.testObject1];
	
	NSString *retrievedUUID = [self.registry registryUUIDForObject:self.testObject1];
	XCTAssertEqualObjects(customUUID, retrievedUUID, @"Custom UUID should be set correctly");
}

- (void)testSetRegistryUUIDWithSameRegisteredObjectUUID {
	NSString *staticUUID = [[NSUUID UUID] UUIDString];
	
	[self.registry setRegistryUUID:staticUUID forObject:self.testObject1];
	[self.registry registerObject:self.testObject1];
	
	XCTAssertThrowsSpecificNamed([self.registry setRegistryUUID:staticUUID forObject:self.testObject2],
								NSException,
								NSDuplicateUUIDException,
								@"Should throw exception for non-conforming object");
}

- (void)testSetRegistryUUIDOnCustomUUID {
	NSString *staticUUID = [[NSUUID UUID] UUIDString];
	
	[self.registry setRegistryUUID:staticUUID forObject:self.testCustomObject1];
	
	NSString *customUUID = [self.testCustomObject1 objectRegistryUUID:nil];
	XCTAssertEqualObjects([self.registry registryUUIDForObject:self.testCustomObject1], customUUID,
						 	@"CustomUUID object should retain it's custom UUID");
}

- (void)testSetRegistryUUIDWithNewDifferentUUID{
	
	NSString *staticUUID1 = [[NSUUID UUID] UUIDString];
	NSString *staticUUID2 = [[NSUUID UUID] UUIDString];
	[self.registry setRegistryUUID:staticUUID1 forObject:self.testObject1];
	[self.registry setRegistryUUID:staticUUID2 forObject:self.testObject1];
	
	XCTAssertEqualObjects([self.registry registryUUIDForObject:self.testObject1], staticUUID2, @"objects with new different UUID should have the new UUID");
}

- (void)testSetRegistryUUIDOnRegisteredObjectWithNewDifferentUUID{
	
	NSString *staticUUID1 = [[NSUUID UUID] UUIDString];
	NSString *staticUUID2 = [[NSUUID UUID] UUIDString];
	[self.registry setRegistryUUID:staticUUID1 forObject:self.testObject1];
	[self.registry registerObject:self.testObject1];
	[self.registry setRegistryUUID:staticUUID2 forObject:self.testObject1];
	
	XCTAssertEqualObjects([self.registry registryUUIDForObject:self.testObject1], staticUUID2, @"objects with new different UUID should have the new UUID");
}

- (void)testSetRegistryUUIDWithObject_nonConformingObject1 {
	XCTAssertThrowsSpecificNamed([self.registry setRegistryUUID:@"test-uuid" forObject:(id)self.nonConformingObject1],
								NSException,
								NSInvalidArgumentException,
								@"Should throw exception for non-conforming object");
}

- (void)testSetRegistryUUIDWithObject_nonConformingObject1_NotRequired {
	self.registry.requireRegistryProtocol = NO;
	
	NSString *customUUID = @"custom-uuid-12345";
	[self.registry setRegistryUUID:customUUID forObject:(id)self.nonConformingObject1];
	
	NSString *retrievedUUID = [self.registry registryUUIDForObject:(id)self.nonConformingObject1];
	XCTAssertEqualObjects(customUUID, retrievedUUID, @"Custom UUID should be set correctly");
}

- (void)testSetRegistryUUIDWithInvalidUUID {
	XCTAssertThrowsSpecificNamed([self.registry setRegistryUUID:(NSString *)@123 forObject:self.testObject1],
								NSException,
								NSInvalidArgumentException,
								@"Should throw exception for non-string UUID");
}

#pragma mark - Registration Count Tests

- (void)testRegisteredCountForObject {
	[self.registry registerObject:self.testObject1];
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after first registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 1, @"Count should be 1 after first registration");
	
	[self.registry registerObject:self.testObject1];
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 2, @"Registered Count should be 2 after second registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 2, @"Count should be 2 after second registration");
}

- (void)testRegisteredCountForObject_SeparateRegistry {
	NSString *uuid1 = [self.registry registerObject:self.testObject1];
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after first registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 1, @"Count should be 1 after first registration");
	
	BEObjectRegistry *registry = BEObjectRegistry.new;
	NSString *uuid2 = [registry registerObject:self.testObject1];
	
	XCTAssertEqualObjects(uuid1, uuid2, @"same object is separate registry with same salt should have the same UUID");
	
	XCTAssertEqual([registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after second registration");
	XCTAssertEqual([registry countForObject:self.testObject1], 2, @"Count should be 2 after second registration");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after second registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 2, @"Count should be 2 after second registration");
}

- (void)testRegisteredCountForObject_UnregisteredObject {
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Registered Count should be 0 for unregistered object");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 0, @"Count should be 0 for unregistered object");
}

- (void)testRegisteredCountForObject_nonConformingObject1 {
	XCTAssertEqual([self.registry registeredCountForObject:(id)self.nonConformingObject1], 0, @"Registered Count should be 0 for non-conforming object");
	XCTAssertEqual([self.registry countForObject:(id)self.nonConformingObject1], 0, @"Count should be 0 for non-conforming object");
}

- (void)testRegisteredCountForObject_nilObject {
	id nilObject = nil;
	XCTAssertEqual([self.registry registeredCountForObject:nilObject], 0, @"Registered Count should be 0 for nil object");
	XCTAssertEqual([self.registry countForObject:nilObject], 0, @"Count should be 0 for nil object");
}

#pragma mark - Object Retrieval Tests

- (void)testRegisteredObjectForUUID {
	NSString *uuid = [self.registry registerObject:self.testObject1];
	id retrievedObject = [self.registry registeredObjectForUUID:uuid];
	
	XCTAssertEqualObjects(retrievedObject, self.testObject1, @"Retrieved object should match registered object");
}

- (void)testRegisteredObjectForInvalidUUID {
	id retrievedObject = [self.registry registeredObjectForUUID:@"non-existent-uuid"];
	XCTAssertNil(retrievedObject, @"Should return nil for non-existent UUID");
	
	id nilObject = nil;
	retrievedObject = [self.registry registeredObjectForUUID:nilObject];
	XCTAssertNil(retrievedObject, @"Should return nil for nil UUID");
	
	retrievedObject = [self.registry registeredObjectForUUID:(NSString *)@123];
	XCTAssertNil(retrievedObject, @"Should return nil for non-string UUID");
}

- (void)testIsObjectRegistered {
	XCTAssertFalse([self.registry isObjectRegistered:self.testObject1], @"Object should not be registered initially");
	
	[self.registry registerObject:self.testObject1];
	XCTAssertTrue([self.registry isObjectRegistered:self.testObject1], @"Object should be registered after registration");
}

- (void)testIsObjectRegisteredWithnonConformingObject1 {
	XCTAssertFalse([self.registry isObjectRegistered:(id)self.nonConformingObject1], @"Non-conforming object should never be considered registered");
}

#pragma mark - Batch Operations Tests

- (void)testAllRegisteredObjects {
	NSString *uuid1 = [self.registry registerObject:self.testObject1];
	NSString *uuid2 = [self.registry registerObject:self.testObject2];
	
	NSDictionary *allObjects = [self.registry allRegisteredObjects];
	
	XCTAssertEqual(allObjects.count, 2, @"Should return all registered objects");
	XCTAssertEqual(allObjects[uuid1], self.testObject1, @"Should contain first test object");
	XCTAssertEqual(allObjects[uuid2], self.testObject2, @"Should contain second test object");
}

- (void)testAllRegisteredObjectUUIDs {
	NSString *uuid1 = [self.registry registerObject:self.testObject1];
	NSString *uuid2 = [self.registry registerObject:self.testObject2];
	
	NSArray *allUUIDs = [self.registry allRegisteredObjectUUIDs];
	
	XCTAssertEqual(allUUIDs.count, 2, @"Should return all UUIDs");
	XCTAssertTrue([allUUIDs containsObject:uuid1], @"Should contain first UUID");
	XCTAssertTrue([allUUIDs containsObject:uuid2], @"Should contain second UUID");
}

#pragma mark - Unregistration Tests

- (void)testUnregisterObject {
	[self.registry registerObject:self.testObject1];
	XCTAssertTrue([self.registry isObjectRegistered:self.testObject1], @"Object should be registered");
	
	BOOL success = [self.registry unregisterObject:self.testObject1];
	XCTAssertTrue(success, @"Unregistration should succeed");
	XCTAssertFalse([self.registry isObjectRegistered:self.testObject1], @"Object should not be registered after unregistration");
	XCTAssertEqual(self.registry.registeredObjectsCount, 0, @"Registry should be empty");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Registered Count should be 0 after unregistration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 0, @"Count should be 0 after unregistration");
}

- (void)testUnregisterObjectWithMultipleCounts {
	[self.registry registerObject:self.testObject1];
	[self.registry registerObject:self.testObject1]; // Register twice
	
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 2, @"Count should be 2");
	
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 2, @"Registered Count should be 2");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 2, @"Count should be 2");
	
	BOOL success = [self.registry unregisterObject:self.testObject1];
	XCTAssertTrue(success, @"First unregistration should succeed");
	XCTAssertTrue([self.registry isObjectRegistered:self.testObject1], @"Object should still be registered");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 1, @"Count should be 1");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after first unregistration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 1, @"Count should be 1 after first unregistration");
	
	success = [self.registry unregisterObject:self.testObject1];
	XCTAssertTrue(success, @"Second unregistration should succeed");
	XCTAssertFalse([self.registry isObjectRegistered:self.testObject1], @"Object should not be registered");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Count should be 0");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Registered Count should be 0 after unregistration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 0, @"Count should be 0 after unregistration");
}

- (void)testUnregisterObject_Unregistered {
	BOOL success = [self.registry unregisterObject:self.testObject1];
	XCTAssertFalse(success, @"Unregistering unregistered object should return NO");
}

- (void)testUnregisterObject_UnregisterednonConformingObject1 {
	BOOL success = [self.registry unregisterObject:(id)self.nonConformingObject1];
	XCTAssertFalse(success, @"Unregistering non-conforming object should return NO");
}

- (void)testUnregisterObject_RegisterednonConformingObject1 {
	self.registry.requireRegistryProtocol = NO;
	NSString *uuid = [self.registry registerObject:self.nonConformingObject1];
	
	XCTAssertNotNil(uuid, @"UUID should not be nil after registration");
	XCTAssertTrue([uuid isKindOfClass:[NSString class]], @"UUID should be a string");
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should contain one object");
	XCTAssertTrue([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
	XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Non-conforming object count should be one");
	
	{	//non conforming objects still in
		self.registry.requireRegistryProtocol = YES;
		
		XCTAssertTrue([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
		XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Non-conforming object count should be one");
		XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Registered Count should be 1 after registration");
	 XCTAssertEqual([self.registry countForObject:self.nonConformingObject1], 1, @"Count should be 1 after registration");
	}
	
	
	BOOL success = [self.registry unregisterObject:self.nonConformingObject1];
	XCTAssertTrue(success, @"Unregistering non-conforming object should return NO");
	XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 0, @"Registered Count should be 0 after unregistration");
	XCTAssertEqual([self.registry countForObject:self.nonConformingObject1], 0, @"Count should be 0 after unregistration");
}

- (void)testUnregisterObjectByUUID {
	NSString *uuida = [self.registry registerObject:self.testObject1];
	[self.registry registerObject:self.testObject1];
	
	int success = [self.registry unregisterObjectByUUID:uuida];
	XCTAssertEqual(success, 1, @"Unregistration by UUID should succeed");
	
	success = [self.registry unregisterObjectByUUID:uuida];
	XCTAssertEqual(success, 2, @"Unregistration by UUID should succeed");
	
	XCTAssertFalse([self.registry isObjectRegistered:self.testObject1], @"Object should not be registered");
}

- (void)testUnregisterObjectByUUID_RegisterednonConformingObject1 {
	self.registry.requireRegistryProtocol = NO;
	NSString *uuid = [self.registry registerObject:self.nonConformingObject1];
	
	XCTAssertNotNil(uuid, @"UUID should not be nil after registration");
	XCTAssertTrue([uuid isKindOfClass:[NSString class]], @"UUID should be a string");
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should contain one object");
	XCTAssertTrue([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
	XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Non-conforming object count should be one");
	
	{	//non conforming objects still in
		self.registry.requireRegistryProtocol = YES;
		
		XCTAssertTrue([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
		XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Non-conforming object count should be one");
	}
	
	BOOL success = [self.registry unregisterObjectByUUID:uuid];
	XCTAssertTrue(success, @"Unregistering non-conforming object should return NO");
}


- (void)testUnregisterObjectByUUID_SeparateRegistry_SingleRegObject{
	NSString *uuid = [self.registry registerObject:self.testObject1];
	
	BEObjectRegistry *registry = BEObjectRegistry.new;
	[registry registerObject:self.testObject1];
	XCTAssertEqual([registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after second registration");
	XCTAssertEqual([registry countForObject:self.testObject1], 2, @"Count should be 2 after second registration");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after second registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 2, @"Count should be 2 after second registration");
	
	BOOL success = [self.registry unregisterObjectByUUID:uuid];
	XCTAssertTrue(success, @"Unregistering object should return YES");
	
	XCTAssertEqual([registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after second registration");
	XCTAssertEqual([registry countForObject:self.testObject1], 1, @"Count should be 2 after second registration");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Registered Count should be 1 after second registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 1, @"Count should be 2 after second registration");
}


- (void)testUnregisterObjectByUUID_SeparateRegistry_MultipleRegObject{
	NSString *uuid = [self.registry registerObject:self.testObject1];
	[self.registry registerObject:self.testObject1];
	
	BEObjectRegistry *registry = BEObjectRegistry.new;
	[registry registerObject:self.testObject1];
	[registry registerObject:self.testObject1];
	XCTAssertEqual([registry registeredCountForObject:self.testObject1], 2, @"Registered Count should be 2 after second registration");
	XCTAssertEqual([registry countForObject:self.testObject1], 4, @"Count should be 4 after second registration");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 2, @"Registered Count should be 2 after second registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 4, @"Count should be 4 after second registration");
	
	BOOL success = [self.registry unregisterObjectByUUID:uuid];
	XCTAssertTrue(success, @"Unregistering object should return YES");
	
	XCTAssertEqual([registry registeredCountForObject:self.testObject1], 2, @"Registered Count should be 1 after second registration");
	XCTAssertEqual([registry countForObject:self.testObject1], 3, @"Count should be 2 after second registration");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after second registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 3, @"Count should be 2 after second registration");
	
	success = [self.registry unregisterObjectByUUID:uuid];
	XCTAssertTrue(success, @"Unregistering object should return YES");
	
	XCTAssertEqual([registry registeredCountForObject:self.testObject1], 2, @"Registered Count should be 1 after second registration");
	XCTAssertEqual([registry countForObject:self.testObject1], 2, @"Count should be 2 after second registration");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Registered Count should be 1 after second registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 2, @"Count should be 2 after second registration");
}

- (void)testUnregisterObjectByInvalidUUID {
	BOOL success = [self.registry unregisterObjectByUUID:@"invalid-uuid"];
	XCTAssertFalse(success, @"Unregistering with invalid UUID should return NO");
	
	NSString *nilUuid = nil;
	success = [self.registry unregisterObjectByUUID:nilUuid];
	XCTAssertFalse(success, @"Unregistering with nil UUID should return NO");
}

#pragma mark - Clear Operations Tests

- (void)testClearObjectsWithoutRegistryProtocol_Default {
	self.registry.requireRegistryProtocol = NO;
	NSString *uuid1 = [self.registry registerObject:self.testObject1];
	NSString *uuid2 = [self.registry registerObject:self.nonConformingObject1];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 2, @"Registry should contain one object");
	
	{	//non conforming objects still in
		self.registry.requireRegistryProtocol = YES;
		
		XCTAssertTrue([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
		XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Non-conforming object count should be one");
		
		self.registry.requireRegistryProtocol = NO;
		
		XCTAssertTrue([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
		XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Non-conforming object count should be one");
	}
	
	[self.registry clearObjectsWithoutRegistryProtocol];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should contain one object");
	XCTAssertFalse([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
	XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 0, @"Non-conforming object count should be one");
	XCTAssertEqualObjects([self.registry registryUUIDForObject:self.nonConformingObject1], uuid2, @"UUID of object not cleared");
}

- (void)testClearObjectsWithoutRegistryProtocol_ClearUUIDNO {
	self.registry.requireRegistryProtocol = NO;
	NSString *uuid1 = [self.registry registerObject:self.testObject1];
	NSString *uuid2 = [self.registry registerObject:self.nonConformingObject1];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 2, @"Registry should contain one object");
	
	{	//non conforming objects still in
		self.registry.requireRegistryProtocol = YES;
		
		XCTAssertTrue([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
		XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Non-conforming object count should be one");
		
		self.registry.requireRegistryProtocol = NO;
		
		XCTAssertTrue([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
		XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Non-conforming object count should be one");
	}
	
	[self.registry clearObjectsWithoutRegistryProtocol:NO];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should contain one object");
	XCTAssertFalse([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
	XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 0, @"Non-conforming object count should be one");
	XCTAssertEqualObjects([self.registry registryUUIDForObject:self.nonConformingObject1], uuid2, @"UUID of object not cleared");
}


- (void)testClearObjectsWithoutRegistryProtocol_ClearUUIDYES {
	self.registry.requireRegistryProtocol = NO;
	NSString *uuid1 = [self.registry registerObject:self.testObject1];
	NSString *uuid2 = [self.registry registerObject:self.nonConformingObject1];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 2, @"Registry should contain one object");
	
	{	//non conforming objects still in
		self.registry.requireRegistryProtocol = YES;
		
		XCTAssertTrue([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
		XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Non-conforming object count should be one");
		
		self.registry.requireRegistryProtocol = NO;
		
		XCTAssertTrue([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
		XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 1, @"Non-conforming object count should be one");
	}
	
	[self.registry clearObjectsWithoutRegistryProtocol:YES];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should contain one object");
	XCTAssertFalse([self.registry isObjectRegistered:self.nonConformingObject1], @"Non-conforming Object should be not registered");
	XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 0, @"Non-conforming object count should be zero");
	XCTAssertNotEqualObjects([self.registry registryUUIDForObject:self.nonConformingObject1], uuid2, @"UUID of object should be cleared");
}


- (void)testClearObjectsWithoutRegistryProtocol_ClearUUIDYES_SeparateRegistry {
	self.registry.requireRegistryProtocol = NO;
	
	[self.registry registerObject:self.testObject1];
	NSString *uuid1 = [self.registry registerObject:self.nonConformingObject1];
	[self.registry registerObject:self.nonConformingObject1];
	NSString *uuid2 = [self.registry registerObject:self.nonConformingObject2];
	
	BEObjectRegistry *registry = BEObjectRegistry.new;
	registry.requireRegistryProtocol = NO;
	[registry registerObject:self.nonConformingObject2];
	
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 3, @"Registry should contain two objects");
	
	[self.registry clearObjectsWithoutRegistryProtocol:YES];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should contain one object");
	XCTAssertTrue([self.registry isObjectRegistered:self.testObject1], @"Object should be registered");
	XCTAssertFalse([self.registry isObjectRegistered:self.nonConformingObject1], @"Object should be registered");
	XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 0, @"Non-conforming object count should be zero");
	XCTAssertNotEqualObjects([self.registry registryUUIDForObject:self.nonConformingObject1], uuid1, @"UUID of object should be cleared");
	XCTAssertEqualObjects([self.registry registryUUIDForObject:self.nonConformingObject2], uuid2, @"UUID of object should be cleared");
	
	
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 1, @"Count should be 1 after registration");
	XCTAssertEqual([self.registry registeredCountForObject:self.nonConformingObject1], 0, @"Registered Count should be 0 after clearing");
	XCTAssertEqual([self.registry countForObject:self.nonConformingObject1], 0, @"Count should be 0 after clearing");
	XCTAssertEqual([registry registeredCountForObject:self.nonConformingObject2], 1, @"Separate Registry Registered Count should be 1 clearing");
	XCTAssertEqual([registry countForObject:self.nonConformingObject2], 1, @"Separate Registry Count should be 1 after clearing");
}



- (void)testClearObject {
	NSString *uuid1 = [self.registry registerObject:self.testObject1];
	[self.registry registerObject:self.testObject1];
	[self.registry registerObject:self.testObject2];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 2, @"Should have 2 registered objects");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 2, @"Registered Count should be 2 after second registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 2, @"Count should be 2 after second registration");
	
	XCTAssertTrue([self.registry clearObject:self.testObject1]);
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should be empty after clearing");
	XCTAssertFalse([self.registry isObjectRegistered:self.testObject1], @"First object should not be registered");
	XCTAssertTrue([self.registry isObjectRegistered:self.testObject2], @"Second object should be registered");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Registered Count should be 0 after second clearing");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 0, @"Count should be 0 after clearing");
	
	XCTAssertEqualObjects([self.registry registryUUIDForObject:self.testObject1], uuid1, @"UUID of cleared object is the same");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Registered Count should be 0 after clearing");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 0, @"Count should be 0 after clearing");
}

- (void)testClearObject_UnegisterednonConformingObject1 {
	BOOL success = [self.registry unregisterObject:(id)self.nonConformingObject1];
	XCTAssertFalse(success, @"Unregistering non-conforming object should return NO");
}


- (void)testClearObject_RegisterednonConformingObject1 {
	self.registry.requireRegistryProtocol = NO;
	
	NSString *uuid1 = [self.registry registerObject:self.nonConformingObject1];
	[self.registry registerObject:self.nonConformingObject1];
	[self.registry registerObject:self.testObject2];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 2, @"Should have 2 registered objects");
	
	self.registry.requireRegistryProtocol = YES;
	
	XCTAssertTrue([self.registry clearObject:self.nonConformingObject1]);
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should be empty after clearing");
	XCTAssertFalse([self.registry isObjectRegistered:self.nonConformingObject1], @"Nonconforming object should not be registered");
	XCTAssertTrue([self.registry isObjectRegistered:self.testObject2], @"Second object should be registered");
	
	XCTAssertNil([self.registry registryUUIDForObject:self.nonConformingObject1], @"UUID of cleared object is the same");
	
	self.registry.requireRegistryProtocol = NO;
	XCTAssertEqualObjects([self.registry registryUUIDForObject:self.nonConformingObject1], uuid1, @"UUID of cleared object is the same");
}

- (void)testClearObject_BadArgument {
	XCTAssertFalse([self.registry clearObject:nil]);
	XCTAssertFalse([self.registry clearObject:(id)NSObject.new]);
}


- (void)testClearObjectByUUID {
	NSString *uuid1 = [self.registry registerObject:self.testObject1];
	[self.registry registerObject:self.testObject1];
	[self.registry registerObject:self.testObject2];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 2, @"Should have 2 registered objects");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 2, @"Registered Count should be 2 after second registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 2, @"Count should be 2 after second registration");
	
	XCTAssertTrue([self.registry clearObjectByUUID:self.testObject1.globalRegistryUUID]);
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 1, @"Registry should be empty after clearing");
	XCTAssertFalse([self.registry isObjectRegistered:self.testObject1], @"First object should not be registered");
	XCTAssertTrue([self.registry isObjectRegistered:self.testObject2], @"Second object should be registered");
	
	XCTAssertEqualObjects([self.registry registryUUIDForObject:self.testObject1], uuid1, @"UUID of cleared object is the same");
	
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Registered Count should be 0 after clearing");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 0, @"Count should be 0 after clearing");
}

- (void)testClearObjectByUUID_BadArgument {
	XCTAssertFalse([self.registry clearObjectByUUID:nil]);
	XCTAssertFalse([self.registry clearObjectByUUID:(NSString*)NSObject.new]);
	XCTAssertFalse([self.registry clearObjectByUUID:@""]);
}

- (void)testClearAllRegisteredObjectsDefault {
	[self.registry registerObject:self.testObject1];
	NSString *uuid = [self.registry registryUUIDForObject:self.testObject1];
	
	[self.registry clearAllRegisteredObjects];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 0, @"Registry should be empty");
	NSString *retrievedUUID = [self.registry registryUUIDForObject:self.testObject1];
	XCTAssertEqualObjects(uuid, retrievedUUID, @"UUID should still be associated with object");
}

- (void)testClearAllRegisteredObjects_WithoutClearingUUIDs {
	[self.registry registerObject:self.testObject1];
	[self.registry registerObject:self.testObject1];
	NSString *uuid = [self.registry registryUUIDForObject:self.testObject1];
	
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 2, @"Registered Count should be 2 after second registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 2, @"Count should be 2 after second registration");
	
	[self.registry clearAllRegisteredObjects:NO];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 0, @"Registry should be empty");
	NSString *retrievedUUID = [self.registry registryUUIDForObject:self.testObject1];
	XCTAssertEqualObjects(uuid, retrievedUUID, @"UUID should still be associated with object");
	
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Registered Count should be 0 after clearing");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 0, @"Count should be 0 after clearing");
}

- (void)testClearAllRegisteredObjects_WithClearingUUIDs {
	[self.registry registerObject:self.testObject1];
	[self.registry registerObject:self.testObject1];
	NSString *uuid = [self.registry registryUUIDForObject:self.testObject1];
	
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 2, @"Registered Count should be 2 after second registration");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 2, @"Count should be 2 after second registration");
	
	[self.registry clearAllRegisteredObjects:YES];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 0, @"Registry should be empty");
	NSString *retrievedUUID = [self.registry registryUUIDForObject:self.testObject1];
	XCTAssertNotEqualObjects(retrievedUUID, uuid, @"UUID should not be associated with object");
	
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Registered Count should be 0 after clearing");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 0, @"Count should be 0 after clearing");
}


- (void)testClearAllRegisteredObjects_SeparateRegistry {
	[self.registry registerObject:self.testObject1];
	NSString *uuid1 = [self.registry registerObject:self.testObject1];
	NSString *uuid2 = [self.registry registerObject:self.testObject2];
	
	BEObjectRegistry *registry = BEObjectRegistry.new;
	[registry registerObject:self.testObject1];
	
	XCTAssertEqual([registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after registering");
	XCTAssertEqual([registry countForObject:self.testObject1], 3, @"Count should be 2 after registering in separate Registry");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 2, @"Registered Count should be 2 after registering");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 3, @"Count should be 3 after registering in separate Registry");
	
	[self.registry clearAllRegisteredObjects:YES];
	
	XCTAssertEqual(self.registry.registeredObjectsCount, 0, @"Registry should be empty");
	NSString *retrievedUUID1 = [self.registry registryUUIDForObject:self.testObject1];
	NSString *retrievedUUID2 = [self.registry registryUUIDForObject:self.testObject2];
	XCTAssertEqualObjects(retrievedUUID1, uuid1, @"UUID should still be associated with object for the separate registry");
	XCTAssertNotEqualObjects(retrievedUUID2, uuid2, @"UUID should not be associated with object");
	
	XCTAssertEqual([registry registeredCountForObject:self.testObject1], 1, @"Registered Count should be 1 after registering");
	XCTAssertEqual([registry countForObject:self.testObject1], 1, @"Count should be 1 after registering in separate Registry");
	XCTAssertEqual([self.registry registeredCountForObject:self.testObject1], 0, @"Registered Count should be 0 after clearing");
	XCTAssertEqual([self.registry countForObject:self.testObject1], 1, @"Count should be 0 after clearing");
}


#pragma mark - Exception Tests

- (void)testSetRegistryUUID_DuplicateUUIDException {
	NSString *customUUID = @"duplicate-test-uuid";
	
	// Set the same UUID for two different objects
	[self.registry setRegistryUUID:customUUID forObject:self.testObject1];
	[self.registry registerObject:self.testObject1];
	
	// This should throw an exception
	XCTAssertThrowsSpecificNamed([self.registry setRegistryUUID:customUUID forObject:self.testObject2],
								NSException,
								NSDuplicateUUIDException,
								@"Should throw NSDuplicateUUIDException for duplicate UUID");
}

#pragma mark - Memory Management Tests

- (void)testWeakReferences {
	NSString *uuid;
	@autoreleasepool {
		TestObjectRegistryObject *tempObject = [[TestObjectRegistryObject alloc] initWithTestValue:@"temp"];
		uuid = [self.registry registerObject:tempObject];
		XCTAssertNotNil([self.registry registeredObjectForUUID:uuid], @"Object should be in registry");
	}
	
	// Force garbage collection to ensure weak reference is cleared
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	
	// Object should be removed from registry due to weak reference
	XCTAssertNil([self.registry registeredObjectForUUID:uuid], @"Object should be removed from registry when deallocated");
}

#pragma mark - Thread Safety Tests

- (void)testConcurrentRegistration {
	NSMutableDictionary	*objects = NSMutableDictionary.new;
	dispatch_group_t	group = dispatch_group_create();
	dispatch_queue_t	queue = dispatch_queue_create("test.concurrent", DISPATCH_QUEUE_CONCURRENT);
	
	const int maxDispatch = 100;
	
	for (int i = 0; i < maxDispatch; i++) {
		dispatch_group_async(group, queue, ^{
			TestObjectRegistryObject *obj = [[TestObjectRegistryObject alloc] initWithTestValue:[NSString stringWithFormat:@"test%d", i]];
			NSString *uuid = nil;
			uuid = [self.registry registerObject:obj];
			XCTAssertNotNil(uuid);
			XCTAssertTrue([self.registry isObjectRegistered:obj]);
			@synchronized(objects) {
				//Obj must be retained or else it will be removed from the registry
				objects[uuid] = obj;
			}
		});
	}
	
	dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
	
	XCTAssertEqual(objects.count, maxDispatch, @"All objects should be registered");
	XCTAssertEqual(self.registry.registeredObjectsCount, maxDispatch, @"Registry should contain all objects");
	
	// Verify all UUIDs are unique
	NSSet *uniqueUUIDs = [NSSet setWithArray:objects.allKeys];
	XCTAssertEqual(uniqueUUIDs.count, objects.count, @"All UUIDs should be unique");
}

@end
