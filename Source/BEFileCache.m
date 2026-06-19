/**
 * BEFileCache.m
 *
 * Memory-eviction delegate
 * ────────────────────────
 *   BEFileCache registers itself as _memoryCache's NSCacheDelegate.  The sole
 *   purpose is to forward cache:willEvictObject: to the caller's delegate as
 *   cache:willEvictObjectFromMemory:.  No disk I/O is performed in response —
 *   the object is already safely on disk (or was never serialisable and was
 *   always memory-only, in which case it is simply gone).
 *
 * Private method naming
 * ─────────────────────
 *   Private methods carry no prefix.  Following Apple's own convention in
 *   open-source frameworks (WebKit, JavaScriptCore, objc runtime), privacy is
 *   communicated by the class extension declaration alone:
 *
 *     @interface BEFileCache () … @end
 *
 *   Apple explicitly reserves the leading-underscore prefix for their own
 *   frameworks, so it must not be used in application or library code.
 *
 * Disk trim order  (mirrors NSCache)
 * ───────────────────────────────────
 *   NSCache trims by cost first (to bring total cost under totalCostLimit) then
 *   by count.  We keep that two-pass order, but both passes evict by one
 *   eviction score (recency, optionally weighted by value density) rather than
 *   blindly by cost or insertion age.
 *
 *   Pass 1 — cost:   remove highest-score-first until totalCostLimit met.
 *   Pass 2 — count:  remove highest-score-first until countLimit met.
 */

#import "BEFileCache.h"
#import <CommonCrypto/CommonDigest.h>

// ---------------------------------------------------------------------------
#pragma mark - BEFileCacheItem  (metadata only — no object payload)
// ---------------------------------------------------------------------------

// NSCoder archive keys for BEFileCacheItem.  Private to this translation unit;
// changing them would invalidate existing on-disk .meta files.
static NSString * const kItemKey       = @"key";
static NSString * const kItemCost      = @"cost";
static NSString * const kItemRetention = @"retentionCost";   // absent in pre-1.1 .meta files
static NSString * const kItemDate      = @"dateStored";

@implementation BEFileCacheItem

+ (BOOL)supportsSecureCoding { return YES; }

- (instancetype)initWithKey:(id<NSCopying, NSSecureCoding>)key
					   cost:(NSUInteger)cost {
	return [self initWithKey:key cost:cost retentionCost:cost];
}

- (instancetype)initWithKey:(id<NSCopying, NSSecureCoding>)key
					   cost:(NSUInteger)cost
			  retentionCost:(NSUInteger)retentionCost {
	if ((self = [super init])) {
		_key           = key;
		_cost          = cost;
		_retentionCost = retentionCost;
		_dateStored    = [NSDate date];   // wall-clock insertion time
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		// Accept any NSSecureCoding-conforming class for the key; callers are
		// responsible for using well-known Foundation key types.
		NSSet *any  = [NSSet setWithArray:@[NSString.class, NSNumber.class, NSDate.class, NSData.class, NSArray.class, NSDictionary.class, NSNull.class]];
		_key        = [coder decodeObjectOfClasses:any forKey:kItemKey];
		_cost       = (NSUInteger)[coder decodeIntegerForKey:kItemCost];
		// Pre-1.1 .meta files have no retentionCost; default it to cost.
		_retentionCost = [coder containsValueForKey:kItemRetention]
			? (NSUInteger)[coder decodeIntegerForKey:kItemRetention]
			: _cost;
		_dateStored = [coder decodeObjectOfClass:[NSDate class] forKey:kItemDate];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:(id)_key                   forKey:kItemKey];
	[coder encodeInteger:(NSInteger)_cost          forKey:kItemCost];
	[coder encodeInteger:(NSInteger)_retentionCost forKey:kItemRetention];
	[coder encodeObject:_dateStored                forKey:kItemDate];
}

@end

// ---------------------------------------------------------------------------
#pragma mark - Constants
// ---------------------------------------------------------------------------

// ── _diskMeta entry keys ──────────────────────────────────────────────────────
// These keys exist only in the in-memory _diskMeta dictionary and are never
// written to disk.  They provide named access to each per-entry NSDictionary
// slot while keeping the code readable and refactor-safe.

static NSString * const kMetaKey        = @"key";         // original key object
static NSString * const kMetaCost       = @"cost";        // NSNumber(NSUInteger)
static NSString * const kMetaRetention  = @"retention";   // NSNumber(NSUInteger) — replacement cost
static NSString * const kMetaDate       = @"date";        // NSDate — insertion time
static NSString * const kMetaAccess     = @"access";      // NSDate — last access (in-RAM live LRU)
static NSString * const kMetaObjectFile = @"objectFile";  // NSString — absolute .cache path
static NSString * const kMetaMetaFile   = @"metaFile";    // NSString — absolute .meta path
static NSString * const kMetaScore      = @"score";       // NSNumber(double) — transient eviction score

// ── BEFileCacheIndex entry keys ───────────────────────────────────────────────
// These keys appear inside each entry dictionary in the on-disk index archive.
// Changing them would invalidate existing BEFileCacheIndex files.

static NSString * const kIdxKeyData     = @"keyData";     // NSData — archived key object
static NSString * const kIdxCost        = @"cost";        // NSNumber
static NSString * const kIdxRetention   = @"retention";   // NSNumber — replacement cost (absent in pre-1.1 indexes)
static NSString * const kIdxDate        = @"date";        // NSDate — insertion time
static NSString * const kIdxAccess      = @"access";      // NSDate — last access (absent in pre-1.1 indexes)
static NSString * const kIdxObjectFile  = @"objectFile";  // NSString — absolute path
static NSString * const kIdxMetaFile    = @"metaFile";    // NSString — absolute path

/** Name of the index file stored inside cacheDirectory. */
static NSString * const kIndexFileName  = @"BEFileCacheIndex";

/**
 * Returns the singleton set of Foundation classes permitted when unarchiving
 * the BEFileCacheIndex file.  Covers every concrete type written into index
 * entry dictionaries: NSArray, NSDictionary, NSData, NSString, NSNumber, NSDate.
 *
 * @return A lazily-initialised, shared NSSet of Class objects.
 */
static NSSet<Class> *BEIndexAllowedClasses(void) {
	static NSSet          *s;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		s = [NSSet setWithObjects:
			 [NSArray      class],
			 [NSDictionary class],
			 [NSData       class],
			 [NSString     class],
			 [NSNumber     class],
			 [NSDate       class],
			 nil];
	});
	return s;
}

// ---------------------------------------------------------------------------
#pragma mark - BEFileCache private interface
// ---------------------------------------------------------------------------

@interface BEFileCache () <NSCacheDelegate>

/**
 * Private memory speed tier.  All NSCache properties remain at their defaults.
 * BEFileCache is its NSCacheDelegate solely to intercept cache:willEvictObject:
 * and forward it as cache:willEvictObjectFromMemory: to the caller's delegate.
 */
@property (strong, nonatomic) NSCache *memoryCache;

/**
 * In-process mirror of the directory's NSURLIsExcludedFromBackupKey value.
 * @c nil until first read.  NSURL caches resource values, so a fresh read can
 * return a stale flag right after a set; this is the authoritative value after a
 * successful set and is seeded from disk on first access.  Guarded by @c self.
 */
@property (strong, nonatomic) NSNumber *excludedFromBackupCache;

/**
 * In-memory index of every entry currently on disk.
 *
 * Structure: @{ <key> : @{ kMetaKey, kMetaCost, kMetaDate,
 *                           kMetaObjectFile, kMetaMetaFile } }
 *
 * @warning Must only be accessed on diskQueue.
 */
@property (strong, nonatomic) NSMutableDictionary *diskMeta;

/**
 * Serial GCD queue that serialises all disk I/O and diskMeta mutations.
 * Using a serial queue removes the need for explicit locks on disk state.
 */
