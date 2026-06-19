//
//  BESecurityScopedURLManager.m
//  BESecurityScopedURLManager
//
//  Implementation: Thread-safe manager for security-scoped bookmarks with
//  persistent storage, reference counting, and automatic staleness handling.
//

#import "BESecurityScopedURLManager.h"
#import <CoreFoundation/CFURL.h>
#import <objc/runtime.h>

// Security-scoped bookmark options are macOS-only flags; on iOS the scope is implicit
// (document-picker URLs + -startAccessingSecurityScopedResource), so no flag is passed.
#if TARGET_OS_OSX
#define BE_BOOKMARK_CREATE_OPTS  NSURLBookmarkCreationWithSecurityScope
#define BE_BOOKMARK_RESOLVE_OPTS NSURLBookmarkResolutionWithSecurityScope
#else
#define BE_BOOKMARK_CREATE_OPTS  0
#define BE_BOOKMARK_RESOLVE_OPTS 0
#endif

#pragma mark - Constants

static NSString * const kBEDefaultCatalogKey = @"BESecurityScopedURLManagerCatalog";
static NSString * const kBECacheFilename = @"BESecurityScopedURLManager_Catalog.archive";

// Logging prefix
static NSString * const kBELogPrefix = @"[BESecurityScopedURLManager]";

#pragma mark - Logging Macros

#ifdef DEBUG
#define BELog(format, ...) NSLog(@"%@ %s: " format, kBELogPrefix, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define BELog(format, ...) do { } while(0)
#endif

#define BELogError(format, ...) NSLog(@"%@ ERROR %s: " format, kBELogPrefix, __PRETTY_FUNCTION__, ##__VA_ARGS__)

#pragma mark - BESecurityScopedURLBookmarkEntry Private Interface

/*!
 @abstract      Private properties and methods for internal bookmark management.
 @discussion    These properties are redeclared as read-write for internal use and should not be
				accessed directly by external code. All modifications are coordinated by the manager.
 */
@interface BESecurityScopedURLBookmarkEntry ()

/*! @property bookmarkData Redeclare as read-write for internal mutations. */
@property (nonatomic, strong, readwrite, nullable) NSData *bookmarkData;

/*! @property url Redeclare as read-write for internal mutations. */
@property (nonatomic, strong, readwrite, nullable) NSURL *url;

/*! @property createdAt Redeclare as read-write for internal mutations. */
@property (nonatomic, strong, readwrite) NSDate *createdAt;

/*! @property lifetime Redeclare as read-write for internal mutations. */
@property (nonatomic, readwrite) BESecurityScopedURLBookmarkLifetime lifetime;

/*! @property isDirectory Redeclare as read-write for internal mutations. */
@property (nonatomic, readwrite) BOOL isDirectory;

/*! @property isStale Redeclare as read-write for internal mutations. */
@property (nonatomic, readwrite) BOOL isStale;

/*! @property bookmarkError Redeclare as read-write for internal mutations. */
@property (nonatomic, strong, readwrite, nullable) NSError *bookmarkError;

/*! @property manager Weak reference to the managing BESecurityScopedURLManager. */
@property (nonatomic, weak) BESecurityScopedURLManager *manager;

/*!
 @method        applyRelocatedURLString:
 @abstract      Updates the entry's urlString (its catalog key) under the entry lock.
 @discussion    Used only by the manager's handleBookmarkRelocationFromPath:toPath:, which
				runs on the access queue. Keeping this change on the access queue (together
				with moving the catalog dictionary key) — rather than mutating _urlString
				directly inside -updateStaleBookmark off-queue — keeps the dictionary key and
				the entry's own urlString consistent. The entry lock guards _urlString against
				concurrent lazy -url resolution.
 @param         newURLString The new canonical key for this entry.
 */
- (void)applyRelocatedURLString:(NSString *)newURLString;
@end

#pragma mark - BESecurityScopedURLManager Private Interface

/*!
 @abstract      Private properties and methods for internal catalog and access management.
 @discussion    These properties and methods are used internally to manage the bookmark catalog,
				reference counting, and thread-safe synchronization. They should not be accessed
				directly by external code.
 */
@interface BESecurityScopedURLManager ()

/*! @property mutableCatalog The internal mutable dictionary storing bookmark entries. */
@property (nonatomic, strong) NSMutableDictionary<NSString *, BESecurityScopedURLBookmarkEntry *> *mutableCatalog;

/*! @property refCounts Tracks reference counts for active security-scoped access by URL. */
@property (nonatomic, strong) NSCountedSet<NSURL *> *refCounts;

/*! @property resolvedAccessURLByKey Maps a catalog key to the symlink-resolved URL form held
	in refCounts for it.  Relocation uses this to transfer active reference counts when the
	catalog key and its resolved form differ (e.g. /var/… vs /private/var/…). */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURL *> *resolvedAccessURLByKey;

/*! @property accessQueue Serial dispatch queue for thread-safe catalog and reference count access. */
@property (nonatomic, strong) dispatch_queue_t accessQueue;

/*! @property cacheFilePath Lazily computed per-instance path to the cache archive file.
    Stored as a readwrite ivar so each instance gets its own copy (no global dispatch_once). */
@property (nonatomic, strong) NSString *cacheFilePath;

/*!
 @method        saveCatalogSynchronously:
 @abstract      Internal method to save the catalog to persistence storage.
 @discussion    Archives long-lived bookmarks to UserDefaults and/or the Caches directory depending on
				the storageOptions setting. This method coordinates access through the accessQueue.
 @param         synchronously If YES, uses dispatch_sync to block until save completes. If NO, uses
				dispatch_async for non-blocking persistence.
 */
- (void)saveCatalogSynchronously:(BOOL)synchronously;

/*!
 @method        handleBookmarkRelocationFromPath:toPath:
 @abstract      Internal method to handle bookmark relocation updates.
 @discussion    Called when a stale bookmark is resolved and found to have moved to a new path.
				Updates the catalog to use the new path as the key and transfers reference counts.
 @param         oldPath The original catalog key (stale path).
 @param         newPath The new catalog key after relocation.
 */
- (void)handleBookmarkRelocationFromPath:(NSString *)oldPath toPath:(NSString *)newPath;

/*!
 @method        urlFromCatalogWithAbsolutePathInternal:
 @abstract      Single source of truth for Tier 1–4 URL resolution. No dispatch.
 @discussion    The public urlFromCatalogWithAbsolutePath: wraps this in dispatch_sync
				and contains no other logic, eliminating duplication.
				Callers already on the accessQueue use this directly to avoid
				the dispatch-within-dispatch serial-queue re-entry deadlock.
 @param         absolutePathString The canonical absolute string of the URL in the catalog.
 @return        The resolved URL from the catalog/directories, or nil if not found.
 */
- (nullable NSURL *)urlFromCatalogWithAbsolutePathInternal:(NSString *)absolutePathString;

/*!
 @method        startAccessingURLInternal:
 @abstract      Non-dispatching core implementation of reference-counted access start.
 @discussion    Performs the same access logic as startAccessingURL: but does NOT call dispatch_sync.
				Must only be called from within a block already executing on self.accessQueue.
				This prevents the dispatch-within-dispatch deadlock that occurs in startAccessingAllURLs.
 @param         url The URL for which to start access.
 @return        The resolved URL if access was successfully started, nil otherwise.
 */
- (nullable NSURL *)startAccessingURLInternal:(NSURL *)url;

/*!
 @method        endAccessingAllURLsInternal
 @abstract      Non-dispatching core implementation of bulk access teardown.
 @discussion    Performs the same teardown logic as endAccessingAllURLs but does NOT call dispatch_sync.
				Must only be called from within a block already executing on self.accessQueue.
				This prevents the dispatch-within-dispatch deadlock that occurs in clearCatalog.
 */
- (void)endAccessingAllURLsInternal;

/*!
 @method        saveCatalogInternal
 @abstract      Non-dispatching core implementation of catalog persistence.
 @discussion    Archives and writes long-lived bookmarks to all configured storage locations.
				Does NOT call dispatch_sync. Must only be called from within a block already executing
				on self.accessQueue. This prevents the dispatch-within-dispatch deadlock that occurs
				in removeURLFromCatalog:.
 */
- (void)saveCatalogInternal;

@end

#pragma mark - BESecurityScopedURLBookmarkEntry Implementation

@implementation BESecurityScopedURLBookmarkEntry

static NSString * const kBookmarkDataKey = @"bookmarkData";
static NSString * const kURLStringKey = @"urlString";
static NSString * const kCreatedAtKey = @"createdAt";
static NSString * const kLifetimeKey = @"lifetime";
static NSString * const kIsDirectoryKey = @"isDirectory";
static NSString * const kIsSecurityScopedKey = @"isSecurityScoped";

