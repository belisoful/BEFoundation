# BEFoundation — Bug Fixes by Version

This document records concrete bug fixes shipped in each release, with enough detail to
understand the failure mode, the root cause, and the fix. New features and additions are
tracked separately in `README.md`'s Change Log.

---

## 1.1 (unreleased)

### BEWebData / NSURL+Data / NSData+URLDownload

- **`NSData+URLDownload`: every download leaked its `NSURLSession` and handler.** The sessions are
  created with `sessionWithConfiguration:delegate:delegateQueue:`, which retains the delegate (the
  `BEDataDownloadHandler`) strongly until the session is invalidated — and nothing ever invalidated
  them. Each `dataDownloadWithContentsOfURL:` / `downloadFileWithURL:` therefore leaked a session
  *and* its handler for the process lifetime. Both factory paths now call
  `-finishTasksAndInvalidate` after creating the task, so the session tears down and releases the
  delegate once the one-shot task completes.

- **`BEWebData`: use-after-free on the download semaphore.** The data-task completion handler
  signalled `_dataTaskSemaphore` and then **nil'd the ivar** (`_self->_dataTaskSemaphore = 0`),
  while the synchronous init path concurrently read that ivar to pass to `dispatch_semaphore_wait`.
  A fast completion could hand `wait()` a NULL semaphore (crash) or deallocate the semaphore
  mid-wait. Removed the nil — the ivar keeps the semaphore alive until the object deallocates.

- **`BEWebData -getBytes:range:` read out of bounds.** `MAX(MIN(range.length, self.length -
  range.location), 0)` underflowed when `range.location > length` (both unsigned), and `MAX(…, 0)`
  is a no-op on unsigned values — so an out-of-range location read past the end of the buffer. Now
  guards the location and clamps the length. Added regression tests for the out-of-range and
  straddling-end cases.

- **`BEWebData`: data race on the asynchronous (`BEDataReadingAsynchronous`) HTTP/HTTPS path.** The
  background data-task completion handler wrote `_data`, `_dataTaskResponse`, `_dataTaskError`,
  `_MIMEType`, `_charset`, `_stringEncoding`, `_dataTask`, and `_isComplete` with no synchronization,
  while the public getters (`bytes`, `length`, `isComplete`, the metadata accessors, …) read them on
  another thread. The completion now publishes all state under `@synchronized(self)` with
  `_isComplete` set **last**, and the matching getters read under the same lock — so a reader that
  observes `isComplete == YES` is guaranteed (via the lock barrier) to see fully-written data. The
  user completion block and the semaphore signal fire **outside** the lock to avoid calling out while
  holding it; `setDataTaskCompletionHandler:` coordinates under the same lock so a handler installed
  after completion still fires exactly once. Verified clean under ThreadSanitizer.

- **`BEWebData`: copied and unarchived instances reported `isComplete == NO`.** `copyWithZone:`
  and `initWithCoder:` populate `_data` and the metadata but never set `_isComplete`, so a fully
  materialized copy/restored object claimed to be an in-flight load — wrong on its own, and worse now
  that `isComplete` is the published completion flag. Both set `_isComplete = YES` (the result is a
  finished, standalone snapshot with no data task). `copyWithZone:` and `encodeWithCoder:` also now
  snapshot `self` under `@synchronized(self)` so copying/archiving an object whose async load is
  still running can't tear. Added `isComplete` assertions to the copy and archive round-trip tests.

- **`NSData+URLDownload`: leaked temp file on the `allowBothCompletions` data-task path.** When a
  data (in-memory) download had `allowBothCompletions` set, the handler wrote the bytes to
  `NSTemporaryDirectory()/<UUID>` to feed the file-style callbacks but never removed it, leaking a
  file per download. The synthesized file now follows the same lifetime contract as a download
  task's location (valid only for the callback) and is deleted once the callbacks return; documented
  on `allowBothCompletions` / `tempCompletionBlock`.

