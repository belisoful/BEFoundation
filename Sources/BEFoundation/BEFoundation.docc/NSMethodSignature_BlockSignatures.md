# NSMethodSignature+BlockSignatures

Block signature extraction and conversion for dynamic method implementations.

```objc
#import <BEFoundation/NSMethodSignature+BlockSignatures.h>
```

## Overview

This header exposes the Apple Block ABI layout (`BlockFlags`, `Block_literal`,
`Block_descriptor`) and tools to read a block's Objective-C type-encoding signature and convert
it into an `NSMethodSignature`. It underpins
[NSObject+DynamicMethods](doc:NSObject_DynamicMethods), which uses these signatures to build
NSInvocations for block-backed methods.

![The Block_literal struct (isa, flags, reserved, invoke, descriptor) whose descriptor points to a Block_descriptor holding the type-encoding signature, which the category converts into an NSMethodSignature.](block-layout)

## Usage

### Extracting Block Signatures

```objc
id block = ^(id self, NSString *param) {
    return [self stringByAppendingString:param];
};

// The block's own (raw) signature, including the leading block pointer.
const char *raw = NSSignatureForBlock(block);

// A method-ready signature: leading block pointer dropped, SEL _cmd injected at index 1.
NSMethodSignature *sig = [NSMethodSignature methodSignatureFromBlock:block];
// sig.numberOfArguments == 3  (self, _cmd, param)
```

`BEBlockSignatureChar` (which backs `NSSignatureForBlock`) resolves both the regular and the
compact "small" block-descriptor layouts.

### App Store Compliance

The `BE_APPLE_TERMS_COMPLIANT` build flag (default `1`) keeps the default build free of
non-public Apple symbols: only the hand-rolled descriptor reader is used, so the binary is safe
for App Store submission. Building with `-DBE_APPLE_TERMS_COMPLIANT=0` opts in to the runtime's
own (non-public) `_Block_signature` extractor — do not ship such a build to the App Store.

### Signature Parsing Utilities

`BEMethodSignatureHelper` provides the low-level parsing used by the conversions:
`rawBlockSignatureChar:`, `blockSignatureString:`, `parseBlockSignature:parseFlags:`, and the
type/number cursor parsers.

## See Also

- [NSObject+DynamicMethods](doc:NSObject_DynamicMethods)
- [BERuntime](doc:BERuntime)
