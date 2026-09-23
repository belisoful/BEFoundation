/*!
 @header     BEFileCache.h
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @author     belisoful@icloud.com
 @abstract   A persistent, file-backed cache that mirrors the NSCache API.
 @discussion Design. The disk layer is the cache. Every object is written to disk
             immediately in @c setObject:forKey:cost: so the cache survives app
             termination with no special shutdown logic required.

             @c _memoryCache is a private, transparent speed tier created with all
             default NSCache settings. BEFileCache is @c _memoryCache's NSCacheDelegate
             solely to forward @c willEvictObjectFromMemory: to the caller's delegate.
             Memory evictions do not write to disk; the object is already there.

             Per-entry disk layout. Each cache entry produces two sibling files sharing
             the same base name. The default base name is the SHA-256 hex digest of the
             archived key bytes; @c fileNameBlock substitutes a caller-computed base name.
             @c <base>.BE_FILE_CACHE_EXTENSION holds the archived cached object only.
             @c <base>.BE_FILE_CACHE_META_EXTENSION holds the archived BEFileCacheItem
             (key + cost + retentionCost + dateStored + objectClassName).

             Payload decoding. Payloads are archived with @c requiresSecureCoding:YES and
             decoded the same way. The admitted classes are the Foundation property-list
             classes, the root class recorded in the entry's @c .meta sidecar at write
             time, and @c allowedClasses. A payload of any other class returns @c nil from
             @c objectForKey:. An entry written before 1.2.0 carries no recorded class and
             decodes with the property-list classes plus @c allowedClasses.

             Cache directory resolution (@c initWithCacheDirectory:).
             - nil / empty → @c <NSCachesDirectory>/BEFileCache
             - existing directory → used as-is (copied)
             - any other string → @c <NSCachesDirectory>/<directory>

             Key contract. Keys must conform to NSCopying and NSSecureCoding. Common
             Foundation types (NSString, NSNumber, NSURL, NSDate …) qualify.

             Disk index. A BEFileCacheIndex file in the cache directory is updated after
             every mutation. On startup @c _diskMeta is rebuilt from this one file; no
             object or meta files are read, giving O(1) cold-start I/O. The index is
             archived with @c requiresSecureCoding:YES. When the index is missing or
             corrupt, the @c .meta files are scanned instead. After loading, a
             reconciliation pass cross-checks the directory: a @c .cache/.meta pair the
             index missed (e.g. written just before a crash) is adopted so it is counted
             and trimmable; stray lone files are deleted. In both recovery paths, a
             recovered pair whose key is already tracked (a @c fileNameBlock rename
             interrupted between writing the new pair and deleting the old) resolves to
             the pair with the newer @c dateStored; the older pair's files are deleted and
             the key is counted once.

             Disk trimming (mirrors NSCache's cost-then-count order). Both passes evict by
             an eviction score, highest-scoring first:
             1. @c totalCostLimit: evict until @c diskTotalCost is within the limit.
             2. @c countLimit: evict until @c diskCount is within the limit.

             The score balances recency against value density:
             @code
             score = pow(age, 1 - evictionBalance) * pow(cost / retentionCost, evictionBalance)
             @endcode
             where age is the time since the entry's last access. @c evictionBalance (0…1,
             default 0.5) is the dial: 0 = least-recently-used, 1 = value density (evict
             large, cheap-to-replace entries first), 0.5 = geometric balance.
             @c retentionCost defaults to @c cost, so the value-density term is inert (pure
             LRU at every balance; score ties break least-recently-used first) until a
             caller supplies a distinct @c retentionCost. Last access updates on every
             memory or disk hit and is held in memory, so reads cause no payload I/O.

             Delegate. BEFileCacheDelegate mirrors NSCacheDelegate with @c BEFileCache* in
             place of @c NSCache*, and adds @c willEvictObjectFromMemory: for memory-tier
             events.

             NSDiscardableContent. On writes, @c beginContentAccess/@c endContentAccess
             bracket the archive step so the payload cannot capture a half-discarded
             state. On memory hits, NSCache calls @c beginContentAccess internally, so no
             action is needed. On disk hits, the cache calls @c beginContentAccess once
             before returning the object; the caller owns @c endContentAccess.

             Thread safety. All public methods are safe to call concurrently from any
             thread. The disk and memory tiers are updated together inside a single
             serial-queue critical section, so the two tiers cannot diverge: concurrent
             writes to the same key serialize and the last writer wins both tiers; a
             concurrent read can never resurrect a key that a trim/remove evicted.

             Delegate callbacks (@c cache:willEvictObject: and
             @c cache:willEvictObjectFromMemory:) are delivered synchronously while that
             critical section is held, and may be delivered on an internal queue rather
             than the calling thread. A delegate must not synchronously call back into the
             same BEFileCache from within an eviction callback; doing so re-enters the
             serial queue and deadlocks. Perform any such follow-up work asynchronously
             (e.g. @c dispatch_async).
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*! @abstract File extension for cached object payload files. */
#define BE_FILE_CACHE_EXTENSION      (@"cache")