// The catalog snapshot hands entries to arbitrary threads while the manager mutates them, so the
// accessors for mutable-after-creation state are serialized on a per-entry @synchronized(self)
// lock — the same lock used by -url, -updateStaleBookmark, and -applyRelocatedURLString:. These
// @synthesize lines keep the backing ivars now that those properties have custom accessors.
// Init-only state (createdAt, lifetime, isDirectory, isSecurityScoped) is never mutated after
// construction and keeps its synthesized accessors.
@synthesize url = _url;
@synthesize bookmarkData = _bookmarkData;
@synthesize bookmarkError = _bookmarkError;
@synthesize isStale = _isStale;
@synthesize urlString = _urlString;

#pragma mark - Initialization

/*!
 @method        initWithURL:lifetime:
 @abstract      Designated initializer for creating a new bookmark entry.
 @discussion    Creates a security-scoped bookmark for the given URL and initializes all metadata.
				The bookmark is immediately tested to verify it can be resolved and supports security scope.
				If the URL is a directory, the path is normalized with a trailing slash.
 @param         url The file URL to create a bookmark for. Must be a valid file URL.
 @param         lifetime The intended persistence lifetime (short-lived or long-lived).
 @return        A new BESecurityScopedURLBookmarkEntry, or nil if the URL is invalid or bookmark creation failed.
 */
- (instancetype)initWithURL:(NSURL *)url lifetime:(BESecurityScopedURLBookmarkLifetime)lifetime {
	if (!url || !url.isFileURL) {
		return nil;
	}
	
	self = [super init];
	if (self) {
		_url = nil; // Lazy load
		_lifetime = lifetime;
		_createdAt = [NSDate date];
		_urlString = url.absoluteString;
		_isStale = NO;
		_isSecurityScoped = NO;
		_bookmarkError = nil;
		
		// Create the security-scoped bookmark.
		// Use typed temp variables instead of nil literals — passing nil literals
		// directly to nonnull-annotated parameters triggers a Clang nonnull assertion.
		NSArray  *nilResourceKeys = nil;
		NSURL    *nilRelativeURL  = nil;
		NSError  *bookmarkError   = nil;
		_bookmarkData = [url bookmarkDataWithOptions:BE_BOOKMARK_CREATE_OPTS
							includingResourceValuesForKeys:nilResourceKeys
											relativeToURL:nilRelativeURL
													error:&bookmarkError];
		
		// FIX: Guard on both the error AND the data being non-nil.
		// bookmarkDataWithOptions: can return nil with no error in a non-sandboxed
		// process. Without !_bookmarkData, the test-resolve call below would pass
		// nil as the nonnull first argument of URLByResolvingBookmarkData:,
		// triggering a "Null passed to a callee that requires a non-null argument" crash.
		if (bookmarkError || !_bookmarkData) {
			_bookmarkError = bookmarkError;
			if (bookmarkError) {
				BELogError(@"Failed to create bookmark for %@: %@", url.absoluteString, bookmarkError);
			}
			return self;
		}
		
		// Test-resolve to verify the bookmark has valid security scope.
		NSURL   *nilRelativeURL2  = nil;
		NSError *resolutionError  = nil;
		BOOL     isStale          = NO;
		NSURL *resolved = [NSURL URLByResolvingBookmarkData:_bookmarkData
													options:BE_BOOKMARK_RESOLVE_OPTS
											  relativeToURL:nilRelativeURL2
									bookmarkDataIsStale:&isStale
												  error:&resolutionError];
		
		_isSecurityScoped = (resolved != nil && resolutionError == nil);
		
		// Check if it's a directory.
		NSNumber *isDirectory     = nil;
		NSError  *dirCheckError   = nil;
		if ([url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&dirCheckError]) {
			_isDirectory = isDirectory.boolValue;
		}
		
		// Normalize directory paths with trailing slash
		if (_isDirectory && ![_urlString hasSuffix:@"/"]) {
			_urlString = [_urlString stringByAppendingString:@"/"];
		}
	}
	return self;
}

#pragma mark - NSSecureCoding

/*!
 @method        supportsSecureCoding
 @abstract      Indicates that this class supports secure archival and unarchival.
 @discussion    This method returns YES to indicate NSSecureCoding compliance. When decoding, only
				whitelisted classes are allowed, preventing deserialization of arbitrary objects.
 @return        YES, indicating secure coding support.
 */
+ (BOOL)supportsSecureCoding {
	return YES;
}

/*!
 @method        initWithCoder:
 @abstract      Decodes a bookmark entry from an NSCoder.
 @discussion    Safely decodes all bookmark data and metadata. Returns nil if critical data is missing
				or corrupted, preventing the loading of invalid entries from persistence.
 @param         coder The NSCoder instance to decode from.
 @return        A new BESecurityScopedURLBookmarkEntry, or nil if decoding failed or data is invalid.
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self) {
		_url = nil; // Lazy load
		_bookmarkData = [coder decodeObjectOfClass:[NSData class] forKey:kBookmarkDataKey];
		_urlString = [coder decodeObjectOfClass:[NSString class] forKey:kURLStringKey];
		_createdAt = [coder decodeObjectOfClass:[NSDate class] forKey:kCreatedAtKey];
		_lifetime = (BESecurityScopedURLBookmarkLifetime)[coder decodeIntegerForKey:kLifetimeKey];
		_isDirectory = [coder decodeBoolForKey:kIsDirectoryKey];
		_isSecurityScoped = [coder decodeBoolForKey:kIsSecurityScopedKey];
		_isStale = NO;
		_bookmarkError = nil;
		
		// Validate critical data
		if (!_bookmarkData || !_urlString || !_createdAt) {
			BELogError(@"Failed to decode bookmark entry: missing critical data");
			return nil;
		}
	}
	return self;
}

/*!
 @method        encodeWithCoder:
 @abstract      Encodes this bookmark entry using an NSCoder.
 @discussion    Safely encodes all public bookmark data and metadata for secure archival.
				Does not encode the transient _url property as it is lazily loaded.
 @param         coder The NSCoder instance to encode to.
 */
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.bookmarkData forKey:kBookmarkDataKey];
	[coder encodeObject:self.urlString forKey:kURLStringKey];
	[coder encodeObject:self.createdAt forKey:kCreatedAtKey];
	[coder encodeInteger:self.lifetime forKey:kLifetimeKey];
	[coder encodeBool:self.isDirectory forKey:kIsDirectoryKey];
	[coder encodeBool:self.isSecurityScoped forKey:kIsSecurityScopedKey];
}

#pragma mark - URL Resolution (Lazy Loading)

/*!
 @method        url
 @abstract      Lazily resolves and returns the current URL for this bookmark entry.
 @discussion    The first access to this property triggers resolution of the bookmark data into a URL.
				Subsequent accesses return the cached URL. This method automatically detects and handles
				stale bookmarks by attempting to refresh the bookmark data and notifying the manager of
				any relocations. Resolution errors are stored in bookmarkError.
 @return        The resolved NSURL, or nil if resolution failed.
 */
- (NSURL *)url {
	// The public `catalog` snapshot exposes entries to arbitrary threads, and this lazy
	// getter mutates ivars — so guard it. The lock is on the entry, never the access queue,
	// so it cannot deadlock against queue operations.
	@synchronized (self) {
		if (_url) {
			return _url;
		}

		// BUG FIX: In non-sandboxed processes NSURLBookmarkCreationWithSecurityScope fails
		// during initWithURL:, leaving _bookmarkData = nil. Without this guard the call
		// below would pass nil to a nonnull parameter, triggering an NSInvalidArgumentException
		// that propagates through the enclosing dispatch_sync block and corrupts queue state,
		// causing subsequent catalog operations (remove, clear, count) to produce wrong results.
		if (!_bookmarkData) {
			return nil;
		}

		NSError *resolveError = nil;
		BOOL isStale = NO;

		NSURL *nilRelativeURL = nil;
		_url = [NSURL URLByResolvingBookmarkData:_bookmarkData
										options:BE_BOOKMARK_RESOLVE_OPTS
								  relativeToURL:nilRelativeURL
						bookmarkDataIsStale:&isStale
									  error:&resolveError];

		_isStale = isStale;
		_bookmarkError = resolveError;

		if (resolveError) {
			BELogError(@"Failed to resolve bookmark for %@: %@", self.urlString, resolveError);
			return nil;
		}

		if (!_url) {
			BELogError(@"Failed to resolve bookmark for %@: returned nil URL", self.urlString);
			return nil;
		}

		// Handle stale bookmarks by attempting to update them
		if (isStale) {
			[self updateStaleBookmark];
		}

		return _url;
	}
}

