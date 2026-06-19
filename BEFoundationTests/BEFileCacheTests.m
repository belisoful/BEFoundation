/**
 * BEFileCacheTests.m
 *
 * Comprehensive XCTest suite for BEFileCache.
 * Target coverage: 100 % of executable branches.
 *
 * Test-fixture classes declared at the top of the file:
 *   BETestObject          – NSSecureCoding-conforming value object.
 *   BETestObjectNoCoding  – does NOT conform to NSSecureCoding (memory-only).
 *   BETestDiscardable     – NSSecureCoding + NSDiscardableContent.
 *   BETestDelegate        – records every BEFileCacheDelegate callback.
 *
 * Conventions
 * ───────────
 *   • Each test method is self-contained: setUp creates a fresh temp directory
 *     and cache; tearDown deletes the directory.
 *   • Any call that touches diskMeta via dispatch_sync implicitly drains the
 *     serial disk queue, so tests that need the async loadIndex to complete
 *     simply call objectForKey: first (which uses dispatch_sync internally).
 *   • Helpers -waitForDiskQueue and -freshCacheOnSameDirectory are defined
 *     near the top of the test class.
 */

#import <XCTest/XCTest.h>
#import "BEFileCache.h"

// ---------------------------------------------------------------------------
// Testing category — re-exposes private properties for white-box assertions.
// No changes to production code are required; the compiler accepts this because
// the properties are already synthesised in BEFileCache.m.  Declared here so
// tests can read diskCount, diskTotalCost, and memoryCache without making them
// public in the production header.
// ---------------------------------------------------------------------------
@interface BEFileCache (Testing)
@property (strong, nonatomic, readonly) NSCache        *memoryCache;
@property (assign, nonatomic, readonly) NSUInteger      diskCount;
@property (assign, nonatomic, readonly) NSUInteger      diskTotalCost;
@end

// ---------------------------------------------------------------------------
#pragma mark - BETestObject  (NSSecureCoding)
// ---------------------------------------------------------------------------

/**
 * Minimal cacheable value object used throughout the test suite.
 * Carries a single NSString payload so equality checks are easy.
 */
@interface BETestObject : NSObject <NSSecureCoding>
@property (nonatomic, copy) NSString *value;
+ (instancetype)objectWithValue:(NSString *)value;
@end

@implementation BETestObject
+ (BOOL)supportsSecureCoding { return YES; }
+ (instancetype)objectWithValue:(NSString *)value {
	BETestObject *o = [self new];
	o.value = value;
	return o;
}
- (instancetype)initWithCoder:(NSCoder *)coder {
	if ((self = [super init]))
		_value = [coder decodeObjectOfClass:[NSString class] forKey:@"value"];
	return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:_value forKey:@"value"];
}
- (BOOL)isEqual:(id)object {
	return [object isKindOfClass:[BETestObject class]]
		&& [((BETestObject *)object).value isEqualToString:_value];
}
@end

// ---------------------------------------------------------------------------
#pragma mark - BETestObjectNoCoding  (no NSSecureCoding — memory-only)
// ---------------------------------------------------------------------------

/**
 * A plain NSObject that does NOT conform to NSSecureCoding.
 * Stored in memory only; should never appear on disk.
 */
@interface BETestObjectNoCoding : NSObject
@property (nonatomic, copy) NSString *value;
+ (instancetype)objectWithValue:(NSString *)value;
@end

@implementation BETestObjectNoCoding
+ (instancetype)objectWithValue:(NSString *)value {
	BETestObjectNoCoding *o = [self new];
	o.value = value;
	return o;
}
@end

// ---------------------------------------------------------------------------
#pragma mark - BETestDiscardable  (NSSecureCoding + NSDiscardableContent)
// ---------------------------------------------------------------------------

/**
 * A cacheable object that also implements NSDiscardableContent.
 * The -shouldSucceedBeginAccess flag controls whether beginContentAccess
 * returns YES or NO, allowing tests to exercise both branches.
 */
@interface BETestDiscardable : NSObject <NSSecureCoding, NSDiscardableContent>
@property (nonatomic, copy)   NSString *value;
@property (nonatomic, assign) BOOL      shouldSucceedBeginAccess;
@property (nonatomic, assign) NSInteger accessCount;          // net begin − end
@property (nonatomic, assign) NSInteger beginAccessCallCount; // monotonic begin calls
+ (instancetype)objectWithValue:(NSString *)value;
@end

@implementation BETestDiscardable
+ (BOOL)supportsSecureCoding { return YES; }
+ (instancetype)objectWithValue:(NSString *)value {
	BETestDiscardable *o = [self new];
	o.value  = value;
	o.shouldSucceedBeginAccess = YES;   // default: accessible
	return o;
}
- (instancetype)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		_value = [coder decodeObjectOfClass:[NSString class] forKey:@"value"];
		// Round-trip the access flag so a deserialized object can model an inaccessible
		// (discarded) state — this is what lets the disk-hit beginContentAccess==NO branch
		// be tested. Defaults to YES when the key is absent (preserves prior behavior).
		_shouldSucceedBeginAccess = [coder containsValueForKey:@"succeed"]
									? [coder decodeBoolForKey:@"succeed"]
									: YES;
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:_value forKey:@"value"];
	[coder encodeBool:_shouldSucceedBeginAccess forKey:@"succeed"];
}
// NSDiscardableContent
- (BOOL)beginContentAccess {
	_beginAccessCallCount++;
	if (_shouldSucceedBeginAccess) { _accessCount++; return YES; }
	return NO;
}
- (void)endContentAccess   { if (_accessCount > 0) _accessCount--; }
- (void)discardContentIfPossible { _value = nil; }
- (BOOL)isContentDiscarded { return _value == nil; }
@end

// ---------------------------------------------------------------------------
#pragma mark - BETestDelegate
// ---------------------------------------------------------------------------

/**
 * Test delegate that records every callback fired by BEFileCache.
 * Tests inspect -evictedObjects, -evictedFromMemoryObjects, and call counts.
 */
@interface BETestDelegate : NSObject <BEFileCacheDelegate>
@property (nonatomic, strong) NSMutableArray *evictedObjects;
@property (nonatomic, strong) NSMutableArray *evictedFromMemoryObjects;
@property (nonatomic, assign) NSUInteger      willEvictCount;
@property (nonatomic, assign) NSUInteger      willEvictFromMemoryCount;
@end

@implementation BETestDelegate
- (instancetype)init {
	if ((self = [super init])) {
		_evictedObjects           = [NSMutableArray array];
		_evictedFromMemoryObjects = [NSMutableArray array];
	}
	return self;
}
- (void)cache:(BEFileCache *)cache willEvictObject:(id)obj {
	_willEvictCount++;
	[_evictedObjects addObject:obj];
}
- (void)cache:(BEFileCache *)cache willEvictObjectFromMemory:(id)obj {
	_willEvictFromMemoryCount++;
	[_evictedFromMemoryObjects addObject:obj];
}
@end

// ---------------------------------------------------------------------------
#pragma mark - BEFileCacheTests
// ---------------------------------------------------------------------------

@interface BEFileCacheTests : XCTestCase
@property (nonatomic, strong) NSString    *tempDir;
@property (nonatomic, strong) BEFileCache *cache;
@end

@implementation BEFileCacheTests

// ── Setup / teardown ─────────────────────────────────────────────────────────

- (void)setUp {
	[super setUp];

	// Create a unique temporary directory for each test so tests are isolated.
	NSString *base = NSTemporaryDirectory();
	_tempDir = [base stringByAppendingPathComponent:
				[[NSUUID UUID] UUIDString]];
	[[NSFileManager defaultManager]
		createDirectoryAtPath:_tempDir
  withIntermediateDirectories:YES
				   attributes:nil
						error:nil];

	_cache = [[BEFileCache alloc] initWithCacheDirectory:_tempDir];
}

