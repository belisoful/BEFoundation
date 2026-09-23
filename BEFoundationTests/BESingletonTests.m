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
	[self cleanupSingletonInstances];
}

- (void)tearDown {
	[self cleanupSingletonInstances];
	[super tearDown];
}

- (void)cleanupSingletonInstances {
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
	XCTAssertFalse([NSObject isSingleton], @"NSObject should return NO for isSingleton");
	
	XCTAssertFalse([TestPlainClass isSingleton], @"Plain class should return NO for isSingleton");
}

- (void)testIsSingletonProtocolImplementation {
	XCTAssertTrue([TestSingleton isSingleton], @"TestSingleton should return YES for isSingleton");
	XCTAssertFalse([TestNonSingleton isSingleton], @"TestNonSingleton should return NO for isSingleton");
}

- (void)testSingletonCreation {
	TestSingleton *instance1 = [TestSingleton sharedInstance];
	XCTAssertNotNil(instance1, @"Singleton instance should not be nil");
	XCTAssertTrue([instance1 isKindOfClass:[TestSingleton class]], @"Instance should be of correct type");
	
	XCTAssertTrue(instance1.initForSingletonCalled, @"initForSingleton should be called");
	XCTAssertEqualObjects(instance1.testProperty, @"singleton_initialized", @"Property should be set by initForSingleton");
}

- (void)testSingletonUniqueness {
	TestSingleton *instance1 = [TestSingleton sharedInstance];
	TestSingleton *instance2 = [TestSingleton sharedInstance];
	TestSingleton *instance3 = [TestSingleton __BESingleton];
	
	XCTAssertEqual(instance1, instance2, @"Multiple calls should return same instance");
	XCTAssertEqual(instance1, instance3, @"Direct __BESingleton call should return same instance");
	
	instance1.testProperty = @"modified";
	XCTAssertEqualObjects(instance2.testProperty, @"modified", @"All references should point to same object");
}

- (void)testNonSingletonBehavior {
	TestNonSingleton *instance = [TestNonSingleton __BESingleton];
	XCTAssertNil(instance, @"Non-singleton should return nil from __BESingleton");
}

- (void)testPlainClassBehavior {
	TestPlainClass *instance = [TestPlainClass __BESingleton];
	XCTAssertNil(instance, @"Plain class should return nil from __BESingleton");
}

- (void)testSingletonWithoutCustomInit {
	TestSingletonNoCustomInit *instance = [TestSingletonNoCustomInit sharedInstance];
	XCTAssertNotNil(instance, @"Singleton without custom init should work");
	XCTAssertEqualObjects(instance.testProperty, @"plain_init", @"Should use regular init method");
	
	TestSingletonNoCustomInit *instance2 = [TestSingletonNoCustomInit sharedInstance];
	XCTAssertEqual(instance, instance2, @"Should still maintain singleton behavior");
}

#pragma mark - Singleton Init Info Tests

- (void)testSingletonInitInfoDefault {
	NSDictionary *initInfo = [TestSingleton singletonInitInfo];
	XCTAssertNil(initInfo, @"Default singletonInitInfo should be nil");
}

- (void)testSingletonInitInfoSetting {
	NSDictionary *testInfo = @{@"key1": @"value1", @"key2": @42};
	[TestSingleton setSingletonInitInfo:testInfo];
	
	NSDictionary *retrievedInfo = [TestSingleton singletonInitInfo];
	XCTAssertEqualObjects(retrievedInfo, testInfo, @"Retrieved init info should match set info");
}

- (void)testSingletonInitInfoPassedToInit {
	NSDictionary *testInfo = @{@"testKey": @"testValue", @"number": @123};
	[TestSingleton setSingletonInitInfo:testInfo];
	
	TestSingleton *instance = [TestSingleton sharedInstance];
	XCTAssertEqualObjects(instance.receivedInitInfo, testInfo, @"initForSingleton should receive the init info");
}

- (void)testSingletonInitInfoIgnoredAfterCreation {
	TestSingleton *instance = [TestSingleton sharedInstance];
	NSDictionary *originalInfo = instance.receivedInitInfo;
	
	NSDictionary *newInfo = @{@"ignored": @"value"};
	[TestSingleton setSingletonInitInfo:newInfo];
	
	XCTAssertEqualObjects(instance.receivedInitInfo, originalInfo, @"Init info should not change after singleton creation");
	
	TestSingleton *instance2 = [TestSingleton sharedInstance];
	XCTAssertEqual(instance, instance2, @"Should still return same singleton instance");
}

