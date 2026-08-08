/*!
 @file       BEDotView.m
 @copyright  © 2025 Delicense - @belisoful. All rights reserved.
 @date       2025-11-11
 @author     belisoful@icloud.com
 @abstract   A cross-platform Core Graphics port of Prado's TDot.
 @discussion The color presets, the shade cascade that derives main/highlight from a
			 single hex color, and the tuning constants are ported to match TDot's
			 output exactly; the SVG document becomes Core Graphics radial-gradient
			 drawing. Colors are built through @c BEColor so the same code serves
			 @c NSColor (macOS) and @c UIColor (iOS/tvOS); the coordinate system is
			 top-left y-down on every platform. The SVG dot was created by @belisoful
			 and released to the public domain (CC0); this port carries that provenance.
 */

#import "BEDotView.h"
#import "BEColor+BExtension.h"
#import "BEColor+BEWebColor.h"
#import "BE_ARC.h"
#import <Accelerate/Accelerate.h>

// Tuning constants, fit to the preset table in TDot. See TDot.php for the derivation.
static const double kBEDotDefaultDepth      = 24.0;
static const double kBEDotNudgeExponent     = 5.819;
static const double kBEDotMainDepthScale    = 0.9633;
static const double kBEDotHSLDepthFraction  = 0.2312;
static const double kBEDotHSLChromaMod      = 0.2157;
static const double kBEDotRGBSatMod         = -0.2100;

#pragma mark - Ported color math

/*! One channel nudged toward an extreme, unrounded. styleTop exaggerates the top of
	the 0..255 range, otherwise the bottom (TDot nudgeRaw with an explicit style). */
static double BEDotNudgeRaw(double v, double n, BOOL styleTop)
{
	double u = 2.0 * (v / 255.0 - 0.5);
	double sign = (u < 0.0) ? -1.0 : 1.0;
	double f = styleTop ? (1.0 + sign * pow(fabs(u), kBEDotNudgeExponent))
	                    : (1.0 - sign * pow(fabs(u), kBEDotNudgeExponent));
	return v + n * f;
}

static int BEDotNudge(double v, double n, BOOL styleTop)
{
	long r = lround(BEDotNudgeRaw(v, n, styleTop));
	return (int)(r < 0 ? 0 : (r > 255 ? 255 : r));
}

static void BEDotRGBToHSL(double r, double g, double b, double *h, double *s, double *l)
{
	r /= 255.0; g /= 255.0; b /= 255.0;
	double mx = fmax(r, fmax(g, b)), mn = fmin(r, fmin(g, b));
	*l = (mx + mn) / 2.0;
	if (mx == mn) { *h = 0.0; *s = 0.0; return; }
	double d = mx - mn;
	*s = (*l > 0.5) ? d / (2.0 - mx - mn) : d / (mx + mn);
	double hue;
	if (mx == r) { hue = (g - b) / d + (g < b ? 6.0 : 0.0); }
	else if (mx == g) { hue = (b - r) / d + 2.0; }
	else { hue = (r - g) / d + 4.0; }
	*h = hue / 6.0;
}

static double BEDotHueToRGB(double p, double q, double t)
{
	if (t < 0.0) { t += 1.0; }
	if (t > 1.0) { t -= 1.0; }
	if (t < 1.0 / 6.0) { return p + (q - p) * 6.0 * t; }
	if (t < 1.0 / 2.0) { return q; }
	if (t < 2.0 / 3.0) { return p + (q - p) * (2.0 / 3.0 - t) * 6.0; }
	return p;
}

static void BEDotHSLToRGB(double h, double s, double l, double *r, double *g, double *b)
{
	l = fmax(0.0, fmin(1.0, l));
	if (s == 0.0) { *r = *g = *b = l * 255.0; return; }
	double q = (l < 0.5) ? l * (1.0 + s) : l + s - l * s;
	double p = 2.0 * l - q;
	*r = BEDotHueToRGB(p, q, h + 1.0 / 3.0) * 255.0;
	*g = BEDotHueToRGB(p, q, h) * 255.0;
	*b = BEDotHueToRGB(p, q, h - 1.0 / 3.0) * 255.0;
}

