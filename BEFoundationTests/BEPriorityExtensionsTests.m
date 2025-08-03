#import <XCTest/XCTest.h>
#import "BEPriorityExtensions.h"

// Test classes implementing various protocols
@interface TestPriorityItem : NSObject <BEPriorityItem>
@property (nonatomic, strong) NSNumber *itemPriority;
@property (nonatomic, copy) NSString *name;
@end

@implementation TestPriorityItem
- (instancetype)initWithPriority:(NSNumber *)priority name:(NSString *)name {
	if (self = [super init]) {
		_itemPriority = priority;
		_name = name;
	}
	return self;
}
@end

@interface TestPriorityCapture : NSObject <BEPriorityCapture>
@property (nonatomic, strong) NSNumber *itemPriority;
@property (nonatomic, copy) NSString *name;
@end

@implementation TestPriorityCapture
- (instancetype)initWithName:(NSString *)name {
	if (self = [super init]) {
		_name = name;
	}
	return self;
}
@end

@interface TestPriorityProperty : NSObject <BEPriorityProperty>
@property (nonatomic, strong) NSNumber *itemPriority;
@property (nonatomic, copy) NSString *name;
@end

@implementation TestPriorityProperty
- (instancetype)initWithPriority:(NSNumber *)priority name:(NSString *)name {
	if (self = [super init]) {
		_itemPriority = priority;
		_name = name;
	}
	return self;
}
@end

@interface TestNonPriorityObject : NSObject
@property (nonatomic, copy) NSString *name;
@end

@implementation TestNonPriorityObject
- (instancetype)initWithName:(NSString *)name {
	if (self = [super init]) {
		_name = name;
	}
	return self;
}
@end

@interface TestPriorityCaptureWithNilPriority : NSObject <BEPriorityCapture>
@property (nonatomic, strong) NSNumber *itemPriority;
@property (nonatomic, copy) NSString *name;
@end

@implementation TestPriorityCaptureWithNilPriority
- (instancetype)initWithName:(NSString *)name {
	if (self = [super init]) {
		_name = name;
		_itemPriority = nil; // Explicitly nil
	}
	return self;
}
@end

@interface TestPriorityItemWithNilPriority : NSObject <BEPriorityItem>
@property (nonatomic, strong) NSNumber *itemPriority;
@property (nonatomic, copy) NSString *name;
@end

@implementation TestPriorityItemWithNilPriority
- (instancetype)initWithName:(NSString *)name {
	if (self = [super init]) {
		_name = name;
		_itemPriority = nil; // Explicitly nil
	}
	return self;
}
@end

@interface TestBothProtocolsWithNilPriority : NSObject <BEPriorityItem, BEPriorityCapture>
@property (nonatomic, strong) NSNumber *itemPriority;
@property (nonatomic, copy) NSString *name;
@end

@implementation TestBothProtocolsWithNilPriority
- (instancetype)initWithName:(NSString *)name {
	if (self = [super init]) {
		_name = name;
		_itemPriority = nil; // Explicitly nil
	}
	return self;
}
@end

// Main test class
@interface BEPriorityExtensionsTests : XCTestCase
@end

@implementation BEPriorityExtensionsTests

#pragma mark - Constants Tests

- (void)testDefaultPriorityConstant {
	XCTAssertEqual(BEDefaultSortedItemPriority, 0);
}

#pragma mark - BEPriorityExtensionHelper Tests

- (void)testPriorityComparatorExists {
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	XCTAssertNotNil(comparator);
}

- (void)testPriorityComparatorWithBothPriorityItems {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@1 name:@"Item1"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@2 name:@"Item2"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(item1, item2);
	
	XCTAssertEqual(result, NSOrderedAscending);
}

- (void)testPriorityComparatorWithEqualPriorities {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@5 name:@"Item1"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@5 name:@"Item2"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(item1, item2);
	
	XCTAssertEqual(result, NSOrderedSame);
}

- (void)testPriorityComparatorWithDescendingOrder {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@10 name:@"Item1"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@5 name:@"Item2"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(item1, item2);
	
	XCTAssertEqual(result, NSOrderedDescending);
}

