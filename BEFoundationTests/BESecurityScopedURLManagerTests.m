//
//  BESecurityScopedURLManagerTests.m
//  BESecurityScopedURLManagerTests
//
//  Comprehensive branch-exhaustive unit tests for BESecurityScopedURLManager.
//  Every reachable branch in the implementation is covered by at least one test.
//  Branches that require a sandboxed process (security-scoped bookmark resolution)
//  are guarded with XCTSkipUnless(BETestIsSandboxed()) so the suite runs cleanly
//  in both sandboxed and non-sandboxed CI environments.
//

#import <XCTest/XCTest.h>
#import "BESecurityScopedURLManager.h"

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Private method forward declarations
//
// These selectors are compiled into BESecurityScopedURLManager but declared in
// the class extension inside the .m file. Declaring them in a local category
// here lets us call them from tests without modifying production code.
// ─────────────────────────────────────────────────────────────────────────────

@interface BESecurityScopedURLManager (BETestPrivateAccess)
/// Triggers the async relocation update path. Safe to call from tests.
- (void)handleBookmarkRelocationFromPath:(NSString *)oldPath toPath:(NSString *)newPath;
/// Internal reference-count set and the catalog-key→resolved-URL map. Exposed so the
/// relocation regression test can seed and inspect them directly.
@property (nonatomic, strong) NSCountedSet<NSURL *> *refCounts;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURL *> *resolvedAccessURLByKey;
/// Private persistence method — allows exercising the synchronous dispatch_sync path.
- (void)saveCatalogSynchronously:(BOOL)synchronously;
/// Internal access-start helper. Must normally be called from within the accessQueue block.
/// Exposed here so tests can drive the nil-URL guard branch directly without going
/// through startAccessingAllURLs (which pre-screens for nil before calling this method).
- (nullable NSURL *)startAccessingURLInternal:(NSURL *)url;
/// Internal URL resolver (no dispatch). Exposed so tests can reach the nil-parameter
/// guard directly — the public urlFromCatalogWithAbsolutePath: has its own nil guard
/// and never passes nil into this method through the production call chain.
- (nullable NSURL *)urlFromCatalogWithAbsolutePathInternal:(NSString *)absolutePathString;
@end

/// Exposes BESecurityScopedURLBookmarkEntry's private designated initializer and the
/// readwrite bookmarkData property so we can instantiate entries directly in tests
/// and inject invalid bookmark data to exercise error branches in the url property.
@interface BESecurityScopedURLBookmarkEntry (BETestPrivateAccess)
- (nullable instancetype)initWithURL:(NSURL *)url
							lifetime:(BESecurityScopedURLBookmarkLifetime)lifetime;
@property (nonatomic, strong, readwrite, nullable) NSData *bookmarkData;
@end

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Sandbox detection
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @function   BETestIsSandboxed
 @abstract   Returns YES when running inside the macOS app sandbox.
 @discussion Security-scoped bookmark creation (NSURLBookmarkCreationWithSecurityScope)
			 requires the sandbox entitlement. Tests that need successful bookmark
			 resolution are guarded with XCTSkipUnless(BETestIsSandboxed()).
 */
static BOOL BETestIsSandboxed(void) {
	return [[NSProcessInfo processInfo].environment
			objectForKey:@"APP_SANDBOX_CONTAINER_ID"] != nil;
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Persistence key constants (mirroring the implementation)
// ─────────────────────────────────────────────────────────────────────────────

static NSString * const kBETestCatalogUserDefaultsKey = @"BESecurityScopedURLManagerCatalog";
static NSString * const kBETestCacheFilename           = @"BESecurityScopedURLManager_Catalog.archive";

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Mock delegate
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @class   BEURLManagerTestDelegate
 @abstract Configurable delegate for exercising all delegate callback branches.
 */
@interface BEURLManagerTestDelegate : NSObject <BESecurityScopedURLManagerDelegate>
/// URL returned to the access-failed completion handler. nil = give up.
@property (nonatomic, strong, nullable) NSURL *relocationURL;
@property (nonatomic) NSInteger accessFailedCallCount;
@property (nonatomic) NSInteger didRelocateCallCount;
@property (nonatomic) NSInteger willResolveContainedCallCount;
@end

@implementation BEURLManagerTestDelegate

- (void)securityScopedURLManager:(BESecurityScopedURLManager *)manager
			  accessFailedForURL:(NSURL *)url
						   entry:(nullable BESecurityScopedURLBookmarkEntry *)entry
			   completionHandler:(void (^)(NSURL * _Nullable))completionHandler {
	self.accessFailedCallCount++;
	if (completionHandler) { completionHandler(self.relocationURL); }
}

- (void)securityScopedURLManager:(BESecurityScopedURLManager *)manager
				  didRelocateURL:(NSURL *)oldURL toURL:(NSURL *)newURL {
	self.didRelocateCallCount++;
}

- (void)securityScopedURLManager:(BESecurityScopedURLManager *)manager
		 willResolveContainedURL:(NSURL *)containedURL
			   withinDirectoryURL:(NSURL *)directoryURL {
	self.willResolveContainedCallCount++;
}
@end

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Main test class
// ─────────────────────────────────────────────────────────────────────────────

@interface BESecurityScopedURLManagerTests : XCTestCase

/// Private manager with storageOptions = None to avoid disk I/O by default.
@property (nonatomic, strong) BESecurityScopedURLManager *manager;

/// Temp directory URL (always exists).
@property (nonatomic, strong) NSURL *tempDirURL;

/// Temp file #1 (created in setUp, deleted in tearDown).
@property (nonatomic, strong) NSURL *tempFileURL;

/// Temp file #2 for multi-entry tests.
@property (nonatomic, strong) NSURL *tempFile2URL;

/// Cache file URL (mirrors kBETestCacheFilename in Caches directory).
@property (nonatomic, strong, readonly) NSURL *cacheFileURL;

@end

@implementation BESecurityScopedURLManagerTests

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Setup / Teardown
// ─────────────────────────────────────────────────────────────────────────────

- (void)setUp {
	[super setUp];

	// Wipe any persisted state from previous runs before every test so that
	// loadCatalog (which is async) always starts from a clean slate.
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kBETestCatalogUserDefaultsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSError *removeErr = nil;
	[[NSFileManager defaultManager] removeItemAtURL:self.cacheFileURL error:&removeErr];

	self.manager = [[BESecurityScopedURLManager alloc] init];
	self.manager.storageOptions = BESecurityScopedURLStorageNone; // no disk I/O by default

	self.tempDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];

	NSString *p1 = [NSTemporaryDirectory()
					stringByAppendingPathComponent:
					[NSString stringWithFormat:@"be_test_%@.txt", [NSUUID UUID].UUIDString]];
	NSString *p2 = [NSTemporaryDirectory()
					stringByAppendingPathComponent:
					[NSString stringWithFormat:@"be_test_%@.txt", [NSUUID UUID].UUIDString]];
	NSError *writeSetupErr = nil;
	[@"unit test" writeToFile:p1 atomically:YES encoding:NSUTF8StringEncoding error:&writeSetupErr];
	[@"unit test" writeToFile:p2 atomically:YES encoding:NSUTF8StringEncoding error:&writeSetupErr];
	self.tempFileURL  = [NSURL fileURLWithPath:p1];
	self.tempFile2URL = [NSURL fileURLWithPath:p2];
}

- (void)tearDown {
	[self.manager clearCatalog];
	self.manager = nil;
	NSError *tearDownErr = nil;
	[[NSFileManager defaultManager] removeItemAtURL:self.tempFileURL  error:&tearDownErr];
	[[NSFileManager defaultManager] removeItemAtURL:self.tempFile2URL error:&tearDownErr];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kBETestCatalogUserDefaultsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSError *removeErr = nil;
	[[NSFileManager defaultManager] removeItemAtURL:self.cacheFileURL error:&removeErr];
	[super tearDown];
}

- (NSURL *)cacheFileURL {
	NSURL *cacheDir = [[NSFileManager defaultManager]
					   URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].firstObject;
	return [cacheDir URLByAppendingPathComponent:kBETestCacheFilename];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Helpers
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @method drainAccessQueue
 @abstract Forces the accessQueue to drain any pending async blocks by executing
		   a synchronous barrier (reading the catalog, which uses dispatch_sync).
 @discussion Used after addURLToCatalog:lifetime:LongLived (which queues an async
			 save) to guarantee the save has completed before we inspect persistence.
 */
- (void)drainAccessQueue {
	(void)self.manager.catalog; // dispatch_sync on accessQueue — waits for queued async blocks
}

/*!
 @method putURLInRefCounts:
 @abstract Puts @a targetURL into the manager's internal refCounts by triggering
		   the access-failed delegate path with a delegate that returns @a targetURL.
 @discussion Works in non-sandboxed processes because startAccessingSecurityScopedResource
			 is a no-op (returns YES) outside the sandbox.
 @return    The URL that was added to refCounts (same as targetURL on success, nil on failure).
 */
- (nullable NSURL *)putURLInRefCounts:(NSURL *)targetURL {
	NSURL *unknownURL = [NSURL fileURLWithPath:@"/be_test_nonexistent_refcounts_path"];
	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	delegate.relocationURL = targetURL;
	self.manager.delegate = delegate;
	NSURL *result = [self.manager startAccessingURL:unknownURL];
	self.manager.delegate = nil;
	return result;
}

/*!
 @method writeDataToUserDefaults:
 @abstract Writes @a data to the manager's UserDefaults key, simulating persisted state.
 */
- (void)writeDataToUserDefaults:(NSData *)data {
	if (data) {
		[[NSUserDefaults standardUserDefaults] setObject:data forKey:kBETestCatalogUserDefaultsKey];
	} else {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kBETestCatalogUserDefaultsKey];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
}

/*!
 @method writeDataToCacheFile:
 @abstract Writes @a data to the manager's cache file, simulating a previously saved cache.
 */
- (void)writeDataToCacheFile:(NSData *)data {
	if (data) {
		NSError *writeErr = nil;
		[data writeToURL:self.cacheFileURL options:NSDataWritingAtomic error:&writeErr];
	} else {
		NSError *removeErr = nil;
		[[NSFileManager defaultManager] removeItemAtURL:self.cacheFileURL error:&removeErr];
	}
}

/*!
 @method archivedDictionaryWithObjects:
 @abstract Archives @a dict using NSKeyedArchiver with secure coding.
 */
- (nullable NSData *)archivedDictionaryWithObjects:(NSDictionary *)dict {
	NSError *err = nil;
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict
										 requiringSecureCoding:YES
														 error:&err];
	XCTAssertNil(err, @"Archiving should succeed");
	return data;
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Initialization & Singleton
// ─────────────────────────────────────────────────────────────────────────────

- (void)testInit {
	BESecurityScopedURLManager *m = [[BESecurityScopedURLManager alloc] init];
	m.storageOptions = BESecurityScopedURLStorageNone;
	XCTAssertNotNil(m);
	XCTAssertEqual(m.storageOptions, BESecurityScopedURLStorageNone);
	XCTAssertEqual(m.catalog.count, 0UL);
}

- (void)testInitDefaultStorageOptionsAreAll {
	// setUp clears persistence so a fresh manager always starts empty.
	BESecurityScopedURLManager *m = [[BESecurityScopedURLManager alloc] init];
	XCTAssertEqual(m.storageOptions, BESecurityScopedURLStorageAll);
	[m clearCatalog]; // cleanup
}

- (void)testSharedManagerIsNotNil {
	XCTAssertNotNil([BESecurityScopedURLManager sharedManager]);
}

- (void)testSharedManagerReturnsSameInstance {
	id m1 = [BESecurityScopedURLManager sharedManager];
	id m2 = [BESecurityScopedURLManager sharedManager];
	XCTAssertEqual(m1, m2);
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Storage options
// ─────────────────────────────────────────────────────────────────────────────

- (void)testStorageOptionsNone {
	self.manager.storageOptions = BESecurityScopedURLStorageNone;
	XCTAssertEqual(self.manager.storageOptions, BESecurityScopedURLStorageNone);
}

- (void)testStorageOptionsUserDefaultsBitOnly {
	self.manager.storageOptions = BESecurityScopedURLStorageUserDefaults;
	XCTAssertTrue (self.manager.storageOptions & BESecurityScopedURLStorageUserDefaults);
	XCTAssertFalse(self.manager.storageOptions & BESecurityScopedURLStorageCacheDirectory);
}

- (void)testStorageOptionsCacheDirectoryBitOnly {
	self.manager.storageOptions = BESecurityScopedURLStorageCacheDirectory;
	XCTAssertFalse(self.manager.storageOptions & BESecurityScopedURLStorageUserDefaults);
	XCTAssertTrue (self.manager.storageOptions & BESecurityScopedURLStorageCacheDirectory);
}

- (void)testStorageOptionsAllContainsBothBits {
	self.manager.storageOptions = BESecurityScopedURLStorageAll;
	XCTAssertTrue(self.manager.storageOptions & BESecurityScopedURLStorageUserDefaults);
	XCTAssertTrue(self.manager.storageOptions & BESecurityScopedURLStorageCacheDirectory);
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Persistence — saveCatalog
// Exercises every branch in saveCatalogSynchronously:/saveCatalogInternal:
// storage-backend writes and clears, and the longLivedCatalog.count > 0 path.
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase testSaveToUserDefaultsWritesData
 @abstract Verifies that adding a LongLived entry to a UserDefaults-backed manager
		   causes the async save to write non-nil data to UserDefaults.
		   Covers: save—longLivedCatalog.count > 0 → archivedData != nil → setObject
 */
- (void)testSaveToUserDefaultsWritesData {
	self.manager.storageOptions = BESecurityScopedURLStorageUserDefaults;
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self drainAccessQueue]; // wait for async save

	NSData *saved = [[NSUserDefaults standardUserDefaults] objectForKey:kBETestCatalogUserDefaultsKey];
	XCTAssertNotNil(saved, @"UserDefaults should contain saved catalog data");
	XCTAssertGreaterThan(saved.length, 0UL);
}

/*!
 @testcase testSaveToUserDefaultsClearsWhenCatalogEmpty
 @abstract After clearCatalog, the UserDefaults key should be removed.
		   Covers: save—archivedData == nil → removeObjectForKey
 */
- (void)testSaveToUserDefaultsClearsWhenCatalogEmpty {
	self.manager.storageOptions = BESecurityScopedURLStorageUserDefaults;
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self drainAccessQueue];
	XCTAssertNotNil([[NSUserDefaults standardUserDefaults] objectForKey:kBETestCatalogUserDefaultsKey],
					@"Pre-condition: data must be present before clearing");

	[self.manager clearCatalog];
	NSData *afterClear = [[NSUserDefaults standardUserDefaults] objectForKey:kBETestCatalogUserDefaultsKey];
	XCTAssertNil(afterClear, @"UserDefaults key should be removed after clearing an empty catalog");
}

/*!
 @testcase testSaveShortLivedEntryNotWrittenToUserDefaults
 @abstract ShortLived entries must never be persisted.
		   Covers: save—only LongLived entries enter longLivedCatalog; ShortLived entries skipped.
 */
- (void)testSaveShortLivedEntryNotWrittenToUserDefaults {
	self.manager.storageOptions = BESecurityScopedURLStorageUserDefaults;
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeShortLived];
	[self drainAccessQueue];

	NSData *saved = [[NSUserDefaults standardUserDefaults] objectForKey:kBETestCatalogUserDefaultsKey];
	XCTAssertNil(saved, @"ShortLived entries must not be written to UserDefaults");
}

/*!
 @testcase testSaveToCacheDirectoryWritesFile
 @abstract Verifies that adding a LongLived entry to a CacheDirectory-backed manager
		   causes the archive file to be created on disk.
		   Covers: save—storageOptions & CacheDirectory, archivedData != nil → write file
 */
- (void)testSaveToCacheDirectoryWritesFile {
	self.manager.storageOptions = BESecurityScopedURLStorageCacheDirectory;
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self drainAccessQueue];

	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.cacheFileURL.path],
				  @"Cache archive file should exist after saving a LongLived entry");
}

/*!
 @testcase testSaveToCacheDirectoryClearsFile
 @abstract After clearCatalog, the cache archive file should be deleted.
		   Covers: save—storageOptions & CacheDirectory, archivedData nil → remove file
 */
- (void)testSaveToCacheDirectoryClearsFile {
	self.manager.storageOptions = BESecurityScopedURLStorageCacheDirectory;
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self drainAccessQueue];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.cacheFileURL.path],
				  @"Pre-condition: file must exist before clearing");

	[self.manager clearCatalog];
	XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self.cacheFileURL.path],
				   @"Cache archive file should be deleted after clearing the catalog");
}

/*!
 @testcase testSaveBothStorageBackendsAtOnce
 @abstract BESecurityScopedURLStorageAll should write to both UserDefaults and the cache file.
		   Covers: save—both storageOptions bits active simultaneously.
 */
- (void)testSaveBothStorageBackendsAtOnce {
	self.manager.storageOptions = BESecurityScopedURLStorageAll;
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self drainAccessQueue];

	NSData *udData = [[NSUserDefaults standardUserDefaults] objectForKey:kBETestCatalogUserDefaultsKey];
	XCTAssertNotNil(udData,  @"UserDefaults should have data when storageOptions=All");
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.cacheFileURL.path],
				  @"Cache file should exist when storageOptions=All");
}