/*! A BEColor from 0..255 channels, via the platform-neutral hex constructor. */
static BEColor *BEDotColorFromRGB(int r, int g, int b)
{
	return [BEColor colorWithHexString:[NSString stringWithFormat:@"#%02X%02X%02X", r, g, b]];
}

/*! TDot shade(): cascades a hue-preserving HSL lightness shift with a per-channel RGB
	nudge, each cross-modulated by the other space, so the result tracks the presets. */
static BEColor *BEDotShade(double r, double g, double b, double n, BOOL styleTop)
{
	double chroma = (fmax(r, fmax(g, b)) - fmin(r, fmin(g, b))) / 255.0;
	double h, s, l;
	BEDotRGBToHSL(r, g, b, &h, &s, &l);
	double hslDepth = kBEDotHSLDepthFraction * n * (1.0 + kBEDotHSLChromaMod * (2.0 * chroma - 1.0));
	l = BEDotNudgeRaw(l * 255.0, hslDepth, styleTop) / 255.0;
	BEDotHSLToRGB(h, s, l, &r, &g, &b);
	double rgbDepth = (1.0 - kBEDotHSLDepthFraction) * n * (1.0 + kBEDotRGBSatMod * (2.0 * s - 1.0));
	return BEDotColorFromRGB(BEDotNudge(r, rgbDepth, styleTop),
	                         BEDotNudge(g, rgbDepth, styleTop),
	                         BEDotNudge(b, rgbDepth, styleTop));
}

/*! Parses "#RRGGBB" into 0..255 channels; NO on a malformed value. */
static BOOL BEDotParseHex(NSString *hex, double *r, double *g, double *b)
{
	if (![hex hasPrefix:@"#"] || hex.length != 7) { return NO; }
	unsigned int value = 0;
	if (![[NSScanner scannerWithString:[hex substringFromIndex:1]] scanHexInt:&value]) { return NO; }
	*r = (value >> 16) & 0xFF;
	*g = (value >> 8) & 0xFF;
	*b = value & 0xFF;
	return YES;
}