- (void)testPriorityComparatorWithNonPriorityObjects {
	TestNonPriorityObject *obj1 = [[TestNonPriorityObject alloc] initWithName:@"Obj1"];
	TestNonPriorityObject *obj2 = [[TestNonPriorityObject alloc] initWithName:@"Obj2"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(obj1, obj2);
	
	XCTAssertEqual(result, NSOrderedSame); // Both get default priority
}

- (void)testPriorityComparatorWithMixedObjects {
	TestPriorityItem *priorityItem = [[TestPriorityItem alloc] initWithPriority:@5 name:@"PriorityItem"];
	TestNonPriorityObject *nonPriorityItem = [[TestNonPriorityObject alloc] initWithName:@"NonPriorityItem"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(priorityItem, nonPriorityItem);
	
	XCTAssertEqual(result, NSOrderedDescending); // 5 > 0 (default)
}

- (void)testPriorityComparatorWithPriorityCaptureNilPriority {
	TestPriorityCaptureWithNilPriority *capture = [[TestPriorityCaptureWithNilPriority alloc] initWithName:@"Capture"];
	TestPriorityItem *item = [[TestPriorityItem alloc] initWithPriority:@5 name:@"Item"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(capture, item);
	
	// Should set default priority on capture object
	XCTAssertEqual(capture.itemPriority.integerValue, BEDefaultSortedItemPriority);
	XCTAssertEqual(result, NSOrderedAscending); // 0 < 5
}

- (void)testPriorityComparatorWithPriorityItemNilPriority {
	TestPriorityItemWithNilPriority *item = [[TestPriorityItemWithNilPriority alloc] initWithName:@"Item"];
	TestPriorityItem *normalItem = [[TestPriorityItem alloc] initWithPriority:@3 name:@"Normal"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(item, normalItem);
	
	XCTAssertEqual(result, NSOrderedAscending); // 0 (default) < 3
}

- (void)testPriorityComparatorWithBothProtocolsNilPriority {
	TestBothProtocolsWithNilPriority *both = [[TestBothProtocolsWithNilPriority alloc] initWithName:@"Both"];
	TestPriorityItem *item = [[TestPriorityItem alloc] initWithPriority:@7 name:@"Item"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(both, item);
	
	// Should set default priority and then read it
	XCTAssertEqual(both.itemPriority.integerValue, BEDefaultSortedItemPriority);
	XCTAssertEqual(result, NSOrderedAscending); // 0 < 7
}

- (void)testPriorityComparatorWithNegativePriorities {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@(-5) name:@"Item1"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@(-2) name:@"Item2"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(item1, item2);
	
	XCTAssertEqual(result, NSOrderedAscending); // -5 < -2
}

#pragma mark - NSArray Extension Tests

- (void)testNSArraySortedArrayUsingItemPriority {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@3 name:@"Item1"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@1 name:@"Item2"];
	TestPriorityItem *item3 = [[TestPriorityItem alloc] initWithPriority:@2 name:@"Item3"];
	
	NSArray *originalArray = @[item1, item2, item3];
	NSArray *sortedArray = [originalArray sortedArrayUsingItemPriority];
	
	XCTAssertEqual(sortedArray.count, 3);
	XCTAssertEqual(((TestPriorityItem *)sortedArray[0]).itemPriority.integerValue, 1);
	XCTAssertEqual(((TestPriorityItem *)sortedArray[1]).itemPriority.integerValue, 2);
	XCTAssertEqual(((TestPriorityItem *)sortedArray[2]).itemPriority.integerValue, 3);
	
	// Verify original array is unchanged
	XCTAssertEqual(((TestPriorityItem *)originalArray[0]).itemPriority.integerValue, 3);
}

- (void)testNSArraySortedArrayWithEmptyArray {
	NSArray *emptyArray = @[];
	NSArray *sortedArray = [emptyArray sortedArrayUsingItemPriority];
	
	XCTAssertEqual(sortedArray.count, 0);
}

- (void)testNSArraySortedArrayWithMixedObjects {
	TestPriorityItem *priorityItem = [[TestPriorityItem alloc] initWithPriority:@5 name:@"Priority"];
	TestNonPriorityObject *nonPriorityItem = [[TestNonPriorityObject alloc] initWithName:@"NonPriority"];
	TestPriorityCaptureWithNilPriority *captureItem = [[TestPriorityCaptureWithNilPriority alloc] initWithName:@"Capture"];
	
	NSArray *mixedArray = @[priorityItem, nonPriorityItem, captureItem];
	NSArray *sortedArray = [mixedArray sortedArrayUsingItemPriority];
	
	XCTAssertEqual(sortedArray.count, 3);
	// captureItem and nonPriorityItem should be first (priority 0), then priorityItem (priority 5)
	XCTAssertTrue([sortedArray[2] isKindOfClass:[TestPriorityItem class]]);
	XCTAssertEqual(((TestPriorityItem *)sortedArray[2]).itemPriority.integerValue, 5);
}

#pragma mark - NSMutableArray Extension Tests

- (void)testNSMutableArraySortArrayUsingItemPriority {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@8 name:@"Item1"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@2 name:@"Item2"];
	TestPriorityItem *item3 = [[TestPriorityItem alloc] initWithPriority:@5 name:@"Item3"];
	
	NSMutableArray *mutableArray = [NSMutableArray arrayWithObjects:item1, item2, item3, nil];
	[mutableArray sortArrayUsingItemPriority];
	
	XCTAssertEqual(mutableArray.count, 3);
	XCTAssertEqual(((TestPriorityItem *)mutableArray[0]).itemPriority.integerValue, 2);
	XCTAssertEqual(((TestPriorityItem *)mutableArray[1]).itemPriority.integerValue, 5);
	XCTAssertEqual(((TestPriorityItem *)mutableArray[2]).itemPriority.integerValue, 8);
}

- (void)testNSMutableArraySortWithEmptyArray {
	NSMutableArray *emptyArray = [NSMutableArray array];
	[emptyArray sortArrayUsingItemPriority];
	
	XCTAssertEqual(emptyArray.count, 0);
}

- (void)testNSMutableArraySortWithSingleItem {
	TestPriorityItem *singleItem = [[TestPriorityItem alloc] initWithPriority:@42 name:@"Single"];
	NSMutableArray *singleArray = [NSMutableArray arrayWithObject:singleItem];
	
	[singleArray sortArrayUsingItemPriority];
	
	XCTAssertEqual(singleArray.count, 1);
	XCTAssertEqual(((TestPriorityItem *)singleArray[0]).itemPriority.integerValue, 42);
}

#pragma mark - NSOrderedSet Extension Tests

- (void)testNSOrderedSetSortedArrayUsingItemPriority {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@9 name:@"Item1"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@1 name:@"Item2"];
	TestPriorityItem *item3 = [[TestPriorityItem alloc] initWithPriority:@4 name:@"Item3"];
	
	NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithObjects:item1, item2, item3, nil];
	NSArray *sortedArray = [orderedSet sortedArrayUsingItemPriority];
	
	XCTAssertEqual(sortedArray.count, 3);
	XCTAssertEqual(((TestPriorityItem *)sortedArray[0]).itemPriority.integerValue, 1);
	XCTAssertEqual(((TestPriorityItem *)sortedArray[1]).itemPriority.integerValue, 4);
	XCTAssertEqual(((TestPriorityItem *)sortedArray[2]).itemPriority.integerValue, 9);
	
	// Verify original ordered set is unchanged
	XCTAssertEqual(((TestPriorityItem *)orderedSet[0]).itemPriority.integerValue, 9);
}

- (void)testNSOrderedSetSortedArrayWithEmptySet {
	NSOrderedSet *emptySet = [NSOrderedSet orderedSet];
	NSArray *sortedArray = [emptySet sortedArrayUsingItemPriority];
	
	XCTAssertEqual(sortedArray.count, 0);
}

- (void)testNSOrderedSetSortedArrayWithDuplicates {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@3 name:@"Item1"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@3 name:@"Item2"];
	TestPriorityItem *item3 = [[TestPriorityItem alloc] initWithPriority:@1 name:@"Item3"];
	
	NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithObjects:item1, item2, item3, nil];
	NSArray *sortedArray = [orderedSet sortedArrayUsingItemPriority];
	
	XCTAssertEqual(sortedArray.count, 3);
	XCTAssertEqual(((TestPriorityItem *)sortedArray[0]).itemPriority.integerValue, 1);
	XCTAssertEqual(((TestPriorityItem *)sortedArray[1]).itemPriority.integerValue, 3);
	XCTAssertEqual(((TestPriorityItem *)sortedArray[2]).itemPriority.integerValue, 3);
}