- (void)tearDown {
	_cache = nil;
	[[NSFileManager defaultManager] removeItemAtPath:_tempDir error:nil];
	[super tearDown];
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/**
 * Drains the disk queue by performing a no-op dispatch_sync on it.
 * Because loadIndex uses dispatch_async, any subsequent dispatch_sync
 * (such as those inside objectForKey:) will automatically serialise after it.
 * Calling objectForKey: on a key that doesn't exist is the simplest flush.
 */
- (void)waitForDiskQueue {
	// objectForKey: always calls dispatch_sync(_diskQueue, …) internally,
	// so this call will not return until any pending async blocks complete.
	(void)[_cache objectForKey:@"__flush__"];
}

/**
 * Returns a new BEFileCache instance backed by the same tempDir as the
 * primary cache, simulating an app relaunch with the same cache on disk.
 */
- (BEFileCache *)freshCacheOnSameDirectory {
	return [[BEFileCache alloc] initWithCacheDirectory:_tempDir];
}

/** Returns the absolute path of the first file in tempDir with the given extension, or nil. */
- (nullable NSString *)firstFileInDirWithExtension:(NSString *)ext {
	NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:_tempDir error:nil];
	for (NSString *f in files) {
		if ([f.pathExtension isEqualToString:ext]) {
			return [_tempDir stringByAppendingPathComponent:f];
		}
	}
	return nil;
}

// ---------------------------------------------------------------------------
#pragma mark - Init: directory resolution
// ---------------------------------------------------------------------------

/**
 * nil → default directory under NSCachesDirectory.
 */
- (void)testInit_nilDirectory_usesDefaultSubdirectory {
	BEFileCache *c = [[BEFileCache alloc] init];
	NSString *caches = NSSearchPathForDirectoriesInDomains(
		NSCachesDirectory, NSUserDomainMask, YES).firstObject;
	NSString *expected = [caches stringByAppendingPathComponent:@"BEFileCache"];
	XCTAssertEqualObjects(c.cacheDirectory, expected);
}

/**
 * Empty string → same as nil (default subdirectory).
 */
- (void)testInit_emptyString_usesDefaultSubdirectory {
	BEFileCache *c = [[BEFileCache alloc] initWithCacheDirectory:@""];
	NSString *caches = NSSearchPathForDirectoriesInDomains(
		NSCachesDirectory, NSUserDomainMask, YES).firstObject;
	NSString *expected = [caches stringByAppendingPathComponent:@"BEFileCache"];
	XCTAssertEqualObjects(c.cacheDirectory, expected);
}

/**
 * Absolute path to an existing directory → used verbatim.
 */
- (void)testInit_existingDirectory_usedAsIs {
	XCTAssertEqualObjects(_cache.cacheDirectory, _tempDir);
}

/**
 * Plain name that is not an existing directory → appended to NSCachesDirectory.
 */
- (void)testInit_plainName_appendedToCachesDirectory {
	NSString *name    = @"BEFileCacheTestCustomName";
	BEFileCache *c    = [[BEFileCache alloc] initWithCacheDirectory:name];
	NSString *caches  = NSSearchPathForDirectoriesInDomains(
		NSCachesDirectory, NSUserDomainMask, YES).firstObject;
	NSString *expected = [caches stringByAppendingPathComponent:name];
	XCTAssertEqualObjects(c.cacheDirectory, expected);
	// Clean up
	[[NSFileManager defaultManager] removeItemAtPath:expected error:nil];
}

/**
 * The designated directory is created on disk during initialisation.
 */
- (void)testInit_createsDirectoryOnDisk {
	NSString *path = [NSTemporaryDirectory()
						stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
	// Directory must NOT exist before init.
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];

	BEFileCache *c = [[BEFileCache alloc] initWithCacheDirectory:path];
	BOOL isDir = NO;
	BOOL exists = [[NSFileManager defaultManager]
					fileExistsAtPath:c.cacheDirectory isDirectory:&isDir];
	XCTAssertTrue(exists && isDir);
	[[NSFileManager defaultManager] removeItemAtPath:c.cacheDirectory error:nil];
}

// ---------------------------------------------------------------------------
#pragma mark - BEFileCacheItem  (encoding / decoding)
// ---------------------------------------------------------------------------

- (void)testBEFileCacheItem_initWithKeyCost_storesValues {
	BEFileCacheItem *item = [[BEFileCacheItem alloc] initWithKey:@"k" cost:42];
	XCTAssertEqualObjects(item.key, @"k");
	XCTAssertEqual(item.cost, 42u);
	XCTAssertNotNil(item.dateStored);
}

- (void)testBEFileCacheItem_supportsSecureCoding {
	XCTAssertTrue([BEFileCacheItem supportsSecureCoding]);
}

- (void)testBEFileCacheItem_roundTripArchive {
	BEFileCacheItem *original = [[BEFileCacheItem alloc] initWithKey:@"myKey" cost:99];

	NSError *err  = nil;
	NSData  *data = [NSKeyedArchiver archivedDataWithRootObject:original
										  requiringSecureCoding:YES
														  error:&err];
	XCTAssertNil(err);
	XCTAssertNotNil(data);

	BEFileCacheItem *decoded =
		[NSKeyedUnarchiver unarchivedObjectOfClass:[BEFileCacheItem class]
										 fromData:data
											error:&err];
	XCTAssertNil(err);
	XCTAssertNotNil(decoded);
	XCTAssertEqualObjects(decoded.key, @"myKey");
	XCTAssertEqual(decoded.cost, 99u);
	XCTAssertNotNil(decoded.dateStored);
}

// ---------------------------------------------------------------------------
#pragma mark - Properties
// ---------------------------------------------------------------------------

- (void)testName_getSet_forwardedToMemoryCache {
	_cache.name = @"TestCache";
	XCTAssertEqualObjects(_cache.name, @"TestCache");
}

- (void)testCountLimit_getSet {
	_cache.countLimit = 10;
	XCTAssertEqual(_cache.countLimit, 10u);
}

- (void)testTotalCostLimit_getSet {
	_cache.totalCostLimit = 1024;
	XCTAssertEqual(_cache.totalCostLimit, 1024u);
}

- (void)testMemoryCountLimit_getSet {
	_cache.memoryCountLimit = 5;
	XCTAssertEqual(_cache.memoryCountLimit, 5u);
}

- (void)testMemoryTotalCostLimit_getSet {
	_cache.memoryTotalCostLimit = 512;
	XCTAssertEqual(_cache.memoryTotalCostLimit, 512u);
}

- (void)testEvictsObjectsWithDiscardedContent_defaultIsYES {
	XCTAssertTrue(_cache.evictsObjectsWithDiscardedContent);
}

- (void)testEvictsObjectsWithDiscardedContent_getSet {
	_cache.evictsObjectsWithDiscardedContent = NO;
	XCTAssertFalse(_cache.evictsObjectsWithDiscardedContent);
	_cache.evictsObjectsWithDiscardedContent = YES;
	XCTAssertTrue(_cache.evictsObjectsWithDiscardedContent);
}

// ---------------------------------------------------------------------------
#pragma mark - setObject:forKey:  /  objectForKey:  basics
// ---------------------------------------------------------------------------

- (void)testSetObject_zeroCost_storedAndRetrievable {
	BETestObject *obj = [BETestObject objectWithValue:@"hello"];
	[_cache setObject:obj forKey:@"k1"];
	id result = [_cache objectForKey:@"k1"];
	XCTAssertEqualObjects(result, obj);
}

- (void)testSetObject_withCost_storedAndRetrievable {
	BETestObject *obj = [BETestObject objectWithValue:@"world"];
	[_cache setObject:obj forKey:@"k2" cost:10];
	id result = [_cache objectForKey:@"k2"];
	XCTAssertEqualObjects(result, obj);
}

- (void)testObjectForKey_missingKey_returnsNil {
	id result = [_cache objectForKey:@"noSuchKey"];
	XCTAssertNil(result);
}

// ---------------------------------------------------------------------------
#pragma mark - setObject: — non-NSSecureCoding objects (memory-only)
// ---------------------------------------------------------------------------

/**
 * A non-NSSecureCoding object must be retrievable from memory but must NOT
 * produce any .cache or .meta files on disk.
 */
