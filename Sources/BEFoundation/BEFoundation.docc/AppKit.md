# AppKit Extensions

This group covers AppKit extensions for path controls, tab views, window controller management, open panels, and pasteboards.

## Overview

BEFoundation provides these AppKit extensions:

- [BEPathControl](doc:BEPathControl) - An `NSPathControl` subclass with relative URL support for displaying project-relative file paths
- [BETabView](doc:BETabView) - An `NSTabView` subclass supporting dynamic tab hiding/showing while preserving tab order
- [BEWindowController](doc:BEWindowController) - A base `NSWindowController` with parent/child window relationship support
- [BEWindowControllerManager](doc:BEWindowControllerManager) - A centralized manager for tracking all active `BEWindowController` instances
- [NSOpenPanel+BESecurityScopedURLManager](doc:NSOpenPanel_BESecurityScopedURLManager) - `NSOpenPanel` categories that bookmark selected URLs into a `BESecurityScopedURLManager`
- [NSPasteboard+BExtension](doc:NSPasteboard_BExtension) - Typed read/write convenience for strings, URLs, and images

## See Also

- <doc:CrossPlatformUI>
- <doc:Collections>
- <doc:RuntimeManagement>
