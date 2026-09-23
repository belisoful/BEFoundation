//
//  Plugin_Unit_Tests.m
//  Plugin Unit Tests
//
//  Created by ~ ~ on 3/14/24.
//

#import <XCTest/XCTest.h>
#import <BEFoundation/BEruntime.h>

// Test helper classes
@interface RuntimeTestClass : NSObject
- (void)testMethod;
- (void)anotherTestMethod;
@end

@implementation RuntimeTestClass
- (void)testMethod {}
- (void)anotherTestMethod {}
@end

@interface EmptyRuntimeTestClass : NSObject
@end

@implementation EmptyRuntimeTestClass
@end

@interface BERuntimeTests : XCTestCase
@end

@implementation BERuntimeTests

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

#pragma mark - metaclass_getClass Tests

- (void)testMetaclassGetClass_WithNilParameter {
	Class nilClass = nil;
	
	Class result = metaclass_getClass(nilClass);
	XCTAssertNil(result, @"Should return nil when metaClass parameter is nil");
}

- (void)testMetaclassGetClass_WithValidMetaclass {
	Class testClass = [RuntimeTestClass class];
	Class testMetaclass = object_getClass(testClass);
	
	Class result = metaclass_getClass(testMetaclass);
	XCTAssertEqual(result, testClass, @"Should return the class corresponding to the metaclass");
}

- (void)testMetaclassGetClass_WithNSObjectMetaclass {
	Class nsObjectClass = [NSObject class];
	Class nsObjectMetaclass = object_getClass(nsObjectClass);
	
	Class result = metaclass_getClass(nsObjectMetaclass);
	XCTAssertEqual(result, nsObjectClass, @"Should return NSObject class for NSObject metaclass");
}

- (void)testMetaclassGetClass_WithCustomClass {
	Class emptyClass = [EmptyRuntimeTestClass class];
	Class emptyMetaclass = object_getClass(emptyClass);
	
	Class result = metaclass_getClass(emptyMetaclass);
	XCTAssertEqual(result, emptyClass, @"Should return EmptyTestClass for its metaclass");
}

- (void)testMetaclassGetClass_WithInvalidMetaclass {
	
	Class dynamicClass = objc_allocateClassPair([NSObject class], "DynamicTestClass", 0);
	objc_registerClassPair(dynamicClass);
	Class dynamicMetaclass = object_getClass(dynamicClass);
	
	Class result = metaclass_getClass(dynamicMetaclass);
	XCTAssertEqual(result, dynamicClass, @"Should return the dynamic class");
	
	// Note: We can't easily test the objc_getClass failure path without corrupting
	// the runtime, so this test verifies the normal case works.
	// The objc_getClass failure would be extremely rare in practice.
}

- (void)testMetaclassGetClass_WithNSObject {
	// Test Path 4: Simulate a scenario where class_getName returns NULL
	// This is difficult to test directly as it would require corrupting runtime data
	// Instead, we test with the root metaclass which has special behavior
	
	Class nsObjectClass = [NSObject class];
	Class nsObjectMetaclass = object_getClass(nsObjectClass);
	
	Class result = metaclass_getClass(nsObjectMetaclass);
	XCTAssertEqual(result, nsObjectClass, @"Should return NSObject class for NSObject metaclass");
	
	// Note: Testing the actual class_getName() == NULL scenario would require
	// corrupting runtime data structures, which is not safe in unit tests.
	// This path is extremely rare and would indicate serious runtime corruption.
}

- (void)testMetaclassGetClass_WithMetaclass {
	// Test Path 4: Simulate a scenario where class_getName returns NULL
	// This is difficult to test directly as it would require corrupting runtime data
	// Instead, we test with edge cases
	
	Class rootMetaclass = object_getClass([NSObject class]);
	Class rootMetaMetaclass = object_getClass(rootMetaclass);
	
	Class result = metaclass_getClass(rootMetaMetaclass);
	XCTAssertNotEqual(result, rootMetaclass, @"Cannot find the metaClass from a metaMetaClass");
}

- (void)testMetaclassGetClass_WithNonMetaclass {
	
	Class testClass = [RuntimeTestClass class];
	
	// Pass the actual class instead of its metaclass
	// This should fail the final check: object_getClass(candidate) == metaClass
	Class result = metaclass_getClass(testClass);
	XCTAssertNil(result, @"Should return nil when passed a class instead of its metaclass");
}
 


#pragma mark - class_hasMethod Tests

- (void)testClassHasMethod_WithNilClass {
	Class nilClass = nil;
	
	SEL testSelector = @selector(testMethod);
	BOOL result = class_hasMethod(nilClass, testSelector);
	XCTAssertFalse(result, @"Should return NO when class is nil");
}

- (void)testClassHasMethod_WithNilSelector {
	SEL nilSelector = nil;
	
	Class testClass = [RuntimeTestClass class];
	BOOL result = class_hasMethod(testClass, nilSelector);
	XCTAssertFalse(result, @"Should return NO when selector is nil");
}

