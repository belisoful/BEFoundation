/*!
 @file       BEView+BExtensionTests.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @abstract   Cross-platform tests for the BEView Auto Layout helpers.
 */

#import <XCTest/XCTest.h>
#import <BEFoundation/BEView+BExtension.h>

@interface BEViewBExtensionTests : XCTestCase
@end

@implementation BEViewBExtensionTests

#pragma mark - pinEdgesToSuperview

- (void)testPinEdgesToSuperview_createsFourActiveConstraints {
	BEView *parent = [[BEView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	BEView *child = [[BEView alloc] init];
	[parent addSubview:child];

	NSArray<NSLayoutConstraint *> *constraints = [child pinEdgesToSuperview];

	XCTAssertEqual(constraints.count, 4u);
	XCTAssertFalse(child.translatesAutoresizingMaskIntoConstraints);
	for (NSLayoutConstraint *c in constraints) {
		XCTAssertTrue(c.isActive);
		XCTAssertEqual(c.constant, 0);
	}
}

- (void)testPinEdgesToSuperviewWithInsets_appliesSignedConstants {
	BEView *parent = [[BEView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	BEView *child = [[BEView alloc] init];
	[parent addSubview:child];

	NSArray<NSLayoutConstraint *> *c = [child pinEdgesToSuperviewWithInsets:BEEdgeInsetsMake(10, 20, 30, 40)];

	XCTAssertEqual(c.count, 4u);
	XCTAssertEqual(c[0].constant, 10);   // top
	XCTAssertEqual(c[1].constant, 20);   // leading (insets.left)
	XCTAssertEqual(c[2].constant, -30);  // bottom (negated)
	XCTAssertEqual(c[3].constant, -40);  // trailing (negated, insets.right)
}

- (void)testPinEdgesToSuperview_noSuperviewReturnsEmpty {
	BEView *orphan = [[BEView alloc] init];
	XCTAssertEqual([orphan pinEdgesToSuperview].count, 0u);
}

- (void)testPinEdgesToSuperview_laysOutToFillSuperview {
	BEView *parent = [[BEView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
	BEView *child = [[BEView alloc] init];
	[parent addSubview:child];
	[child pinEdgesToSuperview];
#if TARGET_OS_OSX
	[parent layoutSubtreeIfNeeded];
#else
	[parent layoutIfNeeded];
#endif
	XCTAssertEqual(child.frame.size.width, 200);
	XCTAssertEqual(child.frame.size.height, 150);
}

#pragma mark - pinEdgesToView:insets:

- (void)testPinEdgesToView_createsFourConstraints {
	BEView *parent = [[BEView alloc] init];
	BEView *a = [[BEView alloc] init];
	BEView *b = [[BEView alloc] init];
	[parent addSubview:a];
	[parent addSubview:b];

	NSArray<NSLayoutConstraint *> *c = [a pinEdgesToView:b insets:BEEdgeInsetsMake(0, 0, 0, 0)];
	XCTAssertEqual(c.count, 4u);
	for (NSLayoutConstraint *con in c) XCTAssertTrue(con.isActive);
}

- (void)testPinEdgesToView_nilViewReturnsEmpty {
	BEView *v = [[BEView alloc] init];
	BEView *nilView = nil;
	XCTAssertEqual([v pinEdgesToView:nilView insets:BEEdgeInsetsMake(0, 0, 0, 0)].count, 0u);
}

#pragma mark - centerInSuperview

- (void)testCenterInSuperview_createsTwoConstraints {
	BEView *parent = [[BEView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	BEView *child = [[BEView alloc] init];
	[parent addSubview:child];

	NSArray<NSLayoutConstraint *> *c = [child centerInSuperview];
	XCTAssertEqual(c.count, 2u);
	XCTAssertFalse(child.translatesAutoresizingMaskIntoConstraints);
	for (NSLayoutConstraint *con in c) XCTAssertTrue(con.isActive);
}

- (void)testCenterInSuperview_noSuperviewReturnsEmpty {
	BEView *orphan = [[BEView alloc] init];
	XCTAssertEqual([orphan centerInSuperview].count, 0u);
}

#pragma mark - sizing

- (void)testConstrainToSize {
	BEView *v = [[BEView alloc] init];
	NSArray<NSLayoutConstraint *> *c = [v constrainToSize:CGSizeMake(50, 60)];
	XCTAssertEqual(c.count, 2u);
	XCTAssertEqual(c[0].constant, 50);   // width
	XCTAssertEqual(c[1].constant, 60);   // height
	XCTAssertFalse(v.translatesAutoresizingMaskIntoConstraints);
}

- (void)testConstrainToWidthHeight {
	BEView *v = [[BEView alloc] init];
	NSArray<NSLayoutConstraint *> *c = [v constrainToWidth:12 height:34];
	XCTAssertEqual(c.count, 2u);
	XCTAssertEqual(c[0].constant, 12);
	XCTAssertEqual(c[1].constant, 34);
}

@end
