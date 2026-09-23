# Priority Notifications

Priority-ordered notification delivery, with notification classes and categories to support it.

```objc
#import <BEFoundation/NSPriorityNotificationCenter.h>
#import <BEFoundation/NSPriorityNotification.h>
```

## Overview

`NSPriorityNotificationCenter` is an `NSNotificationCenter` subclass that delivers notifications
to observers in priority order; registration order does not affect delivery. It is a
[BESingleton](doc:BESingleton)-backed center accessed through `defaultCenter`.

`NSPriorityNotification` is an `NSNotification` subclass (supporting `NSSecureCoding`) carrying
the priority metadata. Observers registered with an `NSOperationQueue` receive their own
stable copy of a notification posted through the center, which they may retain.

The shared `defaultCenter` also intercepts every notification posted to
`NSNotificationCenter.defaultCenter` and re-posts its own notifications there; a center created
with `init` is self-contained. Such an intercepted notification is forwarded to queued observers unchanged, and its `object` may be an
opaque C pointer rather than an Objective-C object (SceneKit posts C structs through
`CFNotificationCenterPostNotification`). The center compares that object by identity and never
retains it; an observer that reads it must do the same, using an `__unsafe_unretained` variable
under ARC.

![A diagram of priority-ordered delivery: observers sorted by Unix-style priority (−20 highest, 10 default, 20 lowest), each delivered synchronously, with the queued path copying the notification for async delivery.](priority-notification-delivery)

Two supporting categories ship alongside the center:

- `NSNotification (ExtraProperties)` — `tag` and `identifier` properties on plain notifications,
  read from the notification itself, then its `object`, then its `userInfo`.
- `NSNotification (MutableUserInfo)` — `mutableUserInfo`, which returns the notification's
  `userInfo` when it already is an `NSMutableDictionary` and nil otherwise.

Per-name observer priority (`ncPriority:` / `setNcPriority:name:`) belongs to the
`NSNotificationObjectPriorityItem` and `NSNotificationObjectPriorityCapture` observer protocols
declared in `NSPriorityNotificationCenter.h`.

## Usage

### Posting with Priority

```objc
NSPriorityNotification *note = [NSPriorityNotification notificationWithName:@"UserLoggedIn"
                                                                     object:self];
[[NSPriorityNotificationCenter defaultCenter] postNotification:note];
```

### Observing in Priority Order

Observers register through the standard `addObserver:` API on the center; their delivery order is
controlled by the priority configuration.

## Topics

### Notification Center

- <doc:NSPriorityNotificationCenter>

### Notification Classes

- <doc:NSPriorityNotification>

### NSNotification Categories

- <doc:NSNotification_ExtraProperties>
- <doc:NSNotification_MutableUserInfo>

## See Also

- [BEPriorityExtensions](doc:BEPriorityExtensions)
- [BESingleton](doc:BESingleton)
