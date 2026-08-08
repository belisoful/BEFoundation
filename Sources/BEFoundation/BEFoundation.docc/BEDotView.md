# ``BEDotView``

A cross-platform status-indicator dot, a port of Prado's `TDot`.

## Overview

`BEDotView` draws a three-dimensional dot: a radial gradient from the highlight color at the
lower center to the main color at the rim, a white specular reflection near the top, and a soft
drop shadow. Setting ``flat`` draws a plain filled circle with an optional border instead.

It subclasses [BEView](doc:BEPlatformTypes), so one class renders on every platform BEFoundation
supports — `NSView` on macOS, `UIView` on iOS and tvOS. Drawing uses a top-left, y-down
coordinate system everywhere (macOS overrides `isFlipped`), so a single Core Graphics path
serves them all.

The color presets, the shade cascade, and the tuning constants reproduce Prado `TDot`'s output
(`framework/Web/UI/WebControls/TDot.php`); its SVG document becomes Core Graphics
radial-gradient drawing.

## Setting the Color

The appearance comes from a single color, set through ``colorName``:

| `colorName` value | Result |
| --- | --- |
| `@"Green"`, `@"DeepSkyBlue"` | A web color name, using TDot's preset main/highlight pair |
| `@"-Green"` | A `-` prefix forces the standard web color over any preset |
| `@"#70FF90"` | A hex value; main is computed darker and highlight lighter by ``depth`` |

``mainColor`` and ``highlightColor`` override the computed pair directly.

### Preset colors

All 141 named presets, each carrying TDot's hand-tuned main and highlight pair.

![A grid of all 141 named preset dots, each a three-dimensional sphere labeled with its color name.](bedotview-presets)

### Computed colors

The same 141 names forced with a `-` prefix, so the pair is computed from the standard web
color through the shade cascade rather than read from the preset table. Compare a few against
the grid above to see where a preset differs from its computed equivalent.

![A grid of all 141 standard web colors with main and highlight computed by the shade cascade.](bedotview-computed)

### Flat colors

The same presets with ``flat`` set — a plain filled circle with a border, no gradient,
specular, or shadow.

![A grid of all 141 preset dots drawn flat: solid circles with a border and no shading.](bedotview-flat)

## Status Indication

``setState:`` maps a ``BEDotState`` to its status color:

| State | Color |
| --- | --- |
| ``BEDotState/BEDotStateOff`` | Gray |
| ``BEDotState/BEDotStateOk`` | LimeGreen |
| ``BEDotState/BEDotStateWarning`` | Yellow |
| ``BEDotState/BEDotStateError`` | Red |
| ``BEDotState/BEDotStateActive`` | Blue |

## Examples

Each row below is rendered by the property settings named beneath it.

![Six labeled rows of dots: the five status states; a preset pair beside its "-"-forced computed equivalent; one hex color at five depth values; three explicit main/highlight pairs; four shadow opacities; and five flat border settings.](bedotview-custom)

### Status indicator

```objc
BEDotView *dot = [[BEDotView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
[dot setState:BEDotStateOk];        // LimeGreen

// Reflect a connection change.
[dot setState:isConnected ? BEDotStateActive : BEDotStateError];
```

### Custom color

```objc
// A web color name uses TDot's preset main/highlight pair.
dot.colorName = @"DeepSkyBlue";

// A hex value computes the pair from depth.
dot.colorName = @"#70FF90";
dot.depth = 40;                     // a wider spread between rim and highlight

// Or set the pair explicitly.
dot.mainColor = someColor;
dot.highlightColor = someLighterColor;
```

### Flat style

```objc
dot.flat = YES;                     // plain filled circle
dot.flatBorder = YES;               // with a border (the default)
dot.flatBorderWidthFraction = 0.08; // border width as a fraction of the diameter
```

## Topics

### Color

- ``colorName``
- ``mainColor``
- ``highlightColor``
- ``depth``

### Status

- ``setState:``
- ``BEDotState``

### Appearance

- ``flat``
- ``flatBorder``
- ``flatBorderWidthFraction``
- ``shadowOpacity``

## See Also

- <doc:CrossPlatformUI>
- <doc:BEPlatformTypes>
- <doc:BEColor_BExtension>
- <doc:BEView_BExtension>
