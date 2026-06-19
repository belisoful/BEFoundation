# AGENTS.md

## Project Overview

**BEFoundation** is an Objective-C framework that extends Apple's Foundation framework with utilities for notifications, runtime manipulation, number/data handling, image processing, data structures, and more. The project uses Xcode for building and XCTest for unit testing.

It is **cross-platform (macOS + iOS)** and ships as a **Universal binary (arm64 + x86_64)**. UI/AppKit-vs-UIKit type differences are bridged by `BEPlatformTypes.h`, which declares `@compatibility_alias` names (`BEColor`, `BEImage`, `BEFont`, `BEView`) that resolve to the right platform class at compile time.

## Build & Test Commands

```bash
# Build the framework (macOS)
xcodebuild -project BEFoundation.xcodeproj -scheme BEFoundation -configuration Debug -destination 'platform=macOS' build

# Run unit tests (macOS, arm64 native)
xcodebuild -project BEFoundation.xcodeproj -scheme BEFoundation -configuration Debug -destination 'platform=macOS' test

# Run unit tests on the x86_64 slice (Rosetta on Apple Silicon)
xcodebuild test -project BEFoundation.xcodeproj -scheme BEFoundation -configuration Debug -destination 'platform=macOS,arch=x86_64'

# Run unit tests on iOS Simulator — use a CONCRETE arm64 simulator id, not 'generic'
ID=$(xcodebuild -showdestinations -scheme BEFoundation -project BEFoundation.xcodeproj 2>/dev/null \
       | grep 'platform:iOS Simulator' | grep 'arch:arm64' | grep -oE 'id:[0-9A-F-]{36}' | head -1 | cut -d: -f2)
xcodebuild test -project BEFoundation.xcodeproj -scheme BEFoundation -configuration Debug -destination "platform=iOS Simulator,id=$ID"

# Validate the DocC catalog
xcodebuild docbuild -project BEFoundation.xcodeproj -scheme BEFoundation -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
```

### Full Check (required before commit)

Code is commit-ready only when every check below passes. These mirror the CI jobs.

1. Build + `test` on **macOS arm64** (`platform=macOS`)
2. `test` on the **macOS x86_64** slice (`platform=macOS,arch=x86_64`)
3. `test` on the **iOS Simulator** (concrete arm64 id)
4. `test` under **AddressSanitizer** (`-enableAddressSanitizer YES`, macOS)
5. `docbuild` of the DocC catalog

## Cross-Platform and Architecture Notes

- **Platform aliases** — extend the real platform classes through `BEPlatformTypes.h`. A category on `BEColor` is a category on `NSColor` (macOS) or `UIColor` (iOS). macOS-only code is wrapped in `#if TARGET_OS_OSX`.
- **iOS Simulator** — always target a concrete arm64 simulator id. `generic/platform=iOS Simulator` also builds the x86_64 slice, which fails on the NEON/Accelerate intrinsics the framework pulls in.
- **`BOOL` encoding differs by ABI** — `@encode(BOOL)` is `"B"` on arm64 and `"c"` on x86_64. On x86_64 `BOOL` is `signed char`, so `BOOL` and `char` are indistinguishable at runtime. Tests must use `@encode(BOOL)` rather than a hardcoded `"B"`, and `NSMutableNumber` follows `NSNumber` by treating `"c"` as `char`.
- **Frame lengths and `long double` differ by ABI** — `NSMethodSignature frameLength` and `long double` size (8 bytes arm64, 16 bytes x86_64) are architecture-specific. Guard exact-value assertions with `#if defined(__arm64__) || defined(__aarch64__)`.
- **`<arm_neon.h>`** — never import it unguarded. Wrap any arm-only header in `#if defined(__arm64__) || defined(__aarch64__)` so the x86_64 slice compiles.
- **No private Apple APIs** — products that ship this framework must not call private methods in Apple's APIs.

### Profile-Guided Optimization

