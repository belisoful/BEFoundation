//
//  NSOrderedSet+BExtension.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import <BEFoundation/NSOrderedSet+BExtension.h>

@interface NSOrderedSetBExtensionTests : XCTestCase

@end

@implementation NSOrderedSetBExtensionTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


#pragma mark - NSOrderedSet objectsClasses Tests

- (void)testObjectsClasses_Correctness {
	{ // object classes
		NSOrderedSet *input = [NSOrderedSet orderedSetWithObjects:@"NSObject", @"NSNumber", @(11), @[@1, @2], [NSNull null], @{@"A": @1, @"B": @2}, nil];
		
		// Map to Class objects
		NSOrderedSet *result = [input objectsClasses];
		
		
		NSOrderedSet *reference = [NSOrderedSet orderedSetWithObjects:@"NSObject".class, @"NSNumber".class, @(11).class, @[@1, @2].class, [NSNull null].class, @{@"A": @1, @"B": @2}.class, nil];
		
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSOrderedSet *input = [NSOrderedSet orderedSet];
		
		NSOrderedSet *result = [input objectsClasses];
		
		NSOrderedSet *reference = [NSOrderedSet orderedSet];
		// An empty set should return an empty set
		XCTAssertEqualObjects(result, reference);
	}
}


#pragma mark objectsClassNames Tests

- (void)testObjectsClassNames_Correctness {
	{ // object classes
		NSOrderedSet *input = [NSOrderedSet orderedSetWithObjects:@"NSObject", @"NSNumber", @11, @[@1, @2], [NSNull null], @{@"A": @1, @"B": @2}, nil];
		
		// Map to Class objects
		NSOrderedSet *result = [input objectsClassNames];
		
		
		NSOrderedSet *reference = [NSOrderedSet orderedSetWithObjects:@"NSObject".className, @"NSNumber".className, @(11).className, @[@1, @2].className, [NSNull null].className, @{@"A": @1, @"B": @2}.className, nil];
		// Verify that each element has been converted to the correct Class object
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSOrderedSet *input = [NSOrderedSet orderedSet];
		
		NSOrderedSet *result = [input objectsClassNames];
		
		NSOrderedSet *reference = [NSOrderedSet orderedSet];
		// An empty set should return an empty set
		XCTAssertEqual(result.count, reference.count);
	}
}


#pragma mark objectsUniqueClasses Tests

- (void)testObjectsUniqueClasses_Correctness {
	{ // object classes
		NSOrderedSet *input = [NSOrderedSet orderedSetWithObjects:@"NSObject", @11, @[@1, @2], [NSNull null], @0, @{@"A": @1, @"B": @2}, nil];
		
		// Map to Class objects
		NSCountedSet *result = [input objectsUniqueClasses];
		
		
		NSCountedSet *reference = [NSCountedSet setWithObjects:@"NSObject".class, @(11).class, @[@1, @2].class, [NSNull null].class, @(0).class, @{@"A": @1, @"B": @2}.class, nil];
		// Verify that each element has been converted to the correct Class object
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSOrderedSet *input = [NSOrderedSet orderedSet];
		
		NSCountedSet *result = [input objectsUniqueClasses];
		
		NSCountedSet *reference = [NSCountedSet set];
		// An empty set should return an empty set
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqual(result.count, 0);
	}
}

#pragma mark objectsUniqueClassNames Tests

- (void)testObjectsUniqueClassNames_Correctness {
	{ // object classes
		NSOrderedSet *input = [NSOrderedSet orderedSetWithObjects:@"NSObject", @11, @[@1, @2], [NSNull null], @{@"A": @1, @"B": @2}, nil];
		
		// Map to Class objects
		NSCountedSet *result = [input objectsUniqueClassNames];
		
		
		NSCountedSet *reference = [NSCountedSet setWithObjects:@"NSObject".className, @(11).className, @[@1, @2].className, [NSNull null].className, @{@"A": @1, @"B": @2}.className, nil];
		// Verify that each element has been converted to the correct Class object
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSOrderedSet *input = [NSOrderedSet orderedSet];
		
		NSCountedSet *result = [input objectsUniqueClassNames];
		
		NSCountedSet *reference = [NSCountedSet set];
		// An empty set should return an empty set
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqual(result.count, 0);
	}
}



