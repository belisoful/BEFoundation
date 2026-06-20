# AppKit Extensions

This group covers AppKit extensions for path controls, tab views, and window controller management.

## Overview

BEFoundation provides several AppKit extensions that enhance standard AppKit functionality:

- [BEPathControl](doc:BEPathControl) - An `NSPathControl` subclass with relative URL support for displaying project-relative file paths
- [BETabView](doc:BETabView) - An `NSTabView` subclass supporting dynamic tab hiding/showing while preserving tab order
- [BEWindowController](doc:BEWindowController) - A base `NSWindowController` with parent/child window relationship support
- [BEWindowControllerManager](doc:BEWindowControllerManager) - A centralized manager for tracking all active `BEWindowController` instances
- [NSPasteboard+BExtension](doc:NSPasteboard_BExtension) - Typed read/write convenience for strings, URLs, and images

## Classes

- [BEPathControl](doc:BEPathControl) - Path control with relative URL filtering
- [BETabView](doc:BETabView) - Tab view with dynamic visibility support
- [BEWindowController](doc:BEWindowController) - Window controller with parent/child relationships
- [BEWindowControllerManager](doc:BEWindowControllerManager) - Manager for tracking window controllers
- [NSPasteboard+BExtension](doc:NSPasteboard_BExtension) - Typed pasteboard read/write

## See Also

- <doc:CrossPlatformUI>
- <doc:Collections>
- <doc:RuntimeManagement>
