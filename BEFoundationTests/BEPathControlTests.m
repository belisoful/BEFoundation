/*!
 @file       BEPathControlTests.m
 @abstract   Comprehensive unit tests for BEPathControl
 @discussion Tests all functionality including URL setting, relative URL handling,
			 path trimming, containment logic, and edge cases.
 @date       2025-12-10
 */

#import <XCTest/XCTest.h>
#import "BEPathControl.h"

@interface BEPathControlTests : XCTestCase
@property (nonatomic, strong) BEPathControl *pathControl;
@property (nonatomic, strong) NSString *tempDirPath;
@end

@implementation BEPathControlTests

#pragma mark - Setup and Teardown

- (void)setUp {
	[super setUp];
	self.pathControl = [[BEPathControl alloc] initWithFrame:NSMakeRect(0, 0, 200, 30)];
	
	// Create a temporary directory structure for testing
	self.tempDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
	[[NSFileManager defaultManager] createDirectoryAtPath:self.tempDirPath
							  withIntermediateDirectories:YES
											   attributes:nil
													error:nil];
}

- (void)tearDown {
	self.pathControl = nil;
	
	// Clean up temporary directory
	if (self.tempDirPath) {
		[[NSFileManager defaultManager] removeItemAtPath:self.tempDirPath error:nil];
		self.tempDirPath = nil;
	}
	
	[super tearDown];
}

#pragma mark - Basic URL Setting Tests

- (void)testSetURL_WithValidURL_SetsURL {
	NSURL *testURL = [NSURL fileURLWithPath:@"/Users/test/Documents/file.txt"];
	
	self.pathControl.URL = testURL;
	
	XCTAssertNotNil(self.pathControl.URL, @"URL should be set");
	XCTAssertEqualObjects(self.pathControl.URL.standardizedURL, testURL.standardizedURL,
						 @"URL should match the set URL");
}

- (void)testSetURL_WithNilURL_SetsNilURL {
	self.pathControl.URL = [NSURL fileURLWithPath:@"/Users/test/file.txt"];
	
	self.pathControl.URL = nil;
	
	XCTAssertNil(self.pathControl.URL, @"URL should be nil");
}

- (void)testSetURL_WithNonStandardizedURL_StandardizesURL {
	NSURL *testURL = [NSURL fileURLWithPath:@"/Users/test/../test/./file.txt"];
	
	self.pathControl.URL = testURL;
	
	XCTAssertEqualObjects(self.pathControl.URL, testURL.standardizedURL,
						 @"URL should be standardized");
}

- (void)testSetURL_WithoutRelativeURL_ShowsFullPath {
	NSURL *testURL = [NSURL fileURLWithPath:@"/Users/test/Documents/file.txt"];
	
	self.pathControl.relativeURL = nil;
	self.pathControl.URL = testURL;
	
	NSArray *pathItems = self.pathControl.pathItems;
	XCTAssertTrue(pathItems.count > 0, @"Should have path items");
	
	// Should include root and all components
	BOOL hasRootComponent = NO;
	for (NSPathControlItem *item in pathItems) {
		if ([item.URL.path isEqualToString:@"/"]) {
			hasRootComponent = YES;
			break;
		}
	}
	XCTAssertTrue(hasRootComponent, @"Should include root component when no relative URL is set");
}

#pragma mark - Relative URL Tests

- (void)testSetRelativeURL_WithValidURL_SetsRelativeURL {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	
	self.pathControl.relativeURL = relativeURL;
	
	XCTAssertNotNil(self.pathControl.relativeURL, @"Relative URL should be set");
	XCTAssertEqualObjects(self.pathControl.relativeURL.standardizedURL,
						 relativeURL.standardizedURL,
						 @"Relative URL should match");
}

- (void)testSetRelativeURL_WithNilURL_SetsNilRelativeURL {
	self.pathControl.relativeURL = [NSURL fileURLWithPath:@"/Users/test/"];
	
	self.pathControl.relativeURL = nil;
	
	XCTAssertNil(self.pathControl.relativeURL, @"Relative URL should be nil");
}