#pragma mark String to Class Correctness Tests

- (void)testToClassesFromStrings_Correctness {
	{	// Class Names to Class, filter out invalid classes, and objects not NSString.
		NSOrderedSet *input = [NSOrderedSet orderedSetWithObjects:@"NSString", @"NSNumber", @"NSObject", @"NSMutableArray", [NSNull null], @"InvalidClass", @"AnotherInvalidClass", @[], @{}, nil];
		
		// Map to Class objects
		NSOrderedSet *result = [input toClassesFromStrings];
		
		NSOrderedSet *reference = [NSOrderedSet orderedSetWithObjects:NSString.class, NSNumber.class, NSObject.class, NSMutableArray.class, nil];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
	{	// empty set remains empty
		NSOrderedSet *input = [NSOrderedSet orderedSet];
		NSOrderedSet *result = [input toClassesFromStrings];
		
		NSOrderedSet *reference = [NSOrderedSet orderedSet];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
}

#pragma mark MapUsingBlock

- (void)testMap_NSOrderedSetCorrectness
{
	NSOrderedSet *input = [NSOrderedSet orderedSetWithObjects:@1, @2, @3, @4, @5, @6, [NSNull null], nil];
	// Test synchronous behavior (no NSEnumerationConcurrent)
	NSOrderedSet *result = [input mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if (*obj == [NSNull null]) {
			return YES;
		}
		if ([*obj integerValue] % 2) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}
		return NO;
	}];
	NSOrderedSet *reference = [NSOrderedSet orderedSetWithObjects:@2, @6, @10, [NSNull null], nil];
	
	XCTAssertTrue([result isKindOfClass:NSOrderedSet.class]);
	XCTAssertEqual(result.count, reference.count);
	XCTAssertEqualObjects(result, reference);
}

- (void)testMap_NSMutableOrderedSetCorrectness
{
	NSMutableOrderedSet *input = [NSMutableOrderedSet orderedSetWithObjects:@1, @2, @3, @4, @5, @6, [NSNull null], nil];
	// Test synchronous behavior (no NSEnumerationConcurrent)
	NSMutableOrderedSet *result = [input mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if (*obj == [NSNull null]) {
			return YES;
		}
		if ([*obj integerValue] % 2) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}
		return NO;
	}];
	NSMutableOrderedSet *reference = [NSMutableOrderedSet orderedSetWithObjects:@2, @6, @10, [NSNull null], nil];
	
	XCTAssertTrue([result isKindOfClass:NSMutableOrderedSet.class]);
	XCTAssertEqual(result.count, reference.count);
	XCTAssertEqualObjects(result, reference);
}



