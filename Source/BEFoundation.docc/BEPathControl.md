# ``BEPathControl``

An `NSPathControl` subclass that limits displayed path items based on a relative URL.

## Overview

`BEPathControl` extends `NSPathControl` to introduce a concept of a "relative" root for the displayed file path. When a `relativeURL` is set, the path control automatically filters its path items to only show the components of the full URL that are descendants of the `relativeURL`, including the relative URL itself.

This is useful for displaying file paths within a project or document structure, where the full path is known, but only the parts relative to the project's root should be visible to the user.

![A BEPathControl whose URL is a deep file path, displaying only the components beneath its relativeURL root: MyApp › Sources › Views › MainView.swift.](bepathcontrol)

## Usage

### Creating a Path Control

- [initWithFrame:](doc:BEPathControl)

### Configuring the Relative URL

- [relativeURL](doc:BEPathControl/relativeURL)

### Checking Path Containment

- [containsURL:](doc:BEPathControl/containsURL:)

## Usage

### Basic Relative Path Display

```objc
BEPathControl *pathControl = [[BEPathControl alloc] initWithFrame:frame];

// Full path to a file inside a project
NSURL *fullURL = [NSURL fileURLWithPath:@"/Users/user/Projects/MyProject/Sources/File.m"];

// The project's root path
NSURL *relativeURL = [NSURL fileURLWithPath:@"/Users/user/Projects/MyProject/"];

pathControl.relativeURL = relativeURL;
pathControl.URL = fullURL;

// The path control will display: MyProject / Sources / File.m
// It hides: / / Users / user / Projects
```

### Checking URL Containment

```objc
NSURL *projectRoot = [NSURL fileURLWithPath:@"/Users/user/Projects/MyProject/"];
NSURL *filePath = [NSURL fileURLWithPath:@"/Users/user/Projects/MyProject/Sources/File.m"];
NSURL *externalPath = [NSURL fileURLWithPath:@"/Users/user/Desktop/Other.txt"];

pathControl.relativeURL = projectRoot;

BOOL isContained = [pathControl containsURL:filePath];     // YES
BOOL isExternal = [pathControl containsURL:externalPath]; // NO
```

## Properties

### relativeURL

```objc
@property (nullable, nonatomic) NSURL *relativeURL;
```

The URL defining the root of the displayed path items.

When set, the path control will only display path items (`NSPathControlItem`) whose URL is a descendant of, or equal to, this URL. Any leading path components up to and including the system root will be hidden.

Setting this property triggers a rebuild of the path items based on the currently set `URL` property. The URL is automatically standardized for reliable path comparison.

If set to `nil`, the path control behaves like a standard `NSPathControl` and displays the full absolute path from the root.

## Methods

### containsURL:

```objc
- (BOOL)containsURL:(NSURL *)checkURL;
```

Determines if a given URL is a descendant of the relative URL.

This method compares the provided `checkURL` against the current `relativeURL` property. It returns `YES` if:

1. The `relativeURL` is `nil` (no restriction)
2. `checkURL` is exactly equal to `relativeURL`
3. `checkURL`'s path components begin with `relativeURL`'s path components (it is a descendant)

URLs are standardized and compared by path components, so containment is exact at directory boundaries. A sibling such as `/Projects/AppX` never matches a `/Projects/App` bookmark.

## Relationships

See Also: [BETabView](doc:BETabView), [BEWindowController](doc:BEWindowController)