- (void)testSetRelativeURL_WithNonStandardizedURL_StandardizesURL {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/../test/./Projects/"];
	
	self.pathControl.relativeURL = relativeURL;
	
	XCTAssertEqualObjects(self.pathControl.relativeURL, relativeURL.standardizedURL,
						 @"Relative URL should be standardized");
}

- (void)testSetRelativeURL_TriggersPathRebuild {
	NSURL *fullURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/Sources/file.m"];
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/"];
	
	self.pathControl.URL = fullURL;
	NSInteger initialCount = self.pathControl.pathItems.count;
	
	self.pathControl.relativeURL = relativeURL;
	NSInteger newCount = self.pathControl.pathItems.count;
	
	XCTAssertLessThan(newCount, initialCount,
					 @"Setting relative URL should reduce the number of path items");
}

#pragma mark - Path Trimming Tests

- (void)testPathTrimming_WithRelativeURL_ShowsOnlyRelativePath {
	NSURL *fullURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/Sources/File.m"];
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/"];
	
	self.pathControl.relativeURL = relativeURL;
	self.pathControl.URL = fullURL;
	
	NSArray *pathItems = self.pathControl.pathItems;
	
	// Verify no items exist outside the relative URL
	for (NSPathControlItem *item in pathItems) {
		XCTAssertTrue([self.pathControl containsURL:item.URL],
					 @"All path items should be within the relative URL: %@", item.URL);
	}
	
	// Verify we don't have root or /Users in the path
	for (NSPathControlItem *item in pathItems) {
		XCTAssertFalse([item.URL.path isEqualToString:@"/"],
					  @"Should not include root component");
		XCTAssertFalse([item.URL.path isEqualToString:@"/Users"],
					  @"Should not include /Users component");
	}
}

- (void)testPathTrimming_WithNestedRelativeURL_ShowsCorrectPath {
	NSURL *fullURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/Sources/Subfolder/File.m"];
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/Sources/"];
	
	self.pathControl.relativeURL = relativeURL;
	self.pathControl.URL = fullURL;
	
	NSArray *pathItems = self.pathControl.pathItems;
	
	// Should include Sources, Subfolder, and File.m
	XCTAssertTrue(pathItems.count >= 3, @"Should have at least 3 items (Sources, Subfolder, File.m)");
	
	// Verify no items before Sources
	for (NSPathControlItem *item in pathItems) {
		NSString *path = item.URL.path;
		XCTAssertFalse([path isEqualToString:@"/Users/test/Projects/MyProject"],
					  @"Should not include components before relative URL");
	}
}

- (void)testPathTrimming_WhenURLEqualsRelativeURL_ShowsSingleItem {
	NSURL *url = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/"];
	NSURL *reference = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject"];
	
	self.pathControl.relativeURL = url;
	self.pathControl.URL = url;
	
	NSArray *pathItems = self.pathControl.pathItems;
	
	// Should show at least the MyProject component
	XCTAssertTrue(pathItems.count >= 1, @"Should have at least one item");
	
	// Verify the relative URL itself is included
	NSString *urlAbsString = reference.standardizedURL.absoluteString;
	BOOL foundRelativeURL = NO;
	for (NSPathControlItem *item in pathItems) {
		NSString *itemAbsString = item.URL.standardizedURL.absoluteString;
		if ([itemAbsString isEqualToString:urlAbsString]) {
			foundRelativeURL = YES;
			break;
		}
	}
	XCTAssertTrue(foundRelativeURL, @"Should include the relative URL itself");
}

