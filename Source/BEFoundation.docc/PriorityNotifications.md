# Priority Notifications

Priority-ordered notification delivery, with notification classes and categories to support it.

```objc
#import <BEFoundation/NSPriorityNotificationCenter.h>
#import <BEFoundation/NSPriorityNotification.h>
```

## Overview

`NSPriorityNotificationCenter` is an `NSNotificationCenter` subclass that delivers notifications
to observers in priority order rather than registration order. It is a
[BESingleton](doc:BESingleton)-backed center accessed through `defaultCenter`.

`NSPriorityNotification` is an `NSNotification` subclass (supporting `NSSecureCoding`) carrying
the priority metadata, and `NSPooledPriorityNotification` is its pooled variant for
high-frequency posting.

![A diagram of priority-ordered delivery: observers sorted by Unix-style priority (−20 highest, 10 default, 20 lowest), each delivered synchronously, with the queued path copying the notification for async delivery.](priority-notification-delivery)

Two supporting categories ship alongside the center:

- `NSNotification (ExtraProperties)` — additional properties on plain notifications, including
  per-name observer priority (`ncPriority:` / `setNcPriority:name:`).
- `NSNotification (MutableUserInfo)` — mutable access to a notification's `userInfo` while it is
  being dispatched.

## Usage

### Posting with Priority

```objc
NSPriorityNotification *note = [NSPriorityNotification notificationWithName:@"UserLoggedIn"
                                                                     object:self];
[[NSPriorityNotificationCenter defaultCenter] postNotification:note];
```

### Observing in Priority Order

Observers register through the standard `addObserver:` API on the center; their delivery order is
controlled by the priority configuration rather than registration order.

## See Also

- [BEPriorityExtensions](doc:BEPriorityExtensions)
- [BESingleton](doc:BESingleton)