#pragma mark - NSMutableOrderedSet Extension Tests

- (void)testNSMutableOrderedSetSortOrderedSetUsingItemPriority {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@7 name:@"Item1"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@3 name:@"Item2"];
	TestPriorityItem *item3 = [[TestPriorityItem alloc] initWithPriority:@9 name:@"Item3"];
	
	NSMutableOrderedSet *mutableSet = [NSMutableOrderedSet orderedSetWithObjects:item1, item2, item3, nil];
	[mutableSet sortOrderedSetUsingItemPriority];
	
	XCTAssertEqual(mutableSet.count, 3);
	XCTAssertEqual(((TestPriorityItem *)mutableSet[0]).itemPriority.integerValue, 3);
	XCTAssertEqual(((TestPriorityItem *)mutableSet[1]).itemPriority.integerValue, 7);
	XCTAssertEqual(((TestPriorityItem *)mutableSet[2]).itemPriority.integerValue, 9);
}

- (void)testNSMutableOrderedSetSortWithEmptySet {
	NSMutableOrderedSet *emptySet = [NSMutableOrderedSet orderedSet];
	[emptySet sortOrderedSetUsingItemPriority];
	
	XCTAssertEqual(emptySet.count, 0);
}

- (void)testNSMutableOrderedSetSortWithMixedObjects {
	TestPriorityProperty *propertyItem = [[TestPriorityProperty alloc] initWithPriority:@6 name:@"Property"];
	TestNonPriorityObject *nonPriorityItem = [[TestNonPriorityObject alloc] initWithName:@"NonPriority"];
	TestPriorityCapture *captureItem = [[TestPriorityCapture alloc] initWithName:@"Capture"];
	
	NSMutableOrderedSet *mixedSet = [NSMutableOrderedSet orderedSetWithObjects:propertyItem, nonPriorityItem, captureItem, nil];
	[mixedSet sortOrderedSetUsingItemPriority];
	
	XCTAssertEqual(mixedSet.count, 3);
	// captureItem and nonPriorityItem should be first (priority 0), then propertyItem (priority 6)
	XCTAssertTrue([mixedSet[2] isKindOfClass:[TestPriorityProperty class]]);
	XCTAssertEqual(((TestPriorityProperty *)mixedSet[2]).itemPriority.integerValue, 6);
}

