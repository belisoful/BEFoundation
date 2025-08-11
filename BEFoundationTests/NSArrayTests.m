//
//  BFoundationExtensionTests.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import "NSArray+BExtension.h"

@interface NSArrayTests : XCTestCase

@end

@implementation NSArrayTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


#pragma mark - NSArray set Tests

- (void) testNSArray_orderedSet
{
	NSArray *array = @[@0, @1, @2, @3, @10, @1, @11, @0, @2];
	NSOrderedSet *reference = [NSOrderedSet orderedSetWithArray:array];
	
	XCTAssertEqualObjects(array.orderedSet, reference);
}


- (void) testNSArray_set
{
	NSArray *array = @[@0, @1, @2, @3, @10, @1, @11, @0, @2];
	NSSet *reference = [NSSet setWithArray:array];
	
	XCTAssertEqualObjects(array.set, reference);
}


#pragma mark objectsClasses Tests

- (void)testNSArray_ObjectsClasses_Correctness {
	{ // object classes
		NSArray *input = @[@"NSObject", @"NSNumber", @11, @[@1, @2], [NSNull null], @{@"A": @1, @"B": @2}];
		
		// Map to Class objects
		NSArray *result = [input objectsClasses];
		
		
		NSArray *reference = @[@"NSObject".class, @"NSNumber".class, @(11).class, @[@1, @2].class, [NSNull null].class, @{@"A": @1, @"B": @2}.class];
		
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSArray *input = @[];
		
		NSArray *result = [input objectsClasses];
		
		NSArray *reference = @[];
		// An empty set should return an empty set
		XCTAssertEqualObjects(result, reference);
	}
}


#pragma mark objectsClassNames Tests

- (void)testNSArray_ObjectsClassNames_Correctness {
	{ // object classes
		NSArray *input = @[@"NSObject", @"NSNumber", @11, @[@1, @2], [NSNull null], @{@"A": @1, @"B": @2}];
		
		// Map to Class objects
		NSArray *result = [input objectsClassNames];
		
		
		NSArray *reference = @[@"NSObject".className, @"NSNumber".className, @(11).className, @[@1, @2].className, [NSNull null].className, @{@"A": @1, @"B": @2}.className];
		// Verify that each element has been converted to the correct Class object
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSArray *input = @[];
		
		NSArray *result = [input objectsClassNames];
		
		NSArray *reference = @[];
		
		// An empty set should return an empty set
		XCTAssertEqual(result.count, reference.count);
	}
}


#pragma mark objectsUniqueClasses Tests

- (void)testNSArray_ObjectsUniqueClasses_Correctness {
	{ // object classes
		NSArray *input = @[@"NSObject", @"NSNumber", @11, @[@1, @2], [NSNull null], @0, @{@"A": @1, @"B": @2}];
		
		// Map to Class objects
		NSCountedSet *result = [input objectsUniqueClasses];
		
		
		NSCountedSet *reference = [NSCountedSet setWithObjects:@"NSObject".class, @"NSNumber".class, @(11).class, @[@1, @2].class, [NSNull null].class, @(0).class, @{@"A": @1, @"B": @2}.class, nil];
		// Verify that each element has been converted to the correct Class object
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSArray *input = @[];
		
		NSCountedSet *result = [input objectsUniqueClasses];
		
		NSCountedSet *reference = [NSCountedSet set];
		// An empty set should return an empty set
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqual(result.count, 0);
	}
}

#pragma mark objectsUniqueClassNames Tests

- (void)testNSArray_ObjectsUniqueClassNames_Correctness {
	{ // object classes
		NSArray *input = @[@"NSObject", @"NSNumber", @11, @[@1, @2], [NSNull null], @{@"A": @1, @"B": @2}];
		
		// Map to Class objects
		NSCountedSet *result = [input objectsUniqueClassNames];
		
		
		NSCountedSet *reference = [NSCountedSet setWithObjects:@"NSObject".className, @"NSNumber".className, @(11).className, @[@1, @2].className, [NSNull null].className, @{@"A": @1, @"B": @2}.className, nil];
		// Verify that each element has been converted to the correct Class object
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSArray *input = @[];
		
		NSCountedSet *result = [input objectsUniqueClassNames];
		
		NSCountedSet *reference = [NSCountedSet set];
		// An empty set should return an empty set
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqual(result.count, 0);
	}
}