@property (strong, nonatomic) dispatch_queue_t diskQueue;

/**
 * Running count of entries currently persisted on disk.
 *
 * @warning Mutated only on diskQueue.
 */
@property (assign, nonatomic) NSUInteger diskCount;

/**
 * Running sum of the costs of all entries currently on disk.
 *
 * @warning Mutated only on diskQueue.
 */
@property (assign, nonatomic) NSUInteger diskTotalCost;

/** Mutable backing store for the readonly public cacheDirectory property. */
@property (copy, nonatomic, readwrite) NSString *cacheDirectory;

@end

// ---------------------------------------------------------------------------
#pragma mark - Filename helpers
// ---------------------------------------------------------------------------

/**
 * @abstract
 *   Returns the SHA-256 hex digest of the NSKeyedArchiver bytes of @p key,
 *   used as the shared base filename for an entry's paired .cache and .meta
 *   files.
 *
 * @discussion
 *   Archiving the key object — rather than using its @c -description string or
 *   @c -hash integer — guarantees three properties that are essential for a
 *   persistent cache:
 *
 *   - **Stability**: the same key value archives to the same bytes on every
 *     launch and every device, so the filename is always reproducible.
 *   - **Uniqueness**: two keys that satisfy @c !isEqual: produce different
 *     archives and therefore different digests.
 *   - **Filesystem safety**: the 64-character lowercase hex string contains
 *     only @c [0-9a-f], which is safe on all supported file systems.
 *
 * @param key  The cache key to hash.  Must conform to NSSecureCoding.
 *
 * @return A 64-character lowercase hex string, or @c nil if archiving failed.
 */
static NSString * _Nullable BEHashForKey(id<NSCopying, NSSecureCoding> key) {
	NSError *err  = nil;
	NSData  *data = [NSKeyedArchiver archivedDataWithRootObject:(id)key
										  requiringSecureCoding:YES
														  error:&err];
	if (!data) {
		NSLog(@"[BEFileCache] key archive failed: %@", err.localizedDescription);
		return nil;
	}

	// Hash the archive bytes with SHA-256 to produce a fixed-length digest.
	unsigned char digest[CC_SHA256_DIGEST_LENGTH];
	CC_SHA256(data.bytes, (CC_LONG)data.length, digest);

	// Convert the raw bytes to a lowercase hex string safe for use as a filename.
	NSMutableString *hex =
		[NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
		[hex appendFormat:@"%02x", digest[i]];

	return [hex copy];
}

/**
 * @abstract  Returns the filename for the object payload file for @p key.
 *
 * @discussion
 *   Format: @c <SHA-256 of archived key>.BE_FILE_CACHE_EXTENSION
 *
 * @param key  The cache key.  Must conform to NSCopying and NSSecureCoding.
 *
 * @return The filename string, or @c nil if the key could not be archived.
 */
static NSString * _Nullable BEObjectFileName(id<NSCopying, NSSecureCoding> key) {
	NSString *h = BEHashForKey(key);
	return h ? [h stringByAppendingPathExtension:BE_FILE_CACHE_EXTENSION] : nil;
}

/**
 * @abstract  Returns the filename for the metadata sidecar file for @p key.
 *
 * @discussion
 *   Format: @c <SHA-256 of archived key>.BE_FILE_CACHE_META_EXTENSION
 *
 *   The metadata file shares the same base name as the object payload file;
 *   only the extension differs.
 *
 * @param key  The cache key.  Must conform to NSCopying and NSSecureCoding.
 *
 * @return The filename string, or @c nil if the key could not be archived.
 */
static NSString * _Nullable BEMetaFileName(id<NSCopying, NSSecureCoding> key) {
	NSString *h = BEHashForKey(key);
	return h ? [h stringByAppendingPathExtension:BE_FILE_CACHE_META_EXTENSION] : nil;
}

// ---------------------------------------------------------------------------
#pragma mark - BEFileCache
// ---------------------------------------------------------------------------

@implementation BEFileCache

// ── Init ─────────────────────────────────────────────────────────────────────

- (instancetype)init {
	return [self initWithCacheDirectory:nil];
}

- (instancetype)initWithCacheDirectory:(nullable NSString *)directory {
	if (!(self = [super init])) return nil;

	// Create the memory speed tier.  BEFileCache becomes its NSCacheDelegate
	// so memory evictions are forwarded to the caller's BEFileCacheDelegate.
	// All other NSCache properties are intentionally left at their defaults.
	_memoryCache          = [[NSCache alloc] init];
	_memoryCache.delegate = self;

	// Initialise the disk layer index and its dedicated serialisation queue.
	_diskMeta  = [NSMutableDictionary dictionary];
	_diskQueue = dispatch_queue_create("com.be.filecache.disk", DISPATCH_QUEUE_SERIAL);

	// Balance recency and value density equally by default.  With the default
	// retentionCost (== cost) the value term is 1, so trimming stays LRU until a
	// caller supplies distinct retention costs.
	_evictionBalance = 0.5;

	// ── Resolve the cache directory ───────────────────────────────────────────
	if (!directory.length) {
		// nil or empty string — use a "BEFileCache" subdirectory inside the
		// system's designated caches directory.
		NSString *caches =
			NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
												NSUserDomainMask, YES).firstObject;
		_cacheDirectory = [caches stringByAppendingPathComponent:@"BEFileCache"];

	} else {
		// Probe the file system: if @p directory already exists as a directory
		// use it verbatim; otherwise treat it as a plain name to be created
		// under NSCachesDirectory (e.g. @"MyCache" → <Caches>/MyCache).
		BOOL isDir  = NO;
		BOOL exists = [[NSFileManager defaultManager]
						fileExistsAtPath:directory isDirectory:&isDir];

		if (exists && isDir) {
			// Caller supplied an absolute path to an existing directory.
			_cacheDirectory = [directory copy];
		} else {
			// Plain subdirectory name — append to the system caches path.
			NSString *caches =
				NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
													NSUserDomainMask, YES).firstObject;
			_cacheDirectory = [caches stringByAppendingPathComponent:directory];
		}
	}

	// Create the resolved directory if it does not yet exist, then rebuild
	// diskMeta asynchronously so -init returns without blocking on disk I/O.
	// Public methods that read diskMeta use dispatch_sync and will naturally
	// wait for the bootstrap to complete if called immediately after init.
	[self createCacheDirectory];
	[self loadIndex];

	return self;
}

// ── NSCache-mirrored property forwarding ─────────────────────────────────────

// name is a human-readable label forwarded to _memoryCache; it does not
// affect the resolved cacheDirectory path.
- (NSString *)name            { return _memoryCache.name; }
- (void)setName:(NSString *)n { _memoryCache.name = n; }

- (void)setCountLimit:(NSUInteger)v {
	_countLimit = v;
	// Enforce the new limit immediately in case the disk cache already exceeds it.
	[self trimDiskIfNeeded];
}

- (void)setTotalCostLimit:(NSUInteger)v {
	_totalCostLimit = v;
	// Trim straight away so the new cost limit takes effect atomically.
	[self trimDiskIfNeeded];
}

// The flag is written to the directory's NSURLIsExcludedFromBackupKey resource
// value and mirrored in _excludedFromBackupCache.  The mirror exists because
// NSURL caches resource values, so a fresh disk read immediately after a set can
// return a stale flag; the mirror is authoritative once a set has succeeded.
- (BOOL)excludedFromBackup {
	@synchronized (self) {
		if (self.excludedFromBackupCache == nil) {
			NSURL *url = [NSURL fileURLWithPath:_cacheDirectory isDirectory:YES];
			NSNumber *excluded = nil;
			[url getResourceValue:&excluded forKey:NSURLIsExcludedFromBackupKey error:nil];
			self.excludedFromBackupCache = @(excluded.boolValue);
		}
		return self.excludedFromBackupCache.boolValue;
	}
}

