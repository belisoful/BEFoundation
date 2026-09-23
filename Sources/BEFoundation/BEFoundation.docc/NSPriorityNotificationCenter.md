# ``NSPriorityNotificationCenter``

An `NSNotificationCenter` subclass that delivers each notification to its observers in priority order.

```objc
#import <BEFoundation/NSPriorityNotificationCenter.h>
```

## Overview

Every observer registers with a priority. The center sorts the matching observers by priority at post time and calls them in that order. Priority follows the Unix convention: -20 is the highest priority, 0 is neutral, and 20 is the lowest. Observers of equal priority run in registration order, as `NSNotificationCenter` delivers them. An observer added without a priority receives the center's ``defaultPriority``, which starts at `NSPriorityNotificationDefaultPriority` (10). Changing ``defaultPriority`` affects observers added afterward. Existing observers keep their priority.

Only the shared ``defaultCenter`` bridges to `NSNotificationCenter.defaultCenter`:

- A post to `NSNotificationCenter.defaultCenter` → delivered to the shared center's observers in priority order.
- A post to the shared center → delivered to its own observers, and forwarded to `NSNotificationCenter.defaultCenter` at ``defaultPriority``.

A center created with ``init`` is self-contained. It delivers to its own observers only, and it neither receives nor forwards system default center notifications. ``initForSingleton:`` creates a bridged center; `BESingleton` calls it once to create ``defaultCenter``. ``cleanup`` removes the bridge from a bridged center and leaves its observers registered. On a self-contained center ``cleanup`` has no effect. This split is introduced in 1.2.0.

The center takes no lock around an observer call-out. A notification's `userInfo` is shared by reference with every observer, including observers on operation queues. An observer that mutates a mutable `userInfo` synchronizes that access itself.

## Usage

### Observing with a Priority

Lower values run first. `-5` runs before the default 10.

```objc
NSPriorityNotificationCenter *center = NSPriorityNotificationCenter.defaultCenter;

[center addObserver:self
           selector:@selector(handleLogin:)
               name:@"UserLoggedIn"
             object:nil
           priority:-5];

id token = [center addObserverForName:@"UserLoggedIn"
                               object:nil
                             priority:5
                                queue:nil
                           usingBlock:^(NSNotification *note) {
    NSLog(@"login: %@", note.userInfo[@"name"]);
}];

[center removeObserver:token];
```

The four-argument `addObserver:selector:name:object:` and `addObserverForName:object:queue:usingBlock:` register at ``defaultPriority``.

### Observer-Supplied Priority

An observer supplies its own priority through two protocols declared in the header:

- ``NSNotificationObjectPriorityItem`` → `ncPriority:` returns the priority for a notification name each time the center sorts observers. The value may change at runtime.
- ``NSNotificationObjectPriorityCapture`` → `setNcPriority:name:` stores the priority the center passes when the observer is added.
- ``NSNotificationObjectPriorityProperty`` → both.

``addObserver:selector:name:object:priority:queue:`` combines its `priority` argument with these protocols:

- Conforms to `NSNotificationObjectPriorityCapture` only → the center calls `setNcPriority:name:` with `priority` and sorts by `priority`.
- Conforms to `NSNotificationObjectPriorityItem` only → the effective priority is `ncPriority:` at sort time plus (`priority` - ``defaultPriority``). Passing ``defaultPriority`` uses the observer's own value unchanged.
- Conforms to both → the center stores `priority` through `setNcPriority:name:` and sorts by `ncPriority:` alone. The offset is 0.
- Conforms to neither → the center sorts by `priority`.

```objc
// AudioEngine conforms to NSNotificationObjectPriorityItem.
- (NSInteger)ncPriority:(NSNotificationName)aName {
    return [aName isEqualToString:@"AppWillTerminate"] ? -20 : 0;
}
```

### Posting

The posting methods accept two options beyond `NSNotificationCenter`'s: `reverse` delivers lowest priority first, and `postBlock` runs once after each observer completes. Each convenience method wraps the arguments in an ``NSPriorityNotification`` and calls ``postNotification:``. Posting a plain `NSNotification` works too; it delivers in priority order with `reverse` NO and no `postBlock`.

```objc
[center postNotificationName:@"UserLoggedIn"
                      object:self
                    userInfo:@{@"name": @"alice"}
                     reverse:NO
                   postBlock:^(NSNotification *note) {
    NSLog(@"delivered to one observer");
}];
```

### Queued Delivery

`addObserver:selector:name:object:queue:` and the block form take an `NSOperationQueue`. Observers are still ordered by priority, and each queued observer's call runs asynchronously on its queue. A queued observer receives a copy of the notification made at post time. The copy shares the original's `userInfo` by reference.

A notification that arrives through the bridge from `NSNotificationCenter.defaultCenter` is forwarded to queued observers unchanged. Its `object` may be an opaque C pointer (SceneKit posts C structs through `CFNotificationCenterPostNotification`). The center compares that object by identity and never retains it. An observer that reads the object of such a notification does the same: under ARC, read it into an `__unsafe_unretained` variable.

### Self-Contained Centers

```objc
NSPriorityNotificationCenter *local = [[NSPriorityNotificationCenter alloc] init];
[local addObserver:self selector:@selector(handleTick:) name:@"Tick" object:nil priority:0];
[local postNotificationName:@"Tick" object:nil];   // reaches local observers only
```

## Topics

### Shared Center

- ``defaultCenter``
- ``defaultPriority``
- ``init``
- ``initForSingleton:``
- ``cleanup``

### Observing

- ``addObserver:selector:name:object:priority:``
- ``addObserver:selector:name:object:priority:queue:``
- ``addObserverForName:object:priority:queue:usingBlock:``
- ``removeObserver:``
- ``removeObserver:name:object:``

### Posting

- ``postNotification:``
- ``postNotificationName:object:userInfo:reverse:postBlock:``
- ``postNotificationName:object:reverse:postBlock:``
- ``postNotificationName:object:userInfo:postBlock:``
- ``postNotificationName:object:postBlock:``
- ``postNotificationName:object:userInfo:reverse:``
- ``postNotificationName:object:reverse:``

### Observer Priority Protocols

- ``NSNotificationObjectPriorityItem``
- ``NSNotificationObjectPriorityCapture``
- ``NSNotificationObjectPriorityProperty``

## See Also

- [Priority Notifications](doc:PriorityNotifications)
- [NSPriorityNotification](doc:NSPriorityNotification)
- [BESingleton](doc:BESingleton)
