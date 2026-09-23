//
//  NSSet+BExtension.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import <BEFoundation/NSSet+BExtension.h>

@interface NSSetBExtensionTests : XCTestCase

@end

@implementation NSSetBExtensionTests

- (void)setUp {
}

- (void)tearDown {
}



#pragma mark - NSSet
#pragma mark objectsClasses Tests

- (void)testObjectsClasses_Correctness {
	{ // object classes
		NSSet *input = [NSSet setWithObjects:@"NSObject", @"NSNumber", @(11), @[@1, @2], [NSNull null], @{@"A": @1, @"B": @2}, nil];
		
		NSSet *result = [input objectsClasses];
		
		
		NSCountedSet *reference = [NSCountedSet setWithObjects:@"NSObject".class, @"NSObject".class, @(11).class, @[@1, @2].class, [NSNull null].class, @{@"A": @1, @"B": @2}.class, nil];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSSet *input = [NSSet set];
		
		NSSet *result = [input objectsClasses];
		
		NSCountedSet *reference = [NSCountedSet set];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqual(result.count, 0);
	}
}


#pragma mark objectsClassNames Tests

- (void)testObjectsClassNames_Correctness {
	{ // object classes
		NSSet *input = [NSSet setWithObjects:@"NSObject", @"NSNumber", @11, @[@1, @2], [NSNull null], @{@"A": @1, @"B": @2}, nil];
		
		NSCountedSet *result = [input objectsClassNames];
		
		
		NSCountedSet *reference = [NSCountedSet setWithObjects:NSStringFromClass(@"NSObject".class), NSStringFromClass(@"NSNumber".class), NSStringFromClass(@(11).class), NSStringFromClass(@[@1, @2].class), NSStringFromClass([NSNull null].class), NSStringFromClass(@{@"A": @1, @"B": @2}.class), nil];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSSet *input = [NSSet set];
		
		NSCountedSet *result = [input objectsClassNames];
		
		NSCountedSet *reference = [NSCountedSet set];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqual(result.count, 0);
	}
}


#pragma mark objectsUniqueClasses Tests

- (void)testObjectsUniqueClasses_Correctness {
	{ // object classes
		NSSet *input = [NSSet setWithObjects:@"NSObject", @(11), @[@1, @2], [NSNull null], @{@"A": @1, @"B": @2}, nil];
		
		NSCountedSet *result = [input objectsUniqueClasses];
		
		
		NSCountedSet *reference = [NSCountedSet setWithObjects:@"NSObject".class, @(11).class, @[@1, @2].class, [NSNull null].class, @{@"A": @1, @"B": @2}.class, nil];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSSet *input = [NSSet set];
		
		NSCountedSet *result = [input objectsUniqueClasses];
		
		NSCountedSet *reference = [NSCountedSet set];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqual(result.count, 0);
	}
}

#pragma mark objectsUniqueClassNames Tests

- (void)testObjectsUniqueClassNames_Correctness {
	{ // object classes
		NSSet *input = [NSSet setWithObjects:@"NSObject", @(11), @[@1, @2], [NSNull null], @{@"A": @1, @"B": @2}, nil];
		
		NSCountedSet *result = [input objectsUniqueClassNames];
		
		
		NSCountedSet *reference = [NSCountedSet setWithObjects:NSStringFromClass(@"NSObject".class), NSStringFromClass(@(11).class), NSStringFromClass(@[@1, @2].class), NSStringFromClass([NSNull null].class), NSStringFromClass(@{@"A": @1, @"B": @2}.class), nil];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSSet *input = [NSSet set];
		
		NSCountedSet *result = [input objectsUniqueClassNames];
		
		NSCountedSet *reference = [NSCountedSet set];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqual(result.count, 0);
	}
}



#pragma mark String to Class Correctness Tests

- (void)testNSSet_ToClassesFromStrings_Correctness {
	{	// Class Names to Class, filter out invalid classes, and objects not NSString.
		NSSet *input = [NSSet setWithObjects:@"NSString", @"NSNumber", @"NSObject", @"NSArray", [NSNull null], @"InvalidClass", @"AnotherInvalidClass", @[], @{}, nil];
		
		NSSet *result = [input toClassesFromStrings];
		
		NSSet *reference = [NSSet setWithObjects:NSString.class, NSNumber.class, NSObject.class, NSArray.class, nil];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		
		XCTAssertEqualObjects(result, reference);
	}
	{	// empty set remains empty
		NSSet *input = [NSSet set];
		NSSet *result = [input toClassesFromStrings];
		
		NSSet *reference = [NSSet set];
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
}

#pragma mark MapUsingBlock

- (void)testNSSet_MapUsingBlock_Correctness
{
	NSSet *input = [NSSet setWithObjects:@1, @2, @3, @4, @5, @6, [NSNull null], nil];
	NSSet *result = [input mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
		if (*obj == [NSNull null]) {
			return YES;
		}
		if ([*obj integerValue] % 2) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}
		return NO;
	}];
	NSSet *reference = [NSSet setWithObjects:@2, @6, @10, [NSNull null], nil];

	XCTAssertTrue([result isKindOfClass:NSSet.class]);
	XCTAssertEqual(result.count, reference.count);
	XCTAssertEqualObjects(result, reference);
}

