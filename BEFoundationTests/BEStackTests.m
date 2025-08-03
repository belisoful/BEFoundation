//
//  BFoundationExtensionTests.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import "BEStackExtensions.h" // Assuming these are in a separate header

@interface BEStackTests : XCTestCase

@end

@implementation BEStackTests

- (void)setUp {
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

#pragma mark - NSMutableArray (StackAdditions) Tests

- (void)testNSMutableArray_Push {
	NSMutableArray *array = [NSMutableArray array];
	XCTAssertEqual(array.count, 0, @"Array should be empty initially.");

	[array push:@"Object1"];
	XCTAssertEqual(array.count, 1, @"Array count should be 1 after push.");
	XCTAssertEqualObjects([array lastObject], @"Object1", @"Pushed object should be the last object.");

	[array push:@"Object2"];
	XCTAssertEqual(array.count, 2, @"Array count should be 2 after second push.");
	XCTAssertEqualObjects([array lastObject], @"Object2", @"Second pushed object should be the new last object.");
}

- (void)testNSMutableArray_PushNil {
	NSMutableArray *array = [NSMutableArray array];
	[array push:nil];
	XCTAssertEqual(array.count, 0, @"Pushing nil should not add an object to the array.");
}

- (void)testNSMutableArray_PushObjects {
	NSMutableArray *array = [NSMutableArray array];
	XCTAssertEqual(array.count, 0, @"Array should be empty initially.");

	[array pushObjects:@"Object1", @"Object2", nil];
	XCTAssertEqual(array.count, 2, @"Array count should be 1 after push.");
	XCTAssertEqualObjects([array lastObject], @"Object2", @"Pushed object should be the last object.");

	[array pushObjects:@"Object3", @"Object4", nil];
	XCTAssertEqual(array.count, 4, @"Array count should be 4 after second push.");
	XCTAssertEqualObjects([array lastObject], @"Object4", @"Second pushed object should be the new last object.");
}

- (void)testNSMutableArray_PushArray {
	NSMutableArray *array = [NSMutableArray array];
	XCTAssertEqual(array.count, 0, @"Array should be empty initially.");

	[array pushArray:@[@"Object1", @"Object2"]];
	XCTAssertEqual(array.count, 2, @"Array count should be 1 after push.");
	XCTAssertEqualObjects([array lastObject], @"Object2", @"Pushed object should be the last object.");

	[array pushArray:@[@"Object3", @"Object4"]];
	XCTAssertEqual(array.count, 4, @"Array count should be 4 after second push.");
	XCTAssertEqualObjects([array lastObject], @"Object4", @"Second pushed object should be the new last object.");
}

- (void)testNSMutableArray_Pop {
	NSMutableArray *array = [NSMutableArray arrayWithArray:@[@"Object1", @"Object2", @"Object3"]];
	XCTAssertEqual(array.count, 3, @"Array should have 3 objects initially.");

	id poppedObject = [array pop];
	XCTAssertEqualObjects(poppedObject, @"Object3", @"Pop should return the last object.");
	XCTAssertEqual(array.count, 2, @"Array count should be 2 after pop.");
	XCTAssertEqualObjects([array lastObject], @"Object2", @"New last object should be Object2.");

	poppedObject = [array pop];
	XCTAssertEqualObjects(poppedObject, @"Object2", @"Pop should return the new last object.");
	XCTAssertEqual(array.count, 1, @"Array count should be 1 after second pop.");

	poppedObject = [array pop];
	XCTAssertEqualObjects(poppedObject, @"Object1", @"Pop should return the only remaining object.");
	XCTAssertEqual(array.count, 0, @"Array should be empty after all objects are popped.");
}

- (void)testNSMutableArray_PopEmpty {
	NSMutableArray *array = [NSMutableArray array];
	id poppedObject = [array pop];
	XCTAssertNil(poppedObject, @"Pop on an empty array should return nil.");
	XCTAssertEqual(array.count, 0, @"Array should remain empty.");
}

- (void)testNSMutableArray_Shift {
	NSMutableArray *array = [NSMutableArray arrayWithArray:@[@"Object1", @"Object2", @"Object3"]];
	XCTAssertEqual(array.count, 3, @"Array should have 3 objects initially.");

	id shiftedObject = [array shift];
	XCTAssertEqualObjects(shiftedObject, @"Object1", @"Shift should return the first object.");
	XCTAssertEqual(array.count, 2, @"Array count should be 2 after shift.");
	XCTAssertEqualObjects([array firstObject], @"Object2", @"New first object should be Object2.");

	shiftedObject = [array shift];
	XCTAssertEqualObjects(shiftedObject, @"Object2", @"Shift should return the new first object.");
	XCTAssertEqual(array.count, 1, @"Array count should be 1 after second shift.");

	shiftedObject = [array shift];
	XCTAssertEqualObjects(shiftedObject, @"Object3", @"Shift should return the only remaining object.");
	XCTAssertEqual(array.count, 0, @"Array should be empty after all objects are shifted.");
}

- (void)testNSMutableArray_ShiftEmpty {
	NSMutableArray *array = [NSMutableArray array];
	id shiftedObject = [array shift];
	XCTAssertNil(shiftedObject, @"Shift on an empty array should return nil.");
	XCTAssertEqual(array.count, 0, @"Array should remain empty.");
}

- (void)testNSMutableArray_StackAndQueueBehavior {
	NSMutableArray *array = [NSMutableArray array];

	// Push elements
	[[array push:@"A"] push:@"B"]; // A, B
	XCTAssertEqualObjects([array lastObject], @"B");
	XCTAssertEqualObjects([array firstObject], @"A");
	XCTAssertEqual(array.count, 2);

	// Pop one
	id popped = [array pop]; // A
	XCTAssertEqualObjects(popped, @"B");
	XCTAssertEqual(array.count, 1);
	XCTAssertEqualObjects([array lastObject], @"A");

	// Push another
	[array push:@"C"]; // A, C
	XCTAssertEqualObjects([array lastObject], @"C");
	XCTAssertEqual(array.count, 2);

	// Shift one
	id shifted = [array shift]; // C
	XCTAssertEqualObjects(shifted, @"A");
	XCTAssertEqual(array.count, 1);
	XCTAssertEqualObjects([array lastObject], @"C");

	// Pop the last one
	popped = [array pop]; //
	XCTAssertEqualObjects(popped, @"C");
	XCTAssertEqual(array.count, 0);

	XCTAssertNil([array pop]);
	XCTAssertNil([array shift]);
}


#pragma mark - NSMutableOrderedSet (StackAdditions) Tests

- (void)testNSMutableOrderedSet_IsPushOnTop_Default {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	XCTAssertTrue(orderedSet.isPushOnTop, @"isPushOnTop should default to YES.");
}

- (void)testNSMutableOrderedSet_SetIsPushOnTop {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	orderedSet.isPushOnTop = NO;
	XCTAssertFalse(orderedSet.isPushOnTop, @"isPushOnTop should be NO after setting.");
	orderedSet.isPushOnTop = YES;
	XCTAssertTrue(orderedSet.isPushOnTop, @"isPushOnTop should be YES after setting.");
}

- (void)testNSMutableOrderedSet_Push_IsPushOnTopYES {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	orderedSet.isPushOnTop = YES; // Default behavior, but explicit for clarity

	[orderedSet push:@"Object1"];
	XCTAssertEqual(orderedSet.count, 1, @"Ordered set count should be 1 after push.");
	XCTAssertEqualObjects([orderedSet lastObject], @"Object1", @"Pushed object should be the last object.");
	XCTAssertEqualObjects([orderedSet objectAtIndex:0], @"Object1", @"Pushed object should be at index 0.");

	[orderedSet push:@"Object2"];
	XCTAssertEqual(orderedSet.count, 2, @"Ordered set count should be 2 after second push.");
	XCTAssertEqualObjects([orderedSet lastObject], @"Object2", @"Second pushed object should be the new last object.");
	XCTAssertEqualObjects([orderedSet objectAtIndex:0], @"Object1", @"First object should remain at index 0.");

	// Push a duplicate when isPushOnTop is YES: should move to end
	[orderedSet push:@"Object1"];
	XCTAssertEqual(orderedSet.count, 2, @"Ordered set count should remain 2 after pushing a duplicate.");
	XCTAssertEqualObjects([orderedSet lastObject], @"Object1", @"Duplicate object should be moved to the end.");
	XCTAssertEqualObjects([orderedSet objectAtIndex:0], @"Object2", @"Original last object should now be first.");

	// Sequence check: Object2, Object1
	XCTAssertEqualObjects([orderedSet array], (@[@"Object2", @"Object1"]));
}

- (void)testNSMutableOrderedSet_Push_IsPushOnTopNO {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	orderedSet.isPushOnTop = NO;

	[orderedSet push:@"Object1"];
	XCTAssertEqual(orderedSet.count, 1, @"Ordered set count should be 1 after push.");
	XCTAssertEqualObjects([orderedSet lastObject], @"Object1", @"Pushed object should be the last object.");

	[orderedSet push:@"Object2"];
	XCTAssertEqual(orderedSet.count, 2, @"Ordered set count should be 2 after second push.");
	XCTAssertEqualObjects([orderedSet lastObject], @"Object2", @"Second pushed object should be the new last object.");

	// Push a duplicate when isPushOnTop is NO: should NOT move to end
	[orderedSet push:@"Object1"];
	XCTAssertEqual(orderedSet.count, 2, @"Ordered set count should remain 2 after pushing a duplicate.");
	XCTAssertEqualObjects([orderedSet lastObject], @"Object2", @"Duplicate object should NOT be moved to the end when isPushOnTop is NO.");
	XCTAssertEqualObjects([orderedSet firstObject], @"Object1", @"Duplicate object should remain at its original position.");

	// Sequence check: Object1, Object2
	XCTAssertEqualObjects([orderedSet array], (@[@"Object1", @"Object2"]));
}

- (void)testNSMutableOrderedSet_PushNil {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	[orderedSet push:nil];
	XCTAssertEqual(orderedSet.count, 0, @"Pushing nil should not add an object to the ordered set.");
}

- (void)testNSMutableOrderedSet_PushObjects_IsPushOnTopYES {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	orderedSet.isPushOnTop = YES; // Default behavior, but explicit for clarity

	[orderedSet pushObjects:@"Object1", @"Object2", @"Object3", nil];
	XCTAssertEqual(orderedSet.count, 3, @"Ordered set count should be 3 after push.");
	XCTAssertEqualObjects([orderedSet lastObject], @"Object3", @"Last pushed object should be the last object.");
	XCTAssertEqualObjects([orderedSet objectAtIndex:0], @"Object1", @"First pushed object should be at index 0.");

	[orderedSet pushObjects:@"Object2", @"Object4", nil];
	XCTAssertEqual(orderedSet.count, 4, @"Ordered set count should be 4 after second push.");

	// Sequence check: Object1, Object3, Object2, Object4
	XCTAssertEqualObjects([orderedSet array], (@[@"Object1", @"Object3", @"Object2", @"Object4"]));
}

- (void)testNSMutableOrderedSet_PushObjects_IsPushOnTopNO {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	orderedSet.isPushOnTop = NO;

	[orderedSet pushObjects:@"Object1", @"Object2", @"Object3", nil];
	XCTAssertEqual(orderedSet.count, 3, @"Ordered set count should be 3 after push.");
	XCTAssertEqualObjects([orderedSet lastObject], @"Object3", @"Last pushed object should be the last object.");
	XCTAssertEqualObjects([orderedSet objectAtIndex:0], @"Object1", @"First pushed object should be at index 0.");

	[orderedSet pushObjects:@"Object2", @"Object4", nil];
	XCTAssertEqual(orderedSet.count, 4, @"Ordered set count should be 4 after second push.");

	// Sequence check: Object1, Object3, Object2, Object4
	XCTAssertEqualObjects([orderedSet array], (@[@"Object1", @"Object2", @"Object3", @"Object4"]));
}

- (void)testNSMutableOrderedSet_PushArray_IsPushOnTopYES {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	orderedSet.isPushOnTop = YES; // Default behavior, but explicit for clarity

	[orderedSet pushArray:@[@"Object1", @"Object2", @"Object3"]];
	XCTAssertEqual(orderedSet.count, 3, @"Ordered set count should be 3 after push.");
	XCTAssertEqualObjects([orderedSet lastObject], @"Object3", @"Last pushed object should be the last object.");
	XCTAssertEqualObjects([orderedSet objectAtIndex:0], @"Object1", @"First pushed object should be at index 0.");

	[orderedSet pushArray:@[@"Object2", @"Object4"]];
	XCTAssertEqual(orderedSet.count, 4, @"Ordered set count should be 4 after second push.");

	// Sequence check: Object1, Object3, Object2, Object4
	XCTAssertEqualObjects([orderedSet array], (@[@"Object1", @"Object3", @"Object2", @"Object4"]));
}

- (void)testNSMutableOrderedSet_PushArray_IsPushOnTopNO {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	orderedSet.isPushOnTop = NO;

	[orderedSet pushArray:@[@"Object1", @"Object2", @"Object3"]];
	XCTAssertEqual(orderedSet.count, 3, @"Ordered set count should be 1 after push.");
	XCTAssertEqualObjects([orderedSet lastObject], @"Object3", @"Last pushed object should be the last object.");
	XCTAssertEqualObjects([orderedSet objectAtIndex:0], @"Object1", @"First pushed object should be at index 0.");

	[orderedSet pushArray:@[@"Object2", @"Object4"]];
	XCTAssertEqual(orderedSet.count, 4, @"Ordered set count should be 4 after second push.");

	// Sequence check: Object1, Object3, Object2, Object4
	XCTAssertEqualObjects([orderedSet array], (@[@"Object1", @"Object2", @"Object3", @"Object4"]));
}

- (void)testNSMutableOrderedSet_Pop {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithArray:@[@"Object1", @"Object2", @"Object3"]];
	XCTAssertEqual(orderedSet.count, 3, @"Ordered set should have 3 objects initially.");

	id poppedObject = [orderedSet pop];
	XCTAssertEqualObjects(poppedObject, @"Object3", @"Pop should return the last object.");
	XCTAssertEqual(orderedSet.count, 2, @"Ordered set count should be 2 after pop.");
	XCTAssertEqualObjects([orderedSet lastObject], @"Object2", @"New last object should be Object2.");

	poppedObject = [orderedSet pop];
	XCTAssertEqualObjects(poppedObject, @"Object2", @"Pop should return the new last object.");
	XCTAssertEqual(orderedSet.count, 1, @"Ordered set count should be 1 after second pop.");

	poppedObject = [orderedSet pop];
	XCTAssertEqualObjects(poppedObject, @"Object1", @"Pop should return the only remaining object.");
	XCTAssertEqual(orderedSet.count, 0, @"Ordered set should be empty after all objects are popped.");
}

