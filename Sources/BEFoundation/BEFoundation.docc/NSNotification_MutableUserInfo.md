# NSNotification+MutableUserInfo

The `userInfo` of an `NSNotification` typed as `NSMutableDictionary` when it is one.

```objc
#import <BEFoundation/NSNotification+MutableUserInfo.h>
```

## Overview

`NSNotification.userInfo` is declared as `NSDictionary`. A poster can pass an `NSMutableDictionary`, and Foundation stores the instance it is given. This category adds one read-only property, `mutableUserInfo`, that returns `userInfo` cast to `NSMutableDictionary` when the stored instance is one. It returns nil when `userInfo` is nil or an immutable dictionary. The category performs the class check with `isKindOfClass:` and never copies or converts the dictionary.

## Usage

### Reading

```objc
NSNotification *note = [NSNotification notificationWithName:@"Event"
                                                     object:nil
                                                   userInfo:[NSMutableDictionary dictionary]];
NSMutableDictionary *info = note.mutableUserInfo;   // the stored dictionary
info[@"count"] = @1;

NSNotification *fixed = [NSNotification notificationWithName:@"Event"
                                                      object:nil
                                                    userInfo:@{@"count": @0}];
NSMutableDictionary *none = fixed.mutableUserInfo;  // nil, userInfo is immutable
```

### Guarding a Write

Nil-messaging makes a subscript assignment on a nil result a no-op. A guard makes the intent explicit.

```objc
NSMutableDictionary *info = note.mutableUserInfo;
if (info == nil) {
    return;
}
info[@"handledBy"] = NSStringFromClass(self.class);
```

### Passing State Between Observers

``NSPriorityNotificationCenter`` shares a notification's `userInfo` by reference with every observer, in priority order. An earlier observer can write into a mutable `userInfo` and a later observer can read it. A copy made for a queued observer shares the same dictionary. The center takes no lock around an observer call-out, so an observer that mutates the dictionary while queued observers may read it synchronizes that access itself.

```objc
// Posted with a mutable userInfo.
[NSPriorityNotificationCenter.defaultCenter postNotificationName:@"WillSave"
                                                          object:document
                                                        userInfo:[NSMutableDictionary dictionary]];

// A high-priority observer records a decision for later observers.
- (void)willSave:(NSNotification *)note {
    note.mutableUserInfo[@"skipBackup"] = @YES;
}
```

## See Also

- [Priority Notifications](doc:PriorityNotifications)
- [NSNotification+ExtraProperties](doc:NSNotification_ExtraProperties)
- [NSPriorityNotificationCenter](doc:NSPriorityNotificationCenter)
