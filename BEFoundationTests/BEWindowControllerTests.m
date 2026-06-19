/*!
 @file          BEWindowControllerTests.m
 @abstract      Comprehensive unit tests for BEWindowController.
 @discussion    Verifies encoding/decoding, delegate callbacks, notifications,
				document closing logic, and parent/child hierarchy behaviors.
*/

@import XCTest;
#import "BEWindowController.h"

#pragma mark - Helper / Mock Classes

@interface MockDocument : NSDocument
@property (nonatomic, strong) NSMutableArray<NSWindowController *> *controllers;
@end

@implementation MockDocument
- (instancetype)init {
	self = [super init];
	if (self) _controllers = [NSMutableArray array];
	return self;
}
- (NSArray<__kindof NSWindowController *> *)windowControllers { return _controllers; }
- (void)addWindowController:(NSWindowController *)controller {
	[_controllers addObject:controller];
	controller.document = self;
}
- (void)removeWindowController:(NSWindowController *)controller {
	[_controllers removeObject:controller];
}
@end


/// Mock delegate that records windowDidLoad: invocations.
@interface MockWindowDelegate : NSObject <BEWindowDelegate>
@property (nonatomic, assign) BOOL didCall;
@property (nonatomic, strong) NSNotification *notification;
@end

@implementation MockWindowDelegate
- (void)windowDidLoad:(NSNotification *)notification {
	self.didCall = YES;
	self.notification = notification;
}
@end


/// A BEWindowController subclass activating both parent and child behaviors.
@interface TestWindowController : BEWindowController <BEParentWindowController, BEChildWindowController>
@property (nonatomic, assign) BOOL closed;
@end

@implementation TestWindowController
- (void)close {
	self.closed = YES;
	[super close];
}
@end

#pragma mark - Tests

@interface BEWindowControllerTests : XCTestCase
@end

@implementation BEWindowControllerTests

#pragma mark Initialization & Encoding

- (void)testInitWithWindowSetsDefaults {
	NSWindow *win = [[NSWindow alloc] init];
	BEWindowController *wc = [[BEWindowController alloc] initWithWindow:win];
	
	XCTAssertNotNil(wc);
	XCTAssertFalse(wc.isPrimaryWindowController, @"Default should be NO.");
}


- (void)testEncodingAndDecodingPreservesPrimaryFlag {
	BEWindowController *original = [[BEWindowController alloc] init];
	original.isPrimaryWindowController = YES;
	
	NSError *error = nil;
	
	// Archive using the modern API but do NOT require secure coding.
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
	[archiver encodeObject:original forKey:NSKeyedArchiveRootObjectKey];
	[archiver finishEncoding];
	NSData *data = archiver.encodedData;
	XCTAssertNotNil(data, @"Archiving should produce data.");
	
	// Unarchive using the modern API and explicitly disable secure-coding enforcement.
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
	XCTAssertNil(error, @"Failed to create unarchiver: %@", error);
	unarchiver.requiresSecureCoding = NO;
	
	BEWindowController *decoded = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
	[unarchiver finishDecoding];
	
	XCTAssertNotNil(decoded, @"Decoded object should not be nil.");
	XCTAssertTrue(decoded.isPrimaryWindowController, @"Flag should survive encoding/decoding.");
}


#pragma mark - Delegate & Notification

- (void)testWindowDidLoadPostsNotificationAndCallsDelegate {
	NSWindow *window = [[NSWindow alloc] init];
	BEWindowController *wc = [[BEWindowController alloc] initWithWindow:window];
	MockWindowDelegate *delegate = [[MockWindowDelegate alloc] init];
	window.delegate = delegate;
	
	XCTestExpectation *notificationExpectation = [self expectationWithDescription:@"Notification posted"];
	id token = [[NSNotificationCenter defaultCenter] addObserverForName:BEWindowDidLoadNotification
																 object:window
																  queue:nil
															 usingBlock:^(NSNotification * _Nonnull note) {
		[notificationExpectation fulfill];
	}];
	
	[wc windowDidLoad];
	
	[self waitForExpectationsWithTimeout:1 handler:nil];
	XCTAssertTrue(delegate.didCall, @"windowDidLoad: should be invoked on delegate.");
	XCTAssertEqual(delegate.notification.object, window);
	
	[[NSNotificationCenter defaultCenter] removeObserver:token];
}

#pragma mark - Parent/Child Relationship

