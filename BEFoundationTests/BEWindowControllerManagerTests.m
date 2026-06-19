/*!
 @file          BEWindowControllerManagerTests.m
 @abstract      Comprehensive tests for BEWindowControllerManager.
 @discussion    Tests notification-driven window tracking, subscripting, enumeration,
				and cascade-closing hierarchy logic.
*/

@import XCTest;
#import "BEWindowControllerManager.h"
#import "BEWindowController.h"

#pragma mark - Mock Classes

/// A simple BEWindowController subclass used for testing.
@interface TestManagerdWindowController : BEWindowController <BEParentWindowController, BEChildWindowController>
@property (nonatomic, assign) BOOL didClose;
@end

@implementation TestManagerdWindowController
- (void)close {
	self.didClose = YES;
	[super close];
}
@end


#pragma mark - Test Case

@interface BEWindowControllerManagerTests : XCTestCase
@property (nonatomic, strong) BEWindowControllerManager *manager;
@end


@implementation BEWindowControllerManagerTests

- (void)setUp {
	[super setUp];
	self.manager = [[BEWindowControllerManager alloc] init];
}

- (void)tearDown {
	self.manager = nil;
	[super tearDown];
}

#pragma mark Initialization & Notifications

- (void)testManagerStartsEmpty {
	XCTAssertEqual(self.manager.windowControllers.count, 0);
}

- (void)testWindowDidLoadAddsController {
	NSWindow *window = [[NSWindow alloc] init];
	TestManagerdWindowController *controller = [[TestManagerdWindowController alloc] initWithWindow:window];
	window.windowController = controller;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:window];
	
	XCTAssertTrue([self.manager.windowControllers containsObject:controller]);
}

- (void)testWindowDidLoadIgnoresInvalidObject {
	[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:@"Invalid"];
	XCTAssertEqual(self.manager.windowControllers.count, 0);
}

- (void)testWindowWillCloseRemovesController {
	
	NSWindow *window = [[NSWindow alloc] init];
	TestManagerdWindowController *controller = [[TestManagerdWindowController alloc] initWithWindow:window];
	window.windowController = controller;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:window];
	XCTAssertTrue([self.manager.windowControllers containsObject:controller]);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:window];
	XCTAssertFalse([self.manager.windowControllers containsObject:controller]);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:window];
	XCTAssertFalse([self.manager.windowControllers containsObject:controller]);
}


- (void)testWindowWillCloseRegularController {
	
	NSWindow *window = [[NSWindow alloc] init];
	BEWindowController *controller = [[BEWindowController alloc] initWithWindow:window];
	window.windowController = controller;
	[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:window];
	XCTAssertTrue([self.manager.windowControllers containsObject:controller]);
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:window];
	XCTAssertFalse([self.manager.windowControllers containsObject:controller]);
}


- (void)testWindowWillCloseNoController {
	
	NSWindow *window = [[NSWindow alloc] init];
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:window];
}

#pragma mark Cascade Close Logic

- (void)testCascadeCloseClosesChildWindows {
	// Create parent & children
	NSWindow *parentWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *parent = [[TestManagerdWindowController alloc] initWithWindow:parentWindow];
	parentWindow.windowController = parent;

	NSWindow *childWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *child = [[TestManagerdWindowController alloc] initWithWindow:childWindow];
	childWindow.windowController = child;
	child.parentController = parent; // establish relationship

	// Add both to manager
	[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:parentWindow];
	[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:childWindow];

	XCTAssertEqual(self.manager.windowControllers.count, 2);

	// Trigger cascade close
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:parentWindow];

	XCTAssertTrue(child.didClose, @"Child should close when parent closes.");
	XCTAssertFalse([self.manager.windowControllers containsObject:parent]);
}

