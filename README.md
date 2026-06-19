[![CI](https://github.com/belisoful/BEFoundation/actions/workflows/ci.yml/badge.svg)](https://github.com/belisoful/BEFoundation/actions/workflows/ci.yml)
[![Platform](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-blue.svg)](https://github.com/belisoful/BEFoundation)
[![Release](https://img.shields.io/github/v/tag/belisoful/BEFoundation?sort=semver&label=release)](https://github.com/belisoful/BEFoundation/releases)
[![License](https://img.shields.io/badge/license-Delicense-blue.svg)](https://github.com/belisoful/BEFoundation/blob/main/LICENSE)

# BEFoundation

**BEFoundation** is a powerful Objective-C framework that enhances Apple's Foundation framework with advanced, reusable components. It provides a comprehensive set of utilities for notification management, runtime manipulation, number and data handling, image processing, data structures, and more — all designed for robustness, clarity, and testability.

---

## 📖 Documentation

For comprehensive documentation, see the [BEFoundation Documentation](Source/BEFoundation.docc/BEFoundation.md) or the [Documentation Index](Source/BEFoundation.docc/Index.md).

---

##  Framework Library Downloads

 - [BEFoundation.framework.zip v1.1.0 (Universal: arm64 x86_64)](https://github.com/belisoful/BEFoundation/blob/main/Framework%20Release%20v1.1.0/BEFoundation%20Universal%20(arm64%2C%20x86_64)/BEFoundation.framework.zip)
 - [BEFoundation.framework.zip v1.1.0 (arm64)](https://github.com/belisoful/BEFoundation/blob/main/Framework%20Release%20v1.1.0/BEFoundation%20(arm64)/BEFoundation.framework.zip)

---

## 🔧 Features

### 📣 Notifications
- `mutableUserInfo` for `NSNotification`
- `NSPriorityNotification`: Notifications with explicit priority
- `NSPriorityNotificationCenter`: Dispatches notifications in priority order linked to NSNotificationCenter

### 🔤 Character Sets
- [`BECharacterSet`](Source/BEFoundation.docc/BECharacterSet.md) and [`BEMutableCharacterSet`](Source/BEFoundation.docc/BEMutableCharacterSet.md): Making a distinction between `NSCharacterSet` and `NSMutableCharacterSet`

### 🖥️ Cross-Platform UI (iOS & macOS)
- [`BEPlatformTypes`](Source/BEFoundation.docc/BEPlatformTypes.md): compile-time aliases — `BEColor`, `BEImage`, `BEFont`, `BEView` — that resolve to the right AppKit/UIKit class per platform, so the same source builds on both
- [`BEColor+BExtension`](Source/BEFoundation.docc/BEColor_BExtension.md): hex-string colors (`#RGB`/`#RGBA`/`#RRGGBB`/`#RRGGBBAA`) and appearance-aware dynamic colors
- [`BEView+BExtension`](Source/BEFoundation.docc/BEView_BExtension.md): Auto Layout helpers — pin to superview/view, center, and size constraints
- [`BEImage+BExtension`](Source/BEFoundation.docc/BEImage_BExtension.md): `CGImage`/`CIImage` round-trips, PNG/JPEG export, pixel size, and aspect-aware resize (fit/fill)
- [`NSPasteboard+BExtension`](Source/BEFoundation.docc/NSPasteboard_BExtension.md) (macOS): one-call typed read/write for strings, URLs, and images

### 🎞️ Image & Metal Helpers
- [`BEMetalHelper`](Source/BEFoundation.docc/BEMetalHelper.md): Metal helper utilities for converting MTLTextures to a `BEImage` (`NSImage`/`UIImage`), and grey data to XRGB
- [`CIImage+BExtension`](Source/BEFoundation.docc/CIImage_BExtension.md): overlay images with alpha, render text

### 🧠 Runtime & Object Management
- [`BEMutable`](Source/BEFoundation.docc/BEMutable.md): Mutable and Collection classes have their own protocols for distinction
- [`NSObject+DynamicMethods`](Source/BEFoundation.docc/NSObject_DynamicMethods.md): Runtime extensions to add selectors implemented by blocks to specific objects and classes
- Runtime extensions to add protocols implemented by objects or classes to specific objects and classes
- `NSObject+Macroable`: Laravel-inspired macro system for attaching block-based methods to classes and individual instances at runtime, built on top of `NSObject+DynamicMethods`
- [`BEObjectRegistry`](Source/BEFoundation.docc/BEObjectRegistry.md): Global object registry with weak references to track object lifetimes
- [`BESingleton`](Source/BEFoundation.docc/BESingleton.md): Singleton pattern macro

### 📚 Data Structures
- [`BEStackExtensions`](Source/BEFoundation.docc/BEStackExtensions.md): Array-based Stack and Queue
- [`BEPriorityExtensions`](Source/BEFoundation.docc/BEPriorityExtensions.md): Priority ordering extensions for `NSArray` and `NSOrderedSet`
- [`FxTime`](Source/BEFoundation.docc/FxTime.md): Object to encapsulate CMTime and methods

### 📡 File & Path Monitoring
- [`BEPathWatcher`](Source/BEFoundation.docc/BEPathWatcher.md): Path watcher class to observe file system changes

### 🧮 Encoding, Numbers, and Dates
- [`NSCoder+AtIndex`](Source/BEFoundation.docc/NSCoder_AtIndex.md): Indexed encoding/decoding with key control (string or numeric)
- [`NSCoder+HalfFloat`](Source/BEFoundation.docc/NSCoder_HalfFloat.md): 16-bit float encoding/decoding
- [`NSMutableNumber`](Source/BEFoundation.docc/NSMutableNumber.md): Mutable variant of `NSNumber`
- [`NSNumber+Primes16b`](Source/BEFoundation.docc/NSNumber_Primes16b.md): Contains all 16-bit prime numbers with rounding
- [`NSDateFormatterRFC3339`](Source/BEFoundation.docc/NSDateFormatterRFC3339.md): Proper RFC 3339 date formatting initialization and setting

### 🧪 Predicate Logic
- [`BEPredicateRule`](Source/BEFoundation.docc/BEPredicateRule.md): Evaluation system that can accept, reject, or remain neutral based on predicate evaluation

### 🧩 Foundation Extensions
- [`NSObject+DynamicMethods`](Source/BEFoundation.docc/NSObject_DynamicMethods.md): Dynamic protocol conformance implemented by objects and classes
- `NSObject` Block-based selectors for instances and classes
- Extensions for:
  - [`NSDictionary+BExtension`](Source/BEFoundation.docc/NSDictionary_BExtension.md): numeric subscripts, object conversion, mapping, swapping, adding, and merging
  - `NSMutableDictionary` numeric subscripts, filtering, swap, and recursive and nonrecursive adding and merging 
  - [`NSArray+BExtension`](Source/BEFoundation.docc/NSArray_BExtension.md): mapping, and conversion
  - `NSMutableArray` removeFirstObject, insert objects at index, and filtering
  - [`NSSet+BExtension`](Source/BEFoundation.docc/NSSet_BExtension.md): conversion, and mapping
  - `NSMutableSet` filtering
  - [`NSOrderedSet+BExtension`](Source/BEFoundation.docc/NSOrderedSet_BExtension.md): conversion, and mapping
  - `NSMutableOrderedSet` conversion, removing first and last, and filtering
  - [`NSString+BExtension`](Source/BEFoundation.docc/NSString_BExtension.md): stringValue (to align with NSNumber and other plist data types), is itself
  - `NSMutableString` deleteAtIndex

---

## 🧪 Unit Testing

BEFoundation includes **comprehensive unit tests** for all major components, using `XCTest`. Tests cover behavior, edge cases, runtime behaviors, and error conditions. In v1.1, unit test coverage was extended to `NSObject+Macroable` (57 tests covering `BEMacroMeta`, class macros, object macros, invocation, isolation, and subclass inheritance).

---

## 📦 Integration

### Framework Integration

1. Download the BEFoundation.framework ZIP file for your project.
2. Unzip the file.
3. Include the BEFoundation.framework in your Project Target under the General Tab and "Framework and Libraries" section.
4. Under the "Embed" dropdown select "Embed & Sign" or "Embed Without Signing".
5. Import the Headers you'd like to use.

### Manual Integration

1. Clone or download this repository.
2. Add the `BEFoundation` source folder to your Xcode project.
3. Link against required frameworks: `Foundation`, `CoreImage`, `Metal`, etc.
4. Ensure ARC is enabled (where applicable).

---

## ✍️ About the Author

### Author

BEFoundation was initially conceived and engineered by belisoful@icloud.com to resolve the lack of [NSString stringValue] and implementing a selector for an object (and instances) with a block.  These requirements came about in working with Apple's FxPlug API in developing an advanced framework around it.  The FxPlug buttons require an object method be implemented per button which is not directly possible in Objective C.  The buttons need to be parameterized for an FxPlug framework.

### Other projects
 - http://gcpdot.com Fully created by @belisoful in about year 2000.
 - https://github.com/pradosoft/prado Implementing Advanced Features like the TCronModule.



---

## Change Log

### New in 1.1

**Cross-Platform (iOS & macOS)**
 - The framework now builds and is unit-tested on both iOS and macOS. [`BEPlatformTypes`](Source/BEFoundation.docc/BEPlatformTypes.md) provides compile-time aliases — `BEColor`, `BEImage`, `BEFont`, `BEView` — that resolve to the right AppKit/UIKit class per platform.
 - [`BEColor+BExtension`](Source/BEFoundation.docc/BEColor_BExtension.md): hex-string colors and appearance-aware dynamic colors.
 - [`BEView+BExtension`](Source/BEFoundation.docc/BEView_BExtension.md): Auto Layout convenience constraints (pin, center, size).
 - [`BEImage+BExtension`](Source/BEFoundation.docc/BEImage_BExtension.md): `CGImage`/`CIImage` round-trips, PNG/JPEG export, pixel size, and aspect-aware resizing.
 - [`NSPasteboard+BExtension`](Source/BEFoundation.docc/NSPasteboard_BExtension.md) (macOS): typed read/write for strings, URLs, and images.

**Foundation & Networking**
 - NSNotification+ExtraProperties adds tag and identifier if the notification object has such properties or are set in the NSNotification
 - NSString (CharacterCounter) category for counting characters of a NSString.
 - [`NSURL+Data`](Source/BEFoundation.docc/NSURL_Data.md): categories for creating and reading "data" scheme NSURL.
 - [`BEWebData`](Source/BEFoundation.docc/BEWebData.md): for decoding a "data" scheme within NSURL, download "http/s" files, or read file system files.
 - [`NSData+URLDownload`](Source/BEFoundation.docc/NSData_URLDownload.md): for easy download of internet data via in-memory or temporary file.
 - [`BEFileCache`](Source/BEFoundation.docc/BEFileCache.md): persistent file-backed caching.
 - [`BESecurityScopedURLManager`](Source/BEFoundation.docc/BESecurityScopedURLManager.md): security-scoped bookmark lifecycle management.
 - `NSObject+Macroable`: Macro system for attaching block-based methods to a class (available on all instances) or to a specific object instance at runtime, built on `NSObject+DynamicMethods`.

**AppKit**
 - [`BEPathControl`](Source/BEFoundation.docc/BEPathControl.md): an NSPathControl that displays paths relative to a sub-directory.
 - [`BETabView`](Source/BEFoundation.docc/BETabView.md): a drop-in NSTabView replacement that supports hidden tabs.
 - [`BEWindowController`](Source/BEFoundation.docc/BEWindowController.md): a drop-in NSWindowController replacement with parent/child window-controller relationships and a `windowDidLoad` notification.
 - [`BEWindowControllerManager`](Source/BEFoundation.docc/BEWindowControllerManager.md): an application singleton that tracks window controllers and closes children when a parent closes.