- **`NSURL+Data`: `decodedData`/`decodedString` returned nil for a charset-less, non-text data URL.**
  For e.g. `data:application/octet-stream,Caf%C3%A9` there is no charset, so `stringEncoding` is `0`.
  `dataUsingEncoding:0` / `initWithData:encoding:0` fall back to a *deprecated* Foundation ASCII
  mapping (it logs "Incorrect NSStringEncoding value 0x0000 detected … will stop … in the near
  future") that drops every non-ASCII byte and returns nil. Both now fall back to UTF-8 when
  `stringEncoding` is `0`, recovering the percent-decoded content. Added a non-ASCII regression test.

- **`NSURL+Data`: uninitialized `BOOL` in the `isBase64` getter** (only set on a code path that
  always runs in practice, but undefined if it ever didn't). Initialized to `NO`.

- **Doc corrections (`BEWebData`):** the `encodeWithCoder:` doc claimed it encoded "via super"
  (it encodes manually); the `dataTaskSemaphore` property doc was a copy of `dataTask`'s; and the
  class doc claimed "Thread-safe (metadata is immutable after initialization)", which is false for
  HTTP/HTTPS URLs (data and metadata are filled in asynchronously). All corrected to describe the
  real async behavior. The `initWithContentsOfURL:options:error:` doc now also spells out that a
  synchronous http/https load **blocks the calling thread** until the request completes (don't call
  it on the main thread for remote URLs) and that `BEDataReadingAsynchronous` returns an empty
  instance to be read only after `isComplete` is YES.

- **Flaky test: `testLoadingFromWebURL_asynchronous_badurl` raced a fixed `sleep(1)` against DNS
  failure.** On a slow/restricted network the error callback arrives after 1s and the assert fails
  (observed: failed in a full-suite run at 3.0s, passed solo at 1.0s). Replaced the fixed sleep with
  a run-loop poll bounded at 15s that exits as soon as `dataTaskError` arrives.

### NSObject+DynamicMethods / DynamicMethodsHelpers

- **Heap buffer overflow in `BEMethodSignatureHelper +mutateInvocation:withMeta:`** (the routine that
  copies a dynamic method's invocation arguments into a new invocation). The per-argument copy buffer
  started at 256 bytes and only grew when `[methodSignature getArgumentSizeAtIndex:i] > 256` — but
  `getArgumentSizeAtIndex:` reports a *pointer-sized* value (8) for ANY by-value struct, so the realloc
  guard never fired for aggregates, while `-getArgument:` copies the *full* value. A dynamic method
  whose block takes a by-value struct larger than 256 bytes therefore wrote past the buffer. Fixed by
  sizing the buffer with `NSGetSizeAndAlignment` (the argument type's true size). Added a 320-byte
  by-value-struct round-trip test; verified RED→GREEN **under AddressSanitizer** (the old code aborts
  with heap-buffer-overflow, the fix is clean — a plain value check can't see it because the copied
  bytes still round-trip while adjacent heap is corrupted).

- **Use-after-free on the dynamic-dispatch path (concurrent remove/replace vs. invoke).**
  `dynamicForwardInvocation:` fetched the `BEDynamicMethodMeta` via a lock-and-release accessor, then
  invoked `meta.implementation` *unlocked* — while `removeObjectMethod:`/replace called `[meta clear]`,
  which ran `imp_removeBlock` and freed that IMP. A concurrent remove during dispatch invoked a freed
  trampoline. Fixed by tying the IMP teardown to the meta's lifetime: moved `imp_removeBlock` from the
  eager `-clear` (now removed, along with its four call sites) into `BEDynamicMethodMeta -dealloc`. The
  dispatch path holds a strong reference to the meta for the duration of the invoke, so an in-flight
  call keeps the IMP alive even if the method is removed/replaced concurrently; the trampoline is freed
  only once no one references it. This also fixes the prior IMP/trampoline **leak** when a meta was
  dropped without `clear`, and the unbalanced MRC `Block_release` in `clear`. Added a replace-then-invoke
  regression test verified under AddressSanitizer.

- **`synchronizeWithClassProtocols` always returned `NO`** (the `returnValue` was initialized `NO` and
  never reassigned), so its `BOOL` couldn't distinguish "already in sync" from "performed a sync." It
  now returns `YES` when a synchronization is actually performed (the object's protocol hash differed
  from the class's) and `NO` when already in sync.

- **`-removeObjectForwardTarget:` parameter was typed `(Protocol *)`** though it takes a forward
  *target* object (passed to `removeObjectProtocol:withTarget:`); the header correctly declared `id`.
  Corrected the `.m` to `(nonnull id)target`.

- **Doc corrections:** `isDynamicMethod:`'s header promised protocol/target forwarding it does not
  actually check (the implementation has `@todo`s and returns NO for forwarded-only selectors) — the
  doc now states that limitation. `addObjectMethod:`'s discussion was self-contradictory (it both
  described the SEL `_cmd` injection and claimed "the SEL is not available to the block") — rewritten
  to describe the optional-`_cmd` behavior the code implements. Fixed the stale `@file`
  (`NSObject+DynamicMethodsHelpers.m` said `NSObject+DynamicMethods.m`), empty `@abstract`/`@discussion`
  file headers in both `.m`s, and a garbage `@abstract toeh` block with the wrong `@method` name above
  `_dynamicMethodsAllowNSKey`.

### NSMethodSignature+BlockSignatures

- **The `BlockFlags` enum was incomplete and had a wrong value and a misnamed flag** versus the
  canonical Apple Block ABI (`Block_private.h`), verified against real runtime blocks. Fixes:
  `BLOCK_REFCOUNT_MASK` was `0xffff` but must be `0xfffe` (bit 0 is the deallocating bit, not part of
  the refcount); the bit-31 flag was named `UNKNOWN_BLOCK_FLAG` but is actually
  `BLOCK_HAS_EXTENDED_LAYOUT` (confirmed: every capturing block sets it). Added the five missing
  flags — `BLOCK_DEALLOCATING` (bit 0), `BLOCK_INLINE_LAYOUT_STRING` (1<<21), `BLOCK_SMALL_DESCRIPTOR`
  (1<<22), `BLOCK_IS_NOESCAPE` (1<<23) — and documented every constant (runtime vs. compiler). A test
  locks all bit positions and checks them against blocks the compiler actually emits.

- **Signature extraction did not handle the small descriptor layout.** When `BLOCK_SMALL_DESCRIPTOR`
  is set the descriptor uses a 32-bit `size` and 32-bit *relative* offsets instead of pointers; the
  old `NSSignatureForBlock` macro read those as absolute pointers, which would return garbage / crash
  on a toolchain that emits small descriptors. It now routes through `BEBlockSignatureChar`, which
  resolves both layouts (regular = absolute pointer after the reserved/size header and optional
  copy/dispose helpers; small = `fieldAddress + relativeOffset`).

  The **regular path is authoritatively verified**: disassembling this platform's
  `libsystem_blocks._Block_signature` shows it tests bit 30 (`BLOCK_HAS_SIGNATURE`) then bit 25
  (`BLOCK_HAS_COPY_DISPOSE`) and reads the signature as an **absolute pointer at descriptor +16/+32**
  — exactly what `BEBlockSignatureChar` does, and a 6/6 probe of real blocks matched the runtime
  string-for-string.

  The **small-descriptor path is defensive and unverified.** That same disassembly has **no**
  small-descriptor branch at all (it never tests bit 22, never reads a relative offset), and clang on
  this toolchain never emits `BLOCK_SMALL_DESCRIPTOR` for Objective-C blocks under `-O0..-O3`. So the
  path is unreachable here and its field-order arithmetic could not be validated against the runtime;
  it must be exercised before being relied on for any future toolchain. (An earlier note that the
  small path was "probe-verified" was an overclaim — every probe block used a regular descriptor.)
  The regular path is covered by the existing BlockSignatures tests.

- **Added the `BE_APPLE_TERMS_COMPLIANT` build flag (default 1).** When 1 (default), only the hand-rolled
  reader is used and the binary references no non-public symbols — verified with `nm`: a default build
  contains **no** `_Block_signature` reference, so it is App Store safe (Guideline 2.5.1). Building with
  `-DBE_APPLE_TERMS_COMPLIANT=0` opts in to the runtime's own (non-public) `_Block_signature`, which
  authoritatively resolves every descriptor layout, with the hand-rolled reader as a weak-import
  fallback. Both build configurations compile/link cleanly; the symbol is referenced only in the
  opted-out build (confirmed weak-external-from-libSystem). Do not ship an opted-out build to the App Store.
  Verified against the *actual consumer*: the `NSObject+DynamicMethods` suites (whose dispatch copies
  invocation arguments byte-for-byte using the derived signature) pass under both `BE_APPLE_TERMS_COMPLIANT=1`
  (145 tests) and `=0` (145 + BlockSignatures = 171 tests, with the binary confirmed to use the runtime
  extractor). `Scripts/run-noncompliant-tests.sh` runs the opt-out config (BlockSignatures + DynamicMethods),
  including a `#if !BE_APPLE_TERMS_COMPLIANT`-guarded test that exercises the `_Block_signature` path directly.

- **`NS_FORMAT_FUNCTION` on `prependFormat:`/`stringByPrependingFormat:` surfaced pre-existing format
  misuse in the deliberate edge-case tests** (empty/zero-length formats and non-literal format strings
  used to exercise runtime behavior). Wrapped those specific calls in targeted
  `#pragma clang diagnostic ignored "-Wformat"/"-Wformat-security"` blocks (matching the pattern the
  test file already used for the Foundation `appendFormat:` calls), so the build is warning-clean.

- **Doc corrections:** the `@header`/`@file` were left as `NSObject+DynamicMethods`; the `Block_descriptor`
  doc now notes the small-descriptor variant; bare `@encode` in doc prose (which clang parsed as a doc
  command, causing a `-Wdocumentation` warning) reworded.

### NSObject+Macroable

Audit of the Laravel-style macro façade over `NSObject+DynamicMethods`. No production logic
defects were found; the code correctly delegates registration/dispatch to DynamicMethods, and
`isMacrosEnabled`'s `> 0` test was confirmed equivalent to the library's
`isDynamicMethodsEnabled(state)` macro (since `DMInheritNone == 0`).

- **Documented but untested behavioral contract, now proven and regression-tested.** The header
  states that disabling macros keeps them registered but not callable until re-enabled. Traced
  `disableDynamicMethods` (it flips the activation flag while leaving the swizzle and meta
  dictionaries intact) and added `testDisableMacros_KeepsMacroRegistered_NotCallable_ReEnableRestores`,
  which verifies: disabled → `hasMacro` YES / `respondsToSelector` NO → re-enable → callable again
  returning the original value.

- **Doc gaps filled.** `macro:macroBlock:` and `objectMacro:macroBlock:` accept a `nil` block as a
  "remove" (returning YES) and auto-enable macro support — neither was documented in the header.
  Added these semantics, plus the instance-override note for object macros.

- **Coverage added** for two real gaps: object-macro replacement
  (`testObjectMacro_Replacement_UpdatesBlock`) and falling back to the class macro after removing an
  instance override (`testRemoveObjectMacro_ClassMacroResurfaces`).

- **Observation (not changed):** `BEMacroMeta` stores its block with `_block = block` rather than
  `[block copy]`. This is internal bookkeeping that is never invoked (the callable copy lives in
  DynamicMethods via `imp_implementationWithBlock`), an existing test relies on its pointer identity,
  and the full suite is AddressSanitizer-clean — so it is a latent style nit, not a live defect.

- **Verification:** 63/63 Macroable tests pass, clean build with no `-Wdocumentation` warnings, and
  the suite is green under AddressSanitizer (runtime confirmed linked; zero reports).

### NSDictionary / NSOrderedSet / NSSet / NSString +BExtension

- **`NSString+BExtension`: `NS_FORMAT_FUNCTION` was missing from the header** for
  `-stringByPrependingFormat:` and `-prependFormat:` (it was on the `.m` definitions, which does
  nothing for callers). Callers therefore got no compile-time `-Wformat` checking of their format
  strings. Added the attribute to both header declarations. (No other logic bugs were found — the
  four categories are otherwise correct; two "bugs" flagged during the sweep, an `intersectArray:nil`
  crash and a wrong exception type on the recursive merge, were verified NOT real: `intersectArray:nil`
  simply empties the set, and the recursive path already raises `NSInvalidArgumentException`.)

- **Pervasive copy-pasted / wrong doc blocks corrected.** `NSDictionary+BExtension.m`'s
  `objectsClasses` family was pasted from an NSSet extension ("the objects in the set", "a new NSSet
  containing class name strings", wrong `@result` types) and `mapUsingBlock:` had a truncated stub
  (`@note This method defines the`); `-filterPairs` was the wrong `@method` name; the recursive-merge
  family had duplicated/wrong `@method` tags, an inverted "does not overwrite" abstract on the *add*
  variants, and an unconditional "mutable collection classes are mutableCopy-ed" claim (it is
  flag-gated). `NSString`'s `systemDate/Time/DateTimeValue` and `dateWith…`/`timeWith…` docs claimed
  "Returns YES" / used `is…`-style `@method` tags though they return `NSDate*`; the class overview
  listed selectors that don't exist; the CharacterCounter doc claimed it "correctly counts … emoji"
  when it only tests the first `unichar` (astral-plane members are not matched). `NSSet`/`NSOrderedSet`
  overviews referenced non-existent `-map:`/`-filter:`; `NSOrderedSet objectsClassNames` `@result`
  wrongly said "NSCountedSet" (it returns an NSOrderedSet) and the deduped accessors falsely claimed
  "how many of each there are". All corrected to match the code.

- **Documented real gotchas**: `filterUsingBlock:` (NSSet/NSOrderedSet) rebuilds from the kept objects,
  so setting `*stop` mid-filter discards the unvisited remainder; `intersectArray:nil`/empty empties
  the receiver; CharacterCounter is BMP-only.

- **Examples** added to all four category headers. **Tests** — closed the coverage gaps:
  re-enabled the commented-out mutable `NSMutableDictionary mapUsingBlock` test (with a non-mutation
  assertion); added `intersectArray:` no-overlap / full-overlap / nil-empties and an `objectsClasses`
  dedupe-vs-`objectsUniqueClasses` count assertion (NSOrderedSet); `mapUsingBlock` `*obj = nil` drop
  and `toClassesFromStrings` mutable-return (NSSet/NSOrderedSet); `is*Value` leading/trailing
  whitespace leniency, Arabic-Indic digit acceptance, empty-string subscript and empty/boundary insert
  (NSString); and for the recursive-combine family: the recursive (not just non-recursive) non-dict
  exception, `MutableCollectionCopyFlag` on a nested **NSArray** (which confirmed plain collections DO
  conform to `BECollectionAbstract` via BEMutable — the flag's non-dict branch works, contrary to an
  initial suspicion), the no-copy-flag aliasing-by-reference behavior, combined flags, deep 3-level
  nesting under `SelfMutableCollectionFlag`, and `swapped` on an empty dictionary.

### NSDateFormatter+RFC2822 / NSDateFormatter+RFC3339

- **`NSDateFormatter+RFC2822` doc falsely claimed RFC 2822 is "a profile of the ISO 8601 standard"
  and "Compatible with ISO 8601".** Both were copy-pasted from the RFC 3339 header. RFC 2822 is the
  Internet Message Format (email/HTTP/RSS) date, derived from RFC 822 — unrelated to ISO 8601.
  Corrected to describe what it actually is and to point ISO 8601 users at the RFC 3339 category.

- **Documented the verified parsing behaviors and gotchas of the fixed formats**, and spelled out
  strict RFC conformance. RFC 3339 accepts a `Z`/`z` zone or numeric offset but rejects the optional
  productions — fractional seconds (`…30.5Z`), the §5.6 separator alternatives (space *and* lowercase
  `t`, which stays case-sensitive as a format literal even though the `z` zone does not), a leap
  second (`…:59:60Z`), an out-of-range hour (`24:00`), and any trailing content — each now tested and
  listed in the header / `.docc`.
  RFC 2822 requires the leading weekday and a numeric zone, so `23 Jun 2025 …` or `… GMT` returns
  nil — and the weekday, though required, is NOT validated against the date (an inconsistent weekday
  is silently accepted), while a single-digit day (`1 Jun`) is accepted; comments/CFWS (`… (UTC)`)
  are rejected, so real email headers must be stripped first. Also noted that each
  `+rfc…DateFormatter` allocates a fresh, relatively expensive formatter that should be reused for
  bulk work (and is thread-safe to read concurrently).

- **Parsing was entirely untested** — every existing test only exercised `stringFromDate:`. Added
  round-trip, `Z`-vs-`+00:00` equivalence, non-UTC offset → correct UTC instant, and the two
  reject-cases above, for both categories. Also added usage examples to both category doc blocks,
  fixed stale `@header`/`@file`/include-guard names left over from the file rename, the RFC 3339
  `.docc` import path, and added the missing RFC 2822 `.docc` page.

### NSArray+BExtension / NSCoder+AtIndex / NSCoder+HalfFloat

- **`NSCoder+HalfFloat -decodeHalfForKey:` dereferenced a possibly-misaligned pointer.** It read the
  decoded value as `*(_Float16 *)p`, but the coder's inner byte pointer is not guaranteed to be
  2-byte aligned, so the load was undefined behavior. Now copies the bytes out with `memcpy` (same
  emitted load on the supported architectures, but well-defined). Existing round-trip tests cover it.

- **`NSCoder+HalfFloat -decodeHalfForKey:` defaults to 0 (was NaN) for a missing/malformed value.**
  Every other NSCoder scalar decoder (`decodeFloatForKey:`, `decodeIntForKey:`, …) returns a zero
  value for an absent key; returning NaN made `decodeHalf` the lone exception and broke the drop-in
  symmetry that is this category's whole purpose. It now returns 0, matching the family — and because
  a stored NaN still round-trips, a real NaN is now *distinguishable* from "missing" (NaN vs 0) rather
  than colliding with the old sentinel. Use `-containsValueForKey:` to tell a stored 0 from a missing
  key, exactly as with the other scalar decoders. Tests updated accordingly.

- **Doc corrections.** `NSCoder+HalfFloat` claimed it ensured "proper byte ordering … for the target
  platform"; it actually stores raw native-endian bytes with no byte-swap, so the header now says so
  (round-trips on the same platform, not cross-endian). Fixed copy-pasted file/category headers
  (`NSCoder+HalfFloat.m` was titled `NSCoder+AtIndex.m`; `NSCode` → `NSCoder`), the `decodeBytesAtIndex:`
  `@return` that wrongly said "decoded double", and several AtIndex decode docs that said "string key"
  instead of "integer index". In `NSArray+BExtension.m` the `objectsClasses` / `objectsClassNames` /
  `objectsUniqueClasses` / `objectsUniqueClassNames` / `toClassesFromStrings` doc blocks were
  copy-pasted from an NSSet extension (wrong method names like `-setClassNames`, "set" instead of
  "array", and inverted descriptions); all rewritten to match what the code does.

- **Usage examples** added to every primary `@category`/`@protocol` doc block across the three files
  (`NSArray (BExtension)`, `NSMutableArray (BExtension)`, `NSCoder (AtIndex)`, `NSCoder (HalfFloat)`).

- **Test coverage.** Added regression tests for the documented "setting `orderedSet`/`set` to nil
  clears the array" behavior (previously untested) and for `decodePropertyListAtIndex:` (a real but
  untested wrapper — verified `decodePropertyListForKey:` exists and the path works).

### NSNumber+BExtension / NSNumber+Primes16b

- **Crash: integer modulus by zero (SIGFPE).** `numberOperation`'s divide case guarded against a
  zero divisor (returning NaN) but the modulus case did not, so `[@10 modulusNumber:@0]` (and the
  `modulusInt:`/`modulusUInt:` family) trapped on integer `%` by zero. Added the same guard the
  divide path uses. Proven RED→GREEN: the new `testModulusNumber_ByZero` crashes the unfixed build
  and passes after the fix. Documented the NaN result in the header.

- **`floatToFpXX` was declared but never implemented.** The header exported a fully-documented
  configurable IEEE-754 float→packed-int encoder with no definition anywhere, so any client calling
  it would fail to link. Implemented it by porting Prado's `TBitHelper::floatToFpXX` (throw-on-bad-
  config becomes return-0). Validated standalone against 26 canonical vectors (every IEEE fp16 value
  including subnormals/inf/NaN/−0 and rounding edges, bf16 spot checks, non-conformant saturation,
  invalid-config → 0) before integrating, and added `testFloatToFpXX_Fp16CanonicalVectors` /
  `testFloatToFpXX_NonConformantSaturationAndFormats`.

- **Prime table verified, not assumed.** Extracted all 6544 entries of `NSPrimeNumbers16Bit` and
  checked them against an independent sieve: exactly the 6542 primes below 2^16, strictly ascending,
  correct guard (`1` at index 0) and sentinel (`0` at index 6543), largest 65521 — no missing, extra,
  or non-prime entries. The ceil/floor/round binary-search logic is correct and stays in-bounds via
  the guard/sentinel.

- **Doc fixes:** filled the empty `.m` `@abstract`/`@discussion` in both files;
  `roundPrimeIndex16:`'s header said NaN/NSNotFound for values *"greater than"* the 65521↔65537
  midpoint, but the code and tests exclude the midpoint itself (`>= 65529`, since rounding it up would
  escape the 16-bit range) — corrected to "at-or-greater-than" with the rationale.

- **Observations (left as-is):** the lazy `typeOrder` table build is not strictly thread-safe (benign
  — worst case builds twice and leaks one array); a 32-bit-only branch in that table is dead code on
  64-bit; the experimental `NSNumber+BExtension.swift` is not in the build target. Flagged, not
  changed.

- **Verification:** 93/93 tests pass (51 BExtension + 42 Primes16b), clean build with no doc warnings,
  and both suites are green under AddressSanitizer (runtime confirmed linked; zero reports).

### NSMutableNumber

Audit of the C++-backed mutable NSNumber replacement (.h/.hpp/.mm). The fixes below were also
applied to the standalone `belisoful/NSMutableNumber` repo, which additionally gained a native-macOS
host-less test target so its suite runs on My Mac without a development team.

- **`addOne`/`minusOne` silently truncated doubles to float.** The real-number branch's else
  (the double case) called `set<float>(get<float>() …)`, converting the stored double to float
  (precision loss + type change). Fixed to `set<double>`. Proven RED→GREEN with type- and
  precision-asserting tests.

- **NSNumber `plusOne`/`subtractOne` wrapped unsigned char as signed.** The `unsigned_char` case
  used `initWithChar:`, so 200 + 1 became a signed-char wrap. Fixed to `initWithUnsignedChar:`.
  Reachable only via objCType `'C'` (this Foundation canonicalizes `numberWithUnsignedChar:` to
  `'s'`), proven RED→GREEN via the suite's `NSMockNumber`, which preserves `'C'`, using 200 (above
  the signed range — the prior test used 0x7b and could not expose the wrap).

- **`compare:` wired through `NSMNumberCTypeIsSigned`** (was an unconditional else), with BOOL added
  to the signed classification. This also made the documented contract real: an operand with an
  unrecognized type encoding now compares as NSOrderedDescending (unsupported) instead of being
  mis-compared as signed. Covered by new BOOL-operand and bogus-encoding tests.

- **Removed six assertions of C undefined behavior from `testCompareSignedTo`.** They asserted the
  results of raw `(NSInteger)INFINITY` / `(NSUInteger)NAN` casts — UB whose value changes with
  compiler mode (they failed under AddressSanitizer codegen while passing without). They tested the
  compiler, not the class; the `compare:`-based infinity/NaN assertions remain.

- **Coverage:** .mm 98.85%, .hpp 90.23% after wiring `NSMNumberCTypeIsSigned`. Every remaining
  uncovered line is deliberate cross-architecture support (the `long`/`unsigned long` paths,
  unreachable on LP64 where `long` encodes as `'q'`) plus the C++ `isSigned()` accessor, kept as
  defensive API symmetry with the used `isUnsigned()`/`isReal()`.

- **Header doc prose proofread:** fixed long-standing typos inherited with the third-party code
  ("of couce", "Comparation", "standart", "ammount", "bacause", "Thread save"), mirrored to the
  standalone repo so the two `.h` files remain byte-identical.

- **Verification:** 80/80 tests pass, green under AddressSanitizer (runtime confirmed linked, zero
  reports).

### BECharacterSet

- **Crash: `[[BEMutableCharacterSet alloc] initWithSet:nil]` produced an immutable-backed mutable
  set.** `initWithSet:` had no nil fallback, so the superclass init (which runs after the subclass
  seeds `_characterSet` — a deliberate ordering) filled in an immutable `NSCharacterSet`; the first
  mutation then trapped (CFCharacterSet "Immutable character set passed to mutable function",
  SIGTRAP). Reproduced standalone (RED), fixed with an `NSMutableCharacterSet` nil fallback (GREEN),
  and regression-tested. Added a comment documenting the deliberate seed-before-super ordering.

- **Swapped doc blocks (.m):** `formUnionWithCharacterSet:` carried the doc for intersection and
  vice versa. Un-swapped (the header's docs were correctly paired).

- **False aliasing claim (.m):** the `BEMutableCharacterSet.characterSet` getter doc said mutations
  to the returned set are "NOT reflect[ed]" — empirically false: the getter returns the backing
  instance itself, so mutations ARE reflected. Corrected the doc and added a test asserting the
  actual behavior.

- **Verified, no change:** equality/hash model is coherent (instance setting overrides class
  setting; ClassStyle=0 falls through; hash XORs a constant exactly when NSCharacterSet-inequality
  is selected, matching `isEqual:`'s gate); secure-coding round trip works and decodes mutable for
  the mutable class (probed empirically, including post-decode mutation). `@header` → `@file` in
  the .m. Observation, not changed: the `URL*AllowedCharacterSet` family and `characterSetWithName:`
  are not mirrored — an API-completeness gap, not a defect.

- **`characterSetWithContentsOfFile:` never returned nil.** Both classes' factories are declared
  `nullable` and document "nil if the file cannot be read", but they wrapped the underlying
  factory's nil in `initWithSet:nil` and returned an empty set instead (probed empirically, RED).
  Fixed to propagate nil per the declared contract — also Apple's semantics — and regression-tested
  (GREEN).

- **Header proofread in full** (881 lines): doc blocks are accurate and consistent throughout; the
  only defects found were the contract mismatch above. Observation for polish: the
  `kCharSetDifferentiable` macro is defined identically in both `BECharacterSet.h` and
  `BEMutable.h` (legal, but a divergence hazard), and the `.h` copyright line lacks the leading
  dash used elsewhere.

- **Verification:** 48/48 tests pass (45 prior + 3 new), green under AddressSanitizer.

### BERuntime / BESingleton / BE_ARC

Audit of the three small runtime/support components (none previously audited).

- **BERuntime:** implementation correct (`metaclass_getClass` validates metaclass-ness and
  round-trips through the name; `class_hasMethod` walks only the class's own method list and frees
  it). 20 tests cover nil/edge/dynamic cases. Fixed the `#endif` guard comment typo (`BEruntime_h`).

- **BESingleton:** double-checked locking, ancestor-chain propagation, and the atexit cleanup are
  sound; 28 tests including concurrency. Fixed the `.h` copyright line ("All rights reserved" →
  the project-standard "All rights released"). Observation, not changed: the chain-walk terminator
  `![singletonChain isMemberOfClass:NSObject.class]` is always true for Class objects (a class is
  never a *member* of NSObject) — the protocol-conformance check is what actually terminates the
  loop, so the extra clause is dead but harmless.

- **BE_ARC:** macros correct in both ARC and MRC expansions. Completed the truncated `@discussion`
  (it ended mid-sentence) and fixed the trailing `#endif` comment, which named another file's guard
  (`NSArray_Extension_h`).

### BEFoundation.h umbrella / public headers

- **The umbrella header was broken for clients** — `#import <BEFoundation/BEFoundation.h>` failed to
  compile (proven with a real client-style build against the framework, RED). Three distinct breaks:
  it imported `NSNotification+MutableInfo.h` (no such header — the real public headers are
  `NSNotification+ExtraProperties.h` and `NSNotification+MutableUserInfo.h`) and the renamed-away
  `NSDateFormatterRFC3339.h`; and the public `NSObject+DynamicMethods.h` quote-imports
  `NSMethodSignature+BlockSignatures.h`, which was not a public header. None of this surfaced
  in-project because nothing in the framework or tests imports the umbrella.

- **Fixes:** rewrote the umbrella to import exactly the framework's public headers (adding the
  missing `NSDateFormatter+RFC2822/RFC3339`, both `NSNotification` categories, and
  `NSOpenPanel+BESecurityScopedURLManager`); marked `NSMethodSignature+BlockSignatures.h` Public in
  the project and added it to the umbrella; fixed the stale "BFoundationExtension" file comment.
  GREEN: the client-style compile now builds, links, and runs against the framework.

- **Observation, not changed:** `BEFileCache.h` is not a public header (Project visibility), so it
  is intentionally or accidentally absent from the umbrella — flagged for a decision.
  `BEFoundation-Bridging-Swift.h` is an empty placeholder, consistent with the project notes.

### BEPredicateRule

- **`-hash` / `-isEqual:` contract violation.** `-hash` folded in the priority only when the
  receiver's `isUniqueItemPriority` was set, but `-isEqual:` compared priority whenever *either*
  rule was unique — an asymmetry a single object's hash cannot mirror. Two equal rules (one unique,
  one not, same predicate/outcome/priority) could therefore hash differently, corrupting `NSSet`
  membership and `NSDictionary` keys. Fixed by making `-isEqual:` also require the
  `isUniqueItemPriority` flag itself to match (it is part of identity), so equal rules always agree
  on whether priority participates in both equality and the hash. Added a regression test.

- **`-copyWithZone:` and the keyed archiver dropped `isUniqueItemPriority`.** A copied or
  encoded→decoded rule silently lost the flag, so it could compare and hash differently from its
  original. Both now carry the flag. Added copy and secure-coding round-trip regression tests.

### BEStackExtensions

- **Added the missing test suite.** The component (stack/queue `push`/`pop`/`shift` on
  `NSMutableArray` and `NSMutableOrderedSet`, plus the ordered-set `isPushOnTop` behavior) had no
  unit tests; added one covering LIFO/FIFO order, nil handling, chaining, variadic push, and both
  `isPushOnTop` modes.
- Corrected the `@file` banner (it read `CIImage+BExtension.m`).

### BEPriorityExtensions

- **Documented a sorting side effect.** `priorityComparator` assigns the default priority to
  `BEPriorityCapture` objects that have none — i.e. sorting *mutates* such elements and is not safe
  to run concurrently on objects sharing state. This is now called out in the header.

### BEPathWatcher

- **Callbacks ran while the internal lock was held → cross-thread deadlock.** `handleEventWithFlags:`
  invoked the event block / target-selector / subclass hook inside `@synchronized(_lock)`. If a
  callback re-entered the watcher from another thread (e.g. dispatched work that called
  `stopMonitoring`/`path`), that thread blocked on the lock the callback's thread still held — a
  deadlock. The handler now snapshots the callback configuration under the lock and invokes the
  callbacks outside it. Added a regression test that re-enters the watcher from a background thread
  (confirmed it deadlocks against the old code and passes against the fix).

- **`setEventHandler:` was unsynchronized and didn't copy the block.** Every other mutator
  (`setTarget:selector:`, `setPath:`, `setEventMask:`) runs under `_lock`, but the event-handler
  setter wrote `_target`/`_selector`/`_block` with no lock — racing the event handler that reads
  them — and assigned the block directly despite the property being `copy`. Now synchronized and
  copies the block.

- **`path` getter raced the setter.** `setPath:` reassigns the strong `_path` under `_lock`; the
  getter read it unguarded, which could race the release of the old string. The getter is now
  synchronized.

- **Auto-stop-on-delete could cancel the wrong dispatch source.** The event handler's
  "path was deleted/renamed → stop" step called `stopMonitoring`, which cancels whatever
  `_dispatchSource` currently is. Because callbacks now run outside the lock (above), a callback
  that reconfigures the watcher (a new path/source) — synchronously, or from another thread —
  leaves the *new* source installed, and the old source's delete would then cancel it, silently
  stopping a watch the caller just started. The event handler now passes the firing source and
  the auto-stop only fires when `_dispatchSource` is still that source. Added a regression test
  that reconfigures inside the delete callback (confirmed it stops the new watch against the old
  code and stays active against the fix).

- **`setPath:` compared `_path` outside the lock.** The early-return equality check read the
  strong `_path` ivar unguarded while `setPath:` on another thread could be reassigning it. The
  comparison is now inside `@synchronized(_lock)` (and simplified — `isEqualToString:` is
  symmetric and nil-tolerant).

- **Removed the dead `_dirFD` ivar.** It was only ever written, never read — the watched file
  descriptor is captured in the dispatch source's cancel handler via a local. Removing it also
  clears up a misleading comment.

### NSObject+GlobalRegistry

Audit of the thin NSObject category that forwards to the shared `BEObjectRegistry` singleton.

- **Doc bug: wrong unregister return value.** `unregisterGlobalInstance`'s header doc claimed
  `2 = fully unregistered`, but `BEUnregisterStatus_Unregistered` is `DecrementedBit | UnregisteredBit
  == 3` (the `.m` comment and `BEObjectRegistry.h` already said 3). Rewrote the `@return` to name the
  enum constants with their correct values (0 / 1 / 3) so it can't drift again. The new
  reference-counting test confirms the value empirically.

- **Category name mismatch.** The header declared `NSObject (BEGlobalRegistry)` while the
  implementation was `NSObject (GlobalRegistry)`. Renamed the `@implementation` to `BEGlobalRegistry`
  so the impl formally backs the header's interface (cosmetic — category names don't affect dispatch).

- **Filled the empty `.m` `@abstract`/`@discussion`.**

- **Verified accurate, left unchanged:** the "weak reference / auto-cleanup on dealloc" doc claims
  hold (`BEObjectRegistry` uses an `NSMapTable` with weak values); the `globalRegistryUUID` /
  `globalRegistryCount` / `isGlobalRegistered` / `setGlobalRegistryUUID:` accessors are declared via
  `BERegistryProtocol` (not undeclared). `+globalRegistry`'s triple init guard (associated-object
  check + `@synchronized` + `dispatch_once`) is redundant but correct, so left as is.