- (void)testParentChildSetAndRemove {
	TestWindowController *parent = [[TestWindowController alloc] init];
	TestWindowController *child1 = [[TestWindowController alloc] init];
	TestWindowController *child2 = [[TestWindowController alloc] init];
	
	// Add children
	child1.parentController = parent;
	child2.parentController = parent;
	
	XCTAssertEqualObjects(child1.parentController, parent);
	XCTAssertEqualObjects(child2.parentController, parent);
	XCTAssertEqual(parent.childControllers.count, 2);
	
	// Remove one child
	child1.parentController = nil;
	XCTAssertNil(child1.parentController);
	XCTAssertEqual(parent.childControllers.count, 1);
	XCTAssertFalse([parent.childControllers containsObject:child1]);
}

- (void)testNonParentChildSetAndRemove {
	BEWindowController *parent = [[BEWindowController alloc] init];
	TestWindowController *child1 = [[TestWindowController alloc] init];
	
	// Add children
	child1.parentController = parent;
	
	XCTAssertEqualObjects(child1.parentController, parent);
	XCTAssertEqual(parent.childControllers.count, 0);
	
	// Remove one child
	child1.parentController = nil;
	XCTAssertNil(child1.parentController);
	XCTAssertEqual(parent.childControllers.count, 0);
	XCTAssertFalse([parent.childControllers containsObject:child1]);
}

- (void)testChildCannotSetParentIfNotConformingToProtocol {
	BEWindowController *plain = [[BEWindowController alloc] init];
	TestWindowController *parent = [[TestWindowController alloc] init];
	
	[plain setParentController:parent];
	XCTAssertNil(plain.parentController, @"Plain BEWindowController should ignore setParentController.");
}

- (void)testParentRejectsAddRemoveChildIfNotOptedIn {
	BEWindowController *plainParent = [[BEWindowController alloc] init];
	TestWindowController *child = [[TestWindowController alloc] init];
	
	[plainParent addChildWindowController:child];
	XCTAssertEqual(plainParent.childControllers.count, 0);
	
	[plainParent removeChildWindowController:child];
	XCTAssertEqual(plainParent.childControllers.count, 0);
}


- (void)testParentAddRemoveChildIfParentPreset {
	BEWindowController *plainParent = [[BEWindowController alloc] init];
	TestWindowController *parent = [[TestWindowController alloc] init];
	TestWindowController *child1 = [[TestWindowController alloc] init];
	
	// Add children
	child1.parentController = plainParent;
	
	[parent addChildWindowController:child1];
	XCTAssertEqual(parent.childControllers.count, 1);
	XCTAssertEqual(child1.parentController, plainParent);
	
	[parent removeChildWindowController:child1];
	XCTAssertEqual(parent.childControllers.count, 0);
	XCTAssertEqual(child1.parentController, plainParent);
	
	
	// Remove child
	child1.parentController = nil;
	
	[parent addChildWindowController:child1];
	XCTAssertEqual(parent.childControllers.count, 1);
	XCTAssertEqual(child1.parentController, parent);
	
	[parent removeChildWindowController:child1];
	XCTAssertEqual(parent.childControllers.count, 0);
	XCTAssertNil(child1.parentController);
}

#pragma mark - Child Management (Add/Remove)

- (void)testAddAndRemoveChildrenMaintainsBidirectionalLinks {
	TestWindowController *parent = [[TestWindowController alloc] init];
	TestWindowController *child = [[TestWindowController alloc] init];
	
	[parent addChildWindowController:child];
	XCTAssertTrue([parent.childControllers containsObject:child]);
	XCTAssertEqual(child.parentController, parent);
	
	[parent removeChildWindowController:child];
	XCTAssertFalse([parent.childControllers containsObject:child]);
	XCTAssertNil(child.parentController);
}

- (void)testRemoveNonexistentChildReturnsNo {
	TestWindowController *parent = [[TestWindowController alloc] init];
	TestWindowController *child = [[TestWindowController alloc] init];
	
	BOOL removed = [parent removeChildWindowController:child];
	XCTAssertFalse(removed);
}

#pragma mark - Primary Window Closing Logic

- (void)testPrimaryWindowClosesAllDocumentWindows {
	MockDocument *doc = [[MockDocument alloc] init];
	TestWindowController *primary = [[TestWindowController alloc] init];
	TestWindowController *secondary1 = [[TestWindowController alloc] init];
	TestWindowController *secondary2 = [[TestWindowController alloc] init];
	
	primary.isPrimaryWindowController = YES;
	
	[doc addWindowController:primary];
	[doc addWindowController:secondary1];
	[doc addWindowController:secondary2];
	
	[primary close];
	
	XCTAssertTrue(primary.closed);
	XCTAssertTrue(secondary1.closed, @"Secondary 1 should close when primary closes.");
	XCTAssertTrue(secondary2.closed, @"Secondary 2 should close when primary closes.");
}

