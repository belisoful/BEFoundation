#!/bin/bash
#
# run-noncompliant-tests.sh
#
# Builds and runs the BlockSignatures tests with BE_APPLE_TERMS_COMPLIANT=0, i.e. the *opt-out*
# configuration that uses the non-public _Block_signature runtime function for block-signature
# extraction (with the hand-rolled reader as a weak-import fallback).
#
# The default test scheme builds with BE_APPLE_TERMS_COMPLIANT=1 (compliant, no private symbols),
# so this path is otherwise never exercised at runtime. This run compiles in the guarded test
# `testBlockSignature_NonCompliantRuntimePath` and verifies the runtime extractor produces correct
# signatures.
#
# NOTE: A binary built this way references a non-public Apple symbol and MUST NOT be shipped to the
# App Store. This is for development verification only.
#
# Usage:  Scripts/run-noncompliant-tests.sh
#
set -euo pipefail

cd "$(dirname "$0")/.."

DERIVED="/tmp/befoundation-noncompliant-dd"
rm -rf "$DERIVED"

echo "Building + testing with BE_APPLE_TERMS_COMPLIANT=0 ..."
# Run BOTH the BlockSignatures suite and its real consumer — the NSObject+DynamicMethods system —
# because dynamic method dispatch is the actual use case for the block-signature machinery: a wrong
# signature here corrupts the byte-for-byte argument copying in -mutateInvocation:withMeta:.
xcodebuild \
    -project BEFoundation.xcodeproj \
    -scheme BEFoundation \
    -configuration Debug \
    -derivedDataPath "$DERIVED" \
    -only-testing:BEFoundationTests/NSMethodSignatureBlockSignaturesTests \
    -only-testing:BEFoundationTests/NSDynamicMethodsTests \
    -only-testing:BEFoundationTests/NSDynamicMethodsHelpersTests \
    -only-testing:BEFoundationTests/NSDynamicMethodsInstanceProtocolTests \
    -only-testing:BEFoundationTests/NSDynamicMethodsObjectProtocolTests \
    GCC_PREPROCESSOR_DEFINITIONS='$(inherited) DEBUG=1 BE_APPLE_TERMS_COMPLIANT=0' \
    test 2>&1 | tee /tmp/befoundation-noncompliant.log | grep -E "Test [Cc]ase.*(passed|failed)|\*\* TEST|warning:|error:" | grep -v "ld:" || true

echo
echo "=== Result ==="
if grep -q "\*\* TEST SUCCEEDED \*\*" /tmp/befoundation-noncompliant.log; then
    echo "TEST SUCCEEDED (BE_APPLE_TERMS_COMPLIANT=0)"
else
    echo "TEST FAILED — see /tmp/befoundation-noncompliant.log"
    exit 1
fi

echo
echo "=== Compliance check: this opt-out binary DOES reference the non-public symbol ==="
FW=$(find "$DERIVED" -name "BEFoundation" -path "*BEFoundation.framework/*" -type f 2>/dev/null | head -1)
if [ -n "$FW" ]; then
    nm -mu "$FW" 2>/dev/null | grep -i "_Block_signature" || echo "(symbol not found in framework binary)"
fi
echo "(The DEFAULT compliant build references no such symbol — this opt-out build is for dev only.)"