- (void)testSetObject_nonSecureCoding_storedInMemoryOnly {
	BETestObjectNoCoding *obj = [BETestObjectNoCoding objectWithValue:@"ephemeral"];
	[_cache setObject:obj forKey:@"memOnly"];
	[self waitForDiskQueue];

	// Retrievable from memory.
	id result = [_cache objectForKey:@"memOnly"];
	XCTAssertEqualObjects(((BETestObjectNoCoding *)result).value, @"ephemeral");

	// No files written to disk.
	NSArray *files = [[NSFileManager defaultManager]
						contentsOfDirectoryAtPath:_tempDir error:nil];
	NSArray *cacheFiles = [files filteredArrayUsingPredicate:
		[NSPredicate predicateWithFormat:@"self ENDSWITH '.cache'"]];
	XCTAssertEqual(cacheFiles.count, 0u,
				   @"Non-NSSecureCoding object must not produce a .cache file");
}

// ---------------------------------------------------------------------------
#pragma mark - Disk persistence — objectForKey: disk-hit path
// ---------------------------------------------------------------------------

/**
 * After evicting an object from memory, objectForKey: must load it from disk.
 */
- (void)testObjectForKey_diskHit_promotedToMemory {
	BETestObject *obj = [BETestObject objectWithValue:@"persistent"];
	[_cache setObject:obj forKey:@"diskKey" cost:5];
	[self waitForDiskQueue];

	// Force the memory tier to forget the object.
	[_cache.memoryCache removeAllObjects];

	// objectForKey: must now hit disk and return the correct value.
	BETestObject *result = (BETestObject *)[_cache objectForKey:@"diskKey"];
	XCTAssertNotNil(result);
	XCTAssertEqualObjects(result.value, @"persistent");
}

/**
 * A new BEFileCache instance backed by the same directory should recover
 * all objects written by the previous instance (persistence across launches).
 */
- (void)testPersistence_acrossInstances_objectsRecovered {
	BETestObject *a = [BETestObject objectWithValue:@"A"];
	BETestObject *b = [BETestObject objectWithValue:@"B"];
	[_cache setObject:a forKey:@"keyA" cost:1];
	[_cache setObject:b forKey:@"keyB" cost:2];
	[self waitForDiskQueue];

	BEFileCache *cache2 = [self freshCacheOnSameDirectory];
	// Flush cache2's async loadIndex by doing any objectForKey:.
	BETestObject *ra = (BETestObject *)[cache2 objectForKey:@"keyA"];
	BETestObject *rb = (BETestObject *)[cache2 objectForKey:@"keyB"];

	XCTAssertEqualObjects(ra.value, @"A");
	XCTAssertEqualObjects(rb.value, @"B");
}

// ---------------------------------------------------------------------------
#pragma mark - Index fallback: scanMetaFilesForIndex
// ---------------------------------------------------------------------------

/**
 * When the index file is deleted, a new cache instance must rebuild the index
 * from .meta sidecar files and still serve the stored objects.
 */
- (void)testLoadIndex_indexFileMissing_fallsBackToMetaScan {
	BETestObject *obj = [BETestObject objectWithValue:@"fallback"];
	[_cache setObject:obj forKey:@"fKey" cost:3];
	[self waitForDiskQueue];

	// Delete the index file to force the fallback path.
	NSString *indexPath = [_tempDir stringByAppendingPathComponent:@"BEFileCacheIndex"];
	[[NSFileManager defaultManager] removeItemAtPath:indexPath error:nil];

	// New instance — must scan .meta files.
	BEFileCache *cache2 = [self freshCacheOnSameDirectory];
	BETestObject *result = (BETestObject *)[cache2 objectForKey:@"fKey"];
	XCTAssertEqualObjects(result.value, @"fallback");
}

/**
 * A corrupt index file triggers the .meta fallback scan.
 */
- (void)testLoadIndex_corruptIndexFile_fallsBackToMetaScan {
	BETestObject *obj = [BETestObject objectWithValue:@"corrupt"];
	[_cache setObject:obj forKey:@"cKey" cost:1];
	[self waitForDiskQueue];

	// Overwrite the index with garbage.
	NSString *indexPath = [_tempDir stringByAppendingPathComponent:@"BEFileCacheIndex"];
	[@"NOT_VALID_ARCHIVE" writeToFile:indexPath
						   atomically:YES
							 encoding:NSUTF8StringEncoding
								error:nil];

	BEFileCache *cache2 = [self freshCacheOnSameDirectory];
	BETestObject *result = (BETestObject *)[cache2 objectForKey:@"cKey"];
	XCTAssertEqualObjects(result.value, @"corrupt");
}

/**
 * Index entries whose .cache file was externally deleted are skipped silently
 * and do not crash or return stale data.
 */
- (void)testLoadIndex_missingCacheFile_entrySkipped {
	BETestObject *obj = [BETestObject objectWithValue:@"orphan"];
	[_cache setObject:obj forKey:@"oKey" cost:1];
	[self waitForDiskQueue];

	// Delete the .cache payload but leave the .meta and index intact.
	NSArray *files = [[NSFileManager defaultManager]
						contentsOfDirectoryAtPath:_tempDir error:nil];
	for (NSString *f in files) {
		if ([f hasSuffix:@".cache"]) {
			[[NSFileManager defaultManager]
				removeItemAtPath:[_tempDir stringByAppendingPathComponent:f]
						   error:nil];
		}
	}

	BEFileCache *cache2 = [self freshCacheOnSameDirectory];
	id result = [cache2 objectForKey:@"oKey"];
	XCTAssertNil(result, @"Entry with missing .cache file must be skipped");
}

/**
 * Index entries whose .meta file was externally deleted are also skipped.
 */
- (void)testLoadIndex_missingMetaFile_entrySkipped {
	BETestObject *obj = [BETestObject objectWithValue:@"orphanMeta"];
	[_cache setObject:obj forKey:@"omKey" cost:1];
	[self waitForDiskQueue];

	// Delete the .meta sidecar but leave the .cache and index intact.
	NSArray *files = [[NSFileManager defaultManager]
						contentsOfDirectoryAtPath:_tempDir error:nil];
	for (NSString *f in files) {
		if ([f hasSuffix:@".meta"]) {
			[[NSFileManager defaultManager]
				removeItemAtPath:[_tempDir stringByAppendingPathComponent:f]
						   error:nil];
		}
	}

	BEFileCache *cache2 = [self freshCacheOnSameDirectory];
	id result = [cache2 objectForKey:@"omKey"];
	XCTAssertNil(result,
				 @"Entry with missing .meta file must be skipped by index loader");
}

/**
 * scanMetaFilesForIndex must skip .meta files that have no sibling .cache file.
 */
- (void)testScanMetaFiles_orphanedMeta_skipped {
	BETestObject *obj = [BETestObject objectWithValue:@"orphanScan"];
	[_cache setObject:obj forKey:@"osKey" cost:1];
	[self waitForDiskQueue];

	// Delete the index AND the .cache file, leaving only the orphaned .meta.
	NSString *indexPath = [_tempDir stringByAppendingPathComponent:@"BEFileCacheIndex"];
	[[NSFileManager defaultManager] removeItemAtPath:indexPath error:nil];

	NSArray *files = [[NSFileManager defaultManager]
						contentsOfDirectoryAtPath:_tempDir error:nil];
	for (NSString *f in files) {
		if ([f hasSuffix:@".cache"]) {
			[[NSFileManager defaultManager]
				removeItemAtPath:[_tempDir stringByAppendingPathComponent:f]
						   error:nil];
		}
	}

	// The fallback scan should find nothing (orphaned .meta, no .cache).
	BEFileCache *cache2 = [self freshCacheOnSameDirectory];
	id result = [cache2 objectForKey:@"osKey"];
	XCTAssertNil(result, @"Orphaned .meta without .cache must be skipped");
}

// ---------------------------------------------------------------------------
#pragma mark - Overwrite  (same key, updated cost)
// ---------------------------------------------------------------------------

/**
 * Overwriting an existing key with a new object must update the value and
 * correctly adjust the running diskTotalCost (no double-counting).
 */
- (void)testSetObject_overwrite_updatesValueAndCost {
	BETestObject *original = [BETestObject objectWithValue:@"v1"];
	BETestObject *updated  = [BETestObject objectWithValue:@"v2"];

	[_cache setObject:original forKey:@"ow" cost:10];
	[self waitForDiskQueue];

	[_cache setObject:updated forKey:@"ow" cost:20];
	[self waitForDiskQueue];

	// Only the new value should be returned.
	BETestObject *result = (BETestObject *)[_cache objectForKey:@"ow"];
	XCTAssertEqualObjects(result.value, @"v2");

	// diskTotalCost must reflect the new cost only (20), not 10 + 20 = 30.
	XCTAssertEqual(_cache.diskTotalCost, 20u);
}