- (void)testCascadeCloseSkipsNonChildControllers {
	NSWindow *parentWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *parent = [[TestManagerdWindowController alloc] initWithWindow:parentWindow];
	parentWindow.windowController = parent;

	NSWindow *unrelatedWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *unrelated = [[TestManagerdWindowController alloc] initWithWindow:unrelatedWindow];
	unrelatedWindow.windowController = unrelated;

	[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:parentWindow];
	[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:unrelatedWindow];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:parentWindow];
	
	XCTAssertFalse(unrelated.didClose, @"Unrelated controller must not close.");
}

#pragma mark Query Methods

- (void)testFirstWindowControllerOfKindReturnsFirstMatch {
	Class nilClass = nil;
	TestManagerdWindowController *a = [[TestManagerdWindowController alloc] init];
	BEWindowController *b = [[BEWindowController alloc] init];
	[self.manager setValue:[@[a, b] mutableCopy] forKey:@"mutableWindowControllers"];
	
	XCTAssertEqualObjects([self.manager firstWindowControllerOfKind:[TestManagerdWindowController class]], a);
	XCTAssertNil([self.manager firstWindowControllerOfKind:nilClass]);
}

- (void)testManagerdWindowControllersOfKindReturnsAllMatches {
	Class nilClass = nil;
	TestManagerdWindowController *a = [[TestManagerdWindowController alloc] init];
	TestManagerdWindowController *b = [[TestManagerdWindowController alloc] init];
	BEWindowController *c = [[BEWindowController alloc] init];
	
	[self.manager setValue:[@[a, b, c] mutableCopy] forKey:@"mutableWindowControllers"];
	
	NSArray *matches = [self.manager windowControllersOfKind:[TestManagerdWindowController class]];
	XCTAssertEqual(matches.count, 2);
	XCTAssertTrue([matches containsObject:a]);
	XCTAssertTrue([matches containsObject:b]);
	
	XCTAssertEqualObjects([self.manager windowControllersOfKind:nilClass], @[]);
}

#pragma mark Subscript Access

- (void)testIndexedSubscriptReturnsExpectedController {
	TestManagerdWindowController *a = [[TestManagerdWindowController alloc] init];
	TestManagerdWindowController *b = [[TestManagerdWindowController alloc] init];
	[self.manager setValue:[@[a, b] mutableCopy] forKey:@"mutableWindowControllers"];
	
	XCTAssertEqualObjects(self.manager[0], a);
	XCTAssertEqualObjects(self.manager[1], b);
	XCTAssertNil(self.manager[2]);
}

- (void)testKeyedSubscriptReturnsFirstOfKind {
	TestManagerdWindowController *a = [[TestManagerdWindowController alloc] init];
	BEWindowController *b = [[BEWindowController alloc] init];
	[self.manager setValue:[@[a, b] mutableCopy] forKey:@"mutableWindowControllers"];
	
	XCTAssertEqualObjects(self.manager[[TestManagerdWindowController class]], a);
	XCTAssertNil(self.manager[[NSString class]]);
}

#pragma mark Fast Enumeration

- (void)testFastEnumerationIteratesAllControllers {
	TestManagerdWindowController *a = [[TestManagerdWindowController alloc] init];
	TestManagerdWindowController *b = [[TestManagerdWindowController alloc] init];
	[self.manager setValue:[@[a, b] mutableCopy] forKey:@"mutableWindowControllers"];
	
	NSMutableArray *collected = [NSMutableArray array];
	for (NSWindowController *wc in self.manager) {
		[collected addObject:wc];
	}
	XCTAssertEqual(collected.count, 2);
	XCTAssertTrue([collected containsObject:a]);
	XCTAssertTrue([collected containsObject:b]);
}

#pragma mark Regression Tests (singleton + robust cascade)

- (void)testSharedManagerIsASingleton {
	BEWindowControllerManager *a = BEWindowControllerManager.sharedManager;
	BEWindowControllerManager *b = BEWindowControllerManager.sharedManager;
	XCTAssertNotNil(a, @"sharedManager must return an instance.");
	XCTAssertEqual(a, b, @"sharedManager must always return the same instance.");
}