/*! @abstract File extension for cached entry metadata sidecar files (key, cost, date). */
#define BE_FILE_CACHE_META_EXTENSION (@"meta")

/*!
 @typedef    BEFileCacheFileNameBlock
 @abstract   Computes the base file name for a cache entry's on-disk files.
 @discussion Receives the entry's key and the default base name (the 64-character
             lowercase SHA-256 hex digest of the archived key bytes).  Returns the
             base name for the entry's files; the cache appends the
             @c BE_FILE_CACHE_EXTENSION and @c BE_FILE_CACHE_META_EXTENSION
             extensions.  The block receives no filesystem paths, so a name
             cannot leak the cache location.

             Requirements on the returned name:
             - a single path component: no @c "/", and not @c "." or @c ".."
             - no embedded NUL characters
             - at most @c NAME_MAX (255) bytes of file-system representation
               including the appended extension
             - unique per key: embed @p hashName (or a prefix of it) to
               guarantee this
             - deterministic: return the same name for the same key on every call

             Returning @c nil or a name that violates the size or component
             rules stores the entry under @p hashName instead.  A name that
             another entry already uses (compared case-insensitively, so
             case-insensitive volumes cannot alias two entries onto one file)
             also falls back to @p hashName.  Names are stored in decomposed
             Unicode form, the form the file system reports.
 @param      key       The entry's cache key.
 @param      hashName  The default base name for @p key (SHA-256 hex digest).
 @return     The base file name, without extension.
 @since      1.1
 */
typedef NSString * _Nullable (^BEFileCacheFileNameBlock)(
	id<NSCopying, NSSecureCoding> key, NSString *hashName);

@class BEFileCache;

// ---------------------------------------------------------------------------
// BEFileCacheDelegate
// ---------------------------------------------------------------------------

/*!
 @protocol   BEFileCacheDelegate
 @abstract   Mirrors NSCacheDelegate (@c BEFileCache* replaces @c NSCache*) and adds a
             memory-eviction callback.
 @discussion @c cache:willEvictObject: fires only when a limit trim permanently removes
             an object from the disk cache. It matches NSCacheDelegate timing and
             semantics.

             @c cache:willEvictObjectFromMemory: fires when an object is about to leave
             the private memory speed tier, whether by automatic eviction or explicit
             removal. The object remains on disk unless it was non-serializable, in
             which case it is truly gone. It mirrors NSCacheDelegate's
             @c willEvictObject: but scoped to the memory layer.
 */
@protocol BEFileCacheDelegate <NSObject>
@optional

/*! @abstract Permanent removal from the disk cache by a limit trim. */
- (void)cache:(BEFileCache *)cache willEvictObject:(id)obj;