/*!
 @discussion	A block that returns YES while niling @c *obj must exclude the
				object through the @c && obj guard, distinct from returning NO.
 */
- (void)testMapUsingBlock_ReturnsYesButNilsObject
{
	NSSet *input = [NSSet setWithObjects:@1, @2, @3, nil];
	NSSet *result = [input mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
		*obj = nil;
		return YES;
	}];
	XCTAssertTrue([result isKindOfClass:NSSet.class]);
	XCTAssertEqual(result.count, 0u);
}



- (void)testMapUsingBlock_EmptySet
{
	{	// NSSet test
		NSSet *input = [NSSet set];
		NSSet *result = [input mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
		XCTAssertTrue([result isKindOfClass:[NSSet class]]);
		XCTAssertEqual(result.count, 0);
	}
	
	{	//NSMutableSet test
		NSMutableSet *mInput = [NSMutableSet set];
		NSMutableSet *mResult = [mInput mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
		XCTAssertTrue([mResult isKindOfClass:[NSMutableSet class]]);
		XCTAssertEqual(mResult.count, 0);
	}
}


- (void)testMapUsingBlock_WithNilBlock {
	NSSet *input = [NSSet setWithObjects:@"1", @"2", @"3", nil];
	NSSet *result = [input mapUsingBlock:nil];
	XCTAssertNotNil(result);
	XCTAssertTrue([result isKindOfClass:[NSSet class]]);
	XCTAssertEqualObjects(result, input);
	
	NSMutableSet *mInput = [NSMutableSet setWithObjects:@"1", @"2", @"3", nil];
	NSMutableSet *mResult = [mInput mapUsingBlock:nil];
	XCTAssertNotNil(mResult);
	XCTAssertTrue([mResult isKindOfClass:[NSMutableSet class]]);
	XCTAssertEqualObjects(mResult, mInput);
}



- (void)testMapUsingBlock_Performance {
	NSMutableSet *largeinput = [NSMutableSet set];
	for (NSInteger i = 0; i < 50000; i++) {
		[largeinput addObject:[NSString stringWithFormat:@"%ld", (long)i]];
	}
	
	NSSet *set = largeinput.copy;
	[self measureBlock:^{
		[set mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
	}];
}


#pragma mark - NSMutableSet

- (void)testNSMutableSet_MapUsingBlock_Correctness
{
	NSMutableSet *input = [NSMutableSet setWithObjects:@1, @2, @3, @4, @5, @6, [NSNull null], nil];
	NSMutableSet *result = [input mapUsingBlock:^BOOL(id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
		if (*obj == [NSNull null]) {
			return YES;
		}
		if ([*obj integerValue] % 2) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}
		return NO;
	}];
	NSMutableSet *reference = [NSMutableSet setWithObjects:@2, @6, @10, [NSNull null], nil];
	
	XCTAssertTrue([result isKindOfClass:NSMutableSet.class]);
	XCTAssertEqual(result.count, reference.count);
	XCTAssertEqualObjects(result, reference);
}

- (void)testFilterUsingBlock_Correctness {
	{	// works correctly
		NSMutableSet *input = [NSMutableSet setWithObjects:@1, @2, @3, @4, @5, @6, [NSNull null], nil];
		NSMutableSet *result = [input filterUsingBlock:^BOOL(id _Nullable *_Nonnull obj, BOOL *_Nonnull stop) {
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
		NSSet *reference = [NSSet setWithObjects:@2, @6, @10, nil];
		XCTAssertEqual(result, input);
		XCTAssertEqualObjects(result, reference, @"The set should contain each element multiplied by 2.");
	}
	{	//empty set
		NSMutableSet *input = [NSMutableSet set];
		NSSet *result = [input filterUsingBlock:^BOOL(id _Nullable *_Nonnull obj, BOOL *_Nonnull stop) {
			if (*obj == [NSNull null]) {
				return YES;
			}
			if ([*obj integerValue] % 2) {
				*obj = @([*obj integerValue] * 2);
				return YES;
			}
			return NO;
		}];
		
		NSSet *reference = [NSSet set];
		XCTAssertEqual(result, input);
		XCTAssertEqualObjects(result, reference, @"The result should be an empty set.");
	}
}


- (void)testFilterUsingBlock_WithNilBlock {
	NSMutableSet *input = [NSMutableSet setWithObjects:@"1", @"2", @3, [NSNull null], @[], @{}, nil];
	
	NSMutableSet *result = [input filterUsingBlock:nil];
	
	NSSet *reference = [NSSet setWithObjects:@"1", @"2", @3, [NSNull null], @[], @{}, nil];
	XCTAssertEqual(result, input);
	XCTAssertEqualObjects(result, reference);
	XCTAssertEqual(result.count, 6);
}


- (void)testFilterUsingBlock_Performance {
	NSMutableSet *set = [NSMutableSet set];
	for (NSInteger i = 0; i < 100000; i++) {
		[set addObject:@(i)];
	}
	
	[self measureBlock:^{
		[set filterUsingBlock:^BOOL(id _Nullable *_Nonnull obj, BOOL *_Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
	}];
}

@end
