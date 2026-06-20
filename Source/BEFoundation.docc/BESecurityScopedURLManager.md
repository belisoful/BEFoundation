# ``BESecurityScopedURLManager``

A thread-safe manager for persistently storing and accessing security-scoped bookmarks.

```objc
#import <BEFoundation/BESecurityScopedURLManager.h>
```

## Overview

This class manages the complete lifecycle of security-scoped bookmarks, including creation, resolution, persistence, and reference-counted access. All operations are thread-safe.

![The bookmark lifecycle: create a bookmark from a URL, persist it, access it under a reference count, and refresh or relocate it when it goes stale, moving the active counts to the new resolved URL.](security-scoped-lifecycle)

A path resolves to a security-scoped URL through four tiers, tried in order.

![A flowchart of the four resolution tiers: direct bookmark match, active reference counts, directory containment, and filename fallback, returning nil if none match.](security-scoped-resolution)

## Usage

### Adding Bookmarks

```objc
BESecurityScopedURLManager *manager = [BESecurityScopedURLManager sharedManager];

// Create bookmark for URL
NSURL *bookmarkedURL = [NSURL fileURLWithPath:@"/path/to/resource"];
BOOL success = [manager addURLToCatalog:bookmarkedURL 
                             lifetime:BESecurityScopedURLBookmarkLifetimeLongLived];
```

### Accessing URLs

```objc
// Resolve URL from catalog
NSURL *resolved = [manager urlFromCatalog:staleURL];

// Access with security scope
NSURL *accessedURL = [manager startAccessingURLWithAbsolutePath:resolved.absoluteString];
if (accessedURL) {
    // Use the security-scoped resource
    [manager endAccessingURLWithAbsolutePath:accessedURL.absoluteString];
}
```

### Reference-Counted Access

```objc
// Multiple parts of app can request access
[manager startAccessingURLWithAbsolutePath:urlPath];
// ... use resource ...
[manager endAccessingURLWithAbsolutePath:urlPath];

// Access all URLs at once
NSArray *urls = [manager startAccessingAllURLs];
// ... use resources ...
[manager endAccessingAllURLs];
```

### Subscript Access

```objc
BESecurityScopedURLManager *manager = [BESecurityScopedURLManager sharedManager];

// Resolve using subscript
NSURL *resolved = manager[staleURL];
NSURL *resolved2 = manager[@"/path/to/file"];
```

### Catalog Management

```objc
BESecurityScopedURLManager *manager = [BESecurityScopedURLManager sharedManager];

// Get all bookmarked URLs
NSDictionary *catalog = manager.catalog;

// Remove bookmark
[manager removeURLFromCatalog:url];

// Clear all
[manager clearCatalog];
```

### Storage Options

```objc
// Configure persistence
manager.storageOptions = BESecurityScopedURLStorageUserDefaults;  // Only UserDefaults
manager.storageOptions = BESecurityScopedURLStorageCacheDirectory; // Only Caches
manager.storageOptions = BESecurityScopedURLStorageAll;            // Both (default)
```

### Persistence Keys

The catalog is persisted under fixed, internally-defined keys:

- **NSUserDefaults key:** `BESecurityScopedURLManagerCatalog` — used when `storageOptions` includes `BESecurityScopedURLStorageUserDefaults`. The archived catalog is read/written under this key on `[NSUserDefaults standardUserDefaults]`.
- **Cache filename:** `BESecurityScopedURLManager_Catalog.archive` — used when `storageOptions` includes `BESecurityScopedURLStorageCacheDirectory`. The archive file is written into the application's Caches directory.

These keys are defined internally and are not configurable. Avoid writing to these keys directly; use the manager's catalog methods to mutate persisted state.

## See Also

- [BEPathWatcher](doc:BEPathWatcher)
- [BEFileCache](doc:BEFileCache)