- (void)setExcludedFromBackup:(BOOL)excluded {
	NSURL *url = [NSURL fileURLWithPath:_cacheDirectory isDirectory:YES];
	NSError *err = nil;
	if ([url setResourceValue:@(excluded)
					   forKey:NSURLIsExcludedFromBackupKey
						error:&err]) {
		@synchronized (self) { self.excludedFromBackupCache = @(excluded); }
	} else {
		NSLog(@"[BEFileCache] excludedFromBackup=%d failed: %@",
			  excluded, err.localizedDescription);
	}
}

- (BOOL)evictsObjectsWithDiscardedContent {
	return _memoryCache.evictsObjectsWithDiscardedContent;
}
- (void)setEvictsObjectsWithDiscardedContent:(BOOL)v {
	_memoryCache.evictsObjectsWithDiscardedContent = v;
}

// ── Memory-tier limit pass-throughs ──────────────────────────────────────────
// These control only the private speed tier and have no effect on the disk
// cache, which is bounded by countLimit / totalCostLimit exclusively.

- (NSUInteger)memoryCountLimit              { return _memoryCache.countLimit; }
- (void)setMemoryCountLimit:(NSUInteger)v   { _memoryCache.countLimit = v; }

- (NSUInteger)memoryTotalCostLimit          { return _memoryCache.totalCostLimit; }
- (void)setMemoryTotalCostLimit:(NSUInteger)v { _memoryCache.totalCostLimit = v; }

// ── NSCacheDelegate — memory-eviction forwarding only ────────────────────────

/**
 * @method cache:willEvictObject:
 *
 * @abstract
 *   Intercepts NSCache's memory-eviction callback and forwards it to the
 *   caller's delegate as @c cache:willEvictObjectFromMemory:.
 *
 * @discussion
 *   This method fires whenever @c _memoryCache is about to release an object,
 *   whether due to automatic eviction under memory pressure or an explicit
 *   @c removeObjectForKey: / @c removeAllObjects call.
 *
 *   No disk I/O is performed here.  If the object conforms to NSSecureCoding
 *   it was already written to disk in @c setObject:forKey:cost: and is safe.
 *   If the object was non-serialisable it was never persisted; its departure
 *   from memory is final, matching plain NSCache behaviour.
 *
 * @param cache   The NSCache that is evicting the object (always _memoryCache).
 * @param object  The object about to be evicted from the memory tier.
 */
- (void)cache:(NSCache *)cache willEvictObject:(id)object {
	id<BEFileCacheDelegate> d = _delegate;
	if ([d respondsToSelector:@selector(cache:willEvictObjectFromMemory:)]) {
		[d cache:self willEvictObjectFromMemory:object];
	}
}

// ── Core cache API ────────────────────────────────────────────────────────────

- (void)setObject:(id)obj forKey:(id<NSCopying, NSSecureCoding>)key {
	[self setObject:obj forKey:key cost:0 retentionCost:0];
}

- (void)setObject:(id)obj forKey:(id<NSCopying, NSSecureCoding>)key cost:(NSUInteger)g {
	[self setObject:obj forKey:key cost:g retentionCost:g];   // retention defaults to cost
}

- (void)setObject:(id)obj
		   forKey:(id<NSCopying, NSSecureCoding>)key
			 cost:(NSUInteger)g
	retentionCost:(NSUInteger)r {
	// Step 1 — Write to disk immediately so the entry survives app termination
	//          before NSCache has a chance to evict it from memory.
	//          Objects that don't conform to NSSecureCoding cannot be archived
	//          and are stored in memory only; if NSCache evicts them later they
	//          are lost, identical to plain NSCache behaviour.
	if ([obj conformsToProtocol:@protocol(NSSecureCoding)]) {
		// writeToDisk: warms the memory tier in the same disk-queue critical section, so the
		// two tiers stay consistent under concurrent same-key writes.
		[self writeToDisk:(id<NSSecureCoding>)obj key:key cost:g retentionCost:r];
	} else {
		// Memory-only, but serialized on the disk queue so it can't interleave with trim/remove.
		dispatch_sync(_diskQueue, ^{
			[self->_memoryCache setObject:obj forKey:key cost:g];
		});
	}
}

- (nullable id)objectForKey:(id<NSCopying, NSSecureCoding>)key {
	// ── Fast path: memory hit ─────────────────────────────────────────────────
	// NSCache calls beginContentAccess on NSDiscardableContent objects
	// internally before returning them, so no additional action is needed.
	id obj = [_memoryCache objectForKey:key];
	if (obj) {
		// Record the access for LRU ordering without blocking the hot path.
		dispatch_async(_diskQueue, ^{ [self touchAccessForKeyOnQueue:key]; });
		return obj;
	}

	// ── Slow path: disk hit ───────────────────────────────────────────────────
	// Snapshot the file path and cost from diskMeta on the disk queue.
	// We do this separately from the file read so the queue is not held
	// during what could be a slow deserialisation.
	__block NSString  *objectFilePath = nil;
	__block NSUInteger cost           = 0;
	dispatch_sync(_diskQueue, ^{
		NSDictionary *m = self->_diskMeta[(id)key];
		objectFilePath  = m[kMetaObjectFile];
		cost            = [m[kMetaCost] unsignedIntegerValue];
	});

	// Key is absent from both tiers — genuine cache miss.
	if (!objectFilePath) return nil;

	// Deserialise the object from its .cache payload file.
	obj = [self loadObjectAtPath:objectFilePath];
	if (!obj) return nil;

	// ── NSDiscardableContent: disk-hit access grant ───────────────────────────
	// On a memory hit NSCache calls beginContentAccess before returning the
	// object.  On this disk hit the object bypassed NSCache's objectForKey:
	// entirely, so NSCache has NOT called beginContentAccess on our behalf.
	// We call it exactly once here to put the object in the "accessible" state
	// before handing it to the caller — matching the guarantee NSCache
	// provides on a memory hit.  The caller is responsible for the paired
	// endContentAccess call.  All future memory hits are managed by NSCache.
	if ([obj conformsToProtocol:@protocol(NSDiscardableContent)]) {
		if (![(id<NSDiscardableContent>)obj beginContentAccess]) {
			// Content was discarded between writing and reading — treat as miss.
			return nil;
		}
	}

	// Re-warm _memoryCache directly (bypassing setObject:'s disk write). The re-warm runs on
	// the disk queue and re-checks diskMeta: a concurrent trim/remove during the load above
	// must not be resurrected in memory. obj is still returned to this caller regardless.
	dispatch_sync(_diskQueue, ^{
		if (self->_diskMeta[(id)key]) {
			[self touchAccessForKeyOnQueue:key];
			[self->_memoryCache setObject:obj forKey:key cost:cost];
		}
	});

	return obj;
}

- (void)removeObjectForKey:(id<NSCopying, NSSecureCoding>)key {
	// Both tiers in one critical section; notifyDelegate:NO — an explicit remove is not an eviction.
	dispatch_sync(_diskQueue, ^{
		[self removeDiskEntryOnQueue:key notifyDelegate:NO];
		[self->_memoryCache removeObjectForKey:key];
	});
}

- (void)removeAllObjects {
	// Both tiers in one critical section.
	dispatch_sync(_diskQueue, ^{
		NSFileManager *fm = [NSFileManager defaultManager];
		for (NSDictionary *m in self->_diskMeta.allValues) {
			// Delete both the object payload and the metadata sidecar.
			[fm removeItemAtPath:m[kMetaObjectFile] error:nil];
			[fm removeItemAtPath:m[kMetaMetaFile]   error:nil];
		}
		[self->_diskMeta removeAllObjects];
		self->_diskCount     = 0;
		self->_diskTotalCost = 0;
		// Clear the memory tier inside the same critical section.
		[self->_memoryCache removeAllObjects];
		// Persist the now-empty index so the cleared state survives a relaunch.
		[self saveIndexOnQueue];
	});
}