- **Coverage:** the documented reference-counting feature (the `Decremented` / `NotRegistered`
  statuses, multi-registration UUID stability) was untested — the gap that let the 2-vs-3 doc error
  survive. Added `testUnregister_ReferenceCounting`, `testUnregister_NeverRegistered_ReturnsNotRegistered`,
  and `testRegister_MultipleTimes_ReturnsSameUUID`.

- **Verification:** 9/9 tests pass, clean build (no doc/category warnings), and the suite is green
  under AddressSanitizer (runtime confirmed linked; zero reports).

### BEObjectRegistry

- **Lock-order inversion → deadlock.** The class is documented thread-safe, but `countForObject:`
  acquired `saltLock` then `registryTable` (via `simpleCountForObject:`), while
  `registerObject:` / `unregisterObject:` / the `clear*` methods acquired `registryTable` then
  `saltLock`. Two threads — one registering, one calling `countForObject:` on the same registry —
  could wedge AB-BA. `countForObject:` now takes the locks in the same order as everyone else
  (`registryTable` then `saltLock`). Added a concurrent register/count stress test (confirmed it
  deadlocks against the old ordering and passes against the fix).

- **`unregisterObject:` and `unregisterObjectByUUID:` returned different codes for the same
  outcome.** `unregisterObject:` returns the enum `BEUnregisterStatus_Unregistered` (3) on full
  removal; `unregisterObjectByUUID:` hard-coded `return 2;` (`BEUnregisterStatus_UnregisteredBit`
  alone, missing the decremented bit). A caller comparing against `BEUnregisterStatus_Unregistered`
  mishandled the by-UUID path. `unregisterObjectByUUID:` now delegates to `unregisterObject:`, so
  both return identical status codes; the test that asserted `2` was corrected.

