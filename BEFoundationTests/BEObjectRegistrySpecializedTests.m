/*!
 @file          BEUniversalObjectRegistryTests.m
 @copyright     -© 2025 Delicense - @belisoful. All rights released.
 @date          2025-01-01
 @abstract      Comprehensive unit tests for BEUniversalObjectRegistry and BEStorageObjectRegistry
 @discussion    Unit tests covering specific functionality differences from BEObjectRegistry including protocol requirements, memory management, and storage behavior.
 */

#import <XCTest/XCTest.h>
#import "BEObjectRegistry.h"
#import "NSObject+GlobalRegistry.h"

// Test objects
@interface TestProtocolObject : NSObject <BERegistryProtocol>
@property (nonatomic, strong) NSString *identifier;
@end

@implementation TestProtocolObject
@dynamic globalRegistryUUID, globalRegistryCount, isGlobalRegistered;
- (instancetype)initWithIdentifier:(NSString *)identifier {
	self = [super init];
	if (self) {
		_identifier = identifier;
	}
	return self;
}
@end

@interface TestNonProtocolObject : NSObject
@property (nonatomic, strong) NSString *identifier;
@end

@implementation TestNonProtocolObject
- (instancetype)initWithIdentifier:(NSString *)identifier {
	self = [super init];
	if (self) {
		_identifier = identifier;
	}
	return self;
}
@end

@interface TestSpecializedCustomUUIDObject : NSObject <BERegistryProtocol, CustomRegistryUUID>
@property (nonatomic, strong) NSString *customUUID;
@end

@implementation TestSpecializedCustomUUIDObject
@dynamic globalRegistryUUID, globalRegistryCount, isGlobalRegistered;
- (instancetype)initWithCustomUUID:(NSString *)uuid {
	self = [super init];
	if (self) {
		_customUUID = uuid;
	}
	return self;
}

- (NSString *)objectRegistryUUID:(BEObjectRegistry *)registry {
	return self.customUUID;
}
@end




@interface BEUniversalObjectRegistryTests : XCTestCase
@property (nonatomic, strong) BEUniversalObjectRegistry *universalRegistry;
@end

@implementation BEUniversalObjectRegistryTests

- (void)setUp {
	[super setUp];
	self.universalRegistry = [[BEUniversalObjectRegistry alloc] init];
}

- (void)tearDown {
	[self.universalRegistry clearAllRegisteredObjects:YES];
	self.universalRegistry = nil;
	[super tearDown];
}

#pragma mark - BEUniversalObjectRegistry Specific Tests

- (void)testUniversalRegistryInitialization {
	XCTAssertNotNil(self.universalRegistry);
	XCTAssertFalse(self.universalRegistry.requireRegistryProtocol, @"BEUniversalObjectRegistry should not require registry protocol");
	XCTAssertEqual(self.universalRegistry.keySalt, 0);
	XCTAssertEqual(self.universalRegistry.registeredObjectsCount, 0);
}

- (void)testUniversalRegistryAcceptsProtocolObjects {
	TestProtocolObject *obj = [[TestProtocolObject alloc] initWithIdentifier:@"protocol-test"];
	NSString *uuid = [self.universalRegistry registerObject:obj];
	
	XCTAssertNotNil(uuid);
	XCTAssertEqual(self.universalRegistry.registeredObjectsCount, 1);
	XCTAssertTrue([self.universalRegistry isObjectRegistered:obj]);
	
	id retrievedObj = [self.universalRegistry registeredObjectForUUID:uuid];
	XCTAssertEqualObjects(retrievedObj, obj);
}

- (void)testUniversalRegistryAcceptsNonProtocolObjects {
	TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:@"non-protocol-test"];
	NSString *uuid = [self.universalRegistry registerObject:obj];
	
	XCTAssertNotNil(uuid);
	XCTAssertEqual(self.universalRegistry.registeredObjectsCount, 1);
	XCTAssertTrue([self.universalRegistry isObjectRegistered:obj]);
	
	id retrievedObj = [self.universalRegistry registeredObjectForUUID:uuid];
	XCTAssertEqualObjects(retrievedObj, obj);
}

- (void)testUniversalRegistryMixedObjectTypes {
	TestProtocolObject *protocolObj = [[TestProtocolObject alloc] initWithIdentifier:@"protocol"];
	TestNonProtocolObject *nonProtocolObj = [[TestNonProtocolObject alloc] initWithIdentifier:@"non-protocol"];
	
	NSString *uuid1 = [self.universalRegistry registerObject:protocolObj];
	NSString *uuid2 = [self.universalRegistry registerObject:nonProtocolObj];
	
	XCTAssertNotNil(uuid1);
	XCTAssertNotNil(uuid2);
	XCTAssertNotEqualObjects(uuid1, uuid2);
	XCTAssertEqual(self.universalRegistry.registeredObjectsCount, 2);
	
	XCTAssertEqualObjects([self.universalRegistry registeredObjectForUUID:uuid1], protocolObj);
	XCTAssertEqualObjects([self.universalRegistry registeredObjectForUUID:uuid2], nonProtocolObj);
}

