# NSPasteboard+BExtension

Typed read/write convenience for `NSPasteboard` (macOS only).

```objc
#import <BEFoundation/NSPasteboard+BExtension.h>
```

## Overview

`NSPasteboard`'s API works in UTIs, `declareTypes:`, and `readObjectsForClasses:options:`. These helpers cover the common cases: putting a string, URL, or image on the pasteboard, reading it back, and checking availability. Each writer clears the pasteboard and writes the value (returning success); each reader returns the first value of that type, or `nil`. This is macOS only. `UIPasteboard` is a separate API and is not bridged here.

## Usage

### Writing

```objc
NSPasteboard *pb = NSPasteboard.generalPasteboard;
[pb writeString:@"copied text"];
[pb writeURL:fileURL];
[pb writeURLs:@[a, b, c]];
[pb writeImage:thumbnail];
```

### Reading

```objc
NSString *text = pb.readString;
NSURL    *url  = pb.readURL;
NSArray<NSURL *> *urls = pb.readURLs;     // nil if none
NSImage  *img  = pb.readImage;
```

## See Also

- <doc:AppKit>