/*! The preset {main, highlight} pairs, ported from TDot::COLORS. */
static NSDictionary<NSString *, NSArray<NSString *> *> *BEDotPresets(void)
{
	static NSDictionary *presets = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		presets = @{
		@"white": @[@"#E3E3E3", @"#FFFFFF"],
		@"silver": @[@"#A8A8A8", @"#E8E8E8"],
		@"gray": @[@"#606060", @"#B0B0B0"],
		@"black": @[@"#000000", @"#3C3C3C"],
		@"red": @[@"#B80000", @"#FF4A4A"],
		@"maroon": @[@"#500000", @"#B00000"],
		@"orange": @[@"#E89800", @"#FFC700"],
		@"yellow": @[@"#D9D900", @"#FFFF80"],
		@"olive": @[@"#505000", @"#9C9C00"],
		@"lime": @[@"#00CC00", @"#36FF36"],
		@"green": @[@"#007000", @"#00B000"],
		@"aqua": @[@"#00C0C0", @"#44FFFF"],
		@"cyan": @[@"#00C0C0", @"#44FFFF"],
		@"teal": @[@"#006060", @"#00A0A0"],
		@"blue": @[@"#0000B0", @"#3B3BFF"],
		@"navy": @[@"#000058", @"#0000C8"],
		@"fuchsia": @[@"#DD00DD", @"#FF80FF"],
		@"magenta": @[@"#DD00DD", @"#FF80FF"],
		@"purple": @[@"#600060", @"#AC00AC"],
		@"darkslategray": @[@"#234040", @"#446868"],
		@"dimgray": @[@"#505050", @"#A0A0A0"],
		@"slategray": @[@"#5C6A78", @"#90A4B6"],
		@"lightslategray": @[@"#637288", @"#99B2BD"],
		@"darkgray": @[@"#909090", @"#D0D0D0"],
		@"lightgray": @[@"#BDBDBD", @"#EFEFEF"],
		@"gainsboro": @[@"#C5C5C5", @"#F9F9F9"],
		@"mistyrose": @[@"#E0C6C3", @"#FFF0ED"],
		@"antiquewhite": @[@"#DCCDB3", @"#FDF4E8"],
		@"linen": @[@"#DCD3C8", @"#FDF7F3"],
		@"beige": @[@"#D6D6BC", @"#FAFAE6"],
		@"whitesmoke": @[@"#D8D8D8", @"#FDFDFD"],
		@"lavenderblush": @[@"#E0D0D4", @"#FFF6FA"],
		@"oldlace": @[@"#E1DAC4", @"#FFFFFF"],
		@"aliceblue": @[@"#D0D8E0", @"#F6FAFF"],
		@"seashell": @[@"#E3D6CE", @"#FFFAF6"],
		@"ghostwhite": @[@"#DBDBE3", @"#FFFFFF"],
		@"honeydew": @[@"#D0E0D0", @"#F3FFF3"],
		@"floralwhite": @[@"#E0D9D0", @"#FFFBF6"],
		@"azure": @[@"#D0E0E0", @"#F5FFFF"],
		@"mintcream": @[@"#D0E3D9", @"#F8FFFC"],
		@"snow": @[@"#E3DDDD", @"#FFFDFD"],
		@"ivory": @[@"#E7E7D0", @"#FFFFF6"],
		@"mediumvioletred": @[@"#B31370", @"#E520A8"],
		@"deeppink": @[@"#E31180", @"#FF69B0"],
		@"palevioletred": @[@"#BD5F80", @"#F288AD"],
		@"hotpink": @[@"#E3529C", @"#FFA0D1"],
		@"lightpink": @[@"#E39FA6", @"#FFCAD8"],
		@"pink": @[@"#E3AAB0", @"#FFD8E3"],
		@"darkred": @[@"#5B0000", @"#BB0B0B"],
		@"firebrick": @[@"#981111", @"#CE4444"],
		@"crimson": @[@"#B91030", @"#F23053"],
		@"indianred": @[@"#B85050", @"#E87B7B"],
		@"lightcoral": @[@"#DB7070", @"#F49A9A"],
		@"salmon": @[@"#E36A5D", @"#FE9D90"],
		@"darksalmon": @[@"#CF7F64", @"#F1B498"],
		@"lightsalmon": @[@"#FF9060", @"#FFBF98"],
		@"orangered": @[@"#E33300", @"#FF6833"],
		@"tomato": @[@"#E3543A", @"#FF8069"],
		@"darkorange": @[@"#E37100", @"#FFA400"],
		@"coral": @[@"#E36238", @"#FFA080"],
		@"darkkhaki": @[@"#A09948", @"#D8CF85"],
		@"gold": @[@"#E0C000", @"#FFE020"],
		@"khaki": @[@"#D3CC72", @"#F8F2A4"],
		@"peachpuff": @[@"#E3B09D", @"#FFE5D0"],
		@"palegoldenrod": @[@"#D2CC99", @"#F9F3BF"],
		@"moccasin": @[@"#E3C89D", @"#FFF9CA"],
		@"papayawhip": @[@"#E3D2BB", @"#FFF7E8"],
		@"lightgoldenrodyellow": @[@"#DFDFB6", @"#FCFCE8"],
		@"lemonchiffon": @[@"#E7E3A7", @"#FFFDE0"],
		@"lightyellow": @[@"#E7E7BF", @"#FFFFF2"],
		@"brown": @[@"#8D1616", @"#C94141"],
		@"saddlebrown": @[@"#703009", @"#A85F2F"],
		@"sienna": @[@"#883D13", @"#BA6D42"],
		@"chocolate": @[@"#BA5110", @"#E57D3A"],
		@"darkgoldenrod": @[@"#A06F08", @"#D09E16"],
		@"peru": @[@"#B66E24", @"#E69F57"],
		@"rosybrown": @[@"#A47777", @"#D4A7A7"],
		@"goldenrod": @[@"#C28D16", @"#F0BD30"],
		@"sandybrown": @[@"#D88B48", @"#FBBC80"],
		@"tan": @[@"#BA9C74", @"#EACCA4"],
		@"burlywood": @[@"#C6A06F", @"#F6D09F"],
		@"wheat": @[@"#DDC69B", @"#FBF2CB"],
		@"navajowhite": @[@"#E7C695", @"#FFF6C5"],
		@"bisque": @[@"#E7CCAC", @"#FFF5D4"],
		@"blanchedalmond": @[@"#E7D3B5", @"#FFFCE2"],
		@"cornsilk": @[@"#E7E0C4", @"#FFFFF0"],
		@"darkgreen": @[@"#004C00", @"#187F18"],
		@"darkolivegreen": @[@"#3D5317", @"#6D8347"],
		@"forestgreen": @[@"#117B11", @"#3ABC3A"],
		@"seagreen": @[@"#14783F", @"#46B36F"],
		@"olivedrab": @[@"#53760B", @"#83A63B"],
		@"mediumseagreen": @[@"#249B59", @"#54CB89"],
		@"limegreen": @[@"#1AB51A", @"#4AE54A"],
		@"springgreen": @[@"#00E767", @"#18FF97"],
		@"mediumspringgreen": @[@"#00E282", @"#18FFB2"],
		@"darkseagreen": @[@"#77A477", @"#A7D4A7"],
		@"mediumaquamarine": @[@"#4EB592", @"#7EE5C2"],
		@"yellowgreen": @[@"#82B51A", @"#B2E54A"],
		@"lawngreen": @[@"#64E400", @"#94FF18"],
		@"chartreuse": @[@"#67E700", @"#97FF18"],
		@"lightgreen": @[@"#78D678", @"#A8FFA8"],
		@"greenyellow": @[@"#95E717", @"#C5FF47"],
		@"palegreen": @[@"#80E380", @"#B0FFB0"],
		@"darkcyan": @[@"#007373", @"#06AEAE"],
		@"lightseagreen": @[@"#089A92", @"#38CAC2"],
		@"cadetblue": @[@"#478688", @"#77B6B8"],
		@"darkturquoise": @[@"#00B6B9", @"#18E6E9"],
		@"mediumturquoise": @[@"#30B9B4", @"#60E9E4"],
		@"turquoise": @[@"#28C8B8", @"#58F8E8"],
		@"aquamarine": @[@"#67E7BC", @"#97FFEC"],
		@"paleturquoise": @[@"#97D6D6", @"#C7FFFF"],
		@"lightcyan": @[@"#CBECEC", @"#FAFFFF"],
		@"midnightblue": @[@"#0A0A58", @"#3434B7"],
		@"darkblue": @[@"#00006A", @"#0000D4"],
		@"mediumblue": @[@"#000098", @"#1A1AF0"],
		@"royalblue": @[@"#2951C9", @"#5981F9"],
		@"steelblue": @[@"#2E6A9C", @"#5E9ACC"],
		@"dodgerblue": @[@"#0678E7", @"#36A8FF"],
		@"deepskyblue": @[@"#00A7E7", @"#18D7FF"],
		@"cornflowerblue": @[@"#4C7DD5", @"#7CADFF"],
		@"skyblue": @[@"#6FB6D3", @"#9FE6FF"],
		@"lightskyblue": @[@"#6FB6E2", @"#9FE6FF"],
		@"lightsteelblue": @[@"#98ACC6", @"#C8DCF6"],
		@"lightblue": @[@"#95C0CE", @"#C5F0FE"],
		@"powderblue": @[@"#98C8CE", @"#C8F8FE"],
		@"indigo": @[@"#33006A", @"#63009A"],
		@"darkmagenta": @[@"#740074", @"#B900B9"],
		@"darkviolet": @[@"#7C00BB", @"#AC00EB"],
		@"darkslateblue": @[@"#302573", @"#6055A3"],
		@"blueviolet": @[@"#7213CA", @"#A243FA"],
		@"darkorchid": @[@"#811AB4", @"#B14AE4"],
		@"slateblue": @[@"#5242B5", @"#8272E5"],
		@"mediumslateblue": @[@"#6350D6", @"#9380FF"],
		@"mediumorchid": @[@"#A23DBB", @"#D26DEB"],
		@"mediumpurple": @[@"#7B58C3", @"#AB88F3"],
		@"orchid": @[@"#C258BE", @"#F288EE"],
		@"violet": @[@"#D66AD6", @"#FF9AFF"],
		@"plum": @[@"#C588C5", @"#F5B8F5"],
		@"thistle": @[@"#C0A7C0", @"#F0D7F0"],
		@"lavender": @[@"#CACAE0", @"#F8F8FF"],
		@"rebeccapurple": @[@"#4E1B81", @"#7E4BB1"],
		};
	});
	return presets;
}



