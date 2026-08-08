# BEPriorityExtensions

Priority ordering extensions for collections.

```objc
#import <BEFoundation/BEPriorityExtensions.h>
```

## Overview

This header provides priority ordering support for collections, allowing items to be sorted and accessed by priority.

## Usage

### Priority Protocols

Objects implement `BEPriorityItem` to expose a read-only priority for sorting:

```objc
@protocol BEPriorityItem
@property (readonly, nullable) NSNumber *itemPriority;
@end
```

Lower numeric values sort first. When `itemPriority` is nil, sorting uses the default priority (`BEDefaultSortedItemPriority`). `BEPriorityCapture` declares the settable counterpart; the sorting system assigns the default priority to a conforming object that has none. `BEPriorityProperty` combines both protocols for read-write priority support.

### Sorting by Priority

```objc
// Sort array by priority (ascending)
NSArray *sorted = [array sortedArrayUsingItemPriority];
```

## See Also

- [BEPredicateRule](doc:BEPredicateRule)
