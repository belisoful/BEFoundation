# BEStackExtensions

Adds stack (LIFO) and queue (FIFO) operations to mutable collections.

```objc
#import <BEFoundation/BEStackExtensions.h>
```

## Overview

This header provides categories on `NSMutableArray` and `NSMutableOrderedSet` to enable stack-like and queue-like behaviors using common push, pop, and shift method names.

![A last-in-first-out stack: push appends an element to the top, and pop removes and returns the top element.](bestack-lifo)

## Usage

### NSMutableArray Stack Operations

```objc
NSMutableArray *stack = [NSMutableArray array];

// Push operations
[stack push:@1];           // Add to end
[stack push:@2];
[stack push:@3];

// Pop operation (removes and returns last)
id top = [stack pop];  // Returns @3, stack is now @[@1, @2]

// Push multiple objects
[stack pushObjects:@4, @5, nil];  // stack is now @[@1, @2, @4, @5]

// Push array
[stack pushArray:@[@6, @7]];  // stack is now @[@1, @2, @4, @5, @6, @7]
```

### NSMutableArray Queue Operations

```objc
NSMutableArray *queue = [NSMutableArray array];

// Enqueue
[queue push:@1];  // queue is @[@1]
[queue push:@2];  // queue is @[@1, @2]
[queue push:@3];  // queue is @[@1, @2, @3]

// Dequeue (removes and returns first)
id first = [queue shift];  // Returns @1, queue is now @[@2, @3]
```

### NSMutableOrderedSet Stack Operations

```objc
NSMutableOrderedSet *stack = [NSMutableOrderedSet orderedSet];

// Push operation
[stack push:@1];
[stack push:@2];

// Configure behavior for existing objects
stack.isPushOnTop = YES;  // Default: pushing existing moves to top
[stack push:@1];  // Removes @1 from current position, adds to end

// Pop operation
id top = [stack pop];  // Removes and returns last object
```

### NSMutableOrderedSet Queue Operations

```objc
NSMutableOrderedSet *queue = [NSMutableOrderedSet orderedSet];

// Enqueue
[queue push:@1];
[queue push:@2];
[queue push:@3];

// Dequeue
id first = [queue shift];  // Returns @1, queue is now @{@2, @3}
```

### Method Chaining

All methods return the collection instance for chaining:

```objc
NSMutableArray *result = [[NSMutableArray array]
    push:@1
    push:@2
    push:@3
    pushArray:@[@4, @5]];
```

## Stack vs Queue

| Operation | Stack (LIFO) | Queue (FIFO) |
|-----------|--------------|--------------|
| Add | `push:` | `push:` |
| Remove | `pop` | `shift` |

## See Also

- [NSArray+BExtension](doc:NSArray_BExtension)
- [NSOrderedSet+BExtension](doc:NSOrderedSet_BExtension)