- (void)testUniversalRegistryProtocolRequirementToggle {
	TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:@"test"];
	
	// Should work with requireRegistryProtocol = NO (default)
	NSString *uuid = [self.universalRegistry registerObject:obj];
	XCTAssertNotNil(uuid);
	
	// Change requirement
	self.universalRegistry.requireRegistryProtocol = YES;
	
	// Should still work for already registered objects
	XCTAssertTrue([self.universalRegistry isObjectRegistered:obj]);
	
	// New non-protocol objects should fail
	TestNonProtocolObject *obj2 = [[TestNonProtocolObject alloc] initWithIdentifier:@"test2"];
	NSString *uuid2 = [self.universalRegistry registryUUIDForObject:obj2];
	XCTAssertNil(uuid2);
}

- (void)testUniversalRegistryCustomUUIDSupport {
	TestSpecializedCustomUUIDObject *obj = [[TestSpecializedCustomUUIDObject alloc] initWithCustomUUID:@"custom-uuid-123"];
	NSString *uuid = [self.universalRegistry registerObject:obj];
	
	XCTAssertEqualObjects(uuid, @"custom-uuid-123");
	XCTAssertEqualObjects([self.universalRegistry registeredObjectForUUID:@"custom-uuid-123"], obj);
}

- (void)testUniversalRegistryWeakReferences {
	NSString *uuid;
	@autoreleasepool {
		TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:@"weak-test"];
		uuid = [self.universalRegistry registerObject:obj];
		XCTAssertNotNil([self.universalRegistry registeredObjectForUUID:uuid]);
	}
	
	// Object should be deallocated and removed from registry
	XCTAssertNil([self.universalRegistry registeredObjectForUUID:uuid]);
}

- (void)testUniversalRegistryMultipleRegistrations {
	TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:@"multi-test"];
	
	NSString *uuid1 = [self.universalRegistry registerObject:obj];
	NSString *uuid2 = [self.universalRegistry registerObject:obj];
	
	XCTAssertEqualObjects(uuid1, uuid2);
	XCTAssertEqual([self.universalRegistry registeredCountForObject:obj], 2);
	
	// First unregister
	int result1 = [self.universalRegistry unregisterObject:obj];
	XCTAssertEqual(result1, 1); // Still registered but count decremented
	XCTAssertTrue([self.universalRegistry isObjectRegistered:obj]);
	
	// Second unregister
	int result2 = [self.universalRegistry unregisterObject:obj];
	XCTAssertEqual(result2, 2); // Completely removed
	XCTAssertFalse([self.universalRegistry isObjectRegistered:obj]);
}

- (void)testUniversalRegistryBulkOperations {
	TestProtocolObject *protocolObj = [[TestProtocolObject alloc] initWithIdentifier:@"protocol"];
	TestNonProtocolObject *nonProtocolObj = [[TestNonProtocolObject alloc] initWithIdentifier:@"non-protocol"];
	
	[self.universalRegistry registerObject:protocolObj];
	[self.universalRegistry registerObject:nonProtocolObj];
	
	XCTAssertEqual(self.universalRegistry.registeredObjectsCount, 2);
	
	// Clear objects without registry protocol
	[self.universalRegistry clearObjectsWithoutRegistryProtocol];
	
	XCTAssertEqual(self.universalRegistry.registeredObjectsCount, 1);
	XCTAssertTrue([self.universalRegistry isObjectRegistered:protocolObj]);
	XCTAssertFalse([self.universalRegistry isObjectRegistered:nonProtocolObj]);
}

- (void)testUniversalRegistryThreadSafety {
	NSMutableArray *objects = [NSMutableArray array];
	NSMutableArray *uuids = [NSMutableArray array];
	
	dispatch_group_t group = dispatch_group_create();
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	// Register objects concurrently
	for (int i = 0; i < 100; i++) {
		dispatch_group_async(group, queue, ^{
			TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:[NSString stringWithFormat:@"thread-test-%d", i]];
			@synchronized(objects) {
				[objects addObject:obj];
			}
			NSString *uuid = [self.universalRegistry registerObject:obj];
			@synchronized(uuids) {
				[uuids addObject:uuid];
			}
		});
	}
	
	dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
	
	XCTAssertEqual(objects.count, 100);
	XCTAssertEqual(uuids.count, 100);
	XCTAssertEqual(self.universalRegistry.registeredObjectsCount, 100);
	
	// All UUIDs should be unique
	NSSet *uniqueUUIDs = [NSSet setWithArray:uuids];
	XCTAssertEqual(uniqueUUIDs.count, 100);
}