- **`allRegisteredObjects` read the map table without synchronization.** It was a bare
  `return [registryTable dictionaryRepresentation];` while every other table access holds
  `@synchronized(registryTable)` — a concurrent mutation could crash or tear. Now synchronized.

- **`saltLock` read the global lock dictionary without synchronization, and could return nil.**
  `initWithKeySalt:` mutates `gSaltLocks` under `@synchronized(gSaltLocks)`, but the `saltLock`
  getter read it unguarded (a concurrent read of the mutable dictionary could crash), and a salt
  not present in `gSaltLocks` would yield a nil lock — silently turning `@synchronized([self
  saltLock])` into a no-op. The lock object is now resolved once at init and cached in an ivar
  (entries in `gSaltLocks` are never removed, so it is stable), which removes the unsynchronized
  read, guarantees a non-nil lock, and keeps the global lock off the hot path.

- **Per-instance registration count leaked and enabled pointer-reuse false positives.** The count
  lived in an `NSCountedSet` keyed by raw object pointer (`NSValue valueWithPointer:`). When a
  registered object deallocated without unregistering, its weak `registryTable` entry cleared but
  the counted-set entry persisted under the now-dangling pointer — a slow leak, and a new object
  allocated at the same address would inherit the stale count (`isObjectRegistered:` returning YES
  for an unrelated object). Replaced the counted set with a per-instance count stored as an
  associated object keyed by the registry itself, so it is released automatically when the object
  deallocates. Added a test that a fresh object inherits no count after a prior object deallocated
  without unregistering.

