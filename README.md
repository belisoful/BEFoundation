# BEFoundation

**BEFoundation** is a powerful Objective-C framework that enhances Apple's Foundation framework with advanced, reusable components. It provides a comprehensive set of utilities for notification management, runtime manipulation, number and data handling, image processing, data structures, and more — all designed for robustness, clarity, and testability.

---

## 🔧 Features

### 📣 Notifications
- `mutableUserInfo` for `NSNotification`
- `NSPriorityNotification`: Notifications with explicit priority
- `NSPriorityNotificationCenter`: Dispatches notifications in priority order linked to NSNotificationCenter

### 🔤 Character Sets
- `BECharacterSet` and `BEMutableCharacterSet`: Making a distinction between `NSCharacterSet` and `NSMutableCharacterSet`

### 🎞️ Image & Metal Helpers
- Metal helper utilities for converting MTLTextures to NSImage, and grey data to to XRGB
- `CIImage+BExtension` extension: overlay images with alpha, render text

### 🧠 Runtime & Object Management
- Mutable and Collection classes have their own protocols for distinction
- Runtime extensions to add selectors implemented by blocks to specific objects and classes
- Runtime extensions to add protocols implemented by objects or classes to specific objects and classes
- Global object registry with weak references to track object lifetimes
- Singleton pattern macro

### 📚 Data Structures
- Array-based Stack and Queue
- Priority ordering extensions for `NSArray` and `NSOrderedSet`
- FxTime object to encapsulate CMTime and methods

### 📡 File & Path Monitoring
- Path watcher class to observe file system changes

### 🧮 Encoding, Numbers, and Dates
- `NSCoder+AtIndex`: Indexed encoding/decoding with key control (string or numeric)
- `NSCoder+HalfFloat`: 16-bit float encoding/decoding
- `NSMutableNumber`: Mutable variant of `NSNumber`
- `NSNumber+Primes16b`: Contains all 16-bit prime numbers with rounding
- `NSDateFormatterRFC3339`: Proper RFC 3339 date formatting initalization and setting

### 🧪 Predicate Logic
- `BEPredicateRule`: Evaluation system that can accept, reject, or remain neutral based on predicate evaluation

### 🧩 Foundation Extensions
- `NSObject` dynamic protocol conformance implemented by objects and classes
- `NSObject` Block-based selectors for instances and classes
- Extensions for:
  - `NSDictionary` numeric subscripts, object conversion, mapping, swapping, adding, and merging
  - `NSMutableDictionary` numeric subscripts, filtering, swap, and recursive and nonrecursive adding and merging 
  - `NSArray` mapping, and conversion
  - `NSMutableArray` removeFirstObject, insert objects at index, and filtering
  - `NSSet` conversion, and mapping
  - `NSMutableSet` filtering
  - `NSOrderedSet` conversion, and mapping
  - `NSMutableOrderedSet` conversion, removing first and last, and filtering
  - `NSString` stringValue (to align with NSNumber and other plist data types), is a specific type of data in string format
  - `NSMutableString` deleteAtIndex

---

## 🧪 Unit Testing

BEFoundation includes **comprehensive unit tests** for all major components, using `XCTest`. Tests cover behavior, edge cases, runtime behaviors, and error conditions.

---

## 📦 Integration

### Manual Integration

1. Clone or download this repository.
2. Add the `BEFoundation` source folder to your Xcode project.
3. Link against required frameworks: `Foundation`, `CoreImage`, `Metal`, etc.
4. Ensure ARC is enabled (where applicable).

> **Note:** CocoaPods and SPM support can be added if needed — contact the maintainer or open a PR.

---

## ✍️ About the Author

### Author

BEFoundation was initially conceived and engineered by belisoful@icloud.com to resolve the lack of [NSString stringValue] and implementing a selector for an object (and instances) with a block.  These requirements came about in working with Apple's FxPlug API in developing an advanced framework around it.  The FxPlug buttons require an object method be implemented per button which is not directly possible in Objective C.  The buttons need to be parameterized for an FxPlug framework.

### Other projects
 - http://gcpdot.com Fully created by @belisoful in about year 2000.
 - https://github.com/pradosoft/prado Implementing Advanced Features like the TCronModule.



---
