//
//  NSOpenPanel+BESecurityScopedURLManagerTests.m
//  BESecurityScopedURLManagerTests
//
//  Unit tests for the NSOpenPanel convenience category.
//  Covers every public method and property branch, including factory paths,
//  property isolation between panel instances, and edge cases for all inputs.
//
//  Note on ss_beginWithCompletionHandler:
//  ───────────────────────────────────────
//  XCTest cannot simulate user interaction with an NSOpenPanel (clicking OK or
//  Cancel), so the internal completion-handler wrapping that adds URLs to the
//  catalog on NSModalResponseOK cannot be exercised through panel interaction.
//  The tests below verify that the method is callable, handles nil and missing
//  managers gracefully, and does not modify the catalog when no selection occurs.
//

#import <XCTest/XCTest.h>
#import <AppKit/AppKit.h>
#import "BESecurityScopedURLManager.h"
#import "NSOpenPanel+BESecurityScopedURLManager.h"

@interface NSOpenPanelBESecurityScopedURLManagerTests : XCTestCase

/*! Fresh manager for every test — storageOptions set to None to avoid disk I/O. */
@property (nonatomic, strong) BESecurityScopedURLManager *manager;

/*! A fresh panel for every test. */
@property (nonatomic, strong) NSOpenPanel *panel;

@end

@implementation NSOpenPanelBESecurityScopedURLManagerTests

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Setup / Teardown
// ─────────────────────────────────────────────────────────────────────────────

- (void)setUp {
	[super setUp];
	self.manager = [[BESecurityScopedURLManager alloc] init];
	self.manager.storageOptions = BESecurityScopedURLStorageNone;
	self.panel = [NSOpenPanel openPanel];
}

