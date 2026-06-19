/*!
 @file       BETabViewTests.m
 @copyright  © 2025 Delicense - @belisoful. All rights reserved.
 @date       2025-01-01
 @author     belisoful@icloud.com
 @abstract   Comprehensive unit tests for BETabView class.
 @discussion Tests tab visibility management, position preservation, delegate notifications,
			 identifier lookups, and edge cases.
*/

#import <XCTest/XCTest.h>
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import "BETabView.h"

@interface BETabView (CommonInit_Test)
- (void)superAddTabViewItem:(NSTabViewItem*)item;
@end
@implementation BETabView (CommonInit_Test)
- (void)superAddTabViewItem:(NSTabViewItem*)item
{
	[super addTabViewItem:item];
}
@end

@interface BETabViewTestDelegate : NSObject <BETabViewDelegate>
@property (nonatomic, strong) NSMutableArray *willHideCallbacks;
@property (nonatomic, strong) NSMutableArray *didHideCallbacks;
@property (nonatomic, strong) NSMutableArray *willShowCallbacks;
@property (nonatomic, strong) NSMutableArray *didShowCallbacks;
@property (nonatomic, strong) NSMutableArray *didChangeNumberCallbacks;
@end

@implementation BETabViewTestDelegate

- (instancetype)init {
	self = [super init];
	if (self) {
		_willHideCallbacks = [NSMutableArray array];
		_didHideCallbacks = [NSMutableArray array];
		_willShowCallbacks = [NSMutableArray array];
		_didShowCallbacks = [NSMutableArray array];
		_didChangeNumberCallbacks = [NSMutableArray array];
	}
	return self;
}

- (void)tabView:(NSTabView *)tabView willHideTabViewItem:(NSTabViewItem *)tabViewItem {
	[self.willHideCallbacks addObject:tabViewItem ?: [NSNull null]];
}

- (void)tabView:(NSTabView *)tabView didHideTabViewItem:(NSTabViewItem *)tabViewItem {
	[self.didHideCallbacks addObject:tabViewItem ?: [NSNull null]];
}

- (void)tabView:(NSTabView *)tabView willShowTabViewItem:(NSTabViewItem *)tabViewItem {
	[self.willShowCallbacks addObject:tabViewItem ?: [NSNull null]];
}

- (void)tabView:(NSTabView *)tabView didShowTabViewItem:(NSTabViewItem *)tabViewItem {
	[self.didShowCallbacks addObject:tabViewItem ?: [NSNull null]];
}

- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)tabView {
	[self.didChangeNumberCallbacks addObject:@(tabView.numberOfTabViewItems)];
}

- (void)reset {
	[self.willHideCallbacks removeAllObjects];
	[self.didHideCallbacks removeAllObjects];
	[self.willShowCallbacks removeAllObjects];
	[self.didShowCallbacks removeAllObjects];
	[self.didChangeNumberCallbacks removeAllObjects];
}

@end


@interface BETabViewTests : XCTestCase
@property (nonatomic, strong) BETabView *tabView;
@property (nonatomic, strong) BETabViewTestDelegate *testDelegate;
@end

@implementation BETabViewTests

- (void)setUp {
	[super setUp];
	self.tabView = [[BETabView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	self.testDelegate = [[BETabViewTestDelegate alloc] init];
	self.tabView.delegate = self.testDelegate;
}

- (void)tearDown {
	self.tabView = nil;
	self.testDelegate = nil;
	[super tearDown];
}

- (NSTabViewItem *)createTabWithIdentifier:(NSString *)identifier label:(NSString *)label {
	NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:identifier];
	item.label = label;
	item.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
	return item;
}

#pragma mark - Initialization Tests

- (void)testInitialization {
	XCTAssertNotNil(self.tabView);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 0);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
	XCTAssertNotNil(self.tabView.allTabViewItems);
}

- (void)testInitWithFrame {
	BETabView *tabView = [[BETabView alloc] initWithFrame:NSMakeRect(10, 20, 300, 200)];
	XCTAssertNotNil(tabView);
	XCTAssertEqual(NSMinX(tabView.frame), 10);
	XCTAssertEqual(NSMinY(tabView.frame), 20);
}

- (void)testInit {
	BETabView *tabView = [[BETabView alloc] init];
	XCTAssertNotNil(tabView);
	XCTAssertEqual(tabView.numberOfAllTabViewItems, 0);
}

- (void)testAwakeFromNib {
	BETabView *tabView = [[BETabView alloc] init];
	NSTabViewItem *tabItem = [[NSTabViewItem alloc] init];
	[tabView superAddTabViewItem:tabItem];
	[tabView awakeFromNib];
	XCTAssertNotNil(tabView);
	XCTAssertEqual(tabView.numberOfAllTabViewItems, 1);
}

