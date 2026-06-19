/*!
 @file       BEColor+BExtension.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @author     belisoful@icloud.com
 @abstract   Implementation of the hex/dynamic-color conveniences on BEColor.
 */

#import <BEFoundation/BEColor+BExtension.h>

@implementation BEColor (BExtension)

#pragma mark - sRGB component access (never raises)

// Fill r/g/b/a with the receiver's sRGB components. On macOS the receiver is first converted
// into the sRGB space (NSColor's component accessors raise on non-RGB colors); on iOS the
// RGBA accessor already reports sRGB. Components are left as reported (callers clamp).
- (void)be_getSRGBRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
	CGFloat r = 0, g = 0, b = 0, a = 1;
#if TARGET_OS_OSX
	NSColor *c = [self colorUsingColorSpace:NSColorSpace.sRGBColorSpace] ?: self;
	@try { [c getRed:&r green:&g blue:&b alpha:&a]; } @catch (__unused NSException *e) {}
#else
	if (![self getRed:&r green:&g blue:&b alpha:&a]) {
		// Non-RGB (e.g. pattern) colors: fall back to white-level if available.
		CGFloat w = 1;
		if ([self getWhite:&w alpha:&a]) { r = g = b = w; }
	}
#endif
	if (red)   *red   = r;
	if (green) *green = g;
	if (blue)  *blue  = b;
	if (alpha) *alpha = a;
}

static inline int BEClamp255(CGFloat component) {
	long v = lround(component * 255.0);
	return (int)(v < 0 ? 0 : (v > 255 ? 255 : v));
}

#pragma mark - Hex parsing

+ (nullable BEColor *)colorWithHexString:(NSString *)hexString {
	if (hexString.length == 0) {
		return nil;
	}
	NSString *s = [hexString stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
	if ([s hasPrefix:@"#"]) {
		s = [s substringFromIndex:1];
	} else if ([s hasPrefix:@"0x"] || [s hasPrefix:@"0X"]) {
		s = [s substringFromIndex:2];
	}

	// Expand 3-digit (RGB) and 4-digit (RGBA) shorthand to their full form.
	if (s.length == 3 || s.length == 4) {
		NSMutableString *expanded = [NSMutableString stringWithCapacity:s.length * 2];
		for (NSUInteger i = 0; i < s.length; i++) {
			unichar ch = [s characterAtIndex:i];
			[expanded appendFormat:@"%C%C", ch, ch];
		}
		s = expanded;
	}
	if (s.length != 6 && s.length != 8) {
		return nil;
	}

	unsigned long long value = 0;
	NSScanner *scanner = [NSScanner scannerWithString:s];
	if (![scanner scanHexLongLong:&value] || !scanner.atEnd) {
		return nil;   // contained non-hex characters
	}

	CGFloat r, g, b, a;
	if (s.length == 8) {
		r = ((value >> 24) & 0xFF) / 255.0;
		g = ((value >> 16) & 0xFF) / 255.0;
		b = ((value >>  8) & 0xFF) / 255.0;
		a = ( value        & 0xFF) / 255.0;
	} else {
		r = ((value >> 16) & 0xFF) / 255.0;
		g = ((value >>  8) & 0xFF) / 255.0;
		b = ( value        & 0xFF) / 255.0;
		a = 1.0;
	}

#if TARGET_OS_OSX
	return [NSColor colorWithSRGBRed:r green:g blue:b alpha:a];
#else
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
#endif
}

#pragma mark - Hex formatting

- (NSString *)hexString {
	CGFloat r, g, b, a;
	[self be_getSRGBRed:&r green:&g blue:&b alpha:&a];
	return [NSString stringWithFormat:@"#%02X%02X%02X", BEClamp255(r), BEClamp255(g), BEClamp255(b)];
}

- (NSString *)hexStringWithAlpha {
	CGFloat r, g, b, a;
	[self be_getSRGBRed:&r green:&g blue:&b alpha:&a];
	return [NSString stringWithFormat:@"#%02X%02X%02X%02X", BEClamp255(r), BEClamp255(g), BEClamp255(b), BEClamp255(a)];
}

#pragma mark - Appearance-aware

+ (BEColor *)dynamicColorWithLight:(BEColor *)lightColor dark:(BEColor *)darkColor {
#if TARGET_OS_OSX
	return [NSColor colorWithName:nil dynamicProvider:^NSColor *(NSAppearance *appearance) {
		NSAppearanceName match = [appearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]];
		return [match isEqualToString:NSAppearanceNameDarkAqua] ? darkColor : lightColor;
	}];
#else
	return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traits) {
		return traits.userInterfaceStyle == UIUserInterfaceStyleDark ? darkColor : lightColor;
	}];
#endif
}

@end