- (void)testNonPrimaryWindowDoesNotCloseOthers {
	MockDocument *doc = [[MockDocument alloc] init];
	TestWindowController *primary = [[TestWindowController alloc] init];
	TestWindowController *secondary = [[TestWindowController alloc] init];
	
	primary.isPrimaryWindowController = YES;
	[doc addWindowController:primary];
	[doc addWindowController:secondary];
	
	[secondary close];

	XCTAssertTrue(secondary.closed);
	XCTAssertFalse(primary.closed, @"Closing non-primary window should not affect primary.");
}

#pragma mark Regression Tests (reparenting + nil safety)

- (void)testReparentingMovesChildToExactlyOneParent {
	TestWindowController *parentA = [[TestWindowController alloc] initWithWindow:nil];
	TestWindowController *parentB = [[TestWindowController alloc] initWithWindow:nil];
	TestWindowController *child   = [[TestWindowController alloc] initWithWindow:nil];

	child.parentController = parentA;
	XCTAssertEqualObjects(child.parentController, parentA);
	XCTAssertTrue([parentA containsChildWindowController:child]);
	XCTAssertFalse([parentB containsChildWindowController:child]);

	// Reparent A -> B. Regression: the child previously lingered in BOTH parents' sets
	// with a stale back-reference.
	child.parentController = parentB;
	XCTAssertEqualObjects(child.parentController, parentB, @"Back-reference must point to the new parent.");
	XCTAssertTrue([parentB containsChildWindowController:child], @"Child must be in the new parent.");
	XCTAssertFalse([parentA containsChildWindowController:child], @"Child must be removed from the old parent.");
	XCTAssertEqual(parentA.childControllers.count, 0u);
	XCTAssertEqual(parentB.childControllers.count, 1u);

	// Detach entirely.
	child.parentController = nil;
	XCTAssertNil(child.parentController);
	XCTAssertFalse([parentB containsChildWindowController:child]);
	XCTAssertEqual(parentB.childControllers.count, 0u);
}

- (void)testAddNilChildDoesNotCrash {
	TestWindowController *parent = [[TestWindowController alloc] initWithWindow:nil];
	NSWindowController *nilChild = nil;
	XCTAssertNoThrow([parent addChildWindowController:nilChild]);
	XCTAssertEqual(parent.childControllers.count, 0u);
}

- (void)testSupportsSecureCoding {
	XCTAssertTrue([BEWindowController supportsSecureCoding]);
}

- (void)testTwoPrimariesDoNotInfinitelyRecurse {
	MockDocument *doc = [[MockDocument alloc] init];
	TestWindowController *primaryA = [[TestWindowController alloc] initWithWindow:[[NSWindow alloc] init]];
	TestWindowController *primaryB = [[TestWindowController alloc] initWithWindow:[[NSWindow alloc] init]];
	primaryA.isPrimaryWindowController = YES;
	primaryB.isPrimaryWindowController = YES;
	[doc addWindowController:primaryA];
	[doc addWindowController:primaryB];

	// Must terminate (no stack overflow) and both must be marked closed exactly via -close.
	XCTAssertNoThrow([primaryA close]);
	XCTAssertTrue(primaryA.closed);
	XCTAssertTrue(primaryB.closed, @"The other primary should be closed by the cascade.");
}

- (void)testSecureCodingRoundTrip {
	// Verified behavior: even though NSWindowController/NSResponder/NSWindow do not adopt
	// NSSecureCoding, a subclass that does (BEWindowController) round-trips through
	// requiringSecureCoding:YES + a secure decode. The managed window is not archived.
	BEWindowController *wc = [[BEWindowController alloc] initWithWindow:nil];
	wc.isPrimaryWindowController = YES;

	NSError *err = nil;
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:wc requiringSecureCoding:YES error:&err];
	XCTAssertNotNil(data, @"Secure archive must succeed: %@", err);

	NSError *derr = nil;
	BEWindowController *back = [NSKeyedUnarchiver unarchivedObjectOfClass:[BEWindowController class]
																fromData:data
																   error:&derr];
	XCTAssertNotNil(back, @"Secure decode must succeed: %@", derr);
	XCTAssertTrue(back.isPrimaryWindowController, @"isPrimaryWindowController must survive the round-trip.");
}

@end