#pragma mark - Adding Tabs Tests

- (void)testAddTabViewItem {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 1);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
	XCTAssertEqualObjects(self.tabView.tabViewItems.firstObject, tab);
	XCTAssertEqualObjects(self.tabView.allTabViewItems.firstObject, tab);
	XCTAssertEqualObjects(tab.hiddenTabView, self.tabView);
}

- (void)testAddMultipleTabs {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	NSTabViewItem *tab3 = [self createTabWithIdentifier:@"tab3" label:@"Tab 3"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	[self.tabView addTabViewItem:tab3];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 3);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 3);
}

- (void)testAddDuplicateTab {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	[self.tabView addTabViewItem:tab];
	
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
}

- (void)testAddNilTab {
	NSTabViewItem *nilItem = nil;
	[self.tabView addTabViewItem:nilItem];
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
}

- (void)testAddHiddenTab {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	BETabView *tempTabView = [[BETabView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	[tempTabView addTabViewItem:tab];
	[tempTabView hideTabViewItem:tab];
	[tempTabView removeTabViewItem:tab];
	
	[self.tabView addTabViewItem:tab];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 0);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
	XCTAssertTrue(tab.hidden);
}

#pragma mark - Inserting Tabs Tests

- (void)testInsertTabViewItemAtIndex {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	NSTabViewItem *tab3 = [self createTabWithIdentifier:@"tab3" label:@"Tab 3"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab3];
	[self.tabView insertTabViewItem:tab2 atIndex:1];
	
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 3);
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:0], tab1);
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:1], tab2);
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:2], tab3);
}

- (void)testInsertTabAtBeginning {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView insertTabViewItem:tab2 atIndex:0];
	
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:0], tab2);
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:1], tab1);
}

#pragma mark - Removing Tabs Tests

- (void)testRemoveTabViewItem {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
	
	[self.tabView removeTabViewItem:tab];
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
	XCTAssertNil(tab.hiddenTabView);
}

- (void)testRemoveHiddenTab {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	[self.tabView hideTabViewItem:tab];
	
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
	
	[self.tabView removeTabViewItem:tab];
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
}

- (void)testRemoveEdgeCases {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
	[self.tabView removeTabViewItem:tab];
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
	
	tab = nil;
	[self.tabView removeTabViewItem:tab];
}

#pragma mark - Hiding Tabs Tests

- (void)testHideTabViewItem {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	[self.tabView hideTabViewItem:tab];
	
	XCTAssertTrue(tab.hidden);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 0);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
	XCTAssertTrue([self.tabView.allTabViewItems containsObject:tab]);
}

- (void)testHideMultipleTabs {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	NSTabViewItem *tab3 = [self createTabWithIdentifier:@"tab3" label:@"Tab 3"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	[self.tabView addTabViewItem:tab3];
	
	[self.tabView hideTabViewItem:tab1];
	[self.tabView hideTabViewItem:tab3];
	
	XCTAssertTrue(tab1.hidden);
	XCTAssertFalse(tab2.hidden);
	XCTAssertTrue(tab3.hidden);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 1);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 3);
}

- (void)testHideAlreadyHiddenTab {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	[self.tabView hideTabViewItem:tab];
	
	[self.testDelegate reset];
	[self.tabView hideTabViewItem:tab];
	
	XCTAssertEqual(self.testDelegate.willHideCallbacks.count, 0);
}

- (void)testHideTabViewItemAtIndex {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	
	[self.tabView hideTabViewItemAtIndex:0];
	
	XCTAssertTrue(tab1.hidden);
	XCTAssertFalse(tab2.hidden);
}

- (void)testHideTabViewItemWithIdentifier {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"settings" label:@"Settings"];
	
	[self.tabView addTabViewItem:tab];
	[self.tabView hideTabViewItemWithIdentifier:@"settings"];
	
	XCTAssertTrue(tab.hidden);
}

- (void)testHideWithNilIdentifier {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	[self.tabView addTabViewItem:tab];
	
	NSString *nilString = nil;
	[self.tabView hideTabViewItemWithIdentifier:nilString];
	XCTAssertFalse(tab.hidden);
}

- (void)testHideWithNonTab {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	XCTAssertEqual(tab.hidden, NO);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
	
	[self.tabView hideTabViewItem:tab];
	
	XCTAssertEqual(tab.hidden, NO, @"tab was not a tab in the tabView");
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
}

- (void)testHideWithNilTab {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	[self.tabView addTabViewItem:tab];
	
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
	
	NSTabViewItem *nilTab = nil;
	[self.tabView hideTabViewItem:nilTab];
	
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
}

#pragma mark - Showing Tabs Tests

