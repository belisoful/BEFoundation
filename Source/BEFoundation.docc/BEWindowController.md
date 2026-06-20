# ``BEWindowController``

A base `NSWindowController` that supports parent/child window relationships and document-wide closing.

## Overview

`BEWindowController` extends `NSWindowController` to provide a framework for managing window controller hierarchies (parents and children) and for coordinating the closing of all windows associated with a single document.

This class provides a default, built-in implementation for both the parent and child protocols. Subclasses explicitly opt-in to this functionality by conforming to `BEParentWindowController` and/or `BEChildWindowController`.

![A parent window controller with child and grandchild controllers; each registers with the shared manager on windowDidLoad, and closing the parent closes its descendants recursively.](window-controllers)

## Usage

### Protocols

- [BEParentWindowController](doc:BEParentWindowController)
- [BEChildWindowController](doc:BEChildWindowController)
- [BEWindowDelegate](doc:BEWindowDelegate)

### Constants

- [BEWindowDidLoadNotification](doc:BEWindowController/BEWindowDidLoadNotification)
- [kBEIsPrimaryWindowControllerKey](doc:BEWindowController/kBEIsPrimaryWindowControllerKey)

## Usage

### Creating a Subclass with Parent/Child Support

```objc
// Interface
@interface MyWindowController : BEWindowController <BEParentWindowController, BEChildWindowController>
@end

// Implementation
@implementation MyWindowController
// No implementation needed - inherits everything from BEWindowController
@end
```

### Managing Parent/Child Relationships

```objc
// Assuming parentController conforms to BEParentWindowController
[childController setParentController:parentController];

// Or add/remove explicitly
[parentController addChildWindowController:childController];
[parentController removeChildWindowController:childController];

// Access children
NSArray *children = parentController.childControllers;
```

### Primary Window and Document Closing

```objc
// Mark the main document window as primary
mainWindowController.isPrimaryWindowController = YES;

// When the primary window closes, all other document windows close automatically
// This is handled in the close method
```

## Properties

### isPrimaryWindowController

```objc
@property (assign) BOOL isPrimaryWindowController;
```

Indicates that this is the "primary" window for a document.

When the primary window controller is closed (via its `close` method), it will trigger `closeDocumentWindowControllers` to close all other window controllers associated with the same document.

## Methods

### closeDocumentWindowControllers

```objc
- (void)closeDocumentWindowControllers;
```

Closes all other window controllers that share the same `document` as this controller.

This method iterates over `self.document.windowControllers` and calls `close` on every controller except for `self`.

## Protocols

### BEParentWindowController

Activation protocol for parent window controller functionality.

Subclasses of `BEWindowController` should conform to this protocol to explicitly activate parent window controller capabilities. The implementation is inherited from `BEWindowController`.

#### Properties

- `childControllers` - An array of all `NSWindowController` instances managed by this parent

#### Methods

- `containsChildWindowController:` - Returns whether a child is in the parent's set
- `addChildWindowController:` - Adds a window controller to the parent's set of children
- `removeChildWindowController:` - Removes a window controller from the parent's set of children

### BEChildWindowController

Activation protocol for child window controller functionality.

Subclasses of `BEWindowController` should conform to this protocol to explicitly activate child window controller capabilities. The implementation is inherited from `BEWindowController`.

#### Properties

- `parentController` - The parent window controller that manages this window controller

### BEWindowDelegate

Extends `NSWindowDelegate` to include a `windowDidLoad:` notification-based callback.

#### Optional Methods

- `windowDidLoad:` - Called from within `-[BEWindowController windowDidLoad]` after `super` has been called

## Constants

### BEWindowDidLoadNotification

```objc
APPITKIT_EXTERN NSNotificationName const BEWindowDidLoadNotification;
```

A notification posted after the window has loaded, the delegate has been notified, and super has been called.

This supplements the standard `NSWindowDelegate` methods, allowing for observers to react to the window's load. The `object` of the notification is the `NSWindow` instance that has loaded.

### kBEIsPrimaryWindowControllerKey

```objc
#define kBEIsPrimaryWindowControllerKey (@"BEIsPrimaryWindowController")
```

An `NSCoding` key for persisting the `isPrimaryWindowController` property.

Used when encoding or decoding the window controller, such as when restoring a document's windows.

## Relationships

See Also: [BETabView](doc:BETabView), [BEWindowControllerManager](doc:BEWindowControllerManager), [BEPathControl](doc:BEPathControl)
