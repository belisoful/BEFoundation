#!/bin/bash
#
# package-release-zip.sh
#
# Packages a built BEFoundation.framework into a release .framework.zip that stays
# code-signature-valid no matter how the recipient extracts it (Finder, `ditto`, or `unzip`).
#
# THE ISSUE
#   A macOS framework bundle contains symlinks — `Versions/Current -> A` and the top-level
#   stub `BEFoundation -> Versions/Current/BEFoundation` — and the ad-hoc code signature seals
#   them. A zip made with `ditto -c -k` round-trips correctly under `ditto -x`, but NOT under
#   Info-ZIP `unzip`: unzip mis-restores those symlinks, so `codesign --verify` then fails with
#   "a sealed resource is missing or invalid". Fresh Xcode builds also carry `com.apple.*`
#   provenance extended attributes that `unzip` drops, compounding the broken seal.
#
# THE SOLUTION
#   1. Strip extended attributes so the seal cannot depend on them.
#   2. Re-sign ad-hoc.
#   3. Archive with Info-ZIP `zip -y -r -X` (`-y` preserves symlinks, `-X` omits extra
#      attributes). Info-ZIP archives are symmetric with `unzip` AND extract correctly with
#      `ditto`/Finder, so the signature survives every extraction path.
#   The script then proves it by extracting the archive with plain `unzip` and running
#   `codesign --verify --deep --strict`.
#
# Usage:  Scripts/package-release-zip.sh <path/to/BEFoundation.framework> <path/to/output.zip>
#
set -euo pipefail

FRAMEWORK="${1:?usage: package-release-zip.sh <BEFoundation.framework> <output.zip>}"
OUTPUT="${2:?usage: package-release-zip.sh <BEFoundation.framework> <output.zip>}"

[ -d "$FRAMEWORK" ] || { echo "error: not a framework directory: $FRAMEWORK" >&2; exit 1; }

FW_DIR="$(cd "$(dirname "$FRAMEWORK")" && pwd)"
FW_NAME="$(basename "$FRAMEWORK")"
case "$OUTPUT" in
	/*) ABS_OUTPUT="$OUTPUT" ;;
	*)  ABS_OUTPUT="$(pwd)/$OUTPUT" ;;
esac

# 1 + 2: drop build-provenance xattrs, then re-seal ad-hoc without them.
xattr -cr "$FRAMEWORK"
codesign --force --deep --sign - "$FRAMEWORK"
codesign --verify --deep --strict "$FRAMEWORK"

# 3: Info-ZIP, preserving symlinks; overwrite any prior archive (zip appends otherwise).
rm -f "$ABS_OUTPUT"
( cd "$FW_DIR" && zip -y -r -X -q "$ABS_OUTPUT" "$FW_NAME" )

# Verify the seal survives a plain `unzip` round-trip.
VERIFY_DIR="$(mktemp -d)"
trap 'rm -rf "$VERIFY_DIR"' EXIT
( cd "$VERIFY_DIR" && unzip -q "$ABS_OUTPUT" )
codesign --verify --deep --strict "$VERIFY_DIR/$FW_NAME"

echo "OK: $ABS_OUTPUT — signature valid after plain unzip"