// ---------------------------------------------------------------------------
#pragma mark - Private – directory
// ---------------------------------------------------------------------------

/**
 * @method createCacheDirectory
 *
 * @abstract  Creates cacheDirectory and any required intermediate directories.
 *
 * @discussion
 *   Called once from @c initWithCacheDirectory: after the resolved path is
 *   stored in @c _cacheDirectory.  On failure the error is logged and
 *   execution continues; subsequent write attempts will fail gracefully with
 *   their own log messages rather than crashing.
 */
- (void)createCacheDirectory {
	NSError *err = nil;
	[[NSFileManager defaultManager]
		createDirectoryAtPath:_cacheDirectory
  withIntermediateDirectories:YES
				   attributes:nil
						error:&err];
	if (err)
		NSLog(@"[BEFileCache] mkdir failed: %@", err.localizedDescription);
}

// ---------------------------------------------------------------------------
#pragma mark - Private – index load / save
// ---------------------------------------------------------------------------

/**
 * @method loadIndex
 *
 * @abstract
 *   Loads @c diskMeta from the BEFileCacheIndex file asynchronously on
 *   @c diskQueue.
 *
 * @discussion
 *   Each index entry is validated before being added to @c diskMeta: both the
 *   @c .cache payload and @c .meta sidecar files must still exist on disk.
 *   This guards against entries whose files were deleted externally while the
 *   app was not running.
 *
 *   On failure (index absent or corrupt) execution falls through to
 *   @c scanMetaFilesForIndex, which rebuilds the index by scanning @c .meta
 *   sidecars directly — never opening the potentially large @c .cache files.
 *
 * @note Called once from @c initWithCacheDirectory: and never again.
 */
- (void)loadIndex {
	dispatch_async(_diskQueue, ^{
		BOOL populated = NO;
		NSString *indexPath =
			[self->_cacheDirectory stringByAppendingPathComponent:kIndexFileName];

		// Attempt to load the pre-built index file written on the previous run.
		NSData *data = [NSData dataWithContentsOfFile:indexPath];

		if (data) {
			NSError *err     = nil;
			NSArray *entries =
				[NSKeyedUnarchiver unarchivedObjectOfClasses:BEIndexAllowedClasses()
												   fromData:data
													  error:&err];
			if (entries) {
				NSFileManager *fm = [NSFileManager defaultManager];
				// Accept any NSSecureCoding-conforming type for key objects.
				NSSet *anyClass   = [NSSet setWithArray:@[NSString.class, NSNumber.class, NSDate.class, NSData.class, NSArray.class, NSDictionary.class, NSNull.class]];

				for (NSDictionary *entry in entries) {
					// Pull each required field; skip entries with missing data.
					NSData   *keyData       = entry[kIdxKeyData];
					NSString *objectFileRef = entry[kIdxObjectFile];
					NSString *metaFileRef   = entry[kIdxMetaFile];
					NSNumber *cost          = entry[kIdxCost];
					NSNumber *retention     = entry[kIdxRetention] ?: cost;  // pre-1.1 indexes lack retention
					NSDate   *date          = entry[kIdxDate];
					NSDate   *access        = entry[kIdxAccess] ?: date;  // pre-1.1 indexes lack access

					if (!keyData || !objectFileRef || !metaFileRef
						|| !cost || !date) continue;

					// Recompose against the current cacheDirectory so a relocated cache still
					// resolves; -lastPathComponent also normalizes legacy absolute-path indexes.
					NSString *objectFilePath =
						[self->_cacheDirectory stringByAppendingPathComponent:objectFileRef.lastPathComponent];
					NSString *metaFilePath =
						[self->_cacheDirectory stringByAppendingPathComponent:metaFileRef.lastPathComponent];

					// Both sibling files must be present.  External deletion
					// or an incomplete prior write could leave orphaned entries.
					if (![fm fileExistsAtPath:objectFilePath]) continue;
					if (![fm fileExistsAtPath:metaFilePath])   continue;

					// Reconstruct the original key object from its archived bytes.
					NSError *keyErr = nil;
					id key =
						[NSKeyedUnarchiver unarchivedObjectOfClasses:anyClass
														   fromData:keyData
															  error:&keyErr];
					if (!key) {
						NSLog(@"[BEFileCache] index key unarchive failed: %@",
							  keyErr.localizedDescription);
						continue;
					}

					// Use the recovered key object so isEqual: / hash lookups
					// in objectForKey: resolve correctly.
					self->_diskMeta[key] = @{ kMetaKey        : key,
											  kMetaCost       : cost,
											  kMetaRetention  : retention,
											  kMetaDate       : date,
											  kMetaAccess     : access,
											  kMetaObjectFile : objectFilePath,
											  kMetaMetaFile   : metaFilePath };
					self->_diskCount++;
					self->_diskTotalCost += cost.unsignedIntegerValue;
				}
				populated = YES;     // Fast path succeeded.
			} else {
				NSLog(@"[BEFileCache] index unarchive failed: %@",
					  err.localizedDescription);
			}
		}

		// Index absent or corrupt — rebuild diskMeta by scanning .meta sidecars.
		if (!populated) {
			[self scanMetaFilesForIndex];
		}

		// Reconcile diskMeta against the directory: adopt any crash-orphaned
		// .cache/.meta pair the index never recorded, and delete stray files.
		[self reconcileWithDirectoryOnQueue];
	});
}

/**
 * @method scanMetaFilesForIndex
 *
 * @abstract
 *   Rebuilds @c diskMeta by scanning every @c .meta sidecar in @c
 *   cacheDirectory without opening any @c .cache object files.
 *
 * @discussion
 *   This is the slow-path fallback used on first launch or when the index file
 *   is missing or corrupt.  Because @c .meta files are small (key + cost + date
 *   only) the scan is fast even for a large number of cached entries.
 *
 *   For each valid @c .meta file the method verifies that the sibling @c .cache
 *   file also exists before adding the entry, skipping orphaned sidecars.
 *
 *   At the end @c saveIndexOnQueue is called so subsequent launches use the
 *   O(1) fast path instead of repeating the scan.
 *
 * @note Must be called on @c diskQueue.
 */
- (void)scanMetaFilesForIndex {
	NSFileManager *fm  = [NSFileManager defaultManager];

	// Build the suffix string to match against directory entries.
	NSString *ext = [NSString stringWithFormat:@".%@", BE_FILE_CACHE_META_EXTENSION];

	NSArray *files = [fm contentsOfDirectoryAtPath:_cacheDirectory error:nil];

	for (NSString *f in files) {
		if (![f hasSuffix:ext]) continue;

		NSString *metaFilePath =
			[_cacheDirectory stringByAppendingPathComponent:f];

		// Both files share the same SHA-256 base name; derive the sibling
		// .cache path by swapping the extension.
		NSString *base           = [f stringByDeletingPathExtension];
		NSString *objectFileName =
			[base stringByAppendingPathExtension:BE_FILE_CACHE_EXTENSION];
		NSString *objectFilePath =
			[_cacheDirectory stringByAppendingPathComponent:objectFileName];

		// Skip orphaned .meta files that have no corresponding .cache file.
		if (![fm fileExistsAtPath:objectFilePath]) continue;

		// Deserialise the lightweight metadata sidecar to recover key/cost/date.
		BEFileCacheItem *item = [self unarchiveMetaAtPath:metaFilePath];
		if (!item || !item.key) continue;

		_diskMeta[(id)item.key] = @{ kMetaKey        : (id)item.key,
									 kMetaCost       : @(item.cost),
									 kMetaRetention  : @(item.retentionCost),
									 kMetaDate       : item.dateStored,
									 kMetaAccess     : [self accessSeedForObjectPath:objectFilePath
																			fallback:item.dateStored],
									 kMetaObjectFile : objectFilePath,
									 kMetaMetaFile   : metaFilePath };
		_diskCount++;
		_diskTotalCost += item.cost;
	}

	// Write the freshly built index so future launches take the fast path.
	[self saveIndexOnQueue];
}