- (void)testNSMutableOrderedSet_PopEmpty {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	id poppedObject = [orderedSet pop];
	XCTAssertNil(poppedObject, @"Pop on an empty ordered set should return nil.");
	XCTAssertEqual(orderedSet.count, 0, @"Ordered set should remain empty.");
}

- (void)testNSMutableOrderedSet_Shift {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithArray:@[@"Object1", @"Object2", @"Object3"]];
	XCTAssertEqual(orderedSet.count, 3, @"Ordered set should have 3 objects initially.");

	id shiftedObject = [orderedSet shift];
	XCTAssertEqualObjects(shiftedObject, @"Object1", @"Shift should return the first object.");
	XCTAssertEqual(orderedSet.count, 2, @"Ordered set count should be 2 after shift.");
	XCTAssertEqualObjects([orderedSet firstObject], @"Object2", @"New first object should be Object2.");

	shiftedObject = [orderedSet shift];
	XCTAssertEqualObjects(shiftedObject, @"Object2", @"Shift should return the new first object.");
	XCTAssertEqual(orderedSet.count, 1, @"Ordered set count should be 1 after second shift.");

	shiftedObject = [orderedSet shift];
	XCTAssertEqualObjects(shiftedObject, @"Object3", @"Shift should return the only remaining object.");
	XCTAssertEqual(orderedSet.count, 0, @"Ordered set should be empty after all objects are shifted.");
}