#pragma mark String to Class Correctness Tests

- (void)testNSArray_ToClassesFromStrings_Correctness {
	{	// Class Names to Class, filter out invalid classes, and objects not NSString.
		NSArray *input = @[@"NSString", @"NSNumber", @"NSObject", @"NSMutableArray", [NSNull null], @"InvalidClass", @"AnotherInvalidClass", @[], @{}];
		
		// Map to Class objects
		NSArray *result = [input toClassesFromStrings];
		
		NSArray *reference = @[NSString.class, NSNumber.class, NSObject.class, NSMutableArray.class];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
	{	// empty set remains empty
		NSArray *input = @[];
		NSArray *result = [input toClassesFromStrings];
		
		NSArray *reference = @[];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
}

#pragma mark arrayByInsertingObjectsFromArray

- (void)testNSArray_arrayByInsertingObjectsFromArray_Correctness
{
	NSArray *array = @[@1, @2, @3];
	NSArray *otherArray = @[@"a", @"b", @"c"];
	
	NSArray *result = [array arrayByInsertingObjectsFromArray:otherArray atIndex:0];
	NSArray *reference = @[@"a", @"b", @"c", @1, @2, @3];
	XCTAssertEqualObjects(result, reference);
	
	result = [array arrayByInsertingObjectsFromArray:otherArray atIndex:1];
	reference = @[@1, @"a", @"b", @"c", @2, @3];
	XCTAssertEqualObjects(result, reference);
	
	result = [array arrayByInsertingObjectsFromArray:otherArray atIndex:2];
	reference = @[@1, @2, @"a", @"b", @"c", @3];
	XCTAssertEqualObjects(result, reference);
	
	result = [array arrayByInsertingObjectsFromArray:otherArray atIndex:3];
	reference = @[@1, @2, @3, @"a", @"b", @"c"];
	XCTAssertEqualObjects(result, reference);
	
	otherArray = @[];
	result = [array arrayByInsertingObjectsFromArray:otherArray atIndex:0];
	XCTAssertEqualObjects(result, array);
	
	NSMutableArray *mArray = array.mutableCopy;
	result = [mArray arrayByInsertingObjectsFromArray:otherArray atIndex:0];
	XCTAssertNotEqual(result, array);
	XCTAssertEqualObjects(result, array);
}

- (void)testNSArray_arrayByInsertingObjectsFromArray_BadArguments
{
	NSArray *array = @[@1, @2, @3];
	NSArray *otherArray = @[@"a", @"b", @"c"];
	NSArray *nilArray = nil;
	
	XCTAssertThrowsSpecificNamed([array arrayByInsertingObjectsFromArray:nilArray atIndex:1], NSException,
								 NSInvalidArgumentException);
	
	XCTAssertThrowsSpecificNamed([array arrayByInsertingObjectsFromArray:(NSArray*)NSObject.new atIndex:1], NSException,
								 NSInvalidArgumentException);
	
	XCTAssertThrowsSpecificNamed([array arrayByInsertingObjectsFromArray:otherArray atIndex:-1], NSException,
								 NSInvalidArgumentException);
	
	XCTAssertThrowsSpecificNamed([array arrayByInsertingObjectsFromArray:otherArray atIndex:4], NSException,
								 NSInvalidArgumentException);
}



#pragma mark MapUsingBlock

- (void)testNSArray_MapUsingBlock_Correctness
{
	NSArray *input = @[@1, @2, @3, @4, @5, @6, [NSNull null]];
	
	// Test synchronous behavior (no NSEnumerationConcurrent)
	NSArray *result = [input mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if (*obj == [NSNull null]) {
			return YES;
		}
		if ([*obj integerValue] % 2) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}
		return NO;
	}];
	NSArray *reference = @[@2, @6, @10, [NSNull null]];
	
	XCTAssertTrue([result isKindOfClass:NSArray.class]);
	XCTAssertEqual(result.count, reference.count);
	XCTAssertEqualObjects(result, reference);
}