/*!
 @method        updateStaleBookmark
 @abstract      Internal method to handle stale bookmark updates and relocation.
 @discussion    When a bookmark is found to be stale during resolution, this method attempts to create a
				new bookmark from the resolved URL. On success it refreshes the bookmark data and clears the
				stale flag. If the resource has been relocated (URL changed), this method notifies the manager
				and updates the catalog keys accordingly. The updated bookmark data is persisted through the
				manager. Runs under the -url getter's per-entry lock.
 */
- (void)updateStaleBookmark {
	BELog(@"Updating stale bookmark for %@", self.urlString);

	NSError *newBookmarkError = nil;
	NSArray *nilResourceKeys = nil;
	NSURL   *nilRelativeURL  = nil;
	NSData *newBookmarkData = [_url bookmarkDataWithOptions:BE_BOOKMARK_CREATE_OPTS
								  includingResourceValuesForKeys:nilResourceKeys
												  relativeToURL:nilRelativeURL
														  error:&newBookmarkError];

	// bookmarkDataWithOptions: can return nil with no error (non-sandboxed); guarding
	// !newBookmarkData avoids overwriting a still-valid bookmark with nil.
	if (newBookmarkError || !newBookmarkData) {
		if (newBookmarkError) {
			BELogError(@"Failed to create updated bookmark for %@: %@", self.urlString, newBookmarkError);
		}
		return;
	}

	_bookmarkData = newBookmarkData;
	// The bookmark was successfully refreshed, so it is no longer stale. (Runs under the -url
	// getter's @synchronized(self).) Without this, the entry reported isStale = YES forever after
	// a successful refresh.
	_isStale = NO;

	// Check if the path changed (relocation)
	NSString *newURLString = _url.absoluteString;
	if (_isDirectory && ![newURLString hasSuffix:@"/"]) {
		newURLString = [newURLString stringByAppendingString:@"/"];
	}
	
	// If relocated, let the manager change the catalog key and the entry's urlString together
	// on the access queue; mutating _urlString here (the catalog key) would desync the two.
	if (![newURLString isEqualToString:_urlString]) {
		NSString *oldURLString = _urlString;

		BESecurityScopedURLManager *manager = self.manager;
		if (manager) {
			[manager handleBookmarkRelocationFromPath:oldURLString toPath:newURLString];
		}
	}

	// Persist if we have a manager
	if (self.manager) {
		[self.manager saveCatalogSynchronously:NO];
	}
}

- (void)applyRelocatedURLString:(NSString *)newURLString {
	@synchronized (self) {
		_urlString = [newURLString copy];
	}
}

#pragma mark - Thread-safe accessors for mutable state

// -url's getter (above) already synchronizes; these complete the coverage so reads from the
// catalog snapshot and writes from the manager (e.g. entry.bookmarkData = …) never race on the
// strong/scalar ivars.

- (void)setUrl:(NSURL *)url {
	@synchronized (self) { _url = url; }
}

- (NSData *)bookmarkData {
	@synchronized (self) { return _bookmarkData; }
}

- (void)setBookmarkData:(NSData *)bookmarkData {
	@synchronized (self) { _bookmarkData = bookmarkData; }
}

- (NSError *)bookmarkError {
	@synchronized (self) { return _bookmarkError; }
}

- (void)setBookmarkError:(NSError *)bookmarkError {
	@synchronized (self) { _bookmarkError = bookmarkError; }
}

- (BOOL)isStale {
	@synchronized (self) { return _isStale; }
}

- (void)setIsStale:(BOOL)isStale {
	@synchronized (self) { _isStale = isStale; }
}

- (NSString *)urlString {
	@synchronized (self) { return _urlString; }
}

@end

#pragma mark - BESecurityScopedURLManager Implementation

@implementation BESecurityScopedURLManager

#pragma mark - Initialization

/*!
 @method        init
 @abstract      Designated initializer for the manager.
 @discussion    Initializes an instance with default storage options (UserDefaults and Cache).
				Sets up the internal access queue for thread-safe operations and loads any existing
				bookmarks from persistence. This method should rarely be called directly; use
				sharedManager for the singleton instance instead.
 @return        A new BESecurityScopedURLManager instance.
 */
- (instancetype)init {
	self = [super init];
	if (self) {
		_storageOptions = BESecurityScopedURLStorageAll;
		_mutableCatalog = [NSMutableDictionary dictionary];
		_refCounts = [NSCountedSet new];
		_resolvedAccessURLByKey = [NSMutableDictionary dictionary];
		_accessQueue = dispatch_queue_create("com.besecurity.urlmanager.queue", DISPATCH_QUEUE_SERIAL);
		
		[self loadCatalog];
	}
	return self;
}

/*!
 @method        sharedManager
 @abstract      Returns the application-wide shared manager instance (thread-safe singleton).
 @discussion    The first call to this method creates the shared instance via dispatch_once. Subsequent
				calls return the same instance. The shared manager persists for the application lifetime.
				This is the recommended way to access the manager in most applications.
 @return        The shared BESecurityScopedURLManager instance.
 */
