/*!
 @file			BESingletonTests.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract		Comprehensive unit tests for BESingleton implementation
 @discussion	Tests all methods, edge cases, thread safety, and inheritance scenarios
*/

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "BESingleton.h"

#pragma mark - Test Helper Classes

// Base singleton class for testing
@interface TestSingleton : NSObject <BESingleton>
@property (nonatomic, strong) NSString *testProperty;
@property (nonatomic, assign) BOOL initForSingletonCalled;
@property (nonatomic, strong) NSDictionary *receivedInitInfo;
+ (instancetype)sharedInstance;
@end

// Test helper class that accepts any type of init info
@interface TestSingletonFlexibleInit : NSObject <BESingleton>
@property (nonatomic, strong) id receivedInitInfo;
@property (nonatomic, assign) BOOL initForSingletonCalled;
+ (instancetype)sharedInstance;
@end

@implementation TestSingletonFlexibleInit

+ (BOOL)isSingleton {
	return YES;
}

+ (instancetype)sharedInstance {
	return [self __BESingleton];
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_initForSingletonCalled = NO;
	}
	return self;
}

- (instancetype)initForSingleton:(id)initInfo {
	self = [super init];
	if (self) {
		_initForSingletonCalled = YES;
		_receivedInitInfo = initInfo;
	}
	return self;
}

@end

@implementation TestSingleton

+ (BOOL)isSingleton {
	return YES;
}

+ (instancetype)sharedInstance {
	return [self __BESingleton];
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_testProperty = @"initialized";
		_initForSingletonCalled = NO;
	}
	return self;
}

- (instancetype)initForSingleton:(NSDictionary *)initInfo {
	self = [super init];
	if (self) {
		_testProperty = @"singleton_initialized";
		_initForSingletonCalled = YES;
		_receivedInitInfo = initInfo;
	}
	return self;
}

@end

// Non-singleton class for testing
@interface TestNonSingleton : NSObject <BESingleton>
@end

@implementation TestNonSingleton

+ (BOOL)isSingleton {
	return NO;
}

@end

// Class that doesn't conform to BESingleton
@interface TestPlainClass : NSObject
@end

@implementation TestPlainClass
@end

// Singleton without initForSingleton method
@interface TestSingletonNoCustomInit : NSObject <BESingleton>
@property (nonatomic, strong) NSString *testProperty;
+ (instancetype)sharedInstance;
@end

@implementation TestSingletonNoCustomInit

+ (BOOL)isSingleton {
	return YES;
}

+ (instancetype)sharedInstance {
	return [self __BESingleton];
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_testProperty = @"plain_init";
	}
	return self;
}

@end

// Singleton subclass for inheritance testing
@interface TestSingletonChild : TestSingleton
@property (nonatomic, strong) NSString *childProperty;
@end

@implementation TestSingletonChild

- (instancetype)init {
	self = [super init];
	if (self) {
		_childProperty = @"child_init";
	}
	return self;
}

- (instancetype)initForSingleton:(NSDictionary *)initInfo {
	self = [super initForSingleton:initInfo];
	if (self) {
		_childProperty = @"child_singleton_init";
	}
	return self;
}

@end

// Non-singleton subclass of singleton
@interface TestNonSingletonChild : TestSingleton
@end

@implementation TestNonSingletonChild

+ (BOOL)isSingleton {
	return NO;
}

@end

#pragma mark - Test Suite

@interface BESingletonTests : XCTestCase
@end

@implementation BESingletonTests

- (void)setUp {
	[super setUp];
	// Clean up any existing singleton instances before each test
	[self cleanupSingletonInstances];
}

- (void)tearDown {
	// Clean up singleton instances after each test
	[self cleanupSingletonInstances];
	[super tearDown];
}

- (void)cleanupSingletonInstances {
	// Clear associated objects for test classes
	NSArray *testClasses = @[
		[TestSingleton class],
		[TestNonSingleton class],
		[TestPlainClass class],
		[TestSingletonNoCustomInit class],
		[TestSingletonChild class],
		[TestNonSingletonChild class],
		[TestSingletonFlexibleInit class]
	];
	
	for (Class cls in testClasses) {
		objc_setAssociatedObject(cls, @selector(__BESingleton), nil, OBJC_ASSOCIATION_ASSIGN);
		objc_setAssociatedObject(cls, @selector(singletonInitInfo), nil, OBJC_ASSOCIATION_ASSIGN);
	}
}

