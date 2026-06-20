# ``BEWindowControllerManager``

A manager class that tracks all active `BEWindowController` instances.

## Overview

`BEWindowControllerManager` listens for window load and close notifications (`BEWindowDidLoadNotification` and `NSWindowWillCloseNotification`) to automatically maintain a list of all active `BEWindowController` instances.

This provides a centralized way to query for windows, such as finding all windows of a certain class or the first available window. It also enables advanced behaviors, like the cascade-closing of child windows when a parent window is closed.

The manager supports fast enumeration (`for...in`) and subscripting for convenient access.

![The shared manager tracking a tree of window controllers: a primary parent with Inspector and Settings children and a grandchild sheet, registered on windowDidLoad and cascade-closed with the parent.](window-controllers)

## Usage

### Main Class

- [BEWindowControllerManager](doc:BEWindowControllerManager)

## Usage

### Creating a Manager

```objc
BEWindowControllerManager *manager = [[BEWindowControllerManager alloc] init];

// The manager automatically starts tracking BEWindowController instances
// via notifications
```

### Finding Window Controllers

```objc
// Find the first window controller of a specific class
EditorWC *editor = (EditorWC *)[manager firstWindowControllerOfKind:[EditorWC class]];

// Find all window controllers of a specific class
NSArray *allEditors = [manager windowControllersOfKind:[EditorWC class]];
```

### Using Subscripting

```objc
// Indexed subscripting
NSWindowController *firstWC = manager[0];
NSWindowController *thirdWC = manager[2];

// Keyed subscripting with class
EditorWC *editor = (EditorWC *)manager[EditorWC.class];
SettingsWC *settings = (SettingsWC *)manager[SettingsWC.class];
```

### Iterating Over All Controllers

```objc
// Fast enumeration
for (NSWindowController *wc in manager) {
    NSLog(@"Window: %@", wc.window.title);
}

// Access the snapshot array
NSArray *allControllers = manager.windowControllers;
```

## Properties

### windowControllers

```objc
@property (readonly, copy) NSArray<NSWindowController *> *windowControllers;
```

A snapshot array of all currently tracked window controllers.

This property is `copy`, so it returns an immutable snapshot of the current list of controllers. Iterating over this is safe from mutation-during-enumeration errors if the manager's list changes on another thread.

## Methods

### firstWindowControllerOfKind:

```objc
- (nullable NSWindowController *)firstWindowControllerOfKind:(nonnull Class)wcClass;
```

Finds the first window controller that is an instance of a given class.

Iterates through the tracked controllers and returns the first object for which `[wc isKindOfClass:wcClass]` is true.

### windowControllersOfKind:

```objc
- (NSArray<NSWindowController *> *)windowControllersOfKind:(nonnull Class)wcClass;
```

Finds all window controllers that are instances of a given class.

Iterates through all tracked controllers and returns an array of all objects for which `[wc isKindOfClass:wcClass]` is true.

### objectAtIndexedSubscript:

```objc
- (nullable NSWindowController *)objectAtIndexedSubscript:(NSUInteger)idx;
```

Provides support for indexed subscripting (e.g., `manager[0]`).

### objectForKeyedSubscript:

```objc
- (nullable NSWindowController *)objectForKeyedSubscript:(nonnull Class)key;
```

Provides support for keyed subscripting (e.g., `manager[MyClass.class]`).

This method is a convenience wrapper for `firstWindowControllerOfKind:`.

## Cascade Closing

When a parent `BEWindowController` closes, `BEWindowControllerManager` automatically closes all child window controllers in the hierarchy:

```objc
// If parentController has children, closing parent will:
// 1. Find all descendant child controllers
// 2. Call close on each of them
// 3. Remove parent from tracking

[parentController close]; // Children are automatically closed
```

This ensures child windows never outlive their parent.

## Thread Safety

The manager uses `@synchronized` internally for thread-safe access to its internal array. However, when iterating over window controllers or accessing the `windowControllers` snapshot, you should synchronize access if modifying from multiple threads.

## Relationships

See Also: [BEWindowController](doc:BEWindowController), [BETabView](doc:BETabView), [BEPathControl](doc:BEPathControl)
