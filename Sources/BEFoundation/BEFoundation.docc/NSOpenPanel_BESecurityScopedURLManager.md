# NSOpenPanel+BESecurityScopedURLManager

`NSOpenPanel` categories that bookmark selected URLs into a `BESecurityScopedURLManager` (macOS only).

```objc
#import <BEFoundation/NSOpenPanel+BESecurityScopedURLManager.h>
```

## Overview

The `BESecurityScopedURLManager` category wraps the standard panel presentation: on `NSModalResponseOK`, the chosen URLs are added to the associated [BESecurityScopedURLManager](doc:BESecurityScopedURLManager) as security-scoped bookmarks before the completion handler runs. This supports the common workflow of letting the user grant persistent access to files and folders.

The `BEPanelHelper` category sets the panel's starting directory from a file or directory URL.

Introduced in 1.1.

## Usage

### Presenting a Panel That Bookmarks Selections

```objc
NSOpenPanel *panel = [NSOpenPanel ss_openPanelWithManager:manager];
panel.canChooseDirectories = YES;
panel.allowsMultipleSelection = YES;

// On NSModalResponseOK the chosen URLs are bookmarked into the manager
// before the handler runs.
[panel ss_beginWithCompletionHandler:^(NSModalResponse result) {
    if (result == NSModalResponseOK) {
        // Bookmarks already added; manager now has persistent access.
    }
}];
```

`+ss_openPanel` creates a panel associated with the shared manager. The `ss_urlManager` property may also be set directly; when it is nil, no bookmarks are created. The `ss_bookmarkLifetime` property selects short-lived or long-lived bookmarks (default: long-lived).

### Adding URLs Without the Panel UI

```objc
NSArray<NSURL *> *failed = [panel ss_addURLsToCatalog:someURLs];
```

`ss_addURLsToCatalog:` is the seam that `ss_beginWithCompletionHandler:` invokes on `NSModalResponseOK`. It returns the subset of URLs that could not be bookmarked (empty on full success or when there is no manager).

### Presetting the Starting Directory

```objc
[panel ss_presetDirectoryAtURL:lastSelectedURL];
```

A directory URL is shown directly; a file URL shows the file's parent directory. A nil or non-file URL leaves the panel's directory unchanged.

## See Also

- [BESecurityScopedURLManager](doc:BESecurityScopedURLManager)
- [NSPasteboard+BExtension](doc:NSPasteboard_BExtension)