- (void)testSingletonInitInfoNilSetting {
	[TestSingleton setSingletonInitInfo:@{@"key": @"value"}];
	XCTAssertNotNil([TestSingleton singletonInitInfo], @"Init info should be set");
	
	[TestSingleton setSingletonInitInfo:nil];
	XCTAssertNil([TestSingleton singletonInitInfo], @"Init info should be cleared");
}

- (void)testSingletonInitInfoOnNonSingleton {
	[TestNonSingleton setSingletonInitInfo:@{@"key": @"value"}];
	NSDictionary *info = [TestNonSingleton singletonInitInfo];
	XCTAssertNil(info, @"Non-singleton class should not store init info");
}

- (void)testSingletonInitInfoNonDictionaryType {
	// Test the edge case where non-dictionary data is stored as init info
	// This tests the condition: if (![instanceInfo isKindOfClass:NSDictionary.class])
	
	NSString *nonDictionaryInfo = @"This is not a dictionary";
	objc_setAssociatedObject([TestSingleton class], @selector(singletonInitInfo), nonDictionaryInfo, OBJC_ASSOCIATION_RETAIN);
	
	id retrievedInfo = [TestSingleton singletonInitInfo];
	XCTAssertEqualObjects(retrievedInfo, nonDictionaryInfo, @"Non-dictionary init info should be returned as-is");
	XCTAssertTrue([retrievedInfo isKindOfClass:[NSString class]], @"Should return the original string object");
	XCTAssertFalse([retrievedInfo isKindOfClass:[NSDictionary class]], @"Should not be a dictionary");
	
	NSNumber *numberInfo = @42;
	objc_setAssociatedObject([TestSingletonNoCustomInit class], @selector(singletonInitInfo), numberInfo, OBJC_ASSOCIATION_RETAIN);
	
	id retrievedNumberInfo = [TestSingletonNoCustomInit singletonInitInfo];
	XCTAssertEqualObjects(retrievedNumberInfo, numberInfo, @"Non-dictionary number should be returned as-is");
	XCTAssertTrue([retrievedNumberInfo isKindOfClass:[NSNumber class]], @"Should return the original number object");
	
	NSArray *arrayInfo = @[@"item1", @"item2"];
	objc_setAssociatedObject([TestSingletonChild class], @selector(singletonInitInfo), arrayInfo, OBJC_ASSOCIATION_RETAIN);
	
	id retrievedArrayInfo = [TestSingletonChild singletonInitInfo];
	XCTAssertEqualObjects(retrievedArrayInfo, arrayInfo, @"Non-dictionary array should be returned as-is");
	XCTAssertTrue([retrievedArrayInfo isKindOfClass:[NSArray class]], @"Should return the original array object");
}

- (void)testSingletonCreationWithNonDictionaryInitInfo {
	NSString *stringInitInfo = @"Custom init string";
	objc_setAssociatedObject([TestSingletonFlexibleInit class], @selector(singletonInitInfo), stringInitInfo, OBJC_ASSOCIATION_RETAIN);
	
	TestSingletonFlexibleInit *instance = [TestSingletonFlexibleInit sharedInstance];
	XCTAssertNotNil(instance, @"Singleton should be created");
	XCTAssertTrue(instance.initForSingletonCalled, @"initForSingleton should be called");
	XCTAssertEqualObjects(instance.receivedInitInfo, stringInitInfo, @"Should receive the non-dictionary init info");
	
	TestSingletonFlexibleInit *instance2 = [TestSingletonFlexibleInit sharedInstance];
	XCTAssertEqual(instance, instance2, @"Should return same singleton instance");
}

#pragma mark - Inheritance Tests

- (void)testSingletonInheritance {
	TestSingletonChild *child = [TestSingletonChild __BESingleton];
	XCTAssertNotNil(child, @"Child singleton should be created");
	XCTAssertTrue([child isKindOfClass:[TestSingletonChild class]], @"Should be child class instance");
	
	XCTAssertEqualObjects(child.testProperty, @"singleton_initialized", @"Parent init should run");
	XCTAssertEqualObjects(child.childProperty, @"child_singleton_init", @"Child init should run");
}

- (void)testSingletonInheritanceUniqueness {
	TestSingleton *parent = [TestSingleton sharedInstance];
	TestSingletonChild *child = [TestSingletonChild __BESingleton];
	
	XCTAssertNotEqual(parent, child, @"Parent and child should have separate instances");
	XCTAssertTrue([parent isMemberOfClass:[TestSingleton class]], @"Parent should be exact parent class");
	XCTAssertTrue([child isMemberOfClass:[TestSingletonChild class]], @"Child should be exact child class");
}

- (void)testNonSingletonChildOfSingleton {
	TestNonSingletonChild *instance = [TestNonSingletonChild __BESingleton];
	XCTAssertNil(instance, @"Non-singleton child should return nil even if parent is singleton");
}