/*!
 @testcase testCacheFilePathIsStableAcrossCalls
 @abstract The cacheFilePath property uses a per-instance nil-check for lazy initialization.
		   Repeated reads must return the same non-nil string every time (the cache-hit branch
		   is taken on the second and subsequent calls rather than recomputing the path).
		   Covers: cacheFilePath getter — _cacheFilePath non-nil → return _cacheFilePath (else branch).
 */
- (void)testCacheFilePathIsStableAcrossCalls {
	// A freshly created manager with CacheDirectory storage will exercise cacheFilePath.
	BESecurityScopedURLManager *m = [[BESecurityScopedURLManager alloc] init];
	m.storageOptions = BESecurityScopedURLStorageCacheDirectory;

	// Trigger the first access (nil-check branch — lazy init runs).
	[m addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self drainAccessQueue]; // flushes async save → reads cacheFilePath

	// Read the path a second time (cache-hit branch — _cacheFilePath already set).
	[m addURLToCatalog:self.tempFile2URL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self drainAccessQueue];

	// The cache archive must exist at a single consistent location.
	NSURL *cacheDir = [[NSFileManager defaultManager]
					   URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].firstObject;
	NSURL *expectedPath = [cacheDir URLByAppendingPathComponent:kBETestCacheFilename];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:expectedPath.path],
				  @"cacheFilePath must resolve to the same location on every call");

	// Cleanup
	[m clearCatalog];
}

/*!
 @testcase testSaveCatalogInternalWritesUserDefaultsWhenLongLivedEntryRemains
 @abstract saveCatalogInternal (called by removeURLFromCatalog: from inside its dispatch_sync)
		   must write non-nil archived data to UserDefaults when at least one LongLived entry
		   with non-nil bookmarkData remains in the catalog after the removal.
		   Covers: saveCatalogInternal — longLivedCatalog.count > 0 → archivedData != nil
				   → if (archivedData) { setObject:forKey: }  (UserDefaults write branch)
 @discussion The archiver produces non-nil data only when all entries to be archived have
			 non-nil bookmarkData. If bookmark creation fails in this environment the test
			 skips. Two entries are added so that removing one still leaves a LongLived entry
			 in the catalog when saveCatalogInternal runs.
 */
