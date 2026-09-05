[![CI](https://github.com/belisoful/BEFoundation/actions/workflows/ci.yml/badge.svg)](https://github.com/belisoful/BEFoundation/actions/workflows/ci.yml)
[![Platform](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-blue.svg)](https://github.com/belisoful/BEFoundation)
[![Release](https://img.shields.io/github/v/tag/belisoful/BEFoundation?sort=semver&label=release)](https://github.com/belisoful/BEFoundation/releases)
[![License](https://img.shields.io/badge/license-Delicense-blue.svg)](https://github.com/belisoful/BEFoundation/blob/main/LICENSE)

# BEFoundation

**BEFoundation** is an Objective-C framework that extends Apple's Foundation with utilities for notifications, runtime manipulation, number and data handling, image processing, data structures, file and path monitoring, security-scoped bookmarks, caching, and more. It is cross-platform (macOS and iOS) and ships as a Universal binary (arm64 + x86_64).

---

## 📖 Documentation

For full documentation, see the [BEFoundation Documentation](Sources/BEFoundation/BEFoundation.docc/BEFoundation.md) or the [Documentation Index](Sources/BEFoundation/BEFoundation.docc/Index.md).

---

## 📦 Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/belisoful/BEFoundation.git", from: "1.1.1")
```

or add it in Xcode via **File ▸ Add Package Dependencies…**.

### CocoaPods

```ruby
pod 'BEFoundation'
```

### Binary

Download an artifact below and drop it into your target.

---

## 📥 Framework Library Downloads

The `.xcframework` is the recommended download: it carries macOS and iOS (device + simulator) in one binary, so a single artifact drops into any target. The plain `.framework` builds are macOS-only.

 - [BEFoundation.xcframework.zip v1.1.1 (macOS + iOS)](https://github.com/belisoful/BEFoundation/blob/main/Framework%20Release%20v1.1.1/BEFoundation%20xcframework%20(macOS%2C%20iOS)/BEFoundation.xcframework.zip) — **recommended**, multi-platform
 - [BEFoundation.framework.zip v1.1.1 (macOS Universal: arm64 x86_64)](https://github.com/belisoful/BEFoundation/blob/main/Framework%20Release%20v1.1.1/BEFoundation%20Universal%20(arm64%2C%20x86_64)/BEFoundation.framework.zip)
 - [BEFoundation.framework.zip v1.1.1 (macOS arm64)](https://github.com/belisoful/BEFoundation/blob/main/Framework%20Release%20v1.1.1/BEFoundation%20(arm64)/BEFoundation.framework.zip)

---

## 🔧 Features

### 📣 Notifications
- `mutableUserInfo` for `NSNotification`
- `NSPriorityNotification`: Notifications with explicit priority
- `NSPriorityNotificationCenter`: Dispatches notifications in priority order linked to NSNotificationCenter

### 🔤 Character Sets
- [`BECharacterSet`](Sources/BEFoundation/BEFoundation.docc/BECharacterSet.md) and [`BEMutableCharacterSet`](Sources/BEFoundation/BEFoundation.docc/BEMutableCharacterSet.md): Making a distinction between `NSCharacterSet` and `NSMutableCharacterSet`

### 🖥️ Cross-Platform UI (iOS & macOS)
- [`BEPlatformTypes`](Sources/BEFoundation/BEFoundation.docc/BEPlatformTypes.md): compile-time aliases — `BEColor`, `BEImage`, `BEFont`, `BEView` — that resolve to the right AppKit/UIKit class per platform, so the same source builds on both
- [`BEColor+BExtension`](Sources/BEFoundation/BEFoundation.docc/BEColor_BExtension.md): hex-string colors (`#RGB`/`#RGBA`/`#RRGGBB`/`#RRGGBBAA`) and appearance-aware dynamic colors
- [`BEColor+BEWebColor`](Sources/BEFoundation/BEFoundation.docc/BEColor_BEWebColor.md): the 141 CSS/SVG color keywords as constants, `web`-prefixed properties, and name lookups
- [`BEView+BExtension`](Sources/BEFoundation/BEFoundation.docc/BEView_BExtension.md): Auto Layout helpers — pin to superview/view, center, and size constraints
- [`BEImage+BExtension`](Sources/BEFoundation/BEFoundation.docc/BEImage_BExtension.md): `CGImage`/`CIImage` round-trips, PNG/JPEG export, pixel size, and aspect-aware resize (fit/fill)
- [`BEDotView`](Sources/BEFoundation/BEFoundation.docc/BEDotView.md): a status-indicator dot view (3D radial-gradient or flat), a port of Prado's `TDot`
- [`NSPasteboard+BExtension`](Sources/BEFoundation/BEFoundation.docc/NSPasteboard_BExtension.md) (macOS): one-call typed read/write for strings, URLs, and images

### 🎞️ Image & Metal Helpers
- [`BEMetalHelper`](Sources/BEFoundation/BEFoundation.docc/BEMetalHelper.md): Metal helper utilities for converting MTLTextures to a `BEImage` (`NSImage`/`UIImage`), and grey data to XRGB
- [`CIImage+BExtension`](Sources/BEFoundation/BEFoundation.docc/CIImage_BExtension.md): overlay images with alpha, render text

### 🧠 Runtime & Object Management
- [`BEMutable`](Sources/BEFoundation/BEFoundation.docc/BEMutable.md): Mutable and Collection classes have their own protocols for distinction
- [`NSObject+DynamicMethods`](Sources/BEFoundation/BEFoundation.docc/NSObject_DynamicMethods.md): Runtime extensions to add selectors implemented by blocks to specific objects and classes
- Runtime extensions to add protocols implemented by objects or classes to specific objects and classes
- `NSObject+Macroable`: Laravel-inspired macro system for attaching block-based methods to classes and individual instances at runtime, built on top of `NSObject+DynamicMethods`
- [`BEObjectRegistry`](Sources/BEFoundation/BEFoundation.docc/BEObjectRegistry.md): Global object registry with weak references to track object lifetimes
- [`BESingleton`](Sources/BEFoundation/BEFoundation.docc/BESingleton.md): Singleton pattern macro

### 📚 Data Structures
- [`BEStackExtensions`](Sources/BEFoundation/BEFoundation.docc/BEStackExtensions.md): Array-based Stack and Queue (`pushObject:`, `popObject`, `shift`)
- [`BEPriorityExtensions`](Sources/BEFoundation/BEFoundation.docc/BEPriorityExtensions.md): Priority ordering extensions for `NSArray` and `NSOrderedSet`
- [`FxTime`](Sources/BEFoundation/BEFoundation.docc/FxTime.md): Immutable object to encapsulate CMTime and methods; `FxMutableTime` adds read-write components and in-place arithmetic

### 📡 File & Path Monitoring
- [`BEPathWatcher`](Sources/BEFoundation/BEFoundation.docc/BEPathWatcher.md): Path watcher class to observe file system changes

### 💾 Networking, Data & Storage
- [`NSURL+Data`](Sources/BEFoundation/BEFoundation.docc/NSURL_Data.md): create and read `data:`-scheme URLs
- [`BEWebData`](Sources/BEFoundation/BEFoundation.docc/BEWebData.md): read a resource through one interface, whether it is a `data:` URL, an `http(s)` download, or a local file
- [`NSData+URLDownload`](Sources/BEFoundation/BEFoundation.docc/NSData_URLDownload.md): download remote data in memory or to a temporary file
- [`BEFileCache`](Sources/BEFoundation/BEFoundation.docc/BEFileCache.md): a two-tier cache — an `NSCache` memory tier over a durable on-disk tier indexed for O(1) cold start — with count/cost limits, `NSDiscardableContent` awareness, crash-safe reconciliation at launch, a score-driven eviction policy (last-access recency, `retentionCost`, and an `evictionBalance` dial between age and value density), and caller-defined entry file naming (`fileNameBlock`)
- [`BESecurityScopedURLManager`](Sources/BEFoundation/BEFoundation.docc/BESecurityScopedURLManager.md): create, resolve, and manage the access lifecycle of security-scoped bookmarks

### 🧮 Encoding, Numbers, and Dates
- [`NSCoder+AtIndex`](Sources/BEFoundation/BEFoundation.docc/NSCoder_AtIndex.md): Indexed encoding/decoding with key control (string or numeric)
- [`NSCoder+HalfFloat`](Sources/BEFoundation/BEFoundation.docc/NSCoder_HalfFloat.md): 16-bit float encoding/decoding
- [`NSMutableNumber`](Sources/BEFoundation/BEFoundation.docc/NSMutableNumber.md): Mutable variant of `NSNumber`
- [`NSNumber+Primes16b`](Sources/BEFoundation/BEFoundation.docc/NSNumber_Primes16b.md): Contains all 16-bit prime numbers with rounding
- [`NSDateFormatterRFC3339`](Sources/BEFoundation/BEFoundation.docc/NSDateFormatterRFC3339.md): Proper RFC 3339 date formatting initialization and setting
- [`NSDateFormatterRFC2822`](Sources/BEFoundation/BEFoundation.docc/NSDateFormatterRFC2822.md): Fixed-format RFC 2822 (Internet Message Format) date formatting initialization and setting

### 🧪 Predicate Logic
- [`BEPredicateRule`](Sources/BEFoundation/BEFoundation.docc/BEPredicateRule.md): Evaluation system that can accept, reject, or remain neutral based on predicate evaluation

### 🧩 Foundation Extensions
- [`NSObject+DynamicMethods`](Sources/BEFoundation/BEFoundation.docc/NSObject_DynamicMethods.md): Dynamic protocol conformance implemented by objects and classes
- `NSObject`: Block-based selectors for instances and classes
- Extensions for:
  - [`NSDictionary+BExtension`](Sources/BEFoundation/BEFoundation.docc/NSDictionary_BExtension.md): numeric subscripts, object conversion, mapping, swapping, adding, and merging
  - `NSMutableDictionary`: numeric subscripts, filtering, swap, and recursive and nonrecursive adding and merging
  - [`NSArray+BExtension`](Sources/BEFoundation/BEFoundation.docc/NSArray_BExtension.md): mapping, and conversion
  - `NSMutableArray`: `removeFirstElement`, `insertElementsOfArray:atIndex:`, and filtering
  - [`NSSet+BExtension`](Sources/BEFoundation/BEFoundation.docc/NSSet_BExtension.md): conversion, and mapping
  - `NSMutableSet`: filtering
  - [`NSOrderedSet+BExtension`](Sources/BEFoundation/BEFoundation.docc/NSOrderedSet_BExtension.md): conversion, and mapping
  - `NSMutableOrderedSet`: conversion, `removeFirstElement`/`removeLastElement`, and filtering
  - [`NSString+BExtension`](Sources/BEFoundation/BEFoundation.docc/NSString_BExtension.md): stringValue (to align with NSNumber and other plist data types), is itself
  - `NSMutableString`: deleteAtIndex

---

## 🧪 Unit Testing

BEFoundation ships unit tests for all major components, using `XCTest`, covering behavior, edge cases, runtime behaviors, and error conditions. The suite runs parallelized across test workers. Continuous integration runs it on macOS (arm64), the macOS x86_64 slice, and the iOS Simulator, plus an AddressSanitizer pass and a DocC catalog build. In v1.1, coverage was extended to `NSObject+Macroable` (65 tests covering `BEMacroMeta`, class macros, object macros, invocation, isolation, and subclass inheritance).

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

### New in 1.1.1

 - **Fix:** `NSPriorityNotificationCenter` no longer crashes on notifications whose `object` is a non-object pointer. SceneKit posts such notifications through `CFNotificationCenterPostNotification`; the object is now read unretained, and super-center notifications reach queued observers unchanged. See [FIXES.md](FIXES.md).

### New in 1.1

**Cross-Platform (iOS & macOS)**
 - The framework now builds and is unit-tested on both iOS and macOS. [`BEPlatformTypes`](Sources/BEFoundation/BEFoundation.docc/BEPlatformTypes.md) provides compile-time aliases — `BEColor`, `BEImage`, `BEFont`, `BEView` — that resolve to the right AppKit/UIKit class per platform.
 - Distributed as a multi-platform `BEFoundation.xcframework` (macOS, iOS device, iOS simulator) alongside the macOS-only `.framework` builds.
 - Installable through Swift Package Manager and CocoaPods. Public headers moved to `Sources/BEFoundation/include/BEFoundation/`, so `#import <BEFoundation/Foo.h>` resolves the same way for SwiftPM, CocoaPods, and the built framework.
 - [`BEColor+BEWebColor`](Sources/BEFoundation/BEFoundation.docc/BEColor_BEWebColor.md): the 141 CSS/SVG color keywords as `BEWebColorName…` constants and `web`-prefixed class properties, with case-insensitive name lookup and exact reverse lookup.
 - [`BEDotView`](Sources/BEFoundation/BEFoundation.docc/BEDotView.md): a cross-platform status-indicator dot (3D or flat), a Core Graphics port of Prado's `TDot`.
 - [`BEColor+BExtension`](Sources/BEFoundation/BEFoundation.docc/BEColor_BExtension.md): hex-string colors and appearance-aware dynamic colors.
 - [`BEView+BExtension`](Sources/BEFoundation/BEFoundation.docc/BEView_BExtension.md): Auto Layout convenience constraints (pin, center, size).
 - [`BEImage+BExtension`](Sources/BEFoundation/BEFoundation.docc/BEImage_BExtension.md): `CGImage`/`CIImage` round-trips, PNG/JPEG export, pixel size, and aspect-aware resizing.
 - **Behavior change:** the `BEImage+BExtension` round-trip and data members are renamed to representation-style names — `CGImageRepresentation`, `CIImageRepresentation`, `imageFromCGImage:`, `imageFromCIImage:`, `pngRepresentation`, `jpegRepresentationWithCompressionQuality:`. Apple frameworks attach same-named category methods to `NSImage` at runtime (PencilKit adds a private `+[NSImage imageWithCGImage:]` and `-CGImage`), and which duplicate wins is undefined, so the 1.0 UIImage-parity spellings were unsafe. `pixelSize` and the `resizedTo…` members keep their names. The round-trip members are also available on iOS now, and the factories return `nil` for `NULL`/`nil` input on both platforms.
 - [`NSPasteboard+BExtension`](Sources/BEFoundation/BEFoundation.docc/NSPasteboard_BExtension.md) (macOS): typed read/write for strings, URLs, and images.

**Foundation & Networking**
 - NSNotification+ExtraProperties adds tag and identifier if the notification object has such properties or are set in the NSNotification
 - NSString (CharacterCounter) category for counting characters of a NSString.
 - [`NSURL+Data`](Sources/BEFoundation/BEFoundation.docc/NSURL_Data.md): categories for creating and reading "data" scheme NSURL.
 - [`BEWebData`](Sources/BEFoundation/BEFoundation.docc/BEWebData.md): for decoding a "data" scheme within NSURL, download "http/s" files, or read file system files.
 - [`NSData+URLDownload`](Sources/BEFoundation/BEFoundation.docc/NSData_URLDownload.md): for easy download of internet data via in-memory or temporary file.
 - [`BEFileCache`](Sources/BEFoundation/BEFoundation.docc/BEFileCache.md): persistent two-tier (memory + disk) caching with count/cost limits, crash-safe reconciliation at launch, a configurable score-driven eviction policy (`retentionCost` + `evictionBalance`), and caller-defined entry file naming (`fileNameBlock`).
 - [`BESecurityScopedURLManager`](Sources/BEFoundation/BEFoundation.docc/BESecurityScopedURLManager.md): security-scoped bookmark lifecycle management.
 - [`NSDateFormatterRFC2822`](Sources/BEFoundation/BEFoundation.docc/NSDateFormatterRFC2822.md): fixed-format RFC 2822 (Internet Message Format) date formatter for email-style dates.
 - `NSObject+Macroable`: Macro system for attaching block-based methods to a class (available on all instances) or to a specific object instance at runtime, built on `NSObject+DynamicMethods`.
 - [`FxTime`](Sources/BEFoundation/BEFoundation.docc/FxTime.md) is now immutable and thread-safe. The new `FxMutableTime` subclass carries the read-write components and in-place arithmetic; code that mutated an `FxTime` must now use `FxMutableTime`. `-copy` returns an immutable `FxTime`; `-mutableCopy` returns an `FxMutableTime`.
 - **Behavior change:** `FxTime` `-compare:`/`-compareTime:` now follow the Cocoa `NSComparisonResult` convention. The result sign is inverted versus 1.0; code that compensated for the old inversion must drop the workaround.
 - **Behavior change:** `NSCoder+AtIndex.h` no longer imports `<simd/simd.h>` (it was unused). Clients that relied on the transitive include through the umbrella header must import `<simd/simd.h>` themselves.

**Behavior change: category methods renamed off Apple's private selectors**

Apple attaches private categories to Foundation classes at runtime, and when a BEFoundation
category defined the same selector the runtime picked a winner by image load order. That
surfaced as an intermittent test failure rather than a build error, and it is the cause of the
flaky failures seen through 1.0. Every colliding selector is renamed; the behavior is unchanged.

| 1.0 | 1.1 | Collided with |
| --- | --- | --- |
| `-[NSMutableArray push:]`, `-pop` | `-pushObject:`, `-popObject` | OSAnalytics (its `push:` returns nil, breaking chaining) |
| `-[NSMutableOrderedSet push:]`, `-pop` | `-pushObject:`, `-popObject` | — (renamed with the array pair for symmetry) |
| `-removeFirstObject`, `-removeLastObject` | `-removeFirstElement`, `-removeLastElement` | CoreFoundation |
| `-[NSMutableArray insertObjects:atIndex:]` | `-insertElementsOfArray:atIndex:` | ScreenReaderCore |
| `setSet:`, `setOrderedSet:`, `setArray:` setters | `be_setSet:`, `be_setOrderedSet:`, `be_setArray:` | CoreFoundation |
| `isMutable` (class and instance) | `hasMutability` | Foundation's private per-instance predicate on every `NSCharacterSet` |

The `set`, `orderedSet`, and `array` properties keep their names — only the setter selectors
changed, so dot syntax (`array.set = value`) is unaffected. `Scripts/check-category-collisions.sh`
now fails the build if any category selector reappears on an Apple class; it runs in CI.

**Behavior change: queued priority-notification observers**

An observer registered with an `NSOperationQueue` now receives a plain `NSPriorityNotification`
it may retain indefinitely. Previously it received a pooled object that was recycled the moment
the handler returned, so a retained notification's `name`, `object`, and `userInfo` went nil and
were later overwritten by an unrelated post. `NSPooledPriorityNotification` is removed; it was
also measurably slower than plain allocation under concurrent posting.

**Behavior change: `NSMutableNumber` is a genuine `NSNumber` subclass**

`NSMutableNumber` now inherits from `NSNumber` rather than wrapping one. `isKindOfClass:` reports
`NSNumber`, equality with a plain `NSNumber` is symmetric, `CFNumberRef` bridging works, and
inherited API such as `decimalValue` returns a value instead of raising. Vendored from the
standalone `NSMutableNumber` v1.3.0.

**AppKit**
 - [`BEPathControl`](Sources/BEFoundation/BEFoundation.docc/BEPathControl.md): an NSPathControl that displays paths relative to a sub-directory.
 - [`BETabView`](Sources/BEFoundation/BEFoundation.docc/BETabView.md): a drop-in NSTabView replacement that supports hidden tabs.
 - [`BEWindowController`](Sources/BEFoundation/BEFoundation.docc/BEWindowController.md): a drop-in NSWindowController replacement with parent/child window-controller relationships and a `windowDidLoad` notification.
 - [`BEWindowControllerManager`](Sources/BEFoundation/BEFoundation.docc/BEWindowControllerManager.md): an application singleton that tracks window controllers and closes children when a parent closes.