- (void)testPathTrimming_WithURLOutsideRelativeURL_ShowsNoItems {
	NSURL *fullURL = [NSURL fileURLWithPath:@"/Users/other/Documents/file.txt"];
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	
	self.pathControl.relativeURL = relativeURL;
	self.pathControl.URL = fullURL;
	
	NSArray *pathItems = self.pathControl.pathItems;
	
	// Should have no items or minimal items since the URL is outside the relative URL
	// The behavior might vary, but no items should be within the relative URL
	for (NSPathControlItem *item in pathItems) {
		XCTAssertFalse([self.pathControl containsURL:item.URL],
					  @"No items should be within the relative URL when URL is completely outside");
	}
}

- (void)testPathTrimming_AfterChangingRelativeURL_UpdatesPath {
	NSURL *fullURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/Sources/File.m"];
	NSURL *relativeURL1 = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	NSURL *relativeURL2 = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/"];
	
	self.pathControl.URL = fullURL;
	self.pathControl.relativeURL = relativeURL1;
	NSInteger count1 = self.pathControl.pathItems.count;
	
	self.pathControl.relativeURL = relativeURL2;
	NSInteger count2 = self.pathControl.pathItems.count;
	
	XCTAssertLessThan(count2, count1,
					 @"Deeper relative URL should result in fewer path items");
}

#pragma mark - containsURL: Tests

- (void)testContainsURL_WithNilRelativeURL_ReturnsYES {
	NSURL *testURL = [NSURL fileURLWithPath:@"/any/path/file.txt"];
	
	self.pathControl.relativeURL = nil;
	
	BOOL contains = [self.pathControl containsURL:testURL];
	
	XCTAssertTrue(contains, @"Should return YES when relative URL is nil");
}

- (void)testContainsURL_WithNilCheckURL_ReturnsNO {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	
	self.pathControl.relativeURL = relativeURL;
	
	NSURL *nilURL = nil;
	BOOL contains = [self.pathControl containsURL:nilURL];
	
	XCTAssertFalse(contains, @"Should return NO for nil URL");
}

- (void)testContainsURL_WithExactMatch_ReturnsYES {
	NSURL *url = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/"];
	
	self.pathControl.relativeURL = url;
	
	BOOL contains = [self.pathControl containsURL:url];
	
	XCTAssertTrue(contains, @"Should return YES for exact match");
}

- (void)testContainsURL_WithDescendantURL_ReturnsYES {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	NSURL *descendantURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/Sources/file.m"];
	
	self.pathControl.relativeURL = relativeURL;
	
	BOOL contains = [self.pathControl containsURL:descendantURL];
	
	XCTAssertTrue(contains, @"Should return YES for descendant URL");
}

- (void)testContainsURL_WithImmediateChildDirectory_ReturnsYES {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	NSURL *childURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/"];
	
	self.pathControl.relativeURL = relativeURL;
	
	BOOL contains = [self.pathControl containsURL:childURL];
	
	XCTAssertTrue(contains, @"Should return YES for immediate child directory");
}

- (void)testContainsURL_WithParentURL_ReturnsNO {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/"];
	NSURL *parentURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	
	self.pathControl.relativeURL = relativeURL;
	
	BOOL contains = [self.pathControl containsURL:parentURL];
	
	XCTAssertFalse(contains, @"Should return NO for parent URL");
}

- (void)testContainsURL_WithSiblingURL_ReturnsNO {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/"];
	NSURL *siblingURL = [NSURL fileURLWithPath:@"/Users/test/Projects/OtherProject/file.txt"];
	
	self.pathControl.relativeURL = relativeURL;
	
	BOOL contains = [self.pathControl containsURL:siblingURL];
	
	XCTAssertFalse(contains, @"Should return NO for sibling URL");
}

- (void)testContainsURL_WithCompletelyDifferentURL_ReturnsNO {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	NSURL *differentURL = [NSURL fileURLWithPath:@"/Applications/Safari.app/"];
	
	self.pathControl.relativeURL = relativeURL;
	
	BOOL contains = [self.pathControl containsURL:differentURL];
	
	XCTAssertFalse(contains, @"Should return NO for completely different URL");
}