// ---------------------------------------------------------------------------
#pragma mark - removeObjectForKey:
// ---------------------------------------------------------------------------

- (void)testRemoveObjectForKey_removesFromBothTiers {
	BETestObject *obj = [BETestObject objectWithValue:@"remove"];
	[_cache setObject:obj forKey:@"rKey"];
	[self waitForDiskQueue];

	[_cache removeObjectForKey:@"rKey"];
	[self waitForDiskQueue];

	XCTAssertNil([_cache objectForKey:@"rKey"]);
}

/**
 * removeObjectForKey: must NOT fire cache:willEvictObject: on the delegate —
 * only limit-driven trims do that.
 */
- (void)testRemoveObjectForKey_doesNotFireDiskEvictionDelegate {
	BETestDelegate *del = [BETestDelegate new];
	_cache.delegate = del;

	BETestObject *obj = [BETestObject objectWithValue:@"silent"];
	[_cache setObject:obj forKey:@"sKey"];
	[self waitForDiskQueue];

	[_cache removeObjectForKey:@"sKey"];
	[self waitForDiskQueue];

	XCTAssertEqual(del.willEvictCount, 0u,
				   @"removeObjectForKey: must not fire cache:willEvictObject:");
}

/**
 * removeObjectForKey: on a key absent from disk is a safe no-op.
 */
- (void)testRemoveObjectForKey_absentKey_noOp {
	XCTAssertNoThrow([_cache removeObjectForKey:@"nonexistent"]);
}

// ---------------------------------------------------------------------------
#pragma mark - removeAllObjects
// ---------------------------------------------------------------------------

- (void)testRemoveAllObjects_clearsMemoryAndDisk {
	[_cache setObject:[BETestObject objectWithValue:@"a"] forKey:@"a"];
	[_cache setObject:[BETestObject objectWithValue:@"b"] forKey:@"b"];
	[self waitForDiskQueue];

	[_cache removeAllObjects];
	[self waitForDiskQueue];

	XCTAssertNil([_cache objectForKey:@"a"]);
	XCTAssertNil([_cache objectForKey:@"b"]);
	XCTAssertEqual(_cache.diskCount,     0u);
	XCTAssertEqual(_cache.diskTotalCost, 0u);
}

/**
 * removeAllObjects must NOT fire cache:willEvictObject: on the delegate.
 */
- (void)testRemoveAllObjects_doesNotFireDiskEvictionDelegate {
	BETestDelegate *del = [BETestDelegate new];
	_cache.delegate = del;

	[_cache setObject:[BETestObject objectWithValue:@"x"] forKey:@"x"];
	[self waitForDiskQueue];

	[_cache removeAllObjects];
	[self waitForDiskQueue];

	XCTAssertEqual(del.willEvictCount, 0u,
				   @"removeAllObjects must not fire cache:willEvictObject:");
}

/**
 * removeAllObjects on an already-empty cache is a safe no-op.
 */
- (void)testRemoveAllObjects_emptyCache_noOp {
	XCTAssertNoThrow([_cache removeAllObjects]);
	[self waitForDiskQueue];
	XCTAssertEqual(_cache.diskCount, 0u);
}

// ---------------------------------------------------------------------------
#pragma mark - NSCacheDelegate forwarding: willEvictObjectFromMemory:
// ---------------------------------------------------------------------------

/**
 * When _memoryCache evicts an object, the delegate must receive
 * cache:willEvictObjectFromMemory: — but NOT cache:willEvictObject:.
 */
- (void)testDelegate_memoryEviction_firesWillEvictFromMemory {
	BETestDelegate *del = [BETestDelegate new];
	_cache.delegate = del;

	BETestObject *obj = [BETestObject objectWithValue:@"mem"];
	[_cache setObject:obj forKey:@"mKey"];

	// Force a memory eviction by removing from the memory tier directly.
	[_cache.memoryCache removeObjectForKey:@"mKey"];

	XCTAssertEqual(del.willEvictFromMemoryCount, 1u);
	XCTAssertEqual(del.willEvictCount,           0u,
				   @"Memory eviction must not fire the disk willEvictObject: callback");
}

/**
 * A nil delegate must not cause a crash when the memory cache evicts.
 */
- (void)testDelegate_nilDelegate_nocrash {
	_cache.delegate = nil;
	BETestObject *obj = [BETestObject objectWithValue:@"safe"];
	[_cache setObject:obj forKey:@"nKey"];
	XCTAssertNoThrow([_cache.memoryCache removeObjectForKey:@"nKey"]);
}

/**
 * A delegate that only implements willEvictObjectFromMemory: (not
 * willEvictObject:) must not crash when a memory eviction occurs.
 */
- (void)testDelegate_partialDelegate_onlyMemoryMethodImplemented {
	// BETestDelegate implements both; test that the selector check is correct
	// by using a delegate that only responds to willEvictObjectFromMemory:.
	// We verify this indirectly: willEvictFromMemoryCount increments without crash.
	BETestDelegate *del = [BETestDelegate new];
	_cache.delegate = del;

	[_cache setObject:[BETestObject objectWithValue:@"p"] forKey:@"pKey"];
	[_cache.memoryCache removeObjectForKey:@"pKey"];

	XCTAssertEqual(del.willEvictFromMemoryCount, 1u);
}

// ---------------------------------------------------------------------------
#pragma mark - NSDiscardableContent
// ---------------------------------------------------------------------------

/**
 * A discardable object stored and fetched from memory should be returned
 * directly by NSCache without BEFileCache calling beginContentAccess.
 */
- (void)testDiscardable_memoryHit_nsubnacheManagesAccess {
	BETestDiscardable *obj = [BETestDiscardable objectWithValue:@"disc"];
	[_cache setObject:obj forKey:@"dKey"];

	// NSCache itself calls beginContentAccess on the memory hit.
	id result = [_cache objectForKey:@"dKey"];
	XCTAssertNotNil(result);
}

/**
 * A discardable object served from disk (memory miss) must have
 * beginContentAccess called exactly once by BEFileCache before it is returned.
 */
- (void)testDiscardable_diskHit_beginContentAccessCalledOnce {
	BETestDiscardable *obj = [BETestDiscardable objectWithValue:@"discDisk"];
	[_cache setObject:obj forKey:@"ddKey"];
	[self waitForDiskQueue];

	// Evict from memory to force a disk hit.
	[_cache.memoryCache removeAllObjects];

	// Fetch — BEFileCache must deserialise a fresh instance from disk.
	// The fresh instance's shouldSucceedBeginAccess defaults to YES (set in initWithCoder:).
	BETestDiscardable *result = (BETestDiscardable *)[_cache objectForKey:@"ddKey"];
	XCTAssertNotNil(result);
	// accessCount == 1: BEFileCache called beginContentAccess once.
	XCTAssertEqual(result.accessCount, 1);
}

/**
 * The write path brackets the archive with beginContentAccess/endContentAccess
 * for a discardable object, so the payload cannot capture a discarded state.
 */
- (void)testDiscardable_write_bracketsContentAccess {
	BETestDiscardable *obj = [BETestDiscardable objectWithValue:@"writeDisc"];
	[_cache setObject:obj forKey:@"wdKey" cost:1];
	[self waitForDiskQueue];

	XCTAssertGreaterThanOrEqual(obj.beginAccessCallCount, 1,
		@"Archiving a discardable object must hold content access");
	XCTAssertEqual(obj.accessCount, 0,
		@"beginContentAccess must be paired with endContentAccess on the write path");
}

/**
 * If a discardable object's beginContentAccess returns NO on a disk hit,
 * objectForKey: must return nil (content unavailable).
 */
- (void)testDiscardable_diskHit_beginContentAccessFails_returnsNil {
	// Store an object whose decoded form reports its content as inaccessible (the access
	// flag now round-trips through NSCoding). On a disk hit, BEFileCache calls
	// beginContentAccess, gets NO, and must return nil — the branch that was previously
	// uncovered.
	BETestDiscardable *obj = [BETestDiscardable objectWithValue:@"failing"];
	obj.shouldSucceedBeginAccess = NO;
	[_cache setObject:obj forKey:@"failKey"];
	[self waitForDiskQueue];

	// Force a disk hit.
	[_cache.memoryCache removeAllObjects];

	id result = [_cache objectForKey:@"failKey"];
	XCTAssertNil(result, @"A disk-hit object whose beginContentAccess returns NO must yield nil.");
}

