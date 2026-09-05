#!/bin/bash
#
# build-xcframework.sh
#
# Builds BEFoundation.xcframework (macOS + iOS device + iOS simulator) and packages it as a
# signature-safe BEFoundation.xcframework.zip in <output-dir>.
#
# WHY AN XCFRAMEWORK
#   A single .framework holds one platform only (iOS and macOS Mach-O binaries carry different
#   platform load commands and use different bundle layouts). The .xcframework is the one binary
#   format that ships macOS + iOS together and lets a consumer drop in a single artifact.
#
# SIGNING
#   Release archives ad-hoc-sign the macOS and simulator slices but leave the iOS-device slice
#   unsigned, and `codesign` on the .xcframework wrapper does not recurse into the slices. So each
#   contained framework is ad-hoc-signed individually, matching the plain .framework release zips.
#
# PACKAGING
#   The macOS slice carries symlinks (`Versions/Current -> A`, the top-level stub) sealed by the
#   signature. A `ditto -c -k` zip breaks under Info-ZIP `unzip`; `zip -y -r -X` stays valid under
#   both `unzip` and `ditto`/Finder. Build-provenance xattrs are stripped first. See
#   Scripts/package-release-zip.sh for the same issue on the plain frameworks.
#
# Usage:  Scripts/build-xcframework.sh <output-dir>
#
set -euo pipefail

OUT="${1:?usage: build-xcframework.sh <output-dir>}"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"

PROJECT="BEFoundation.xcodeproj"
SCHEME="BEFoundation"
XCF="$OUT/BEFoundation.xcframework"
ZIP="$OUT/BEFoundation.xcframework.zip"

WORK="$(mktemp -d)"
VERIFY=""
trap 'rm -rf "$WORK" "$VERIFY"' EXIT

# BUILD_LIBRARY_FOR_DISTRIBUTION=YES emits a stable module; SKIP_INSTALL=NO keeps the framework in
# the archive's Products; unsigned slices are re-signed ad-hoc below. CLANG_COVERAGE_MAPPING=NO
# is required for the PGO profile to apply: the shared scheme enables code coverage, which sets
# CLANG_COVERAGE_MAPPING=YES on scheme-driven builds, and Clang.xcspec drops
# -fprofile-instr-use whenever coverage mapping is on.
BUILD_SETTINGS="SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES CODE_SIGNING_ALLOWED=NO CLANG_COVERAGE_MAPPING=NO"

archive() { # <name> <destination>
	echo ">>> archiving $1 ($2)"
	# shellcheck disable=SC2086
	xcodebuild archive -project "$PROJECT" -scheme "$SCHEME" \
		-destination "$2" -archivePath "$WORK/$1" $BUILD_SETTINGS \
		>"$WORK/$1.log" 2>&1 || { echo "archive failed ($1):"; tail -40 "$WORK/$1.log"; exit 1; }
}

archive macos  'generic/platform=macOS'
archive ios    'generic/platform=iOS'
archive iossim 'generic/platform=iOS Simulator'

echo ">>> creating xcframework"
rm -rf "$XCF"
xcodebuild -create-xcframework \
	-framework "$WORK/macos.xcarchive/Products/Library/Frameworks/BEFoundation.framework" \
	-framework "$WORK/ios.xcarchive/Products/Library/Frameworks/BEFoundation.framework" \
	-framework "$WORK/iossim.xcarchive/Products/Library/Frameworks/BEFoundation.framework" \
	-output "$XCF" >"$WORK/create.log" 2>&1 || { echo "create-xcframework failed:"; tail -40 "$WORK/create.log"; exit 1; }

echo ">>> ad-hoc signing each slice"
for fw in "$XCF"/*/BEFoundation.framework; do
	[ -d "$fw" ] || continue
	xattr -cr "$fw"
	codesign --force --sign - "$fw"
	codesign --verify --deep --strict "$fw"
done

echo ">>> packaging (Info-ZIP, symlink-preserving)"
xattr -cr "$XCF"
rm -f "$ZIP"
( cd "$OUT" && zip -y -r -X -q "$(basename "$ZIP")" "$(basename "$XCF")" )

echo ">>> verifying the zip survives a plain unzip round-trip"
VERIFY="$(mktemp -d)"
( cd "$VERIFY" && unzip -q "$ZIP" )
for fw in "$VERIFY/BEFoundation.xcframework"/*/BEFoundation.framework; do
	[ -d "$fw" ] || continue
	codesign --verify --deep --strict "$fw"
done

SLICES="$(cd "$XCF" && ls -d */ | tr -d '/' | tr '\n' ' ')"

# The .xcframework itself is an intermediate: the zip is the deliverable, and the release
# folders carry the zip alone. Leaving it behind would put 166 loose binary files next to
# the artifact that already contains them.
rm -rf "$XCF"

echo "OK: $ZIP"
echo "    slices: $SLICES"