/**
 * @method reconcileWithDirectoryOnQueue
 *
 * @abstract
 *   Reconciles @c diskMeta with the actual files in @c cacheDirectory: adopts
 *   on-disk entries the index missed and deletes orphaned files.
 *
 * @discussion
 *   @c loadIndex trusts the index as the authoritative set and only prunes
 *   entries whose files have vanished.  It cannot discover files the index never
 *   recorded — for example a @c .cache / @c .meta pair written just before the
 *   process was killed, before @c saveIndexOnQueue ran.  Such files would
 *   otherwise be invisible: never returned, never counted toward the limits, and
 *   never trimmed, leaking disk space until the index is deleted or corrupted.
 *
 *   This pass lists the directory once and cross-checks it against @c diskMeta:
 *
 *   - A @c .cache / @c .meta pair not already tracked is adopted; its @c .meta
 *     is read to recover the key, cost, and date, and the running totals update.
 *   - A pair whose @c .meta will not decode is deleted (the entry is unusable).
 *   - A lone @c .cache with no sidecar is deleted; the key lives in the @c .meta,
 *     so the payload cannot be recovered.
 *   - A lone @c .meta with no payload is deleted.
 *
 *   The index is saved only when the pass changes @c diskMeta or removes a file.
 *
 * @note Must be called on @c diskQueue, after @c diskMeta has been populated.
 */
- (void)reconcileWithDirectoryOnQueue {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray<NSString *> *files =
		[fm contentsOfDirectoryAtPath:_cacheDirectory error:nil];
	if (!files) return;

	NSString *cacheExt = BE_FILE_CACHE_EXTENSION;
	NSString *metaExt  = BE_FILE_CACHE_META_EXTENSION;

	// Base names (SHA-256 digests) of the .cache and .meta files present on disk.
	NSMutableSet<NSString *> *cacheBases = [NSMutableSet set];
	NSMutableSet<NSString *> *metaBases  = [NSMutableSet set];
	for (NSString *f in files) {
		NSString *ext = f.pathExtension;
		if ([ext isEqualToString:cacheExt]) {
			[cacheBases addObject:f.stringByDeletingPathExtension];
		} else if ([ext isEqualToString:metaExt]) {
			[metaBases addObject:f.stringByDeletingPathExtension];
		}
	}

	// Base names already tracked by the loaded index.
	NSMutableSet<NSString *> *tracked =
		[NSMutableSet setWithCapacity:_diskMeta.count];
	for (NSDictionary *m in _diskMeta.allValues) {
		[tracked addObject:
		 [[m[kMetaObjectFile] lastPathComponent] stringByDeletingPathExtension]];
	}

	BOOL changed = NO;

	// ── Adopt or clean entries the index does not know about ──────────────────
	for (NSString *base in cacheBases) {
		if ([tracked containsObject:base]) continue;     // already indexed

		NSString *objectFilePath =
			[_cacheDirectory stringByAppendingPathComponent:
			 [base stringByAppendingPathExtension:cacheExt]];

		if (![metaBases containsObject:base]) {
			// Lone .cache with no sidecar — the key lives in the .meta, so the
			// payload is unrecoverable.  Delete it.
			[fm removeItemAtPath:objectFilePath error:nil];
			changed = YES;
			continue;
		}

		NSString *metaFilePath =
			[_cacheDirectory stringByAppendingPathComponent:
			 [base stringByAppendingPathExtension:metaExt]];

		// Crash-orphan: a complete pair the index missed.  Recover the key.
		BEFileCacheItem *item = [self unarchiveMetaAtPath:metaFilePath];
		if (!item || !item.key) {
			// Corrupt sidecar — the entry is unusable.  Delete both files.
			[fm removeItemAtPath:objectFilePath error:nil];
			[fm removeItemAtPath:metaFilePath   error:nil];
			changed = YES;
			continue;
		}

		_diskMeta[(id)item.key] = @{ kMetaKey        : (id)item.key,
									 kMetaCost       : @(item.cost),
									 kMetaRetention  : @(item.retentionCost),
									 kMetaDate       : item.dateStored,
									 kMetaAccess     : [self accessSeedForObjectPath:objectFilePath
																			fallback:item.dateStored],
									 kMetaObjectFile : objectFilePath,
									 kMetaMetaFile   : metaFilePath };
		_diskCount++;
		_diskTotalCost += item.cost;
		changed = YES;
	}

	// ── Delete lone .meta sidecars with no payload ────────────────────────────
	for (NSString *base in metaBases) {
		if ([tracked containsObject:base])    continue;   // a live entry owns it
		if ([cacheBases containsObject:base]) continue;   // handled in the pair loop

		NSString *metaFilePath =
			[_cacheDirectory stringByAppendingPathComponent:
			 [base stringByAppendingPathExtension:metaExt]];
		[fm removeItemAtPath:metaFilePath error:nil];
		changed = YES;
	}

	if (changed) [self saveIndexOnQueue];
}

/**
 * @method saveIndexOnQueue
 *
 * @abstract
 *   Serialises @c diskMeta to the BEFileCacheIndex file.
 *
 * @discussion
 *   Each entry's key object is archived separately to @c NSData so it can be
 *   stored as a plain Foundation type inside the index archive, which requires
 *   @c NSSecureCoding.  The index is written atomically so a crash during the
 *   write cannot leave a corrupt or partial index on disk.
 *
 *   This method is called after every mutation to @c diskMeta — insertions,
 *   removals, and trims — to keep the index consistent with the actual files
 *   in the cache directory.
 *
 * @note Must be called on @c diskQueue.
 */
- (void)saveIndexOnQueue {
	NSMutableArray *entries =
		[NSMutableArray arrayWithCapacity:_diskMeta.count];

	[_diskMeta enumerateKeysAndObjectsUsingBlock:
	 ^(id key, NSDictionary *meta, BOOL *stop) {

		// Archive each key to NSData so the index array contains only standard
		// Foundation types compatible with requiresSecureCoding:YES.
		NSError *keyErr  = nil;
		NSData  *keyData =
			[NSKeyedArchiver archivedDataWithRootObject:key
								  requiringSecureCoding:YES
												  error:&keyErr];
		if (!keyData) {
			// Non-fatal: skip this entry.  It will be recovered by the .meta
			// scan fallback on the next launch if the index is rebuilt.
			NSLog(@"[BEFileCache] index key archive failed: %@",
				  keyErr.localizedDescription);
			return;
		}

		// Store base filenames, not absolute paths, so the index survives a cache-directory
		// relocation; loadIndex recomposes them against the current cacheDirectory.
		[entries addObject:@{ kIdxKeyData    : keyData,
							  kIdxCost       : meta[kMetaCost],
							  kIdxRetention  : (meta[kMetaRetention] ?: meta[kMetaCost]),
							  kIdxDate       : meta[kMetaDate],
							  kIdxAccess     : (meta[kMetaAccess] ?: meta[kMetaDate]),
							  kIdxObjectFile : [meta[kMetaObjectFile] lastPathComponent],
							  kIdxMetaFile   : [meta[kMetaMetaFile]   lastPathComponent] }];
	}];

	// Archive the full array with secure coding enabled.
	NSError *err  = nil;
	NSData  *data = [NSKeyedArchiver archivedDataWithRootObject:entries
										  requiringSecureCoding:YES
														  error:&err];
	if (!data) {
		NSLog(@"[BEFileCache] index save failed: %@", err.localizedDescription);
		return;
	}

	NSString *indexPath =
		[_cacheDirectory stringByAppendingPathComponent:kIndexFileName];
	// NSDataWritingAtomic prevents a partial index from being left on disk
	// if the process is killed mid-write.
	NSError *writeErr = nil;
	if (![data writeToFile:indexPath options:NSDataWritingAtomic error:&writeErr]) {
		// Non-fatal: diskMeta stays authoritative this session and the .meta scan can rebuild.
		NSLog(@"[BEFileCache] index write failed: %@", writeErr.localizedDescription);
	}
}