- (void)testShowTabViewItem {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	[self.tabView hideTabViewItem:tab];
	
	XCTAssertTrue(tab.hidden);
	
	[self.tabView showTabViewItem:tab];
	
	XCTAssertFalse(tab.hidden);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 1);
	XCTAssertTrue([self.tabView.tabViewItems containsObject:tab]);
}

- (void)testShowPreservesPosition {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	NSTabViewItem *tab3 = [self createTabWithIdentifier:@"tab3" label:@"Tab 3"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	[self.tabView addTabViewItem:tab3];
	
	[self.tabView hideTabViewItem:tab2];
	
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], tab1);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:1], tab3);
	
	[self.tabView showTabViewItem:tab2];
	
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], tab1);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:1], tab2);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:2], tab3);
}

- (void)testShowAlreadyVisibleTab {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	
	[self.testDelegate reset];
	[self.tabView showTabViewItem:tab];
	
	XCTAssertEqual(self.testDelegate.willShowCallbacks.count, 0);
}

- (void)testShowTabViewItemAtIndex {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	[self.tabView hideTabViewItem:tab];
	
	[self.tabView showTabViewItemAtIndex:0];
	
	XCTAssertFalse(tab.hidden);
}

- (void)testShowTabViewItemWithIdentifier {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"settings" label:@"Settings"];
	
	[self.tabView addTabViewItem:tab];
	[self.tabView hideTabViewItem:tab];
	
	[self.tabView showTabViewItemWithIdentifier:@"settings"];
	
	NSString *nilString = nil;
	[self.tabView showTabViewItemWithIdentifier:nilString];
	
	XCTAssertFalse(tab.hidden);
}

- (void)testShowWithNonTab {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	tab.hidden = YES;
	XCTAssertEqual(tab.hidden, YES);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
	
	[self.tabView showTabViewItem:tab];
	
	XCTAssertEqual(tab.hidden, YES, @"tab was not a tab in the tabView");
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
}

- (void)testShowWithNilTab {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	[self.tabView addTabViewItem:tab];
	
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
	
	NSTabViewItem *nilTab = nil;
	[self.tabView showTabViewItem:nilTab];
	
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
}

#pragma mark - Hidden Property Tests

- (void)testHiddenPropertySetter {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	
	tab.hidden = YES;
	XCTAssertTrue(tab.hidden);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 0);
	
	tab.hidden = NO;
	XCTAssertFalse(tab.hidden);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 1);
}