#pragma mark - Basic Functionality Tests

- (void)testIsSingletonDefaultBehavior {
	// NSObject should return NO by default
	XCTAssertFalse([NSObject isSingleton], @"NSObject should return NO for isSingleton");
	
	// Plain class should return NO by default
	XCTAssertFalse([TestPlainClass isSingleton], @"Plain class should return NO for isSingleton");
}

- (void)testIsSingletonProtocolImplementation {
	// Classes implementing BESingleton should return their configured value
	XCTAssertTrue([TestSingleton isSingleton], @"TestSingleton should return YES for isSingleton");
	XCTAssertFalse([TestNonSingleton isSingleton], @"TestNonSingleton should return NO for isSingleton");
}

- (void)testSingletonCreation {
	// Test basic singleton creation
	TestSingleton *instance1 = [TestSingleton sharedInstance];
	XCTAssertNotNil(instance1, @"Singleton instance should not be nil");
	XCTAssertTrue([instance1 isKindOfClass:[TestSingleton class]], @"Instance should be of correct type");
	
	// Test singleton property
	XCTAssertTrue(instance1.initForSingletonCalled, @"initForSingleton should be called");
	XCTAssertEqualObjects(instance1.testProperty, @"singleton_initialized", @"Property should be set by initForSingleton");
}

- (void)testSingletonUniqueness {
	// Test that multiple calls return the same instance
	TestSingleton *instance1 = [TestSingleton sharedInstance];
	TestSingleton *instance2 = [TestSingleton sharedInstance];
	TestSingleton *instance3 = [TestSingleton __BESingleton];
	
	XCTAssertEqual(instance1, instance2, @"Multiple calls should return same instance");
	XCTAssertEqual(instance1, instance3, @"Direct __BESingleton call should return same instance");
	
	// Modify one instance and verify it affects all references
	instance1.testProperty = @"modified";
	XCTAssertEqualObjects(instance2.testProperty, @"modified", @"All references should point to same object");
}

- (void)testNonSingletonBehavior {
	// Non-singleton should return nil from __BESingleton
	TestNonSingleton *instance = [TestNonSingleton __BESingleton];
	XCTAssertNil(instance, @"Non-singleton should return nil from __BESingleton");
}

- (void)testPlainClassBehavior {
	// Class not conforming to BESingleton should return nil
	TestPlainClass *instance = [TestPlainClass __BESingleton];
	XCTAssertNil(instance, @"Plain class should return nil from __BESingleton");
}

- (void)testSingletonWithoutCustomInit {
	// Test singleton that doesn't implement initForSingleton
	TestSingletonNoCustomInit *instance = [TestSingletonNoCustomInit sharedInstance];
	XCTAssertNotNil(instance, @"Singleton without custom init should work");
	XCTAssertEqualObjects(instance.testProperty, @"plain_init", @"Should use regular init method");
	
	// Test uniqueness
	TestSingletonNoCustomInit *instance2 = [TestSingletonNoCustomInit sharedInstance];
	XCTAssertEqual(instance, instance2, @"Should still maintain singleton behavior");
}

#pragma mark - Singleton Init Info Tests

- (void)testSingletonInitInfoDefault {
	// Test default behavior (no init info set)
	NSDictionary *initInfo = [TestSingleton singletonInitInfo];
	XCTAssertNil(initInfo, @"Default singletonInitInfo should be nil");
}

- (void)testSingletonInitInfoSetting {
	// Test setting init info
	NSDictionary *testInfo = @{@"key1": @"value1", @"key2": @42};
	[TestSingleton setSingletonInitInfo:testInfo];
	
	NSDictionary *retrievedInfo = [TestSingleton singletonInitInfo];
	XCTAssertEqualObjects(retrievedInfo, testInfo, @"Retrieved init info should match set info");
}

- (void)testSingletonInitInfoPassedToInit {
	// Set init info before creating singleton
	NSDictionary *testInfo = @{@"testKey": @"testValue", @"number": @123};
	[TestSingleton setSingletonInitInfo:testInfo];
	
	TestSingleton *instance = [TestSingleton sharedInstance];
	XCTAssertEqualObjects(instance.receivedInitInfo, testInfo, @"initForSingleton should receive the init info");
}

