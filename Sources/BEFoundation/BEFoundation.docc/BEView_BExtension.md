# BEView+BExtension

Auto Layout convenience for `NSView` (macOS) and `UIView` (iOS).

```objc
#import <BEFoundation/BEView+BExtension.h>
```

## Overview

`BEView` is a cross-platform alias (`NSView` / `UIView` — see <doc:BEPlatformTypes>). These helpers replace the usual anchor boilerplate. Each one clears `translatesAutoresizingMaskIntoConstraints`, **activates** the constraints it creates, and **returns** them so you can deactivate or animate them later. The implementation is shared — `NSLayoutAnchor` and `UILayoutAnchor` are the same API.

## Usage

### Pinning and centering

```objc
[child pinEdgesToSuperview];                                   // fill the superview
[child pinEdgesToSuperviewWithInsets:BEEdgeInsetsMake(8,8,8,8)];
[badge centerInSuperview];
```

`pinEdges…` uses leading/trailing anchors (so `insets.left`/`insets.right` respect right-to-left layout) and returns an empty array when there is no superview.

### Sizing

```objc
[thumbnail constrainToSize:CGSizeMake(64, 64)];
NSArray<NSLayoutConstraint *> *wh = [bar constrainToWidth:200 height:44];
// ...later: [NSLayoutConstraint deactivateConstraints:wh];
```

## See Also

- <doc:BEPlatformTypes>
- <doc:CrossPlatformUI>
