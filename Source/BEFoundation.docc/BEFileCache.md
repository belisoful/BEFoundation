# BEFileCache

A persistent, file-backed cache that mirrors the NSCache API.

```objc
#import <BEFoundation/BEFileCache.h>
```

## Overview

[BEFileCache](doc:BEFileCache) provides a disk-based cache that persists across app launches. Every object is written to disk immediately in `setObject:forKey:`, so the cache survives app termination. A private in-memory tier accelerates repeat reads.

![A diagram of the two tiers: an in-memory NSCache over an on-disk tier of per-entry .cache payloads and .meta sidecars plus a BEFileCacheIndex, with reconciliation at cold start.](befilecache-architecture)

When the cache exceeds its limits it evicts entries by an eviction score that balances recency against value density (see [Eviction Policy](#Eviction-Policy)). Last access is tracked in memory, so reads cause no extra disk writes. On launch the on-disk index is reconciled against the directory: an entry written just before a crash is recovered, and stray files are deleted.

## Usage

### Basic Usage

```objc
// Create cache with default directory
BEFileCache *cache = [[BEFileCache alloc] init];

// Store objects
[cache setObject:myObject forKey:@"myKey"];
[cache setObject:otherObject forKey:@"otherKey" cost:1024];

// Give an entry a distinct replacement cost (see Eviction Policy)
[cache setObject:thumbnail forKey:@"thumb" cost:thumbnail.length retentionCost:fetchCost];

// Retrieve objects
id cached = [cache objectForKey:@"myKey"];

// Remove objects
[cache removeObjectForKey:@"myKey"];

// Clear all
[cache removeAllObjects];
```

### Custom Cache Directory

```objc
// Use custom directory
BEFileCache *cache = [[BEFileCache alloc] initWithCacheDirectory:@"/path/to/cache"];

// Use subdirectory in caches
BEFileCache *cache = [[BEFileCache alloc] initWithCacheDirectory:@"MyCache"];
```

### Cache Limits

```objc
// Set maximum entry count
cache.countLimit = 100;

// Set maximum total cost (bytes)
cache.totalCostLimit = 10 * 1024 * 1024;  // 10 MB

// Memory tier limits
cache.memoryCountLimit = 50;
cache.memoryTotalCostLimit = 5 * 1024 * 1024;  // 5 MB
```

Both the cost limit and the count limit evict by the same eviction score (see [Eviction Policy](#Eviction-Policy)), highest-scoring first.

### Eviction Policy

![A dial from 0 to 1: 0 is least-recently-used, 0.5 (the default) is a geometric balance, and 1 is value density. The score is pow(age, 1 minus balance) times pow(cost over retentionCost, balance).](befilecache-evictionbalance)

When a limit is exceeded, BEFileCache evicts the highest-scoring entries first. The score balances two factors:

- **Recency** — time since the entry was last accessed, read or written. Last access updates on every hit and is held in memory, so reads add no disk writes.
- **Value density** — `cost / retentionCost`. A large entry that is cheap to recreate scores high and is evicted first; a costly-to-recreate entry scores low and is retained.

`evictionBalance` (0…1, default 0.5) is the dial between them:

| `evictionBalance` | Behavior |
| --- | --- |
| `0` | Least-recently-used. Size and `retentionCost` ignored. |
| `0.5` (default) | Geometric balance of recency and value density. |
| `1` | Pure value density. Recency ignored. |

`retentionCost` defaults to `cost`, so the value-density term is inert until a distinct `retentionCost` is supplied. With default retention costs, every `evictionBalance` behaves as LRU.

```objc
cache.evictionBalance = 0.5;   // the default

// This thumbnail is small to store but costly to refetch, so it survives
// eviction longer than its size alone would suggest.
[cache setObject:thumbnail
          forKey:assetID
            cost:thumbnail.length     // storage cost
   retentionCost:networkFetchCost];   // replacement cost
```

### Backup Exclusion

`excludedFromBackup` reads and writes the `NSURLIsExcludedFromBackupKey` flag on the cache directory. Set it `YES` for an ephemeral cache so its files are skipped by iCloud/iTunes backup and Time Machine; leave it `NO` for a cache that doubles as a real, backed-up file store. The default `<NSCachesDirectory>` location is already excluded by the system regardless of this flag.

```objc
BEFileCache *cache = [[BEFileCache alloc] initWithCacheDirectory:@"/path/to/store"];
cache.excludedFromBackup = YES;            // keep this cache out of backups
BOOL excluded = cache.excludedFromBackup;
```

### Delegate

```objc
@interface MyClass () <BEFileCacheDelegate>
@end

@implementation MyClass

- (void)setupCache {
    BEFileCache *cache = [[BEFileCache alloc] init];
    cache.delegate = self;
}

- (void)cache:(BEFileCache *)cache willEvictObject:(id)obj {
    NSLog(@"Object being evicted: %@", obj);
}

- (void)cache:(BEFileCache *)cache willEvictObjectFromMemory:(id)obj {
    NSLog(@"Object evicted from memory tier: %@", obj);
}

@end
```

### Key Requirements

Keys must conform to `NSCopying` and `NSSecureCoding`. Common Foundation types qualify:
- `NSString`
- `NSNumber`
- `NSURL`
- `NSDate`

## See Also

- [BEPathWatcher](doc:BEPathWatcher)