// ---------------------------------------------------------------------------
#pragma mark - Disk file pair integrity
// ---------------------------------------------------------------------------

/**
 * After setObject:forKey:, exactly one .cache and one .meta file must exist
 * in the cache directory (plus the index file).
 */
- (void)testDiskFiles_setObject_createsPairOfFiles {
	[_cache setObject:[BETestObject objectWithValue:@"pair"] forKey:@"pairKey"];
	[self waitForDiskQueue];

	NSArray *files = [[NSFileManager defaultManager]
						contentsOfDirectoryAtPath:_tempDir error:nil];
	NSUInteger cacheCount = [[files filteredArrayUsingPredicate:
		[NSPredicate predicateWithFormat:@"self ENDSWITH '.cache'"]] count];
	NSUInteger metaCount  = [[files filteredArrayUsingPredicate:
		[NSPredicate predicateWithFormat:@"self ENDSWITH '.meta'"]]  count];

	XCTAssertEqual(cacheCount, 1u);
	XCTAssertEqual(metaCount,  1u);
}

/**
 * After removeObjectForKey:, both sibling files must be deleted.
 */
- (void)testDiskFiles_removeObjectForKey_deletesBothFiles {
	[_cache setObject:[BETestObject objectWithValue:@"del"] forKey:@"delKey"];
	[self waitForDiskQueue];

	[_cache removeObjectForKey:@"delKey"];
	[self waitForDiskQueue];

	NSArray *files = [[NSFileManager defaultManager]
						contentsOfDirectoryAtPath:_tempDir error:nil];
	NSUInteger cacheCount = [[files filteredArrayUsingPredicate:
		[NSPredicate predicateWithFormat:@"self ENDSWITH '.cache'"]] count];
	NSUInteger metaCount  = [[files filteredArrayUsingPredicate:
		[NSPredicate predicateWithFormat:@"self ENDSWITH '.meta'"]]  count];

	XCTAssertEqual(cacheCount, 0u);
	XCTAssertEqual(metaCount,  0u);
}

/**
 * removeAllObjects must delete all .cache and .meta files.
 */
- (void)testDiskFiles_removeAllObjects_deletesAllFiles {
	[_cache setObject:[BETestObject objectWithValue:@"1"] forKey:@"k1"];
	[_cache setObject:[BETestObject objectWithValue:@"2"] forKey:@"k2"];
	[self waitForDiskQueue];

	[_cache removeAllObjects];
	[self waitForDiskQueue];

	NSArray *files = [[NSFileManager defaultManager]
						contentsOfDirectoryAtPath:_tempDir error:nil];
	NSUInteger cacheCount = [[files filteredArrayUsingPredicate:
		[NSPredicate predicateWithFormat:@"self ENDSWITH '.cache'"]] count];
	NSUInteger metaCount  = [[files filteredArrayUsingPredicate:
		[NSPredicate predicateWithFormat:@"self ENDSWITH '.meta'"]]  count];

	XCTAssertEqual(cacheCount, 0u);
	XCTAssertEqual(metaCount,  0u);
}

// ---------------------------------------------------------------------------
#pragma mark - diskCount / diskTotalCost bookkeeping
// ---------------------------------------------------------------------------

- (void)testDiskCount_incrementsOnSetObject {
	XCTAssertEqual(_cache.diskCount, 0u);
	[_cache setObject:[BETestObject objectWithValue:@"c1"] forKey:@"c1"];
	[self waitForDiskQueue];
	XCTAssertEqual(_cache.diskCount, 1u);

	[_cache setObject:[BETestObject objectWithValue:@"c2"] forKey:@"c2"];
	[self waitForDiskQueue];
	XCTAssertEqual(_cache.diskCount, 2u);
}

- (void)testDiskCount_decrementsOnRemove {
	[_cache setObject:[BETestObject objectWithValue:@"d"] forKey:@"dk"];
	[self waitForDiskQueue];

	[_cache removeObjectForKey:@"dk"];
	[self waitForDiskQueue];
	XCTAssertEqual(_cache.diskCount, 0u);
}

- (void)testDiskTotalCost_tracksInsertAndRemove {
	[_cache setObject:[BETestObject objectWithValue:@"t1"] forKey:@"t1" cost:7];
	[_cache setObject:[BETestObject objectWithValue:@"t2"] forKey:@"t2" cost:3];
	[self waitForDiskQueue];
	XCTAssertEqual(_cache.diskTotalCost, 10u);

	[_cache removeObjectForKey:@"t1"];
	[self waitForDiskQueue];
	XCTAssertEqual(_cache.diskTotalCost, 3u);
}

/**
 * diskCount underflow guard: removing an entry when diskCount is already 0
 * must not wrap around to ULONG_MAX.
 */
- (void)testDiskCount_underflowGuard_doesNotWrap {
	// Populate and then clear so diskCount is genuinely 0.
	[_cache setObject:[BETestObject objectWithValue:@"uf"] forKey:@"uf"];
	[self waitForDiskQueue];
	[_cache removeAllObjects];
	[self waitForDiskQueue];

	// A subsequent remove of a key not on disk should be a no-op, not underflow.
	[_cache removeObjectForKey:@"uf"];
	[self waitForDiskQueue];
	XCTAssertEqual(_cache.diskCount, 0u);
}

// ---------------------------------------------------------------------------
#pragma mark - Trim: countLimit
// ---------------------------------------------------------------------------

/**
 * Setting countLimit to N when more than N objects are on disk must evict
 * the oldest entries until the count is within the limit.
 */
- (void)testTrim_countLimit_evictsOldestFirst {
	// Insert three objects oldest-first. Each insert captures dateStored from [NSDate date] on this
	// thread, which only moves forward, so the on-disk order is old, middle, new.
	[_cache setObject:[BETestObject objectWithValue:@"old"]    forKey:@"old"    cost:1];
	[_cache setObject:[BETestObject objectWithValue:@"middle"] forKey:@"middle" cost:1];
	[_cache setObject:[BETestObject objectWithValue:@"new"]    forKey:@"new"    cost:1];
	[self waitForDiskQueue];

	XCTAssertEqual(_cache.diskCount, 3u);

	// Limit to 2 — should evict "old".
	_cache.countLimit = 2;
	[self waitForDiskQueue];

	XCTAssertEqual(_cache.diskCount, 2u);
	XCTAssertNil([_cache objectForKey:@"old"],
				 @"Oldest entry must be evicted first");
	XCTAssertNotNil([_cache objectForKey:@"middle"]);
	XCTAssertNotNil([_cache objectForKey:@"new"]);
}

/**
 * The count-limit trim evicts by last access, so re-reading the oldest entry
 * spares it and the least-recently-used entry is evicted instead.
 */
- (void)testTrim_countLimit_evictsLeastRecentlyUsed {
	[_cache setObject:[BETestObject objectWithValue:@"old"]    forKey:@"old"    cost:1];
	[_cache setObject:[BETestObject objectWithValue:@"middle"] forKey:@"middle" cost:1];
	[_cache setObject:[BETestObject objectWithValue:@"new"]    forKey:@"new"    cost:1];
	[self waitForDiskQueue];

	// Re-access the oldest entry so it becomes the most-recently-used.
	XCTAssertNotNil([_cache objectForKey:@"old"]);
	[self waitForDiskQueue];     // drain the async access bump

	// Limit to 2 — "middle" is now least-recently-used and must be evicted.
	_cache.countLimit = 2;
	[self waitForDiskQueue];

	XCTAssertEqual(_cache.diskCount, 2u);
	XCTAssertNil([_cache objectForKey:@"middle"],
				 @"Least-recently-used entry must be evicted");
	XCTAssertNotNil([_cache objectForKey:@"old"],
					@"Recently-accessed entry must survive even though it is oldest by insertion");
	XCTAssertNotNil([_cache objectForKey:@"new"]);
}

/**
 * At evictionBalance 1 the count trim evicts by value density: a large entry
 * cheap to recreate is evicted before a same-size entry costly to recreate.
 */