// ---------------------------------------------------------------------------
#pragma mark - Private – disk write
// ---------------------------------------------------------------------------

/**
 * @method writeToDisk:key:cost:
 *
 * @abstract
 *   Writes the object payload and metadata sidecar for @p key to disk, then
 *   updates @c diskMeta and the index file.
 *
 * @discussion
 *   Two files are written per entry:
 *
 *   - @c <hash>.BE_FILE_CACHE_EXTENSION      — the archived object, no wrapper.
 *   - @c <hash>.BE_FILE_CACHE_META_EXTENSION — @c BEFileCacheItem (key + cost +
 *     date only); intentionally excludes the object so index rebuilds via
 *     @c scanMetaFilesForIndex never need to open large payload files.
 *
 *   The object file is written first.  If the metadata write subsequently
 *   fails, the object file is removed so the two files always remain in sync.
 *   An orphaned @c .cache file without a @c .meta sidecar would be invisible
 *   to the fallback scanner and would waste disk space.
 *
 *   After a successful write @c trimDiskIfNeeded is scheduled asynchronously
 *   so limits are enforced without blocking the caller.
 *
 * @param obj   The object to persist.  Must conform to @c NSSecureCoding.
 * @param key   The cache key.  Must conform to @c NSCopying and @c NSSecureCoding.
 * @param cost  The caller-supplied cost for this entry (@c 0 if unspecified).
 *
 * @return @c YES if both files were written successfully; @c NO otherwise.
 */
- (BOOL)writeToDisk:(id<NSSecureCoding>)obj
				key:(id<NSCopying, NSSecureCoding>)key
			   cost:(NSUInteger)cost
	  retentionCost:(NSUInteger)retentionCost {

	// Derive filenames for the payload and sidecar.  Both share the same
	// SHA-256 base name derived from the archived key bytes.
	NSString *objectFileName = BEObjectFileName(key);
	NSString *metaFileName   = BEMetaFileName(key);
	if (!objectFileName || !metaFileName) return NO;    // key archiving failed

	NSString *objectFilePath =
		[_cacheDirectory stringByAppendingPathComponent:objectFileName];
	NSString *metaFilePath =
		[_cacheDirectory stringByAppendingPathComponent:metaFileName];

	// ── Archive the object payload ────────────────────────────────────────────
	// The object is archived directly — no envelope wrapper — into the .cache
	// file so loadObjectAtPath: can deserialise it without knowing the
	// concrete class in advance.
	//
	// Hold content access across the archive for NSDiscardableContent objects so
	// the payload cannot capture a half-discarded state.  If the content is
	// already gone (beginContentAccess returns NO) the archive is best-effort.
	BOOL accessHeld = [(id)obj conformsToProtocol:@protocol(NSDiscardableContent)]
		&& [(id<NSDiscardableContent>)obj beginContentAccess];

	NSError *objErr  = nil;
	NSData  *objData =
		[NSKeyedArchiver archivedDataWithRootObject:obj
							 requiringSecureCoding:YES
											 error:&objErr];

	if (accessHeld) {
		[(id<NSDiscardableContent>)obj endContentAccess];
	}

	if (!objData) {
		NSLog(@"[BEFileCache] object archive failed: %@",
			  objErr.localizedDescription);
		return NO;
	}

	// ── Archive the metadata sidecar ──────────────────────────────────────────
	// BEFileCacheItem stores key + cost + dateStored and nothing else.
	BEFileCacheItem *item =
		[[BEFileCacheItem alloc] initWithKey:key cost:cost retentionCost:retentionCost];
	NSError *metaErr  = nil;
	NSData  *metaData =
		[NSKeyedArchiver archivedDataWithRootObject:item
							 requiringSecureCoding:YES
											 error:&metaErr];
	if (!metaData) {
		NSLog(@"[BEFileCache] meta archive failed: %@",
			  metaErr.localizedDescription);
		return NO;
	}

	// ── Write both files atomically on the disk queue ─────────────────────────
	__block BOOL ok = NO;
	dispatch_sync(_diskQueue, ^{
		// Warm the memory tier in the same critical section as the disk update so the two
		// cannot diverge. Done unconditionally so the value survives even a failed disk write.
		[self->_memoryCache setObject:obj forKey:key cost:cost];

		NSError *writeErr = nil;

		// Write the object payload first.
		ok = [objData writeToFile:objectFilePath
						  options:NSDataWritingAtomic
							error:&writeErr];
		if (!ok) {
			NSLog(@"[BEFileCache] object write failed: %@",
				  writeErr.localizedDescription);
			return;     // meta not yet written — nothing to roll back
		}

		// Write the metadata sidecar.
		ok = [metaData writeToFile:metaFilePath
						   options:NSDataWritingAtomic
							 error:&writeErr];
		if (!ok) {
			NSLog(@"[BEFileCache] meta write failed: %@",
				  writeErr.localizedDescription);
			// Roll back the object file to keep the sibling pair in sync.
			[[NSFileManager defaultManager]
				removeItemAtPath:objectFilePath error:nil];
			return;
		}

		// ── Update diskMeta and the running totals ────────────────────────────
		// If a prior entry for this key existed (overwrite case), subtract its
		// old cost before adding the new cost to prevent double-counting.
		NSDictionary *prev = self->_diskMeta[(id)key];
		if (prev) self->_diskTotalCost -= [prev[kMetaCost] unsignedIntegerValue];
		else      self->_diskCount    += 1;     // genuinely new entry

		self->_diskMeta[(id)key] = @{ kMetaKey        : (id)key,
									  kMetaCost       : @(cost),
									  kMetaRetention  : @(retentionCost),
									  kMetaDate       : item.dateStored,
									  kMetaAccess     : item.dateStored,   // a write is also an access
									  kMetaObjectFile : objectFilePath,
									  kMetaMetaFile   : metaFilePath };
		self->_diskTotalCost += cost;

		// Persist the updated index so cold-start reconstruction is O(1).
		[self saveIndexOnQueue];
	});

	// Schedule a trim check outside the dispatch block so the caller is not
	// blocked waiting for potential file deletions to complete.
	if (ok) [self trimDiskIfNeeded];
	return ok;
}

// ---------------------------------------------------------------------------
#pragma mark - Private – disk read
// ---------------------------------------------------------------------------

/**
 * @method loadObjectAtPath:
 *
 * @abstract  Deserialises and returns the cached object stored at @p path.
 *
 * @discussion
 *   Accepts any @c NSSecureCoding-conforming class; the concrete type is
 *   determined entirely by the archived data itself.  Returns @c nil and logs
 *   a message if the file is missing or the archive cannot be decoded.
 *
 *   A missing file is not treated as a fatal error; it can occur if a file
 *   was deleted externally while the app was running.
 *
 * @param path  Absolute path to a @c .BE_FILE_CACHE_EXTENSION payload file.
 *
 * @return The deserialised object, or @c nil on failure.
 */
- (nullable id)loadObjectAtPath:(NSString *)path {
	NSData *data = [NSData dataWithContentsOfFile:path];
	if (!data) return nil;     // file missing — may have been deleted externally

	NSError *err = nil;
	// The cache stores arbitrary caller-supplied objects, so the concrete class is
	// unknown here. Secure coding cannot express "any class" (and modern OS versions
	// reject [NSObject class] in the allowed list), so the object payload is decoded
	// without secure-coding enforcement. The cache only ever reads files it wrote
	// itself, under its own caches directory.
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&err];
	unarchiver.requiresSecureCoding = NO;
	id obj = err ? nil : [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
	[unarchiver finishDecoding];
	if (!obj)
		NSLog(@"[BEFileCache] object unarchive failed at '%@': %@",
			  path, err.localizedDescription);
	return obj;
}