#pragma mark - View

@implementation BEDotView

- (nonnull instancetype)initWithFrame:(CGRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self != nil) {
		_depth = (NSInteger)kBEDotDefaultDepth;
		_shadowOpacity = 0.618;
		_flat = NO;
		_flatBorder = YES;
		_flatBorderWidthFraction = 0.05;
#if !TARGET_OS_OSX
		self.opaque = NO;
		self.backgroundColor = BEColor.clearColor;
		self.contentMode = UIViewContentModeRedraw;
#endif
	}
	return self;
}

#if TARGET_OS_OSX
- (BOOL)isOpaque { return NO; }
// Draw in a top-left y-down space so a single Core Graphics path serves macOS and UIKit.
- (BOOL)isFlipped { return YES; }
#endif

/*! Requests a redraw across the NSView (setNeedsDisplay:) / UIView (setNeedsDisplay) split. */
- (void)beMarkNeedsDisplay
{
#if TARGET_OS_OSX
	[self setNeedsDisplay:YES];
#else
	[self setNeedsDisplay];
#endif
}

- (void)setColorName:(NSString *)colorName
{
	NARC_RELEASE(_colorName);
	_colorName = [colorName copy];
	NARC_RELEASE(_mainColor);
	NARC_RELEASE(_highlightColor);
	_mainColor = nil;
	_highlightColor = nil;

	NSString *trimmed = [colorName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
	BOOL forceStandard = [trimmed hasPrefix:@"-"];
	if (forceStandard) {
		trimmed = [trimmed substringFromIndex:1];
	}
	NSString *key = trimmed.lowercaseString;

	NSArray<NSString *> *preset = BEDotPresets()[key];
	if (preset != nil && !forceStandard) {
		_mainColor = NARC_RETAIN([BEColor colorWithHexString:preset[0]]);
		_highlightColor = NARC_RETAIN([BEColor colorWithHexString:preset[1]]);
	} else {
		// The standard web colors live in BEColor (BExtension); TDot names map onto the
		// same CSS keywords, so there is one table rather than a copy that can drift.
		NSString *hex = [trimmed hasPrefix:@"#"] ? trimmed : [BEColor webColorNamed:key].hexString;
		double r = 0, g = 0, b = 0;
		if (hex != nil && BEDotParseHex(hex, &r, &g, &b)) {
			double depth = (double)self.depth;
			_mainColor = NARC_RETAIN(BEDotShade(r, g, b, -depth * kBEDotMainDepthScale, YES));
			_highlightColor = NARC_RETAIN(BEDotShade(r, g, b, depth, NO));
		}
	}
	[self beMarkNeedsDisplay];
}

- (void)setMainColor:(BEColor *)mainColor
{
	NARC_RELEASE(_mainColor);
	_mainColor = [mainColor copy];
	[self beMarkNeedsDisplay];
}

- (void)setHighlightColor:(BEColor *)highlightColor
{
	NARC_RELEASE(_highlightColor);
	_highlightColor = [highlightColor copy];
	[self beMarkNeedsDisplay];
}

- (void)setDepth:(NSInteger)depth
{
	_depth = depth < 0 ? 0 : (depth > 255 ? 255 : depth);
	if (_colorName != nil) {
		self.colorName = _colorName;   // recompute main/highlight at the new depth
	}
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
	_shadowOpacity = shadowOpacity < 0.0 ? 0.0 : (shadowOpacity > 1.0 ? 1.0 : shadowOpacity);
	[self beMarkNeedsDisplay];
}

- (void)setFlat:(BOOL)flat { _flat = flat; [self beMarkNeedsDisplay]; }
- (void)setFlatBorder:(BOOL)flatBorder { _flatBorder = flatBorder; [self beMarkNeedsDisplay]; }
- (void)setFlatBorderWidthFraction:(CGFloat)fraction { _flatBorderWidthFraction = fraction; [self beMarkNeedsDisplay]; }

- (void)setState:(BEDotState)state
{
	switch (state) {
		case BEDotStateOk:      self.colorName = @"LimeGreen"; break;
		case BEDotStateWarning: self.colorName = @"Yellow"; break;
		case BEDotStateError:   self.colorName = @"Red"; break;
		case BEDotStateActive:  self.colorName = @"Blue"; break;
		case BEDotStateOff:
		default:                self.colorName = @"Gray"; break;
	}
}

/*! The resolved main and highlight, falling back to TDot's neutral defaults. */
- (BEColor *)resolvedMainColor { return _mainColor ?: BEDotColorFromRGB(0x88, 0x88, 0x88); }
- (BEColor *)resolvedHighlightColor { return _highlightColor ?: BEDotColorFromRGB(0xE0, 0xE0, 0xE0); }

/*! The current Core Graphics context across the NSGraphicsContext / UIGraphics split. */
- (CGContextRef)beCurrentContext
{
#if TARGET_OS_OSX
	return [NSGraphicsContext currentContext].CGContext;
#else
	return UIGraphicsGetCurrentContext();
#endif
}

/*!
 @function   BEDotBoxKernel
 @abstract   The odd box width whose three-pass convolution approximates a Gaussian of sigma.
 @discussion Three box passes of width w give variance 3(w^2-1)/12, so w = sqrt(4*sigma^2+1).
*/
static uint32_t BEDotBoxKernel(CGFloat sigma)
{
	if (sigma <= 0.0) {
		return 1u;
	}
	uint32_t w = (uint32_t)lround(sqrt(4.0 * (double)sigma * (double)sigma + 1.0));
	if ((w & 1u) == 0u) {
		w += 1u;
	}
	return w < 1u ? 1u : w;
}

/*! Draws a radial gradient as an ellipse by scaling a circular one about its center. */
static void BEDotDrawEllipticalGradient(CGContextRef ctx, CGGradientRef gradient, CGPoint center,
                                        CGFloat rx, CGFloat ry, CGGradientDrawingOptions options)
{
	if (rx <= 0.0 || ry <= 0.0) {
		return;
	}
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, center.x, center.y);
	CGContextScaleCTM(ctx, rx / ry, 1.0);
	CGContextDrawRadialGradient(ctx, gradient, CGPointZero, 0.0, CGPointZero, ry, options);
	CGContextRestoreGState(ctx);
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGContextRef ctx = [self beCurrentContext];
	if (ctx == NULL) { return; }

	// TDot lays every element out as a percentage of a square viewport; the ball's 45% radius
	// is what leaves room for the shadow, so the square is not inset here.
	CGFloat side = fmin(self.bounds.size.width, self.bounds.size.height);
	CGRect square = CGRectMake(CGRectGetMidX(self.bounds) - side / 2.0,
	                           CGRectGetMidY(self.bounds) - side / 2.0, side, side);

	if (self.flat) {
		[self drawFlatInContext:ctx
		                 center:CGPointMake(CGRectGetMidX(square), CGRectGetMidY(square))
		                 radius:side * 0.46];
	} else {
		[self drawDotInContext:ctx square:square];
	}
}