- (void)testHiddenPropertyWithStandardNSTabView {
	NSTabView *standardTabView = [[NSTabView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[standardTabView addTabViewItem:tab];
	
	XCTAssertThrows(tab.hidden = YES);
}

#pragma mark - Delegate Tests

- (void)testWillHideDelegate {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	[self.testDelegate reset];
	
	[self.tabView hideTabViewItem:tab];
	
	XCTAssertEqual(self.testDelegate.willHideCallbacks.count, 1);
	XCTAssertEqualObjects(self.testDelegate.willHideCallbacks.firstObject, tab);
}

- (void)testDidHideDelegate {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	[self.testDelegate reset];
	
	[self.tabView hideTabViewItem:tab];
	
	XCTAssertEqual(self.testDelegate.didHideCallbacks.count, 1);
	XCTAssertEqualObjects(self.testDelegate.didHideCallbacks.firstObject, tab);
}

- (void)testWillShowDelegate {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	[self.tabView hideTabViewItem:tab];
	[self.testDelegate reset];
	
	[self.tabView showTabViewItem:tab];
	
	XCTAssertEqual(self.testDelegate.willShowCallbacks.count, 1);
	XCTAssertEqualObjects(self.testDelegate.willShowCallbacks.firstObject, tab);
}

- (void)testDidShowDelegate {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	[self.tabView hideTabViewItem:tab];
	[self.testDelegate reset];
	
	[self.tabView showTabViewItem:tab];
	
	XCTAssertEqual(self.testDelegate.didShowCallbacks.count, 1);
	XCTAssertEqualObjects(self.testDelegate.didShowCallbacks.firstObject, tab);
}

- (void)testDelegateCallOrder {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	[self.testDelegate reset];
	
	[self.tabView hideTabViewItem:tab];
	
	XCTAssertEqual(self.testDelegate.willHideCallbacks.count, 1);
	XCTAssertEqual(self.testDelegate.didHideCallbacks.count, 1);
	
	[self.testDelegate reset];
	[self.tabView showTabViewItem:tab];
	
	XCTAssertEqual(self.testDelegate.willShowCallbacks.count, 1);
	XCTAssertEqual(self.testDelegate.didShowCallbacks.count, 1);
}

#pragma mark - Display Index Tests

- (void)testDisplayIndexAtIndex {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	NSTabViewItem *tab3 = [self createTabWithIdentifier:@"tab3" label:@"Tab 3"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	[self.tabView addTabViewItem:tab3];
	
	XCTAssertEqual([self.tabView displayIndexAtIndex:0], 0);
	XCTAssertEqual([self.tabView displayIndexAtIndex:1], 1);
	XCTAssertEqual([self.tabView displayIndexAtIndex:2], 2);
	
	[self.tabView hideTabViewItem:tab2];
	
	XCTAssertEqual([self.tabView displayIndexAtIndex:0], 0);
	XCTAssertEqual([self.tabView displayIndexAtIndex:1], NSNotFound);
	XCTAssertEqual([self.tabView displayIndexAtIndex:2], 1);
}
- (void)testDisplayIndexAtIndexBadArgument {
	XCTAssertEqual([self.tabView displayIndexAtIndex:-1], NSNotFound);
	XCTAssertEqual([self.tabView displayIndexAtIndex:0], NSNotFound);
}

- (void)testDisplayIndexWithInsertMode {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	[self.tabView hideTabViewItem:tab2];
	
	XCTAssertEqual([self.tabView displayIndexAtIndex:2 insertMode:YES], 1);
	XCTAssertEqual([self.tabView displayIndexAtIndex:1 insertMode:YES], 1);
}

#pragma mark - Identifier Lookup Tests

- (void)testIndexOfAllTabViewItemWithIdentifier {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"first" label:@"First"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"second" label:@"Second"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	
	NSString *nilString = nil;
	XCTAssertEqual([self.tabView indexOfAllTabViewItemWithIdentifier:@"first"], 0);
	XCTAssertEqual([self.tabView indexOfAllTabViewItemWithIdentifier:@"second"], 1);
	XCTAssertEqual([self.tabView indexOfAllTabViewItemWithIdentifier:@"nonexistent"], NSNotFound);
	XCTAssertEqual([self.tabView indexOfAllTabViewItemWithIdentifier:nilString], NSNotFound);
}

- (void)testAllTabViewItemWithIdentifier {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"settings" label:@"Settings"];
	
	[self.tabView addTabViewItem:tab];
	
	NSTabViewItem *found = [self.tabView allTabViewItemWithIdentifier:@"settings"];
	XCTAssertEqualObjects(found, tab);
	
	NSString *nilString = nil;
	XCTAssertNil([self.tabView allTabViewItemWithIdentifier:@"nonexistent"]);
	XCTAssertNil([self.tabView allTabViewItemWithIdentifier:nilString]);
}

- (void)testTabViewItemWithIdentifierCategory {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"settings" label:@"Settings"];
	
	[self.tabView addTabViewItem:tab];
	
	NSTabViewItem *found = [self.tabView tabViewItemWithIdentifier:@"settings"];
	XCTAssertEqualObjects(found, tab);
	
	[self.tabView hideTabViewItem:tab];
	
	XCTAssertNil([self.tabView tabViewItemWithIdentifier:@"settings"]);
	
	XCTAssertEqualObjects([self.tabView allTabViewItemWithIdentifier:@"settings"], tab);
}

#pragma mark - Accessing Tabs Tests

- (void)testAllTabViewItemAtIndex {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:0], tab1);
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:1], tab2);
	XCTAssertNil([self.tabView allTabViewItemAtIndex:2]);
	XCTAssertNil([self.tabView allTabViewItemAtIndex:-1]);
}

- (void)testIndexOfAllTabViewItem {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	NSTabViewItem *tab3 = [self createTabWithIdentifier:@"tab3" label:@"Tab 3"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	
	XCTAssertEqual([self.tabView indexOfAllTabViewItem:tab1], 0);
	XCTAssertEqual([self.tabView indexOfAllTabViewItem:tab2], 1);
	XCTAssertEqual([self.tabView indexOfAllTabViewItem:tab3], NSNotFound);
}

#pragma mark - AllTabViewItems Property Tests

- (void)testAllTabViewItemsGetter {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	[self.tabView hideTabViewItem:tab1];
	
	NSArray *allTabs = self.tabView.allTabViewItems;
	XCTAssertEqual(allTabs.count, 2);
	XCTAssertTrue([allTabs containsObject:tab1]);
	XCTAssertTrue([allTabs containsObject:tab2]);
}

- (void)testNumberOfAllTabViewItems {
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
	
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	
	[self.tabView addTabViewItem:tab1];
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
	
	[self.tabView addTabViewItem:tab2];
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 2);
	
	[self.tabView hideTabViewItem:tab1];
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 2);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 1);
}

#pragma mark - Complex Scenarios