/**
 * @method unarchiveMetaAtPath:
 *
 * @abstract  Deserialises and returns the @c BEFileCacheItem stored at @p path.
 *
 * @discussion
 *   @c BEFileCacheItem contains the entry's key, cost, and @c dateStored but
 *   NOT the cached object itself.  Used during the index-rebuild fallback scan
 *   so that large @c .cache payload files are never opened during start-up.
 *
 * @param path  Absolute path to a @c .BE_FILE_CACHE_META_EXTENSION sidecar file.
 *
 * @return The deserialised @c BEFileCacheItem, or @c nil on failure.
 */
- (nullable BEFileCacheItem *)unarchiveMetaAtPath:(NSString *)path {
	NSData *data = [NSData dataWithContentsOfFile:path];
	if (!data) return nil;

	NSError *err = nil;
	BEFileCacheItem *item =
		[NSKeyedUnarchiver unarchivedObjectOfClass:[BEFileCacheItem class]
										 fromData:data
											error:&err];
	if (!item)
		NSLog(@"[BEFileCache] meta unarchive failed at '%@': %@",
			  path, err.localizedDescription);
	return item;
}

// ---------------------------------------------------------------------------
#pragma mark - Private – recency
// ---------------------------------------------------------------------------

/**
 * @method touchAccessForKeyOnQueue:
 *
 * @abstract  Records a fresh last-access time for @p key in @c diskMeta.
 *
 * @discussion
 *   Updates only the in-memory @c kMetaAccess slot; nothing is written to disk.
 *   The new time reaches disk the next time the index is saved for another
 *   reason (a write, removal, or trim), so reads never cause disk I/O.  This is
 *   what drives the count-pass LRU ordering without touching the payload files.
 *
 * @note Must be called on @c diskQueue.
 */
- (void)touchAccessForKeyOnQueue:(id<NSCopying, NSSecureCoding>)key {
	NSDictionary *m = _diskMeta[(id)key];
	if (!m) return;     // memory-only entry or already evicted — nothing to record
	NSMutableDictionary *mm = [m mutableCopy];
	mm[kMetaAccess] = [NSDate date];
	_diskMeta[(id)key] = mm;
}

/**
 * @method accessSeedForObjectPath:fallback:
 *
 * @abstract  Returns a cold-start last-access seed for an entry recovered from disk.
 *
 * @discussion
 *   Used by the scan and reconciliation paths, where no persisted access time is
 *   available.  Returns the later of @p fallback (the insertion date) and the
 *   payload file's modification time.  The file's mtime is only read, never
 *   written, so this adds no backup churn.
 *
 * @param objectPath  Absolute path to the entry's @c .cache payload file.
 * @param fallback    The entry's insertion date.
 *
 * @return The seed last-access date.
 */
- (NSDate *)accessSeedForObjectPath:(NSString *)objectPath fallback:(NSDate *)fallback {
	NSDate *mtime = [[[NSFileManager defaultManager]
						attributesOfItemAtPath:objectPath error:nil] fileModificationDate];
	if (mtime && fallback && [mtime compare:fallback] == NSOrderedDescending) return mtime;
	return fallback ?: (mtime ?: [NSDate date]);
}

- (void)setEvictionBalance:(double)evictionBalance {
	_evictionBalance = MAX(0.0, MIN(1.0, evictionBalance));   // clamp to [0,1]
}

/**
 * @method evictionScoreForEntry:now:
 *
 * @abstract  The count-pass eviction score for a snapshot entry; higher is evicted first.
 *
 * @discussion
 *   @c score = pow(age, 1 − evictionBalance) × pow(max(cost,1)/max(retention,1), evictionBalance),
 *   where @c age is seconds since last access.  At balance 0 the score is the age
 *   (least-recently-used); at balance 1 it is the value density.  Computed once
 *   per entry per trim so @c pow never runs inside the sort comparator.
 *
 * @param e    A @c diskMeta snapshot entry.
 * @param now  Reference-date seconds captured once at the start of the pass.
 *
 * @return The eviction score.
 */
- (double)evictionScoreForEntry:(NSDictionary *)e now:(NSTimeInterval)now {
	double w   = _evictionBalance;
	double age = MAX(now - [e[kMetaAccess] timeIntervalSinceReferenceDate], 0.0);
	if (w <= 0.0) return age;                       // pure LRU — skip the pow pair
	double cost = MAX([e[kMetaCost]      doubleValue], 1.0);
	double ret  = MAX([e[kMetaRetention] doubleValue], 1.0);
	if (w >= 1.0) return cost / ret;                // pure value density
	return pow(age, 1.0 - w) * pow(cost / ret, w);
}

/**
 * @method scoredEvictionSnapshot
 *
 * @abstract  Snapshots @c diskMeta, scores each entry once, and returns it sorted
 *            most-evictable first.
 *
 * @discussion
 *   Both trim passes evict in this order.  Each entry is decorated with its
 *   @c evictionScoreForEntry:now: value a single time (the @c pow pair runs once
 *   per entry, never inside the comparator).  Entries are sorted by descending
 *   score; ties (e.g. an all-fresh cache where every score is 0) break by larger
 *   @c cost first, then least-recently-used first, so a full cache still trims.
 *
 * @note Must be called on @c diskQueue.
 *
 * @return A new array of mutable @c diskMeta snapshot dictionaries, each carrying
 *         a @c kMetaScore slot, ordered highest-score first.
 */
- (NSArray<NSDictionary *> *)scoredEvictionSnapshot {
	NSTimeInterval now = [NSDate date].timeIntervalSinceReferenceDate;
	NSMutableArray *scored =
		[NSMutableArray arrayWithCapacity:_diskMeta.count];
	[_diskMeta enumerateKeysAndObjectsUsingBlock:
	 ^(id k, NSDictionary *v, BOOL *s) {
		NSMutableDictionary *e = [v mutableCopy];
		e[kMetaScore] = @([self evictionScoreForEntry:e now:now]);
		[scored addObject:e];
	}];
	[scored sortUsingComparator:^NSComparisonResult(NSDictionary *a,
													 NSDictionary *b) {
		// Descending — highest (most evictable) score first.
		double sa = [a[kMetaScore] doubleValue];
		double sb = [b[kMetaScore] doubleValue];
		if (sa > sb) return NSOrderedAscending;
		if (sa < sb) return NSOrderedDescending;
		// Tiebreak: larger cost first, then least-recently-used first.
		NSUInteger ca = [a[kMetaCost] unsignedIntegerValue];
		NSUInteger cb = [b[kMetaCost] unsignedIntegerValue];
		if (ca != cb) return ca > cb ? NSOrderedAscending : NSOrderedDescending;
		return [a[kMetaAccess] compare:b[kMetaAccess]];
	}];
	return scored;
}

// ---------------------------------------------------------------------------
#pragma mark - Private – disk remove
// ---------------------------------------------------------------------------

/**
 * @method removeDiskEntry:notifyDelegate:
 *
 * @abstract
 *   Removes the disk entry for @p key, deleting both the @c .cache payload
 *   and the @c .meta sidecar, and updates @c diskMeta and the running totals.
 *
 * @discussion
 *   When @p notify is @c YES, @c cache:willEvictObject: is called on the
 *   delegate before the files are deleted, passing the deserialised object so
 *   the delegate receives the actual cached value — mirroring the
 *   NSCacheDelegate contract.
 *
 *   When @p notify is @c NO (explicit caller removes, overwrites, and
 *   promotions back to memory) the delegate is not notified, matching
 *   NSCache's own convention of not calling @c cache:willEvictObject: from
 *   @c removeObjectForKey: or @c removeAllObjects.
 *
 *   The index file is saved after every removal to keep the on-disk state
 *   consistent with @c diskMeta.
 *
 * @param key     The key whose disk entry should be removed.
 * @param notify  @c YES to fire @c cache:willEvictObject: before deletion
 *                (limit-driven evictions only); @c NO otherwise.
 */
