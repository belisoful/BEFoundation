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
	NSMutableArray *returned = [stack pushObject:@"a"];
	XCTAssertEqual(returned, stack, @"pushObject: returns self for chaining");
	[[stack pushObject:@"b"] pushObject:@"c"];
	XCTAssertEqualObjects(stack, (@[@"a", @"b", @"c"]));
}

- (void)testArrayPushNilIsIgnored {
	NSMutableArray *stack = [NSMutableArray arrayWithObject:@"a"];
	[stack pushObject:nil];
	XCTAssertEqualObjects(stack, (@[@"a"]));
}

- (void)testArrayPushObjectsVariadic {
	NSMutableArray *stack = [NSMutableArray array];
	[stack pushObjects:@"a", @"b", @"c", nil];
	XCTAssertEqualObjects(stack, (@[@"a", @"b", @"c"]));
}

- (void)testArrayPushObjectsNilFirstArgIsIgnored {
	NSMutableArray *stack = [NSMutableArray array];
	[stack pushObjects:nil];
	XCTAssertEqual(stack.count, 0u);
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
	XCTAssertEqualObjects([stack popObject], @"c");
	XCTAssertEqualObjects([stack popObject], @"b");
	XCTAssertEqualObjects([stack popObject], @"a");
	XCTAssertNil([stack popObject], @"popObject on empty returns nil");
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
	[set pushObject:@"a"];   // already present -> moved to the end
	XCTAssertEqualObjects(set.array, (@[@"b", @"c", @"a"]));
}

- (void)testOrderedSetPushNotOnTopLeavesExistingInPlace {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithArray:@[@"a", @"b", @"c"]];
	set.isPushOnTop = NO;
	[set pushObject:@"a"];   // already present -> position unchanged
	XCTAssertEqualObjects(set.array, (@[@"a", @"b", @"c"]));
	[set pushObject:@"d"];   // new -> appended
	XCTAssertEqualObjects(set.array, (@[@"a", @"b", @"c", @"d"]));
}

- (void)testOrderedSetPushNilIgnoredAndChains {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
	NSMutableOrderedSet *returned = [set pushObject:@"a"];
	XCTAssertEqual(returned, set);
	[set pushObject:nil];
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

- (void)testOrderedSetPushObjectsNilFirstArgAndPushArrayNilAreIgnored {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
	[set pushObjects:nil];
	[set pushArray:nil];
	XCTAssertEqual(set.count, 0u);
}

- (void)testOrderedSetPopAndShift {
	NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithArray:@[@"a", @"b", @"c"]];
	XCTAssertEqualObjects([set popObject], @"c");
	XCTAssertEqualObjects([set shift], @"a");
	XCTAssertEqualObjects(set.array, (@[@"b"]));
	XCTAssertEqualObjects([set popObject], @"b");
	XCTAssertNil([set popObject]);
	XCTAssertNil([set shift]);
}

@end
