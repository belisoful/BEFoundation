#!/bin/zsh
# check-category-collisions.sh — fails when a BEFoundation category defines a selector that
# already exists on the target Apple class in a clean process.
#
#   A category method unconditionally displaces the class's own method, and two categories
#   defining the same selector resolve in undefined load order. Apple attaches private
#   categories to Foundation classes at runtime (OSAnalytics defines -[NSMutableArray push:],
#   PencilKit defines +[NSImage imageWithCGImage:]), so any BE category selector that
#   pre-exists on the class is a latent undefined-winner bug. The fix is a BE-owned rename
#   (see CATEGORY_NAMING.md).
#
# Usage:  Scripts/check-category-collisions.sh <path/to/BEFoundation.framework>
#
# Exits 0 when no category selector pre-exists on its Apple class; prints each collision
# and exits 1 otherwise.

set -e
set -u

FRAMEWORK="${1:?usage: check-category-collisions.sh <BEFoundation.framework>}"
BINARY="$FRAMEWORK/BEFoundation"
[ -f "$BINARY" ] || BINARY="$FRAMEWORK/Versions/A/BEFoundation"
[ -f "$BINARY" ] || { echo "error: no binary in $FRAMEWORK" >&2; exit 1; }

WORK="$(mktemp -d /tmp/be-collision-check.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

# ── 1. Extract (kind, class, selector) for every category method in the binary ──────────
# Within the __objc_catlist section, every implemented category method has an imp line:
#     imp 0x... (0x...) -[NSDictionary(BExtension) copyRecursive]
# Protocol method lists carry no imp lines, so this extraction cannot pick them up. The
# clean-process probe below skips classes that do not exist without BEFoundation loaded,
# which filters the list to categories on Apple/system classes.
otool -oV "$BINARY" | awk '
	/Contents of \(__DATA[A-Z_]*,__objc_catlist\) section/ { incat = 1; next }
	incat && /^Contents of / { incat = 0 }
	incat && /imp / && match($0, /[+-]\[[A-Za-z_][A-Za-z0-9_]*\([A-Za-z0-9_|]+\) [^ \]]+\]/) {
		s = substr($0, RSTART, RLENGTH)
		kind = substr(s, 1, 1)
		cls = s; sub(/^[+-]\[/, "", cls); sub(/\(.*/, "", cls)
		sel = s; sub(/^[^ ]+ /, "", sel); sub(/\]$/, "", sel)
		# +load is exempt: the runtime invokes every category'\''s +load independently
		# rather than resolving one winner, so it can never collide.
		if (kind == "+" && sel == "load") { next }
		print kind "\t" cls "\t" sel
	}
' | sort -u > "$WORK/selectors.tsv"

COUNT=$(wc -l < "$WORK/selectors.tsv" | tr -d ' ')
[ "$COUNT" -gt 0 ] || { echo "error: extracted no category selectors — otool format change?" >&2; exit 1; }
echo "extracted $COUNT category selectors on external classes"

# ── 2. Clean-process probe: does each selector already exist before BEFoundation loads? ──
cat > "$WORK/probe.m" <<'EOF'
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>
int main(int argc, char **argv) {
	// Load Apple frameworks known to attach private categories lazily, so the probe also
	// sees selectors that only exist once a host application pulls these in.
	dlopen("/System/Library/Frameworks/PencilKit.framework/PencilKit", RTLD_NOW);
	dlopen("/System/Library/PrivateFrameworks/ScreenReaderCore.framework/ScreenReaderCore", RTLD_NOW);
	// argv[1]: tsv of "<kind>\t<class>\t<selector>" lines. Prints colliding lines.
	NSString *tsv = [NSString stringWithContentsOfFile:@(argv[1]) encoding:NSUTF8StringEncoding error:NULL];
	int collisions = 0;
	for (NSString *line in [tsv componentsSeparatedByString:@"\n"]) {
		NSArray *f = [line componentsSeparatedByString:@"\t"];
		if (f.count != 3) { continue; }
		Class cls = NSClassFromString(f[1]);
		if (!cls) { continue; }   // class not present on this platform/process
		SEL sel = NSSelectorFromString(f[2]);
		Method m = [f[0] isEqualToString:@"+"]
			? class_getClassMethod(cls, sel)
			: class_getInstanceMethod(cls, sel);
		if (m) {
			printf("COLLISION: %s[%s %s] already exists in a clean process\n",
				   [f[0] UTF8String], [f[1] UTF8String], [f[2] UTF8String]);
			collisions++;
		}
	}
	return collisions ? 1 : 0;
}
EOF
clang -fobjc-arc -framework Foundation -framework AppKit "$WORK/probe.m" -o "$WORK/probe"

if "$WORK/probe" "$WORK/selectors.tsv"; then
	echo "OK: no BEFoundation category selector pre-exists on its Apple class"
else
	echo "FAIL: the selectors above collide with pre-existing Apple implementations." >&2
	echo "      Rename them to BE-owned selectors (see CATEGORY_NAMING.md)." >&2
	exit 1
fi