- (void)testInheritanceInitInfoMerging {
	NSDictionary *parentInfo = @{@"parent": @"parentValue", @"shared": @"parentShared"};
	NSDictionary *childInfo = @{@"child": @"childValue", @"shared": @"childShared"};
	
	[TestSingleton setSingletonInitInfo:parentInfo];
	[TestSingletonChild setSingletonInitInfo:childInfo];
	
	TestSingletonChild *child = [TestSingletonChild __BESingleton];
	
	NSDictionary *expectedMerged = @{
		@"parent": @"parentValue",
		@"child": @"childValue",
		@"shared": @"childShared"  // Child should override parent
	};
	
	// Note: The exact behavior depends on the mergeEntriesFromDictionary implementation
	// This test assumes child info takes precedence
	XCTAssertNotNil(child.receivedInitInfo, @"Child should receive merged init info");
	
	XCTAssertEqualObjects(child.receivedInitInfo, expectedMerged);
}

#pragma mark - Thread Safety Tests

- (void)testConcurrentSingletonCreation {
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
	
	TestSingleton *firstInstance = instances.firstObject;
	for (TestSingleton *instance in instances) {
		XCTAssertEqual(instance, firstInstance, @"All concurrent instances should be identical");
	}
	
	XCTAssertEqual(instances.count, numThreads, @"Should have collected all instances");
}

- (void)testConcurrentInitInfoAccess {
	XCTestExpectation *setExpectation = [self expectationWithDescription:@"Set init info"];
	XCTestExpectation *getExpectation = [self expectationWithDescription:@"Get init info"];
	
	__block NSDictionary *retrievedInfo = nil;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[TestSingleton setSingletonInitInfo:@{@"concurrent": @"test"}];
		[setExpectation fulfill];
	});
	
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
	XCTAssertTrue([TestSingleton conformsToProtocol:@protocol(BESingleton)], @"Should conform to BESingleton");
	
	TestSingleton *instance = [TestSingleton sharedInstance];
	XCTAssertNotNil(instance, @"Multi-protocol conforming class should work");
}

- (void)testRespondsToSelectorFix {
	
	id testInstance = [TestSingleton.alloc init];
	XCTAssertTrue([testInstance respondsToSelector:@selector(initForSingleton:)],
				  @"Instance should respond to initForSingleton:");
	
	XCTAssertFalse([TestSingleton respondsToSelector:@selector(initForSingleton:)],
				   @"Class should not respond to instance method initForSingleton:");
	
	TestSingleton *singleton = [TestSingleton sharedInstance];
	XCTAssertTrue(singleton.initForSingletonCalled,
				  @"initForSingleton should have been called with corrected selector check");
}

- (void)testMemoryManagement {
	@autoreleasepool {
		TestSingleton *instance = [TestSingleton sharedInstance];
		XCTAssertNotNil(instance, @"Instance should exist");
		
		// The instance should persist beyond the autorelease pool
		// since it's retained by the associated object mechanism
	}
	
	TestSingleton *instance2 = [TestSingleton sharedInstance];
	XCTAssertNotNil(instance2, @"Instance should persist");
}

- (void)testClassMethodOverride {
	XCTAssertTrue([TestSingleton isSingleton], @"Overridden method should return YES");
	XCTAssertFalse([TestNonSingleton isSingleton], @"Overridden method should return NO");
}

#pragma mark - Performance Tests

- (void)testSingletonPerformance {
	[self measureBlock:^{
		for (int i = 0; i < 1000; i++) {
			TestSingleton *instance = [TestSingleton sharedInstance];
			(void)instance; // Suppress unused variable warning
		}
	}];
}

- (void)testInitInfoPerformance {
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
	
	NSDictionary *initInfo = @{
		@"workflow": @"test",
		@"step": @1,
		@"data": @[@"a", @"b", @"c"]
	};
	[TestSingleton setSingletonInitInfo:initInfo];
	
	TestSingleton *instance = [TestSingleton sharedInstance];
	XCTAssertNotNil(instance, @"Singleton should be created");
	
	XCTAssertEqualObjects(instance.receivedInitInfo, initInfo, @"Init info should be passed correctly");
	
	TestSingleton *instance2 = [TestSingleton sharedInstance];
	XCTAssertEqual(instance, instance2, @"Should return same instance");
	
	instance.testProperty = @"workflow_modified";
	XCTAssertEqualObjects(instance2.testProperty, @"workflow_modified", @"Property should be shared");
	
	[TestSingleton setSingletonInitInfo:@{@"ignored": @"value"}];
	TestSingleton *instance3 = [TestSingleton sharedInstance];
	XCTAssertEqual(instance, instance3, @"Should still return original instance");
}

@end