@end

#pragma mark - BEStorageObjectRegistry Tests

@interface BEStorageObjectRegistryTests : XCTestCase
@property (nonatomic, strong) BEStorageObjectRegistry *storageRegistry;
@end

@implementation BEStorageObjectRegistryTests

- (void)setUp {
	[super setUp];
	self.storageRegistry = [[BEStorageObjectRegistry alloc] init];
}

- (void)tearDown {
	[self.storageRegistry clearAllRegisteredObjects:YES];
	self.storageRegistry = nil;
	[super tearDown];
}

#pragma mark - BEStorageObjectRegistry Specific Tests

- (void)testStorageRegistryInitialization {
	XCTAssertNotNil(self.storageRegistry);
	XCTAssertFalse(self.storageRegistry.requireRegistryProtocol, @"BEStorageObjectRegistry should not require registry protocol");
	XCTAssertEqual(self.storageRegistry.keySalt, 0);
	XCTAssertEqual(self.storageRegistry.registeredObjectsCount, 0);
}

- (void)testStorageRegistryValueOptions {
	NSPointerFunctionsOptions options = [BEStorageObjectRegistry valueOptions];
	XCTAssertEqual(options, NSPointerFunctionsStrongMemory, @"BEStorageObjectRegistry should use strong memory for values");
}

- (void)testStorageRegistryStrongReferences {
	NSString *uuid;
	@autoreleasepool {
		TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:@"strong-test"];
		uuid = [self.storageRegistry registerObject:obj];
		XCTAssertNotNil([self.storageRegistry registeredObjectForUUID:uuid]);
	}
	
	// Object should still be retained by the registry
	id retrievedObj = [self.storageRegistry registeredObjectForUUID:uuid];
	XCTAssertNotNil(retrievedObj);
	XCTAssertTrue([retrievedObj isKindOfClass:[TestNonProtocolObject class]]);
	XCTAssertEqualObjects(((TestNonProtocolObject *)retrievedObj).identifier, @"strong-test");
}

- (void)testStorageRegistryVsUniversalRegistryMemoryBehavior {
	BEUniversalObjectRegistry *universalRegistry = [[BEUniversalObjectRegistry alloc] init];
	
	NSString *storageUUID;
	NSString *universalUUID;
	
	@autoreleasepool {
		TestNonProtocolObject *storageObj = [[TestNonProtocolObject alloc] initWithIdentifier:@"storage-memory-test"];
		TestNonProtocolObject *universalObj = [[TestNonProtocolObject alloc] initWithIdentifier:@"universal-memory-test"];
		
		storageUUID = [self.storageRegistry registerObject:storageObj];
		universalUUID = [universalRegistry registerObject:universalObj];
		
		XCTAssertNotNil([self.storageRegistry registeredObjectForUUID:storageUUID]);
		XCTAssertNotNil([universalRegistry registeredObjectForUUID:universalUUID]);
	}
	
	// Storage registry should retain the object
	XCTAssertNotNil([self.storageRegistry registeredObjectForUUID:storageUUID]);
	
	// Universal registry should not retain the object (weak reference)
	XCTAssertNil([universalRegistry registeredObjectForUUID:universalUUID]);
	
	[universalRegistry clearAllRegisteredObjects:YES];
}

- (void)testStorageRegistryObjectLifecycle {
	TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:@"lifecycle-test"];
	NSString *uuid = [self.storageRegistry registerObject:obj];
	
	// Object should be retained by registry
	XCTAssertNotNil([self.storageRegistry registeredObjectForUUID:uuid]);
	
	// Release our reference
	obj = nil;
	
	// Object should still be available in registry
	id retrievedObj = [self.storageRegistry registeredObjectForUUID:uuid];
	XCTAssertNotNil(retrievedObj);
	
	// Unregister should release the object
	int result = [self.storageRegistry unregisterObject:retrievedObj];
	XCTAssertEqual(result, 2); // Completely removed
	
	// Object should no longer be available
	XCTAssertNil([self.storageRegistry registeredObjectForUUID:uuid]);
}

- (void)testStorageRegistryMultipleReferences {
	TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:@"multi-ref-test"];
	NSString *uuid = [self.storageRegistry registerObject:obj];
	
	// Register multiple times
	[self.storageRegistry registerObject:obj];
	[self.storageRegistry registerObject:obj];
	
	XCTAssertEqual([self.storageRegistry registeredCountForObject:obj], 3);
	
	// Release our reference
	obj = nil;
	
	// Object should still be available
	id retrievedObj = [self.storageRegistry registeredObjectForUUID:uuid];
	XCTAssertNotNil(retrievedObj);
	
	// Unregister twice
	[self.storageRegistry unregisterObject:retrievedObj];
	[self.storageRegistry unregisterObject:retrievedObj];
	
	// Object should still be available
	XCTAssertNotNil([self.storageRegistry registeredObjectForUUID:uuid]);
	
	// Final unregister
	int result = [self.storageRegistry unregisterObject:retrievedObj];
	XCTAssertEqual(result, 2); // Completely removed
	
	// Object should no longer be available
	XCTAssertNil([self.storageRegistry registeredObjectForUUID:uuid]);
}