- **Doc / cosmetic.** Corrected the `@file` banner in both `BEObjectRegistry.m` and
  `NSObject+GlobalRegistry.m` (both said `NSObject+DynamicMethods.m`); fixed exception messages in
  `registerObject:` / `setRegistryUUID:forObject:` that named `NSMutableDictionary` instead of the
  registry's own class; corrected the `unregisterObject:` / `unregisterObjectByUUID:` /
  `unregisterGlobalInstance` return-value docs (said "2", actually `BEUnregisterStatus_Unregistered`
  = 3); and the `globalRegistryUUID` doc that claimed "read-only" for a read-write property.

### FxTime

- **`-hash` was missing, violating the NSObject equality/hash contract.**
  `-isEqual:` compares by value (`CMTimeCompare`), so `CMTimeMake(300, 30)` and
  `CMTimeMake(400, 40)` (both 10 s) are equal — but with no `-hash` override they
  inherited `NSObject`'s identity hash and returned *different* hashes. Equal objects with
  unequal hashes corrupt `NSSet` membership and `NSDictionary` keys (duplicates, failed
  lookups). Added a `-hash` derived from `CMTimeGetSeconds` for numeric times (equal
  rational values produce identical seconds, hence identical hashes), with stable distinct
  constants for the non-numeric special values (invalid, indefinite, ±infinity).

- **`-isEqual:` crashed on foreign types and mishandled nil.**
  The implementation blindly cast its argument to `FxTime` and sent it `-time`. Passing a
  non-`FxTime` object raised `unrecognized selector` (crash); passing `nil` could yield
  spurious equality, violating the `isEqual:nil` → `NO` contract. Hardened with a
  `self == object` fast path, a `nil`/`isKindOfClass:` type check, and an `(id)` signature.

- **`-compare:` / `-compareTime:` returned the inverted sign.**
  The result described the *argument* relative to the receiver, the opposite of the Cocoa
  `NSComparisonResult` convention (`[self compare:other]` must describe self relative to
  other). Any caller assuming standard semantics — e.g. sorting — got reversed ordering.
  Corrected the operand order so `-1`/`0`/`+1` now mean receiver `<`/`==`/`>` argument.
  **Behavior change:** callers that compensated for the old inversion must drop the
  workaround; the bundled tests were updated to the corrected orientation.

- **Immutable/mutable split: `FxTime` is now immutable, with a new `FxMutableTime`
  subclass.**
  `FxTime` was documented as suitable for "immutable time representations" yet exposed
  read-write components and in-place arithmetic, and was not thread-safe. Following the
  NSString/NSMutableString idiom, `FxTime` is now genuinely immutable (read-only
  components; no mutators) and therefore thread-safe, while the new `FxMutableTime : FxTime`
  carries the read-write component setters and the in-place `add:`/`subtract:`/`multiply…`/
  `minimum:`/`maximum:`/`convertTimeScale:` operations. `-copy` returns an immutable
  `FxTime` snapshot; `-mutableCopy` returns an independent `FxMutableTime` (the class now
  conforms to `NSMutableCopying`). Factory methods (`+time:`, `+zero`, etc.) use `[self …]`
  so they construct the correct class for the receiver.
  **Migration:** code that mutated an `FxTime` (set `value`/`timescale`/`flags`/`epoch`/
  `time`, or called arithmetic/min/max) must now use `FxMutableTime` (via `mutableCopy`,
  the factory/initializers, or by typing the variable as `FxMutableTime`).

- **`-copyWithZone:` hardcoded `FxTime`, an issue for subclassing.**
  Now part of the immutable/mutable copy semantics above: `-copy` always yields an
  immutable `FxTime`, `-mutableCopy` always yields an `FxMutableTime`.

- **`rationalize:tolerance:` sign/cast cleanups.**
  Replaced the `0x80000000` unsigned-literal-to-`int32_t` narrowing with `INT32_MIN`, and
  made the divisor cast `(int32_t)` consistent with the `multiplier` cast (was `(int)`).

- **`#import "math.h"` corrected to `#import <math.h>`** (system header).

### CIImage+BExtension

- **`createImageText:…` crashed on a nil or unrecognized font name (and on nil color).**
  `+[NSFont fontWithName:size:]` returns `nil` for an unknown/nil name; that `nil` was
  inserted directly into the attributes `NSDictionary` literal, raising
  `NSInvalidArgumentException` ("attempt to insert nil object"). Now falls back to
  `[NSFont systemFontOfSize:]` when the font is unavailable, and returns `nil` early if
  `text` or `color` is nil. Nil filter output is also guarded instead of propagated through
  the transform chain.

- **`combineImage:alpha:withImage:` did not validate inputs or clamp alpha.**
  Nil images now return `nil` rather than silently propagating nil filter output, and
  `topAlpha` is clamped to `[0.0, 1.0]` before entering the `CIColorMatrix` alpha vector
  (out-of-range values produced invalid premultiplied alpha).

- **`inputScaleFactor` was set to `@(YES)`.**
  This is a scale multiplier (`NSNumber`), not a boolean; it worked only by accident
  (`YES == 1`). Replaced with an explicit `@(1.0)`.

- **Nullability annotations added.**
  The header now wraps the API in `NS_ASSUME_NONNULL_BEGIN/END`, marks both return types
  `nullable` (both methods can legitimately return nil), and marks `fontName` `nullable`.