/*! @abstract Removal from the in-memory speed tier (eviction or explicit remove). */
- (void)cache:(BEFileCache *)cache willEvictObjectFromMemory:(id)obj;

@end

// ---------------------------------------------------------------------------
// BEFileCacheItem  – lightweight on-disk metadata envelope (no object)
// ---------------------------------------------------------------------------

/*!
 @class      BEFileCacheItem
 @abstract   On-disk metadata envelope for a single cache entry.
 @discussion Stores only the entry's key, cost, retention cost, and insertion date. The
             cached object is stored separately in a @c .BE_FILE_CACHE_EXTENSION file so
             that index rebuilds can scan @c .meta sidecars without opening large payload
             files.
 */
@interface BEFileCacheItem : NSObject <NSSecureCoding>

/*! @abstract The cache key.  Conforms to NSCopying and NSSecureCoding. */
@property (nonatomic, strong, readonly) id<NSCopying, NSSecureCoding> key;

/*! @abstract The cost supplied by the caller at insertion time. */
@property (nonatomic, assign, readonly) NSUInteger cost;

/*!
 @property   retentionCost
 @abstract   The caller-supplied replacement cost: how expensive this entry is to recreate.
 @discussion Defaults to @c cost when not given.  The eviction score weighs @c cost against
             @c retentionCost, so a high @c retentionCost protects an entry from eviction.
 @since      1.1
 */
@property (nonatomic, assign, readonly) NSUInteger retentionCost;

/*! @abstract Wall-clock time at which this entry was written to disk. */
@property (nonatomic, strong, readonly) NSDate *dateStored;

/*!
 @property   objectClassName
 @abstract   The class name NSKeyedArchiver recorded for the cached object's root, or @c nil
             for an entry written before 1.2.0.
 @discussion BEFileCache admits this class when it decodes the entry's payload.
 @since      1.2.0
 */
@property (nonatomic, copy, readonly, nullable) NSString *objectClassName;

/*!
 @method     initWithKey:cost:
 @abstract   Creates an item whose retention cost equals its cost.
 @param      key   The cache key.  Must conform to NSCopying and NSSecureCoding.
 @param      cost  The caller-supplied cost for this entry.
 */
- (instancetype)initWithKey:(id<NSCopying, NSSecureCoding>)key
					   cost:(NSUInteger)cost;

/*!
 @method     initWithKey:cost:retentionCost:
 @abstract   Creates an item with a storage cost and a replacement cost.
 @param      key            The cache key.  Must conform to NSCopying and NSSecureCoding.
 @param      cost           The caller-supplied storage cost for this entry.
 @param      retentionCost  The caller-supplied replacement cost for this entry.
 @since      1.1
 */
- (instancetype)initWithKey:(id<NSCopying, NSSecureCoding>)key
					   cost:(NSUInteger)cost
			  retentionCost:(NSUInteger)retentionCost;

@end

// ---------------------------------------------------------------------------
// BEFileCache
// ---------------------------------------------------------------------------

/*!
 @class      BEFileCache
 @abstract   A persistent, file-backed cache mirroring the NSCache API.
 @discussion Objects are written to disk immediately on insertion and survive app
             relaunches; a private in-memory tier accelerates repeat reads. Keys must
             conform to both NSCopying and NSSecureCoding.

             @code
             BEFileCache *cache = [[BEFileCache alloc] initWithCacheDirectory:@"Thumbnails"];
             cache.countLimit = 500;

             NSData *thumb = [self renderThumbnailForAsset:assetID];
             [cache setObject:thumb forKey:assetID cost:thumb.length];

             NSData *cached = [cache objectForKey:assetID];   // memory hit, then disk
             if (cached) { [self displayThumbnail:cached]; }

             [cache removeObjectForKey:assetID];
             @endcode
 */
@interface BEFileCache : NSObject

// ── Identical to NSCache ──────────────────────────────────────────────────────

/*! @abstract Label only.  Defaults to @c @"" matching NSCache. */
@property (copy,     nonatomic)           NSString                *name;

