# ``BEFoundation``

**BEFoundation** is an Objective-C framework that extends Apple's Foundation framework with reusable components. It provides utilities for notification management, runtime manipulation, number and data handling, image processing, and data structures.

## Overview

The framework provides these components:

- **Stack and Queue Operations** — [BEStackExtensions](doc:BEStackExtensions) on NSMutableArray and NSMutableOrderedSet for LIFO/FIFO data structures
- **Priority Ordering** — [BEPriorityExtensions](doc:BEPriorityExtensions) for sorting NSArray and NSOrderedSet by item priority
- **Object Registry** — [BEObjectRegistry](doc:BEObjectRegistry) for managing object instances by UUID with thread-safe operations, and [NSObject+GlobalRegistry](doc:NSObject_GlobalRegistry) for the shared global registry
- **Runtime Helpers** — [BERuntime](doc:BERuntime) for class and method introspection
- **Singleton Pattern** — [BESingleton](doc:BESingleton) protocol and backing implementation for thread-safe singletons
- **Coder Extensions** — [NSCoder+AtIndex](doc:NSCoder_AtIndex) for index-based encoding, [NSCoder+HalfFloat](doc:NSCoder_HalfFloat) for 16-bit float support
- **File System Monitoring** — [BEPathWatcher](doc:BEPathWatcher) using GCD dispatch sources
- **Mutable Numbers** — [NSMutableNumber](doc:NSMutableNumber) for mutable numeric values with thread-safe operations
- **Prime Numbers** — [NSNumber+Primes16b](doc:NSNumber_Primes16b) with all 6542 primes in 16-bit range
- **Number Math** — [NSNumber+BExtension](doc:NSNumber_BExtension) for arithmetic operations between NSNumber instances
- **Dynamic Methods** — [NSObject+DynamicMethods](doc:NSObject_DynamicMethods) for runtime method injection using blocks
- **Macros** — [NSObject+Macroable](doc:NSObject_Macroable) for Laravel-style block macros on classes and instances
- **Priority Notifications** — [NSPriorityNotificationCenter](doc:NSPriorityNotificationCenter) and [NSPriorityNotification](doc:NSPriorityNotification) for priority-ordered delivery, with [NSNotification+ExtraProperties](doc:NSNotification_ExtraProperties) and [NSNotification+MutableUserInfo](doc:NSNotification_MutableUserInfo)
- **String Utilities** — [NSString+BExtension](doc:NSString_BExtension) for type checking and stringValue alignment with NSNumber
- **Time Handling** — [FxTime](doc:FxTime) encapsulating CMTime with arithmetic and comparison operations
- **Collection Protocols** — [BEMutable](doc:BEMutable) system for mutability detection and recursive copying
- **Character Sets** — [BECharacterSet](doc:BECharacterSet) and [BEMutableCharacterSet](doc:BEMutableCharacterSet) for clear type distinction
- **Predicate Rules** — [BEPredicateRule](doc:BEPredicateRule) for accept/reject/NA evaluation logic
- **Dictionary Extensions** — [NSDictionary+BExtension](doc:NSDictionary_BExtension) with indexed subscripts, mapping, swapping, and recursive merging
- **Array Extensions** — [NSArray+BExtension](doc:NSArray_BExtension) and NSMutableArray+BExtension for mapping and filtering
- **Set Extensions** — [NSSet+BExtension](doc:NSSet_BExtension) and [NSOrderedSet+BExtension](doc:NSOrderedSet_BExtension) with mapping and filtering
- **Image Processing** — [CIImage+BExtension](doc:CIImage_BExtension) for text rendering and alpha compositing
- **Metal Utilities** — [BEMetalHelper](doc:BEMetalHelper) for texture-to-image conversion
- **Cross-Platform UI** — [BEPlatformTypes](doc:BEPlatformTypes) aliases plus [BEColor](doc:BEColor_BExtension) hex/appearance colors, the [BEWebColor](doc:BEColor_BEWebColor) CSS keyword palette, [BEView](doc:BEView_BExtension) Auto Layout helpers, [BEImage](doc:BEImage_BExtension) round-trips/resize, and the [BEDotView](doc:BEDotView) status dot that build on both macOS and iOS
- **AppKit (macOS)** — [BEPathControl](doc:BEPathControl), [BETabView](doc:BETabView), [BEWindowController](doc:BEWindowController), and [BEWindowControllerManager](doc:BEWindowControllerManager)
- **Typed Pasteboard** — [NSPasteboard+BExtension](doc:NSPasteboard_BExtension) for one-call string, URL, and image read/write
- **Web Data** — [BEWebData](doc:BEWebData) for loading data, http(s), and file URLs, [NSData+URLDownload](doc:NSData_URLDownload) for async downloads
- **URL Extensions** — [NSURL+Data](doc:NSURL_Data) for data URL creation and parsing
- **File Caching** — [BEFileCache](doc:BEFileCache) for persistent file-backed caching
- **Security Scoped URLs** — [BESecurityScopedURLManager](doc:BESecurityScopedURLManager) for bookmark lifecycle management, with [NSOpenPanel integration](doc:NSOpenPanel_BESecurityScopedURLManager) on macOS
- **RFC Date Formats** — [NSDateFormatterRFC3339](doc:NSDateFormatterRFC3339) and [NSDateFormatterRFC2822](doc:NSDateFormatterRFC2822) for standardized date formatting
- **Block Signatures** — [NSMethodSignature+BlockSignatures](doc:NSMethodSignature_BlockSignatures) for working with block type encodings