- (void)tearDown {
	[self.manager clearCatalog];
	self.manager = nil;
	self.panel    = nil;
	[super tearDown];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - ss_urlManager property
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase       testURLManagerCanBeSetAndRetrieved
 @abstract       The ss_urlManager property must round-trip the assigned value.
 */
- (void)testURLManagerCanBeSetAndRetrieved {
	self.panel.ss_urlManager = self.manager;
	XCTAssertEqual(self.panel.ss_urlManager, self.manager,
				   @"ss_urlManager should return the same manager that was set");
}

/*!
 @testcase       testURLManagerDefaultsToNil
 @abstract       A panel created with the plain +openPanel factory must not have
				 a manager attached by default.
 */
- (void)testURLManagerDefaultsToNil {
	NSOpenPanel *freshPanel = [NSOpenPanel openPanel];
	XCTAssertNil(freshPanel.ss_urlManager,
				 @"ss_urlManager should be nil on a panel created with +openPanel");
}

/*!
 @testcase       testURLManagerCanBeSetToNil
 @abstract       After setting a manager, assigning nil must clear the property.
 */
- (void)testURLManagerCanBeSetToNil {
	self.panel.ss_urlManager = self.manager;
	XCTAssertNotNil(self.panel.ss_urlManager, @"Pre-condition: manager must be set");

	self.panel.ss_urlManager = nil;
	XCTAssertNil(self.panel.ss_urlManager,
				 @"ss_urlManager should be nil after explicitly setting it to nil");
}

/*!
 @testcase       testURLManagerCanBeReplacedWithDifferentManager
 @abstract       Assigning a second manager must replace the first.
 */
- (void)testURLManagerCanBeReplacedWithDifferentManager {
	BESecurityScopedURLManager *mgr1 = [[BESecurityScopedURLManager alloc] init];
	BESecurityScopedURLManager *mgr2 = [[BESecurityScopedURLManager alloc] init];

	self.panel.ss_urlManager = mgr1;
	XCTAssertEqual(self.panel.ss_urlManager, mgr1, @"First assignment must take effect");

	self.panel.ss_urlManager = mgr2;
	XCTAssertEqual(self.panel.ss_urlManager, mgr2,
				   @"Second assignment should replace the first manager");
}

/*!
 @testcase       testURLManagerIsStoredPerPanel
 @abstract       Two separate panel instances must maintain independent ss_urlManager
				 values — verifies that the associated-object key is per-object, not global.
 */
- (void)testURLManagerIsStoredPerPanel {
	BESecurityScopedURLManager *mgr1 = [[BESecurityScopedURLManager alloc] init];
	BESecurityScopedURLManager *mgr2 = [[BESecurityScopedURLManager alloc] init];

	NSOpenPanel *panel1 = [NSOpenPanel openPanel];
	NSOpenPanel *panel2 = [NSOpenPanel openPanel];

	panel1.ss_urlManager = mgr1;
	panel2.ss_urlManager = mgr2;

	XCTAssertEqual(panel1.ss_urlManager, mgr1, @"panel1 should retain its own manager");
	XCTAssertEqual(panel2.ss_urlManager, mgr2, @"panel2 should retain its own manager");
	XCTAssertNotEqual(panel1.ss_urlManager, panel2.ss_urlManager,
					  @"The two panels must not share a manager");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - ss_bookmarkLifetime property
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase       testBookmarkLifetimeDefaultsToLongLived
 @abstract       A newly created panel must have ss_bookmarkLifetime == LongLived.
 */
- (void)testBookmarkLifetimeDefaultsToLongLived {
	NSOpenPanel *freshPanel = [NSOpenPanel openPanel];
	XCTAssertEqual(freshPanel.ss_bookmarkLifetime,
				   BESecurityScopedURLBookmarkLifetimeLongLived,
				   @"Default bookmark lifetime should be BESecurityScopedURLBookmarkLifetimeLongLived");
}

/*!
 @testcase       testBookmarkLifetimeCanBeSetToShortLived
 @abstract       Assigning ShortLived must be reflected immediately.
 */
- (void)testBookmarkLifetimeCanBeSetToShortLived {
	self.panel.ss_bookmarkLifetime = BESecurityScopedURLBookmarkLifetimeShortLived;
	XCTAssertEqual(self.panel.ss_bookmarkLifetime,
				   BESecurityScopedURLBookmarkLifetimeShortLived);
}

/*!
 @testcase       testBookmarkLifetimeCanBeToggledRepeatedly
 @abstract       Toggling the lifetime property back and forth many times must
				 always reflect the most recently set value.
 */
- (void)testBookmarkLifetimeCanBeToggledRepeatedly {
	for (int i = 0; i < 5; i++) {
		self.panel.ss_bookmarkLifetime = BESecurityScopedURLBookmarkLifetimeLongLived;
		XCTAssertEqual(self.panel.ss_bookmarkLifetime,
					   BESecurityScopedURLBookmarkLifetimeLongLived,
					   @"Toggle %d: expected LongLived", i);

		self.panel.ss_bookmarkLifetime = BESecurityScopedURLBookmarkLifetimeShortLived;
		XCTAssertEqual(self.panel.ss_bookmarkLifetime,
					   BESecurityScopedURLBookmarkLifetimeShortLived,
					   @"Toggle %d: expected ShortLived", i);
	}
}

/*!
 @testcase       testBookmarkLifetimeIsStoredPerPanel
 @abstract       Two panels must track their own lifetime setting independently.
 */
- (void)testBookmarkLifetimeIsStoredPerPanel {
	NSOpenPanel *panel1 = [NSOpenPanel openPanel];
	NSOpenPanel *panel2 = [NSOpenPanel openPanel];

	panel1.ss_bookmarkLifetime = BESecurityScopedURLBookmarkLifetimeShortLived;
	panel2.ss_bookmarkLifetime = BESecurityScopedURLBookmarkLifetimeLongLived;

	XCTAssertEqual(panel1.ss_bookmarkLifetime, BESecurityScopedURLBookmarkLifetimeShortLived);
	XCTAssertEqual(panel2.ss_bookmarkLifetime, BESecurityScopedURLBookmarkLifetimeLongLived);
	XCTAssertNotEqual(panel1.ss_bookmarkLifetime, panel2.ss_bookmarkLifetime,
					  @"The two panels must not share their lifetime setting");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Factory methods
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase       testSSOpenPanelReturnsPanel
 @abstract       +ss_openPanel must return a non-nil NSOpenPanel instance.
 */
- (void)testSSOpenPanelReturnsPanel {
	NSOpenPanel *panel = [NSOpenPanel ss_openPanel];
	XCTAssertNotNil(panel);
	XCTAssertTrue([panel isKindOfClass:[NSOpenPanel class]]);
}

/*!
 @testcase       testSSOpenPanelUsesSharedManager
 @abstract       +ss_openPanel must pre-configure the panel with the shared manager.
 */
- (void)testSSOpenPanelUsesSharedManager {
	NSOpenPanel *panel = [NSOpenPanel ss_openPanel];
	XCTAssertNotNil(panel.ss_urlManager,
					@"ss_openPanel should set ss_urlManager to the shared manager");
	XCTAssertEqual(panel.ss_urlManager, [BESecurityScopedURLManager sharedManager],
				   @"ss_urlManager must be the singleton shared manager");
}

/*!
 @testcase       testSSOpenPanelDefaultsLifetimeToLongLived
 @abstract       Panels from +ss_openPanel should also start with LongLived lifetime.
 */
- (void)testSSOpenPanelDefaultsLifetimeToLongLived {
	NSOpenPanel *panel = [NSOpenPanel ss_openPanel];
	XCTAssertEqual(panel.ss_bookmarkLifetime,
				   BESecurityScopedURLBookmarkLifetimeLongLived);
}

/*!
 @testcase       testSSOpenPanelWithManagerSetsProvidedManager
 @abstract       +ss_openPanelWithManager: must configure the panel with the supplied manager.
 */
- (void)testSSOpenPanelWithManagerSetsProvidedManager {
	NSOpenPanel *panel = [NSOpenPanel ss_openPanelWithManager:self.manager];
	XCTAssertNotNil(panel);
	XCTAssertTrue([panel isKindOfClass:[NSOpenPanel class]]);
	XCTAssertEqual(panel.ss_urlManager, self.manager,
				   @"ss_urlManager should be the manager that was passed in");
}

/*!
 @testcase       testSSOpenPanelWithNilManagerLeavesManagerNil
 @abstract       Passing nil to +ss_openPanelWithManager: must result in a panel
				 whose ss_urlManager is nil — exercises the nil-manager branch.
 @discussion     The parameter is declared nonnull in NS_ASSUME_NONNULL_BEGIN context.
				 We pass through a nullable typed variable to intentionally suppress
				 the Clang "null passed to nonnull" warning while still reaching the
				 nil-manager branch for testing. This is deliberate: the implementation
				 must handle nil gracefully even though callers should not pass it.
 */
- (void)testSSOpenPanelWithNilManagerLeavesManagerNil {
	// Use a nullable variable to route nil through the nonnull parameter without
	// triggering a -Wnonnull compiler diagnostic.
	BESecurityScopedURLManager * _Nullable nilManager = nil;
	NSOpenPanel *panel = [NSOpenPanel ss_openPanelWithManager:nilManager];
	XCTAssertNotNil(panel, @"Should still return a valid panel even for a nil manager");
	XCTAssertNil(panel.ss_urlManager,
				 @"ss_urlManager must be nil when nil was passed to the factory");
}

/*!
 @testcase       testSSOpenPanelWithManagerProducesDistinctPanelFromSSOpenPanel
 @abstract       +ss_openPanelWithManager: and +ss_openPanel should return different
				 object instances (not cached/reused).
 */
- (void)testSSOpenPanelWithManagerProducesDistinctPanelFromSSOpenPanel {
	NSOpenPanel *panel1 = [NSOpenPanel ss_openPanel];
	NSOpenPanel *panel2 = [NSOpenPanel ss_openPanelWithManager:self.manager];
	XCTAssertNotEqual(panel1, panel2, @"Factory methods should produce distinct panel instances");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - ss_beginWithCompletionHandler:
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase       testSSBeginWithNilHandlerAndNoManagerDoesNotCrash
 @abstract       Passing nil as the completion handler with no manager set must
				 not crash — exercises the nil-handler guard (no manager path).
 */
- (void)testSSBeginWithNilHandlerAndNoManagerDoesNotCrash {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	XCTAssertNoThrow([panel ss_beginWithCompletionHandler:nil]);
#pragma clang diagnostic pop
}

/*!
 @testcase       testSSBeginWithNilHandlerAndManagerSetDoesNotCrash
 @abstract       Passing nil as the completion handler with a manager set must
				 not crash — exercises the nil-handler guard (with manager path).
 */
- (void)testSSBeginWithNilHandlerAndManagerSetDoesNotCrash {
	self.panel.ss_urlManager = self.manager;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	XCTAssertNoThrow([self.panel ss_beginWithCompletionHandler:nil]);
#pragma clang diagnostic pop
}

/*!
 @testcase       testSSBeginWithHandlerAndNoManagerDoesNotCrash
 @abstract       Calling ss_beginWithCompletionHandler: without a manager set
				 must not crash — exercises the "no manager" wrapping branch.
 */
- (void)testSSBeginWithHandlerAndNoManagerDoesNotCrash {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	XCTAssertNoThrow([panel ss_beginWithCompletionHandler:^(NSModalResponse r) {
		(void)r; // Handler body intentionally empty.
	}]);
}

/*!
 @testcase       testSSBeginWithHandlerAndManagerSetDoesNotCrash
 @abstract       Calling ss_beginWithCompletionHandler: with a manager set
				 must not crash — exercises the "with manager" wrapping branch.
 */
- (void)testSSBeginWithHandlerAndManagerSetDoesNotCrash {
	self.panel.ss_urlManager = self.manager;
	self.panel.ss_bookmarkLifetime = BESecurityScopedURLBookmarkLifetimeLongLived;

	XCTAssertNoThrow([self.panel ss_beginWithCompletionHandler:^(NSModalResponse r) {
		(void)r;
	}]);
}

/*!
 @testcase       testSSBeginWithHandlerShortLivedDoesNotCrash
 @abstract       The ss_beginWithCompletionHandler: path must also work with a
				 ShortLived bookmark lifetime — exercises the ShortLived branch.
 */
- (void)testSSBeginWithHandlerShortLivedDoesNotCrash {
	self.panel.ss_urlManager = self.manager;
	self.panel.ss_bookmarkLifetime = BESecurityScopedURLBookmarkLifetimeShortLived;

	XCTAssertNoThrow([self.panel ss_beginWithCompletionHandler:^(NSModalResponse r) {
		(void)r;
	}]);
}

/*!
 @testcase       testSSBeginWithHandlerDoesNotModifyCatalogWithoutSelection
 @abstract       Calling ss_beginWithCompletionHandler: without any panel interaction
				 (no OK click) must not add any URLs to the manager's catalog.
 */
- (void)testSSBeginWithHandlerDoesNotModifyCatalogWithoutSelection {
	self.panel.ss_urlManager = self.manager;
	[self.panel ss_beginWithCompletionHandler:^(NSModalResponse r) {
		(void)r;
	}];

	XCTAssertEqual(self.manager.catalog.count, 0UL,
				   @"No URLs should be added without an actual user selection");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - ss_presetDirectoryAtURL:
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase       testPresetDirectoryAtURLWithDirectoryURL
 @abstract       A directory URL must set panel.directoryURL to that directory.
 */
- (void)testPresetDirectoryAtURLWithDirectoryURL {
	NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
	self.panel.directoryURL = nil;

	[self.panel ss_presetDirectoryAtURL:tempDir];

	XCTAssertNotNil(self.panel.directoryURL,
					@"directoryURL should be set for a directory URL");
}

/*!
 @testcase       testPresetDirectoryAtURLSetsCorrectDirectoryForDirectoryURL
 @abstract       When the input is already a directory, the panel's directoryURL
				 should point at that directory (or a path-equivalent).
 */
- (void)testPresetDirectoryAtURLSetsCorrectDirectoryForDirectoryURL {
	NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
	[self.panel ss_presetDirectoryAtURL:tempDir];

	XCTAssertEqualObjects(self.panel.directoryURL.path.stringByStandardizingPath,
						  tempDir.path.stringByStandardizingPath,
						  @"directoryURL should equal the passed-in directory URL");
}

/*!
 @testcase       testPresetDirectoryAtURLWithExistingFileURL
 @abstract       When the input is a file (not a directory), the panel's directoryURL
				 should be set to the parent directory of that file.
 */
- (void)testPresetDirectoryAtURLWithExistingFileURL {
	// Create a temporary file.
	NSString *filePath = [NSTemporaryDirectory()
						  stringByAppendingPathComponent:@"be_preset_test.txt"];
	[@"test" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	NSURL *fileURL = [NSURL fileURLWithPath:filePath];

	self.panel.directoryURL = nil;
	[self.panel ss_presetDirectoryAtURL:fileURL];

	XCTAssertNotNil(self.panel.directoryURL,
					@"directoryURL should be set to the parent directory of the file");
	XCTAssertEqualObjects(self.panel.directoryURL.path.stringByStandardizingPath,
						  fileURL.URLByDeletingLastPathComponent.path.stringByStandardizingPath,
						  @"directoryURL should be the parent directory of the supplied file URL");

	[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

/*!
 @testcase       testPresetDirectoryAtURLWithNilURLDoesNotChangeDirectory
 @abstract       Passing nil must leave directoryURL unchanged — exercises the nil guard.
 */
- (void)testPresetDirectoryAtURLWithNilURLDoesNotChangeDirectory {
	NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
	self.panel.directoryURL = tempDir;
	NSString *before = self.panel.directoryURL.absoluteString;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	[self.panel ss_presetDirectoryAtURL:nil];
#pragma clang diagnostic pop

	XCTAssertEqualObjects(self.panel.directoryURL.absoluteString, before,
						  @"directoryURL must not change when nil is passed");
}

/*!
 @testcase       testPresetDirectoryAtURLWithNonFileURLDoesNotChangeDirectory
 @abstract       A non-file URL (https://) must leave directoryURL unchanged —
				 exercises the isFileURL guard.
 */
- (void)testPresetDirectoryAtURLWithNonFileURLDoesNotChangeDirectory {
	NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
	self.panel.directoryURL = tempDir;
	NSString *before = self.panel.directoryURL.absoluteString;

	NSURL *httpURL = [NSURL URLWithString:@"https://example.com/path/to/file"];
	[self.panel ss_presetDirectoryAtURL:httpURL];

	XCTAssertEqualObjects(self.panel.directoryURL.absoluteString, before,
						  @"Non-file URL must not change directoryURL");
}

/*!
 @testcase       testPresetDirectoryAtURLWithNonexistentPathSetsParentDirectory
 @abstract       Even a path that does not exist on disk should cause the method to
				 set the panel's directoryURL to the (non-existent) parent directory.
				 The method must not crash on missing resources.
 */
- (void)testPresetDirectoryAtURLWithNonexistentPathSetsParentDirectory {
	NSURL *fictionalFile = [NSURL fileURLWithPath:@"/nonexistent/path/to/file.txt"];
	self.panel.directoryURL = nil;

	[self.panel ss_presetDirectoryAtURL:fictionalFile];

	XCTAssertNotNil(self.panel.directoryURL,
					@"directoryURL should be set even for a non-existent file path");
}

/*!
 @testcase       testPresetDirectoryAtURLCalledMultipleTimesUpdatesEachTime
 @abstract       Calling ss_presetDirectoryAtURL: multiple times must update
				 directoryURL to reflect the most recent call.
 */
- (void)testPresetDirectoryAtURLCalledMultipleTimesUpdatesEachTime {
	NSURL *dir1 = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
	NSURL *dir2 = [NSURL fileURLWithPath:@"/private/tmp" isDirectory:YES];

	[self.panel ss_presetDirectoryAtURL:dir1];
	NSString *pathAfterFirst = self.panel.directoryURL.path.stringByStandardizingPath;

	[self.panel ss_presetDirectoryAtURL:dir2];
	NSString *pathAfterSecond = self.panel.directoryURL.path.stringByStandardizingPath;

	// Both paths should be the standardized equivalents of what was passed.
	XCTAssertEqualObjects(pathAfterFirst,
						  dir1.path.stringByStandardizingPath,
						  @"First preset should have set the temp directory");
	XCTAssertEqualObjects(pathAfterSecond,
						  dir2.path.stringByStandardizingPath,
						  @"Second preset should have overwritten with the new directory");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Integration scenarios
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase       testPanelFullConfigurationChain
 @abstract       Configuring manager, lifetime, and directory in sequence must
				 result in all three properties being set correctly.
 */
- (void)testPanelFullConfigurationChain {
	NSOpenPanel *panel = [NSOpenPanel ss_openPanelWithManager:self.manager];
	panel.ss_bookmarkLifetime = BESecurityScopedURLBookmarkLifetimeShortLived;
	[panel ss_presetDirectoryAtURL:[NSURL fileURLWithPath:NSTemporaryDirectory()
											  isDirectory:YES]];

	XCTAssertEqual(panel.ss_urlManager, self.manager,
				   @"Manager should be set to the provided instance");
	XCTAssertEqual(panel.ss_bookmarkLifetime,
				   BESecurityScopedURLBookmarkLifetimeShortLived,
				   @"Lifetime should reflect the most recent assignment");
	XCTAssertNotNil(panel.directoryURL,
					@"directoryURL should be set after ss_presetDirectoryAtURL:");
}

/*!
 @testcase       testURLManagerIsRetainedByPanel
 @abstract       The panel must hold a strong reference to its ss_urlManager, keeping
				 the manager alive even after the caller's local ARC reference is dropped.
 @discussion     This test verifies the OBJC_ASSOCIATION_RETAIN_NONATOMIC fix (#5).
				 Before the fix, OBJC_ASSOCIATION_ASSIGN stored a raw pointer; releasing
				 the last external reference would deallocate the manager and leave the
				 panel with a dangling pointer. With the fix the panel's retain keeps the
				 manager alive as long as the panel exists.

				 We use a weak reference to observe the manager's lifetime. After zeroing
				 the strong local reference, the manager must NOT have been deallocated as
				 long as the panel still holds it.
 */
- (void)testURLManagerIsRetainedByPanel {
	__weak BESecurityScopedURLManager *weakRef = nil;

	@autoreleasepool {
		// Create a manager inside an inner scope so its only strong reference is
		// the one we are about to transfer to the panel's associated object store.
		BESecurityScopedURLManager *localManager = [[BESecurityScopedURLManager alloc] init];
		localManager.storageOptions = BESecurityScopedURLStorageNone;
		weakRef = localManager;

		// Hand the manager to the panel. With RETAIN semantics the panel now owns it.
		self.panel.ss_urlManager = localManager;

		// Drop our only strong local reference.
		localManager = nil;
	} // localManager ARC released here; inner autorelease pool drains

	// The manager must still be alive because the panel retains it.
	XCTAssertNotNil(weakRef,
					@"The panel must retain its ss_urlManager (OBJC_ASSOCIATION_RETAIN_NONATOMIC); "
					@"the manager must not be deallocated while the panel is alive");

	// Sanity check: after releasing the panel, the manager should be deallocated.
	self.panel = nil;
	XCTAssertNil(weakRef,
				 @"After releasing the panel, the manager (whose only owner was the panel) "
				 @"must be deallocated");
}

/*!
 @testcase       testMultiplePanelsHaveIndependentProperties
 @abstract       Two panels created from the same factory must store their
				 ss_urlManager and ss_bookmarkLifetime independently.
 */
- (void)testMultiplePanelsHaveIndependentProperties {
	BESecurityScopedURLManager *mgr1 = [[BESecurityScopedURLManager alloc] init];
	BESecurityScopedURLManager *mgr2 = [[BESecurityScopedURLManager alloc] init];

	NSOpenPanel *panel1 = [NSOpenPanel ss_openPanelWithManager:mgr1];
	NSOpenPanel *panel2 = [NSOpenPanel ss_openPanelWithManager:mgr2];

	panel1.ss_bookmarkLifetime = BESecurityScopedURLBookmarkLifetimeShortLived;
	panel2.ss_bookmarkLifetime = BESecurityScopedURLBookmarkLifetimeLongLived;

	XCTAssertEqual(panel1.ss_urlManager, mgr1);
	XCTAssertEqual(panel2.ss_urlManager, mgr2);
	XCTAssertNotEqual(panel1.ss_bookmarkLifetime, panel2.ss_bookmarkLifetime,
					  @"Panels should maintain independent bookmark lifetime settings");
}

#pragma mark - Regression Tests (testable bookmark-creation seam)

- (void)testAddURLsToCatalogWithNoManagerReturnsEmpty {
	// The OK-path logic is now a separate seam (ss_addURLsToCatalog:) so it can be tested
	// without driving the panel UI. With no manager, nothing is attempted.
	NSOpenPanel *panel = [NSOpenPanel ss_openPanelWithManager:nil];
	NSArray<NSURL *> *failed = [panel ss_addURLsToCatalog:@[[NSURL fileURLWithPath:@"/tmp"]]];
	XCTAssertEqualObjects(failed, @[], @"With no manager, no URLs are attempted, so none are reported failed.");
}

- (void)testAddURLsToCatalogReturnsFailuresForUnbookmarkableURLs {
	// Non-file / nonexistent URLs cannot be bookmarked; the seam must REPORT the failures
	// rather than silently swallowing them (the previous behavior discarded the BOOL).
	NSOpenPanel *panel = [NSOpenPanel ss_openPanelWithManager:self.manager];
	NSURL *bogus = [NSURL URLWithString:@"https://example.com/not-a-file"];
	NSArray<NSURL *> *failed = [panel ss_addURLsToCatalog:@[bogus]];
	XCTAssertEqual(failed.count, 1u, @"A non-file URL cannot be bookmarked and must be reported.");
	XCTAssertEqualObjects(failed.firstObject, bogus);
}

- (void)testAddURLsToCatalogSuccessPathPopulatesCatalog {
	// A real temp file must bookmark and land in the catalog with the configured lifetime.
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"be_ssadd_success.txt"];
	[@"x" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	NSURL *fileURL = [NSURL fileURLWithPath:path];

	NSOpenPanel *panel = [NSOpenPanel ss_openPanelWithManager:self.manager];
	panel.ss_bookmarkLifetime = BESecurityScopedURLBookmarkLifetimeLongLived;

	NSArray<NSURL *> *failed = [panel ss_addURLsToCatalog:@[fileURL]];
	XCTAssertEqualObjects(failed, @[], @"A real file should bookmark successfully.");
	XCTAssertEqual(self.manager.catalog.count, 1UL, @"The bookmark should land in the catalog.");
	BESecurityScopedURLBookmarkEntry *entry = self.manager.catalog.allValues.firstObject;
	XCTAssertEqual(entry.lifetime, BESecurityScopedURLBookmarkLifetimeLongLived,
				   @"The configured lifetime must be applied.");

	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)testAddURLsToCatalogPartialFailureCatalogsOnlyGoodURLs {
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"be_ssadd_partial.txt"];
	[@"x" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	NSURL *good = [NSURL fileURLWithPath:path];
	NSURL *bad = [NSURL URLWithString:@"https://example.com/x"];

	NSOpenPanel *panel = [NSOpenPanel ss_openPanelWithManager:self.manager];
	NSArray<NSURL *> *failed = [panel ss_addURLsToCatalog:@[good, bad]];

	XCTAssertEqual(failed.count, 1UL);
	XCTAssertEqualObjects(failed.firstObject, bad, @"Only the non-file URL is reported failed.");
	XCTAssertEqual(self.manager.catalog.count, 1UL, @"Only the good URL is cataloged.");

	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)testAddURLsToCatalogEmptyArray {
	NSOpenPanel *panel = [NSOpenPanel ss_openPanelWithManager:self.manager];
	XCTAssertEqualObjects([panel ss_addURLsToCatalog:@[]], @[]);
	XCTAssertEqual(self.manager.catalog.count, 0UL);
}

@end