- (void)testMap_EmptySet
{
	{	// NSOrderedSet test
		NSOrderedSet *input = [NSOrderedSet orderedSet];
		NSOrderedSet *result = [input mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
		XCTAssertTrue([result isKindOfClass:[NSOrderedSet class]]);
		XCTAssertEqual(result.count, 0);
	}
	
	{	//NSMutableOrderedSet test
		NSMutableOrderedSet *mInput = [NSMutableOrderedSet orderedSet];
		NSMutableOrderedSet *mResult = [mInput mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
		XCTAssertTrue([mResult isKindOfClass:[NSMutableOrderedSet class]]);
		XCTAssertEqual(mResult.count, 0);
	}
}


- (void)testMap_WithNilBlock {
	NSOrderedSet *input = [NSOrderedSet orderedSetWithObjects:@"1", @"2", @"3", nil];
	NSOrderedSet *result = [input mapUsingBlock:nil];
	XCTAssertNotNil(result);
	XCTAssertTrue([result isKindOfClass:[NSOrderedSet class]]);
	XCTAssertEqualObjects(result, input);
	
	NSMutableOrderedSet *mInput = [NSMutableOrderedSet orderedSetWithObjects:@"1", @"2", @"3", nil];
	NSMutableOrderedSet *mResult = [mInput mapUsingBlock:nil];
	XCTAssertNotNil(mResult);
	XCTAssertTrue([mResult isKindOfClass:[NSMutableOrderedSet class]]);
	XCTAssertEqualObjects(mResult, mInput);
}



- (void)testMap_Performance {
	NSMutableOrderedSet *largeinput = [NSMutableOrderedSet orderedSet];
	for (NSInteger i = 0; i < 50000; i++) {
		[largeinput addObject:[NSString stringWithFormat:@"%ld", (long)i]];
	}
	
	NSOrderedSet *set = largeinput.copy;
	// Measure performance for large input with synchronous processing
	[self measureBlock:^{
		[set mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
	}];
}



#pragma mark - NSMutableOrderSet
#pragma mark intersectArray

- (void)testIntersectArray
{
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithObjects:@1, @2, @3, @4, @5, @6, @7, @8, @9, @10, nil];
	
	[orderedSet intersectArray:@[@1, @2, @2, @3, @3, @3, @4, @5, @11, @12, @13]];
	
	NSOrderedSet *reference = [NSOrderedSet orderedSetWithObjects:@1, @2, @3, @4, @5, nil];
	
	XCTAssertEqualObjects(orderedSet, reference);
}


#pragma mark setArray

- (void)testSetArray
{
	{	//Correctness
		NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithObjects:@-1, @-2, @-3, @-4, @-5, @-6, @-7, @-8, @-9, @-10, nil];
		
		orderedSet.array = @[@1, @2, @3, @3, @4, @4, @5, @1];
		
		NSOrderedSet *reference = [NSOrderedSet orderedSetWithObjects:@1, @2, @3, @4, @5, nil];
		XCTAssertEqualObjects(orderedSet, reference);
	}
	{	// no elements
		NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithObjects:@-1, @-2, @-3, @-4, @-5, @-6, @-7, @-8, @-9, @-10, nil];
		
		orderedSet.array = @[];
		
		NSOrderedSet *reference = [NSOrderedSet orderedSet];
		XCTAssertEqualObjects(orderedSet, reference);
	}
	{	// nil array
		NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithObjects:@-1, @-2, @-3, @-4, @-5, @-6, @-7, @-8, @-9, @-10, nil];
		
		orderedSet.array = NULL;
		
		NSOrderedSet *reference = [NSOrderedSet orderedSet];
		XCTAssertEqualObjects(orderedSet, reference);
	}
}


#pragma mark setSet
#define min(a, b) ((a < b) ? a : b)
- (void)testSetSet
{
	{	//Correctness
		NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithObjects:@-1, @-2, @-3, @-4, @-5, @-6, @-7, @-8, @-9, @-10, nil];
		
		orderedSet.set = [NSSet setWithObjects:@1, @2, @3, @3, @4, @5, nil];
		
		NSOrderedSet *reference = [NSOrderedSet orderedSetWithObjects:@1, @2, @3, @4, @5, nil];
		XCTAssertTrue([orderedSet containsObject:@1]);
		XCTAssertTrue([orderedSet containsObject:@2]);
		XCTAssertTrue([orderedSet containsObject:@3]);
		XCTAssertTrue([orderedSet containsObject:@4]);
		XCTAssertTrue([orderedSet containsObject:@5]);
		XCTAssertEqual(orderedSet.count, reference.count);
	}
	{	// no elements
		NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithObjects:@-1, @-2, @-3, @-4, @-5, @-6, @-7, @-8, @-9, @-10, nil];
		
		orderedSet.set = [NSSet set];
		
		NSOrderedSet *reference = [NSOrderedSet orderedSet];
		XCTAssertEqualObjects(orderedSet, reference);
	}
	{	// nil array
		NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithObjects:@-1, @-2, @-3, @-4, @-5, @-6, @-7, @-8, @-9, @-10, nil];
		
		orderedSet.set = NULL;
		
		NSOrderedSet *reference = [NSOrderedSet orderedSet];
		XCTAssertEqualObjects(orderedSet, reference);
	}
}