+ (instancetype)sharedManager {
	static BESecurityScopedURLManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

#pragma mark - Properties

/*!
 @method        setStorageOptions:
 @abstract      Sets the persistence storage options, serialized on the access queue.
 @discussion    storageOptions is read inside accessQueue blocks (loadCatalog,
				saveCatalogSynchronously:, saveCatalogInternal) to decide which stores to
				write. Routing the write through the same serial queue makes those reads
				see a stable value and removes the data race that could otherwise desync the
				two persistence stores (UserDefaults vs. cache file).
 @param         storageOptions The new storage option bitmask.
 */
- (void)setStorageOptions:(BESecurityScopedURLStorageOption)storageOptions {
	dispatch_sync(self.accessQueue, ^{
		self->_storageOptions = storageOptions;
	});
}

/*!
 @method        catalog
 @abstract      Returns a thread-safe snapshot of the current catalog.
 @discussion    This property getter returns a copy of the internal mutable catalog for thread-safety.
				Modifications to the returned dictionary have no effect on the manager's state.
				To modify the catalog, use addURLToCatalog:lifetime:, removeURLFromCatalog:, etc.
 @return        An NSDictionary mapping URL strings to BESecurityScopedURLBookmarkEntry objects.
 */
- (NSDictionary<NSString *, BESecurityScopedURLBookmarkEntry *> *)catalog {
	__block NSDictionary *result;
	dispatch_sync(self.accessQueue, ^{
		result = [self.mutableCatalog copy];
	});
	return result;
}

/*!
 @method        cacheFilePath
 @abstract      Returns the full path to the bookmark archive file in the Caches directory.
 @discussion    This path is computed once on first access using dispatch_once and cached for efficiency.
				Returns nil if the Caches directory cannot be determined. This property is used internally
				for persisting long-lived bookmarks to disk.
 @return        The full file system path to the cache file, or nil if unavailable.
 */
- (NSString *)cacheFilePath {
	// BUG FIX: Do NOT use a global dispatch_once here. A global once-token means every
	// BESecurityScopedURLManager instance — both the shared singleton and any private
	// instances created via -init — would share the same cache-file path, causing
	// concurrent instances to clobber each other's persisted bookmarks.
	//
	// Instead, lazily compute the path once per instance using a simple nil-check.
	// This is safe because cacheFilePath is only ever called from within a
	// dispatch_sync/dispatch_async block on self.accessQueue (a serial queue), so
	// there is no multi-thread race on the ivar for a given instance.
	if (!_cacheFilePath) {
		NSURL *cacheDir = [[NSFileManager defaultManager]
						  URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].firstObject;
		if (cacheDir) {
			NSString *path = [[cacheDir URLByAppendingPathComponent:kBECacheFilename] path];
			_cacheFilePath = [path stringByStandardizingPath];
		}
	}
	return _cacheFilePath;
}

#pragma mark - Catalog Persistence

/*!
 @method        loadCatalog
 @abstract      Internal method to load persisted bookmarks from storage on initialization.
 @discussion    Called automatically by init. Attempts to load bookmarks from configured storage locations
				in order: UserDefaults first (primary), then Cache Directory as a fallback only when
				UserDefaults contains no data. Only long-lived bookmarks are loaded; short-lived bookmarks are session-only.
				Errors during unarchival are logged but do not fail initialization.
				This method executes asynchronously on the accessQueue.
 */
- (void)loadCatalog {
	dispatch_async(self.accessQueue, ^{
		NSData *archivedData = nil;
		
		// Try UserDefaults FIRST (primary storage location)
		if (self.storageOptions & BESecurityScopedURLStorageUserDefaults) {
			NSData *userDefaultsData = [[NSUserDefaults standardUserDefaults]
									   objectForKey:kBEDefaultCatalogKey];
			if (userDefaultsData) {
				archivedData = userDefaultsData;
			}
		}
		
		// Only fall back to Cache Directory if UserDefaults had nothing
		if (!archivedData && (self.storageOptions & BESecurityScopedURLStorageCacheDirectory)) {
			NSString *cachePath = self.cacheFilePath;
			if (cachePath && [[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
				archivedData = [NSData dataWithContentsOfFile:cachePath];
			}
		}
		
		if (!archivedData) {
			return;
		}
		
		@try {
			NSError *error = nil;
			NSSet *allowedClasses = [NSSet setWithObjects:
									[NSDictionary class],
									[BESecurityScopedURLBookmarkEntry class],
									[NSString class],
									[NSDate class],
									[NSData class],
									[NSNumber class],
									nil];
			
			NSDictionary *loadedCatalog = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses
																			  fromData:archivedData
																				 error:&error];
			
			if (error) {
				BELogError(@"Failed to unarchive catalog: %@", error);
				return;
			}
			
			if (!loadedCatalog || ![loadedCatalog isKindOfClass:[NSDictionary class]]) {
				BELogError(@"Loaded catalog is not a valid dictionary");
				return;
			}
			
			// Load only long-lived bookmarks
			for (NSString *key in loadedCatalog) {
				BESecurityScopedURLBookmarkEntry *entry = loadedCatalog[key];
				if (![entry isKindOfClass:[BESecurityScopedURLBookmarkEntry class]]) {
					continue;
				}
				
				if (entry.lifetime == BESecurityScopedURLBookmarkLifetimeLongLived) {
					entry.manager = self;
					self.mutableCatalog[key] = entry;
				}
			}
			
			BELog(@"Loaded %lu bookmarks from persistence", (unsigned long)self.mutableCatalog.count);
		}
		@catch (NSException *exception) {
			BELogError(@"Exception during catalog unarchival: %@", exception);
		}
	});
}

/*!
 @method        saveCatalogSynchronously:
 @abstract      Persists the catalog to configured storage locations.
 @discussion    Archives only long-lived bookmarks (short-lived bookmarks are session-only and not persisted).
				Always writes to UserDefaults if enabled (even empty data to clear stale entries).
				This ensures UserDefaults stays in sync with the manager state. The cache directory
				follows the same write pattern. If synchronously is YES, blocks until the save completes.
				If NO, schedules the save asynchronously on the accessQueue for better performance.
 @param         synchronously If YES, the method blocks until save completes. If NO, returns immediately
				and save happens asynchronously on the accessQueue.
 */
- (void)saveCatalogSynchronously:(BOOL)synchronously {
	void (^saveBlock)(void) = ^{
		// Only archive long-lived bookmarks
		NSMutableDictionary *longLivedCatalog = [NSMutableDictionary dictionary];
		for (NSString *key in self.mutableCatalog) {
			BESecurityScopedURLBookmarkEntry *entry = self.mutableCatalog[key];
			if (entry.lifetime == BESecurityScopedURLBookmarkLifetimeLongLived) {
				longLivedCatalog[key] = entry;
			}
		}
		
		NSError *archiveError = nil;
		NSData *archivedData = nil;
		
		if (longLivedCatalog.count > 0) {
			archivedData = [NSKeyedArchiver archivedDataWithRootObject:longLivedCatalog
													requiringSecureCoding:YES
																  error:&archiveError];
			if (archiveError) {
				BELogError(@"Failed to archive catalog: %@", archiveError);
				// Continue to clear persistence even if archiving fails
			}
		}
		
		// Always save/clear UserDefaults (even with nil/empty data) to keep in sync
		if (self.storageOptions & BESecurityScopedURLStorageUserDefaults) {
			if (archivedData) {
				[[NSUserDefaults standardUserDefaults] setObject:archivedData forKey:kBEDefaultCatalogKey];
			} else {
				[[NSUserDefaults standardUserDefaults] removeObjectForKey:kBEDefaultCatalogKey];
			}
			// No -synchronize: deprecated/no-op on macOS 12+; NSUserDefaults persists automatically.
		}

		// Always save/clear Cache Directory (even with nil/empty data) to keep in sync
		if (self.storageOptions & BESecurityScopedURLStorageCacheDirectory) {
			NSString *cachePath = self.cacheFilePath;
			if (cachePath) {
				if (archivedData) {
					NSError *writeError = nil;
					if (![archivedData writeToFile:cachePath options:NSDataWritingAtomic error:&writeError]) {
						BELogError(@"Failed to write cache file: %@", writeError);
					}
				} else {
					NSError *removeError = nil;
					[[NSFileManager defaultManager] removeItemAtPath:cachePath error:&removeError];
				}
			}
		}
	};
	
	if (synchronously) {
		dispatch_sync(self.accessQueue, saveBlock);
	} else {
		dispatch_async(self.accessQueue, saveBlock);
	}
}

#pragma mark - Bookmark Management

/*!
 @method        addURLToCatalog:lifetime:
 @abstract      Creates a security-scoped bookmark for the given URL and adds it to the catalog.
 @discussion    If the URL is already in the catalog, its bookmark data and metadata are updated.
				The URL must be a valid file URL. This method verifies the resource can be bookmarked
				before adding it. Long-lived bookmarks are persisted asynchronously to configured storage.
				Short-lived bookmarks exist only in memory for the current session.
 @param         url The file URL to bookmark. Must be a valid file URL (not nil).
 @param         lifetime The persistence option: short-lived (session-only) or long-lived (persisted).
 @return        YES if the bookmark was created and added successfully, NO if URL is invalid or
				bookmark creation failed.
 */
- (BOOL)addURLToCatalog:(NSURL *)url lifetime:(BESecurityScopedURLBookmarkLifetime)lifetime {
	if (!url || !url.isFileURL) {
		BELogError(@"Invalid URL provided to addURLToCatalog:");
		return NO;
	}
	
	BESecurityScopedURLBookmarkEntry *entry = [[BESecurityScopedURLBookmarkEntry alloc]
											   initWithURL:url lifetime:lifetime];
	if (!entry) {
		BELogError(@"Failed to create bookmark entry for %@", url.absoluteString);
		return NO;
	}
	
	entry.manager = self;
	
	__block BOOL success = NO;
	dispatch_sync(self.accessQueue, ^{
		// End any existing access for this URL before replacing.
		// IMPORTANT: refCounts holds the *resolved* URL produced by URLByResolvingBookmarkData:,
		// which may differ from `url` due to symlink expansion (e.g. /var/... → /private/var/...).
		// We must look up the existing catalog entry and resolve it via the catalog to obtain the
		// same URL form that was stored in refCounts, then call endAccessingURLInternal: on that
		// resolved form so the ref-count lookup matches. Fall back to `url` only when the catalog
		// has no pre-existing entry or resolution returns nil.
		BESecurityScopedURLBookmarkEntry *existingEntry = self.mutableCatalog[entry.urlString];
		if (existingEntry) {
			NSURL *existingResolvedURL = [self urlFromCatalogWithAbsolutePathInternal:existingEntry.urlString];
			if (existingResolvedURL) {
				// If the resolved (canonical) URL isn't in refCounts, fall back to the
				// raw url — refCounts may hold a pre-resolution (symlink) form.
				if (![self endAccessingURLInternal:existingResolvedURL]) {
					[self endAccessingURLInternal:url];
				}
			} else {
				[self endAccessingURLInternal:url];
			}
		}

		// Add the new entry
		self.mutableCatalog[entry.urlString] = entry;
		success = YES;
	});
	
	// Persist long-lived bookmarks asynchronously
	if (lifetime == BESecurityScopedURLBookmarkLifetimeLongLived && success) {
		[self saveCatalogSynchronously:NO];
	}
	
	return success;
}

/*!
 @method        removeURLFromCatalog:
 @abstract      Removes the bookmark associated with the given URL from the catalog and persistence.
 @discussion    This is a convenience method that resolves the URL and calls the canonical removal method.
				Automatically ends any active reference-counted access sessions and persists the removal.
				This is a thread-safe operation.
 @param         url The file URL whose bookmark should be removed. If nil, this method returns without error.
 */
- (void)removeURLFromCatalog:(NSURL *)url {
	if (!url) {
		return;
	}
	
	// FIX: Perform the entire lookup-and-remove in a single dispatch_sync so the
	// catalog key used for removal is the exact key that was stored at add-time.
	//
	// The original two-step approach called urlFromCatalog: (outside the sync block)
	// and then removed by resolvedURL.absoluteString (inside the sync block). This
	// silently failed because URLByResolvingBookmarkData: expands symlinks — e.g.
	// /var/folders → /private/var/folders — so resolvedURL.absoluteString differed
	// from the stored catalog key, which is always the original unresolved URL string.
	//
	// Fix: look up the entry by the input URL's absoluteString directly. Directory
	// entries are normalized with a trailing slash in initWithURL:lifetime:, so we
	// also check a trailing-slash variant. Either way we remove by the exact stored
	// key — never by a symlink-resolved URL string.
	dispatch_sync(self.accessQueue, ^{
		NSString *catalogKey = url.absoluteString;
		
		if (!self.mutableCatalog[catalogKey]) {
			// Directory entries are stored with a trailing slash. Check that variant.
			NSString *withSlash = [catalogKey hasSuffix:@"/"]
				? catalogKey
				: [catalogKey stringByAppendingString:@"/"];
			if (self.mutableCatalog[withSlash]) {
				catalogKey = withSlash;
			}
		}
		
		BESecurityScopedURLBookmarkEntry *entry = self.mutableCatalog[catalogKey];
		if (entry) {
			// End any active security-scoped access using the entry's stored urlString.
			// We deliberately avoid calling entry.url here: that triggers lazy bookmark
			// resolution which could call handleBookmarkRelocationFromPath: dispatching
			// async onto this queue while we are already holding it synchronously.
			NSURL *storedURL = [NSURL URLWithString:entry.urlString];
			if (storedURL) {
				[self endAccessingURLInternal:storedURL];
			}
			[self.mutableCatalog removeObjectForKey:catalogKey];
		}
		
		[self saveCatalogInternal];
	});
}

/*!
 @method        removeAbsolutePathFromCatalog:
 @abstract      Removes the bookmark entry associated with the given absolute path string.
 @discussion    This is a convenience method that converts the string to an NSURL and calls removeURLFromCatalog:.
				It ends any active reference-counted access sessions and persists the removal.
				This is a thread-safe operation.
 @param         absolutePathString The canonical absolute string path of the bookmark key.
				If nil, this method returns without error.
 */
- (void)removeAbsolutePathFromCatalog:(NSString *)absolutePathString {
	if (!absolutePathString) {
		return;
	}
	
	[self removeURLFromCatalog:[NSURL URLWithString:absolutePathString]];
}

/*!
 @method        clearCatalog
 @abstract      Removes all bookmarks from the catalog, ends all access sessions, and clears persistence.
 @discussion    This comprehensive cleanup method removes all entries and releases all security-scoped access.
				All reference counts are released and underlying resource access is terminated.
				Persisted bookmarks in all storage locations are also cleared.
				This is a thread-safe operation that executes atomically.
 */
- (void)clearCatalog {
	// FIX (Deadlock 5): The original code called endAccessingAllURLs inside a
	// dispatch_sync(accessQueue) block. endAccessingAllURLs itself calls
	// dispatch_sync(accessQueue) — a serial-queue re-entry deadlock.
	// Fix: use endAccessingAllURLsInternal which performs the same teardown without
	// dispatching. saveCatalogInternal is similarly used to keep everything in one
	// atomic dispatch block so clearCatalog is fully serialized end-to-end.
	dispatch_sync(self.accessQueue, ^{
		[self endAccessingAllURLsInternal];
		[self.mutableCatalog removeAllObjects];
		[self saveCatalogInternal];
	});
}

#pragma mark - URL Resolution

/*!
 @method        urlFromCatalog:
 @abstract      Resolves a URL from the catalog, handling staleness and directory containment.
 @discussion    If the provided URL matches a direct bookmark or is contained within a bookmarked directory,
				the resolved URL is returned. Stale bookmarks are automatically updated and the delegate is
				notified of relocations. This method does NOT start access; use startAccessingURLWithAbsolutePath:
				for reference-counted access. This is a thread-safe operation.
 @param         url The URL to resolve, which may be stale or contained within a bookmarked directory.
				Must be a file URL or nil.
 @return        The current, resolved URL from the catalog, or nil if not found or URL is invalid.
 */
- (nullable NSURL *)urlFromCatalog:(NSURL *)url {
	if (!url || !url.isFileURL) {
		return nil;
	}
	
	return [self urlFromCatalogWithAbsolutePath:url.absoluteString];
}

/*!
 @method        urlFromCatalogWithAbsolutePath:
 @abstract      Thread-safe public entry point for multi-strategy URL resolution.
 @discussion    This method is a thin, thread-safe wrapper: it acquires the serial accessQueue
				via dispatch_sync and delegates all resolution work to
				urlFromCatalogWithAbsolutePathInternal:, which is the single source of truth
				for Tier 1–4 URL resolution.

				All resolution behaviour — direct catalog match, refCounts lookup,
				directory containment, and filename search — is documented on
				urlFromCatalogWithAbsolutePathInternal:.

				This method does NOT prompt the user. For stale bookmarks that can't be
				resolved, use startAccessingURL: which invokes the delegate.
				This is a thread-safe operation.
 @param         absolutePathString The canonical absolute string of the URL in the catalog.
 @return        The resolved URL from the catalog/directories, or nil if not found.
 */
- (nullable NSURL *)urlFromCatalogWithAbsolutePath:(NSString *)absolutePathString {
	if (!absolutePathString) {
		return nil;
	}
	
	// Delegate all resolution logic to the non-dispatching internal method, wrapped
	// in a single dispatch_sync so any calling thread gets a consistent, thread-safe
	// view of the catalog and refCounts. urlFromCatalogWithAbsolutePathInternal: is
	// the single source of truth for all Tier 1-4 resolution; this public method
	// adds only the queue barrier — nothing more.
	__block NSURL *resolvedURL = nil;
	dispatch_sync(self.accessQueue, ^{
		resolvedURL = [self urlFromCatalogWithAbsolutePathInternal:absolutePathString];
	});
	return resolvedURL;
}

/*!
 @method        objectForKeyedSubscript:
 @abstract      Allows subscript access to resolve URLs using array-like syntax.
 @discussion    Supports subscript notation for convenient URL resolution: manager[url] or manager[@"file:///path"].
				Accepts either NSURL or NSString keys. This is equivalent to calling urlFromCatalog: or
				urlFromCatalogWithAbsolutePath: depending on the key type.
 @param         key An NSURL or NSString key for URL resolution.
 @return        The resolved URL, or nil if not found or key type is unsupported.
 */
- (nullable NSURL *)objectForKeyedSubscript:(id)key {
	if ([key isKindOfClass:[NSURL class]]) {
		return [self urlFromCatalog:(NSURL *)key];
	} else if ([key isKindOfClass:[NSString class]]) {
		return [self urlFromCatalogWithAbsolutePath:(NSString *)key];
	}
	return nil;
}

#pragma mark - Access Control (Direct)

/*!
 @method        startAccessingURL:
 @abstract      Starts security-scoped access for a given URL with reference counting.
 @discussion    Resolves the URL from the catalog and starts security-scoped access if not already active.
				If the URL cannot be resolved or access fails, notifies the delegate via the
				accessFailedForURL:entry:completionHandler: callback. The delegate is responsible for
				deciding how to handle the failure (show UI, try alternatives, ignore, etc.).
				
				Reference counting ensures that access is maintained until all callers have called
				the corresponding end method. This is a thread-safe operation.
 @param         url The URL for which to start access. If nil, returns nil.
 @return        The resolved URL if access was successfully started, nil otherwise.
 */
- (nullable NSURL *)startAccessingURL:(NSURL *)url {
	if (!url) {
		return nil;
	}
	
	__block NSURL *resolvedURL = nil;
	__block BOOL success = NO;
	__block BESecurityScopedURLBookmarkEntry *entry = nil;
	
	// FIX (Deadlock 1): Use the non-dispatching internal resolver so that this single
	// dispatch_sync does not nest a second dispatch_sync onto the same serial queue.
	// Previously this block called urlFromCatalogWithAbsolutePath:, which itself called
	// dispatch_sync(self.accessQueue) — a guaranteed deadlock on a serial queue.
	dispatch_sync(self.accessQueue, ^{
		resolvedURL = [self urlFromCatalogWithAbsolutePathInternal:url.absoluteString];
		
		if (!resolvedURL) {
			// Resolution failed - get the entry for delegate callback
			entry = self.mutableCatalog[url.absoluteString];
			return;
		}
		
		// Start access if not already started
		if (![self.refCounts containsObject:resolvedURL]) {
			success = [resolvedURL startAccessingSecurityScopedResource];
		} else {
			success = YES;
		}
		
		if (success) {
			[self.refCounts addObject:resolvedURL];
		} else {
			// Access failed (likely stale bookmark) - prepare for delegate callback
			entry = self.mutableCatalog[url.absoluteString];
			resolvedURL = nil;
		}
	});
	
	// FIX (Deadlock 6): The original code always dispatched async to the main thread
	// then blocked the calling thread with dispatch_semaphore_wait.  When this method
	// was called from the main thread (e.g. from a button action or app launch), the
	// main thread blocked forever on the semaphore: the only block that could signal
	// it was queued on that same frozen main thread — an irreversible deadlock.
	//
	// Fix: if we are already on the main thread, call the delegate synchronously so
	// we never block the main thread.  Only use the semaphore + async pattern on
	// background threads where blocking is safe.
	if (!resolvedURL && [self.delegate respondsToSelector:@selector(securityScopedURLManager:accessFailedForURL:entry:completionHandler:)]) {
		__block NSURL *delegateURL = nil;
		
		if ([NSThread isMainThread]) {
			// Already on the main thread — call the delegate inline to avoid deadlock.
			[self.delegate securityScopedURLManager:self
								 accessFailedForURL:url
											  entry:entry
								  completionHandler:^(NSURL * _Nullable relocatedURL) {
				delegateURL = relocatedURL;
			}];
		} else {
			// Background thread — safe to block here while the delegate shows UI.
			dispatch_semaphore_t delegateSemaphore = dispatch_semaphore_create(0);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.delegate securityScopedURLManager:self
									 accessFailedForURL:url
												  entry:entry
									  completionHandler:^(NSURL * _Nullable relocatedURL) {
					delegateURL = relocatedURL;
					dispatch_semaphore_signal(delegateSemaphore);
				}];
			});
			
			// Wait indefinitely — the delegate controls when it calls the completion handler
			// (e.g. after the user dismisses an NSOpenPanel). Imposing a timeout would force
			// the background thread to continue before the user has made a choice, which is
			// never the right behaviour. The delegate contract requires exactly one call to
			// the completion handler — failing to call it will permanently block this thread,
			// which is the correct signal that the delegate implementation is broken.
			dispatch_semaphore_wait(delegateSemaphore, DISPATCH_TIME_FOREVER);
		}
		
		if (delegateURL) {
			// Delegate provided a URL — try to access it.  This dispatch_sync is safe:
			// the first one completed before we reached this point in the call stack.
			dispatch_sync(self.accessQueue, ^{
				// The queue was free during the (possibly long) delegate call: a concurrent
				// clear/remove/add may have replaced the entry. Don't resurrect a stale entry —
				// only re-key if it's still the live catalog entry. (Access is still granted.)
				BOOL entryStillValid = (entry != nil && self.mutableCatalog[url.absoluteString] == entry);

				if (![self.refCounts containsObject:delegateURL]) {
					success = [delegateURL startAccessingSecurityScopedResource];
				} else {
					success = YES;
				}

				if (success) {
					[self.refCounts addObject:delegateURL];
					resolvedURL = delegateURL;

					// If the relocated URL differs from the original, refresh the bookmark
					// and move the catalog entry to the new key — but only if the entry is
					// still the live catalog entry (not removed/replaced during the gap).
					if (entryStillValid && ![delegateURL.absoluteString isEqualToString:url.absoluteString]) {
						NSError *bookmarkError = nil;
						NSArray *nilResourceKeys = nil;
						NSURL   *nilRelativeURL  = nil;
						NSData *newBookmarkData = [delegateURL bookmarkDataWithOptions:BE_BOOKMARK_CREATE_OPTS
															  includingResourceValuesForKeys:nilResourceKeys
																			  relativeToURL:nilRelativeURL
																					  error:&bookmarkError];
						
						if (!bookmarkError && newBookmarkData) {
							entry.bookmarkData = newBookmarkData;
							entry.url = delegateURL;
							entry.isStale = NO;
							
							NSString *newAbsolutePath = delegateURL.absoluteString;
							if (entry.isDirectory && ![newAbsolutePath hasSuffix:@"/"]) {
								newAbsolutePath = [newAbsolutePath stringByAppendingString:@"/"];
							}
							
							if (![newAbsolutePath isEqualToString:url.absoluteString]) {
								[self.mutableCatalog removeObjectForKey:url.absoluteString];
								self.mutableCatalog[newAbsolutePath] = entry;
							}
							
							if (entry.lifetime == BESecurityScopedURLBookmarkLifetimeLongLived) {
								[self saveCatalogSynchronously:NO];
							}
						}
					}
				}
			});
			
			if (success && ![delegateURL.absoluteString isEqualToString:url.absoluteString]) {
				if ([self.delegate respondsToSelector:@selector(securityScopedURLManager:didRelocateURL:toURL:)]) {
					[self.delegate securityScopedURLManager:self
											 didRelocateURL:url
													  toURL:delegateURL];
				}
			}
		}
	}
	
	return resolvedURL;
}


