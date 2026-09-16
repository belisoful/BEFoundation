#!/bin/bash
#
# check-deployment-target.sh
#
# Fails when a built BEFoundation binary's minimum OS version differs from the deployment target
# that BEFoundation.podspec declares.
#
# THE ISSUE
#   Each Xcode release raises the lowest deployment target it accepts. Xcode 27 rejects macOS 11.0
#   and iOS 14.0. A build that overrides MACOSX_DEPLOYMENT_TARGET or IPHONEOS_DEPLOYMENT_TARGET to
#   get past that succeeds, and its binary requires a newer OS than the release declares. Nothing
#   in the build output reports the change.
#
# THE CHECK
#   `vtool -show-build` reads the LC_BUILD_VERSION of every architecture. The MACOS platform is
#   compared with `s.osx.deployment_target`; IOS and IOSSIMULATOR with `s.ios.deployment_target`.
#   Any other platform, or a binary without LC_BUILD_VERSION, is an error.
#
#   BE_ALLOW_DEPLOYMENT_TARGET_MISMATCH=1 reports a mismatch without failing. It is for builds that
#   are not published as a release, such as a vendored copy for an app with a newer minimum OS.
#
# Usage:  Scripts/check-deployment-target.sh <BEFoundation.framework>...
#
set -euo pipefail

[ $# -ge 1 ] || { echo "usage: check-deployment-target.sh <BEFoundation.framework>..." >&2; exit 2; }

PODSPEC="$(cd "$(dirname "$0")/.." && pwd)/BEFoundation.podspec"

podspec_target() { # <osx|ios>
	sed -nE "s/^[[:space:]]*s\.$1\.deployment_target[[:space:]]*=[[:space:]]*[\"']([0-9.]+)[\"'].*/\1/p" "$PODSPEC"
}

normalized_version() { # <version>  "12" and "12.0" both become "12.0.0"
	echo "$1" | awk -F. '{ printf "%d.%d.%d", $1, $2, $3 }'
}

MACOS_TARGET="$(podspec_target osx)"
IOS_TARGET="$(podspec_target ios)"
if [ -z "$MACOS_TARGET" ] || [ -z "$IOS_TARGET" ]; then
	echo "error: no osx/ios deployment_target in $PODSPEC" >&2
	exit 1
fi

MISMATCHES=0
for FRAMEWORK in "$@"; do
	BINARY="$FRAMEWORK/BEFoundation"
	if [ ! -f "$BINARY" ]; then
		echo "error: no binary in $FRAMEWORK" >&2
		exit 1
	fi

	# One "<arch> <platform> <minos>" line per LC_BUILD_VERSION. A thin binary's header line
	# carries no "(architecture ...)" suffix.
	RECORDS="$(xcrun vtool -show-build "$BINARY" | awk '
		/^[^ ].*:$/ {
			arch = "single"
			if (match($0, /\(architecture [^)]+\)/)) {
				arch = substr($0, RSTART + 14, RLENGTH - 15)
			}
		}
		$1 == "platform" { platform = $2 }
		$1 == "minos"    { print arch, platform, $2 }
	')"
	if [ -z "$RECORDS" ]; then
		echo "error: no LC_BUILD_VERSION in $BINARY" >&2
		exit 1
	fi

	while read -r ARCH PLATFORM MINOS; do
		case "$PLATFORM" in
			MACOS)            EXPECTED="$MACOS_TARGET" ;;
			IOS|IOSSIMULATOR) EXPECTED="$IOS_TARGET" ;;
			*)
				echo "error: unexpected platform $PLATFORM in $BINARY ($ARCH)" >&2
				exit 1
				;;
		esac
		if [ "$(normalized_version "$MINOS")" != "$(normalized_version "$EXPECTED")" ]; then
			echo "MISMATCH: $FRAMEWORK ($PLATFORM $ARCH) has minos $MINOS; BEFoundation.podspec declares $EXPECTED"
			MISMATCHES=$((MISMATCHES + 1))
		fi
	done <<< "$RECORDS"
done

if [ "$MISMATCHES" -gt 0 ]; then
	if [ "${BE_ALLOW_DEPLOYMENT_TARGET_MISMATCH:-0}" = "1" ]; then
		echo "warning: $MISMATCHES deployment-target mismatch(es) allowed by BE_ALLOW_DEPLOYMENT_TARGET_MISMATCH=1; do not publish this build"
		exit 0
	fi
	echo "error: build with an Xcode that accepts the podspec's deployment targets (macOS $MACOS_TARGET, iOS $IOS_TARGET)" >&2
	exit 1
fi

echo "OK: minimum OS versions match BEFoundation.podspec (macOS $MACOS_TARGET, iOS $IOS_TARGET)"