#pragma mark - Edge Cases and Stability Tests

- (void)testStableSortWithEqualPriorities {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@5 name:@"First"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@5 name:@"Second"];
	TestPriorityItem *item3 = [[TestPriorityItem alloc] initWithPriority:@5 name:@"Third"];
	
	NSArray *originalArray = @[item1, item2, item3];
	NSArray *sortedArray = [originalArray sortedArrayUsingItemPriority];
	
	// Due to stable sort, original order should be preserved for equal priorities
	XCTAssertEqualObjects(((TestPriorityItem *)sortedArray[0]).name, @"First");
	XCTAssertEqualObjects(((TestPriorityItem *)sortedArray[1]).name, @"Second");
	XCTAssertEqualObjects(((TestPriorityItem *)sortedArray[2]).name, @"Third");
}

- (void)testComparatorWithZeroPriorities {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@0 name:@"Zero1"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@0 name:@"Zero2"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(item1, item2);
	
	XCTAssertEqual(result, NSOrderedSame);
}

- (void)testComparatorWithFloatingPointPriorities {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@1.5 name:@"Float1"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@1.7 name:@"Float2"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(item1, item2);
	
	XCTAssertEqual(result, NSOrderedAscending);
}

- (void)testPriorityCaptureSetsDefaultCorrectly {
	TestPriorityCapture *capture = [[TestPriorityCapture alloc] initWithName:@"Test"];
	XCTAssertNil(capture.itemPriority); // Initially nil
	
	TestPriorityItem *item = [[TestPriorityItem alloc] initWithPriority:@1 name:@"Item"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	comparator(capture, item);
	
	XCTAssertNotNil(capture.itemPriority);
	XCTAssertEqual(capture.itemPriority.integerValue, BEDefaultSortedItemPriority);
}

- (void)testLargeNumberPriorities {
	TestPriorityItem *item1 = [[TestPriorityItem alloc] initWithPriority:@(NSIntegerMax) name:@"Max"];
	TestPriorityItem *item2 = [[TestPriorityItem alloc] initWithPriority:@(NSIntegerMin) name:@"Min"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(item1, item2);
	
	XCTAssertEqual(result, NSOrderedDescending);
}

- (void)testProtocolConformanceChecking {
	// Test that protocol conformance is checked correctly
	TestPriorityItem *priorityItem = [[TestPriorityItem alloc] initWithPriority:@5 name:@"Priority"];
	TestPriorityCapture *captureItem = [[TestPriorityCapture alloc] initWithName:@"Capture"];
	TestPriorityProperty *propertyItem = [[TestPriorityProperty alloc] initWithPriority:@3 name:@"Property"];
	TestNonPriorityObject *nonPriorityItem = [[TestNonPriorityObject alloc] initWithName:@"NonPriority"];
	
	// Verify protocol conformance
	XCTAssertTrue([priorityItem conformsToProtocol:@protocol(BEPriorityItem)]);
	XCTAssertFalse([priorityItem conformsToProtocol:@protocol(BEPriorityCapture)]);
	
	XCTAssertFalse([captureItem conformsToProtocol:@protocol(BEPriorityItem)]);
	XCTAssertTrue([captureItem conformsToProtocol:@protocol(BEPriorityCapture)]);
	
	XCTAssertTrue([propertyItem conformsToProtocol:@protocol(BEPriorityItem)]);
	XCTAssertTrue([propertyItem conformsToProtocol:@protocol(BEPriorityCapture)]);
	XCTAssertTrue([propertyItem conformsToProtocol:@protocol(BEPriorityProperty)]);
	
	XCTAssertFalse([nonPriorityItem conformsToProtocol:@protocol(BEPriorityItem)]);
	XCTAssertFalse([nonPriorityItem conformsToProtocol:@protocol(BEPriorityCapture)]);
	XCTAssertFalse([nonPriorityItem conformsToProtocol:@protocol(BEPriorityProperty)]);
}

- (void)testPriorityComparatorSecondObjectPriorityItemPath {
	// Specifically test the case where obj2 is a BEPriorityItem to cover the line:
	// if (bPriorityItem) { b = [obj2 itemPriority]; }
	TestNonPriorityObject *nonPriorityObj = [[TestNonPriorityObject alloc] initWithName:@"NonPriority"];
	TestPriorityItem *priorityItem = [[TestPriorityItem alloc] initWithPriority:@7 name:@"Priority"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(nonPriorityObj, priorityItem);
	
	// nonPriorityObj gets default priority (0), priorityItem has priority 7
	XCTAssertEqual(result, NSOrderedAscending); // 0 < 7
}

- (void)testPriorityComparatorSecondObjectPriorityItemWithNilPriority {
	// Test the case where obj2 is a BEPriorityItem but returns nil priority
	TestNonPriorityObject *nonPriorityObj = [[TestNonPriorityObject alloc] initWithName:@"NonPriority"];
	TestPriorityItemWithNilPriority *nilPriorityItem = [[TestPriorityItemWithNilPriority alloc] initWithName:@"NilPriority"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(nonPriorityObj, nilPriorityItem);
	
	// Both should get default priority (0)
	XCTAssertEqual(result, NSOrderedSame); // 0 == 0
}

- (void)testPriorityComparatorSecondObjectBothProtocolsPath {
	// Test where obj2 implements both BEPriorityItem and BEPriorityCapture
	// This ensures the "if (bPriorityItem)" path is taken after setting default priority
	TestNonPriorityObject *nonPriorityObj = [[TestNonPriorityObject alloc] initWithName:@"NonPriority"];
	TestBothProtocolsWithNilPriority *bothProtocols = [[TestBothProtocolsWithNilPriority alloc] initWithName:@"Both"];
	
	NSComparator comparator = BEPriorityExtensionHelper.priorityComparator;
	NSComparisonResult result = comparator(nonPriorityObj, bothProtocols);
	
	// bothProtocols should get default priority set, then read via BEPriorityItem
	XCTAssertEqual(bothProtocols.itemPriority.integerValue, BEDefaultSortedItemPriority);
	XCTAssertEqual(result, NSOrderedSame); // 0 == 0
}

@end
