# ``BEFoundation``

**BEFoundation** is a powerful Objective-C framework that enhances Apple's Foundation framework with advanced, reusable components. It provides a comprehensive set of utilities for notification management, runtime manipulation, number and data handling, image processing, data structures, and more—all designed for robustness, clarity, and testability.

## Overview

BEFoundation extends the utility of Foundation classes to assist in project development. The framework provides many primary functions organized into distinct categories:

- **Stack and Queue Operations** — [NSMutableArray](doc:NSArray_BExtension) and NSMutableOrderedSet extensions for LIFO/FIFO data structures
- **Object Registry** — [BEObjectRegistry](doc:BEObjectRegistry) for managing object instances by UUID with thread-safe operations
- **Singleton Pattern** — [BESingleton](doc:BESingleton) protocol and backing implementation for thread-safe singletons
- **Coder Extensions** — [NSCoder+AtIndex](doc:NSCoder_AtIndex) for index-based encoding, [NSCoder+HalfFloat](doc:NSCoder_HalfFloat) for 16-bit float support
- **File System Monitoring** — [BEPathWatcher](doc:BEPathWatcher) using GCD dispatch sources
- **Mutable Numbers** — [NSMutableNumber](doc:NSMutableNumber) for mutable numeric values with thread-safe operations
- **Prime Numbers** — [NSNumber+Primes16b](doc:NSNumber_Primes16b) with all 6542 primes in 16-bit range
- **Number Math** — [NSNumber+BExtension](doc:NSNumber_BExtension) for arithmetic operations between NSNumber instances
- **Dynamic Methods** — [NSObject+DynamicMethods](doc:NSObject_DynamicMethods) for runtime method injection using blocks
- **Macros** — [NSObject+Macroable](doc:NSObject_Macroable) for Laravel-style block macros on classes and instances
- **Priority Notifications** — [NSPriorityNotificationCenter](doc:PriorityNotifications) for priority-ordered notification delivery
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
- **Cross-Platform UI** — [BEPlatformTypes](doc:BEPlatformTypes) aliases plus [BEColor](doc:BEColor_BExtension) hex/appearance colors, [BEView](doc:BEView_BExtension) Auto Layout helpers, and [BEImage](doc:BEImage_BExtension) round-trips/resize that build on both macOS and iOS
- **Typed Pasteboard** — [NSPasteboard+BExtension](doc:NSPasteboard_BExtension) for one-call string, URL, and image read/write
- **Web Data** — [BEWebData](doc:BEWebData) for data URLs, [NSData+URLDownload](doc:NSData_URLDownload) for async downloads
- **URL Extensions** — [NSURL+Data](doc:NSURL_Data) for data URL creation and parsing
- **File Caching** — [BEFileCache](doc:BEFileCache) for persistent file-backed caching
- **Security Scoped URLs** — [BESecurityScopedURLManager](doc:BESecurityScopedURLManager) for bookmark lifecycle management
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

### Character Sets

- <doc:CharacterSets>
- <doc:BECharacterSet>
- <doc:BEMutableCharacterSet>

### Predicates and Rules

- <doc:Predicates>
- <doc:BEPredicateRule>
- <doc:BEPriorityExtensions>

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
- <doc:BEView_BExtension>
- <doc:BEImage_BExtension>

### Images and Metal

- <doc:ImagesAndMetal>
- <doc:CIImage_BExtension>
- <doc:BEMetalHelper>
- <doc:BEImage_BExtension>

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
- <doc:NSPasteboard_BExtension>

### Documentation Index

- <doc:Index>
