# BEFoundation Documentation Index

Comprehensive documentation for the BEFoundation framework.

## Documentation Structure

### [Main Documentation](doc:BEFoundation)

The main entry point for BEFoundation framework documentation.

## Framework Components

### Foundation Extensions

BEFoundation extends Apple's Foundation framework with utilities for:

- **[Runtime and Object Management](doc:RuntimeManagement)** — Object registries, singletons, dynamic methods
- **[Numbers and Mathematics](doc:Numbers)** — Mutable numbers, arithmetic operations, prime numbers
- **[Collections](doc:Collections)** — Array, dictionary, set, and ordered set extensions
- **[Character Sets](doc:CharacterSets)** — Type-safe character set distinction
- **[Predicates and Rules](doc:Predicates)** — Predicate evaluation with outcomes
- **[Strings](doc:Strings)** — String validation and type checking
- **[Time and Dates](doc:TimeAndDates)** — CMTime encapsulation, RFC 3339 formatting
- **[Method Signatures](doc:MethodSignatures)** — Block signature manipulation

### AppKit Extensions

BEFoundation provides AppKit extensions for macOS development:

- **[AppKit Extensions](doc:AppKit)** — Overview of AppKit components
- **[BEPathControl](doc:BEPathControl)** — NSPathControl with relative URL filtering
- **[BETabView](doc:BETabView)** — NSTabView with hidden tab support
- **[BEWindowController](doc:BEWindowController)** — Window controller with parent/child relationships
- **[BEWindowControllerManager](doc:BEWindowControllerManager)** — Window controller tracking
- **[NSPasteboard+BExtension](doc:NSPasteboard_BExtension)** — Typed pasteboard read/write

### Cross-Platform UI

Categories that work on both macOS (AppKit) and iOS (UIKit):

- **[Cross-Platform UI](doc:CrossPlatformUI)** — Overview of the shared UI conveniences
- **[BEPlatformTypes](doc:BEPlatformTypes)** — Compile-time aliases (`BEColor`, `BEImage`, `BEFont`, `BEView`)
- **[BEColor+BExtension](doc:BEColor_BExtension)** — Hex and appearance-aware colors
- **[BEView+BExtension](doc:BEView_BExtension)** — Auto Layout convenience constraints
- **[BEImage+BExtension](doc:BEImage_BExtension)** — Image round-trips, export, and resizing

### Image and Metal Utilities

- **[Images and Metal](doc:ImagesAndMetal)** — Overview of image processing components
- **[CIImage+BExtension](doc:CIImage_BExtension)** — Text rendering and image compositing
- **[BEMetalHelper](doc:BEMetalHelper)** — Metal texture to image conversion
- **[BEImage+BExtension](doc:BEImage_BExtension)** — Cross-platform image round-trips and resizing

### File and Networking Utilities

- **[File System](doc:FileSystem)** — Overview of file-related components
- **[BEPathWatcher](doc:BEPathWatcher)** — File system monitoring with GCD
- **[BEFileCache](doc:BEFileCache)** — Persistent file-backed caching
- **[BESecurityScopedURLManager](doc:BESecurityScopedURLManager)** — Security-scoped bookmark management
- **[Web and Networking](doc:WebAndNetworking)** — Overview of networking components
- **[BEWebData](doc:BEWebData)** — NSData subclass for data URLs
- **[NSData+URLDownload](doc:NSData_URLDownload)** — Asynchronous URL downloading
- **[NSURL+Data](doc:NSURL_Data)** — Data URL creation and parsing

## Components

### Runtime Management

- [BEObjectRegistry](doc:BEObjectRegistry) — Thread-safe object registry
- [BESingleton](doc:BESingleton) — Thread-safe singleton pattern
- [BERuntime](doc:BERuntime) — Runtime utility functions
- [NSObject+DynamicMethods](doc:NSObject_DynamicMethods) — Runtime method injection
- [NSObject+Macroable](doc:NSObject_Macroable) — Laravel-style block macros
- [NSObject+GlobalRegistry](doc:NSObject_GlobalRegistry) — Global registry integration

### Numbers and Mathematics

- [NSMutableNumber](doc:NSMutableNumber) — Mutable NSNumber replacement
- [NSNumber+BExtension](doc:NSNumber_BExtension) — Arithmetic operations
- [NSNumber+Primes16b](doc:NSNumber_Primes16b) — Prime number operations
- [NSCoder+AtIndex](doc:NSCoder_AtIndex) — Index-based encoding
- [NSCoder+HalfFloat](doc:NSCoder_HalfFloat) — Half-precision float encoding

### Collections

- [NSArray+BExtension](doc:NSArray_BExtension) — Array extensions
- [NSDictionary+BExtension](doc:NSDictionary_BExtension) — Dictionary extensions
- [NSSet+BExtension](doc:NSSet_BExtension) — Set extensions
- [NSOrderedSet+BExtension](doc:NSOrderedSet_BExtension) — Ordered set extensions
- [BEMutable](doc:BEMutable) — Mutability protocols
- [BEStackExtensions](doc:BEStackExtensions) — Stack and queue operations

### Character Sets

- [BECharacterSet](doc:BECharacterSet) — Immutable character set
- [BEMutableCharacterSet](doc:BEMutableCharacterSet) — Mutable character set

### Predicates and Rules

- [BEPredicateRule](doc:BEPredicateRule) — Predicate evaluation with outcomes
- [BEPriorityExtensions](doc:BEPriorityExtensions) — Priority ordering

### Notifications

- [Priority Notifications](doc:PriorityNotifications) — Priority-ordered notification delivery

### Strings

- [NSString+BExtension](doc:NSString_BExtension) — String validation and type checking

### Time and Dates

- [FxTime](doc:FxTime) — CMTime encapsulation
- [NSDateFormatterRFC3339](doc:NSDateFormatterRFC3339) — RFC 3339 date formatting
- [NSDateFormatterRFC2822](doc:NSDateFormatterRFC2822) — RFC 2822 date formatting

### Method Signatures

- [NSMethodSignature+BlockSignatures](doc:NSMethodSignature_BlockSignatures) — Block signature manipulation

## See Also

- [BEFoundation on GitHub](https://github.com/belisoful/BEFoundation)
- [Framework Releases](https://github.com/belisoful/BEFoundation/releases)