/*!
 @method        urlFromCatalogWithAbsolutePathInternal:
 @abstract      Single source of truth for all Tier 1–4 URL resolution. No dispatch.
 @discussion    Contains ALL resolution logic. The public urlFromCatalogWithAbsolutePath:
				is a thin dispatch_sync wrapper around this method and contains no other
				logic, eliminating code duplication while preserving thread safety.
				Callers that already hold the accessQueue (startAccessingURL:,
				startAccessingAllURLs, endAccessingURLWithAbsolutePath:) call this method
				directly to avoid the dispatch-within-dispatch deadlock that would result
				from calling the public wrapper.
				This method MUST only be called from within a block already executing
				on self.accessQueue.
 @param         absolutePathString The canonical absolute string of the URL to resolve.
 @return        The resolved URL, or nil if not found in the catalog or bookmarked directories.
 */
- (nullable NSURL *)urlFromCatalogWithAbsolutePathInternal:(NSString *)absolutePathString {
	if (!absolutePathString) {
		return nil;
	}
	
	// TIER 1: Direct bookmark match
	BESecurityScopedURLBookmarkEntry *entry = self.mutableCatalog[absolutePathString];
	if (entry) {
		NSURL *resolvedURL = entry.url; // Triggers lazy resolution + staleness handling
		if (!entry.bookmarkError) {
			return resolvedURL;
		}
		BELog(@"Error resolving bookmark for %@: %@", absolutePathString, entry.bookmarkError);
		// Fall through to lower tiers
	}
	
	// TIER 2: Already present in active refCounts
	NSURL *checkURL = [NSURL URLWithString:absolutePathString];
	if ([self.refCounts containsObject:checkURL]) {
		return [self.refCounts member:checkURL];
	}
	
	// TIER 3: Directory containment — input path is inside a bookmarked directory.
	// Compare FILESYSTEM paths, not URL strings: derive the input's path (via -[NSURL path],
	// which also percent-decodes) so it has the same form as directoryURL.path. Comparing the
	// "file:///…" absoluteString against the "/…" directory path never matched, so directory
	// containment silently never resolved.
	NSString *inputPath = [[NSURL URLWithString:absolutePathString].path stringByStandardizingPath];
	if (!inputPath) {
		inputPath = [([absolutePathString stringByRemovingPercentEncoding] ?: absolutePathString) stringByStandardizingPath];
	}

	for (NSString *key in self.mutableCatalog.allKeys) {
		BESecurityScopedURLBookmarkEntry *dirEntry = self.mutableCatalog[key];
		if (!dirEntry.isDirectory) { continue; }

		NSURL *directoryURL = dirEntry.url;
		if (!directoryURL) { continue; }

		NSString *dirPath = [directoryURL.path stringByStandardizingPath];
		// Boundary-safe containment: the directory itself, or a path strictly beneath it. The
		// "/"-delimited prefix prevents a sibling like /a/ProjectsX matching a /a/Projects bookmark.
		NSString *dirPrefix = [dirPath hasSuffix:@"/"] ? dirPath : [dirPath stringByAppendingString:@"/"];
		if ([inputPath isEqualToString:dirPath] || [inputPath hasPrefix:dirPrefix]) {
			NSString *relativePath = [inputPath substringFromIndex:dirPath.length];
			while ([relativePath hasPrefix:@"/"]) {
				relativePath = [relativePath substringFromIndex:1];
			}
			NSURL *resolvedURL = [directoryURL URLByAppendingPathComponent:relativePath];
			
			if ([self.delegate respondsToSelector:@selector(securityScopedURLManager:willResolveContainedURL:withinDirectoryURL:)]) {
				NSURL *capturedInput  = [NSURL URLWithString:absolutePathString];
				NSURL *capturedDirURL = directoryURL;
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.delegate securityScopedURLManager:self
								 willResolveContainedURL:capturedInput
									  withinDirectoryURL:capturedDirURL];
				});
			}
			return resolvedURL;
		}
	}
	
	// TIER 4: Filename search across all bookmarked directories
	NSString *fileName = [inputPath lastPathComponent];
	if (fileName.length > 0) {
		for (NSString *key in self.mutableCatalog.allKeys) {
			BESecurityScopedURLBookmarkEntry *dirEntry = self.mutableCatalog[key];
			if (!dirEntry.isDirectory) { continue; }
			
			NSURL *directoryURL = dirEntry.url;
			if (!directoryURL) { continue; }
			
			NSURL *potentialURL = [directoryURL URLByAppendingPathComponent:fileName];
			NSNumber *isRegularFile = nil;
			NSError *fileCheckError = nil;
			if ([potentialURL getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:&fileCheckError]) {
				if ([isRegularFile boolValue]) {
					BELog(@"Tier 4: Found matching filename in bookmarked directory: %@", potentialURL.path);
					return potentialURL;
				}
			}
		}
	}
	
	return nil;
}