- (void)testStorageRegistryBulkClear {
	NSMutableArray *objects = [NSMutableArray array];
	NSMutableArray *uuids = [NSMutableArray array];
	
	// Register multiple objects
	for (int i = 0; i < 10; i++) {
		TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:[NSString stringWithFormat:@"bulk-test-%d", i]];
		[objects addObject:obj];
		NSString *uuid = [self.storageRegistry registerObject:obj];
		[uuids addObject:uuid];
	}
	
	XCTAssertEqual(self.storageRegistry.registeredObjectsCount, 10);
	
	// Clear our references
	[objects removeAllObjects];
	
	// All objects should still be available in storage registry
	for (NSString *uuid in uuids) {
		XCTAssertNotNil([self.storageRegistry registeredObjectForUUID:uuid]);
	}
	
	// Clear all registered objects
	[self.storageRegistry clearAllRegisteredObjects:YES];
	
	// All objects should be gone
	XCTAssertEqual(self.storageRegistry.registeredObjectsCount, 0);
	for (NSString *uuid in uuids) {
		XCTAssertNil([self.storageRegistry registeredObjectForUUID:uuid]);
	}
}

- (void)testStorageRegistryThreadSafetyWithStrongReferences {
	NSMutableArray *uuids = [NSMutableArray array];
	
	dispatch_group_t group = dispatch_group_create();
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	// Register objects concurrently
	for (int i = 0; i < 50; i++) {
		dispatch_group_async(group, queue, ^{
			@autoreleasepool {
				TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:[NSString stringWithFormat:@"thread-storage-test-%d", i]];
				NSString *uuid = [self.storageRegistry registerObject:obj];
				@synchronized(uuids) {
					[uuids addObject:uuid];
				}
			}
		});
	}
	
	dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
	
	XCTAssertEqual(uuids.count, 50);
	XCTAssertEqual(self.storageRegistry.registeredObjectsCount, 50);
	
	// All objects should still be available despite being out of scope
	for (NSString *uuid in uuids) {
		XCTAssertNotNil([self.storageRegistry registeredObjectForUUID:uuid]);
	}
}

- (void)testStorageRegistryCustomUUIDSupport {
	TestSpecializedCustomUUIDObject *obj = [[TestSpecializedCustomUUIDObject alloc] initWithCustomUUID:@"storage-custom-uuid-123"];
	NSString *uuid = [self.storageRegistry registerObject:obj];
	
	XCTAssertEqualObjects(uuid, @"storage-custom-uuid-123");
	
	// Release our reference
	obj = nil;
	
	// Object should still be available via custom UUID
	id retrievedObj = [self.storageRegistry registeredObjectForUUID:@"storage-custom-uuid-123"];
	XCTAssertNotNil(retrievedObj);
	XCTAssertTrue([retrievedObj conformsToProtocol:@protocol(CustomRegistryUUID)]);
}

- (void)testStorageRegistry_registerObjectPerformanceWithLargeDataset {
	NSMutableArray *uuids = [NSMutableArray array];
	
	__block int maxCount = 1000;
	__block int fullCount = 0;
	// Measure registration time
	[self measureBlock:^{
		
		for (int i = 0; i < maxCount; i++) {
			TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:[NSString stringWithFormat:@"perf-test-%d", i]];
			NSString *uuid = [self.storageRegistry registerObject:obj];
			[uuids addObject:uuid];
		}
		fullCount += maxCount;
	}];
	
	XCTAssertEqual(self.storageRegistry.registeredObjectsCount, fullCount);
	
}

- (void)testStorageRegistry_retreivePerformanceWithLargeDataset {
	NSMutableArray *uuids = [NSMutableArray array];
	
	__block int maxCount = 1000;
	// Measure registration time
		
	for (int i = 0; i < maxCount; i++) {
		TestNonProtocolObject *obj = [[TestNonProtocolObject alloc] initWithIdentifier:[NSString stringWithFormat:@"perf-test-%d", i]];
		NSString *uuid = [self.storageRegistry registerObject:obj];
		[uuids addObject:uuid];
	}
	
	// Test retrieval performance
	[self measureBlock:^{
		for (NSString *uuid in uuids) {
			id obj = [self.storageRegistry registeredObjectForUUID:uuid];
			XCTAssertNotNil(obj);
		}
	}];
}

@end
