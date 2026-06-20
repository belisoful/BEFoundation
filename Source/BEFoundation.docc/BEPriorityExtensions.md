# BEPriorityExtensions

Priority ordering extensions for collections.

```objc
#import <BEFoundation/BEPriorityExtensions.h>
```

## Overview

This header provides priority ordering support for collections, allowing items to be sorted and accessed by priority.

## Usage

### Priority Item Protocol

Objects can implement `BEPriorityItem` to participate in priority ordering:

```objc
@protocol BEPriorityItem <NSObject>
@property (readonly) NSNumber *defaultItemPriority;
@property NSNumber *itemPriority;
@end
```

### Sorting by Priority

```objc
// Sort array by priority (ascending)
NSArray *sorted = [array sortedArrayUsingItemPriority];
```

## See Also

- [BEPredicateRule](doc:BEPredicateRule)