/*!
 @method        startAccessingURLInternal:
 @abstract      Non-dispatching core implementation of reference-counted access start.
 @discussion    Resolves the URL via urlFromCatalogWithAbsolutePathInternal: and calls
				startAccessingSecurityScopedResource if the URL is not already in refCounts.
				If startAccessingSecurityScopedResource returns NO (the URL is outside the
				current security scope), the method returns nil without modifying refCounts.
				If the URL is already in refCounts (a second caller acquiring access to the
				same resource), the method increments the count and returns the URL directly
				without making a second OS call.
				This method MUST only be called from within a block already executing on
				self.accessQueue. It contains no dispatch calls.
 @param         url The URL for which to start access.
 @return        The resolved URL if access was successfully started, nil otherwise.
 */
- (nullable NSURL *)startAccessingURLInternal:(NSURL *)url {
	if (!url) {
		return nil;
	}

	NSURL *resolvedURL = [self urlFromCatalogWithAbsolutePathInternal:url.absoluteString];
	if (!resolvedURL) {
		return nil;
	}

	if (![self.refCounts containsObject:resolvedURL]) {
		if (![resolvedURL startAccessingSecurityScopedResource]) {
			return nil;
		}
	}

	[self.refCounts addObject:resolvedURL];
	// Remember the resolved form keyed by the catalog key, so relocation can transfer the
	// count even when the key (url.absoluteString) and the resolved form differ.
	self.resolvedAccessURLByKey[url.absoluteString] = resolvedURL;
	return resolvedURL;
}