- (void)removeDiskEntry:(id<NSCopying, NSSecureCoding>)key
		 notifyDelegate:(BOOL)notify {
	dispatch_sync(_diskQueue, ^{
		[self removeDiskEntryOnQueue:key notifyDelegate:notify];
	});
}

/**
 * @method removeDiskEntryOnQueue:notifyDelegate:
 *
 * @abstract  Non-dispatching core of @c removeDiskEntry:notifyDelegate:.
 *
 * @discussion
 *   Deletes the @c .cache / @c .meta pair, removes the entry from @c diskMeta,
 *   updates the running totals, and persists the index. When @c notify is YES the
 *   delegate's @c cache:willEvictObject: is fired BEFORE deletion — on the disk
 *   queue, exactly as @c trimDiskOnQueue does. The delegate must not synchronously
 *   re-enter the cache from this callback (see the header's thread-safety note).
 *
 * @note Must be called on @c diskQueue. Exists so callers can remove the disk and
 *   memory tiers in a single critical section, keeping them consistent.
 */
- (void)removeDiskEntryOnQueue:(id<NSCopying, NSSecureCoding>)key
				notifyDelegate:(BOOL)notify {
	NSDictionary *meta = self->_diskMeta[(id)key];
	if (!meta) return;     // key not on disk — nothing to do

	if (notify) {
		id<BEFileCacheDelegate> d = self->_delegate;
		if ([d respondsToSelector:@selector(cache:willEvictObject:)]) {
			id obj = [self loadObjectAtPath:meta[kMetaObjectFile]];
			if (obj) [d cache:self willEvictObject:obj];
		}
	}

	NSFileManager *fm = [NSFileManager defaultManager];
	[fm removeItemAtPath:meta[kMetaObjectFile] error:nil];
	[fm removeItemAtPath:meta[kMetaMetaFile]   error:nil];

	[self->_diskMeta removeObjectForKey:(id)key];

	// Guard against underflow on both running totals.
	NSUInteger c         = [meta[kMetaCost] unsignedIntegerValue];
	self->_diskCount     = self->_diskCount     > 0 ? self->_diskCount - 1      : 0;
	self->_diskTotalCost = self->_diskTotalCost >= c ? self->_diskTotalCost - c : 0;

	[self saveIndexOnQueue];
}

// ---------------------------------------------------------------------------
#pragma mark - Private – disk trim
// ---------------------------------------------------------------------------

/**
 * @method trimDiskIfNeeded
 *
 * @abstract
 *   Schedules @c trimDiskOnQueue asynchronously on @c diskQueue if either
 *   @c countLimit or @c totalCostLimit is active.
 *
 * @discussion
 *   The asynchronous dispatch means the caller is not blocked waiting for file
 *   deletions to complete.  Any public method that reads @c diskMeta
 *   (e.g. @c objectForKey:) uses @c dispatch_sync and will execute after any
 *   pending trim has finished.
 */
- (void)trimDiskIfNeeded {
	dispatch_async(_diskQueue, ^{ [self trimDiskOnQueue]; });
}

/**
 * @method trimDiskOnQueue
 *
 * @abstract
 *   Trims the disk cache in two passes, mirroring NSCache's trim behaviour.
 *
 * @discussion
 *   Both passes evict in @c scoredEvictionSnapshot order: the highest-scoring
 *   (most evictable) entry first, by @c evictionScoreForEntry:now:.  The score
 *   folds the time since last access together with value density (@c cost
 *   relative to @c retentionCost), weighted by @c evictionBalance (default 0.5).
 *   While entries keep the default @c retentionCost (== cost) the value term is
 *   1 and eviction is least-recently-used.  Last access updates on every memory
 *   or disk hit, so frequently-read entries survive.
 *
 *   **Pass 1 — Cost** removes entries until @c diskTotalCost is within
 *   @c totalCostLimit.  **Pass 2 — Count** removes entries until @c diskCount is
 *   within @c countLimit.  The two passes differ only in the budget they enforce.
 *
 *   Both passes work on a snapshot of @c diskMeta taken at the start of each
 *   pass so that mutations inside the loop do not invalidate the enumeration.
 *
 *   @c cache:willEvictObject: is fired on the delegate for each deletion in
 *   both passes — this is the @b only code path that calls that callback.
 *   The index is saved once after all evictions to minimise file-system writes.
 *
 * @note Must be called on @c diskQueue.
 *
 * @warning Do not call this method directly; use @c trimDiskIfNeeded instead.
 */
- (void)trimDiskOnQueue {
	BOOL                    didEvict = NO;
	NSFileManager          *fm       = [NSFileManager defaultManager];
	id<BEFileCacheDelegate>  d       = _delegate;

	// ── Pass 1: cost ──────────────────────────────────────────────────────────
	if (_totalCostLimit > 0 && _diskTotalCost > _totalCostLimit) {

		// Evict most-evictable first by the same score the count pass uses.
		for (NSDictionary *entry in [self scoredEvictionSnapshot]) {
			// Re-check each iteration — a previous deletion may have already
			// brought the total cost within the limit.
			if (_diskTotalCost <= _totalCostLimit) break;

			id         key            = entry[kMetaKey];
			NSString  *objectFilePath = entry[kMetaObjectFile];
			NSString  *metaFilePath   = entry[kMetaMetaFile];
			NSUInteger cost           = [entry[kMetaCost] unsignedIntegerValue];

			// Notify the delegate before deleting — the object is still readable.
			if ([d respondsToSelector:@selector(cache:willEvictObject:)]) {
				id obj = [self loadObjectAtPath:objectFilePath];
				if (obj) [d cache:self willEvictObject:obj];
			}

			// Delete both files and remove from both tiers using the original
			// key object so _memoryCache can find the in-memory entry.
			[fm removeItemAtPath:objectFilePath error:nil];
			[fm removeItemAtPath:metaFilePath   error:nil];
			[_diskMeta removeObjectForKey:key];
			[_memoryCache removeObjectForKey:key];

			_diskCount     = _diskCount     > 0    ? _diskCount - 1        : 0;
			_diskTotalCost = _diskTotalCost >= cost ? _diskTotalCost - cost : 0;
			didEvict = YES;
		}
	}

	// ── Pass 2: count ─────────────────────────────────────────────────────────
	if (_countLimit > 0 && _diskCount > _countLimit) {

		for (NSDictionary *entry in [self scoredEvictionSnapshot]) {
			// Re-check each iteration in case Pass 1 also reduced the count.
			if (_diskCount <= _countLimit) break;

			id         key            = entry[kMetaKey];
			NSString  *objectFilePath = entry[kMetaObjectFile];
			NSString  *metaFilePath   = entry[kMetaMetaFile];
			NSUInteger cost           = [entry[kMetaCost] unsignedIntegerValue];

			if ([d respondsToSelector:@selector(cache:willEvictObject:)]) {
				id obj = [self loadObjectAtPath:objectFilePath];
				if (obj) [d cache:self willEvictObject:obj];
			}

			[fm removeItemAtPath:objectFilePath error:nil];
			[fm removeItemAtPath:metaFilePath   error:nil];
			[_diskMeta removeObjectForKey:key];
			[_memoryCache removeObjectForKey:key];

			_diskCount     = _diskCount     > 0    ? _diskCount - 1        : 0;
			_diskTotalCost = _diskTotalCost >= cost ? _diskTotalCost - cost : 0;
			didEvict = YES;
		}
	}

	// Save the index once after all evictions rather than after each individual
	// deletion to keep file-system write traffic to a minimum.
	if (didEvict) [self saveIndexOnQueue];
}

@end