- **Corrected broken/copy-pasted doc comments** in the implementation for
  `combineImage:alpha:withImage:` (parameters were documented as "font size"/"font name"),
  and reconciled the documented selector name with the header.

- **Test helper leaked a `CGColorSpaceRef`.**
  `getBitmapFromImage:` called `CGColorSpaceCreateDeviceRGB()` inline and never released it,
  leaking one color space per pixel-inspecting test (CoreGraphics "Create" rule). The result
  is now captured and `CGColorSpaceRelease`-d.

### BESecurityScopedURLManager

- **Tier 3 directory containment never matched (resolution silently broken).** The contained-URL
  resolver compared the input's *URL absoluteString* (`file:///…`) against a bookmarked
  directory's *filesystem path* (`/…`), so the `hasPrefix:` check could never be true — a file
  inside a bookmarked directory was never resolved via containment, contrary to the documented
  four-tier behavior. (The existing Tier 3 tests masked this: they `XCTSkip` when the prefix
  doesn't match, so they were silently skipping rather than passing.) Fixed by deriving the input
  path via `-[NSURL path]` (which also percent-decodes) so both sides are filesystem paths; the
  Tier 3 tests now actually run and pass. Also made the containment **boundary-safe** — a sibling
  like `/a/ProjectsX` no longer matches a `/a/Projects` bookmark (exact match or `"/"`-delimited
  prefix only). Added a sibling-directory regression test.

- **Atomicity hardening (concurrency).** A focused atomicity audit found several cross-thread
  defects; all fixed:
  - **`startAccessingURL:` TOCTOU across the delegate gap.** While the delegate ran (a
    potentially long modal wait), the access queue was free, so a concurrent
    `clearCatalog`/`removeURLFromCatalog:` could be silently undone — the post-delegate block
    resurrected and re-keyed the stale entry, leaking a security scope the app believed it had
    released. The post-delegate block now re-validates that the captured entry is still the
    live catalog entry before re-keying; if the catalog changed during the gap it is not
    resurrected (the caller still gets a balanced access to the delegate-provided URL).
  - **Catalog key mutated off the access queue.** `updateStaleBookmark` set `entry.urlString`
    (the catalog dictionary key) under the *entry* lock, then reconciled the dictionary via an
    async relocation — leaving a window where `mutableCatalog`'s key and `entry.urlString`
    disagreed. The `urlString` change is now deferred to `handleBookmarkRelocationFromPath:`
    so the dictionary key and the entry's own key change together on the access queue.
  - **Off-queue `mutableCatalog` read.** The relocation's main-thread delegate notification
    read `self.mutableCatalog[newPath]` off the access queue (an unsynchronized
    `NSMutableDictionary` read concurrent with mutations — a crash risk); it now captures the
    relocated URL on the queue and passes it to the main-thread block by value.
  - **`storageOptions` data race.** The setter is now routed through the access queue, so the
    decision-input reads inside `loadCatalog`/`saveCatalog…` see a stable value and the two
    persistence stores can't desync. Added concurrency stress + concurrent-setter tests.

- **`updateStaleBookmark` could silently destroy a valid bookmark.**
  On a stale-bookmark refresh, `bookmarkDataWithOptions:` can return `nil` with no error
  (e.g. in a non-sandboxed process). The code checked only the error and then assigned
  `_bookmarkData = newBookmarkData` unconditionally, nilling a still-valid bookmark and
  making every subsequent `-url` resolution return nil. Added a `!newBookmarkData` guard
  mirroring the one already present in `initWithURL:lifetime:`.

- **Data race on `BESecurityScopedURLBookmarkEntry.url`.**
  The public `catalog` snapshot hands the same entry instances to arbitrary threads, while
  the lazy `-url` getter mutates `_url`/`_isStale`/`_bookmarkError`/`_bookmarkData` with no
  synchronization. Because ARC does not guarantee atomic object-ivar stores, a concurrent
  read/write of `_url` could over-release and crash. Wrapped the lazy resolution in a
  per-entry `@synchronized(self)` lock (never the manager's access queue, so no deadlock).

- **`BESecurityScopedURLBookmarkEntry`: completed the per-entry synchronization.** The fix above
  locked the `-url` getter's writes, but the other mutable-after-creation properties still
  raced: external readers reach `urlString`/`isStale`/`bookmarkData`/`bookmarkError` through
  unsynchronized synthesized getters, and the manager writes `entry.url`/`entry.bookmarkData`/
  `entry.isStale` through unsynchronized synthesized setters — a concurrent read/write of those
  strong ivars can over-release and crash. All accessors for mutable state now go through the
  same per-entry `@synchronized(self)` lock; init-only state (createdAt/lifetime/isDirectory/
  isSecurityScoped) keeps its synthesized accessors.

- **`BESecurityScopedURLBookmarkEntry`: a refreshed bookmark stayed flagged stale forever.**
  `-updateStaleBookmark` rewrote `bookmarkData` to the new location but never reset `_isStale`,
  so `isStale` reported `YES` permanently after the first successful refresh — inconsistent with
  the manager's relocation path, which already clears it. Now reset to `NO` on a successful
  refresh. The existing stale-bookmark test was corrected to assert the cleared state.

- **`BESecurityScopedURLBookmarkEntry.bookmarkData` was annotated nonnull but can be nil.** Inside
  `NS_ASSUME_NONNULL`, the property was implicitly nonnull, yet it is nil when the security-scoped
  bookmark cannot be created (e.g. a non-sandboxed process). Marked `nullable` (matching the
  reality the code already guards for) and documented that callers should check `bookmarkError`.
  Also corrected the `isStale`/`urlString` property docs to match the post-fix behavior (staleness
  is cleared on refresh; the key is updated on relocation) and documented that entry properties are
  safe to read from any thread.

- **Removed deprecated `[NSUserDefaults synchronize]` calls.**
  No-ops on macOS 12+, and on older systems they forced a synchronous disk write on the
  access queue, blocking other catalog operations. `NSUserDefaults` persists automatically.

- **Corrected contradictory documentation.**
  The header described `startAccessingURL:`/`endAccessingURL:` as "direct,
  non-reference-counted," but the implementation is fully reference-counted. Documentation
  was corrected to match the actual behavior. The four-tier resolution order and the Tier 4
  filename-collision hazard are now documented on `urlFromCatalogWithAbsolutePath:`, and the
  silent-failure behavior of `startAccessingAllURLs` (no delegate callback on failed
  entries, unlike `startAccessingURL:`) is documented.

- **Known issue (flagged, not yet fixed):** `handleBookmarkRelocationFromPath:toPath:`
  transfers reference counts keyed on the unresolved catalog path, which won't match a
  `refCounts` entry stored under the symlink-resolved form — dropping active access sessions
  on relocation. A correct fix needs the old *resolved* URL threaded in from the caller plus
  a regression test. Tracked as an `@todo` in the method's doc block.

### NSPriorityNotification / NSPooledPriorityNotification

- **Abstract-class init crash.**
  `NSNotification` is an abstract class cluster whose `-initWithName:object:userInfo:`
  raises "cannot be sent to an abstract object" for any non-Apple concrete subclass. The
  designated initializers store their own `_name`/`_object`/`_userInfo` ivars and override
  the accessors instead of calling `super`. The unavoidable
  `-Wobjc-designated-initializers` warning is suppressed locally with an explanatory comment.

- **Secure decoding dropped any non-flat `userInfo`.** `initWithCoder:` decoded `userInfo`
  with `decodeObjectOfClass:[NSDictionary class]`. Under secure coding every class reachable
  inside the dictionary must be whitelisted, so a `userInfo` containing nested arrays,
  nested dictionaries, dates, etc. failed to decode and came back `nil` — only flat
  string/number dictionaries survived (which is all the tests had exercised). Now decodes
  with `decodeObjectOfClasses:` over the standard property-list class set
  (`NSDictionary`/`NSArray`/`NSSet`/`NSString`/`NSNumber`/`NSDate`/`NSData`/`NSNull`/`NSURL`).
  Added a regression test that round-trips a nested `userInfo` under
  `requiringSecureCoding:YES`.

- **`NSPooledPriorityNotification.h` force-imported `<AppKit/AppKit.h>`** for a class that
  uses no AppKit (and is meant to be a Foundation-level internal). Removed, dropping an
  unnecessary framework coupling that would also break a Foundation-only / non-macOS build.

- **Added coverage** for previously-untested behavior: `+supportsSecureCoding`, the
  `ExtraProperties` `tag`/`identifier` fallbacks (to the notification object, then to
  `userInfo`), explicit-value-overrides-fallback, `mutableUserInfo` for both the mutable and
  immutable cases, and the pool's empty-state `unusedNotificationCount`.

### NSPriorityNotificationCenter

- **`cleanup` never unregistered from the system center.** It called
  `[super removeObserver:self]`, which removes observers from the receiver's own table — but
  the center registers *itself* on `NSNotificationCenter.defaultCenter` (a different
  instance), so this was a no-op. A center that had been "cleaned up" kept intercepting and
  re-dispatching every system notification, contradicting the method's documented contract.
  Now calls `[NSNotificationCenter.defaultCenter removeObserver:self]`, and `dealloc` does the
  same as a safety net. Added a regression test that posts to the system center before and
  after `cleanup`.

- **The center strongly retained its observers (and leaked itself).** The internal observer
  record held its `observer` in a strong ivar, unlike `NSNotificationCenter`, which does not
  retain observers — so observers were kept alive past their intended lifetime and were still
  invoked after the caller dropped them. Worse, the internal `_superPostNotification` record's
  observer is the center itself, forming a self-retaining cycle that leaked every non-singleton
  center unless `cleanup` happened to be called. The `observer` reference is now `weak`, which
  matches `NSNotificationCenter` semantics, stops calling observers after they deallocate, and
  breaks the cycle so transient centers deallocate normally. Added tests for non-retention.

- **Priority sort could overflow and reordered equal priorities.** The comparator computed
  `obj1.ncPriority - obj2.ncPriority`, which is signed-overflow undefined behavior for extreme
  priorities (e.g. `NSIntegerMin`/`NSIntegerMax`) and could invert the order; and
  `sortUsingComparator:` is not stable, so observers registered at the same priority were
  delivered in an arbitrary order rather than registration order (which `NSNotificationCenter`
  preserves). The sort now snapshots each observer's priority once (also avoiding an
  inconsistent comparator if a dynamic `ncPriority` changes mid-sort, which can raise) and
  sorts by `(priority, registrationIndex)` using overflow-safe `NSNumber` comparison. Added
  tests for equal-priority registration order and extreme-priority ordering.

- **`removeObserver:name:object:` ignored a nil name.** The name match was
  `[notifObserver.name isEqualToString:aName]`, which returns `NO` when `aName` is `nil`, so the
  documented "nil to remove all names" behavior removed nothing. Now matches all names when
  `aName` is `nil`. Added a regression test.

- **The internal super-post observer sorted at twice the default priority.** The center's
  internal `_superPostNotification` (which forwards a priority post to the underlying
  `NSNotificationCenter` at default priority) was constructed directly with
  `priority:defaultPriority`. A `PriorityItem` observer is expected to carry an *offset*: the
  `addObserver:` path subtracts `defaultPriority` so the priority getter's later
  `+ [observer ncPriority:]` nets back to the intended value. Building the record directly
  skipped that subtraction, so its effective priority was `defaultPriority + defaultPriority`
  (20 instead of 10). The stored offset is now `0`, which both yields exactly `defaultPriority`
  and tracks runtime changes to it. (No black-box test: the super-post delivers through the
  base `NSNotificationCenter` table, which is not reachable via the public API — the value is
  documented at the construction site instead.)

- **A throwing observer could leave a notification permanently flagged.**
  `_raiseSuperPostNotification:` set `isPriorityPost = YES`, forwarded to the underlying
  `NSNotificationCenter`, then set it back to `NO`. If an observer of the underlying center
  raised, the final reset was skipped, leaving the notification flagged (which would suppress
  its future priority dispatch). The reset is now in a `@finally`. Added a test that a
  throwing handler leaves the notification unflagged and the center usable. (The threading
  assumption — one notification instance must not be posted from two threads at once, since
  the flag is set/cleared around delivery — is now documented on the `isPriorityPost`
  property.)

- **Queued selector observers could invoke a freed target (use-after-free).** For an
  observer registered with a queue, the dispatch builds an `NSInvocation`, sets its target
  and notification argument, and runs it asynchronously on the queue — but never called
  `-retainArguments`. `NSInvocation` does not retain its target or object arguments by
  default, so if the observer deallocated between scheduling and execution, the async
  `-invoke` messaged a freed object. (The synchronous path is unaffected — it invokes
  immediately.) Now calls `-retainArguments` before enqueuing so the invocation owns its
  target and argument across the async boundary. Added a regression test that drops the
  observer while the operation is suspended in the queue. Note: this was latent but became
  reachable once `observer` became weak (above) — previously the strong reference kept the
  target alive.

- **The center strongly retained the notification object filter.** Like the observer, the
  per-registration `object` (a filter, not owned by the center) was a strong ivar, leaking it
  for the lifetime of the registration. It is now `weak`, matching `NSNotificationCenter`. To
  avoid a deallocated filter silently becoming a wildcard (a `nil` object historically meant
  "all objects"), each record captures an `observesAllObjects` flag at registration, so only a
  registration made *with* a nil object matches all objects. `raiseNotification:` also now
  prunes records whose weak observer has deallocated (keeping block observers and live ones),
  so dropped observers don't accumulate. Added tests for object non-retention and for the
  deallocated-filter-is-not-a-wildcard behavior.

### AppKit — BETabView

- **`allTabViewItems` setter was broken (crash) and its documented contract unimplemented.**
  The property was `@synthesize`'d as `(copy)` into an `NSMutableArray` ivar, so the setter
  stored an immutable `NSArray` and the next tab mutation crashed with unrecognized-selector.
  The setter is now hand-written: it copies into a mutable store, sets each item's
  `hiddenTabView` back-pointer, and rebuilds the superclass's visible tabs in order (hidden
  items stay hidden). The getter now returns an immutable snapshot. **Impact:** assigning
  `allTabViewItems` now works as documented instead of crashing. The setter also
  de-duplicates and drops non-tab (`NSNull`) entries — a repeated item previously crashed
  `super addTabViewItem:` and corrupted the index bookkeeping — and now reports a selection
  change once (via `tabView:didSelectTabViewItem:`) when the wholesale replace moves the
  selection.