/*!
 @method        endAccessingAllURLsInternal
 @abstract      Non-dispatching core implementation of bulk access teardown.
 @discussion    Drains refCounts completely and calls stopAccessingSecurityScopedResource
				on each unique URL.  This method MUST only be called from within a block
				already executing on self.accessQueue.  It exists to break the deadlock in
				clearCatalog, which called endAccessingAllURLs (a dispatch_sync) from inside
				its own dispatch_sync block.
 */
- (void)endAccessingAllURLsInternal {
	NSArray<NSURL *> *activeURLs = self.refCounts.allObjects;
	for (NSURL *url in activeURLs) {
		NSUInteger count = [self.refCounts countForObject:url];
		for (NSUInteger i = 0; i < count; i++) {
			[self.refCounts removeObject:url];
		}
		[url stopAccessingSecurityScopedResource];
	}
}

/*!
 @method        saveCatalogInternal
 @abstract      Non-dispatching core implementation of catalog persistence.
 @discussion    Archives long-lived bookmarks and writes to all configured storage locations
				(UserDefaults and/or the Caches directory).  This method MUST only be called
				from within a block already executing on self.accessQueue.  It exists to break
				the deadlock in removeURLFromCatalog:, which called saveCatalogSynchronously:YES
				(a dispatch_sync) from inside its own dispatch_sync block.
 */
- (void)saveCatalogInternal {
	// Collect only long-lived bookmarks for persistence
	NSMutableDictionary *longLivedCatalog = [NSMutableDictionary dictionary];
	for (NSString *key in self.mutableCatalog) {
		BESecurityScopedURLBookmarkEntry *entry = self.mutableCatalog[key];
		if (entry.lifetime == BESecurityScopedURLBookmarkLifetimeLongLived) {
			longLivedCatalog[key] = entry;
		}
	}
	
	NSError *archiveError = nil;
	NSData *archivedData = nil;
	
	if (longLivedCatalog.count > 0) {
		archivedData = [NSKeyedArchiver archivedDataWithRootObject:longLivedCatalog
												requiringSecureCoding:YES
																error:&archiveError];
		if (archiveError) {
			BELogError(@"Failed to archive catalog: %@", archiveError);
		}
	}
	
	// Always write (or clear) UserDefaults to keep it in sync
	if (self.storageOptions & BESecurityScopedURLStorageUserDefaults) {
		if (archivedData) {
			[[NSUserDefaults standardUserDefaults] setObject:archivedData forKey:kBEDefaultCatalogKey];
		} else {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:kBEDefaultCatalogKey];
		}
		// No -synchronize: deprecated/no-op on macOS 12+; NSUserDefaults persists automatically.
	}

	// Always write (or clear) the cache file to keep it in sync
	if (self.storageOptions & BESecurityScopedURLStorageCacheDirectory) {
		NSString *cachePath = self.cacheFilePath;
		if (cachePath) {
			if (archivedData) {
				NSError *writeError = nil;
				if (![archivedData writeToFile:cachePath options:NSDataWritingAtomic error:&writeError]) {
					BELogError(@"Failed to write cache file: %@", writeError);
				}
			} else {
				NSError *removeError = nil;
				[[NSFileManager defaultManager] removeItemAtPath:cachePath error:&removeError];
			}
		}
	}
}

#pragma mark - Internal Helper Methods

/*!
 @method        endAccessingURLInternal:
 @abstract      Internal implementation of endAccessingURL without dispatch_sync.
 @discussion    This helper prevents deadlock by not calling dispatch_sync on self.accessQueue.
				Called directly from within dispatch_sync blocks.
 @param         url The URL for which to end access.
 @return        YES if access was successfully ended, NO otherwise.
 */
- (BOOL)endAccessingURLInternal:(NSURL *)url {
	if (!url) {
		return NO;
	}
	
	if (![self.refCounts containsObject:url]) {
		return NO;
	}
	
	// Only stop access if this is the last reference
	if ([self.refCounts countForObject:url] == 1) {
		[url stopAccessingSecurityScopedResource];
	}
	
	[self.refCounts removeObject:url];
	return YES;
}

/*!
 @method        endAccessingURL:
 @abstract      Ends security-scoped access for a given URL with reference counting.
 @discussion    Decrements the reference count for the URL and stops the underlying resource access
				only if the count reaches zero. This allows multiple parts of the application to safely
				share access to the same resource. This is a thread-safe operation.
 @param         url The URL for which to end access. If nil, returns NO.
 @return        YES if access was successfully ended or was not active, NO if an error occurred.
 */
- (BOOL)endAccessingURL:(NSURL *)url {
	if (!url) {
		return NO;
	}
	
	__block BOOL success = NO;
	
	dispatch_sync(self.accessQueue, ^{
		success = [self endAccessingURLInternal:url];
	});
	
	return success;
}

#pragma mark - Access Control (Reference-Counted)

/*!
 @method        startAccessingURLWithAbsolutePath:
 @abstract      Resolves a bookmarked URL path and starts reference-counted access to it.
 @discussion    Convenience method that converts the string to an NSURL and calls startAccessingURL:.
				If the URL is found and access starts successfully, the resolved URL is returned.
				Reference counting ensures proper access management across multiple callers.
				This is a thread-safe operation.
 @param         absolutePathString The canonical absolute string of the URL in the catalog.
 @return        The resolved URL if access successfully started, otherwise nil.
 */
- (nullable NSURL *)startAccessingURLWithAbsolutePath:(NSString *)absolutePathString {
	if (!absolutePathString) {
		return nil;
	}
	
	NSURL *url = [NSURL URLWithString:absolutePathString];
	return [self startAccessingURL:url];
}

/*!
 @method        endAccessingURLWithAbsolutePath:
 @abstract      Ends reference-counted access for a bookmarked URL path.
 @discussion    Convenience method that resolves the URL string and calls endAccessingURL:.
				Decrements the reference count and stops underlying resource access if the count
				reaches zero. This is a thread-safe operation.
 @param         absolutePathString The canonical absolute string of the URL in the catalog.
 @return        YES if access was successfully ended or was not active, NO if path not found.
 */