#pragma mark removeXObject

- (void)testRemoveFirstObject
{
	{
		NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithObjects:@1, @2, @3, @4, @5, nil];
		
		[orderedSet removeFirstObject];
		NSMutableOrderedSet *reference = [NSMutableOrderedSet orderedSetWithObjects:@2, @3, @4, @5, nil];
		XCTAssertEqualObjects(orderedSet, reference);
	}
	{
		NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
		
		[orderedSet removeFirstObject];
		
		NSMutableOrderedSet *reference = [NSMutableOrderedSet orderedSet];
		XCTAssertEqualObjects(orderedSet, reference);
	}
}


- (void)testRemoveLastObject
{
	{
		NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithObjects:@1, @2, @3, @4, @5, nil];
		
		[orderedSet removeLastObject];
		
		NSMutableOrderedSet *reference = [NSMutableOrderedSet orderedSetWithObjects:@1, @2, @3, @4, nil];
		XCTAssertEqualObjects(orderedSet, reference);
	}
	{
		NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
		
		[orderedSet removeLastObject];
		NSMutableOrderedSet *reference = [NSMutableOrderedSet orderedSet];
		XCTAssertEqualObjects(orderedSet, reference);
	}
}



#pragma mark FilterUsingBlock

- (void)testFilterUsingBlock_Correctness {
	{	// works correctly
		// Test the filter operation with no concurrency (map I -> I*2)
		NSMutableOrderedSet *input = [NSMutableOrderedSet orderedSetWithObjects:@1, @2, @3, @4, @5, @6, [NSNull null], nil];
		NSMutableOrderedSet *result = [input filterUsingBlock:^BOOL(id _Nullable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
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
		NSOrderedSet *reference = [NSOrderedSet orderedSetWithObjects:@2, @6, @10, nil];
		XCTAssertEqual(result, input);
		XCTAssertEqualObjects(result, reference, @"The set should contain each element multiplied by 2.");
	}
	{	//empty set
		NSMutableOrderedSet *input = [NSMutableOrderedSet orderedSet];
		NSMutableOrderedSet *result = [input filterUsingBlock:^BOOL(id _Nullable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
			if (*obj == [NSNull null]) {
				return YES;
			}
			if ([*obj integerValue] % 2) {
				*obj = @([*obj integerValue] * 2);
				return YES;
			}
			return NO;
		}];
		
		NSOrderedSet *reference = [NSOrderedSet orderedSet];
		XCTAssertEqual(result, input);
		XCTAssertEqualObjects(result, reference, @"The result should be an empty set.");
	}
}


- (void)testFilterUsingBlock_WithNilBlock {
	NSMutableOrderedSet *input = [NSMutableOrderedSet orderedSetWithObjects:@"1", @"2", @3, [NSNull null], @[], @{}, nil];
	
	// Test both synchronous and concurrent with a nil block
	NSMutableOrderedSet *result = [input filterUsingBlock:nil];
	
	NSOrderedSet *reference = [NSOrderedSet orderedSetWithObjects:@"1", @"2", @3, [NSNull null], @[], @{}, nil];
	XCTAssertEqual(result, input);
	XCTAssertEqualObjects(result, reference);
	XCTAssertEqual(result.count, 6);
}


- (void)testFilterUsingBlock_Performance {
	// Performance test to check how well the filter works with a large set (map I -> I*2)
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
	for (NSInteger i = 0; i < 100000; i++) {
		[set addObject:@(i)];
	}
	
	// Measure performance of mapping each element to I*2
	[self measureBlock:^{
		[set filterUsingBlock:^BOOL(id _Nullable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
	}];
}

@end