`OptimizationProfiles/BEFoundation.profdata` is consumed by the Release config (`CLANG_USE_OPTIMIZATION_PROFILE=YES`). To refresh it: run `test` in Release with `-enableCodeCoverage YES ENABLE_CODE_COVERAGE=YES CLANG_USE_OPTIMIZATION_PROFILE=NO` for **both** macOS and iOS (the framework target's `ENABLE_CODE_COVERAGE` is `NO`, so the override is required to instrument it), then `xcrun llvm-profdata merge` the two `Coverage.profdata` files into one cross-platform profile.

## Project Structure

- `Source/` — Framework source code (Objective-C and Swift); `BEPlatformTypes.h` holds the cross-platform aliases
- `BEFoundationTests/` — XCTest unit tests (a `PBXFileSystemSynchronizedRootGroup`: files added to this folder are compiled automatically)
- `BEFoundation.xcodeproj/` — Xcode project file
- `BEFoundation.xctestplan` — Test plan configuration
- `OptimizationProfiles/` — Profile-guided-optimization data (`BEFoundation.profdata`)

### Vendored: NSMutableNumber

`NSMutableNumber` is maintained as a standalone upstream repo (`/Users/user/Code/NSMutableNumber`); BEFoundation vendors a copy. These four files **must stay byte-identical** between the two:

| BEFoundation copy | Upstream repo |
| --- | --- |
| `Source/NSMutableNumber.h` | `NSMutableNumber.h` |
| `Source/NSMutableNumber.hpp` | `NSMutableNumber.hpp` |
| `Source/NSMutableNumber.mm` | `NSMutableNumber.mm` |
| `BEFoundationTests/NSMutableNumberTests.m` | `Tests/NSMutableNumberTests.m` |

The repo is upstream: prefer its conventions, mirror any edit to both places, and confirm with `diff -q`.

## Code Conventions

- Objective-C header/implementation pattern (.h/.m files)
- Swift files use explicit imports of Foundation and related frameworks
- Bridging header: @todo There is no Bridging yet.
- Tests follow the naming pattern: `<ClassName>Tests.m`
- Some source files have duplicate extensions (e.g., `.m` and `.mm` for Objective-C++)
- `if` statements always use a block (`{}`), never a single-line body.
- Uniform Access Principle / self-encapsulation: read and write state through accessors, not direct ivar access.
- Extract Method → Predicate/Guard Clause (Fowler) is preferred over nested conditionals.
- **Backward compatibility** — point releases must stay backward compatible. Minor releases may break, but minimize the breaks.
- Document the introducing version on new public methods and classes.

## Code Comments

The bar for a comment is high. Code should explain itself through clear naming and
structure; comments are reserved for what the code cannot express.

- Use HeaderDoc `/*! ... */` blocks for public types, methods, and properties — the
  established house style. Put multi-sentence rationale in the method's `@discussion`.
- Write an inline `//` comment ONLY when it documents something non-obvious the code cannot
  state on its own: a subtle invariant (e.g. "must run on the access queue"), an external
  constraint or platform quirk (e.g. an Apple API that returns nil with no error; an
  abstract class cluster that raises on `[super init]`), or a deliberate omission a
  maintainer might otherwise "fix".
- Do NOT narrate what the code obviously does, restate the method name, or leave
  historical / "FIX:" / "previously the code did X" / "regression" justifications. The diff
  and commit message carry that — not the source.
- Prefer one terse line over a paragraph. If a comment needs several lines, it usually
  belongs in the HeaderDoc `@discussion`, not inline.
- The same bar applies to test code: the test method name should describe intent; add a
  comment only for a non-obvious setup or invariant.

## Documentation Style (enforced)

HeaderDoc blocks and comments are technical documentation written with direct technical statements.
Language and National Variety: English — American.
Qualities of the writing: clear, thorough, easy to comprehend, not verbose (brevity), timeless, integrated, wholistic.
Tense: Present — tuned for ease of comprehension.

_Banned constructions_:
- **Antithesis / "not merely X — it Ys"**: no "does not just X, it Ys", "is not a Y, it's a Z", "rather than X, it Ys". State what it does, once.
- **Em-dash dramatic asides** used for emphasis or reveal ("— and that's the point"). Use a period or plain clause.
- **Editorializing / filler.**
- **Rule-of-three rhetorical lists** and build-up sentences. One fact per sentence.

Prefer subject–verb–object declaratives, and bullet lists of `condition → result` where appropriate. Documentation informs and describes; it is not persuasive writing. Documentation additions, changes, and removals are integrated into the surrounding text at each level of detail.

## Adding New Source Files

1. Add .h and .m files to `Source/`
2. Add corresponding test file to `BEFoundationTests/` (auto-compiled — the test group is synchronized)
3. Register new framework files in the Xcode project via project.pbxproj or the Xcode GUI; mark public headers `Public`
4. Add the public header to the umbrella `BEFoundation.h`
5. macOS-only files are excluded from the iOS target via `EXCLUDED_SOURCE_FILE_NAMES[sdk=iphone*]`

## Key Dependencies

- Foundation.framework
- AppKit.framework (macOS) / UIKit.framework (iOS) — via `BEPlatformTypes.h`
- CoreImage.framework (for CIImage+BExtension)
- Metal.framework / Accelerate.framework (for BEMetalHelper)
- XCTest.framework (for tests)

## Safeguards (Anti-Patterns)

Required without exception:

- **NEVER** run `git clone/mv/restore/rm/branch/commit/merge/rebase/reset/push` without developer approval first.
- **NEVER** run `rm` on any path without developer approval first.
- **NEVER** erase or overwrite files for the task of unit testing — the changes being tested must be preserved.
- **NEVER** delete a file or folder until its associated task is completely finished.