- (BOOL)endAccessingURLWithAbsolutePath:(NSString *)absolutePathString {
	if (!absolutePathString) {
		return NO;
	}
	
	// FIX (Deadlock 3): The original code called dispatch_sync(accessQueue) here, then
	// inside that block called urlFromCatalogWithAbsolutePath:, which also calls
	// dispatch_sync(accessQueue) — a serial-queue re-entry deadlock.
	// Fix: use the non-dispatching internal resolver, and combine the resolve + end
	// steps into a single dispatch_sync using endAccessingURLInternal: so we never
	// nest a second dispatch onto the same queue.
	__block BOOL success = NO;
	dispatch_sync(self.accessQueue, ^{
		NSURL *resolvedURL = [self urlFromCatalogWithAbsolutePathInternal:absolutePathString];
		success = [self endAccessingURLInternal:resolvedURL];
		if (!success) {
			// The catalog-resolved URL was not in refCounts; fall back to the raw input URL.
			// This handles cases where refCounts holds a pre-resolution (symlink) form that
			// does not match the canonical form returned by bookmark resolution.
			NSURL *rawURL = [NSURL URLWithString:absolutePathString];
			if (rawURL && ![rawURL isEqual:resolvedURL]) {
				success = [self endAccessingURLInternal:rawURL];
			}
		}
	});
	return success;
}

#pragma mark - Bulk Access Control

/*!
 @method        startAccessingAllURLs
 @abstract      Starts reference-counted access for every URL in the catalog.
 @discussion    Useful on application launch or after loading the catalog to ensure all bookmarked
				resources are immediately accessible. Returns the array of successfully accessed URLs.
				The returned URLs are guaranteed to have active security-scoped access until endAccessingAllURLs
				is called. This is a thread-safe, atomic operation.
 @return        An array of all resolved URLs for which access was successfully started. May be empty
				if no bookmarks exist or none could be accessed.
 */
- (NSArray<NSURL *> *)startAccessingAllURLs {
	__block NSMutableArray *accessedURLs = [NSMutableArray array];
	
	// FIX (Deadlock 2): The original code called startAccessingURL: inside a
	// dispatch_sync(accessQueue) block. startAccessingURL: itself calls
	// dispatch_sync(accessQueue) — a serial-queue re-entry deadlock.
	// Fix: use startAccessingURLInternal: which performs the same logic without
	// dispatching, safe to call from within an already-dispatched block.
	dispatch_sync(self.accessQueue, ^{
		for (BESecurityScopedURLBookmarkEntry *entry in self.mutableCatalog.allValues) {
			NSURL *url = entry.url;
			if (url) {
				NSURL *accessedURL = [self startAccessingURLInternal:url];
				if (accessedURL) {
					[accessedURLs addObject:accessedURL];
				}
			}
		}
	});
	
	return [accessedURLs copy];
}

/*!
 @method        endAccessingAllURLs
 @abstract      Ends all reference-counted access sessions tracked by the manager.
 @discussion    Releases access for all bookmarked resources regardless of how many times
				startAccessingAllURLs or individual start methods were called. This is typically
				called during application shutdown or when access to all bookmarked resources should
				be released. This is a thread-safe operation.
 */
- (void)endAccessingAllURLs {
	dispatch_sync(self.accessQueue, ^{
		NSArray<NSURL *> *activeURLs = self.refCounts.allObjects;
		
		for (NSURL *url in activeURLs) {
			// Remove all reference counts for this URL
			NSUInteger count = [self.refCounts countForObject:url];
			for (NSUInteger i = 0; i < count; i++) {
				[self.refCounts removeObject:url];
			}
			
			// Stop access
			[url stopAccessingSecurityScopedResource];
		}
	});
}

#pragma mark - Internal Helpers

/*!
 @method        handleBookmarkRelocationFromPath:toPath:
 @abstract      Internal method to handle bookmark relocation updates.
 @discussion    Called when a stale bookmark is resolved and found to have moved to a new path.
				This method updates the internal catalog to use the new path as the key, transfers any
				active reference counts to the new path, and notifies the delegate of the relocation
				(on the main thread). This is an asynchronous operation on the accessQueue.
 @param         oldPath The original catalog key (stale path).
 @param         newPath The new catalog key after relocation.
 @note          Active reference counts are keyed in refCounts by the symlink-resolved URL form
				captured at access-start (tracked in resolvedAccessURLByKey).  The transfer looks up
				that resolved form for oldPath, so counts move to newPath even when the catalog key
				and its resolved form differ (e.g. /var/... vs /private/var/...).
 */
- (void)handleBookmarkRelocationFromPath:(NSString *)oldPath toPath:(NSString *)newPath {
	dispatch_async(self.accessQueue, ^{
		// Update the catalog entry key
		BESecurityScopedURLBookmarkEntry *entry = self.mutableCatalog[oldPath];
		if (!entry) {
			return;
		}
		[self.mutableCatalog removeObjectForKey:oldPath];
		self.mutableCatalog[newPath] = entry;
		// Change the entry's urlString together with its dictionary key, here on the queue.
		[entry applyRelocatedURLString:newPath];

		// Transfer any reference counts.  refCounts is keyed by the symlink-resolved URL
		// captured at access-start, which may differ from the catalog key oldPath (e.g.
		// /var/… resolves to /private/var/…).  Look up the resolved form so active counts
		// actually transfer; fall back to oldPath when no access was started.
		NSURL *oldResolved = self.resolvedAccessURLByKey[oldPath] ?: [NSURL URLWithString:oldPath];
		NSUInteger refCount = [self.refCounts countForObject:oldResolved];
		if (refCount > 0) {
			NSURL *newURL = [NSURL URLWithString:newPath];
			for (NSUInteger i = 0; i < refCount; i++) {
				[self.refCounts removeObject:oldResolved];
				[self.refCounts addObject:newURL];
			}
			self.resolvedAccessURLByKey[newPath] = newURL;
		}
		[self.resolvedAccessURLByKey removeObjectForKey:oldPath];

		// Capture the URL on the queue; the main-thread block must not read mutableCatalog off-queue.
		NSURL *relocatedURL = entry.url;
		if (relocatedURL &&
			[self.delegate respondsToSelector:@selector(securityScopedURLManager:didRelocateURL:toURL:)]) {
			NSURL *oldURL = [NSURL URLWithString:oldPath];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.delegate securityScopedURLManager:self
										 didRelocateURL:oldURL
												  toURL:relocatedURL];
			});
		}
	});
}

#pragma mark - NSFastEnumeration

/*!
 @method        countByEnumeratingWithState:objects:count:
 @abstract      Enables fast enumeration over the catalog entries.
 @discussion    Implements NSFastEnumeration protocol to allow the manager to be used in for-in loops.
				Example: for (BESecurityScopedURLBookmarkEntry *entry in manager) { ... }
				Returns a thread-safe snapshot of the catalog for enumeration.
 @param         state Pointer to NSFastEnumerationState structure.
 @param         buffer Pointer to array to receive object pointers.
 @param         len Maximum number of objects to return.
 @return        Number of objects returned in buffer, or 0 to indicate enumeration complete.
 */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
								   objects:(__unsafe_unretained id _Nullable *_Nonnull)buffer
									 count:(NSUInteger)len {
	// BUG FIX: NSDictionary fast-enumeration yields keys (NSString), not values.
	// The documented and expected behaviour is "for (BESecurityScopedURLBookmarkEntry *entry in manager)"
	// which requires enumerating the dictionary values (the entry objects), not the keys.
	return [self.catalog.allValues countByEnumeratingWithState:state objects:buffer count:len];
}

@end

#pragma mark - NSURL Convenience Category Implementation

@implementation NSURL (BESecurityScopedURLManagerHelpers)

/*!
 @method        ss_startAccessingSecurityScopedResource
 @abstract      Starts reference-counted security-scoped access for this URL via the shared manager.
 @discussion    Convenience method that delegates to the shared manager's startAccessingURL: method.
				The underlying resource access is only started if the reference count transitions from 0 to 1.
				Subsequent calls increment the count without starting access again. This is the simplest API
				for accessing bookmarked resources in most applications.
 @return        YES if access was successfully started or the reference count was incremented, NO otherwise.
 */
- (BOOL)ss_startAccessingSecurityScopedResource {
	NSURL *resolvedURL = [[BESecurityScopedURLManager sharedManager] startAccessingURL:self];
	return (resolvedURL != nil);
}

/*!
 @method        ss_endAccessingSecurityScopedResource
 @abstract      Ends reference-counted security-scoped access for this URL via the shared manager.
 @discussion    Convenience method that delegates to the shared manager's endAccessingURL: method.
				The underlying resource access is only stopped if the reference count drops to 0.
				Calls to this method must be balanced with calls to ss_startAccessingSecurityScopedResource.
 */
- (void)ss_endAccessingSecurityScopedResource {
	[[BESecurityScopedURLManager sharedManager] endAccessingURL:self];
}

@end
