#!/usr/bin/env python3
#
# generate-docc-dark-svgs.py
#
# Generates the `name~dark.svg` variants in the DocC catalog from their light `name.svg`
# source. DocC auto-swaps to a `~dark` asset in dark appearance, so each hand-authored light
# diagram needs a dark counterpart. Re-run this after editing or adding any light SVG.
#
# The recolor is tag-aware because one hex value can mean different things by element: e.g.
# `#1D1D1F` is a dark pill *fill* on a <rect> (becomes a visible grey on dark) but *text* on a
# <text> (becomes light). GLOBAL substitutions run first so the tag-aware outputs below are
# never re-mapped.
#
# Usage:  Scripts/generate-docc-dark-svgs.py [Source/BEFoundation.docc/Resources]
#         (defaults to the current directory)
#
import sys, os, re

# Colors that map the same regardless of element.
GLOBAL = {
    '#FCFCFE': '#131316',   # card background
    '#D2D2D7': '#3A3A3C',   # card stroke
    '#6E6E73': '#98989D',   # subtitle / arrow stroke / marker
    '#C7C7CC': '#48484A',   # neutral box stroke
    # accent box tints (light -> dark)
    '#E9F1FF': '#0A2A4D', '#E8F8EE': '#11371F', '#FFF4E5': '#3A2A0A',
    '#EFEAFB': '#2A1F40', '#F3ECFB': '#2A1F40', '#F0F0F2': '#232327',
    # accent text (dark -> light)
    '#0A5FCC': '#6FB6FF', '#137A37': '#5DD27A', '#B5710A': '#FFBF5A',
    '#8A2BE2': '#D29BFF', '#C7261C': '#FF8A80',
}
# These read fine on both themes; leave untouched: #0A84FF #34C759 #FF9F0A
# #BF5AF2 #FF453A #8E8E93 #5E5CE6 #E5E5EA and url(#...) gradients.


def tag_of(line):
    m = re.search(r'<(\w+)', line)
    return m.group(1) if m else ''


def convert(text):
    out = []
    for line in text.splitlines():
        tag = tag_of(line)
        # GLOBAL first, so tag-aware outputs below are never re-mapped.
        for a, b in GLOBAL.items():
            line = line.replace(a, b)
        # tag-aware: #1D1D1F is a dark pill fill on rect, otherwise text/marker.
        if tag in ('rect',):
            line = line.replace('#1D1D1F', '#48484A')      # pill -> visible grey on dark
            line = line.replace('#FFFFFF', '#232327')      # white box -> dark box
        elif tag in ('text',):
            line = line.replace('#1D1D1F', '#F5F5F7')      # title/box text -> light
            line = line.replace('#48484A', '#C7C7CC')      # grey text -> light grey
            # white text stays white (sits on coloured badges / grey pills)
        elif tag in ('path', 'line', 'polygon'):
            line = line.replace('#1D1D1F', '#F5F5F7')      # pointers / ticks -> light
        out.append(line)
    return '\n'.join(out) + ('\n' if text.endswith('\n') else '')


def main(d):
    for f in sorted(os.listdir(d)):
        if not f.endswith('.svg') or f.endswith('~dark.svg'):
            continue
        src = os.path.join(d, f)
        dst = os.path.join(d, f[:-4] + '~dark.svg')
        with open(src) as fh:
            converted = convert(fh.read())
        with open(dst, 'w') as fh:
            fh.write(converted)
        print('wrote', os.path.basename(dst))


main(sys.argv[1] if len(sys.argv) > 1 else '.')