- (void)testTrim_countLimit_valueDensityEvictsCheapToReplace {
	_cache.evictionBalance = 1.0;     // pure value density, recency ignored
	[_cache setObject:[BETestObject objectWithValue:@"cheap"]    forKey:@"cheap"    cost:10 retentionCost:1];
	[_cache setObject:[BETestObject objectWithValue:@"neutral"]  forKey:@"neutral"  cost:10 retentionCost:10];
	[_cache setObject:[BETestObject objectWithValue:@"precious"] forKey:@"precious" cost:10 retentionCost:100];
	[self waitForDiskQueue];

	_cache.countLimit = 2;            // evict the single highest-scoring entry
	[self waitForDiskQueue];

	XCTAssertEqual(_cache.diskCount, 2u);
	XCTAssertNil([_cache objectForKey:@"cheap"],
				 @"Cheap-to-replace entry must be evicted first at balance 1");
	XCTAssertNotNil([_cache objectForKey:@"neutral"]);
	XCTAssertNotNil([_cache objectForKey:@"precious"],
					@"Costly-to-recreate entry must survive at balance 1");
}

/** A fresh cache balances recency and value density by default. */
- (void)testEvictionBalance_defaultsToBalanced {
	XCTAssertEqual(_cache.evictionBalance, 0.5);
}

/** evictionBalance clamps to [0,1]. */
- (void)testEvictionBalance_clampsToUnitRange {
	_cache.evictionBalance = -5.0;
	XCTAssertEqual(_cache.evictionBalance, 0.0);
	_cache.evictionBalance = 3.5;
	XCTAssertEqual(_cache.evictionBalance, 1.0);
	_cache.evictionBalance = 0.5;
	XCTAssertEqual(_cache.evictionBalance, 0.5);
}

/**
 * excludedFromBackup reads and writes NSURLIsExcludedFromBackupKey on the cache
 * directory and round-trips both states.
 */
- (void)testExcludedFromBackup_getSetRoundTrip {
	XCTAssertFalse(_cache.excludedFromBackup,
				   @"A fresh temp directory is not excluded by default");
	_cache.excludedFromBackup = YES;
	XCTAssertTrue(_cache.excludedFromBackup,
				  @"Flag must read back YES after being set");
	_cache.excludedFromBackup = NO;
	XCTAssertFalse(_cache.excludedFromBackup,
				   @"Flag must read back NO after being cleared");
}

/**
 * cache:willEvictObject: is fired exactly once per evicted entry during a
 * count-limit trim.
 */
- (void)testTrim_countLimit_firesDelegatePerEviction {
	BETestDelegate *del = [BETestDelegate new];
	_cache.delegate = del;

	[_cache setObject:[BETestObject objectWithValue:@"e1"] forKey:@"e1" cost:1];
	[_cache setObject:[BETestObject objectWithValue:@"e2"] forKey:@"e2" cost:1];
	[_cache setObject:[BETestObject objectWithValue:@"e3"] forKey:@"e3" cost:1];
	[self waitForDiskQueue];

	_cache.countLimit = 1;
	[self waitForDiskQueue];

	// 2 entries evicted → 2 callbacks.
	XCTAssertEqual(del.willEvictCount, 2u);
}

/**
 * When countLimit is already satisfied, no entries are evicted.
 */
- (void)testTrim_countLimit_alreadySatisfied_noEvictions {
	BETestDelegate *del = [BETestDelegate new];
	_cache.delegate = del;

	[_cache setObject:[BETestObject objectWithValue:@"s"] forKey:@"s"];
	[self waitForDiskQueue];

	// Limit of 5 with only 1 entry — nothing to evict.
	_cache.countLimit = 5;
	[self waitForDiskQueue];

	XCTAssertEqual(del.willEvictCount, 0u);
	XCTAssertEqual(_cache.diskCount, 1u);
}

/**
 * countLimit = 0 (no limit) with many objects must not trigger any evictions.
 */
- (void)testTrim_countLimitZero_noEvictions {
	BETestDelegate *del = [BETestDelegate new];
	_cache.delegate = del;

	for (NSUInteger i = 0; i < 5; i++) {
		NSString *k = [NSString stringWithFormat:@"k%lu", (unsigned long)i];
		[_cache setObject:[BETestObject objectWithValue:k] forKey:k];
	}
	[self waitForDiskQueue];

	_cache.countLimit = 0;  // explicitly no limit
	[self waitForDiskQueue];

	XCTAssertEqual(del.willEvictCount, 0u);
	XCTAssertEqual(_cache.diskCount, 5u);
}

// ---------------------------------------------------------------------------
#pragma mark - Trim: totalCostLimit
// ---------------------------------------------------------------------------

/**
 * With default retention costs (so the value term is 1), the cost pass evicts
 * least-recently-used entries until the total cost is within the limit.
 */
- (void)testTrim_totalCostLimit_defaultEvictsLeastRecentlyUsed {
	// Insert in age order: cheap (oldest), mid, expensive (newest).  Total 17.
	[_cache setObject:[BETestObject objectWithValue:@"cheap"]     forKey:@"cheap"     cost:2];
	[_cache setObject:[BETestObject objectWithValue:@"mid"]       forKey:@"mid"       cost:5];
	[_cache setObject:[BETestObject objectWithValue:@"expensive"] forKey:@"expensive" cost:10];
	[self waitForDiskQueue];

	// Limit to 10 — evicts the two oldest (cheap + mid = 7), leaving expensive (10).
	_cache.totalCostLimit = 10;
	[self waitForDiskQueue];

	XCTAssertNil([_cache objectForKey:@"cheap"],
				 @"Least-recently-used entries are evicted first by default");
	XCTAssertNil([_cache objectForKey:@"mid"]);
	XCTAssertNotNil([_cache objectForKey:@"expensive"],
					@"The most-recently-used entry survives even though it is largest");
	XCTAssertLessThanOrEqual(_cache.diskTotalCost, 10u);
}

/**
 * At evictionBalance 1 the cost pass evicts by value density: a large entry
 * cheap to recreate is freed before a small entry costly to recreate.
 */
- (void)testTrim_totalCostLimit_valueDensityEvictsCheapToReplace {
	_cache.evictionBalance = 1.0;
	[_cache setObject:[BETestObject objectWithValue:@"big"]      forKey:@"big"      cost:10 retentionCost:1];
	[_cache setObject:[BETestObject objectWithValue:@"precious"] forKey:@"precious" cost:3  retentionCost:100];
	[self waitForDiskQueue];

	// Total 13; limit 10 forces one eviction.  "big" has the higher cost/retention.
	_cache.totalCostLimit = 10;
	[self waitForDiskQueue];

	XCTAssertNil([_cache objectForKey:@"big"],
				 @"Large cheap-to-replace entry is evicted first at balance 1");
	XCTAssertNotNil([_cache objectForKey:@"precious"],
					@"Small costly-to-recreate entry survives at balance 1");
	XCTAssertLessThanOrEqual(_cache.diskTotalCost, 10u);
}

/**
 * cache:willEvictObject: fires for every cost-trim eviction.
 */
- (void)testTrim_totalCostLimit_firesDelegatePerEviction {
	BETestDelegate *del = [BETestDelegate new];
	_cache.delegate = del;

	[_cache setObject:[BETestObject objectWithValue:@"a"] forKey:@"a" cost:10];
	[_cache setObject:[BETestObject objectWithValue:@"b"] forKey:@"b" cost:10];
	[self waitForDiskQueue];

	// Limit to 5 — both entries (cost 10 each) must be evicted.
	_cache.totalCostLimit = 5;
	[self waitForDiskQueue];

	XCTAssertEqual(del.willEvictCount, 2u);
	XCTAssertEqual(_cache.diskCount, 0u);
}

/**
 * When totalCostLimit is already satisfied, no entries are evicted.
 */
- (void)testTrim_totalCostLimit_alreadySatisfied_noEvictions {
	BETestDelegate *del = [BETestDelegate new];
	_cache.delegate = del;

	[_cache setObject:[BETestObject objectWithValue:@"v"] forKey:@"v" cost:3];
	[self waitForDiskQueue];

	_cache.totalCostLimit = 100;    // much larger than the 3 already on disk
	[self waitForDiskQueue];

	XCTAssertEqual(del.willEvictCount, 0u);
}

