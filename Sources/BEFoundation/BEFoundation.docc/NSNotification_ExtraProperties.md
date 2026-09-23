# NSNotification+ExtraProperties

A `tag` and an `identifier` on every `NSNotification`.

```objc
#import <BEFoundation/NSNotification+ExtraProperties.h>
```

## Overview

The category adds two read-write properties to `NSNotification`: `tag`, an `NSInteger`, and `identifier`, an object. Both are stored as associated objects, so they work on any notification instance, including one created by Foundation. A getter that finds no value set on the notification falls back to the notification's `object`, then to its `userInfo`.

## Usage

### Setting and Reading

```objc
NSNotification *note = [NSNotification notificationWithName:@"MyNotification" object:nil];
note.tag = 456;
note.identifier = @"userLogin";

NSInteger tag = note.tag;       // 456
id ident = note.identifier;     // @"userLogin"
```

### Lookup Order

`tag` resolves in this order:

- A nonzero tag set on the notification → that value.
- `object` responds to `tag` → `[object tag]`.
- `userInfo[@"tag"]` is an `NSNumber` → its `integerValue`.
- Otherwise → 0.

`identifier` resolves in this order:

- An identifier set on the notification → that value.
- `object` responds to `identifier` → `[object identifier]`.
- Otherwise → `userInfo[@"identifier"]`, which is nil when absent.

```objc
// A view with tag 7 posts; the notification carries no tag of its own.
NSNotification *note = [NSNotification notificationWithName:@"Clicked" object:view];
NSInteger tag = note.tag;   // 7, from view.tag

// userInfo supplies the identifier when neither the notification nor its object has one.
NSNotification *info = [NSNotification notificationWithName:@"Loaded"
                                                     object:nil
                                                   userInfo:@{@"identifier": @"cache"}];
id ident = info.identifier;  // @"cache"
```

### Clearing a Tag

Setting `tag` to 0 removes the stored value. A subsequent read falls through to `object` and `userInfo`.

```objc
note.tag = 0;
NSInteger tag = note.tag;   // view.tag, or userInfo[@"tag"], or 0
```

### Identifier Copy Semantics

The `identifier` setter copies a value that conforms to `NSCopying`. A mutable identifier reads back as its immutable counterpart. A value that does not conform is retained as given.

```objc
NSMutableString *name = [NSMutableString stringWithString:@"draft"];
note.identifier = name;
[name appendString:@"-edited"];
id ident = note.identifier;   // @"draft", an immutable NSString
```

### Archiving

``NSPriorityNotification`` encodes a `tag` or `identifier` that is set on the notification itself and restores it on decode. A value that a read would resolve from `object` or `userInfo` is not written to the archive.

## See Also

- [Priority Notifications](doc:PriorityNotifications)
- [NSPriorityNotification](doc:NSPriorityNotification)
- [NSNotification+MutableUserInfo](doc:NSNotification_MutableUserInfo)
