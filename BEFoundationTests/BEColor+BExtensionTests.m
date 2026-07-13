/*!
 @file       BEColor+BExtensionTests.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @abstract   Cross-platform tests for BEColor (hex parse/format, dynamic color).
 */

#import <XCTest/XCTest.h>
#import <BEFoundation/BEColor+BExtension.h>

@interface BEColorBExtensionTests : XCTestCase
@end

@implementation BEColorBExtensionTests

#pragma mark - Hex parsing

- (void)testHexParse_sixDigit {
	XCTAssertEqualObjects([BEColor colorWithHexString:@"#FF0000"].hexString, @"#FF0000");
	XCTAssertEqualObjects([BEColor colorWithHexString:@"#00FF00"].hexString, @"#00FF00");
	XCTAssertEqualObjects([BEColor colorWithHexString:@"#0000FF"].hexString, @"#0000FF");
}

- (void)testHexParse_noHashPrefix {
	XCTAssertEqualObjects([BEColor colorWithHexString:@"00FF00"].hexString, @"#00FF00");
}

- (void)testHexParse_0xPrefix {
	XCTAssertEqualObjects([BEColor colorWithHexString:@"0x0000FF"].hexString, @"#0000FF");
	XCTAssertEqualObjects([BEColor colorWithHexString:@"0X0000FF"].hexString, @"#0000FF");
}

- (void)testHexParse_threeDigitShorthandExpands {
	XCTAssertEqualObjects([BEColor colorWithHexString:@"#1a2"].hexString, @"#11AA22");
	XCTAssertEqualObjects([BEColor colorWithHexString:@"#fff"].hexString, @"#FFFFFF");
}

- (void)testHexParse_eightDigitAlpha {
	XCTAssertEqualObjects([BEColor colorWithHexString:@"#FF000080"].hexStringWithAlpha, @"#FF000080");
}

- (void)testHexParse_fourDigitShorthandAlphaExpands {
	XCTAssertEqualObjects([BEColor colorWithHexString:@"#f00f"].hexStringWithAlpha, @"#FF0000FF");
}

- (void)testHexParse_caseInsensitiveAndTrimmed {
	XCTAssertEqualObjects([BEColor colorWithHexString:@"  #ff0000  "].hexString, @"#FF0000");
}

- (void)testHexParse_invalidReturnsNil {
	XCTAssertNil([BEColor colorWithHexString:@""]);
	XCTAssertNil([BEColor colorWithHexString:@"#GG0000"]);   // non-hex, fails on first char
	XCTAssertNil([BEColor colorWithHexString:@"#12345G"]);   // valid hex prefix, trailing non-hex (!atEnd)
	XCTAssertNil([BEColor colorWithHexString:@"#FF000"]);    // 5 digits
	XCTAssertNil([BEColor colorWithHexString:@"#FF0000000"]);// 9 digits
	XCTAssertNil([BEColor colorWithHexString:@"nope"]);
}

#pragma mark - Hex formatting

- (void)testHexStringWithAlpha_opaqueAppendsFF {
	XCTAssertEqualObjects([BEColor colorWithHexString:@"#FF0000"].hexStringWithAlpha, @"#FF0000FF");
}

- (void)testHexString_roundTrips {
	for (NSString *hex in @[@"#123456", @"#ABCDEF", @"#000000", @"#FFFFFF"]) {
		XCTAssertEqualObjects([BEColor colorWithHexString:hex].hexString, hex, @"round-trip %@", hex);
	}
}

#pragma mark - Dynamic color

- (void)testDynamicColor_notNil {
	BEColor *dyn = [BEColor dynamicColorWithLight:[BEColor colorWithHexString:@"#FFFFFF"]
											 dark:[BEColor colorWithHexString:@"#000000"]];
	XCTAssertNotNil(dyn);
}

- (void)testDynamicColor_resolvesToDarkVariant {
	BEColor *dyn = [BEColor dynamicColorWithLight:[BEColor colorWithHexString:@"#FFFFFF"]
											 dark:[BEColor colorWithHexString:@"#000000"]];
	BEColor *resolved = nil;
#if TARGET_OS_OSX
	NSAppearance *dark = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
	__block BEColor *r = nil;
	[dark performAsCurrentDrawingAppearance:^{
		r = [dyn colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
	}];
	resolved = r;
#else
	resolved = [dyn resolvedColorWithTraitCollection:
				[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]];
#endif
	XCTAssertEqualObjects(resolved.hexString, @"#000000");
}

- (void)testDynamicColor_resolvesToLightVariant {
	BEColor *dyn = [BEColor dynamicColorWithLight:[BEColor colorWithHexString:@"#FFFFFF"]
											 dark:[BEColor colorWithHexString:@"#000000"]];
	BEColor *resolved = nil;
#if TARGET_OS_OSX
	NSAppearance *aqua = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
	__block BEColor *r = nil;
	[aqua performAsCurrentDrawingAppearance:^{
		r = [dyn colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
	}];
	resolved = r;
#else
	resolved = [dyn resolvedColorWithTraitCollection:
				[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]];
#endif
	XCTAssertEqualObjects(resolved.hexString, @"#FFFFFF");
}

#if TARGET_OS_OSX

#pragma mark - Non-RGB color formatting (macOS)

/*!
 @testcase testHexString_patternColorDoesNotRaise
 @abstract A pattern color has no sRGB representation; @c hexString must not raise.
 @discussion @c colorUsingColorSpace:sRGB returns nil for a pattern color, so @c be_getSRGBRed:
			 falls back to the receiver and its raising @c getRed: is caught and swallowed.
			 The result is a well-formed opaque-black hex string.
 */
- (void)testHexString_patternColorDoesNotRaise {
	NSImage *swatch = [[NSImage alloc] initWithSize:NSMakeSize(2, 2)];
	NSColor *pattern = [NSColor colorWithPatternImage:swatch];
	XCTAssertNil([pattern colorUsingColorSpace:NSColorSpace.sRGBColorSpace]);
	NSString *hex = nil;
	XCTAssertNoThrow(hex = pattern.hexString);
	XCTAssertEqual(hex.length, 7u);
	XCTAssertEqualObjects(hex, @"#000000");
}

#else

#pragma mark - Wide-gamut clamping (iOS)

/*!
 @testcase testHexString_wideGamutClampsComponents
 @abstract A Display-P3 saturated red reports extended-sRGB components outside [0, 1];
			@c BEClamp255 must clamp them into 00..FF.
 @discussion Display-P3 pure red maps to an sRGB red above 1 (clamps high to FF) and green/blue
			 slightly below 0 (clamp low to 00). This exercises both @c BEClamp255 boundary arms
			 the macOS sRGB conversion never reaches.
 */
- (void)testHexString_wideGamutClampsComponents {
	UIColor *p3 = [UIColor colorWithDisplayP3Red:1.0 green:0.0 blue:0.0 alpha:1.0];
	NSString *hex = p3.hexString;
	XCTAssertEqual(hex.length, 7u);
	XCTAssertEqualObjects([hex substringWithRange:NSMakeRange(1, 2)], @"FF");   // red clamps high
	XCTAssertEqualObjects([hex substringWithRange:NSMakeRange(3, 2)], @"00");   // green clamps low
	XCTAssertEqualObjects([hex substringWithRange:NSMakeRange(5, 2)], @"00");   // blue clamps low
}

#endif

@end