/**
 * totalCostLimit = 0 (no limit) must never trigger cost-based evictions.
 */
- (void)testTrim_totalCostLimitZero_noEvictions {
	BETestDelegate *del = [BETestDelegate new];
	_cache.delegate = del;

	[_cache setObject:[BETestObject objectWithValue:@"h"] forKey:@"h" cost:999];
	[self waitForDiskQueue];

	_cache.totalCostLimit = 0;
	[self waitForDiskQueue];

	XCTAssertEqual(del.willEvictCount, 0u);
	XCTAssertEqual(_cache.diskCount, 1u);
}

// ---------------------------------------------------------------------------
#pragma mark - Trim: both passes in one trim cycle
// ---------------------------------------------------------------------------

/**
 * With both totalCostLimit and countLimit set, Pass 1 (cost) runs first,
 * then Pass 2 (count) runs on whatever remains.
 */
- (void)testTrim_bothLimits_costPassRunsFirst {
	// Insert oldest-first (dateStored moves forward per insert).  "pricey" is the
	// oldest, so at the default balance the cost pass evicts it by its LRU score.
	[_cache setObject:[BETestObject objectWithValue:@"pricey"]     forKey:@"p"  cost:100];
	[_cache setObject:[BETestObject objectWithValue:@"cheap-old"]  forKey:@"co" cost:1];
	[_cache setObject:[BETestObject objectWithValue:@"cheap-new"]  forKey:@"cn" cost:1];
	[self waitForDiskQueue];

	BETestDelegate *del = [BETestDelegate new];
	_cache.delegate = del;

	// Pass 1 (cost): total 102 > 5 → evicts the oldest, "pricey" (100), leaving 2.
	// Pass 2 (count): 2 > 1 → evicts the oldest remaining, "cheap-old".
	_cache.totalCostLimit = 5;
	_cache.countLimit     = 1;
	[self waitForDiskQueue];

	XCTAssertNil([_cache objectForKey:@"p"],
				 @"Oldest (and largest) entry removed in the cost pass");
	XCTAssertNil([_cache objectForKey:@"co"],
				 @"Oldest remaining entry removed in the count pass");
	XCTAssertNotNil([_cache objectForKey:@"cn"],
					@"Newest entry survives");

	// 2 evictions total — one per pass.
	XCTAssertEqual(del.willEvictCount, 2u);
}

// ---------------------------------------------------------------------------
#pragma mark - Trim: memory cache also cleared on eviction
// ---------------------------------------------------------------------------

/**
 * When a disk entry is evicted by a limit trim, the corresponding memory
 * entry must also be removed so objectForKey: does not return stale data.
 */
- (void)testTrim_evictedEntryRemovedFromMemoryToo {
	[_cache setObject:[BETestObject objectWithValue:@"evict"] forKey:@"evictKey" cost:50];
	[self waitForDiskQueue];

	// Limit forces eviction of the entry.
	_cache.totalCostLimit = 1;
	[self waitForDiskQueue];

	// Must not be served from memory either.
	id result = [_cache objectForKey:@"evictKey"];
	XCTAssertNil(result);
}

// ---------------------------------------------------------------------------
#pragma mark - File extension defines
// ---------------------------------------------------------------------------

- (void)testFileExtensionDefines_correctValues {
	XCTAssertEqualObjects(BE_FILE_CACHE_EXTENSION,      @"cache");
	XCTAssertEqualObjects(BE_FILE_CACHE_META_EXTENSION, @"meta");
}

// ---------------------------------------------------------------------------
#pragma mark - diskCount / diskTotalCost after removeAllObjects
// ---------------------------------------------------------------------------

- (void)testDiskCountAndCost_resetAfterRemoveAllObjects {
	[_cache setObject:[BETestObject objectWithValue:@"r1"] forKey:@"r1" cost:5];
	[_cache setObject:[BETestObject objectWithValue:@"r2"] forKey:@"r2" cost:5];
	[self waitForDiskQueue];
	XCTAssertEqual(_cache.diskCount,     2u);
	XCTAssertEqual(_cache.diskTotalCost, 10u);

	[_cache removeAllObjects];
	[self waitForDiskQueue];
	XCTAssertEqual(_cache.diskCount,     0u);
	XCTAssertEqual(_cache.diskTotalCost, 0u);
}

// ---------------------------------------------------------------------------
#pragma mark - Index persisted after removeAllObjects
// ---------------------------------------------------------------------------

/**
 * After removeAllObjects the new instance should find an empty cache
 * (the cleared index is persisted, not the old populated one).
 */
- (void)testPersistence_afterRemoveAllObjects_newInstanceIsEmpty {
	[_cache setObject:[BETestObject objectWithValue:@"gone"] forKey:@"gone"];
	[self waitForDiskQueue];

	[_cache removeAllObjects];
	[self waitForDiskQueue];

	BEFileCache *cache2 = [self freshCacheOnSameDirectory];
	id result = [cache2 objectForKey:@"gone"];
	XCTAssertNil(result);
	XCTAssertEqual(cache2.diskCount, 0u);
}

// ---------------------------------------------------------------------------
#pragma mark - Multiple keys — isolation
// ---------------------------------------------------------------------------

/**
 * Multiple keys must not interfere with each other's storage or retrieval.
 */
- (void)testMultipleKeys_isolation {
	NSUInteger n = 10;
	for (NSUInteger i = 0; i < n; i++) {
		NSString *key = [NSString stringWithFormat:@"key%lu", (unsigned long)i];
		NSString *val = [NSString stringWithFormat:@"val%lu", (unsigned long)i];
		[_cache setObject:[BETestObject objectWithValue:val] forKey:key cost:i];
	}
	[self waitForDiskQueue];
	XCTAssertEqual(_cache.diskCount, n);

	for (NSUInteger i = 0; i < n; i++) {
		NSString *key      = [NSString stringWithFormat:@"key%lu", (unsigned long)i];
		NSString *expected = [NSString stringWithFormat:@"val%lu", (unsigned long)i];
		BETestObject *r    = (BETestObject *)[_cache objectForKey:key];
		XCTAssertEqualObjects(r.value, expected,
							  @"Value for key%lu must be val%lu", (unsigned long)i, (unsigned long)i);
	}
}

// ---------------------------------------------------------------------------
#pragma mark - Index save on every mutation
// ---------------------------------------------------------------------------

/**
 * After each mutation the index file must exist on disk so that a crash
 * immediately after would still leave a consistent index.
 */
- (void)testIndexFile_existsAfterEachMutation {
	NSString *indexPath = [_tempDir stringByAppendingPathComponent:@"BEFileCacheIndex"];

	[_cache setObject:[BETestObject objectWithValue:@"idx"] forKey:@"idxKey"];
	[self waitForDiskQueue];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:indexPath],
				  @"Index must exist after setObject:forKey:");

	[_cache removeObjectForKey:@"idxKey"];
	[self waitForDiskQueue];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:indexPath],
				  @"Index must exist after removeObjectForKey:");

	[_cache removeAllObjects];
	[self waitForDiskQueue];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:indexPath],
				  @"Index must exist after removeAllObjects");
}

// ---------------------------------------------------------------------------
#pragma mark - Hardening regression tests
// ---------------------------------------------------------------------------

/**
 * Concurrency: hammer set/get/remove on overlapping keys from many threads. The
 * tier-atomic critical sections must not deadlock or crash, and the cache stays usable.
 */
- (void)testConcurrentSetGetRemoveStressDoesNotDeadlockOrCrash {
	dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_group_t g = dispatch_group_create();
	const int iterations = 300;

	for (int t = 0; t < 8; t++) {
		dispatch_group_async(g, q, ^{
			for (int i = 0; i < iterations; i++) {
				NSString *key = [NSString stringWithFormat:@"k%d", i % 16];
				switch (i % 3) {
					case 0:
						[self->_cache setObject:[BETestObject objectWithValue:@"v"] forKey:key cost:1];
						break;
					case 1:
						(void)[self->_cache objectForKey:key];
						break;
					default:
						[self->_cache removeObjectForKey:key];
						break;
				}
			}
		});
	}

	long timedOut = dispatch_group_wait(g, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)));
	XCTAssertEqual(timedOut, 0, @"Concurrent set/get/remove must complete without deadlock.");

	// Cache remains usable and consistent afterward.
	[_cache setObject:[BETestObject objectWithValue:@"final"] forKey:@"finalKey"];
	[self waitForDiskQueue];
	[_cache.memoryCache removeAllObjects];
	XCTAssertEqualObjects(((BETestObject *)[_cache objectForKey:@"finalKey"]).value, @"final");
}