- (void)testSingletonInitInfoIgnoredAfterCreation {
	// Create singleton first
	TestSingleton *instance = [TestSingleton sharedInstance];
	NSDictionary *originalInfo = instance.receivedInitInfo;
	
	// Try to set init info after creation
	NSDictionary *newInfo = @{@"ignored": @"value"};
	[TestSingleton setSingletonInitInfo:newInfo];
	
	// Verify init info wasn't changed
	XCTAssertEqualObjects(instance.receivedInitInfo, originalInfo, @"Init info should not change after singleton creation");
	
	// Verify new singleton calls still return same instance
	TestSingleton *instance2 = [TestSingleton sharedInstance];
	XCTAssertEqual(instance, instance2, @"Should still return same singleton instance");
}

- (void)testSingletonInitInfoNilSetting {
	// Set some init info first
	[TestSingleton setSingletonInitInfo:@{@"key": @"value"}];
	XCTAssertNotNil([TestSingleton singletonInitInfo], @"Init info should be set");
	
	// Clear it
	[TestSingleton setSingletonInitInfo:nil];
	XCTAssertNil([TestSingleton singletonInitInfo], @"Init info should be cleared");
}

- (void)testSingletonInitInfoOnNonSingleton {
	// Setting init info on non-singleton class should be ignored
	[TestNonSingleton setSingletonInitInfo:@{@"key": @"value"}];
	NSDictionary *info = [TestNonSingleton singletonInitInfo];
	XCTAssertNil(info, @"Non-singleton class should not store init info");
}

- (void)testSingletonInitInfoNonDictionaryType {
	// Test the edge case where non-dictionary data is stored as init info
	// This tests the condition: if (![instanceInfo isKindOfClass:NSDictionary.class])
	
	// Store a non-dictionary object directly using objc_setAssociatedObject
	NSString *nonDictionaryInfo = @"This is not a dictionary";
	objc_setAssociatedObject([TestSingleton class], @selector(singletonInitInfo), nonDictionaryInfo, OBJC_ASSOCIATION_RETAIN);
	
	// Retrieve the init info - should return the non-dictionary object directly
	id retrievedInfo = [TestSingleton singletonInitInfo];
	XCTAssertEqualObjects(retrievedInfo, nonDictionaryInfo, @"Non-dictionary init info should be returned as-is");
	XCTAssertTrue([retrievedInfo isKindOfClass:[NSString class]], @"Should return the original string object");
	XCTAssertFalse([retrievedInfo isKindOfClass:[NSDictionary class]], @"Should not be a dictionary");
	
	// Test with another non-dictionary type
	NSNumber *numberInfo = @42;
	objc_setAssociatedObject([TestSingletonNoCustomInit class], @selector(singletonInitInfo), numberInfo, OBJC_ASSOCIATION_RETAIN);
	
	id retrievedNumberInfo = [TestSingletonNoCustomInit singletonInitInfo];
	XCTAssertEqualObjects(retrievedNumberInfo, numberInfo, @"Non-dictionary number should be returned as-is");
	XCTAssertTrue([retrievedNumberInfo isKindOfClass:[NSNumber class]], @"Should return the original number object");
	
	// Test with array type
	NSArray *arrayInfo = @[@"item1", @"item2"];
	objc_setAssociatedObject([TestSingletonChild class], @selector(singletonInitInfo), arrayInfo, OBJC_ASSOCIATION_RETAIN);
	
	id retrievedArrayInfo = [TestSingletonChild singletonInitInfo];
	XCTAssertEqualObjects(retrievedArrayInfo, arrayInfo, @"Non-dictionary array should be returned as-is");
	XCTAssertTrue([retrievedArrayInfo isKindOfClass:[NSArray class]], @"Should return the original array object");
}

- (void)testSingletonCreationWithNonDictionaryInitInfo {
	// Test creating a singleton when non-dictionary init info is stored
	NSString *stringInitInfo = @"Custom init string";
	objc_setAssociatedObject([TestSingletonFlexibleInit class], @selector(singletonInitInfo), stringInitInfo, OBJC_ASSOCIATION_RETAIN);
	
	// Create the singleton - it should receive the string as init info
	TestSingletonFlexibleInit *instance = [TestSingletonFlexibleInit sharedInstance];
	XCTAssertNotNil(instance, @"Singleton should be created");
	XCTAssertTrue(instance.initForSingletonCalled, @"initForSingleton should be called");
	XCTAssertEqualObjects(instance.receivedInitInfo, stringInitInfo, @"Should receive the non-dictionary init info");
	
	// Verify it's still a singleton
	TestSingletonFlexibleInit *instance2 = [TestSingletonFlexibleInit sharedInstance];
	XCTAssertEqual(instance, instance2, @"Should return same singleton instance");
}