- (void)testNSMutableArray_MapUsingBlock_Correctness
{
	NSMutableArray *input = @[@1, @2, @3, @4, @5, @6, [NSNull null]].mutableCopy;
	
	// Test synchronous behavior (no NSEnumerationConcurrent)
	NSMutableArray *result = [input mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if (*obj == [NSNull null]) {
			return YES;
		}
		if ([*obj integerValue] % 2) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}
		return NO;
	}];
	NSArray *reference = @[@2, @6, @10, [NSNull null]];
	
	XCTAssertTrue([result isKindOfClass:NSMutableArray.class]);
	XCTAssertEqual(result.count, reference.count);
	XCTAssertEqualObjects(result, reference);
}



- (void)testNSxArray_MapUsingBlock_EmptySet
{
	{	// NSOrderedSet test
		NSArray *input = @[];
		NSArray *result = [input mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
		XCTAssertTrue([result isKindOfClass:[NSArray class]]);
		XCTAssertEqual(result.count, 0);
	}
	
	{	//NSMutableOrderedSet test
		NSMutableArray *mInput = @[].mutableCopy;
		NSMutableArray *mResult = [mInput mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
		XCTAssertTrue([mResult isKindOfClass:[NSMutableArray class]]);
		XCTAssertEqual(mResult.count, 0);
	}
}


- (void)testNSxArray_MapUsingBlock_WithNilBlock
{
	NSArray *input = @[@"1", @"2", @"3"];
	NSArray *result = [input mapUsingBlock:nil];
	XCTAssertNotNil(result);
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqualObjects(result, input);
	
	NSMutableArray *mInput = @[@"1", @"2", @"3"].mutableCopy;
	NSMutableArray *mResult = [mInput mapUsingBlock:nil];
	XCTAssertNotNil(mResult);
	XCTAssertTrue([mResult isKindOfClass:[NSMutableArray class]]);
	XCTAssertEqualObjects(mResult, mInput);
}



- (void)testNSArray_MapUsingBlock_Performance
{
	NSMutableArray *largeinput = @[].mutableCopy;
	for (NSInteger i = 0; i < 50000; i++) {
		[largeinput addObject:[NSString stringWithFormat:@"%ld", (long)i]];
	}
	
	NSArray *array = largeinput.copy;
	// Measure performance for large input with synchronous processing
	[self measureBlock:^{
		[array mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
	}];
}


#pragma mark - NSMutableArray

- (void)testNSMutableArray_removeFirstObject
{
	NSMutableArray *array = @[@0, @1, @2].mutableCopy;
	
	[array removeFirstObject];
	NSArray *reference = @[@1, @2];
	XCTAssertEqualObjects(array, reference);
	
	[array removeFirstObject];
	reference = @[@2];
	XCTAssertEqualObjects(array, reference);
	
	[array removeFirstObject];
	reference = @[];
	XCTAssertEqualObjects(array, reference);
}

- (void)testNSMutableArray_removeFirstObject_NoObjects
{
	NSMutableArray *array = @[].mutableCopy;
	
	[array removeLastObject];
	[array removeFirstObject];
}



- (void)testNSMutableArray_insertObjects_Correctness
{
	NSArray *original = @[@0, @1, @2];
	NSArray *otherArray = @[@"a", @"b", @"c"];
	
	NSMutableArray *array = original.mutableCopy;
	[array insertObjects:otherArray atIndex:0];
	NSArray *reference = @[@"a", @"b", @"c", @0, @1, @2];
	XCTAssertEqualObjects(array, reference);
	
	
	array = original.mutableCopy;
	[array insertObjects:otherArray atIndex:1];
	reference = @[@0, @"a", @"b", @"c", @1, @2];
	XCTAssertEqualObjects(array, reference);
	
	
	array = original.mutableCopy;
	[array insertObjects:otherArray atIndex:2];
	reference = @[@0, @1, @"a", @"b", @"c", @2];
	XCTAssertEqualObjects(array, reference);
	
	
	array = original.mutableCopy;
	[array insertObjects:otherArray atIndex:3];
	reference = @[@0, @1, @2, @"a", @"b", @"c"];
	XCTAssertEqualObjects(array, reference);
	
	array = original.mutableCopy;
	otherArray = @[];
	[array insertObjects:otherArray atIndex:1];
	reference = @[@0, @1, @2];
	XCTAssertEqualObjects(array, reference);
}

- (void)testNSMutableArray_insertObjects_BadArguments
{
	NSMutableArray *array = @[@1, @2, @3].mutableCopy;
	NSArray *otherArray = @[@"a", @"b", @"c"];
	NSArray *nilArray = nil;
	
	
	XCTAssertThrowsSpecificNamed([array insertObjects:nilArray atIndex:1], NSException,
								 NSInvalidArgumentException);
	
	XCTAssertThrowsSpecificNamed([array insertObjects:(NSArray*)NSObject.new atIndex:1], NSException,
								 NSInvalidArgumentException);
	
	XCTAssertThrowsSpecificNamed([array insertObjects:otherArray atIndex:-1], NSException,
								 NSInvalidArgumentException);
	
	XCTAssertThrowsSpecificNamed([array insertObjects:otherArray atIndex:4], NSException,
								 NSInvalidArgumentException);
}



- (void)testNSMutableArray_setOrderedSet
{
	NSMutableArray *array = @[@1, @2, @3].mutableCopy;
	NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithObjects:@"a", @"b", @"c", @"a", nil];
	
	array.orderedSet = orderedSet;
	NSArray *reference = @[@"a", @"b", @"c"];
	XCTAssertEqualObjects(array, reference);
}

- (void)testNSMutableArray_setSet
{
	NSMutableArray *array = @[@1, @2, @3].mutableCopy;
	NSSet *set = [NSSet setWithObjects:@"a", @"b", @"c", @"a", nil];
	
	array.set = set;
	
	XCTAssertEqual(array.count, 3);
	XCTAssertTrue([array containsObject:@"a"]);
	XCTAssertTrue([array containsObject:@"b"]);
	XCTAssertTrue([array containsObject:@"c"]);
}


#pragma mark FilterUsingBlock

- (void)testFilterUsingBlock_Correctness {
	{	// works correctly
		// Test the filter operation with no concurrency (map I -> I*2)
		NSMutableArray *input = @[@1, @2, @3, @4, @5, @6, [NSNull null]].mutableCopy;
		NSMutableArray *result = [input filterUsingBlock:^BOOL(id _Nullable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
			if (*obj == [NSNull null]) {
				*obj = nil;
				return YES;
			}
			if ([*obj integerValue] % 2) {
				*obj = @([*obj integerValue] * 2);
				return YES;
			}
			return NO;
		}];
		NSArray *reference = @[@2, @6, @10];
		XCTAssertEqual(result, input);
		XCTAssertEqualObjects(result, reference, @"The set should contain each element multiplied by 2.");
	}
	{	//empty set
		NSMutableArray *input = @[].mutableCopy;
		NSMutableArray *result = [input filterUsingBlock:^BOOL(id _Nullable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
			if (*obj == [NSNull null]) {
				return YES;
			}
			if ([*obj integerValue] % 2) {
				*obj = @([*obj integerValue] * 2);
				return YES;
			}
			return NO;
		}];
		
		NSArray *reference = @[];
		XCTAssertEqual(result, input);
		XCTAssertEqualObjects(result, reference, @"The result should be an empty set.");
	}
}


- (void)testFilterUsingBlock_WithNilBlock
{
	NSMutableArray *input = @[@"1", @"2", @3, [NSNull null], @[], @{}].mutableCopy;
	
	// Test both synchronous and concurrent with a nil block
	NSMutableArray *result = [input filterUsingBlock:nil];
	
	NSArray *reference = @[@"1", @"2", @3, [NSNull null], @[], @{}];
	XCTAssertEqual(result, input);
	XCTAssertEqualObjects(result, reference);
	XCTAssertEqual(result.count, 6);
}


- (void)testFilterUsingBlock_Performance {
	// Performance test to check how well the filter works with a large set (map I -> I*2)
	NSMutableArray *array = @[].mutableCopy;
	for (NSInteger i = 0; i < 100000; i++) {
		[array addObject:@(i)];
	}
	
	// Measure performance of mapping each element to I*2
	[self measureBlock:^{
		[array filterUsingBlock:^BOOL(id _Nullable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
	}];
}

@end