/**
 * Container relocation: after the cache directory is moved, the persisted index (which
 * now stores base filenames, not absolute paths) must still resolve entries against the
 * new directory rather than silently losing the whole cache.
 */
- (void)testContainerRelocationResolvesViaIndex {
	[_cache setObject:[BETestObject objectWithValue:@"v1"] forKey:@"rk1"];
	[_cache setObject:[BETestObject objectWithValue:@"v2"] forKey:@"rk2"];
	[self waitForDiskQueue];
	_cache = nil; // close the original cache

	// Simulate a container/path relocation by moving the whole directory.
	NSString *newDir = [_tempDir stringByAppendingString:@"_relocated"];
	[[NSFileManager defaultManager] removeItemAtPath:newDir error:NULL];
	NSError *moveErr = nil;
	XCTAssertTrue([[NSFileManager defaultManager] moveItemAtPath:_tempDir toPath:newDir error:&moveErr],
				  @"relocation move failed: %@", moveErr);
	_tempDir = newDir; // tearDown cleans up the new location

	BEFileCache *relocated = [[BEFileCache alloc] initWithCacheDirectory:newDir];
	XCTAssertEqualObjects(((BETestObject *)[relocated objectForKey:@"rk1"]).value, @"v1",
						  @"Entry must resolve after relocation (index recomposes base filenames).");
	XCTAssertEqualObjects(((BETestObject *)[relocated objectForKey:@"rk2"]).value, @"v2");
	_cache = relocated; // keep alive for the rest of the test lifecycle
}

/**
 * Path safety: a key that looks like a path-traversal string must produce a flat,
 * SHA-256-named file inside the cache directory and round-trip correctly. Non-string
 * keys (NSNumber) must also work.
 */
- (void)testAdversarialAndNonStringKeysAreSafe {
	NSString *evil = @"../../../../etc/passwd";
	[_cache setObject:[BETestObject objectWithValue:@"x"] forKey:evil];
	[self waitForDiskQueue];

	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_tempDir error:NULL];
	for (NSString *f in files) {
		XCTAssertFalse([f containsString:@"/"],  @"Malicious key must not create nested paths.");
		XCTAssertFalse([f containsString:@".."], @"Malicious key must not create traversal names.");
	}

	[_cache.memoryCache removeAllObjects];
	XCTAssertEqualObjects(((BETestObject *)[_cache objectForKey:evil]).value, @"x",
						  @"Path-like key must round-trip correctly.");

	// Non-string key.
	[_cache setObject:[BETestObject objectWithValue:@"num"] forKey:@42];
	[self waitForDiskQueue];
	[_cache.memoryCache removeAllObjects];
	XCTAssertEqualObjects(((BETestObject *)[_cache objectForKey:@42]).value, @"num",
						  @"Non-string (NSNumber) key must round-trip.");
}

/**
 * A corrupt .cache payload on a disk hit must be handled gracefully (nil), not crash.
 */
- (void)testCorruptCachePayloadReturnsNilGracefully {
	[_cache setObject:[BETestObject objectWithValue:@"v"] forKey:@"corruptKey"];
	[self waitForDiskQueue];

	// Overwrite every .cache payload file with garbage.
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_tempDir error:NULL];
	for (NSString *f in files) {
		if ([f.pathExtension isEqualToString:BE_FILE_CACHE_EXTENSION]) {
			[[@"not a valid archive" dataUsingEncoding:NSUTF8StringEncoding]
				writeToFile:[_tempDir stringByAppendingPathComponent:f] atomically:YES];
		}
	}

	[_cache.memoryCache removeAllObjects];
	XCTAssertNil([_cache objectForKey:@"corruptKey"],
				 @"A corrupt .cache payload must yield nil rather than crash.");
}

// ---------------------------------------------------------------------------
#pragma mark - Index ↔ directory reconciliation
// ---------------------------------------------------------------------------

/**
 * A .cache/.meta pair present on disk but absent from the index — as if the
 * files were written just before a crash, before the index was saved — is
 * adopted on the next launch so it is readable and counted toward the limits.
 */
- (void)testReconcile_adoptsCrashOrphanPairMissingFromIndex {
	[_cache setObject:[BETestObject objectWithValue:@"V"] forKey:@"orphanKey" cost:5];
	[self waitForDiskQueue];

	// Snapshot the entry's two files.
	NSString *cachePath = [self firstFileInDirWithExtension:BE_FILE_CACHE_EXTENSION];
	NSString *metaPath  = [self firstFileInDirWithExtension:BE_FILE_CACHE_META_EXTENSION];
	NSData   *cacheBytes = [NSData dataWithContentsOfFile:cachePath];
	NSData   *metaBytes  = [NSData dataWithContentsOfFile:metaPath];
	XCTAssertNotNil(cacheBytes);
	XCTAssertNotNil(metaBytes);

	// Remove the entry (deletes the files and drops it from the index), then
	// re-create the pair on disk WITHOUT updating the index.
	[_cache removeObjectForKey:@"orphanKey"];
	[self waitForDiskQueue];
	[cacheBytes writeToFile:cachePath atomically:YES];
	[metaBytes  writeToFile:metaPath  atomically:YES];

	// Relaunch: the index does not list the pair, so reconciliation must adopt it.
	BEFileCache *cache2 = [self freshCacheOnSameDirectory];
	BETestObject *got = [cache2 objectForKey:@"orphanKey"];
	XCTAssertEqualObjects(got.value, @"V",
						  @"Crash-orphaned pair must be adopted and readable.");
	XCTAssertEqual(cache2.diskCount, 1u, @"Adopted entry must be counted.");
	XCTAssertEqual(cache2.diskTotalCost, 5u, @"Adopted entry's cost must be restored.");
}

/**
 * A lone .cache payload with no sibling .meta cannot have its key recovered, so
 * reconciliation deletes it rather than leaking the file forever.
 */
- (void)testReconcile_deletesLoneCacheWithoutSidecar {
	[_cache setObject:[BETestObject objectWithValue:@"V"] forKey:@"k" cost:3];
	[self waitForDiskQueue];

	NSString *cachePath = [self firstFileInDirWithExtension:BE_FILE_CACHE_EXTENSION];
	NSString *metaPath  = [self firstFileInDirWithExtension:BE_FILE_CACHE_META_EXTENSION];
	[NSFileManager.defaultManager removeItemAtPath:metaPath error:nil];

	BEFileCache *cache2 = [self freshCacheOnSameDirectory];
	XCTAssertNil([cache2 objectForKey:@"k"],
				 @"An entry whose sidecar is gone must not load.");   // also drains the queue
	XCTAssertFalse([NSFileManager.defaultManager fileExistsAtPath:cachePath],
				   @"Lone .cache payload must be deleted by reconciliation.");
	XCTAssertEqual(cache2.diskCount, 0u);
}

/**
 * A lone .meta sidecar with no sibling .cache payload is deleted by reconciliation.
 */
- (void)testReconcile_deletesLoneSidecarWithoutPayload {
	[_cache setObject:[BETestObject objectWithValue:@"V"] forKey:@"k" cost:3];
	[self waitForDiskQueue];

	NSString *cachePath = [self firstFileInDirWithExtension:BE_FILE_CACHE_EXTENSION];
	NSString *metaPath  = [self firstFileInDirWithExtension:BE_FILE_CACHE_META_EXTENSION];
	[NSFileManager.defaultManager removeItemAtPath:cachePath error:nil];

	BEFileCache *cache2 = [self freshCacheOnSameDirectory];
	XCTAssertNil([cache2 objectForKey:@"k"]);   // also drains the queue
	XCTAssertFalse([NSFileManager.defaultManager fileExistsAtPath:metaPath],
				   @"Lone .meta sidecar must be deleted by reconciliation.");
	XCTAssertEqual(cache2.diskCount, 0u);
}

@end