/*! @abstract The cache's delegate. */
@property (nullable, weak, nonatomic)     id<BEFileCacheDelegate>  delegate;

/*! @abstract Maximum object count on disk.  0 = no limit (default). */
@property (assign, nonatomic) NSUInteger countLimit;

/*! @abstract Maximum total cost on disk.  0 = no limit (default). */
@property (assign, nonatomic) NSUInteger totalCostLimit;

/*!
 @property   evictionBalance
 @abstract   Disk-trim policy balance in [0,1].  Default 0.5.
 @discussion Sets how both trim passes (@c totalCostLimit and @c countLimit) rank
             entries for eviction:
             - @c 0 : pure least-recently-used; @c retentionCost is ignored.
             - @c 1 : pure value density; evict the largest @c cost relative to its
               @c retentionCost, ignoring recency.
             - @c 0.5 : geometric balance of recency and value density.

             The score is @c pow(age,1-balance) × @c pow(cost/retentionCost,balance);
             the highest-scoring entry is evicted first.  Values outside [0,1] clamp.
 @since      1.1
 */
@property (assign, nonatomic) double evictionBalance;

/*! @abstract Forwarded to the internal @c _memoryCache.  Default: YES. */
@property (assign, nonatomic) BOOL evictsObjectsWithDiscardedContent;

/*!
 @method     setObject:forKey:
 @abstract   Inserts @p obj with a cost of 0.
 @param      obj  The object to store.
 @param      key  Must conform to NSCopying and NSSecureCoding.
 */
- (void)setObject:(id)obj forKey:(id<NSCopying, NSSecureCoding>)key;

/*!
 @method     setObject:forKey:cost:
 @abstract   Inserts @p obj, tagging it with a storage cost.
 @param      obj   The object to store.
 @param      key   Must conform to NSCopying and NSSecureCoding.
 @param      g     Caller-supplied cost for this entry.
 */
- (void)setObject:(id)obj forKey:(id<NSCopying, NSSecureCoding>)key cost:(NSUInteger)g;

/*!
 @method     setObject:forKey:cost:retentionCost:
 @abstract   Inserts @p obj, tagging it with both a storage cost and a replacement cost.
 @discussion @p retentionCost states how expensive the entry is to recreate.  When
             @c evictionBalance is above 0, the disk trim weighs @p g against
             @p retentionCost: a large entry that is cheap to refetch is evicted before
             a small entry that is costly to recompute.  When @p retentionCost equals
             @p g (the default), the value term is 1, so trimming stays least-recently-
             used regardless of @c evictionBalance.
 @param      obj  The object to store.
 @param      key  Must conform to NSCopying and NSSecureCoding.
 @param      g    Storage cost for this entry.
 @param      r    Replacement cost for this entry.
 @since      1.1
 */
- (void)setObject:(id)obj
		   forKey:(id<NSCopying, NSSecureCoding>)key
			 cost:(NSUInteger)g
	retentionCost:(NSUInteger)r;

/*!
 @method     objectForKey:
 @abstract   Returns the cached object for @p key, checking memory first then disk.
 @param      key  Must conform to NSCopying and NSSecureCoding.
 @return     The cached object, or @c nil if absent from both tiers.
 */
- (nullable id)objectForKey:(id<NSCopying, NSSecureCoding>)key;

/*!
 @method     removeObjectForKey:
 @abstract   Removes the object for @p key from both tiers.
 @param      key  Must conform to NSCopying and NSSecureCoding.
 */
- (void)removeObjectForKey:(id<NSCopying, NSSecureCoding>)key;

/*!
 @method     removeAllObjects
 @abstract   Removes every object from both tiers in one critical section, deletes each
             payload and sidecar file, and persists the empty index.
 @discussion The delegate is not notified.
 */
- (void)removeAllObjects;

// ── Memory-tier controls ─────────────────────────────────────────────────────

