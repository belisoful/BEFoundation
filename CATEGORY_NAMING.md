# Category Method Naming on Apple Classes

BEFoundation extends Apple classes (`NSImage`, `NSColor`, `NSString`, …) through categories.
A category method whose selector matches a method Apple attaches to the same class produces
undefined behavior: the Objective-C runtime keeps both implementations and gives no guarantee
about which one dispatch resolves. The build emits no warning, because the duplicate lives in a
different binary.

## The rule

- A public category method on an Apple class uses a descriptive name that Apple does not use.
  Prefer Apple's own public naming idioms without colliding with them:
  `imageFromCGImage:`, `CGImageRepresentation`, `pngRepresentation` (the `TIFFRepresentation`
  idiom). Never reuse a UIKit/AppKit method name — those exact spellings are what Apple's
  compatibility shims define.
- A private (non-header) category helper carries the `be_` prefix: `be_bitmapRep`.
- Before adding a category method, verify the selector is absent from the target class at
  runtime with the relevant Apple frameworks loaded (see "Checking a selector" below), not just
  absent from the SDK headers.

## Why headers are not enough

Apple frameworks attach **private** category methods to AppKit/UIKit classes at runtime, and
some of those frameworks load lazily mid-process.

**A collision presents as a flaky test.** Dispatch resolves to one implementation or the other
depending on image load order, so the same test passes in isolation, passes under ASan, and
fails intermittently under parallel full-suite runs. Every flaky failure investigated in this
project traced back to a selector collision. Treat intermittent, load-order-dependent failures
as a collision until proven otherwise.

The 1.1 release fixed a real instance:

- PencilKit's macOS binary contains a private `NSImage` category defining exactly
  `+imageWithCGImage:` and `-CGImage` (UIKit-compatibility shims; declared in no SDK header).
- AppKit dlopens PencilKit lazily during window machinery setup.
- BEFoundation's 1.0 `BEImage (BExtension)` used the same UIImage spellings. Once PencilKit
  loaded, dispatch could resolve to PencilKit's implementation (observed: a non-nil empty
  `NSImage` for `NULL` where BEFoundation returns nil), which failed
  `testNilInputsReturnNil` in 25–31% of parallel full-suite runs — exactly the runs where a
  worker executed the window-controller suites first. Both resolution directions were observed
  across load configurations; the runtime makes no promise.
- The collision is bidirectional: in a load order where BEFoundation's implementation wins,
  PencilKit's internal calls receive BEFoundation's semantics. Re-asserting an IMP after
  Apple's framework loads is therefore not a fix; non-overlapping names are.

Full incident record: [FIXES.md](FIXES.md) ("BEImage+BExtension").

## Resolving a collision: rename, never share

When a desired selector already exists privately on the target class, BE renames its
method. Sharing the selector — whether by category (undefined winner) or by runtime
registration that yields to Apple's copy — leaves BE callers invoking a private Apple
implementation whose semantics are unversioned and whose use violates the no-private-API
rule for shipping products. A BE-owned selector is deterministic on every OS release.

The collection categories apply this policy (all renamed from selectors that exist
privately in CoreFoundation, OSAnalytics, or ScreenReaderCore):

| BE method | Collided with |
| --- | --- |
| `pushObject:` / `popObject` | OSAnalytics `push:`/`pop` (its `push:` returns nil, breaking chaining) |
| `removeFirstElement` / `removeLastElement` | CoreFoundation `removeFirstObject`/`removeLastObject` |
| `insertElementsOfArray:atIndex:` | ScreenReaderCore `insertObjects:atIndex:` |
| `be_setSet:` / `be_setOrderedSet:` / `be_setArray:` | CoreFoundation property setters |

For readwrite category properties, rename only the setter selector
(`@property (…, setter=be_setSet:)`): dot syntax is compiled against the declared setter,
so `array.set = value` keeps working while the colliding selector disappears.

`hasMutability` (BEMutable, declared on NSObject) follows the same policy: Foundation
defines a private per-instance `isMutable` on NSCharacterSet, and a root-class category is
the most collision-prone place a generic name can live.

## The collision guard

`Scripts/check-category-collisions.sh <BEFoundation.framework>` extracts every category
method on an external class from the built binary and fails if any selector already exists
in a clean process (with PencilKit and ScreenReaderCore force-loaded). Run it as part of
the full check; it prevents this entire bug class from returning.

## Checking a selector

Absence from headers proves nothing; check the runtime. Compile a probe with
`clang -fobjc-arc -framework AppKit probe.m`:

```objc
// Does the class answer the selector, and which binary provides the IMP?
Method m = class_getClassMethod(NSImage.class, sel_registerName("imageWithCGImage:"));
if (m) {
    Dl_info info = {0};
    dladdr((void *)method_getImplementation(m), &info);
    printf("taken by %s\n", info.dli_fname);
}
```

To enumerate everything a lazily loaded Apple framework adds to a class, diff
`class_copyMethodList` (class and metaclass) before and after `dlopen`-ing the framework.

## Diagnosing a suspected collision in tests

Capture the evidence inside the failing test: store the baseline IMP in `+load`, and on failure
report the current IMP, whether it changed, and its providing image via `dladdr`. That turns an
"impossible" result — a nil-guarded method returning non-nil — into a named binary.
`BEImage+BExtensionTests.m`'s `testNilFactories_returnNilWithPencilKitLoaded` keeps the
PencilKit scenario pinned.

## Known unprefixed survivors

`BEColor+BExtension` (`colorWithHexString:`, `dynamicColorWithLight:dark:`) and
`BEView+BExtension` (`pinEdgesToSuperview`, `centerInSuperview`, `constrainToSize:`, …) predate
this policy. No Apple collision exists for them today (probed against PencilKit); review them at
the next minor release. The `NSOpenPanel` category's public `ss_` methods also predate the
policy and keep their names.