- (void)testNSMutableOrderedSet_ShiftEmpty {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	id shiftedObject = [orderedSet shift];
	XCTAssertNil(shiftedObject, @"Shift on an empty ordered set should return nil.");
	XCTAssertEqual(orderedSet.count, 0, @"Ordered set should remain empty.");
}

- (void)testNSMutableOrderedSet_StackAndQueueBehavior {
	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
	orderedSet.isPushOnTop = YES; // Default behavior

	// Push elements
	[[orderedSet push:@"A"] push:@"B"]; // A, B
	XCTAssertEqualObjects([orderedSet lastObject], @"B");
	XCTAssertEqualObjects([orderedSet firstObject], @"A");
	XCTAssertEqual(orderedSet.count, 2);

	// Pop one
	id popped = [orderedSet pop]; // A
	XCTAssertEqualObjects(popped, @"B");
	XCTAssertEqual(orderedSet.count, 1);
	XCTAssertEqualObjects([orderedSet lastObject], @"A");

	// Push another (duplicate, moves to top)
	[orderedSet push:@"A"]; // A
	XCTAssertEqualObjects([orderedSet lastObject], @"A");
	XCTAssertEqual(orderedSet.count, 1); // Still 1 because A was moved

	// Push a new one
	[orderedSet push:@"C"]; // A, C
	XCTAssertEqualObjects([orderedSet lastObject], @"C");
	XCTAssertEqual(orderedSet.count, 2);
	XCTAssertEqualObjects([orderedSet firstObject], @"A");

	// Shift one
	id shifted = [orderedSet shift]; // C
	XCTAssertEqualObjects(shifted, @"A");
	XCTAssertEqual(orderedSet.count, 1);
	XCTAssertEqualObjects([orderedSet lastObject], @"C");

	// Pop the last one
	popped = [orderedSet pop]; //
	XCTAssertEqualObjects(popped, @"C");
	XCTAssertEqual(orderedSet.count, 0);

	XCTAssertNil([orderedSet pop]);
	XCTAssertNil([orderedSet shift]);
}

@end