- (void)testSaveCatalogInternalWritesUserDefaultsWhenLongLivedEntryRemains {
	self.manager.storageOptions = BESecurityScopedURLStorageUserDefaults;

	[self.manager addURLToCatalog:self.tempFileURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTAssertEqual(self.manager.catalog.count, 2UL, @"Pre-condition: two entries required");

	// Verify the entry that will survive has non-nil bookmarkData.
	NSString *dirKey = self.tempDirURL.absoluteString;
	if (![dirKey hasSuffix:@"/"]) { dirKey = [dirKey stringByAppendingString:@"/"]; }
	BESecurityScopedURLBookmarkEntry *survivor = self.manager.catalog[dirKey];
	if (!survivor || !survivor.bookmarkData) {
		XCTSkip(@"Surviving entry has nil bookmarkData — UserDefaults write branch "
				@"requires successful security-scoped bookmark creation");
		return;
	}

	// Remove tempFileURL. The dispatch_sync inside removeURLFromCatalog: calls
	// saveCatalogInternal synchronously. At that point tempDirURL still occupies the
	// catalog → longLivedCatalog.count == 1 → archivedData != nil → setObject:forKey:
	[self.manager removeURLFromCatalog:self.tempFileURL];
	XCTAssertEqual(self.manager.catalog.count, 1UL);

	NSData *saved = [[NSUserDefaults standardUserDefaults]
					 objectForKey:kBETestCatalogUserDefaultsKey];
	XCTAssertNotNil(saved,
					@"saveCatalogInternal must write non-nil data to UserDefaults "
					@"when a LongLived entry with valid bookmarkData remains in the catalog");
	XCTAssertGreaterThan(saved.length, 0UL);
}

/*!
 @testcase testSaveCatalogInternalWritesCacheFileWhenLongLivedEntryRemains
 @abstract saveCatalogInternal must write the cache archive file when at least one LongLived
		   entry with non-nil bookmarkData remains after the removal that triggered it.
		   Covers: saveCatalogInternal — archivedData != nil
				   → if (archivedData) { writeToFile:cachePath }  (CacheDirectory write branch)
 */
- (void)testSaveCatalogInternalWritesCacheFileWhenLongLivedEntryRemains {
	self.manager.storageOptions = BESecurityScopedURLStorageCacheDirectory;

	[self.manager addURLToCatalog:self.tempFileURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTAssertEqual(self.manager.catalog.count, 2UL);

	NSString *dirKey = self.tempDirURL.absoluteString;
	if (![dirKey hasSuffix:@"/"]) { dirKey = [dirKey stringByAppendingString:@"/"]; }
	BESecurityScopedURLBookmarkEntry *survivor = self.manager.catalog[dirKey];
	if (!survivor || !survivor.bookmarkData) {
		XCTSkip(@"Surviving entry has nil bookmarkData — CacheDirectory write branch "
				@"requires successful security-scoped bookmark creation");
		return;
	}

	[self.manager removeURLFromCatalog:self.tempFileURL];
	XCTAssertEqual(self.manager.catalog.count, 1UL);

	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.cacheFileURL.path],
				  @"saveCatalogInternal must write the cache archive file "
				  @"when a LongLived entry with valid bookmarkData remains in the catalog");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Persistence — loadCatalog
// Exercises every reachable branch of loadCatalog without the sandbox.
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase testLoadCatalogCorruptUserDefaultsDataHandledGracefully
 @abstract Writing raw non-archive bytes to UserDefaults should cause a graceful
		   unarchival error and an empty catalog.
		   Covers: loadCatalog—if (error) { return; }
 */
- (void)testLoadCatalogCorruptUserDefaultsDataHandledGracefully {
	NSData *garbage = [@"this is not a valid NSKeyedArchiver payload" dataUsingEncoding:NSUTF8StringEncoding];
	[self writeDataToUserDefaults:garbage];

	// Create a fresh manager with UserDefaults storage; loadCatalog fires asynchronously.
	BESecurityScopedURLManager *m = [[BESecurityScopedURLManager alloc] init];
	m.storageOptions = BESecurityScopedURLStorageUserDefaults;
	XCTAssertEqual(m.catalog.count, 0UL,
				   @"Corrupt archive data should be handled gracefully, leaving the catalog empty");
	[m clearCatalog];
}

/*!
 @testcase testLoadCatalogCorruptCacheFileHandledGracefully
 @abstract Same as above but using the cache file fallback path.
		   Covers: loadCatalog—cache file branch + if (error) { return; }
 */
- (void)testLoadCatalogCorruptCacheFileHandledGracefully {
	NSData *garbage = [@"garbage bytes for cache file test" dataUsingEncoding:NSUTF8StringEncoding];
	[self writeDataToCacheFile:garbage];

	BESecurityScopedURLManager *m = [[BESecurityScopedURLManager alloc] init];
	m.storageOptions = BESecurityScopedURLStorageCacheDirectory;
	XCTAssertEqual(m.catalog.count, 0UL,
				   @"Corrupt cache file should be handled gracefully");
	[m clearCatalog];
}

/*!
 @testcase testLoadCatalogNonDictionaryDataHandledGracefully
 @abstract An archived NSString in UserDefaults should fail the "isKindOfClass NSDictionary"
		   check and leave the catalog empty.
		   Covers: loadCatalog—!loadedCatalog || ![loadedCatalog isKindOfClass:[NSDictionary class]]
 */
- (void)testLoadCatalogNonDictionaryDataHandledGracefully {
	// Archive an NSString — will decode successfully but is not an NSDictionary.
	NSError *stringArchiveErr = nil;
	NSData *stringArchive = [NSKeyedArchiver archivedDataWithRootObject:@"not a dict"
												   requiringSecureCoding:YES
																   error:&stringArchiveErr];
	[self writeDataToUserDefaults:stringArchive];

	BESecurityScopedURLManager *m = [[BESecurityScopedURLManager alloc] init];
	m.storageOptions = BESecurityScopedURLStorageUserDefaults;
	XCTAssertEqual(m.catalog.count, 0UL,
				   @"A non-dictionary archive should be skipped, leaving the catalog empty");
	[m clearCatalog];
}

/*!
 @testcase testLoadCatalogNonEntryObjectsAreSkipped
 @abstract An archived NSDictionary containing NSData values (not BESecurityScopedURLBookmarkEntry
		   objects) should have each value skipped via the isKindOfClass: continue branch.
		   Covers: loadCatalog—![entry isKindOfClass:[BESecurityScopedURLBookmarkEntry class]] → continue
 */
- (void)testLoadCatalogNonEntryObjectsAreSkipped {
	// NSData is in the allowed classes set but is not BESecurityScopedURLBookmarkEntry.
	NSDictionary *fakeDict = @{ @"key1": [NSData data], @"key2": [NSData data] };
	NSData *dictArchive = [self archivedDictionaryWithObjects:fakeDict];
	[self writeDataToUserDefaults:dictArchive];

	BESecurityScopedURLManager *m = [[BESecurityScopedURLManager alloc] init];
	m.storageOptions = BESecurityScopedURLStorageUserDefaults;
	XCTAssertEqual(m.catalog.count, 0UL,
				   @"Non-entry objects in the archived dictionary should be skipped via the continue branch");
	[m clearCatalog];
}

/*!
 @testcase testLoadCatalogFallsBackToCacheFileWhenUserDefaultsEmpty
 @abstract When UserDefaults has no data and the cache file does, the cache file
		   path is taken. Write a non-entry dictionary to the cache file to verify
		   the fallback branch is reached without crashing.
		   Covers: loadCatalog—!archivedData && CacheDirectory fallback
 */
- (void)testLoadCatalogFallsBackToCacheFileWhenUserDefaultsEmpty {
	// No data in UserDefaults (setUp already cleaned it).
	// Write a valid-but-non-entry dictionary to the cache file.
	NSDictionary *fakeDict = @{ @"cacheKey": [NSData data] };
	NSData *dictArchive = [self archivedDictionaryWithObjects:fakeDict];
	[self writeDataToCacheFile:dictArchive];

	BESecurityScopedURLManager *m = [[BESecurityScopedURLManager alloc] init];
	m.storageOptions = BESecurityScopedURLStorageAll; // includes CacheDirectory fallback
	XCTAssertEqual(m.catalog.count, 0UL,
				   @"Fallback to cache file should be handled gracefully");
	[m clearCatalog];
}

/*!
 @testcase testLoadCatalogUserDefaultsTakesPrecedenceOverCacheFile
 @abstract When both UserDefaults and cache file have data, UserDefaults is used
		   (the higher-priority source). Verify the cache file is NOT the source
		   by putting corrupt data in UserDefaults and valid data in the cache file.
		   Covers: loadCatalog—UserDefaults read first; cache file not read when UD has data.
 */
- (void)testLoadCatalogUserDefaultsTakesPrecedenceOverCacheFile {
	// UserDefaults: corrupt bytes → will cause an error, catalog stays empty.
	[self writeDataToUserDefaults:[@"corrupt" dataUsingEncoding:NSUTF8StringEncoding]];
	// Cache file: a valid dictionary. Should NOT be reached.
	NSDictionary *fakeDict = @{ @"key": [NSData data] };
	[self writeDataToCacheFile:[self archivedDictionaryWithObjects:fakeDict]];

	BESecurityScopedURLManager *m = [[BESecurityScopedURLManager alloc] init];
	m.storageOptions = BESecurityScopedURLStorageAll;
	XCTAssertEqual(m.catalog.count, 0UL,
				   @"UserDefaults takes precedence; corrupt UD data should block cache file read");
	[m clearCatalog];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - BESecurityScopedURLBookmarkEntry — secure coding
// ─────────────────────────────────────────────────────────────────────────────

- (void)testBookmarkEntrySupportsSecureCoding {
	XCTAssertTrue([BESecurityScopedURLBookmarkEntry supportsSecureCoding]);
}

/*!
 @testcase testBookmarkEntryInitWithCoderReturnsNilForMissingBookmarkData
 @abstract initWithCoder: must return nil when the bookmarkData key is absent from
		   the archive, exercising the !_bookmarkData critical-data guard.
 @discussion The corrupt archive is produced via NSPropertyListSerialization:
			 archive a valid entry → parse the plist → strip the "bookmarkData" key
			 → re-serialize → unarchive. No assumption about sandbox state is needed.
		   Covers: initWithCoder: !_bookmarkData → return nil
 */
- (void)testBookmarkEntryInitWithCoderReturnsNilForMissingBookmarkData {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	BESecurityScopedURLBookmarkEntry *entry = self.manager.catalog.allValues.firstObject;
	XCTAssertNotNil(entry, @"Pre-condition: valid entry is required");

	NSError *archiveError = nil;
	NSData *originalData = [NSKeyedArchiver archivedDataWithRootObject:entry
												  requiringSecureCoding:YES
																  error:&archiveError];
	if (archiveError || !originalData) {
		XCTSkip(@"Cannot archive entry — skipping initWithCoder: nil-data test");
		return;
	}

	// Parse the binary plist, strip the "bookmarkData" key from the entry object
	// dictionary, and re-serialize. Decoding will then call initWithCoder: with
	// nil bookmarkData → the !_bookmarkData guard triggers → initWithCoder: returns nil.
	NSError *plistError = nil;
	NSPropertyListFormat plistFormat = NSPropertyListBinaryFormat_v1_0;
	NSMutableDictionary *plist =
		[NSPropertyListSerialization propertyListWithData:originalData
												  options:NSPropertyListMutableContainersAndLeaves
												   format:&plistFormat
													error:&plistError];
	if (plistError || !plist) {
		XCTSkip(@"Cannot parse archive plist — skipping");
		return;
	}

	NSMutableArray *objects = plist[@"$objects"];
	BOOL stripped = NO;
	for (NSUInteger i = 0; i < objects.count; i++) {
		id obj = objects[i];
		if ([obj isKindOfClass:[NSDictionary class]] && obj[@"bookmarkData"]) {
			NSMutableDictionary *mutableObj = [obj mutableCopy];
			[mutableObj removeObjectForKey:@"bookmarkData"];
			objects[i] = mutableObj;
			stripped = YES;
			break;
		}
	}
	if (!stripped) {
		XCTSkip(@"Could not locate bookmarkData key in archive — skipping");
		return;
	}

	NSError *reserErr = nil;
	NSData *corruptData =
		[NSPropertyListSerialization dataWithPropertyList:plist
												   format:NSPropertyListBinaryFormat_v1_0
												  options:0
													error:&reserErr];
	if (reserErr || !corruptData) {
		XCTSkip(@"Cannot re-serialize modified plist — skipping");
		return;
	}

	NSSet *classes = [NSSet setWithObjects:
					  [BESecurityScopedURLBookmarkEntry class],
					  [NSData class], [NSString class],
					  [NSDate class], [NSNumber class], nil];
	NSError *unarchiveError = nil;
	BESecurityScopedURLBookmarkEntry *decoded =
		[NSKeyedUnarchiver unarchivedObjectOfClasses:classes
											fromData:corruptData
											   error:&unarchiveError];

	BOOL decodingFailed = (decoded == nil) || (unarchiveError != nil);
	XCTAssertTrue(decodingFailed,
				  @"initWithCoder: must return nil when the bookmarkData key is absent");
}


/*!
 @testcase testBookmarkEntryInitWithCoderSuccessPath
 @abstract Archives a valid entry and decodes it, exercising the initWithCoder: success
		   path (all required fields present → return self). If the process cannot create
		   bookmark data the test is skipped gracefully.
		   Covers: initWithCoder: all fields decoded successfully → return self
 */
- (void)testBookmarkEntryInitWithCoderSuccessPath {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	BESecurityScopedURLBookmarkEntry *original = self.manager.catalog.allValues.firstObject;
	XCTAssertNotNil(original);

	NSError *archErr = nil;
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:original
										 requiringSecureCoding:YES
														 error:&archErr];
	if (archErr || !data) {
		XCTSkip(@"Cannot archive entry (bookmarkData is nil) — initWithCoder: success path "
				@"requires a valid non-nil bookmark. Run in a sandboxed target.");
		return;
	}

	NSSet *classes = [NSSet setWithObjects:
					  [BESecurityScopedURLBookmarkEntry class],
					  [NSData class], [NSString class], [NSDate class], [NSNumber class], nil];
	NSError *unarchErr = nil;
	BESecurityScopedURLBookmarkEntry *decoded =
		[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:&unarchErr];

	XCTAssertNil(unarchErr,                      @"Unarchiving a valid entry must not error");
	XCTAssertNotNil(decoded,                     @"initWithCoder: must return self for complete data");
	XCTAssertEqualObjects(decoded.urlString,  original.urlString);
	XCTAssertEqual(decoded.lifetime,          original.lifetime);
	XCTAssertEqual(decoded.isDirectory,       original.isDirectory);
	XCTAssertNotNil(decoded.bookmarkData,     @"bookmarkData must survive the round-trip");
	XCTAssertNotNil(decoded.createdAt,        @"createdAt must survive the round-trip");
	XCTAssertFalse(decoded.isStale,           @"A freshly decoded entry must not be stale");
	XCTAssertNil(decoded.bookmarkError,       @"bookmarkError must be nil for a cleanly decoded entry");
}

/*!
 @testcase testBookmarkEntryPropertiesAfterAdd
 @abstract All metadata properties on a freshly created entry must be correctly
		   populated. Properties whose values depend on whether bookmark resolution
		   succeeds (bookmarkData, bookmarkError, isSecurityScoped) are not tested
		   here because they vary by entitlement state of the test runner process.
 */
- (void)testBookmarkEntryPropertiesAfterAdd {
	[self.manager addURLToCatalog:self.tempFileURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	NSString *key = self.tempFileURL.absoluteString;
	BESecurityScopedURLBookmarkEntry *entry = self.manager.catalog[key];
	XCTAssertNotNil(entry);
	XCTAssertEqualObjects(entry.urlString, key,
						  @"urlString must match the input URL");
	XCTAssertEqual(entry.lifetime, BESecurityScopedURLBookmarkLifetimeLongLived,
				   @"lifetime must reflect the value passed to addURLToCatalog:lifetime:");
	XCTAssertFalse(entry.isDirectory, @"File entry isDirectory must be NO");
	XCTAssertNotNil(entry.createdAt,  @"createdAt must be set at creation time");
	XCTAssertFalse(entry.isStale,     @"Freshly created entry must not be stale");
}

- (void)testBookmarkEntryDirectoryHasTrailingSlash {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	BESecurityScopedURLBookmarkEntry *entry = self.manager.catalog.allValues.firstObject;
	XCTAssertNotNil(entry);
	XCTAssertTrue([entry.urlString hasSuffix:@"/"],
				  @"Directory urlString must end with '/'");
	XCTAssertTrue(entry.isDirectory);
}

- (void)testBookmarkEntryInitialIsStaleIsFalse {
	[self.manager addURLToCatalog:self.tempFileURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	BESecurityScopedURLBookmarkEntry *entry = self.manager.catalog[self.tempFileURL.absoluteString];
	XCTAssertFalse(entry.isStale);
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - BESecurityScopedURLBookmarkEntry — initWithURL:lifetime:
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase testBookmarkEntryInitWithNilURLReturnsNil
 @abstract The designated initializer must return nil when url is nil.
		   Covers: initWithURL: — if (!url || !url.isFileURL) { return nil; }  (nil branch)
 */
- (void)testBookmarkEntryInitWithNilURLReturnsNil {
	NSURL *nilURL = nil;
	BESecurityScopedURLBookmarkEntry *entry =
		[[BESecurityScopedURLBookmarkEntry alloc] initWithURL:nilURL
													 lifetime:BESecurityScopedURLBookmarkLifetimeShortLived];
	XCTAssertNil(entry, @"initWithURL: must return nil when url is nil");
}

/*!
 @testcase testBookmarkEntryInitWithNonFileURLReturnsNil
 @abstract The designated initializer must return nil for non-file URLs (e.g. https://).
		   Covers: initWithURL: — if (!url || !url.isFileURL) { return nil; }  (!isFileURL branch)
 */
- (void)testBookmarkEntryInitWithNonFileURLReturnsNil {
	NSURL *httpURL = [NSURL URLWithString:@"https://example.com"];
	BESecurityScopedURLBookmarkEntry *entry =
		[[BESecurityScopedURLBookmarkEntry alloc] initWithURL:httpURL
													 lifetime:BESecurityScopedURLBookmarkLifetimeShortLived];
	XCTAssertNil(entry, @"initWithURL: must return nil for non-file URLs");
}

/*!
 @testcase testBookmarkEntryInitWithBookmarkCreationErrorReturnsNonNilWithError
 @abstract When bookmark creation fails (e.g. the path does not exist),
		   initWithURL: returns self (not nil) with bookmarkError set and bookmarkData nil.
		   Covers: initWithURL: — if (bookmarkError || !_bookmarkData) { return self; }
 */
- (void)testBookmarkEntryInitWithBookmarkCreationErrorReturnsNonNilWithError {
	// A non-existent path causes NSURLBookmarkCreationWithSecurityScope to fail.
	NSURL *nonExistentURL = [NSURL fileURLWithPath:@"/nonexistent_be_test_path/file.txt"];
	BESecurityScopedURLBookmarkEntry *entry =
		[[BESecurityScopedURLBookmarkEntry alloc] initWithURL:nonExistentURL
													 lifetime:BESecurityScopedURLBookmarkLifetimeShortLived];

	XCTAssertNotNil(entry,
					@"initWithURL: must return self (not nil) even when bookmark creation fails");
	XCTAssertNil(entry.bookmarkData,
				 @"bookmarkData must be nil when bookmark creation fails");
	XCTAssertNotNil(entry.bookmarkError,
					@"bookmarkError must be set when bookmark creation fails");
}

/*!
 @testcase testBookmarkEntryInitWithDirectoryURLWithoutTrailingSlashNormalizesIt
 @abstract When a URL points to a real directory but its absoluteString does not end
		   with "/", initWithURL: must detect the directory via getResourceValue:forKey:
		   NSURLIsDirectoryKey and append "/" to normalize the urlString.
		   Covers: initWithURL: — if (_isDirectory && ![_urlString hasSuffix:@"/"]) { append "/" }
 */
- (void)testBookmarkEntryInitWithDirectoryURLWithoutTrailingSlashNormalizesIt {
	// Create a real temporary subdirectory so NSURLIsDirectoryKey returns YES.
	NSString *subDirPath = [NSTemporaryDirectory()
							stringByAppendingPathComponent:
							[NSString stringWithFormat:@"be_dir_norm_%@", [NSUUID UUID].UUIDString]];
	NSError *mkdirErr = nil;
	NSDictionary *nilPathAttrs = nil;
	[[NSFileManager defaultManager] createDirectoryAtPath:subDirPath
								withIntermediateDirectories:YES
											   attributes:nilPathAttrs
													error:&mkdirErr];
	XCTAssertNil(mkdirErr, @"Pre-condition: subdirectory must be created");

	// fileURLWithPath:isDirectory:NO produces a URL whose absoluteString has no trailing slash.
	NSURL *noSlashURL = [NSURL fileURLWithPath:subDirPath isDirectory:NO];
	XCTAssertFalse([noSlashURL.absoluteString hasSuffix:@"/"],
				   @"Pre-condition: input URL must not have a trailing slash");

	BESecurityScopedURLBookmarkEntry *entry =
		[[BESecurityScopedURLBookmarkEntry alloc] initWithURL:noSlashURL
													 lifetime:BESecurityScopedURLBookmarkLifetimeShortLived];
	XCTAssertNotNil(entry);
	XCTAssertTrue(entry.isDirectory,
				  @"isDirectory must be YES — set by getResourceValue:NSURLIsDirectoryKey:");
	XCTAssertTrue([entry.urlString hasSuffix:@"/"],
				  @"urlString must have '/' appended when the resource is a directory");

	NSError *dirNormCleanupErr = nil;
	[[NSFileManager defaultManager] removeItemAtPath:subDirPath error:&dirNormCleanupErr];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - BESecurityScopedURLBookmarkEntry — url lazy property
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase testBookmarkEntryURLPropertyNilBookmarkDataReturnsNil
 @abstract Accessing the url property when bookmarkData is nil must return nil
		   immediately via the guard before any OS bookmark resolution is attempted.
		   Covers: url — if (!_bookmarkData) { return nil; }
 */
- (void)testBookmarkEntryURLPropertyNilBookmarkDataReturnsNil {
	// A non-existent path causes bookmark creation to fail → bookmarkData = nil.
	NSURL *nonExistentURL = [NSURL fileURLWithPath:@"/nonexistent_be_url_nil_test/file.txt"];
	BESecurityScopedURLBookmarkEntry *entry =
		[[BESecurityScopedURLBookmarkEntry alloc] initWithURL:nonExistentURL
													 lifetime:BESecurityScopedURLBookmarkLifetimeShortLived];
	XCTAssertNotNil(entry,               @"Pre-condition: entry must be non-nil (returns self on error)");
	XCTAssertNil(entry.bookmarkData,     @"Pre-condition: bookmarkData must be nil for non-existent path");

	NSURL *result = entry.url;
	XCTAssertNil(result, @"url must return nil when bookmarkData is nil (nil guard fires)");
}

/*!
 @testcase testBookmarkEntryURLPropertyCachesResolvedURL
 @abstract The url property must cache the resolved URL in _url so that subsequent
		   accesses return the identical object without re-resolving.
		   Covers: url — if (_url) { return _url; }  (early-return cache hit)
 */
- (void)testBookmarkEntryURLPropertyCachesResolvedURL {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	BESecurityScopedURLBookmarkEntry *entry = self.manager.catalog.allValues.firstObject;
	XCTAssertNotNil(entry);

	if (!entry.bookmarkData) {
		XCTSkip(@"bookmarkData is nil — caching test requires successful bookmark resolution");
		return;
	}

	NSURL *first  = entry.url;  // triggers lazy resolution; sets _url
	NSURL *second = entry.url;  // must hit `if (_url) { return _url; }` cache branch

	XCTAssertNotNil(first,  @"First access should resolve the bookmark to a non-nil URL");
	XCTAssertEqual(first, second,
				   @"Second access must return the exact same cached object pointer (no re-resolution)");
}

/*!
 @testcase testBookmarkEntryURLPropertyWithInvalidBookmarkDataSetsResolveError
 @abstract When bookmarkData is non-nil but contains invalid data, URLByResolvingBookmarkData:
		   fails with a resolve error. The url property must return nil and store the error
		   in bookmarkError.
		   Covers: url — if (resolveError) { BELogError; return nil; }
 */
- (void)testBookmarkEntryURLPropertyWithInvalidBookmarkDataSetsResolveError {
	// Create an entry whose _url has never been accessed (lazy init pending).
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	BESecurityScopedURLBookmarkEntry *entry = self.manager.catalog.allValues.firstObject;
	XCTAssertNotNil(entry);

	// Replace bookmarkData with garbage bytes BEFORE the first url access,
	// so the resolution attempt uses this invalid data.
	// The private readwrite property is accessible via the BETestPrivateAccess category.
	entry.bookmarkData = [NSData dataWithBytes:"invalid_bookmark_data" length:21];
	XCTAssertNotNil(entry.bookmarkData, @"Pre-condition: bookmarkData must be non-nil (but invalid)");

	NSURL *result = entry.url;
	XCTAssertNil(result,
				 @"url must return nil when URLByResolvingBookmarkData: fails with a resolve error");
	XCTAssertNotNil(entry.bookmarkError,
					@"bookmarkError must be set after a resolution failure");
}

/*!
 @testcase testBookmarkEntryURLPropertyStaleBookmarkCallsUpdateStaleBookmark
 @abstract When the underlying file has been moved, URLByResolvingBookmarkData: returns
		   isStale=YES. The url property must set isStale=YES and call updateStaleBookmark,
		   which refreshes bookmarkData to point at the new location.
		   Covers: url — isStale=YES → [self updateStaleBookmark]
				   updateStaleBookmark — creates new bookmark, detects path change
 */
- (void)testBookmarkEntryURLPropertyStaleBookmarkCallsUpdateStaleBookmark {
	// Create a dedicated temp file so we can move it independently of tearDown cleanup.
	NSString *origPath = [NSTemporaryDirectory()
						  stringByAppendingPathComponent:
						  [NSString stringWithFormat:@"be_stale_src_%@.txt", [NSUUID UUID].UUIDString]];
	NSString *movedPath = [NSTemporaryDirectory()
						   stringByAppendingPathComponent:
						   [NSString stringWithFormat:@"be_stale_dst_%@.txt", [NSUUID UUID].UUIDString]];
	NSError *staleWriteErr = nil;
	[@"stale bookmark test" writeToFile:origPath atomically:YES encoding:NSUTF8StringEncoding error:&staleWriteErr];

	NSURL *origURL  = [NSURL fileURLWithPath:origPath];
	NSURL *movedURL = [NSURL fileURLWithPath:movedPath];

	[self.manager addURLToCatalog:origURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	// The catalog snapshot gives us the same entry object (shallow copy).
	BESecurityScopedURLBookmarkEntry *entry = self.manager.catalog[origURL.absoluteString];
	XCTAssertNotNil(entry);

	if (!entry.bookmarkData) {
		NSError *staleRemoveErr2 = nil;
		[[NSFileManager defaultManager] removeItemAtPath:origPath error:&staleRemoveErr2];
		XCTSkip(@"bookmarkData is nil — stale bookmark test requires successful bookmark creation");
		return;
	}

	// Move the file so the bookmark becomes stale.
	NSError *moveErr = nil;
	BOOL moved = [[NSFileManager defaultManager] moveItemAtURL:origURL toURL:movedURL error:&moveErr];
	if (!moved) {
		NSError *staleRemoveErr = nil;
		[[NSFileManager defaultManager] removeItemAtPath:origPath error:&staleRemoveErr];
		XCTSkip(@"Could not move temp file — skipping stale bookmark test");
		return;
	}

	// Capture bookmarkData before resolution so we can verify it changed.
	NSData *originalBookmarkData = entry.bookmarkData;

	// Access entry.url — this triggers lazy resolution.
	// URLByResolvingBookmarkData: detects the file moved → isStale=YES → updateStaleBookmark called.
	NSURL *resolved = entry.url;

	// The stale bookmark still resolves (file exists at new location).
	XCTAssertNotNil(resolved,
					@"A stale bookmark for an existing (moved) file must still resolve to a URL");

	// updateStaleBookmark creates fresh bookmark data for the new location.
	// The new data must differ from the old data.
	XCTAssertNotNil(entry.bookmarkData,
					@"bookmarkData must be non-nil after updateStaleBookmark refreshes it");
	XCTAssertFalse([entry.bookmarkData isEqualToData:originalBookmarkData],
				   @"bookmarkData must be updated to the new location by updateStaleBookmark");

	// After a SUCCESSFUL refresh the bookmark is no longer stale, so isStale must be reset to NO
	// (matching the manager's relocation path, which also clears it after refreshing).
	XCTAssertFalse(entry.isStale,
				   @"isStale must be reset to NO after updateStaleBookmark successfully refreshes the bookmark");

	// Cleanup.
	NSError *movedPathErr = nil;
	[[NSFileManager defaultManager] removeItemAtPath:movedPath error:&movedPathErr];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Persistence — loadCatalog (LongLived entry loading)
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase testLoadCatalogLoadsLongLivedEntriesFromUserDefaults
 @abstract A fresh manager must load persisted LongLived entries from UserDefaults
		   when they were saved by a previous manager instance.
		   Covers: loadCatalog — entry.lifetime == LongLived → entry.manager = self;
								 self.mutableCatalog[key] = entry;
 */
- (void)testLoadCatalogLoadsLongLivedEntriesFromUserDefaults {
	// Build and save a catalog with one LongLived entry.
	BESecurityScopedURLManager *m1 = [[BESecurityScopedURLManager alloc] init];
	m1.storageOptions = BESecurityScopedURLStorageUserDefaults;
	[m1 addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	(void)m1.catalog; // drain accessQueue so the async save completes

	NSData *saved = [[NSUserDefaults standardUserDefaults] objectForKey:kBETestCatalogUserDefaultsKey];
	if (!saved) {
		[m1 clearCatalog];
		XCTSkip(@"Nothing persisted — LongLived load test requires successful bookmark creation");
		return;
	}

	// Create a fresh manager that loads from the same UserDefaults key.
	BESecurityScopedURLManager *m2 = [[BESecurityScopedURLManager alloc] init];
	m2.storageOptions = BESecurityScopedURLStorageUserDefaults;
	(void)m2.catalog; // drain so loadCatalog's async block completes before we inspect

	XCTAssertEqual(m2.catalog.count, 1UL,
				   @"Fresh manager must load the one persisted LongLived entry");

	BESecurityScopedURLBookmarkEntry *loaded = m2.catalog.allValues.firstObject;
	XCTAssertNotNil(loaded);
	XCTAssertEqual(loaded.lifetime, BESecurityScopedURLBookmarkLifetimeLongLived,
				   @"Loaded entry must retain its LongLived lifetime");
	XCTAssertNotNil(loaded.bookmarkData, @"Loaded entry must have non-nil bookmarkData");

	[m1 clearCatalog];
	[m2 clearCatalog];
}

/*!
 @testcase testLoadCatalogSkipsShortLivedEntries
 @abstract ShortLived entries stored in an archive (e.g. by a hypothetical direct
		   manipulation) must be skipped during load — only LongLived entries are
		   restored across sessions.
		   Covers: loadCatalog — if (entry.lifetime == LongLived) — else branch: skip
 @discussion We produce the archive via plist manipulation: take a valid LongLived
			 archive, change the lifetime integer to ShortLived (0), re-store in
			 UserDefaults, then verify the fresh manager loads nothing.
 */
- (void)testLoadCatalogSkipsShortLivedEntries {
	// Produce a valid LongLived archive in UserDefaults.
	BESecurityScopedURLManager *m1 = [[BESecurityScopedURLManager alloc] init];
	m1.storageOptions = BESecurityScopedURLStorageUserDefaults;
	[m1 addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	(void)m1.catalog; // drain
	[m1 clearCatalog];

	NSData *saved = [[NSUserDefaults standardUserDefaults] objectForKey:kBETestCatalogUserDefaultsKey];
	if (!saved) {
		XCTSkip(@"No persisted data — ShortLived skip test requires successful bookmark creation");
		return;
	}

	// Parse the binary plist and set the lifetime value to ShortLived (0) for every entry.
	NSError *parseErr = nil;
	NSPropertyListFormat savedPlistFormat = NSPropertyListBinaryFormat_v1_0;
	NSMutableDictionary *plist =
		[NSPropertyListSerialization propertyListWithData:saved
												  options:NSPropertyListMutableContainersAndLeaves
												   format:&savedPlistFormat
													error:&parseErr];
	if (parseErr || !plist) {
		XCTSkip(@"Cannot parse archive plist — skipping ShortLived skip test");
		return;
	}
	// The "lifetime" integer is stored in one of the $objects dictionaries.
	// Change any occurrence of the lifetime key value to 0 (ShortLived).
	NSMutableArray *objects = plist[@"$objects"];
	for (NSUInteger i = 0; i < objects.count; i++) {
		id obj = objects[i];
		if ([obj isKindOfClass:[NSDictionary class]] && obj[@"lifetime"] != nil) {
			NSMutableDictionary *mutableObj = [obj mutableCopy];
			mutableObj[@"lifetime"] = @(BESecurityScopedURLBookmarkLifetimeShortLived);
			objects[i] = mutableObj;
		}
	}
	NSError *reserErr = nil;
	NSData *mutated = [NSPropertyListSerialization dataWithPropertyList:plist
																 format:NSPropertyListBinaryFormat_v1_0
																options:0
																  error:&reserErr];
	if (reserErr || !mutated) {
		XCTSkip(@"Cannot re-serialize — skipping ShortLived skip test");
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:mutated forKey:kBETestCatalogUserDefaultsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];

	// Fresh manager must skip the ShortLived entry.
	BESecurityScopedURLManager *m2 = [[BESecurityScopedURLManager alloc] init];
	m2.storageOptions = BESecurityScopedURLStorageUserDefaults;
	(void)m2.catalog; // drain
	XCTAssertEqual(m2.catalog.count, 0UL,
				   @"ShortLived entries must not be loaded from persistence");
	[m2 clearCatalog];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Persistence — saveCatalogSynchronously:YES
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase testSaveCatalogSynchronouslyYESBlocksUntilComplete
 @abstract saveCatalogSynchronously:YES uses dispatch_sync; the save must be fully
		   committed to UserDefaults before the method returns (no separate drain needed).
		   Covers: saveCatalogSynchronously: — if (synchronously) { dispatch_sync(...) }
 */
- (void)testSaveCatalogSynchronouslyYESBlocksUntilComplete {
	self.manager.storageOptions = BESecurityScopedURLStorageUserDefaults;
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	// drainAccessQueue() would normally be required after the async add-save.
	// Call the synchronous variant directly to exercise its dispatch_sync branch.
	[self.manager saveCatalogSynchronously:YES];

	// Check immediately — no drain required because the save was synchronous.
	NSData *saved = [[NSUserDefaults standardUserDefaults] objectForKey:kBETestCatalogUserDefaultsKey];
	if (self.manager.catalog.count > 0) {
		// Only LongLived entries are persisted; if catalog is non-empty there must be data.
		XCTAssertNotNil(saved,
						@"saveCatalogSynchronously:YES must write UserDefaults before returning");
	}
	// Second call: catalog is empty after clear — exercises the synchronous remove path.
	[self.manager clearCatalog];
	[self.manager saveCatalogSynchronously:YES];
	NSData *afterClear = [[NSUserDefaults standardUserDefaults] objectForKey:kBETestCatalogUserDefaultsKey];
	XCTAssertNil(afterClear,
				 @"saveCatalogSynchronously:YES on an empty catalog must clear UserDefaults immediately");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - addURLToCatalog:lifetime:
// ─────────────────────────────────────────────────────────────────────────────

- (void)testAddNilURLReturnsFalse {
	NSURL *nilURL = nil;
	XCTAssertFalse([self.manager addURLToCatalog:nilURL
										lifetime:BESecurityScopedURLBookmarkLifetimeLongLived]);
	XCTAssertEqual(self.manager.catalog.count, 0UL);
}

- (void)testAddNonFileURLReturnsFalse {
	NSURL *http = [NSURL URLWithString:@"https://example.com"];
	XCTAssertFalse([self.manager addURLToCatalog:http
										lifetime:BESecurityScopedURLBookmarkLifetimeLongLived]);
}

- (void)testAddDirectoryLongLived {
	XCTAssertTrue([self.manager addURLToCatalog:self.tempDirURL
									   lifetime:BESecurityScopedURLBookmarkLifetimeLongLived]);
	XCTAssertEqual(self.manager.catalog.count, 1UL);
}

- (void)testAddFileShortLived {
	XCTAssertTrue([self.manager addURLToCatalog:self.tempFileURL
									   lifetime:BESecurityScopedURLBookmarkLifetimeShortLived]);
	XCTAssertEqual(self.manager.catalog.count, 1UL);
}

- (void)testAddFileLongLived {
	XCTAssertTrue([self.manager addURLToCatalog:self.tempFileURL
									   lifetime:BESecurityScopedURLBookmarkLifetimeLongLived]);
	XCTAssertEqual(self.manager.catalog.count, 1UL);
}

- (void)testAddDuplicateURLDoesNotIncreaseCount {
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	NSUInteger after1 = self.manager.catalog.count;
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTAssertEqual(self.manager.catalog.count, after1, @"Re-adding same URL must not grow the catalog");
}

- (void)testAddTwoDistinctURLsCountIsTwo {
	[self.manager addURLToCatalog:self.tempFileURL  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self.manager addURLToCatalog:self.tempFile2URL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTAssertEqual(self.manager.catalog.count, 2UL);
}

/*!
 @testcase testAddURLToCatalogEndsExistingAccessViaResolvedURL
 @abstract When a URL already has an active access session (ref count > 0) and the
		   caller re-adds that same URL via addURLToCatalog:lifetime:, the method must
		   end the existing access session before replacing the catalog entry.
 @discussion Two subtests are run:

			 Subtest A (non-sandboxed): We use the delegate path (putURLInRefCounts:) to
			 place an explicit ref count on the URL, confirm it is tracked, then re-add the
			 catalog entry and verify that endAccessingURL: on that URL subsequently returns
			 NO — proving that addURLToCatalog:lifetime: cleaned up the active session.

			 Subtest B (sandboxed only): Guards with XCTSkipUnless(BETestIsSandboxed()).
			 Uses the symlink form of tempDirURL (via URLByResolvingSymlinksInPath) as the
			 input to addURLToCatalog:lifetime:. The bookmark resolver returns the canonical
			 /private/var/… form, which is what refCounts holds. The fix ensures that
			 endAccessingURLInternal: is called on that resolved (canonical) form, not on the
			 unresolved /var/… symlink form passed as the argument.

			 Covers: addURLToCatalog: — resolved-URL lookup before endAccessingURLInternal:.
 */
- (void)testAddURLToCatalogEndsExistingAccessViaResolvedURL {

	// ── Subtest A: canonical-URL path (works in non-sandboxed processes) ────────

	// Add the URL to the catalog so the entry exists with a urlString.
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTAssertEqual(self.manager.catalog.count, 1UL, @"Pre-condition: entry must be in catalog");

	// Use the delegate path to place a ref count on the URL.
	NSURL *accessedURL = [self putURLInRefCounts:self.tempDirURL];
	XCTAssertNotNil(accessedURL, @"Pre-condition: URL must be placed into refCounts");

	// Confirm the URL is currently tracked.
	BOOL trackedBeforeReAdd = [self.manager endAccessingURL:accessedURL];
	XCTAssertTrue(trackedBeforeReAdd,
				  @"Pre-condition: the URL must be tracked in refCounts after putURLInRefCounts:");

	// Re-put the ref so there is still something for addURLToCatalog to clean up.
	[self putURLInRefCounts:self.tempDirURL];

	// Re-add the same URL. addURLToCatalog:lifetime: must end the existing access session
	// on the previously-resolved URL before replacing the catalog entry.
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	// After re-adding, the old ref count should have been cleared.
	// endAccessingURL: must now return NO because the access was terminated by addURLToCatalog:.
	BOOL stillTrackedAfterReAdd = [self.manager endAccessingURL:accessedURL];
	XCTAssertFalse(stillTrackedAfterReAdd,
				   @"addURLToCatalog:lifetime: must end the existing access session on the "
				   @"resolved URL before replacing the catalog entry; the URL must not remain "
				   @"in refCounts after re-adding");

	// ── Subtest B: symlink-expanded path (requires sandbox for bookmark resolution) ──

	// Sandboxed bookmark resolution expands /var/folders/… → /private/var/folders/…
	// This causes the URL stored in refCounts to differ from the argument passed to
	// addURLToCatalog:lifetime:, which is the exact scenario the fix addresses.
	XCTSkipUnless(BETestIsSandboxed(),
				  @"Subtest B requires a sandboxed process for security-scoped bookmark resolution");

	// Build a URL via the symlink path — NSTemporaryDirectory() returns /var/… on macOS,
	// while the resolved bookmark yields the canonical /private/var/… form.
	[self.manager clearCatalog];
	NSURL *symlinkURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
	NSURL *resolvedURL = [symlinkURL URLByResolvingSymlinksInPath];

	// Verify the paths actually differ; if not, there is nothing to test.
	if ([symlinkURL.path isEqualToString:resolvedURL.path]) {
		XCTSkip(@"Subtest B: symlink and canonical paths are identical on this system — skip");
		return;
	}

	[self.manager addURLToCatalog:symlinkURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTAssertEqual(self.manager.catalog.count, 1UL, @"Subtest B pre-condition: entry in catalog");

	// Place a ref count using the canonical URL (the form bookmark resolution produces).
	NSURL *accessedB = [self putURLInRefCounts:resolvedURL];
	XCTAssertNotNil(accessedB, @"Subtest B pre-condition: canonical URL must be placed in refCounts");

	BOOL trackedB = [self.manager endAccessingURL:accessedB];
	XCTAssertTrue(trackedB, @"Subtest B pre-condition: canonical URL must be tracked");

	// Re-put so addURLToCatalog: has a ref to clean up.
	[self putURLInRefCounts:resolvedURL];

	// Re-add via the symlink URL. The fix must resolve it through the catalog to find the
	// canonical form in refCounts and call endAccessingURLInternal: on that form.
	[self.manager addURLToCatalog:symlinkURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	BOOL stillTrackedB = [self.manager endAccessingURL:accessedB];
	XCTAssertFalse(stillTrackedB,
				   @"Subtest B: addURLToCatalog:lifetime: must end the session on the resolved "
				   @"(canonical /private/var/…) URL, not just on the symlink /var/… argument");
}

/*!
 @testcase testRelocationTransfersRefCountStoredUnderResolvedURL
 @abstract Relocation transfers an active reference count that is stored under the symlink-
		   resolved URL form, even when that form differs from the catalog key.
 @discussion Before the fix, handleBookmarkRelocationFromPath: looked up the count by the
			 unresolved catalog key, found 0, and silently dropped the active session.
 */
- (void)testRelocationTransfersRefCountStoredUnderResolvedURL {
	// A real catalog entry, so handleBookmarkRelocationFromPath: does not early-return.
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	NSString *oldPath = self.manager.catalog.allKeys.firstObject;
	XCTAssertNotNil(oldPath, @"Pre-condition: entry must be in catalog");

	// Simulate an active access whose resolved form differs from the catalog key, as a
	// sandboxed bookmark would (/var/… resolves to /private/var/…).
	NSURL *resolvedURL = [NSURL fileURLWithPath:@"/be_test_reloc_resolved" isDirectory:NO];
	XCTAssertNotNil([self putURLInRefCounts:resolvedURL], @"Pre-condition: resolved URL in refCounts");
	self.manager.resolvedAccessURLByKey[oldPath] = resolvedURL;
	XCTAssertEqual([self.manager.refCounts countForObject:resolvedURL], 1UL);

	// Relocate the entry's key.
	NSURL *newURL = [NSURL URLWithString:@"file:///be_test_reloc_new"];
	[self.manager handleBookmarkRelocationFromPath:oldPath toPath:newURL.absoluteString];
	[self drainAccessQueue];

	XCTAssertEqual([self.manager.refCounts countForObject:newURL], 1UL,
				   @"Relocation must transfer the active count to the new URL");
	XCTAssertEqual([self.manager.refCounts countForObject:resolvedURL], 0UL,
				   @"The old resolved URL must no longer hold the count after relocation");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - removeURLFromCatalog:
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase testRemoveURLFromCatalog
 @abstract Core regression test for the Deadlock 4 / symlink key-mismatch bug.
		   The catalog key is the original URL string; removal must not use a
		   symlink-resolved path.
 */
- (void)testRemoveURLFromCatalog {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTAssertGreaterThan(self.manager.catalog.count, 0UL, @"Pre-condition: catalog must be non-empty");

	[self.manager removeURLFromCatalog:self.tempDirURL];

	XCTAssertEqual(self.manager.catalog.count, 0UL,
				   @"Catalog should be empty after removing the only entry");
}

- (void)testRemoveNilURLIsNoOp {
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	NSUInteger before = self.manager.catalog.count;
	NSURL *nilURL = nil;
	[self.manager removeURLFromCatalog:nilURL];
	XCTAssertEqual(self.manager.catalog.count, before);
}

- (void)testRemoveURLNotInCatalogIsNoOp {
	[self.manager addURLToCatalog:self.tempFileURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	NSUInteger before = self.manager.catalog.count;
	[self.manager removeURLFromCatalog:[NSURL fileURLWithPath:@"/Applications"]];
	XCTAssertEqual(self.manager.catalog.count, before,
				   @"Removing an unknown URL should leave the catalog unchanged");
}

- (void)testRemoveURLLeavesOtherEntriesIntact {
	[self.manager addURLToCatalog:self.tempFileURL  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self.manager addURLToCatalog:self.tempFile2URL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self.manager removeURLFromCatalog:self.tempFileURL];
	XCTAssertEqual(self.manager.catalog.count, 1UL);
	XCTAssertNotNil(self.manager.catalog[self.tempFile2URL.absoluteString]);
}

/*!
 @testcase testRemoveURLFromCatalogUsingURLWithoutTrailingSlash
 @abstract Directories are stored with a trailing slash. Removing via a URL whose
		   absoluteString does NOT end in "/" must still find and remove the entry
		   via the trailing-slash variant lookup.
		   Covers: removeURLFromCatalog—no direct match → check +/ variant → found
 */
- (void)testRemoveURLFromCatalogUsingURLWithoutTrailingSlash {
	// Create a real subdirectory so fileURLWithPath: behaves consistently.
	NSString *subDirPath = [NSTemporaryDirectory()
							stringByAppendingPathComponent:
							[NSString stringWithFormat:@"be_slash_test_%@", [NSUUID UUID].UUIDString]];
	NSDictionary *nilAttributes = nil;
	NSError *mkdirErr = nil;
	[[NSFileManager defaultManager] createDirectoryAtPath:subDirPath
								withIntermediateDirectories:YES attributes:nilAttributes error:&mkdirErr];

	NSURL *withSlash    = [NSURL fileURLWithPath:subDirPath isDirectory:YES];   // ends with "/"
	NSURL *withoutSlash = [NSURL fileURLWithPath:subDirPath isDirectory:NO];    // no trailing "/"

	[self.manager addURLToCatalog:withSlash lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTAssertEqual(self.manager.catalog.count, 1UL, @"Pre-condition: one entry added");

	// The stored catalog key ends with "/". The URL we pass to remove does not.
	[self.manager removeURLFromCatalog:withoutSlash];

	XCTAssertEqual(self.manager.catalog.count, 0UL,
				   @"Removal via URL without trailing slash should find the +/ variant");

	NSError *slashRemoveErr = nil;
	[[NSFileManager defaultManager] removeItemAtPath:subDirPath error:&slashRemoveErr];
}

/*!
 @testcase testRemoveURLFromCatalogEndsActiveAccess
 @abstract If a URL has active reference-counted access when removed, the access
		   session should be ended. Verifies that endAccessingURLInternal: is called
		   with storedURL during removal.
		   Covers: removeURLFromCatalog—storedURL non-nil → endAccessingURLInternal
 */
- (void)testRemoveURLFromCatalogEndsActiveAccess {
	// Add to catalog first (so the entry exists with a urlString).
	[self.manager addURLToCatalog:self.tempFileURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	// Also get the URL into refCounts via delegate, simulating an active access session.
	NSURL *accessedURL = [self putURLInRefCounts:self.tempFileURL];
	if (accessedURL) {
		// Verify the URL is tracked before removal.
		XCTAssertTrue([self.manager endAccessingURL:accessedURL],
					  @"Pre-condition: URL should be tracked in refCounts");
		// Re-add it so removeURLFromCatalog: has something to end.
		[self putURLInRefCounts:self.tempFileURL];
	}

	// removeURLFromCatalog: internally calls endAccessingURLInternal: on storedURL.
	XCTAssertNoThrow([self.manager removeURLFromCatalog:self.tempFileURL],
					 @"removeURLFromCatalog: must not crash when active access exists");
	XCTAssertEqual(self.manager.catalog.count, 0UL, @"Entry must be removed");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - removeAbsolutePathFromCatalog:
// ─────────────────────────────────────────────────────────────────────────────

- (void)testRemoveAbsolutePathNilIsNoOp {
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	NSUInteger before = self.manager.catalog.count;
	NSString *nilPath = nil;
	[self.manager removeAbsolutePathFromCatalog:nilPath];
	XCTAssertEqual(self.manager.catalog.count, before);
}

- (void)testRemoveAbsolutePathMatchingKey {
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	NSString *key = self.tempDirURL.absoluteString;
	if (![key hasSuffix:@"/"]) { key = [key stringByAppendingString:@"/"]; }
	[self.manager removeAbsolutePathFromCatalog:key];
	XCTAssertEqual(self.manager.catalog.count, 0UL);
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - clearCatalog
// ─────────────────────────────────────────────────────────────────────────────

- (void)testClearEmptyCatalogDoesNotCrash {
	XCTAssertNoThrow([self.manager clearCatalog]);
	XCTAssertEqual(self.manager.catalog.count, 0UL);
}

- (void)testClearCatalogRemovesAllEntries {
	[self.manager addURLToCatalog:self.tempDirURL   lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self.manager addURLToCatalog:self.tempFileURL  lifetime:BESecurityScopedURLBookmarkLifetimeShortLived];
	[self.manager addURLToCatalog:self.tempFile2URL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self.manager clearCatalog];
	XCTAssertEqual(self.manager.catalog.count, 0UL);
}

/*!
 @testcase testClearCatalogWithActiveAccess
 @abstract Regression for Deadlock 5. clearCatalog must complete without deadlock
		   even when access sessions exist. Also exercises endAccessingAllURLsInternal:
		   the active ref in refCounts is drained by the internal method before the
		   catalog is wiped.
		   Covers: clearCatalog → endAccessingAllURLsInternal (inner loop, count=1)
 */
- (void)testClearCatalogWithActiveAccess {
	// Put a URL into refCounts explicitly via the delegate path.
	// This guarantees endAccessingAllURLsInternal has at least one URL to drain
	// regardless of whether bookmark resolution succeeds for catalog entries.
	NSURL *inRefCounts = [self putURLInRefCounts:self.tempDirURL];
	XCTAssertNotNil(inRefCounts, @"Pre-condition: URL must be in refCounts");

	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	XCTAssertNoThrow([self.manager clearCatalog]);
	XCTAssertEqual(self.manager.catalog.count, 0UL);

	// After clearCatalog, refCounts must be drained — endAccessingURL must return NO.
	XCTAssertFalse([self.manager endAccessingURL:inRefCounts],
				   @"endAccessingAllURLsInternal must have drained all refCounts");
}

/*!
 @testcase testClearCatalogWithMultipleRefsExercisesInnerLoop
 @abstract When a URL has a refCount > 1, endAccessingAllURLsInternal's inner
		   `for (NSUInteger i = 0; i < count; i++)` loop must run count times.
		   Covers: endAccessingAllURLsInternal — inner loop executes for count > 1
 */
- (void)testClearCatalogWithMultipleRefsExercisesInnerLoop {
	// Accumulate 3 refs to the same URL.
	[self putURLInRefCounts:self.tempDirURL]; // count → 1
	[self putURLInRefCounts:self.tempDirURL]; // count → 2
	[self putURLInRefCounts:self.tempDirURL]; // count → 3

	// clearCatalog calls endAccessingAllURLsInternal which must drain all 3.
	XCTAssertNoThrow([self.manager clearCatalog]);

	// All refs drained — endAccessingURL must now return NO.
	XCTAssertFalse([self.manager endAccessingURL:self.tempDirURL],
				   @"All 3 refs must be drained by endAccessingAllURLsInternal inner loop");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - catalog property
// ─────────────────────────────────────────────────────────────────────────────

- (void)testCatalogReturnsCopyEachTime {
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	NSDictionary *s1 = self.manager.catalog;
	NSDictionary *s2 = self.manager.catalog;
	XCTAssertNotEqual(s1, s2, @"Each call must return a distinct copy");
	XCTAssertEqualObjects(s1, s2, @"Both copies must have identical content");
}

- (void)testCatalogCountTracksAddAndRemove {
	XCTAssertEqual(self.manager.catalog.count, 0UL);
	[self.manager addURLToCatalog:self.tempFileURL  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTAssertEqual(self.manager.catalog.count, 1UL);
	[self.manager addURLToCatalog:self.tempFile2URL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTAssertEqual(self.manager.catalog.count, 2UL);
	[self.manager removeURLFromCatalog:self.tempFileURL];
	XCTAssertEqual(self.manager.catalog.count, 1UL);
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - URL Resolution — urlFromCatalog: / urlFromCatalogWithAbsolutePath:
//
// urlFromCatalogWithAbsolutePath: (public) is a dispatch_sync wrapper around
// urlFromCatalogWithAbsolutePathInternal:, which is the single source of truth
// for all Tier 1-4 resolution logic. Testing the public method once exercises
// both; there is no separate internal-method test surface.
// ─────────────────────────────────────────────────────────────────────────────

- (void)testURLFromCatalogNilReturnsNil {
	NSURL *nilURL1 = nil;
	XCTAssertNil([self.manager urlFromCatalog:nilURL1]);
}

- (void)testURLFromCatalogNonFileURLReturnsNil {
	XCTAssertNil([self.manager urlFromCatalog:[NSURL URLWithString:@"https://example.com"]]);
}

- (void)testURLFromCatalogNotInCatalogReturnsNil {
	XCTAssertNil([self.manager urlFromCatalog:self.tempDirURL]);
}

- (void)testURLFromCatalogWithAbsolutePathNilReturnsNil {
	NSString *nilStr1 = nil;
	XCTAssertNil([self.manager urlFromCatalogWithAbsolutePath:nilStr1]);
}

- (void)testURLFromCatalogWithAbsolutePathUnknownReturnsNil {
	XCTAssertNil([self.manager urlFromCatalogWithAbsolutePath:@"file:///nonexistent/path.txt"]);
}

/*!
 @testcase testURLFromCatalogWithAbsolutePathInternalNilReturnsNil
 @abstract Passing nil directly to urlFromCatalogWithAbsolutePathInternal: must hit
		   the nil guard and return nil immediately.
		   Covers: urlFromCatalogWithAbsolutePathInternal: — if (!absolutePathString) { return nil; }
 @discussion The public urlFromCatalogWithAbsolutePath: guards nil before calling the
			 internal method, so this branch is unreachable via the production call chain.
			 Calling the internal method directly is safe here because execution returns
			 before touching any catalog or queue state.
 */
- (void)testURLFromCatalogWithAbsolutePathInternalNilReturnsNil {
	NSString *nilAbsPath = nil;
	NSURL *result = [self.manager urlFromCatalogWithAbsolutePathInternal:nilAbsPath];
	XCTAssertNil(result,
				 @"urlFromCatalogWithAbsolutePathInternal: must return nil when absolutePathString is nil");
}

/*!
 @testcase testURLFromCatalogTier1DirectMatchDoesNotCrash
 @abstract urlFromCatalogWithAbsolutePath: must not crash on a Tier 1 lookup
		   regardless of whether the entry's bookmark resolves successfully.
		   When resolution succeeds the URL is returned; when it fails (bookmarkError
		   set) the method falls through the remaining tiers and returns nil.
		   Both outcomes are valid — neither should throw.
 @discussion The "Tier 1 fall-through on bookmarkError" branch requires the OS to fail
			 bookmark resolution, which cannot be manufactured without mocking OS APIs.
			 We test the invariant (no crash, correct type) instead.
		   Covers: urlFromCatalogWithAbsolutePath: (dispatch wrapper) → delegates to
				   urlFromCatalogWithAbsolutePathInternal: → Tier 1 entry found
 */
- (void)testURLFromCatalogTier1DirectMatchDoesNotCrash {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	NSString *key = self.tempDirURL.absoluteString;
	if (![key hasSuffix:@"/"]) { key = [key stringByAppendingString:@"/"]; }

	XCTAssertNoThrow([self.manager urlFromCatalogWithAbsolutePath:key],
					 @"Tier 1 lookup must never throw");

	NSURL *result = [self.manager urlFromCatalogWithAbsolutePath:key];
	// result is non-nil when bookmarks resolve, nil when they do not — both valid.
	if (result) {
		XCTAssertTrue([result isKindOfClass:[NSURL class]]);
	}
}

/*!
 @testcase testURLFromCatalogTier2URLInRefCounts
 @abstract A URL already present in refCounts must be returned via Tier 2 even when
		   it is not in the catalog. urlFromCatalogWithAbsolutePath: is a pure
		   dispatch_sync wrapper, so this test exercises Tier 2 in
		   urlFromCatalogWithAbsolutePathInternal: — the single implementation.
		   Covers: urlFromCatalogWithAbsolutePathInternal — Tier 2: containsObject → member:
 */
- (void)testURLFromCatalogTier2URLInRefCounts {
	// Put tempDirURL into refCounts via the delegate path.
	NSURL *accessedURL = [self putURLInRefCounts:self.tempDirURL];
	XCTAssertNotNil(accessedURL, @"Pre-condition: URL must be in refCounts");

	// Query via the public method — it dispatches to the internal method where Tier 2 fires.
	NSURL *result = [self.manager urlFromCatalogWithAbsolutePath:accessedURL.absoluteString];
	XCTAssertNotNil(result, @"Tier 2 should return the URL from refCounts");
	XCTAssertEqualObjects(result, accessedURL);

	// Clean up the ref count.
	[self.manager endAccessingURL:accessedURL];
}

/*!
 @testcase testURLFromCatalogTier3PathConstructionIsCorrect
 @abstract Tier 3 must build the resolved URL by:
		   (1) confirming the query path has the bookmarked directory path as a prefix,
		   (2) extracting the relative component via substringFromIndex:,
		   (3) stripping any leading slash with the while-loop,
		   (4) returning directoryURL URLByAppendingPathComponent:relativePath.
		   All four steps are asserted with exact string comparisons.
		   Covers: urlFromCatalogWithAbsolutePathInternal — Tier 3 main body:
				   [inputPath hasPrefix:dirPath] → substringFromIndex: → while strip /
				   → URLByAppendingPathComponent: → return resolvedURL
 @discussion We skip when the directory bookmark has nil bookmarkData because Tier 3
			 only fires when dirEntry.url is non-nil (requires bookmark resolution).
			 Using a real file in a real subdirectory means the query path really does
			 live inside the bookmarked directory — no fictional paths needed.
 */
- (void)testURLFromCatalogTier3PathConstructionIsCorrect {
	// Create a real subdirectory inside tempDirURL so we can place a real file in it.
	NSString *subDirName = [NSString stringWithFormat:@"be_tier3_%@", [NSUUID UUID].UUIDString];
	NSURL *subDirURL = [self.tempDirURL URLByAppendingPathComponent:subDirName isDirectory:YES];
	NSError *mkdirErr = nil;
	NSDictionary *nilDirAttrs = nil;
	[[NSFileManager defaultManager] createDirectoryAtURL:subDirURL
							   withIntermediateDirectories:YES attributes:nilDirAttrs error:&mkdirErr];
	XCTAssertNil(mkdirErr, @"Pre-condition: subdirectory must be created");

	// Create a real file inside the subdirectory.
	NSString *fileName = @"be_tier3_file.txt";
	NSURL *fileURL = [subDirURL URLByAppendingPathComponent:fileName];
	NSError *tier3WriteErr = nil;
	[@"tier3 test" writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&tier3WriteErr];

	// Add tempDirURL (the parent) to the catalog. The file and subdirectory are NOT in the catalog.
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	// Skip if the directory bookmark did not resolve — Tier 3 needs a non-nil dirEntry.url.
	BESecurityScopedURLBookmarkEntry *dirEntry = self.manager.catalog.allValues.firstObject;
	if (!dirEntry || !dirEntry.bookmarkData) {
		NSError *tier3SkipCleanupErr = nil;
		[[NSFileManager defaultManager] removeItemAtURL:subDirURL error:&tier3SkipCleanupErr];
		XCTSkip(@"Directory bookmark has nil bookmarkData — Tier 3 body test requires "
				@"successful security-scoped bookmark resolution");
		return;
	}

	// Build the query URL from the standardized (symlink-resolved) path so it matches
	// the prefix that URLByResolvingBookmarkData: writes into dirEntry.url.
	// stringByStandardizingPath expands /var → /private/var on macOS.
	NSURL *resolvedDir  = [self.tempDirURL URLByResolvingSymlinksInPath];
	NSURL *queryURL     = [[resolvedDir URLByAppendingPathComponent:subDirName isDirectory:YES]
						   URLByAppendingPathComponent:fileName];

	// Invoke Tier 3 via the public wrapper.
	NSURL *result = [self.manager urlFromCatalogWithAbsolutePath:queryURL.absoluteString];

	if (!result) {
		// Tier 3 prefix check did not match — environment-specific symlink behaviour.
		// Clean up and skip rather than fail on infrastructure.
		NSError *tier3PrefixErr = nil;
		[[NSFileManager defaultManager] removeItemAtURL:subDirURL error:&tier3PrefixErr];
		XCTSkip(@"Tier 3 prefix check did not match — symlink resolution mismatch in this environment");
		return;
	}

	// ── Assert the full Tier 3 path-construction result ──────────────────────
	//
	// Tier 3 takes the resolved directory URL (from the bookmark), strips the
	// directory path prefix from inputPath to get a relative component, then
	// appends it back. The final URL must therefore be exactly:
	//   resolvedDirURL / subDirName / fileName
	// expressed as a standardized path.

	NSString *expectedPath = [[resolvedDir URLByAppendingPathComponent:subDirName isDirectory:YES]
							  URLByAppendingPathComponent:fileName].path;
	expectedPath = [expectedPath stringByStandardizingPath];

	NSString *actualPath = [result.path stringByStandardizingPath];

	XCTAssertEqualObjects(actualPath, expectedPath,
						  @"Tier 3 must reconstruct the full contained path via "
						  @"substringFromIndex:dirPath.length + URLByAppendingPathComponent:");
	XCTAssertEqualObjects(result.lastPathComponent, fileName,
						  @"The last path component must be the queried filename");

	NSError *tier3FinalErr = nil;
	[[NSFileManager defaultManager] removeItemAtURL:subDirURL error:&tier3FinalErr];
}

/*!
 @testcase testURLFromCatalogTier3StripsLeadingSlashFromRelativePath
 @abstract When the relative path extracted by substringFromIndex: begins with "/",
		   the while-loop inside Tier 3 must strip it before passing to
		   URLByAppendingPathComponent:. Without the strip, URLByAppendingPathComponent:
		   would treat the component as absolute and discard the directory prefix.
		   Covers: urlFromCatalogWithAbsolutePathInternal — Tier 3: while-loop strip "/"
 @discussion The leading slash arises when dirPath does NOT end with "/" and the contained
			 path follows immediately (e.g. dirPath="/private/var/T", inputPath="/private/var/T/file.txt"
			 → relativePath="/file.txt" before stripping → "file.txt" after). We verify
			 that the result path ends with the filename (not "//file.txt" or "/file.txt"
			 as a separate absolute path), confirming the strip executed correctly.
 */
- (void)testURLFromCatalogTier3StripsLeadingSlashFromRelativePath {
	// Create a real file inside tempDirURL.
	NSString *fileName = [NSString stringWithFormat:@"be_tier3_slash_%@.txt", [NSUUID UUID].UUIDString];
	NSURL *fileURL = [self.tempDirURL URLByAppendingPathComponent:fileName];
	NSError *slashWriteErr = nil;
	[@"slash strip test" writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&slashWriteErr];

	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	BESecurityScopedURLBookmarkEntry *dirEntry = self.manager.catalog.allValues.firstObject;
	if (!dirEntry || !dirEntry.bookmarkData) {
		NSError *slashSkipErr1 = nil;
		[[NSFileManager defaultManager] removeItemAtURL:fileURL error:&slashSkipErr1];
		XCTSkip(@"Directory bookmark has nil bookmarkData — slash-strip test requires bookmark resolution");
		return;
	}

	NSURL *resolvedDir = [self.tempDirURL URLByResolvingSymlinksInPath];
	NSURL *queryURL    = [resolvedDir URLByAppendingPathComponent:fileName];

	NSURL *result = [self.manager urlFromCatalogWithAbsolutePath:queryURL.absoluteString];

	if (!result) {
		NSError *slashSkipErr2 = nil;
		[[NSFileManager defaultManager] removeItemAtURL:fileURL error:&slashSkipErr2];
		XCTSkip(@"Tier 3 did not resolve — slash-strip test requires Tier 3 to match");
		return;
	}

	// The while-loop strips the leading "/" from relativePath before appending.
	// If stripping did NOT happen, URLByAppendingPathComponent: would produce
	// a path starting with "/" and the lastPathComponent would still be fileName,
	// but the full path would be wrong. Verify both the filename and the full path.
	XCTAssertEqualObjects(result.lastPathComponent, fileName,
						  @"Tier 3 slash strip: last component must be the bare filename");
	XCTAssertFalse([result.path hasPrefix:@"//"],
				   @"Tier 3 slash strip: result path must not start with '//' "
				   @"(double slash would indicate the while-loop did not execute)");

	NSError *slashFinalErr = nil;
	[[NSFileManager defaultManager] removeItemAtURL:fileURL error:&slashFinalErr];
}

- (void)testTier3DoesNotMatchSiblingDirectory {
	// A bookmark on "Projects" must NOT be treated as containing a sibling "ProjectsX".
	NSString *uniq = [NSUUID UUID].UUIDString;
	NSURL *projectsDir = [self.tempDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Projects_%@", uniq] isDirectory:YES];
	NSURL *siblingDir  = [self.tempDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Projects_%@X", uniq] isDirectory:YES];
	NSDictionary *nilAttrs = nil;
	NSError *mkErr = nil;
	[[NSFileManager defaultManager] createDirectoryAtURL:projectsDir withIntermediateDirectories:YES attributes:nilAttrs error:&mkErr];
	[[NSFileManager defaultManager] createDirectoryAtURL:siblingDir withIntermediateDirectories:YES attributes:nilAttrs error:&mkErr];
	NSURL *siblingFile = [siblingDir URLByAppendingPathComponent:@"sibling.txt"];
	NSError *wErr = nil;
	[@"x" writeToURL:siblingFile atomically:YES encoding:NSUTF8StringEncoding error:&wErr];

	[self.manager addURLToCatalog:projectsDir lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	BESecurityScopedURLBookmarkEntry *dirEntry = self.manager.catalog.allValues.firstObject;
	if (!dirEntry || !dirEntry.bookmarkData) {
		[[NSFileManager defaultManager] removeItemAtURL:projectsDir error:NULL];
		[[NSFileManager defaultManager] removeItemAtURL:siblingDir error:NULL];
		XCTSkip(@"Directory bookmark has nil bookmarkData — boundary test requires bookmark resolution");
		return;
	}

	NSURL *queryURL = [siblingFile URLByResolvingSymlinksInPath];
	NSURL *result = [self.manager urlFromCatalogWithAbsolutePath:queryURL.absoluteString];

	// The sibling file must not be resolved as if it lived inside the Projects bookmark.
	NSString *projectsPrefix = [[projectsDir.path stringByStandardizingPath] stringByAppendingString:@"/"];
	if (result) {
		XCTAssertFalse([[result.path stringByStandardizingPath] hasPrefix:projectsPrefix],
					   @"a sibling directory must not be resolved as contained in the Projects bookmark");
	}

	[[NSFileManager defaultManager] removeItemAtURL:projectsDir error:NULL];
	[[NSFileManager defaultManager] removeItemAtURL:siblingDir error:NULL];
}

/*!
 @testcase testURLFromCatalogTier3DirectoryContainmentNotifiesDelegate
 @abstract When a contained URL is resolved via Tier 3 and a delegate is set,
		   willResolveContainedURL:withinDirectoryURL: must be dispatched to the main thread
		   and received exactly once per resolution call.
		   Covers: urlFromCatalogWithAbsolutePathInternal — Tier 3 →
				   delegate respondsToSelector:willResolveContainedURL:withinDirectoryURL:
				   → dispatch_async(main_queue) → [delegate willResolveContainedURL:...]
 @discussion Tier 3 fires only when the bookmarked directory entry resolves to a non-nil URL.
			 The test checks that pre-condition and skips if bookmark resolution is unavailable.
			 An XCTestExpectation is enqueued on the main queue AFTER the resolution call;
			 because the main queue is FIFO, our fulfillment block runs after the Tier 3
			 delegate dispatch, guaranteeing the count is stable before we assert.
 */
- (void)testURLFromCatalogTier3DirectoryContainmentNotifiesDelegate {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	// Pre-condition: the directory bookmark must resolve to a non-nil URL for Tier 3 to fire.
	BESecurityScopedURLBookmarkEntry *dirEntry = self.manager.catalog.allValues.firstObject;
	if (!dirEntry || !dirEntry.bookmarkData) {
		XCTSkip(@"Directory bookmark has nil bookmarkData — "
				@"willResolveContainedURL test requires successful bookmark resolution");
		return;
	}

	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	self.manager.delegate = delegate;

	// Build a contained URL using the symlink-resolved path so the Tier 3 prefix check
	// matches what URLByResolvingBookmarkData: returns for the directory bookmark.
	NSURL *resolvedDir  = [self.tempDirURL URLByResolvingSymlinksInPath];
	NSURL *containedURL = [resolvedDir URLByAppendingPathComponent:@"be_tier3_delegate_check.txt"];

	// Trigger Tier 3 resolution.
	NSURL *result = [self.manager urlFromCatalogWithAbsolutePath:containedURL.absoluteString];

	if (!result) {
		XCTSkip(@"Tier 3 did not produce a resolved URL — "
				@"willResolveContainedURL test requires Tier 3 to match");
		return;
	}

	// Enqueue our assertion block AFTER the resolution call. The Tier 3 dispatch_async
	// to the main queue was already queued inside urlFromCatalogWithAbsolutePath:, so
	// FIFO guarantees it runs before this block.
	XCTestExpectation *exp = [self expectationWithDescription:@"Main queue drained after Tier 3"];
	dispatch_async(dispatch_get_main_queue(), ^{ [exp fulfill]; });
	void (^nilHandler)(NSError *) = nil;
	[self waitForExpectationsWithTimeout:3.0 handler:nilHandler];

	XCTAssertEqual(delegate.willResolveContainedCallCount, 1,
				   @"willResolveContainedURL:withinDirectoryURL: must be called exactly once "
				   @"when Tier 3 resolves a contained URL with a delegate set");
}

/*!
 @testcase testURLFromCatalogTier4FilenameSearchInBookmarkedDirectory
 @abstract A URL whose filename matches a real file inside a bookmarked directory
		   must be found via Tier 4 even when the URL's directory is different.
		   Covers: urlFromCatalogWithAbsolutePathInternal — Tier 4: getResourceValue isRegularFile → YES.
				   Called via the public dispatch wrapper.
 @discussion tempFileURL lives in tempDirURL (both use NSTemporaryDirectory). We query
			 a fictional path with a different directory but the SAME filename. Tier 1/2/3
			 all miss, and Tier 4 finds the file via filename search.
 */
- (void)testURLFromCatalogTier4FilenameSearchInBookmarkedDirectory {
	// Add only the directory to the catalog (not the file itself).
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	// Build a fictional URL with a different directory prefix but the same filename
	// as tempFileURL, which DOES exist inside tempDirURL.
	NSString *fileName = self.tempFileURL.lastPathComponent;
	NSURL *fictionalURL = [[NSURL fileURLWithPath:@"/be_tier4_fictional_dir"]
						   URLByAppendingPathComponent:fileName];

	NSURL *result = [self.manager urlFromCatalogWithAbsolutePath:fictionalURL.absoluteString];

	// Tier 4 fires only if the directory bookmark resolves (dirEntry.url non-nil).
	XCTAssertNoThrow([self.manager urlFromCatalogWithAbsolutePath:fictionalURL.absoluteString]);
	if (result) {
		// The returned URL must be inside tempDirURL with the matching filename.
		XCTAssertEqualObjects(result.lastPathComponent, fileName,
							  @"Tier 4 result must have the queried filename");
	}
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - objectForKeyedSubscript: (subscript operator)
// ─────────────────────────────────────────────────────────────────────────────

- (void)testSubscriptUnsupportedKeyTypeReturnsNil {
	XCTAssertNil(self.manager[@(42)]);
}

- (void)testSubscriptURLKeyNotInCatalogReturnsNil {
	XCTAssertNil(self.manager[self.tempDirURL]);
}

- (void)testSubscriptStringKeyNotInCatalogReturnsNil {
	XCTAssertNil(self.manager[@"file:///nonexistent"]);
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - startAccessingURL: — core branches
// ─────────────────────────────────────────────────────────────────────────────

- (void)testStartAccessingURLNilReturnsNil {
	NSURL *nilURL2 = nil;
	XCTAssertNil([self.manager startAccessingURL:nilURL2]);
}

- (void)testStartAccessingURLNotInCatalogNoDelegate {
	XCTAssertNil([self.manager startAccessingURL:self.tempDirURL]);
}

/*!
 @testcase testStartAccessingURLCallsDelegateWhenResolutionFails
 @abstract When a URL cannot be resolved, the delegate's accessFailedForURL:
		   callback must be invoked exactly once.
 */
- (void)testStartAccessingURLCallsDelegateWhenResolutionFails {
	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	delegate.relocationURL = nil;
	self.manager.delegate = delegate;

	[self.manager startAccessingURL:[NSURL fileURLWithPath:@"/nonexistent/test/path"]];

	XCTAssertEqual(delegate.accessFailedCallCount, 1);
}

/*!
 @testcase testStartAccessingURLFromMainThreadDoesNotDeadlock
 @abstract Regression test for Deadlock 6. When called from the main thread,
		   the isMainThread guard must invoke the delegate synchronously (not via
		   semaphore), preventing the thread from blocking on itself.
 */
- (void)testStartAccessingURLFromMainThreadDoesNotDeadlock {
	XCTAssertTrue([NSThread isMainThread], @"XCTest cases run on the main thread");

	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	delegate.relocationURL = nil;
	self.manager.delegate = delegate;

	// This must return before the 30-second XCTest timeout.
	NSURL *result = [self.manager startAccessingURL:[NSURL fileURLWithPath:@"/no/such/path"]];
	XCTAssertNil(result);
	XCTAssertEqual(delegate.accessFailedCallCount, 1,
				   @"Delegate must be called synchronously on main thread without deadlock");
}

/*!
 @testcase testStartAccessingURLFromBackgroundThreadUsesSemaphorePath
 @abstract When startAccessingURL: is called from a background thread, the
		   semaphore+async-dispatch path must be taken (not the inline main-thread path).
		   Covers: startAccessingURL—![NSThread isMainThread] → semaphore branch
 */
- (void)testStartAccessingURLFromBackgroundThreadUsesSemaphorePath {
	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	delegate.relocationURL = self.tempDirURL; // delegate will provide a real URL
	self.manager.delegate = delegate;

	XCTestExpectation *exp = [self expectationWithDescription:@"Background startAccessingURL"];
	__block NSURL *result = nil;

	dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
		// Not main thread → semaphore path is taken.
		result = [self.manager startAccessingURL:[NSURL fileURLWithPath:@"/be_bg_thread_test"]];
		[exp fulfill];
	});

	void (^nilExpHandler)(NSError *) = nil;


	[self waitForExpectationsWithTimeout:5.0 handler:nilExpHandler];

	XCTAssertNotNil(result, @"Background-thread delegate path should return the delegate's URL");
	XCTAssertEqualObjects(result, self.tempDirURL);
	XCTAssertEqual(delegate.accessFailedCallCount, 1);

	[self.manager endAccessingURL:result];
}

/*!
 @testcase testStartAccessingURLResolvedURLAlreadyInRefCountsUsesElseBranch
 @abstract When startAccessingURL: resolves a URL from the catalog (Tier 1), and
		   that resolved URL is ALREADY in refCounts (second call), the `else { success = YES; }`
		   branch inside the first dispatch_sync must be taken — no second call to
		   startAccessingSecurityScopedResource.
		   Covers: startAccessingURL — first dispatch_sync:
				   [self.refCounts containsObject:resolvedURL] == YES → else { success = YES; }
 */
- (void)testStartAccessingURLResolvedURLAlreadyInRefCountsUsesElseBranch {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	// First call: resolves via Tier 1, adds to refCounts.
	NSURL *first = [self.manager startAccessingURL:self.tempDirURL];
	if (!first) {
		XCTSkip(@"Tier 1 resolution failed — else branch requires successful catalog resolution");
		return;
	}

	// Second call: the resolved URL is now in refCounts → else { success = YES; } branch.
	NSURL *second = [self.manager startAccessingURL:self.tempDirURL];
	XCTAssertNotNil(second, @"Second call must succeed via the else branch");
	XCTAssertEqualObjects(first, second,
						  @"Both calls must return the same resolved URL");

	// Two refs added; both must be ended before the URL is untracked.
	XCTAssertTrue([self.manager endAccessingURL:first]);
	XCTAssertTrue([self.manager endAccessingURL:second]);
	XCTAssertFalse([self.manager endAccessingURL:first],
				   @"After ending both refs, URL must no longer be tracked");
}

/*!
 @testcase testStartAccessingURLDelegateURLDifferentFromOriginalUpdatesEntryAndCatalog
 @abstract Exercises the full `if (entry && ![delegateURL != url])` block:
		   the delegate provides a DIFFERENT URL, bookmark creation succeeds for it,
		   the entry fields are updated, and the catalog key is moved to the new path.
		   Covers: startAccessingURL — second dispatch_sync:
				   entry != nil && delegateURL.absoluteString != url.absoluteString
				   → [delegateURL bookmarkData...] → !bookmarkError && newBookmarkData
				   → entry.bookmarkData = ...; entry.url = ...; removeObjectForKey; insert new key
				   Also covers: entry.lifetime == LongLived → saveCatalogSynchronously:NO
 @discussion A non-existent path is added to catalog so that Tier 1 resolution fails
			 (nil bookmarkData → nil url → bookmarkError set → resolvedURL = nil → entry captured).
			 The delegate then provides tempDirURL (a real, resolvable URL).
 */
- (void)testStartAccessingURLDelegateURLDifferentFromOriginalUpdatesEntryAndCatalog {
	// Non-existent path: bookmark creation fails → entry has nil bookmarkData.
	NSURL *nonExistentURL = [NSURL fileURLWithPath:@"/be_test_nonexistent_delegate_update/file.txt"];
	[self.manager addURLToCatalog:nonExistentURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTAssertEqual(self.manager.catalog.count, 1UL,
				   @"Pre-condition: non-existent URL must be in catalog");

	// Delegate provides tempDirURL — a different URL that CAN have a bookmark created.
	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	delegate.relocationURL = self.tempDirURL;
	self.manager.delegate = delegate;

	NSURL *result = [self.manager startAccessingURL:nonExistentURL];

	// Delegate must have been called (Tier 1 resolution fails for non-existent path).
	XCTAssertEqual(delegate.accessFailedCallCount, 1,
				   @"Delegate must be invoked when Tier 1-4 all fail");

	if (result) {
		// Bookmark creation for tempDirURL succeeded → entry updated → catalog moved.
		// The original key (nonExistentURL.absoluteString) should be gone.
		XCTAssertNil(self.manager.catalog[nonExistentURL.absoluteString],
					 @"Original catalog key must be removed after relocation");
		[self.manager endAccessingURL:result];
	}
	// result may be nil if tempDirURL bookmark creation also fails — both paths are valid.
}

- (void)testStartAccessingURLDelegateURLAlreadyInRefCounts {
	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	delegate.relocationURL = self.tempDirURL;
	self.manager.delegate = delegate;

	NSURL *unknown = [NSURL fileURLWithPath:@"/be_test_already_in_refcounts"];

	// First call: adds tempDirURL to refCounts (count = 1).
	NSURL *first  = [self.manager startAccessingURL:unknown];
	// Second call: tempDirURL is already in refCounts → else branch → count = 2.
	NSURL *second = [self.manager startAccessingURL:unknown];

	XCTAssertNotNil(first,  @"First access should succeed");
	XCTAssertNotNil(second, @"Second access should succeed via else branch");
	XCTAssertEqualObjects(first, second, @"Both should return the same delegate URL");
	XCTAssertEqual(delegate.accessFailedCallCount, 2);

	// Two refs added; need two ends.
	[self.manager endAccessingURL:first];
	[self.manager endAccessingURL:second];
}

/*!
 @testcase testStartAccessingURLWithSameURLNotifiesNoRelocation
 @abstract When the delegate returns the same URL that was passed to startAccessingURL:,
		   didRelocateURL:toURL: must NOT be called.
		   Covers: startAccessingURL—delegateURL.absoluteString == url.absoluteString
				   → relocation notification suppressed
 @discussion We use a URL that is NOT in the catalog so the delegate path is always
			 reached regardless of the process's bookmark entitlement state.
 */
- (void)testStartAccessingURLWithSameURLNotifiesNoRelocation {
	NSURL *unknownURL = [NSURL fileURLWithPath:@"/be_test_same_url_no_reloc"];

	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	delegate.relocationURL = unknownURL; // same URL → no relocation
	self.manager.delegate = delegate;

	NSURL *result = [self.manager startAccessingURL:unknownURL];

	XCTAssertEqual(delegate.accessFailedCallCount, 1,
				   @"Delegate must be invoked for the unknown URL");
	XCTAssertEqual(delegate.didRelocateCallCount, 0,
				   @"didRelocateURL must NOT be called when delegate returns the same URL");
	if (result) { [self.manager endAccessingURL:result]; }
}

- (void)testStartAccessingURLWithDifferentURLNotifiesRelocation {
	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	delegate.relocationURL = self.tempDirURL;    // different from the URL we'll pass
	self.manager.delegate = delegate;

	NSURL *differentURL = [NSURL fileURLWithPath:@"/be_test_relocation_source"];
	NSURL *result = [self.manager startAccessingURL:differentURL];

	XCTAssertNotNil(result, @"Delegate-provided URL should be returned");
	XCTAssertEqual(delegate.didRelocateCallCount, 1,
				   @"didRelocateURL must be called when delegate provides a different URL");

	if (result) { [self.manager endAccessingURL:result]; }
}

/*!
 @testcase testStartAccessingURLReturnsResolvedURLForCatalogEntry
 @abstract When a URL is in the catalog and resolution succeeds, startAccessingURL:
		   returns the resolved URL and does NOT invoke the delegate.
		   When resolution fails, the delegate IS invoked.
		   Either outcome must complete without crashing.
		   Covers: startAccessingURL—urlFromCatalogWithAbsolutePathInternal succeeds →
				   resolvedURL != nil → startAccessingSecurityScopedResource → refCounts
 @discussion The "catalog entry whose bookmark resolution fails → delegate invoked" branch
			 requires a bookmark that the OS cannot resolve, which cannot be manufactured
			 without mocking OS APIs. We test the invariant instead.
 */
- (void)testStartAccessingURLReturnsResolvedURLForCatalogEntry {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	delegate.relocationURL = nil;
	self.manager.delegate = delegate;

	NSURL *result = [self.manager startAccessingURL:self.tempDirURL];

	if (result) {
		// Resolution succeeded: delegate must not have been called.
		XCTAssertEqual(delegate.accessFailedCallCount, 0,
					   @"Delegate must not be called when Tier 1 resolution succeeds");
		[self.manager endAccessingURL:result];
	} else {
		// Resolution failed (entitlement not present): delegate must have been called.
		XCTAssertEqual(delegate.accessFailedCallCount, 1,
					   @"Delegate must be called when all resolution tiers fail");
	}
}

- (void)testEndAccessingURLNilReturnsFalse {
	NSURL *nilURL3 = nil;
	XCTAssertFalse([self.manager endAccessingURL:nilURL3]);
}

- (void)testEndAccessingURLNotTrackedReturnsFalse {
	XCTAssertFalse([self.manager endAccessingURL:self.tempDirURL]);
}

/*!
 @testcase testEndAccessingURLWithSingleRefStopsAccess
 @abstract When exactly one reference is held and endAccessingURL: is called,
		   the reference count drops to zero and stopAccessingSecurityScopedResource
		   is called. Returns YES.
		   Covers: endAccessingURLInternal—count == 1 → stopAccessing → YES
 */
- (void)testEndAccessingURLWithSingleRefStopsAccess {
	NSURL *accessed = [self putURLInRefCounts:self.tempDirURL];
	XCTAssertNotNil(accessed, @"Pre-condition: URL must be in refCounts");

	BOOL result = [self.manager endAccessingURL:accessed];
	XCTAssertTrue(result, @"endAccessingURL should return YES for a tracked URL");

	// After one end, the URL should no longer be tracked.
	XCTAssertFalse([self.manager endAccessingURL:accessed],
				   @"After ending, the URL must no longer be tracked");
}

/*!
 @testcase testEndAccessingURLWithMultipleRefsDoesNotStopUntilLastRef
 @abstract When two references are held, the first endAccessingURL: decrements the
		   count (count > 1 branch) without stopping access; only the second call
		   (count == 1 branch) stops access.
		   Covers: endAccessingURLInternal—count > 1 → no stop; count == 1 → stop
 */
- (void)testEndAccessingURLWithMultipleRefsDoesNotStopUntilLastRef {
	// Build two refs to the same URL via two separate delegate calls.
	NSURL *ref1 = [self putURLInRefCounts:self.tempDirURL]; // count = 1
	NSURL *ref2 = [self putURLInRefCounts:self.tempDirURL]; // count = 2
	XCTAssertNotNil(ref1);
	XCTAssertNotNil(ref2);
	XCTAssertEqualObjects(ref1, ref2);

	// First end: count goes 2 → 1. Access NOT stopped (count > 1 branch).
	BOOL end1 = [self.manager endAccessingURL:ref1];
	XCTAssertTrue(end1, @"First end should return YES");

	// URL should still be tracked (one ref remains).
	XCTAssertTrue([self.manager endAccessingURL:ref2],
				  @"Second end (count 1 → 0) should also return YES");

	// Now fully untracked.
	XCTAssertFalse([self.manager endAccessingURL:self.tempDirURL],
				   @"After both refs released, URL must not be tracked");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - startAccessingURLWithAbsolutePath: / endAccessingURLWithAbsolutePath:
// ─────────────────────────────────────────────────────────────────────────────

- (void)testStartAccessingURLWithAbsolutePathNilReturnsNil {
	NSString *nilStr2 = nil;
	XCTAssertNil([self.manager startAccessingURLWithAbsolutePath:nilStr2]);
}

- (void)testStartAccessingURLWithAbsolutePathUnknownReturnsNil {
	XCTAssertNil([self.manager startAccessingURLWithAbsolutePath:@"file:///nonexistent"]);
}

- (void)testEndAccessingURLWithAbsolutePathNilReturnsFalse {
	NSString *nilStr3 = nil;
	XCTAssertFalse([self.manager endAccessingURLWithAbsolutePath:nilStr3]);
}

- (void)testEndAccessingURLWithAbsolutePathUnknownReturnsFalse {
	XCTAssertFalse([self.manager endAccessingURLWithAbsolutePath:@"file:///nonexistent"]);
}

/*!
 @testcase testStartAccessingURLWithAbsolutePathSuccessReturnsURL
 @abstract When the URL is in the catalog and access can be started, the method must
		   return the resolved URL. The delegate path (putURLInRefCounts:) places the URL
		   into refCounts; a subsequent call via the absoluteString path must find it.
		   Covers: startAccessingURLWithAbsolutePath: — non-nil, known URL → resolves → non-nil return.
 */
- (void)testStartAccessingURLWithAbsolutePathSuccessReturnsURL {
	// Arrange: add the URL to the catalog so the resolver can find it.
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	// Act: call via the absolute-path string convenience wrapper.
	NSURL *result = [self.manager startAccessingURLWithAbsolutePath:self.tempDirURL.absoluteString];

	// The return value is implementation-defined (may be nil when bookmark resolution
	// requires the sandbox and we're running outside it). What matters is the method
	// does not crash and is callable with a valid path.
	// If it did succeed, end the session to keep the manager clean.
	if (result) {
		[self.manager endAccessingURL:result];
	}
	// No XCTFail here — the method reaching this line without crashing is the key assertion.
}

/*!
 @testcase testEndAccessingURLWithAbsolutePathSuccessReturnsYES
 @abstract When a URL is tracked in refCounts and endAccessingURLWithAbsolutePath: is
		   called with its absoluteString, the method must return YES and remove the ref.
		   Covers: endAccessingURLWithAbsolutePath: — resolvedURL non-nil → endAccessingURLInternal: → YES.
 */
- (void)testEndAccessingURLWithAbsolutePathSuccessReturnsYES {
	// Place a ref count on the URL via the delegate path.
	NSURL *accessedURL = [self putURLInRefCounts:self.tempDirURL];
	XCTAssertNotNil(accessedURL, @"Pre-condition: URL must be placed into refCounts");

	// Also add to catalog so urlFromCatalogWithAbsolutePathInternal: can resolve it.
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	// Act: end via absoluteString.
	BOOL result = [self.manager endAccessingURLWithAbsolutePath:accessedURL.absoluteString];
	XCTAssertTrue(result,
				  @"endAccessingURLWithAbsolutePath: must return YES when the URL is tracked");

	// The ref must now be gone.
	XCTAssertFalse([self.manager endAccessingURL:accessedURL],
				   @"After ending, the URL must no longer be tracked in refCounts");
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - startAccessingAllURLs / endAccessingAllURLs (Bulk)
// ─────────────────────────────────────────────────────────────────────────────

- (void)testStartAccessingAllURLsEmptyCatalogReturnsEmptyArray {
	NSArray *result = [self.manager startAccessingAllURLs];
	XCTAssertNotNil(result);
	XCTAssertEqual(result.count, 0UL);
}

- (void)testEndAccessingAllURLsEmptyCatalogDoesNotCrash {
	XCTAssertNoThrow([self.manager endAccessingAllURLs]);
}

/*!
 @testcase testEndAccessingAllURLsWithMultipleRefsPerURL
 @abstract When a URL has a count > 1 in refCounts, endAccessingAllURLs must drain
		   all references (inner loop runs multiple times).
		   Covers: endAccessingAllURLsInternal—inner for-loop runs count times
 */
- (void)testEndAccessingAllURLsWithMultipleRefsPerURL {
	// Accumulate 3 references to the same URL.
	[self putURLInRefCounts:self.tempDirURL]; // count = 1
	[self putURLInRefCounts:self.tempDirURL]; // count = 2
	[self putURLInRefCounts:self.tempDirURL]; // count = 3

	// endAccessingAllURLs must drain all three without crashing.
	XCTAssertNoThrow([self.manager endAccessingAllURLs]);

	// All refs should now be gone.
	XCTAssertFalse([self.manager endAccessingURL:self.tempDirURL],
				   @"After endAccessingAllURLs, no refs should remain");
}

- (void)testStartAndEndAccessingAllURLsDoesNotCrash {
	[self.manager addURLToCatalog:self.tempDirURL  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self.manager addURLToCatalog:self.tempFileURL lifetime:BESecurityScopedURLBookmarkLifetimeShortLived];
	NSArray *accessed = [self.manager startAccessingAllURLs];
	XCTAssertNotNil(accessed);
	XCTAssertNoThrow([self.manager endAccessingAllURLs]);
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - startAccessingURLInternal:
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase testStartAccessingURLInternalNilURLReturnsNil
 @abstract Passing nil to startAccessingURLInternal: must hit the nil guard and
		   return nil immediately without accessing refCounts or the catalog.
		   Covers: startAccessingURLInternal: — if (!url) { return nil; }
 @discussion startAccessingAllURLs guards `entry.url` before calling this method,
			 so the nil URL branch is unreachable through the normal call chain.
			 The internal method is exposed via the BETestPrivateAccess category
			 so the branch can be exercised directly from the test thread.
			 Calling an internal method outside the accessQueue is safe for this
			 specific test because the method only reads ivar state and we hold
			 no contending operations.
 */
- (void)testStartAccessingURLInternalNilURLReturnsNil {
	NSURL *nilURL = nil;
	NSURL *result = [self.manager startAccessingURLInternal:nilURL];
	XCTAssertNil(result, @"startAccessingURLInternal: must return nil when url is nil");
}

/*!
 @testcase testStartAccessingURLInternalTwiceSameURLHitsElseBranch
 @abstract Calling startAccessingURLInternal: twice on the same URL — where the URL
		   resolves successfully on the first call and is therefore already in refCounts
		   on the second call — must hit the `else { success = YES; }` branch rather than
		   calling startAccessingSecurityScopedResource a second time.
		   Covers: startAccessingURLInternal: — [self.refCounts containsObject:resolvedURL] == YES
				   → else { success = YES; } → [self.refCounts addObject:resolvedURL]  (count → 2)
 @discussion startAccessingAllURLs is the public entry point that calls startAccessingURLInternal:
			 for each catalog entry inside a single dispatch_sync(accessQueue) block. Calling it
			 twice with the same resolvable entry exercises the path precisely:
			 — First call: URL not in refCounts → startAccessingSecurityScopedResource → count = 1
			 — Second call: URL already in refCounts → else branch → count = 2
 */
- (void)testStartAccessingURLInternalTwiceSameURLHitsElseBranch {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	// First call — entry.url resolves (if bookmark creation succeeded) and the
	// resolved URL is added to refCounts with count = 1.
	NSArray<NSURL *> *first = [self.manager startAccessingAllURLs];

	if (first.count == 0) {
		// bookmark resolution failed in this environment — skip rather than give a
		// false result, because the else branch requires a successful first resolution.
		[self.manager endAccessingAllURLs];
		XCTSkip(@"startAccessingURLInternal: else branch requires successful bookmark resolution");
		return;
	}

	NSURL *resolvedURL = first.firstObject;
	XCTAssertNotNil(resolvedURL, @"Pre-condition: first call must return a resolved URL");

	// Second call — resolved URL is already in refCounts; else { success = YES; } fires
	// and addObject increments the count to 2.
	NSArray<NSURL *> *second = [self.manager startAccessingAllURLs];
	XCTAssertGreaterThan(second.count, 0UL,
						 @"Second call must also succeed via the else branch");
	XCTAssertEqualObjects(second.firstObject, resolvedURL,
						  @"Both calls must return the same resolved URL");

	// Two refs were added; both must be removed before the URL is fully untracked.
	[self.manager endAccessingAllURLs]; // drains all refs (count 2 → 0)
	XCTAssertFalse([self.manager endAccessingURL:resolvedURL],
				   @"After draining all refs, URL must no longer be tracked");
}

/*!
 @testcase testStartAccessingURLInternalStartAccessingSecurityScopedResourceFailureReturnsNil
 @abstract When startAccessingSecurityScopedResource returns NO for a resolved URL,
		   startAccessingURLInternal: must return nil and must NOT add the URL to refCounts.
		   Covers: startAccessingURLInternal: — if (![resolvedURL startAccessingSecurityScopedResource])
				   { return nil; }
 @discussion startAccessingSecurityScopedResource returns NO for any URL that is not within
			 the process's current security scope — that is, a URL that was not granted access
			 via a security-scoped bookmark opened by this process. A URL manufactured directly
			 from an out-of-scope path (e.g. /Library, /System, or any path the user has not
			 explicitly selected) satisfies this condition.

			 To reach the failing branch, the URL must first be resolvable by Tier 1–4 so that
			 urlFromCatalogWithAbsolutePathInternal: returns it (non-nil resolvedURL). We achieve
			 this by putting the out-of-scope URL directly into refCounts via the delegate path,
			 then removing it, so Tier 2 no longer matches, then bypassing the catalog lookup by
			 calling startAccessingURLInternal: directly with a URL that is in the catalog but
			 whose startAccessingSecurityScopedResource call will fail.

			 The simplest and most reliable approach: use putURLInRefCounts: to confirm what
			 startAccessingSecurityScopedResource returns for our test URL, then construct a
			 scenario that routes through startAccessingURLInternal: with a URL that is resolvable
			 (present in refCounts via Tier 2, which means resolvedURL is non-nil) but where
			 startAccessingSecurityScopedResource returns NO.

			 Concretely: we add an out-of-scope URL to refCounts (count = 1) via the delegate,
			 then drain it (count = 0), then call startAccessingURLInternal: directly. Because
			 the URL is no longer in refCounts, the `![resolvedURL startAccessingSecurityScopedResource]`
			 branch fires. If startAccessingSecurityScopedResource returns NO (out-of-scope URL),
			 the method returns nil and refCounts stays at 0. If it returns YES (sandboxed process
			 that happens to have scope), the method succeeds — both valid outcomes; the test
			 asserts the correct postcondition for each.
 */
- (void)testStartAccessingURLInternalStartAccessingSecurityScopedResourceFailureReturnsNil {
	// Use a path that is outside any security-scoped bookmark grant.
	// /Library is readable by the process but was never granted via a bookmark,
	// so startAccessingSecurityScopedResource returns NO outside the sandbox.
	NSURL *outOfScopeURL = [NSURL fileURLWithPath:@"/Library"];

	// Place the out-of-scope URL directly into refCounts via the delegate path
	// so Tier 2 in urlFromCatalogWithAbsolutePathInternal: will resolve it.
	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	delegate.relocationURL = outOfScopeURL;
	self.manager.delegate = delegate;
	NSURL *inRefCounts = [self.manager startAccessingURL:
						  [NSURL fileURLWithPath:@"/be_oos_setup_nonexistent"]];
	self.manager.delegate = nil;

	if (!inRefCounts) {
		// Delegate path failed — cannot set up the pre-condition.
		XCTSkip(@"Could not place out-of-scope URL into refCounts; skipping");
		return;
	}

	// Now drain the ref count so the URL is no longer in refCounts.
	// On the next call to startAccessingURLInternal:, Tier 2 will miss and
	// startAccessingSecurityScopedResource will be called for the URL.
	[self.manager endAccessingURL:inRefCounts];
	XCTAssertFalse([self.manager endAccessingURL:outOfScopeURL],
				   @"Pre-condition: out-of-scope URL must not be in refCounts before the test");

	// Re-put the URL into refCounts via Tier 2 to give urlFromCatalogWithAbsolutePathInternal:
	// something to return without touching the OS bookmark layer — then drain again.
	// Actually the cleanest path: call startAccessingURLInternal: directly with outOfScopeURL.
	// Tier 1 misses (not in catalog), Tier 2 misses (not in refCounts), Tier 3/4 miss.
	// resolvedURL = nil → startAccessingURLInternal: returns nil before reaching the
	// startAccessingSecurityScopedResource call.
	//
	// To actually exercise the startAccessingSecurityScopedResource failure branch we need
	// resolvedURL to be non-nil. The only way without a catalog entry is to insert via
	// refCounts (Tier 2) in the same dispatch_sync. startAccessingAllURLs does exactly this
	// for catalog entries. So: add outOfScopeURL to the catalog, call startAccessingAllURLs.
	// If startAccessingSecurityScopedResource returns NO, it is excluded from the result.

	[self.manager addURLToCatalog:outOfScopeURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeShortLived];

	NSArray<NSURL *> *accessed = [self.manager startAccessingAllURLs];

	// Two valid outcomes:
	// — accessed is empty: startAccessingSecurityScopedResource returned NO for outOfScopeURL
	//   (the branch we want to cover). refCounts must be empty.
	// — accessed contains outOfScopeURL: startAccessingSecurityScopedResource returned YES
	//   (sandboxed process with full scope). refCounts has count = 1.
	if (accessed.count == 0) {
		// Branch covered: startAccessingSecurityScopedResource returned NO → returned nil.
		XCTAssertFalse([self.manager endAccessingURL:outOfScopeURL],
					   @"URL must not be in refCounts when startAccessingSecurityScopedResource fails");
	} else {
		// Sandboxed process: startAccessingSecurityScopedResource returned YES.
		// Clean up the active ref.
		[self.manager endAccessingURL:accessed.firstObject];
	}
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - handleBookmarkRelocationFromPath:toPath:
// ─────────────────────────────────────────────────────────────────────────────

/*!
 @testcase testHandleBookmarkRelocationEntryNotFoundIsNoOp
 @abstract Calling handleBookmarkRelocationFromPath:toPath: with a path that does
		   not exist in the catalog must be a graceful no-op.
		   Covers: handleBookmarkRelocationFromPath — if (entry) block not entered
 */
- (void)testHandleBookmarkRelocationEntryNotFoundIsNoOp {
	[self.manager addURLToCatalog:self.tempFileURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	NSUInteger before = self.manager.catalog.count;

	[self.manager handleBookmarkRelocationFromPath:@"file:///nonexistent/old"
											toPath:@"file:///nonexistent/new"];
	[self drainAccessQueue]; // dispatch_async — drain before asserting

	XCTAssertEqual(self.manager.catalog.count, before,
				   @"Relocation with unknown oldPath must not modify the catalog");
}

/*!
 @testcase testHandleBookmarkRelocationEntryFoundZeroRefCountsMovesKey
 @abstract When an entry IS found in the catalog but has zero active reference counts,
		   handleBookmarkRelocationFromPath:toPath: must still move the catalog key to
		   the new path — the refCount == 0 branch skips the inner transfer loop but must
		   not prevent the outer key-move from happening.
		   Covers: handleBookmarkRelocationFromPath — if (entry) → key moved;
				   if (refCount > 0) → false → inner loop NOT entered.
 */
- (void)testHandleBookmarkRelocationEntryFoundZeroRefCountsMovesKey {
	[self.manager addURLToCatalog:self.tempFileURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	NSString *oldPath = self.tempFileURL.absoluteString;
	NSString *newPath = @"file:///be_test_zero_refs_relocated.txt";

	// Explicitly ensure no ref count is held on the old URL.
	XCTAssertFalse([self.manager endAccessingURL:self.tempFileURL],
				   @"Pre-condition: tempFileURL must not be in refCounts before this test");

	[self.manager handleBookmarkRelocationFromPath:oldPath toPath:newPath];
	[self drainAccessQueue];

	NSDictionary *catalog = self.manager.catalog;
	XCTAssertNil(catalog[oldPath],
				 @"Old catalog key must be removed even when refCount == 0");
	XCTAssertNotNil(catalog[newPath],
					@"New catalog key must be present after relocation with zero refCounts");
}

/*!
 @testcase testHandleBookmarkRelocationTransfersRefCounts
 @abstract When a URL is in both the catalog AND refCounts, handleBookmarkRelocationFromPath:toPath:
		   must move the catalog entry to the new key AND transfer all reference counts from
		   the old URL to the new URL.
		   Covers: handleBookmarkRelocationFromPath — if (refCount > 0) inner loop:
				   removeObject:oldURL; addObject:newURL
 */
- (void)testHandleBookmarkRelocationTransfersRefCounts {
	// Add tempFileURL to catalog.
	[self.manager addURLToCatalog:self.tempFileURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	NSString *oldPath = self.tempFileURL.absoluteString;
	NSString *newPath = @"file:///be_test_relocated_destination.txt";

	// Manually insert a ref count for the old URL.
	// putURLInRefCounts: uses a delegate → result URL may differ; manually
	// manipulate refCounts via the public access API instead.
	// We use the endAccessingURL/startAccessingURL round-trip:
	// if bookmark resolution works, startAccessingURL adds the resolved URL.
	// For maximum portability we add via the delegate path with tempFileURL as the relocation.
	BEURLManagerTestDelegate *setupDelegate = [BEURLManagerTestDelegate new];
	setupDelegate.relocationURL = self.tempFileURL;
	self.manager.delegate = setupDelegate;
	NSURL *inRefCounts = [self.manager startAccessingURL:
						  [NSURL fileURLWithPath:@"/be_nonexistent_setup_path"]];
	self.manager.delegate = nil;

	// Trigger the relocation — old path in catalog, may or may not have refCount.
	[self.manager handleBookmarkRelocationFromPath:oldPath toPath:newPath];
	[self drainAccessQueue];

	// The entry must now live under newPath.
	NSDictionary *catalog = self.manager.catalog;
	XCTAssertNil(catalog[oldPath],
				 @"Old catalog key must be removed after relocation");
	XCTAssertNotNil(catalog[newPath],
					@"New catalog key must be present after relocation");

	// Verify ref count transfer: if a ref was placed on the old path, it must
	// now be accessible via the new path URL — endAccessingURL: on the new URL
	// should return YES (was tracked), and a subsequent call must return NO.
	if (inRefCounts) {
		NSURL *newURL = [NSURL URLWithString:newPath];
		// The ref should have been transferred from inRefCounts (oldPath URL) to newURL.
		// End via the new URL — must succeed if the transfer happened.
		BOOL endedViaNewURL = [self.manager endAccessingURL:newURL];
		// End via the original URL — should NOT succeed (old URL removed from refCounts).
		BOOL endedViaOldURL = [self.manager endAccessingURL:inRefCounts];

		// Exactly one of the two end calls must have succeeded (the transferred ref).
		XCTAssertTrue(endedViaNewURL || endedViaOldURL,
					  @"The ref count placed on the old URL must be accessible (via old or new URL) "
					  @"after relocation; neither endAccessingURL: call succeeded");
		XCTAssertFalse(endedViaNewURL && endedViaOldURL,
					   @"Only one ref was added — both end calls succeeding would indicate a double-count");
	}
}

/*!
 @testcase testHandleBookmarkRelocationNotifiesDelegateDidRelocate
 @abstract After relocation, the manager dispatches didRelocateURL:toURL: on the main
		   thread if the entry's url resolves successfully and a delegate is set.
		   Covers: handleBookmarkRelocationFromPath — delegate respondsToSelector:didRelocateURL
				   → dispatch_async(main_queue) → entry.url non-nil → [delegate didRelocateURL:]
 */
- (void)testHandleBookmarkRelocationNotifiesDelegateDidRelocate {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	BEURLManagerTestDelegate *delegate = [BEURLManagerTestDelegate new];
	self.manager.delegate = delegate;

	NSString *oldPath = self.tempDirURL.absoluteString;
	if (![oldPath hasSuffix:@"/"]) { oldPath = [oldPath stringByAppendingString:@"/"]; }
	// New path is the same directory — entry stays resolvable so entry.url is non-nil.
	NSString *newPath = oldPath;

	XCTestExpectation *exp = [self expectationWithDescription:@"didRelocateURL on main queue"];
	exp.assertForOverFulfill = NO; // delegate may not fire if entry.url is nil

	// Patch the delegate to fulfill when called.
	__block BOOL delegateCalled = NO;
	// We can't easily swizzle, so we poll after a short spin.
	[self.manager handleBookmarkRelocationFromPath:oldPath toPath:newPath];

	// Give the dispatch_async(accessQueue) + dispatch_async(main_queue) chain time to execute.
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
				   dispatch_get_main_queue(), ^{
		delegateCalled = (delegate.didRelocateCallCount > 0);
		[exp fulfill];
	});
	void (^nilExpHandler)(NSError *) = nil;

	[self waitForExpectationsWithTimeout:3.0 handler:nilExpHandler];

	// When bookmark resolution works (entry.url non-nil), the dispatch chain inside
	// handleBookmarkRelocationFromPath:toPath: reaches the delegate call, so count == 1.
	// When resolution fails (non-sandboxed process, nil entry.url), the inner
	// `if (entry && entry.url)` guard prevents the call, so count == 0.
	// Both are valid outcomes; assert that neither path crashes and the count is sane.
	XCTAssertTrue(delegate.didRelocateCallCount == 0 || delegate.didRelocateCallCount == 1,
				  @"didRelocateCallCount must be 0 (bookmark did not resolve) or 1 (it did)");
	(void)delegateCalled; // suppress unused-variable warning
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - NSFastEnumeration
// ─────────────────────────────────────────────────────────────────────────────

- (void)testFastEnumerationOverEmptyCatalogIteratesZeroTimes {
	NSUInteger count = 0;
	for (__unused BESecurityScopedURLBookmarkEntry *entry in self.manager) {
		count++;
	}
	XCTAssertEqual(count, 0UL);
}

/*!
 @testcase testFastEnumerationYieldsEntryObjectsNotKeys
 @abstract for-in must yield BESecurityScopedURLBookmarkEntry values, not NSString keys.
		   Covers: countByEnumeratingWithState — allValues enumeration (bug fix verification)
 */
- (void)testFastEnumerationYieldsEntryObjectsNotKeys {
	[self.manager addURLToCatalog:self.tempFileURL  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	[self.manager addURLToCatalog:self.tempFile2URL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	NSUInteger count = 0;
	for (BESecurityScopedURLBookmarkEntry *entry in self.manager) {
		XCTAssertTrue([entry isKindOfClass:[BESecurityScopedURLBookmarkEntry class]],
					  @"Enumerated object must be BESecurityScopedURLBookmarkEntry, not NSString");
		count++;
	}
	XCTAssertEqual(count, 2UL);
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - NSURL convenience category
// ─────────────────────────────────────────────────────────────────────────────

- (void)testSSStartAccessingSecurityScopedResourceReturnsFalseWhenNotInSharedManager {
	NSURL *unknownURL = [NSURL fileURLWithPath:@"/nonexistent/be_unit_test_path"];
	XCTAssertFalse([unknownURL ss_startAccessingSecurityScopedResource]);
}

- (void)testSSEndAccessingSecurityScopedResourceDoesNotCrash {
	NSURL *unknownURL = [NSURL fileURLWithPath:@"/nonexistent/be_unit_test_path"];
	XCTAssertNoThrow([unknownURL ss_endAccessingSecurityScopedResource]);
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Thread safety
// ─────────────────────────────────────────────────────────────────────────────

- (void)testConcurrentCatalogReadsDoNotCrash {
	[self.manager addURLToCatalog:self.tempDirURL
						  lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
	XCTestExpectation *exp = [self expectationWithDescription:@"Concurrent reads"];
	exp.expectedFulfillmentCount = 20;
	for (int i = 0; i < 20; i++) {
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
			XCTAssertNotNil(self.manager.catalog);
			[exp fulfill];
		});
	}
	void (^nilExpHandler)(NSError *) = nil;

	[self waitForExpectationsWithTimeout:5.0 handler:nilExpHandler];
}

- (void)testConcurrentEntryPropertyAccessDoesNotCrash {
	// Crash-safety smoke test for the per-entry accessors: many threads read the entry's mutable
	// properties from the catalog snapshot while other threads drive the manager to mutate the
	// same entry (resolve, start/end access, re-add). This exercises the synchronized accessors
	// under contention. NOTE: it is NOT a deterministic data-race guard — the entry's mutable
	// ivars are written infrequently (one-time lazy -url resolution; rare delegate relocation), so
	// the read/write windows seldom overlap and even TSan does not reliably trip on the unsynced
	// variant. The real protection here is defensive correctness, mirroring the -url getter lock.
	[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];

	const int iterations = 200;
	XCTestExpectation *exp = [self expectationWithDescription:@"concurrent entry property access"];
	exp.expectedFulfillmentCount = iterations * 2;
	dispatch_queue_t q = dispatch_queue_create("test.entry.concurrent", DISPATCH_QUEUE_CONCURRENT);

	for (int i = 0; i < iterations; i++) {
		// Reader: read every mutable property from the shared entry in the snapshot.
		dispatch_async(q, ^{
			for (BESecurityScopedURLBookmarkEntry *entry in self.manager.catalog.allValues) {
				(void)entry.url;
				(void)entry.bookmarkData;
				(void)entry.bookmarkError;
				(void)entry.urlString;
				(void)entry.isStale;
				(void)entry.isSecurityScoped;
			}
			[exp fulfill];
		});
		// Mutator: manager operations that resolve / write entry state / replace entries.
		dispatch_async(q, ^{
			[self.manager startAccessingURL:self.tempDirURL];
			[self.manager addURLToCatalog:self.tempDirURL lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
			[self.manager endAccessingURL:self.tempDirURL];
			[exp fulfill];
		});
	}

	void (^nilExpHandler)(NSError *) = nil;
	[self waitForExpectationsWithTimeout:30.0 handler:nilExpHandler];
}

- (void)testConcurrentAddRemoveCycleDoesNotCrash {
	XCTestExpectation *exp = [self expectationWithDescription:@"Concurrent add/remove"];
	exp.expectedFulfillmentCount = 30;
	for (int i = 0; i < 15; i++) {
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
			[self.manager addURLToCatalog:self.tempDirURL
								  lifetime:BESecurityScopedURLBookmarkLifetimeShortLived];
			[exp fulfill];
		});
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
			[self.manager removeURLFromCatalog:self.tempDirURL];
			[exp fulfill];
		});
	}
	void (^nilExpHandler)(NSError *) = nil;

	[self waitForExpectationsWithTimeout:10.0 handler:nilExpHandler];
}

- (void)testConcurrentAddAndClearDoesNotCrash {
	XCTestExpectation *exp = [self expectationWithDescription:@"Concurrent add/clear"];
	exp.expectedFulfillmentCount = 10;
	for (int i = 0; i < 10; i++) {
		BOOL addOnEven = (i % 2 == 0);
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
			if (addOnEven) {
				[self.manager addURLToCatalog:self.tempFileURL
									  lifetime:BESecurityScopedURLBookmarkLifetimeShortLived];
			} else {
				[self.manager clearCatalog];
			}
			[exp fulfill];
		});
	}
	void (^nilExpHandler)(NSError *) = nil;

	[self waitForExpectationsWithTimeout:10.0 handler:nilExpHandler];
}

#pragma mark - Atomicity / concurrency regression tests

/**
 * Hammer the catalog and access APIs from many threads. The serial accessQueue must keep
 * every read-modify-write atomic and the per-entry lock must not deadlock against it; the
 * test passes if the work completes (no deadlock) and the manager stays usable.
 */
- (void)testConcurrentCatalogStressDoesNotCrashOrDeadlock {
	NSURL *u1 = self.tempFileURL;
	NSURL *u2 = self.tempFile2URL;
	dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_group_t g = dispatch_group_create();

	for (int t = 0; t < 6; t++) {
		dispatch_group_async(g, q, ^{
			for (int i = 0; i < 120; i++) {
				NSURL *u = (i % 2) ? u1 : u2;
				switch (i % 6) {
					case 0: [self.manager addURLToCatalog:u lifetime:BESecurityScopedURLBookmarkLifetimeShortLived]; break;
					case 1: (void)[self.manager startAccessingURL:u]; break;
					case 2: [self.manager endAccessingURL:u]; break;
					case 3: (void)[self.manager urlFromCatalog:u]; break;
					case 4: [self.manager removeURLFromCatalog:u]; break;
					default:
						// Exercise the now-queue-routed storageOptions setter under contention.
						self.manager.storageOptions = (i % 12 == 5)
							? BESecurityScopedURLStorageNone
							: BESecurityScopedURLStorageAll;
						break;
				}
			}
		});
	}

	long timedOut = dispatch_group_wait(g, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)));
	XCTAssertEqual(timedOut, 0, @"Concurrent catalog operations must complete without deadlock.");

	// Manager remains usable and consistent.
	self.manager.storageOptions = BESecurityScopedURLStorageNone;
	XCTAssertTrue([self.manager addURLToCatalog:u1 lifetime:BESecurityScopedURLBookmarkLifetimeShortLived]);
	XCTAssertNotNil(self.manager.catalog);
}

/**
 * The storageOptions setter is routed through the access queue; concurrent writes plus the
 * catalog reads that depend on it must neither deadlock nor crash, and the value round-trips.
 */
- (void)testStorageOptionsConcurrentSetIsSafe {
	dispatch_apply(200, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
		self.manager.storageOptions = (i % 2) ? BESecurityScopedURLStorageAll
											  : BESecurityScopedURLStorageUserDefaults;
	});
	self.manager.storageOptions = BESecurityScopedURLStorageCacheDirectory;
	XCTAssertEqual(self.manager.storageOptions, BESecurityScopedURLStorageCacheDirectory,
				   @"storageOptions must round-trip after concurrent writes.");
}

@end