## Topics

### Runtime and Object Management

- <doc:RuntimeManagement>
- <doc:BEObjectRegistry>
- <doc:BESingleton>
- <doc:BERuntime>
- <doc:NSObject_DynamicMethods>
- <doc:NSObject_Macroable>
- <doc:NSObject_GlobalRegistry>

### Numbers and Mathematics

- <doc:Numbers>
- <doc:NSMutableNumber>
- <doc:NSNumber_BExtension>
- <doc:NSNumber_Primes16b>
- <doc:NSCoder_HalfFloat>
- <doc:NSCoder_AtIndex>

### Collection Extensions

- <doc:Collections>
- <doc:NSArray_BExtension>
- <doc:NSDictionary_BExtension>
- <doc:NSSet_BExtension>
- <doc:NSOrderedSet_BExtension>
- <doc:BEMutable>
- <doc:BEStackExtensions>
- <doc:BEPriorityExtensions>

### Character Sets

- <doc:CharacterSets>
- <doc:BECharacterSet>
- <doc:BEMutableCharacterSet>

### Predicates and Rules

- <doc:Predicates>
- <doc:BEPredicateRule>

### Notifications

- <doc:PriorityNotifications>

### String Extensions

- <doc:Strings>
- <doc:NSString_BExtension>

### Time and Dates

- <doc:TimeAndDates>
- <doc:FxTime>
- <doc:NSDateFormatterRFC3339>
- <doc:NSDateFormatterRFC2822>

### Cross-Platform UI

- <doc:CrossPlatformUI>
- <doc:BEPlatformTypes>
- <doc:BEColor_BExtension>
- <doc:BEColor_BEWebColor>
- <doc:BEView_BExtension>
- <doc:BEImage_BExtension>
- <doc:BEDotView>

### Images and Metal

- <doc:ImagesAndMetal>
- <doc:CIImage_BExtension>
- <doc:BEMetalHelper>

### Web and Networking

- <doc:WebAndNetworking>
- <doc:BEWebData>
- <doc:NSData_URLDownload>
- <doc:NSURL_Data>

### File System

- <doc:FileSystem>
- <doc:BEPathWatcher>
- <doc:BEFileCache>
- <doc:BESecurityScopedURLManager>

### Method Signatures

- <doc:MethodSignatures>
- <doc:NSMethodSignature_BlockSignatures>

### AppKit Extensions

- <doc:AppKit>
- <doc:BEPathControl>
- <doc:BETabView>
- <doc:BEWindowController>
- <doc:BEWindowControllerManager>
- <doc:NSOpenPanel_BESecurityScopedURLManager>
- <doc:NSPasteboard_BExtension>

### Documentation Index

- <doc:Index>