/*! @abstract Count limit for the private in-memory speed cache.  0 = no limit. */
@property (assign, nonatomic) NSUInteger memoryCountLimit;

/*! @abstract Cost limit for the private in-memory speed cache.  0 = no limit. */
@property (assign, nonatomic) NSUInteger memoryTotalCostLimit;

// ── Disk controls ────────────────────────────────────────────────────────────

/*! @abstract Absolute path of the directory used for disk storage. */
@property (copy, nonatomic, readonly) NSString *cacheDirectory;

/*!
 @property   excludedFromBackup
 @abstract   Whether @c cacheDirectory is flagged to be excluded from backup.
 @discussion Reads and writes @c NSURLIsExcludedFromBackupKey on the cache
             directory, which keeps it out of iCloud/iTunes backups and Time
             Machine.  Set @c YES for an ephemeral cache; leave @c NO for a real
             file store that should be backed up.  The value is read from the
             directory on first access (so it survives relaunch) and mirrored
             in-process thereafter, because NSURL caches resource values and a
             fresh read right after a set can return a stale flag.  The default
             @c <NSCachesDirectory> location is already system-excluded
             regardless of this flag.
 @since      1.1
 */
@property (assign, nonatomic) BOOL excludedFromBackup;

/*!
 @property   fileNameBlock
 @abstract   Optional block that names an entry's on-disk files.
 @discussion When @c nil (the default) an entry's files use the SHA-256 hex
             digest of the archived key bytes as their base name.  When set, the
             block computes the base name instead and the cache appends the
             @c .cache / @c .meta extensions.  See @c BEFileCacheFileNameBlock
             for the requirements on returned names.

             Entries already on disk keep their recorded file names: lookups and
             removals resolve paths through the index, never by recomputing
             names.  Overwriting a key whose stored name differs from the name
             the block now returns deletes the old file pair, so changing the
             block between launches leaves no orphaned files.  During that
             renaming overwrite a concurrent read of the same key can return
             @c nil once (the old payload is deleted while the read holds its
             path); the miss is transient, like any cache miss.

             Set the block before the first write and keep it constant for the
             life of the directory.  The property is atomic; the block may be
             invoked on any thread and must be safe to call concurrently.
 @since      1.1
 */
@property (copy, nullable) BEFileCacheFileNameBlock fileNameBlock;

/*!
 @property   allowedClasses
 @abstract   Classes admitted when a payload is decoded, in addition to the defaults.
 @discussion Payloads decode with secure coding on.  A payload may instantiate:
             - the Foundation property-list classes (NSArray, NSDictionary, NSData,
               NSString, NSNumber, NSDate, NSURL) and their subclasses;
             - the root class recorded in the entry's @c .meta sidecar when the
               entry was written, when that class supports secure coding;
             - every class in this set.

             The recorded root class covers a custom NSSecureCoding object whose
             contents are property-list types.  An object graph whose nested
             objects are custom classes needs those classes listed here.  An
             entry written before 1.2.0 has no recorded class and decodes with
             the property-list classes plus this set, so a custom-class entry
             from an earlier release loads only when its class is listed here.

             A payload whose classes are not admitted returns @c nil from
             @c objectForKey:, as a cache miss.  The property is atomic; set it
             before the first read.  Default @c nil.
 @since      1.2.0
 */
@property (copy, nullable) NSSet<Class> *allowedClasses;

/*!
 @method     initWithCacheDirectory:
 @abstract   Designated initializer.
 @param      directory Resolved as follows:
             - nil / empty → @c <NSCachesDirectory>/BEFileCache
             - existing directory → used as-is
             - any other string → @c <NSCachesDirectory>/<directory> (an absolute path
               that does not yet exist is treated as a name, not created)
 */
- (instancetype)initWithCacheDirectory:(nullable NSString *)directory
	NS_DESIGNATED_INITIALIZER;

/*! @abstract Equivalent to @c -initWithCacheDirectory:nil. */
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