- **Selection is now reported when hiding the selected tab.** Hiding the selected tab moves
  the selection to a remaining visible tab; the delegate now receives
  `tabView:didSelectTabViewItem:` once for the new selection (previously the selection change
  was silently swallowed because the delegate is suppressed during the structural hide).
  **Impact:** delegates relying on selection callbacks now behave like plain NSTabView.

- **`hiddenTabView` is now a true zeroing-weak reference.** It was stored with
  `OBJC_ASSOCIATION_ASSIGN`, which left a dangling pointer (use-after-free risk in
  `setHidden:`) if the tab view deallocated while an item outlived it. It now uses a retained
  wrapper holding a `__weak` pointer, so it auto-nils on dealloc with no retain cycle.

- **`initWithCoder:` added for Interface Builder.** BETabView is IB-instantiable; the new
  override reconciles `allTabViewItems` with the decoded visible tabs so the view is correctly
  set up regardless of `awakeFromNib` timing. Note: per-item hidden state lives in associated
  objects and is not archived (documented). The init reconciliation is idempotent.

### AppKit — BEWindowController

- **Reparenting corruption fixed.** Setting `parentController` from parent A to parent B now
  detaches from A before attaching to B, so the child ends up in exactly one parent's
  `childControllers`. Previously the child lingered in BOTH sets — strong-retained by two
  parents (a leak) with a stale back-reference. **Impact:** `child.parentController = B` is now
  safe when the child already had a parent.