- (void)testComplexHideShowSequence {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	NSTabViewItem *tab3 = [self createTabWithIdentifier:@"tab3" label:@"Tab 3"];
	NSTabViewItem *tab4 = [self createTabWithIdentifier:@"tab4" label:@"Tab 4"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	[self.tabView addTabViewItem:tab3];
	[self.tabView addTabViewItem:tab4];
	
	[self.tabView hideTabViewItem:tab2];
	[self.tabView hideTabViewItem:tab4];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 2);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], tab1);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:1], tab3);
	
	[self.tabView showTabViewItem:tab2];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 3);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], tab1);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:1], tab2);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:2], tab3);
	
	[self.tabView showTabViewItem:tab4];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 4);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:3], tab4);
}

- (void)testHideAllTabs {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	
	[self.tabView hideTabViewItem:tab1];
	[self.tabView hideTabViewItem:tab2];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 0);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 2);
}

- (void)testShowAllTabs {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	
	[self.tabView hideTabViewItem:tab1];
	[self.tabView hideTabViewItem:tab2];
	
	[self.tabView showTabViewItem:tab1];
	[self.tabView showTabViewItem:tab2];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 2);
	XCTAssertFalse(tab1.hidden);
	XCTAssertFalse(tab2.hidden);
}

- (void)testAlternatingHideShow {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	[self.tabView addTabViewItem:tab];
	
	for (int i = 0; i < 5; i++) {
		[self.tabView hideTabViewItem:tab];
		XCTAssertTrue(tab.hidden);
		XCTAssertEqual(self.tabView.numberOfTabViewItems, 0);
		
		[self.tabView showTabViewItem:tab];
		XCTAssertFalse(tab.hidden);
		XCTAssertEqual(self.tabView.numberOfTabViewItems, 1);
	}
}

#pragma mark - Edge Cases

- (void)testEmptyTabView {
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 0);
	XCTAssertNil([self.tabView allTabViewItemAtIndex:0]);
	XCTAssertEqual([self.tabView indexOfAllTabViewItemWithIdentifier:@"any"], NSNotFound);
	XCTAssertNil([self.tabView allTabViewItemWithIdentifier:@"any"]);
	
	NSString *nilString = nil;
	XCTAssertNil([self.tabView tabViewItemWithIdentifier:nilString]);
}

- (void)testSingleTabHideShow {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"only" label:@"Only Tab"];
	
	[self.tabView addTabViewItem:tab];
	[self.tabView hideTabViewItem:tab];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 0);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1);
	
	[self.tabView showTabViewItem:tab];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 1);
}

- (void)testHideFirstTab {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	
	[self.tabView hideTabViewItem:tab1];
	
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], tab2);
}

- (void)testHideLastTab {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	
	[self.tabView hideTabViewItem:tab2];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 1);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], tab1);
}

- (void)testHideMiddleTab {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	NSTabViewItem *tab3 = [self createTabWithIdentifier:@"tab3" label:@"Tab 3"];
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab2];
	[self.tabView addTabViewItem:tab3];
	
	[self.tabView hideTabViewItem:tab2];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 2);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], tab1);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:1], tab3);
}

#pragma mark - Position Preservation Tests

- (void)testPositionPreservationWithMultipleHiddenTabs {
	NSTabViewItem *tabs[5];
	for (int i = 0; i < 5; i++) {
		tabs[i] = [self createTabWithIdentifier:[NSString stringWithFormat:@"tab%d", i]
										   label:[NSString stringWithFormat:@"Tab %d", i]];
		[self.tabView addTabViewItem:tabs[i]];
	}
	
	[self.tabView hideTabViewItem:tabs[1]];
	[self.tabView hideTabViewItem:tabs[3]];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 3);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], tabs[0]);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:1], tabs[2]);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:2], tabs[4]);
	
	[self.tabView showTabViewItem:tabs[1]];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 4);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], tabs[0]);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:1], tabs[1]);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:2], tabs[2]);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:3], tabs[4]);
	
	[self.tabView showTabViewItem:tabs[3]];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 5);
	for (int i = 0; i < 5; i++) {
		XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:i], tabs[i]);
	}
}

- (void)testPositionAfterInsertAndHide {
	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	NSTabViewItem *tab2 = [self createTabWithIdentifier:@"tab2" label:@"Tab 2"];
	NSTabViewItem *tab3 = [self createTabWithIdentifier:@"tab3" label:@"Tab 3"];
	NSTabViewItem *tab4 = [self createTabWithIdentifier:@"tab4" label:@"Tab 4"];
	tab4.hidden = YES;
	
	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab3];
	[self.tabView insertTabViewItem:tab2 atIndex:1];
	[self.tabView addTabViewItem:tab4];
	
	[self.tabView hideTabViewItem:tab2];
	[self.tabView showTabViewItem:tab2];
	
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], tab1);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:1], tab2);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:2], tab3);
	XCTAssertThrowsSpecificNamed([self.tabView tabViewItemAtIndex:3], NSException, NSRangeException, @"hidden tab not part of tabViewItems");
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:3], tab4, @"hidden tab is part of allTabViewItems");
}

