# ``NSPriorityNotification``

An `NSNotification` subclass that carries reverse-order and post-processing options for ``NSPriorityNotificationCenter``.

```objc
#import <BEFoundation/NSPriorityNotification.h>
```

## Overview

``NSPriorityNotification`` adds two read-only properties to a notification. ``reverse`` asks the center to deliver in reverse priority order. ``postBlock`` runs after each observer completes. Both are set at initialization. The class conforms to `NSSecureCoding`.

The `NSNotification (PriorityExtension)` category, declared in the same header, gives every `NSNotification` the same two properties so the center reads them polymorphically:

- `reverse` → always NO on a plain `NSNotification`.
- `postBlock` → always NULL on a plain `NSNotification`.
- `isPriorityPost` → an internal flag the center sets around delivery to stop a bridged notification from re-entering. A single notification instance must not be posted on two threads concurrently.

## Usage

### Reverse Delivery

With ``reverse`` YES, observers with higher numeric priority values run before observers with lower values. Observers of equal priority run in reverse registration order.

```objc
NSPriorityNotification *note = [NSPriorityNotification notificationWithName:@"WillTearDown"
                                                                     object:self
                                                                    reverse:YES];
[NSPriorityNotificationCenter.defaultCenter postNotification:note];
```

### Post-Processing Blocks

The center calls ``postBlock`` once per observer, after that observer's selector or block returns. The block receives the notification delivered to that observer. The initializer copies the block.

```objc
NSPriorityNotification *note = [NSPriorityNotification notificationWithName:@"DidSave"
                                                                     object:self
                                                                   userInfo:@{@"path": path}
                                                                  postBlock:^(NSNotification *n) {
    NSLog(@"one observer handled %@", n.name);
}];
[NSPriorityNotificationCenter.defaultCenter postNotification:note];
```

### Factory Methods and Initializers

Every factory method forwards to ``notificationWithName:object:userInfo:reverse:postBlock:``, and every initializer forwards to the designated ``initWithName:object:userInfo:reverse:postBlock:``. An option that a shorter form omits defaults to nil, NO, or NULL.

`NSNotification` is an abstract class cluster whose initializers raise for non-Apple subclasses. The designated initializer stores the name, object, user info, reverse flag, and block in the subclass's own instance variables and does not call `[super init]`.

### Secure Coding

``encodeWithCoder:`` and ``initWithCoder:`` support keyed and non-keyed coders.

- `name` → encoded as a string. Decoding returns nil when the archive holds no string name.
- `object` conforming to `BERegistryProtocol` → registered in the global registry if not already registered; its registry UUID is encoded. Decoding restores the object through `NSObject.globalRegistry`.
- `object` that does not conform → not encoded.
- `userInfo` → encoded as a dictionary. Decoding allows the property-list classes (`NSDictionary`, `NSArray`, `NSSet`, `NSString`, `NSNumber`, `NSDate`, `NSData`, `NSNull`, `NSURL`).
- `reverse` → encoded as a Boolean.
- `tag` and `identifier` from `NSNotification (ExtraProperties)` → encoded when set on the notification itself.
- ``postBlock`` → not encoded. It is NULL after decoding.

```objc
NSData *data = [NSKeyedArchiver archivedDataWithRootObject:note
                                     requiringSecureCoding:YES
                                                     error:&error];
NSPriorityNotification *restored = [NSKeyedUnarchiver unarchivedObjectOfClass:NSPriorityNotification.class
                                                                     fromData:data
                                                                        error:&error];
```

``classForCoder`` and ``classForKeyedArchiver`` both return the receiver's class, so an archive records the ``NSPriorityNotification`` class.

### Copying

`copy` returns a new ``NSPriorityNotification`` with the same name, object, user info, ``reverse`` flag, and ``postBlock``. A `tag` or `identifier` set on the original is set on the copy.

## Topics

### Options

- ``reverse``
- ``postBlock``

### Creating a Notification

- ``notificationWithName:object:``
- ``notificationWithName:object:userInfo:``
- ``notificationWithName:object:reverse:``
- ``notificationWithName:object:postBlock:``
- ``notificationWithName:object:userInfo:reverse:``
- ``notificationWithName:object:userInfo:postBlock:``
- ``notificationWithName:object:reverse:postBlock:``
- ``notificationWithName:object:userInfo:reverse:postBlock:``
- ``initWithName:object:userInfo:reverse:``
- ``initWithName:object:userInfo:postBlock:``
- ``initWithName:object:userInfo:reverse:postBlock:``

### Secure Coding

- ``supportsSecureCoding``
- ``initWithCoder:``
- ``encodeWithCoder:``
- ``classForCoder``
- ``classForKeyedArchiver``

## See Also

- [Priority Notifications](doc:PriorityNotifications)
- [NSPriorityNotificationCenter](doc:NSPriorityNotificationCenter)
- [NSNotification+ExtraProperties](doc:NSNotification_ExtraProperties)
- [NSObject+GlobalRegistry](doc:NSObject_GlobalRegistry)