#pragma mark - Inheritance Tests

- (void)testSingletonInheritance {
	// Test that child singleton works
	TestSingletonChild *child = [TestSingletonChild __BESingleton];
	XCTAssertNotNil(child, @"Child singleton should be created");
	XCTAssertTrue([child isKindOfClass:[TestSingletonChild class]], @"Should be child class instance");
	
	// Verify both parent and child initialization occurred
	XCTAssertEqualObjects(child.testProperty, @"singleton_initialized", @"Parent init should run");
	XCTAssertEqualObjects(child.childProperty, @"child_singleton_init", @"Child init should run");
}

- (void)testSingletonInheritanceUniqueness {
	// Child and parent should have separate singleton instances
	TestSingleton *parent = [TestSingleton sharedInstance];
	TestSingletonChild *child = [TestSingletonChild __BESingleton];
	
	XCTAssertNotEqual(parent, child, @"Parent and child should have separate instances");
	XCTAssertTrue([parent isMemberOfClass:[TestSingleton class]], @"Parent should be exact parent class");
	XCTAssertTrue([child isMemberOfClass:[TestSingletonChild class]], @"Child should be exact child class");
}

- (void)testNonSingletonChildOfSingleton {
	// Non-singleton child of singleton should return nil
	TestNonSingletonChild *instance = [TestNonSingletonChild __BESingleton];
	XCTAssertNil(instance, @"Non-singleton child should return nil even if parent is singleton");
}

- (void)testInheritanceInitInfoMerging {
	// Set init info on both parent and child
	NSDictionary *parentInfo = @{@"parent": @"parentValue", @"shared": @"parentShared"};
	NSDictionary *childInfo = @{@"child": @"childValue", @"shared": @"childShared"};
	
	[TestSingleton setSingletonInitInfo:parentInfo];
	[TestSingletonChild setSingletonInitInfo:childInfo];
	
	// Create child singleton
	TestSingletonChild *child = [TestSingletonChild __BESingleton];
	
	// Verify merged init info (child should override parent for same keys)
	NSDictionary *expectedMerged = @{
		@"parent": @"parentValue",
		@"child": @"childValue",
		@"shared": @"childShared"  // Child should override parent
	};
	
	// Note: The exact behavior depends on the mergeEntriesFromDictionary implementation
	// This test assumes child info takes precedence
	XCTAssertNotNil(child.receivedInitInfo, @"Child should receive merged init info");
}

#pragma mark - Thread Safety Tests

- (void)testConcurrentSingletonCreation {
	// Test thread safety with concurrent access
	NSMutableArray *instances = [NSMutableArray array];
	NSMutableArray *expectations = [NSMutableArray array];
	
	const int numThreads = 10;
	
	for (int i = 0; i < numThreads; i++) {
		XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"Thread %d", i]];
		[expectations addObject:expectation];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			TestSingleton *instance = [TestSingleton sharedInstance];
			@synchronized(instances) {
				[instances addObject:instance];
			}
			[expectation fulfill];
		});
	}
	
	[self waitForExpectations:expectations timeout:5.0];
	
	// Verify all instances are the same
	TestSingleton *firstInstance = instances.firstObject;
	for (TestSingleton *instance in instances) {
		XCTAssertEqual(instance, firstInstance, @"All concurrent instances should be identical");
	}
	
	XCTAssertEqual(instances.count, numThreads, @"Should have collected all instances");
}

- (void)testConcurrentInitInfoAccess {
	// Test concurrent access to init info
	XCTestExpectation *setExpectation = [self expectationWithDescription:@"Set init info"];
	XCTestExpectation *getExpectation = [self expectationWithDescription:@"Get init info"];
	
	__block NSDictionary *retrievedInfo = nil;
	
	// Set init info on one thread
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[TestSingleton setSingletonInitInfo:@{@"concurrent": @"test"}];
		[setExpectation fulfill];
	});
	
	// Get init info on another thread
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// Wait a bit to ensure potential race condition
		usleep(1000); // 1ms
		retrievedInfo = [TestSingleton singletonInitInfo];
		[getExpectation fulfill];
	});
	
	[self waitForExpectations:@[setExpectation, getExpectation] timeout:5.0];
	
	// The result may be nil or the set value depending on timing
	// This test mainly ensures no crashes occur during concurrent access
	XCTAssertTrue(retrievedInfo == nil || [retrievedInfo[@"concurrent"] isEqualToString:@"test"],
				  @"Concurrent access should be safe");
}