- (void)testPositionAfterInsertAndHide_BadArgument {
	NSTabViewItem *nilTab = nil;
	[self.tabView insertTabViewItem:nilTab atIndex:0];

	NSTabViewItem *tab1 = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];

	[self.tabView addTabViewItem:tab1];
	[self.tabView addTabViewItem:tab1];
}

- (void)testInterleavedAddHideShowPreservesPositionsAndCallbacks {
	NSTabViewItem *t0 = [self createTabWithIdentifier:@"t0" label:@"T0"];
	NSTabViewItem *t1 = [self createTabWithIdentifier:@"t1" label:@"T1"];
	NSTabViewItem *t2 = [self createTabWithIdentifier:@"t2" label:@"T2"];
	NSTabViewItem *t3 = [self createTabWithIdentifier:@"t3" label:@"T3"];

	[self.tabView addTabViewItem:t0];
	[self.tabView addTabViewItem:t1];
	[self.tabView hideTabViewItem:t1];
	[self.tabView addTabViewItem:t2];
	[self.tabView showTabViewItem:t1];
	[self.tabView addTabViewItem:t3];
	[self.tabView hideTabViewItem:t0];

	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 4);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 3);
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:0], t0);
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:1], t1);
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:2], t2);
	XCTAssertEqualObjects([self.tabView allTabViewItemAtIndex:3], t3);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], t1);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:1], t2);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:2], t3);

	XCTAssertEqualObjects(self.testDelegate.willHideCallbacks, (@[t1, t0]));
	XCTAssertEqualObjects(self.testDelegate.didHideCallbacks, (@[t1, t0]));
	XCTAssertEqualObjects(self.testDelegate.willShowCallbacks, (@[t1]));
	XCTAssertEqualObjects(self.testDelegate.didShowCallbacks, (@[t1]));
}

#pragma mark - HiddenTabView Property Tests

- (void)testHiddenTabViewProperty {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	XCTAssertNil(tab.hiddenTabView);
	
	[self.tabView addTabViewItem:tab];
	XCTAssertEqualObjects(tab.hiddenTabView, self.tabView);
	
	[self.tabView hideTabViewItem:tab];
	XCTAssertEqualObjects(tab.hiddenTabView, self.tabView);
	
	[self.tabView removeTabViewItem:tab];
	XCTAssertNil(tab.hiddenTabView);
}

#pragma mark - Delegate Change Notification Tests

- (void)testDidChangeNumberOfTabViewItemsForHiddenTab {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	BETabView *tempTabView = [[BETabView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	[tempTabView addTabViewItem:tab];
	[tempTabView hideTabViewItem:tab];
	[tempTabView removeTabViewItem:tab];
	
	[self.testDelegate reset];
	[self.tabView addTabViewItem:tab];
	
	XCTAssertEqual(self.testDelegate.didChangeNumberCallbacks.count, 1);
}

#pragma mark - Integration Tests

- (void)testRealWorldScenarioProgressiveDisclosure {
	NSTabViewItem *generalTab = [self createTabWithIdentifier:@"general" label:@"General"];
	NSTabViewItem *advancedTab = [self createTabWithIdentifier:@"advanced" label:@"Advanced"];
	NSTabViewItem *developerTab = [self createTabWithIdentifier:@"developer" label:@"Developer"];
	
	[self.tabView addTabViewItem:generalTab];
	[self.tabView addTabViewItem:advancedTab];
	[self.tabView addTabViewItem:developerTab];
	
	[self.tabView hideTabViewItem:advancedTab];
	[self.tabView hideTabViewItem:developerTab];
	
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 1);
	
	[self.tabView showTabViewItem:advancedTab];
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 2);
	
	[self.tabView showTabViewItem:developerTab];
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 3);
	
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:0], generalTab);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:1], advancedTab);
	XCTAssertEqualObjects([self.tabView tabViewItemAtIndex:2], developerTab);
}

- (void)testRealWorldScenarioConditionalFeatures {
	NSTabViewItem *documentsTab = [self createTabWithIdentifier:@"documents" label:@"Documents"];
	NSTabViewItem *cloudTab = [self createTabWithIdentifier:@"cloud" label:@"Cloud"];
	NSTabViewItem *settingsTab = [self createTabWithIdentifier:@"settings" label:@"Settings"];
	
	[self.tabView addTabViewItem:documentsTab];
	[self.tabView addTabViewItem:cloudTab];
	[self.tabView addTabViewItem:settingsTab];
	
	BOOL userLoggedIn = NO;
	if (!userLoggedIn) {
		[self.tabView hideTabViewItem:cloudTab];
	}
	
	XCTAssertTrue(cloudTab.hidden);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 2);
	
	userLoggedIn = YES;
	if (userLoggedIn) {
		[self.tabView showTabViewItem:cloudTab];
	}
	
	XCTAssertFalse(cloudTab.hidden);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 3);
}

