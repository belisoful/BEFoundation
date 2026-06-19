/*!
 @file			BEStackExtensionsTests.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract		Unit tests for the NSMutableArray/NSMutableOrderedSet stack & queue categories.
*/

#import <XCTest/XCTest.h>
#import "BEStackExtensions.h"

@interface BEStackExtensionsTests : XCTestCase
@end

@implementation BEStackExtensionsTests

#pragma mark - NSMutableArray

- (void)testArrayPushAddsAndChains {
	NSMutableArray *stack = [NSMutableArray array];
	NSMutableArray *returned = [stack push:@"a"];
	XCTAssertEqual(returned, stack, @"push: returns self for chaining");
	[[stack push:@"b"] push:@"c"];
	XCTAssertEqualObjects(stack, (@[@"a", @"b", @"c"]));
}

- (void)testArrayPushNilIsIgnored {
	NSMutableArray *stack = [NSMutableArray arrayWithObject:@"a"];
	[stack push:nil];
	XCTAssertEqualObjects(stack, (@[@"a"]));
}

- (void)testArrayPushObjectsVariadic {
	NSMutableArray *stack = [NSMutableArray array];
	[stack pushObjects:@"a", @"b", @"c", nil];
	XCTAssertEqualObjects(stack, (@[@"a", @"b", @"c"]));
}

- (void)testArrayPushArrayAndNil {
	NSMutableArray *stack = [NSMutableArray arrayWithObject:@"a"];
	[stack pushArray:@[@"b", @"c"]];
	XCTAssertEqualObjects(stack, (@[@"a", @"b", @"c"]));
	[stack pushArray:nil];
	XCTAssertEqualObjects(stack, (@[@"a", @"b", @"c"]));
}

- (void)testArrayPopIsLIFO {
	NSMutableArray *stack = [NSMutableArray arrayWithArray:@[@"a", @"b", @"c"]];
	XCTAssertEqualObjects([stack pop], @"c");
	XCTAssertEqualObjects([stack pop], @"b");
	XCTAssertEqualObjects([stack pop], @"a");
	XCTAssertNil([stack pop], @"pop on empty returns nil");
	XCTAssertEqual(stack.count, 0);
}

- (void)testArrayShiftIsFIFO {
	NSMutableArray *queue = [NSMutableArray arrayWithArray:@[@"a", @"b", @"c"]];
	XCTAssertEqualObjects([queue shift], @"a");
	XCTAssertEqualObjects([queue shift], @"b");
	XCTAssertEqualObjects([queue shift], @"c");
	XCTAssertNil([queue shift], @"shift on empty returns nil");
}

#pragma mark - NSMutableOrderedSet

- (void)testOrderedSetIsPushOnTopDefaultsYES {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
	XCTAssertTrue(set.isPushOnTop);
}

- (void)testOrderedSetPushOnTopMovesExistingToEnd {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithArray:@[@"a", @"b", @"c"]];
	XCTAssertTrue(set.isPushOnTop);
	[set push:@"a"];   // already present -> moved to the end
	XCTAssertEqualObjects(set.array, (@[@"b", @"c", @"a"]));
}

- (void)testOrderedSetPushNotOnTopLeavesExistingInPlace {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithArray:@[@"a", @"b", @"c"]];
	set.isPushOnTop = NO;
	[set push:@"a"];   // already present -> position unchanged
	XCTAssertEqualObjects(set.array, (@[@"a", @"b", @"c"]));
	[set push:@"d"];   // new -> appended
	XCTAssertEqualObjects(set.array, (@[@"a", @"b", @"c", @"d"]));
}

- (void)testOrderedSetPushNilIgnoredAndChains {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
	NSMutableOrderedSet *returned = [set push:@"a"];
	XCTAssertEqual(returned, set);
	[set push:nil];
	XCTAssertEqualObjects(set.array, (@[@"a"]));
}

- (void)testOrderedSetPushObjectsAndArray {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
	[set pushObjects:@"a", @"b", nil];
	[set pushArray:@[@"c", @"a"]];   // isPushOnTop default YES -> "a" moves to end
	XCTAssertEqualObjects(set.array, (@[@"b", @"c", @"a"]));
}

- (void)testOrderedSetPushArrayNotOnTopKeepsExistingPositions {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithArray:@[@"a", @"b", @"c"]];
	set.isPushOnTop = NO;
	[set pushArray:@[@"c", @"d"]];   // "c" already present stays put; "d" appended
	XCTAssertEqualObjects(set.array, (@[@"a", @"b", @"c", @"d"]));
}

- (void)testOrderedSetPushObjectsRespectsIsPushOnTop {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithArray:@[@"a", @"b"]];
	[set pushObjects:@"a", @"c", nil];   // isPushOnTop YES: "a" moves to end, "c" appended
	XCTAssertEqualObjects(set.array, (@[@"b", @"a", @"c"]));
}

- (void)testOrderedSetPushArrayWithDuplicatesStaysUnique {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
	[set pushArray:@[@"d", @"d", @"e"]];   // an ordered set never holds duplicates
	XCTAssertEqualObjects(set.array, (@[@"d", @"e"]));
}

- (void)testOrderedSetPopAndShift {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithArray:@[@"a", @"b", @"c"]];
	XCTAssertEqualObjects([set pop], @"c");
	XCTAssertEqualObjects([set shift], @"a");
	XCTAssertEqualObjects(set.array, (@[@"b"]));
	XCTAssertEqualObjects([set pop], @"b");
	XCTAssertNil([set pop]);
	XCTAssertNil([set shift]);
}

@end