- (void)drawFlatInContext:(CGContextRef)ctx center:(CGPoint)center radius:(CGFloat)radius
{
	BEColor *fill = _mainColor ?: [self resolvedMainColor];
	BEColor *border = _highlightColor ?: [self resolvedMainColor];
	if (_colorName != nil && _mainColor == nil) { fill = [self resolvedMainColor]; }

	CGRect circle = CGRectMake(center.x - radius, center.y - radius, radius * 2.0, radius * 2.0);
	if (self.flatBorder) {
		CGFloat stroke = fmax(0.0, self.flatBorderWidthFraction) * radius * 2.0;
		circle = CGRectInset(circle, stroke / 2.0, stroke / 2.0);
		CGContextSetLineWidth(ctx, stroke);
		CGContextSetStrokeColorWithColor(ctx, border.CGColor);
	}
	CGContextSetFillColorWithColor(ctx, fill.CGColor);
	CGContextAddEllipseInRect(ctx, circle);
	CGContextFillPath(ctx);
	if (self.flatBorder) {
		CGContextAddEllipseInRect(ctx, circle);
		CGContextStrokePath(ctx);
	}
}

- (void)drawDotInContext:(CGContextRef)ctx square:(CGRect)square
{
	// Percentages of the square, taken from TDot's SVG. The context is y-down on every
	// platform (macOS overrides isFlipped), matching SVG, so they transfer directly.
	const CGFloat S = square.size.width;
	const CGFloat ox = square.origin.x, oy = square.origin.y;
	const CGFloat bodyR = 0.45 * S;
	const CGRect bodyRect = CGRectMake(ox + 0.50 * S - bodyR, oy + 0.45 * S - bodyR, bodyR * 2, bodyR * 2);

	CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);

	// Drop shadow: TDot's shadow disc sits 4% lower than the ball, blurred by 2% of the side.
	CGContextSaveGState(ctx);
	CGColorRef shadowColor = CGColorCreateGenericGray(0.0, self.shadowOpacity);
	CGContextSetShadowWithColor(ctx, CGSizeMake(0.0, 0.04 * S), 0.04 * S, shadowColor);
	CGColorRelease(shadowColor);
	CGContextSetFillColorWithColor(ctx, [BEColor colorWithWhite:0.0 alpha:1.0].CGColor);
	CGContextAddEllipseInRect(ctx, bodyRect);
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);

	// Body: an ellipse-shaped radial, highlight at the low center out to main at the rim.
	CGContextSaveGState(ctx);
	CGContextAddEllipseInRect(ctx, bodyRect);
	CGContextClip(ctx);
	CGFloat bodyLocations[2] = { 0.0, 1.0 };
	NSArray *bodyColors = @[ (id)[self resolvedHighlightColor].CGColor, (id)[self resolvedMainColor].CGColor ];
	CGGradientRef bodyGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)bodyColors, bodyLocations);
	BEDotDrawEllipticalGradient(ctx, bodyGradient, CGPointMake(ox + 0.50 * S, oy + 0.828 * S),
	                            0.756 * S, 0.54 * S,
	                            kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(bodyGradient);
	CGContextRestoreGState(ctx);

	[self drawSpecularInContext:ctx square:square bodyRect:bodyRect colorSpace:space];
	CGColorSpaceRelease(space);
}