#pragma mark - Performance Tests

- (void)testPerformanceHideShowManyTabs {
	NSMutableArray *tabs = [NSMutableArray array];
	for (int i = 0; i < 20; i++) {
		NSTabViewItem *tab = [self createTabWithIdentifier:[NSString stringWithFormat:@"tab%d", i]
													 label:[NSString stringWithFormat:@"Tab %d", i]];
		[tabs addObject:tab];
		[self.tabView addTabViewItem:tab];
	}
	
	[self measureBlock:^{
		for (int i = 0; i < 20; i++) {
			if (i % 2 == 0) {
				[self.tabView hideTabViewItem:tabs[i]];
			}
		}
		
		for (int i = 0; i < 20; i++) {
			if (i % 2 == 0) {
				[self.tabView showTabViewItem:tabs[i]];
			}
		}
	}];
}

- (void)testPerformanceDisplayIndexCalculation {
	for (int i = 0; i < 50; i++) {
		NSTabViewItem *tab = [self createTabWithIdentifier:[NSString stringWithFormat:@"tab%d", i]
													 label:[NSString stringWithFormat:@"Tab %d", i]];
		[self.tabView addTabViewItem:tab];
		if (i % 3 == 0) {
			[self.tabView hideTabViewItem:tab];
		}
	}
	
	[self measureBlock:^{
		for (int i = 0; i < 50; i++) {
			[self.tabView displayIndexAtIndex:i];
		}
	}];
}

#pragma mark - Memory Management Tests

- (void)testWeakReferenceInHiddenTabView {
	NSTabViewItem *tab = [self createTabWithIdentifier:@"tab1" label:@"Tab 1"];
	
	__weak BETabView *weakTabView = nil;
	
	@autoreleasepool {
		BETabView *tempTabView = [[BETabView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
		weakTabView = tempTabView;
		[tempTabView addTabViewItem:tab];
		XCTAssertNotNil(tab.hiddenTabView);
		XCTAssertEqualObjects(tab.hiddenTabView, tempTabView);
	}

	XCTAssertNil(weakTabView, @"Tab view should be deallocated");
}

#pragma mark - Regression Tests (setter, weak back-ref, selection, coder)

- (void)testAllTabViewItemsSetterRebuildsAndStaysMutable {
	NSTabViewItem *t1 = [self createTabWithIdentifier:@"a" label:@"A"];
	NSTabViewItem *t2 = [self createTabWithIdentifier:@"b" label:@"B"];

	self.tabView.allTabViewItems = @[t1, t2];

	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 2);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 2, @"Both items should be visible.");
	XCTAssertEqualObjects(t1.hiddenTabView, self.tabView, @"Setter must set the back-pointer.");
	XCTAssertEqualObjects(t2.hiddenTabView, self.tabView);

	// The result must still be mutable (no immutable-array regression).
	NSTabViewItem *t3 = [self createTabWithIdentifier:@"c" label:@"C"];
	XCTAssertNoThrow([self.tabView addTabViewItem:t3]);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 3);
	XCTAssertNoThrow([self.tabView removeTabViewItem:t1]);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 2);
}

- (void)testAllTabViewItemsSetterHonorsHiddenItems {
	NSTabViewItem *t1 = [self createTabWithIdentifier:@"a" label:@"A"];
	NSTabViewItem *t2 = [self createTabWithIdentifier:@"b" label:@"B"];
	t2.hidden = YES; // standalone item stores hidden state directly

	self.tabView.allTabViewItems = @[t1, t2];

	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 2);
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 1, @"Only the non-hidden item should be visible.");
	XCTAssertTrue(t2.hidden);
}

- (void)testAllTabViewItemsSetterDeduplicatesInput {
	// A duplicate item must not crash; the setter de-duplicates.
	NSTabViewItem *t1 = [self createTabWithIdentifier:@"a" label:@"A"];
	NSTabViewItem *t2 = [self createTabWithIdentifier:@"b" label:@"B"];

	XCTAssertNoThrow((self.tabView.allTabViewItems = @[t1, t2, t1, t2]));
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 2, @"Duplicates must collapse to one each.");
	XCTAssertEqual(self.tabView.numberOfTabViewItems, 2);

	// And the result is still mutable (no immutable-array regression).
	NSTabViewItem *t3 = [self createTabWithIdentifier:@"c" label:@"C"];
	XCTAssertNoThrow([self.tabView addTabViewItem:t3]);
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 3);
}