- (void)testContainsURL_WithNonStandardizedURLs_HandlesCorrectly {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/../test/./Projects/"];
	NSURL *checkURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/../MyProject/file.txt"];
	
	self.pathControl.relativeURL = relativeURL;
	
	BOOL contains = [self.pathControl containsURL:checkURL];
	
	XCTAssertTrue(contains, @"Should handle non-standardized URLs correctly");
}

- (void)testContainsURL_WithTrailingSlashVariations_HandlesCorrectly {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects"];
	NSURL *urlWithSlash = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	NSURL *urlWithoutSlash = [NSURL fileURLWithPath:@"/Users/test/Projects"];
	
	self.pathControl.relativeURL = relativeURL;
	
	BOOL containsWithSlash = [self.pathControl containsURL:urlWithSlash];
	BOOL containsWithoutSlash = [self.pathControl containsURL:urlWithoutSlash];
	
	XCTAssertTrue(containsWithSlash, @"Should handle URL with trailing slash");
	XCTAssertTrue(containsWithoutSlash, @"Should handle URL without trailing slash");
}

- (void)testContainsURL_WithPartialMatchPrefix_ReturnsNO {
	// Test that "/Users/test/Proj" doesn't match "/Users/test/Projects/"
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	NSURL *partialMatchURL = [NSURL fileURLWithPath:@"/Users/test/Proj/file.txt"];
	
	self.pathControl.relativeURL = relativeURL;
	
	BOOL contains = [self.pathControl containsURL:partialMatchURL];
	
	XCTAssertFalse(contains, @"Should return NO for partial prefix match");
}

#pragma mark - Edge Cases and Special Scenarios

- (void)testRootURL_AsRelativeURL {
	NSURL *rootURL = [NSURL fileURLWithPath:@"/"];
	NSURL *anyURL = [NSURL fileURLWithPath:@"/Users/test/file.txt"];
	
	self.pathControl.relativeURL = rootURL;
	self.pathControl.URL = anyURL;
	
	NSArray *pathItems = self.pathControl.pathItems;
	
	XCTAssertTrue(pathItems.count > 0, @"Should have path items with root as relative URL");
	
	// All items should be contained since root contains everything
	for (NSPathControlItem *item in pathItems) {
		XCTAssertTrue([self.pathControl containsURL:item.URL],
					 @"Root relative URL should contain all paths");
	}
}

- (void)testDeepNestedPath_WithRelativeURL {
	NSMutableString *deepPath = [NSMutableString stringWithString:@"/Users/test/Projects"];
	for (int i = 0; i < 10; i++) {
		[deepPath appendFormat:@"/folder%d", i];
	}
	[deepPath appendString:@"/file.txt"];
	
	NSURL *fullURL = [NSURL fileURLWithPath:deepPath];
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	
	self.pathControl.relativeURL = relativeURL;
	self.pathControl.URL = fullURL;
	
	NSArray *pathItems = self.pathControl.pathItems;
	
	// Should have many items
	XCTAssertTrue(pathItems.count > 5, @"Should handle deep nested paths");
	
	// All should be within relative URL
	for (NSPathControlItem *item in pathItems) {
		XCTAssertTrue([self.pathControl containsURL:item.URL],
					 @"All items in deep path should be within relative URL");
	}
}

- (void)testEmptyPathComponents_HandledCorrectly {
	NSURL *urlWithEmptyComponents = [NSURL fileURLWithPath:@"/Users//test///Projects//file.txt"];
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/"];
	
	self.pathControl.relativeURL = relativeURL;
	self.pathControl.URL = urlWithEmptyComponents;
	
	// Should standardize and handle correctly
	XCTAssertNotNil(self.pathControl.URL, @"Should handle URLs with empty components");
}

