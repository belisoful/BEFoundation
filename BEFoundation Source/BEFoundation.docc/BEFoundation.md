# ``BEFoundation``

This extends the utility of the Foundation classes to assist in project development.

## Overview

There are many primary functions of this Framework:
- Stack and Queue for NSMutableArray and NSMutableOrderedSet.
- Object Registry and Storage by UUID. Objects can specify their own UUID for inter-application or cross network operability.
- Singleton Pattern.
- NSCoder atIndex extension.
- NSCoder halfFloat.
- File and Directory Watcher with callbacks.
- NSMutableNumber, interchangable with NSNumber.
- 16 bit Prime Number ceil, floor, and rounding.
- NSNumber extension for basic math functions between NSNumber.
- Dynamic Object specific and instance-wide Methods implemented by blocks.
	- Functions for working with Block Signatures
- NSString checking for numbers, dates, and adding `stringValue` method.
- FxTime for encapsulating CMTime within an Objective C Object.
- Adds `BECollection` protocol to Collection, and `BEMutableCollection` protocol to Mutable Collections.
- Adds `BEHasMutable` protocol to objects with mutable counterparts, and `BEMutable` protocol to Mutable objects.  This includes Collections and Mutable Collections.
- Adds BECharacterSet and BEMutableCharacterSet to differentiate NSCharacterSet from NSMutableCharacterSet due to Apple combining the implementation of NSCharacterSet with NSMutableCharacterSet.
- Determining the acceptance or rejection (or not-applicable) of an object based on a list of Predicates.
- NSDictionary/NSMutableDictionary extension for mapping, swapping keys and values, adding and merging dictionaries, and filtering dictionaries with a Block. Dictionies are given indexed subscripts (eg `dictionary[13]` converting to NSNumber or NSString (choice is an option).
- NSArray/NSMutableArray extension for mapping, inserting elements, and filtering.
- Ordering elements in NSArray, NSMutableArray, NSOrderedSet, and NSMutableOrderedSet by an elements protocol priority.
- NSOrderedSet/NSMutableOrderedSet for mapping, inserting, removing first/last object, conversion, and filtering.
- NSSet/NSMutableSet extension for mapping, and filtering.
- CIImage extension for text and combining two images with an alpha for the top image 
- Metal Helper for converting MTLTexture to NSImage.
- Extends the NSDateFormatter with a RFC3339 constructor and an instance method to configure existing objects.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- ``NSString stringValue``
This is to make NSString more interchangable with NSNumber in getting either one's `stringValue`.  