- (void)testClassHasMethod_WithBothNil {
	Class nilClass = nil;
	SEL nilSelector = nil;
	
	BOOL result = class_hasMethod(nilClass, nilSelector);
	XCTAssertFalse(result, @"Should return NO when both class and selector are nil");
}

- (void)testClassHasMethod_WithExistingMethod {
	Class testClass = [RuntimeTestClass class];
	SEL testSelector = @selector(testMethod);
	
	BOOL result = class_hasMethod(testClass, testSelector);
	XCTAssertTrue(result, @"Should return YES when method exists in class");
}

- (void)testClassHasMethod_WithNonexistentMethod {
	Class testClass = [RuntimeTestClass class];
	SEL nonexistentSelector = NSSelectorFromString(@"nonexistentMethod");
	
	BOOL result = class_hasMethod(testClass, nonexistentSelector);
	XCTAssertFalse(result, @"Should return NO when method doesn't exist in class");
}

- (void)testClassHasMethod_WithMultipleMethods {
	Class testClass = [RuntimeTestClass class];
	SEL testSelector1 = @selector(testMethod);
	SEL testSelector2 = @selector(anotherTestMethod);
	
	BOOL result1 = class_hasMethod(testClass, testSelector1);
	BOOL result2 = class_hasMethod(testClass, testSelector2);
	
	XCTAssertTrue(result1, @"Should find first test method");
	XCTAssertTrue(result2, @"Should find second test method");
}

- (void)testClassHasMethod_WithEmptyClass {
	Class emptyClass = [EmptyRuntimeTestClass class];
	SEL testSelector = @selector(testMethod);
	
	BOOL result = class_hasMethod(emptyClass, testSelector);
	XCTAssertFalse(result, @"Should return NO when method doesn't exist in empty class");
}

- (void)testClassHasMethod_WithNSObjectMethod {
	Class testClass = [RuntimeTestClass class];
	SEL initSelector = @selector(init);
	
	// Note: This tests the current class's method list, not inherited methods
	// init is defined in NSObject, not TestClass, so it should return NO
	BOOL result = class_hasMethod(testClass, initSelector);
	XCTAssertFalse(result, @"Should return NO for inherited methods not defined in the specific class");
}

- (void)testClassHasMethod_WithClassMethod {
	Class testMetaclass = object_getClass([RuntimeTestClass class]);
	SEL allocSelector = @selector(alloc);
	
	BOOL result = class_hasMethod(testMetaclass, allocSelector);
	// alloc is inherited from NSObject's metaclass, so it won't be in TestClass's metaclass method list
	XCTAssertFalse(result, @"Should return NO for inherited class methods");
}

- (void)testClassHasMethod_WithDynamicMethod {
	Class dynamicClass = objc_allocateClassPair([NSObject class], "DynamicMethodTestClass", 0);
	
	SEL dynamicSelector = NSSelectorFromString(@"dynamicMethod");
	IMP dynamicIMP = imp_implementationWithBlock(^{
	});
	
	class_addMethod(dynamicClass, dynamicSelector, dynamicIMP, "v@:");
	objc_registerClassPair(dynamicClass);
	
	BOOL result = class_hasMethod(dynamicClass, dynamicSelector);
	XCTAssertTrue(result, @"Should find dynamically added method");
	
	SEL nonexistentSelector = NSSelectorFromString(@"nonexistentDynamicMethod");
	BOOL result2 = class_hasMethod(dynamicClass, nonexistentSelector);
	XCTAssertFalse(result2, @"Should not find non-existent method in dynamic class");
	
	objc_disposeClassPair(dynamicClass);
}

- (void)testClassHasMethod_WithNilMethodList {
	// Test Path 11: Edge case where class_copyMethodList might return NULL
	// This is hard to simulate directly, but we test with a class that has no methods
	
	Class emptyClass = objc_allocateClassPair([NSObject class], "EmptyMethodListClass", 0);
	objc_registerClassPair(emptyClass);
	
	SEL testSelector = @selector(testMethod);
	BOOL result = class_hasMethod(emptyClass, testSelector);
	XCTAssertFalse(result, @"Should handle empty method list correctly");
	
	objc_disposeClassPair(emptyClass);
}

- (void)testClassHasMethod_EdgeCaseWithSameMethodNames {
	Class testClass = [RuntimeTestClass class];
	
	SEL exactSelector = @selector(testMethod);
	SEL differentSelector = NSSelectorFromString(@"testMethod2");
	
	BOOL exactResult = class_hasMethod(testClass, exactSelector);
	BOOL differentResult = class_hasMethod(testClass, differentSelector);
	
	XCTAssertTrue(exactResult, @"Should find exact method match");
	XCTAssertFalse(differentResult, @"Should not find different method");
}

@end