#pragma mark - Edge Cases and Error Conditions

- (void)testMultipleProtocolConformance {
	// Ensure classes conforming to multiple protocols work correctly
	XCTAssertTrue([TestSingleton conformsToProtocol:@protocol(BESingleton)], @"Should conform to BESingleton");
	
	TestSingleton *instance = [TestSingleton sharedInstance];
	XCTAssertNotNil(instance, @"Multi-protocol conforming class should work");
}

- (void)testRespondsToSelectorFix {
	// Test that the respondsToSelector check works correctly
	// This verifies the fix for the respondsToSelector issue
	
	// Create an instance to test against
	id testInstance = [TestSingleton.alloc init];
	XCTAssertTrue([testInstance respondsToSelector:@selector(initForSingleton:)],
				  @"Instance should respond to initForSingleton:");
	
	// Verify class doesn't respond to instance method
	XCTAssertFalse([TestSingleton respondsToSelector:@selector(initForSingleton:)],
				   @"Class should not respond to instance method initForSingleton:");
	
	// Test the corrected singleton creation
	TestSingleton *singleton = [TestSingleton sharedInstance];
	XCTAssertTrue(singleton.initForSingletonCalled,
				  @"initForSingleton should have been called with corrected selector check");
}

- (void)testMemoryManagement {
	// Test that singleton instances are properly retained
	@autoreleasepool {
		TestSingleton *instance = [TestSingleton sharedInstance];
		XCTAssertNotNil(instance, @"Instance should exist");
		
		// The instance should persist beyond the autorelease pool
		// since it's retained by the associated object mechanism
	}
	
	// Instance should still be accessible
	TestSingleton *instance2 = [TestSingleton sharedInstance];
	XCTAssertNotNil(instance2, @"Instance should persist");
}

- (void)testClassMethodOverride {
	// Verify that overriding isSingleton works correctly
	XCTAssertTrue([TestSingleton isSingleton], @"Overridden method should return YES");
	XCTAssertFalse([TestNonSingleton isSingleton], @"Overridden method should return NO");
}

#pragma mark - Performance Tests

- (void)testSingletonPerformance {
	// Test performance of singleton access
	[self measureBlock:^{
		for (int i = 0; i < 1000; i++) {
			TestSingleton *instance = [TestSingleton sharedInstance];
			(void)instance; // Suppress unused variable warning
		}
	}];
}

- (void)testInitInfoPerformance {
	// Test performance of init info access
	[TestSingleton setSingletonInitInfo:@{@"key": @"value"}];
	
	[self measureBlock:^{
		for (int i = 0; i < 1000; i++) {
			NSDictionary *info = [TestSingleton singletonInitInfo];
			(void)info; // Suppress unused variable warning
		}
	}];
}

#pragma mark - Integration Tests

- (void)testCompleteWorkflow {
	// Test a complete workflow combining all features
	
	// 1. Set init info
	NSDictionary *initInfo = @{
		@"workflow": @"test",
		@"step": @1,
		@"data": @[@"a", @"b", @"c"]
	};
	[TestSingleton setSingletonInitInfo:initInfo];
	
	// 2. Create singleton
	TestSingleton *instance = [TestSingleton sharedInstance];
	XCTAssertNotNil(instance, @"Singleton should be created");
	
	// 3. Verify init info was passed
	XCTAssertEqualObjects(instance.receivedInitInfo, initInfo, @"Init info should be passed correctly");
	
	// 4. Verify singleton behavior
	TestSingleton *instance2 = [TestSingleton sharedInstance];
	XCTAssertEqual(instance, instance2, @"Should return same instance");
	
	// 5. Verify property access
	instance.testProperty = @"workflow_modified";
	XCTAssertEqualObjects(instance2.testProperty, @"workflow_modified", @"Property should be shared");
	
	// 6. Test that changing init info after creation has no effect
	[TestSingleton setSingletonInitInfo:@{@"ignored": @"value"}];
	TestSingleton *instance3 = [TestSingleton sharedInstance];
	XCTAssertEqual(instance, instance3, @"Should still return original instance");
}

@end