- (void)testMultiLevelCascadeClosesAllDescendants {
	// grandparent -> parent -> child
	NSWindow *gpWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *grandparent = [[TestManagerdWindowController alloc] initWithWindow:gpWindow];
	gpWindow.windowController = grandparent;

	NSWindow *pWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *parent = [[TestManagerdWindowController alloc] initWithWindow:pWindow];
	pWindow.windowController = parent;
	parent.parentController = grandparent;

	NSWindow *cWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *child = [[TestManagerdWindowController alloc] initWithWindow:cWindow];
	cWindow.windowController = child;
	child.parentController = parent;

	for (NSWindow *w in @[gpWindow, pWindow, cWindow]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:w];
	}
	XCTAssertEqual(self.manager.windowControllers.count, 3);

	// Close the grandparent: parent and child must both cascade closed and be untracked.
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:gpWindow];

	XCTAssertTrue(parent.didClose, @"Parent should close when grandparent closes.");
	XCTAssertTrue(child.didClose, @"Grandchild should close when grandparent closes.");
	XCTAssertFalse([self.manager.windowControllers containsObject:grandparent]);
	XCTAssertFalse([self.manager.windowControllers containsObject:parent]);
	XCTAssertFalse([self.manager.windowControllers containsObject:child]);
	XCTAssertEqual(self.manager.windowControllers.count, 0);
}

- (void)testCascadeRemovesDescendantsFromTrackingEvenWithoutNotification {
	// A controller whose -close does not synchronously post NSWindowWillCloseNotification
	// must still be removed from tracking by the up-front removal.
	NSWindow *pWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *parent = [[TestManagerdWindowController alloc] initWithWindow:pWindow];
	pWindow.windowController = parent;

	NSWindow *cWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *child = [[TestManagerdWindowController alloc] initWithWindow:cWindow];
	cWindow.windowController = child;
	child.parentController = parent;

	[self.manager setValue:[@[parent, child] mutableCopy] forKey:@"mutableWindowControllers"];

	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:pWindow];

	XCTAssertFalse([self.manager.windowControllers containsObject:parent]);
	XCTAssertFalse([self.manager.windowControllers containsObject:child],
				   @"Cascade-closed child must be removed from tracking up front.");
}

- (void)testCascadeCloseTerminatesOnCyclicParentGraph {
	// A cyclic parent graph (A<->B) must not infinite-loop the BFS.
	NSWindow *aWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *a = [[TestManagerdWindowController alloc] initWithWindow:aWindow];
	aWindow.windowController = a;

	NSWindow *bWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *b = [[TestManagerdWindowController alloc] initWithWindow:bWindow];
	bWindow.windowController = b;

	a.parentController = b;
	b.parentController = a; // 2-cycle

	[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:aWindow];
	[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:bWindow];

	// Must return (not hang). Closing A cascades to B; both end up untracked.
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:aWindow];

	XCTAssertTrue(b.didClose, @"B (child of A in the cycle) should be closed.");
	XCTAssertEqual(self.manager.windowControllers.count, 0);
}

- (void)testWindowWillCloseIgnoresUntrackedController {
	// An untracked parent's close must not cascade to its tracked child.
	NSWindow *parentWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *untrackedParent = [[TestManagerdWindowController alloc] initWithWindow:parentWindow];
	parentWindow.windowController = untrackedParent;

	NSWindow *childWindow = [[NSWindow alloc] init];
	TestManagerdWindowController *child = [[TestManagerdWindowController alloc] initWithWindow:childWindow];
	childWindow.windowController = child;
	child.parentController = untrackedParent;

	// Track ONLY the child, not the parent.
	[[NSNotificationCenter defaultCenter] postNotificationName:BEWindowDidLoadNotification object:childWindow];
	XCTAssertTrue([self.manager.windowControllers containsObject:child]);

	// Closing the untracked parent must be a no-op for the manager.
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:parentWindow];

	XCTAssertFalse(child.didClose, @"An untracked parent's close must not cascade to the tracked child.");
	XCTAssertTrue([self.manager.windowControllers containsObject:child], @"Child must remain tracked.");
}

@end
