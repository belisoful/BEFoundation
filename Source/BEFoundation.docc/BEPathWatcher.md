# BEPathWatcher

File system monitoring using Grand Central Dispatch.

```objc
#import <BEFoundation/BEPathWatcher.h>
```

## Overview

[BEPathWatcher](doc:BEPathWatcher) monitors file system paths for changes using GCD's dispatch sources. It provides flexible callback mechanisms including blocks, target-action, and protocol-based notifications.

![A pipeline from a file change to a kernel VNODE event, through a GCD dispatch source filtering by event mask, to your block or target-selector callback.](bepathwatcher-flow)

## Usage

### Block-Based Monitoring

```objc
BEPathWatcher *watcher = [BEPathWatcher watcherForPath:@"/path/to/file.txt"
                                             withBlock:^(BEPathWatcher *w, unsigned long flags) {
    NSLog(@"Path changed: %@", w.path);
}];
```

### Target-Action Monitoring

```objc
@interface MyClass
@property (nonatomic, strong) BEPathWatcher *watcher;
@end

@implementation MyClass

- (void)startWatching {
    self.watcher = [BEPathWatcher watcherForPath:@"/path/to/file.txt"
                                         target:self
                                       selector:@selector(pathChanged:)];
}

- (void)pathChanged:(BEPathWatcher *)watcher {
    NSLog(@"File changed: %@", watcher.path);
}

@end
```

### Event Types

The `eventMask` property accepts DISPATCH_VNODE_* flags:
- `DISPATCH_VNODE_WRITE` — File was modified
- `DISPATCH_VNODE_DELETE` — File was deleted
- `DISPATCH_VNODE_EXTEND` — File was extended
- `DISPATCH_VNODE_RENAME` — File was renamed
- `DISPATCH_VNODE_ATTRIB` — Metadata changed

### Custom Event Mask

```objc
BEPathWatcher *watcher = [BEPathWatcher watcherForPath:@"/path/to/file.txt"
                                             eventMask:DISPATCH_VNODE_WRITE | DISPATCH_VNODE_DELETE
                                              withBlock:^(BEPathWatcher *w, unsigned long flags) {
    if (flags & DISPATCH_VNODE_WRITE) {
        NSLog(@"File was modified");
    }
    if (flags & DISPATCH_VNODE_DELETE) {
        NSLog(@"File was deleted");
    }
}];
```

### Controlling the Watcher

```objc
// Start/stop monitoring
watcher.isActive = YES;   // Start
watcher.isActive = NO;    // Stop

// Change path
[watcher watchPath:@"/new/path.txt"];

// Stop monitoring
[watcher stopMonitoring];
```

### Threading and Lifecycle

Callbacks (block, target-action, and the `pathDidChangeWithFlags:` subclass hook) are delivered on
the main queue, and are invoked without the watcher's internal lock held — so a callback may safely
call back into the watcher, including from another thread. Configuration methods are safe to call
from any thread.

The watcher automatically stops itself when the watched path is deleted, renamed, or revoked,
because the underlying file descriptor becomes invalid. After such an event, `isActive` is `NO`.

## See Also

- [BEFileCache](doc:BEFileCache)
- [BESecurityScopedURLManager](doc:BESecurityScopedURLManager)