- (void)testAllTabViewItemsSetterIgnoresNonTabEntries {
	// NSNull / non-tab entries are ignored rather than crashing.
	NSTabViewItem *t1 = [self createTabWithIdentifier:@"a" label:@"A"];
	NSArray *mixed = @[t1, (NSTabViewItem *)[NSNull null]];
	XCTAssertNoThrow((self.tabView.allTabViewItems = mixed));
	XCTAssertEqual(self.tabView.numberOfAllTabViewItems, 1, @"Only the real tab is kept.");
}

- (void)testHiddenTabViewIsZeroingWeak {
	NSTabViewItem *item = [[NSTabViewItem alloc] init];
	@autoreleasepool {
		BETabView *tv = [[BETabView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
		[tv addTabViewItem:item];
		XCTAssertEqualObjects(item.hiddenTabView, tv);
	}
	// The tab view is gone; the back-reference must be nil (zeroing weak), not dangling.
	XCTAssertNil(item.hiddenTabView, @"hiddenTabView must zero out after the tab view deallocates.");
}

- (void)testHidingSelectedTabMovesSelectionToVisibleTab {
	NSTabViewItem *t1 = [self createTabWithIdentifier:@"a" label:@"A"];
	NSTabViewItem *t2 = [self createTabWithIdentifier:@"b" label:@"B"];
	[self.tabView addTabViewItem:t1];
	[self.tabView addTabViewItem:t2];
	[self.tabView selectTabViewItem:t1];
	XCTAssertEqualObjects(self.tabView.selectedTabViewItem, t1);

	[self.tabView hideTabViewItem:t1];

	XCTAssertEqualObjects(self.tabView.selectedTabViewItem, t2,
						  @"Hiding the selected tab must move the selection to a remaining visible tab.");
	XCTAssertTrue(t1.hidden);
}

- (void)testInitWithCoderPopulatesAllTabViewItems {
	NSTabViewItem *t1 = [self createTabWithIdentifier:@"a" label:@"A"];
	[self.tabView addTabViewItem:t1];
	self.tabView.delegate = nil; // avoid encoding the test delegate

	NSError *err = nil;
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.tabView requiringSecureCoding:NO error:&err];
	XCTAssertNotNil(data, @"archive failed: %@", err);

	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&err];
	unarchiver.requiresSecureCoding = NO;
	BETabView *decoded = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
	[unarchiver finishDecoding];

	XCTAssertTrue([decoded isKindOfClass:[BETabView class]]);
	// initWithCoder: must reconcile allTabViewItems with the decoded visible tabs.
	XCTAssertEqual(decoded.numberOfAllTabViewItems, decoded.numberOfTabViewItems);
	XCTAssertEqual(decoded.numberOfAllTabViewItems, 1);
}

- (void)testNumberChangeNotificationSemantics {
	// Documented contract: tabViewDidChangeNumberOfTabViewItems: tracks the count of ALL
	// tabs. Add/remove (visible OR hidden) change that count and fire; hide/show do not.
	NSTabViewItem *t1 = [self createTabWithIdentifier:@"a" label:@"A"];
	NSTabViewItem *t2 = [self createTabWithIdentifier:@"b" label:@"B"];

	[self.testDelegate.didChangeNumberCallbacks removeAllObjects];
	[self.tabView addTabViewItem:t1];
	[self.tabView addTabViewItem:t2];
	XCTAssertEqual(self.testDelegate.didChangeNumberCallbacks.count, 2u, @"Each (visible) add fires count-change.");

	[self.testDelegate.didChangeNumberCallbacks removeAllObjects];
	[self.tabView hideTabViewItem:t1];
	XCTAssertEqual(self.testDelegate.didChangeNumberCallbacks.count, 0u, @"Hiding must NOT fire count-change.");

	[self.testDelegate.didChangeNumberCallbacks removeAllObjects];
	[self.tabView showTabViewItem:t1];
	XCTAssertEqual(self.testDelegate.didChangeNumberCallbacks.count, 0u, @"Showing must NOT fire count-change.");

	// Adding a hidden tab still changes the all-tabs count, so it fires.
	[self.testDelegate.didChangeNumberCallbacks removeAllObjects];
	NSTabViewItem *t3 = [self createTabWithIdentifier:@"c" label:@"C"];
	t3.hidden = YES; // standalone item stores hidden state
	[self.tabView addTabViewItem:t3];
	XCTAssertEqual(self.testDelegate.didChangeNumberCallbacks.count, 1u, @"Adding a hidden tab fires count-change.");

	[self.testDelegate.didChangeNumberCallbacks removeAllObjects];
	[self.tabView removeTabViewItem:t1];
	XCTAssertEqual(self.testDelegate.didChangeNumberCallbacks.count, 1u, @"Removing fires count-change.");
}

@end