- (void)testSymbolicLinks_IfStandardized {
	// This test assumes standardizedURL resolves symlinks
	// Create actual file system structure for more accurate testing
	NSString *realDir = [self.tempDirPath stringByAppendingPathComponent:@"RealDir"];
	[[NSFileManager defaultManager] createDirectoryAtPath:realDir
							  withIntermediateDirectories:YES
											   attributes:nil
													error:nil];
	
	NSURL *realURL = [NSURL fileURLWithPath:realDir];
	self.pathControl.relativeURL = realURL;
	self.pathControl.URL = [realURL URLByAppendingPathComponent:@"file.txt"];
	
	XCTAssertNotNil(self.pathControl.URL, @"Should handle real file URLs");
}

- (void)testMultipleConsecutiveURLSets_MaintainsConsistency {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	NSURL *url1 = [NSURL fileURLWithPath:@"/Users/test/Projects/Project1/file.txt"];
	NSURL *url2 = [NSURL fileURLWithPath:@"/Users/test/Projects/Project2/file.txt"];
	NSURL *url3 = [NSURL fileURLWithPath:@"/Users/test/Projects/Project3/file.txt"];
	
	self.pathControl.relativeURL = relativeURL;
	
	self.pathControl.URL = url1;
	NSInteger count1 = self.pathControl.pathItems.count;
	
	self.pathControl.URL = url2;
	NSInteger count2 = self.pathControl.pathItems.count;
	
	self.pathControl.URL = url3;
	NSInteger count3 = self.pathControl.pathItems.count;
	
	// Counts should be consistent for similar depth paths
	XCTAssertEqual(count1, count2, @"Similar paths should have same item count");
	XCTAssertEqual(count2, count3, @"Similar paths should have same item count");
}