/*!
 @method     drawSpecularInContext:square:bodyRect:colorSpace:
 @abstract   Draws TDot's white reflection: an elliptical white gradient confined to an
             offset circle, blurred, then clipped to the ball.
 @discussion The blur is strongly anisotropic — TDot uses stdDeviation 8% of the side across
             and 2.3% down — which is what turns the clipped circle into a wide, soft
             reflection instead of a disc. Core Graphics has no shape blur, so the reflection
             is rendered into its own layer and convolved before it is composited.
*/
- (void)drawSpecularInContext:(CGContextRef)ctx square:(CGRect)square bodyRect:(CGRect)bodyRect
                   colorSpace:(CGColorSpaceRef)space
{
	const CGFloat S = square.size.width;
	const CGFloat sigmaX = 0.080 * S, sigmaY = 0.023 * S;
	const CGFloat margin = ceil(3.0 * sigmaX);
	const size_t w = (size_t)ceil(S + 2.0 * margin), h = w;
	if (w < 3) { return; }

	CGContextRef layer = CGBitmapContextCreate(NULL, w, h, 8, 0, space,
	                                           (uint32_t)kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
	if (layer == NULL) { return; }
	// Give the layer the same y-down orientation, with the square's origin at (margin, margin).
	CGContextTranslateCTM(layer, 0.0, (CGFloat)h);
	CGContextScaleCTM(layer, 1.0, -1.0);
	CGContextTranslateCTM(layer, margin, margin);

	const CGFloat clipR = 0.37 * S;
	CGContextAddEllipseInRect(layer, CGRectMake(0.50 * S - clipR, 0.40 * S - clipR, clipR * 2, clipR * 2));
	CGContextClip(layer);
	CGFloat specLocations[2] = { 0.10, 1.0 };   // solid white core out to 10% of the radius
	NSArray *specColors = @[ (id)[BEColor colorWithWhite:1.0 alpha:1.0].CGColor,
	                         (id)[BEColor colorWithWhite:1.0 alpha:0.0].CGColor ];
	CGGradientRef specGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)specColors, specLocations);
	BEDotDrawEllipticalGradient(layer, specGradient, CGPointMake(0.50 * S, 0.068 * S),
	                            0.648 * S, 0.432 * S, kCGGradientDrawsBeforeStartLocation);
	CGGradientRelease(specGradient);

	// Three box passes stand in for the Gaussian; vImage takes the two axes separately.
	uint8_t *pixels = (uint8_t *)CGBitmapContextGetData(layer);
	size_t rowBytes = CGBitmapContextGetBytesPerRow(layer);
	uint8_t *scratch = (uint8_t *)malloc(rowBytes * h);
	if (pixels != NULL && scratch != NULL) {
		vImage_Buffer a = { pixels,  h, w, rowBytes };
		vImage_Buffer b = { scratch, h, w, rowBytes };
		uint32_t kx = BEDotBoxKernel(sigmaX), ky = BEDotBoxKernel(sigmaY);
		for (int pass = 0; pass < 3; pass++) {
			vImageBoxConvolve_ARGB8888(&a, &b, NULL, 0, 0, ky, kx, NULL, kvImageEdgeExtend);
			vImage_Buffer t = a; a = b; b = t;   // ping-pong; `a` always holds the result
		}
		if (a.data != pixels) {
			memcpy(pixels, a.data, rowBytes * h);
		}
	}
	free(scratch);

	CGImageRef image = CGBitmapContextCreateImage(layer);
	CGContextRelease(layer);
	if (image == NULL) { return; }

	CGContextSaveGState(ctx);
	CGContextAddEllipseInRect(ctx, bodyRect);
	CGContextClip(ctx);
	CGRect dst = CGRectMake(square.origin.x - margin, square.origin.y - margin, (CGFloat)w, (CGFloat)h);
	// The layer is top-row-first; flip it back for this y-down context.
	CGContextTranslateCTM(ctx, dst.origin.x, dst.origin.y + dst.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, dst.size.width, dst.size.height), image);
	CGContextRestoreGState(ctx);
	CGImageRelease(image);
}

@end