- **Infinite-recursion fix when a document has two primary controllers.** Two controllers
  both flagged `isPrimaryWindowController` in the same document recursed forever
  (`A.close → closes B → B.close → closes A → …`, because `[super close]` — which removes the
  controller from the document's array — was never reached). A re-entrancy guard now makes a
  re-entrant `close` a no-op. **Impact:** closing one of several primaries no longer
  stack-overflows.

- **`addChildWindowController:nil` no longer crashes** (it raised via `NSMutableSet addObject:nil`).
- **`+supportsSecureCoding` added** (returns YES; the class now declares `NSSecureCoding`),
  and `isPrimaryWindowController` is now `nonatomic`.
- Documentation corrected: the `containsChildWindowController:` abstract (was a copy-paste
  "Adds…"), the reparenting semantics, that `close` does not auto-close children (the manager
  does), and the main-thread requirement.

### AppKit — BEWindowControllerManager

- **Now a real singleton.** Added `+sharedManager` (class property `sharedManager`,
  `dispatch_once`) — the documented "application singleton" previously had no shared accessor,
  so every instance independently observed (and acted on) all app-wide window notifications.
  `-init` remains available for isolated/test instances. **Impact:** use
  `BEWindowControllerManager.sharedManager` for the app-wide instance.

- **Cascade-close is robust.** `windowWillClose:` now ignores windows it doesn't track, uses a
  visited set (idempotent; immune to cyclic parent graphs), and removes the closing controller
  and all descendants from tracking up front — so a controller whose `-close` is overridden to
  defer is no longer leaked by the tracking array.

- **Fast-enumeration iteration contract documented.** Iterating the manager directly
  (`for (wc in manager)`) follows standard `NSMutableArray` semantics — mutating the manager
  during that loop raises "mutated while being enumerated". The header now directs callers who
  need to mutate while iterating to use the `windowControllers` snapshot
  (`for (wc in manager.windowControllers)`). (A per-call snapshot inside the enumerator was
  considered and rejected: fast enumeration vends `__unsafe_unretained` pointers, so an
  autoreleased snapshot could outlive-fail under the caller's loop.)
- **Consistent locking** across all reads (lookups, subscript, enumeration), the dead
  `idx < 0` unsigned check removed, and `firstWindowControllerOfKind:` /
  `windowControllersOfKind:` parameters made `nullable` to match their nil-tolerant behavior.

### AppKit — BEPathControl

- **`containsURL:` containment is now exact at directory boundaries (behavior change).**
  Comparison switched from a raw `absoluteString` prefix test (with a trailing-slash hack) to
  standardized **path-component** comparison. **Impact:** a root of `/a/Projects` no longer
  matches the sibling `/a/ProjectsX`; files are no longer treated as directories; percent-encoding
  differences are normalized; schemes must match. Code that (incorrectly) relied on the old
  prefix false-positives will see those URLs now excluded.
- **`containsURL:` parameter is now `nullable`** (it always handled nil), and the documentation
  no longer claims symlink resolution (`standardizedURL` does not resolve symlinks).

### AppKit — NSOpenPanel (BESecurityScopedURLManager)

- **Bookmark-creation failures are no longer silently swallowed.** The `NSModalResponseOK`
  logic moved into a new public seam, `-ss_addURLsToCatalog:`, which returns the URLs that could
  not be bookmarked; `ss_beginWithCompletionHandler:` logs partial failures. **Impact:** you can
  now call `ss_addURLsToCatalog:` directly (and unit-test it) and detect failures.
- **Nullability made honest:** `ss_beginWithCompletionHandler:`'s handler,
  `ss_openPanelWithManager:`'s manager, and `ss_presetDirectoryAtURL:`'s url are now `nullable`,
  matching the implementations (removing the need for callers to suppress `-Wnonnull`). The
  completion handler also captures `self` weakly.

### BEFileCache

- **Memory and disk tiers are now updated atomically — the "safe from any thread" claim is
  now actually true.** Previously `objectForKey:` snapshotted the disk path on the serial
  queue, released it, then re-warmed `NSCache` off-queue — a TOCTOU against `trim`/`remove`
  that could leave a stale object in memory after it had been evicted from disk, and
  concurrent same-key writes could leave the two tiers holding different values. Now every
  memory mutation happens inside the same disk-queue critical section as the corresponding
  disk mutation (`setObject:`, `removeObjectForKey:`, `removeAllObjects:`), and the
  `objectForKey:` re-warm re-validates the entry still exists on disk before repopulating
  memory. **Impact:** concurrent access no longer diverges the tiers; added a concurrency
  stress test.

- **The cache survives a cache-directory relocation.** The persisted index stored *absolute*
  `.cache`/`.meta` paths; if the cache directory moved (e.g. an app-container path change),
  the index loaded, every absolute path failed the existence check, and the whole cache was
  silently discarded (the `.meta`-scan fallback did not run for a successfully-unarchived but
  stale index). The index now stores base filenames and recomposes them against the current
  directory on load (legacy absolute-path indexes are normalized via `lastPathComponent`).
  **Impact:** a relocated cache resolves instead of being lost.

- **Delegate re-entrancy contract documented.** Eviction callbacks
  (`cache:willEvictObject:` / `cache:willEvictObjectFromMemory:`) are delivered while the
  serial queue is held and may run on an internal queue; the header now states that a
  delegate must not synchronously call back into the same cache (which would deadlock) — this
  matches the pre-existing behavior of `trimDiskOnQueue`.

- Minor: the index-file write error is now logged instead of silently ignored; the
  previously-placeholder discardable `beginContentAccess == NO` disk-hit test now actually
  exercises that branch (the test fixture round-trips the access flag). Added tests for
  adversarial/path-like and non-string keys (SHA-256 filenames stay flat and safe) and for
  corrupt `.cache` payload recovery.

### BEMetalHelper

- **`imageFromTexture:` memory-safety hardening.** In the grayscale (R8/R16F/R32F) paths the
  `malloc` results were unchecked and the `convertGray…` return value was ignored, so an
  allocation or conversion failure fed a NULL/garbage buffer into `CGBitmapContextCreate`
  (potential heap corruption), and the color space could leak on a failed path. All
  allocations and conversion results are now checked, with full cleanup (free both buffers,
  release the color space) and a `nil` return on any failure. Multiplication sizes
  (`bytesPerPixel * width`, `height * rowBytes`, and the 16F temp buffer) are now
  overflow-guarded, and zero-dimension textures return `nil` rather than `malloc(0)`. No
  change on valid inputs. **Impact:** robust failure handling instead of undefined behavior.

- **Documented two behavioral caveats** (not changed, to avoid regressing existing callers):
  `getBytes:` requires a CPU-readable (`Shared`/`Managed`) texture and completed GPU work —
  a `Private` render-target must be blitted first; and the result is interpreted in
  `kCGColorSpaceGenericRGBLinear`, which will look wrong for sRGB/gamma-encoded `*Unorm`
  content. Also changed `<= 0` to `== 0` on `size_t` parameters (tautological-compare).

### BEMutable

- **Recursive copying now terminates on cyclic and self-referential graphs.** The eight
  recursive copy methods (`copyRecursive` / `copyCollectionRecursive` /
  `mutableCopyRecursive` / `mutableCopyCollectionRecursive` on
  `NSSet`/`NSOrderedSet`/`NSArray`/`NSDictionary`) recursed unconditionally into every
  nested collection, so a container reachable from itself (`a` contains `a`, or
  `a→b→a`) recursed until the stack overflowed and crashed. Each method now threads a
  `visited` set of non-retained pointer identities (path-based: added before recursing,
  removed after), and breaks a cycle by referencing the already-visited node instead of
  recursing into it. **Impact:** cyclic object graphs copy safely; added regression tests
  for self-referential arrays/dictionaries and mutually-referential arrays.

- **Removed a dead no-op branch** in `NSSet`'s recursive copy (a `BEMutableCharacterSet`
  check that assigned the object to itself) and an undefined-macro `#if` guard
  (`kExcludeImmutableClassesWithMutableImplementation`, never defined) on `NSString`'s
  instance-level `isMutable`, corrected to the defined
  `kIncludeImmutableClassesWithMutableImplementation` to match the header (both default to
  `NO`; no behavior change).

- **Documentation corrected.** `copyRecursive`'s "completely immutable" claim overstated
  the guarantee — objects that do not conform to `NSCopying` are shared by reference, and
  cycles are broken by referencing the original node. The doc now states the precise
  contract.

- **Flaky set correctness tests stabilized.** `testNSSet_copyRecursive_Correctness`,
  `testNSMutableSet_copyRecursive_Correctness`, and their `mutableCopyRecursive` variants
  asserted per-element results via `-[NSSet member:]`. The collection fixtures hash by
  element count, so several distinct elements share a hash bucket; under an unlucky heap
  layout `member:` probed a non-equal bucket occupant and returned `nil`, failing only
  under full-suite execution (heap/ASLR dependent). The lookup is now a deterministic
  linear scan (`-memberOf:equalTo:`) — the fixtures contain no two mutually-equal elements,
  so exactly one member matches and the result is stable across runs. **Impact:** the four
  tests pass deterministically; not a product bug (the copy methods were always correct).

### Polish pass (post-audit)

- **Copyright lines normalized framework-wide.** 13 whitespace/wording variants collapsed to the
  canonical `-© 2025 Delicense - @belisoful. All rights released.` (81 lines; each file keeps its
  own indentation style). Three files still said "All rights reserved" (BEMutable.h,
  CIImage+BExtension.h, BEStackExtensions.h) — corrected to "released". NSMutableNumber's
  third-party MIT header was deliberately left untouched.

- **`kCharSetDifferentiable` single-sourced.** It was defined identically in both
  `BECharacterSet.h` and `BEMutable.h`; the unused `BECharacterSet.h` copy was removed.
  `BEMutable.h` — the only consumer — now owns the definition.

- **BECharacterSet class-cluster rationale rewritten** in both the `.h` and `.m` headers (the prior
  phrasing — "both contain the NSCharacterSet and NSMutableCharacterSet as a subclass" — was
  garbled); it now states plainly that Foundation's class cluster backs both classes with the same
  concrete subclass.

- **Removed a dangling empty `@discussion` tag** in `BEPredicateRule.h`.

- **Verification:** clean build with zero compiler warnings; full suite 1824 passed, 0 failed,
  2 skipped (the pre-existing entitlement-dependent BESecurityScopedURLManager skips).

### BEFoundation.docc (update + polish)

- **Update:** new pages for NSObject+Macroable and the priority-notification cluster (neither was
  documented); fixed examples that called nonexistent initializers (BECharacterSet pages) and a
  wrong arithmetic result (integer division shown as 3.333…); documented the audited APIs
  (`floatToFpXX`, `BE_APPLE_TERMS_COMPLIANT`, the DynamicMethods thread-safety contract, the
  nil-on-missing-file and compare contracts); wired RFC 2822 and the new pages into the landing
  page, Index, and topic groups.

- **Polish: 286 DocC warnings → 0.** The catalog used `## Topics` as a prose heading (DocC treats
  it as symbol curation, so every description and code block under it warned) — content sections
  renamed to `## Usage`; the 15 articles whose names collide with their class/protocol were
  converted to documentation extensions (`# ``Symbol``` H1), merging their guides onto the symbol
  pages; the root page's curation groups were reduced to bare `<doc:>` links per DocC rules
  (rendered docs pull each page's abstract automatically) and a leftover duplicate AppKit group was
  removed; fixed a self-curation cycle in BERuntime.md, two symbol-style links to article pages in
  the RFC 2822 page, underscore-vs-hyphen category links in BETabView.md, and non-link Apple-class
  items in `## See Also` groups. Validated with `xcodebuild docbuild`: BUILD SUCCEEDED, 0 warnings,
  0 errors.

### Compiler warnings

- **Framework target:** fixed `-Wenum-enum-conversion` in `BEMetalHelper.m` (mixing
  `CGImageAlphaInfo` and `CGBitmapInfo` in bitwise-OR), and `-Wnullability-completeness` on a
  `SEL` parameter in `NSObject+Macroable.h`.
- **Test target:** cleared all remaining compiler warnings (unused variables, nil-to-nonnull
  arguments, non-literal format strings, undeclared selectors, an abstract-class designated
  initializer, a deprecated `-getBytes:`, an incompatible pointer assignment, and
  variable-length-array folding) via `__unused`, typed nil locals, or localized
  `#pragma clang diagnostic` suppression where the construct was intentional.

---

## 1.0

Initial release.