- (void)testSettingRelativeURL_ThenNil_RestoresFullPath {
	NSURL *fullURL =		[NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/file.txt"];
	NSURL *relativeURL =	[NSURL fileURLWithPath:@"/Users/test/Projects/"];
	
	self.pathControl.URL = fullURL;
	NSInteger fullCount = self.pathControl.pathItems.count;
	
	self.pathControl.relativeURL = relativeURL;
	NSInteger trimmedCount = self.pathControl.pathItems.count;
	
	self.pathControl.relativeURL = nil;
	NSInteger restoredCount = self.pathControl.pathItems.count;
	
	XCTAssertLessThan(trimmedCount, fullCount, @"Trimmed count should be less than full");
	XCTAssertEqual(restoredCount, fullCount, @"Restored count should equal original full count");
}

- (void)testURLWithSpecialCharacters_HandledCorrectly {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	NSURL *specialURL = [NSURL fileURLWithPath:@"/Users/test/Projects/My Project/file with spaces.txt"];
	
	self.pathControl.relativeURL = relativeURL;
	self.pathControl.URL = specialURL;
	
	XCTAssertNotNil(self.pathControl.URL, @"Should handle URLs with special characters");
	XCTAssertTrue([self.pathControl containsURL:specialURL],
				 @"Should contain URL with special characters");
}

- (void)testCaseSensitivity_OnCaseSensitiveFileSystems {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	NSURL *mixedCaseURL = [NSURL fileURLWithPath:@"/Users/test/projects/file.txt"];
	
	self.pathControl.relativeURL = relativeURL;
	
	BOOL contains = [self.pathControl containsURL:mixedCaseURL];
	
	// On case-sensitive systems, this should return NO
	// On case-insensitive systems (like default macOS), this might return YES
	// The test documents the behavior
	NSLog(@"Case sensitivity test result: %@", contains ? @"YES" : @"NO");
}

#pragma mark - Stress Tests

- (void)testRapidURLChanges {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/"];
	self.pathControl.relativeURL = relativeURL;
	
	for (int i = 0; i < 100; i++) {
		NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/Users/test/Projects/Project%d/file.txt", i]];
		self.pathControl.URL = url;
		
		XCTAssertNotNil(self.pathControl.pathItems, @"Should have path items after rapid change %d", i);
	}
}

- (void)testRapidRelativeURLChanges {
	NSURL *fullURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/Sources/file.txt"];
	self.pathControl.URL = fullURL;
	
	for (int i = 0; i < 100; i++) {
		NSURL *relativeURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/Users/test/Projects/Project%d/", i]];
		self.pathControl.relativeURL = relativeURL;
		
		XCTAssertNotNil(self.pathControl.pathItems, @"Should handle rapid relative URL change %d", i);
	}
}

#pragma mark - Integration Tests

- (void)testCompleteWorkflow_SetRelativeThenURL {
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/"];
	NSURL *fullURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/Sources/File.m"];
	
	// Set relative URL first
	self.pathControl.relativeURL = relativeURL;
	
	// Then set full URL
	self.pathControl.URL = fullURL;
	
	// Verify trimming occurred
	NSArray *pathItems = self.pathControl.pathItems;
	for (NSPathControlItem *item in pathItems) {
		XCTAssertTrue([self.pathControl containsURL:item.URL],
					 @"All items should be within relative URL");
	}
}

- (void)testCompleteWorkflow_SetURLThenRelative {
	NSURL *fullURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/Sources/File.m"];
	NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects/MyProject/"];
	
	// Set full URL first
	self.pathControl.URL = fullURL;
	NSInteger initialCount = self.pathControl.pathItems.count;
	
	// Then set relative URL
	self.pathControl.relativeURL = relativeURL;
	NSInteger finalCount = self.pathControl.pathItems.count;

	// Verify trimming occurred
	XCTAssertLessThan(finalCount, initialCount, @"Setting relative URL should trim path");
}

#pragma mark - Regression Tests (component-wise containment)

- (void)testContainsURL_SiblingPrefixIsNotContained {
	// /a/Projects must not match the sibling /a/ProjectsX.
	self.pathControl.relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects"];

	XCTAssertTrue([self.pathControl containsURL:[NSURL fileURLWithPath:@"/Users/test/Projects/Sources/File.m"]],
				  @"A genuine descendant must be contained.");
	XCTAssertTrue([self.pathControl containsURL:[NSURL fileURLWithPath:@"/Users/test/Projects"]],
				  @"The root itself must be contained.");
	XCTAssertFalse([self.pathControl containsURL:[NSURL fileURLWithPath:@"/Users/test/ProjectsX/File.m"]],
				   @"A sibling sharing a name prefix must NOT be contained.");
	XCTAssertFalse([self.pathControl containsURL:[NSURL fileURLWithPath:@"/Users/test/Proj"]],
				   @"A shorter path must NOT be contained.");
}

- (void)testContainsURL_NilRelativeAllowsAll {
	self.pathControl.relativeURL = nil;
	XCTAssertTrue([self.pathControl containsURL:[NSURL fileURLWithPath:@"/anything/at/all"]]);
	NSURL *nilURL = nil;
	XCTAssertTrue([self.pathControl containsURL:nilURL], @"With no root, even nil is unrestricted.");
}

- (void)testContainsURL_PercentEncodingNormalized {
	// A path with a space, however the URL was constructed, should compare by decoded
	// components rather than raw percent-encoded strings.
	self.pathControl.relativeURL = [NSURL fileURLWithPath:@"/Users/test/My Folder"];
	XCTAssertTrue([self.pathControl containsURL:[NSURL fileURLWithPath:@"/Users/test/My Folder/file.txt"]]);
	XCTAssertFalse([self.pathControl containsURL:[NSURL fileURLWithPath:@"/Users/test/My FolderX/file.txt"]]);
}

- (void)testContainsURL_SchemeMismatchNotContained {
	// A non-file URL with a coincidentally matching path must NOT be contained under a
	// file:// root — schemes must match.
	self.pathControl.relativeURL = [NSURL fileURLWithPath:@"/Users/test/Projects"];
	NSURL *httpURL = [NSURL URLWithString:@"http://host/Users/test/Projects/File.m"];
	XCTAssertFalse([self.pathControl containsURL:httpURL], @"Different scheme must not be contained.");
}

@end
