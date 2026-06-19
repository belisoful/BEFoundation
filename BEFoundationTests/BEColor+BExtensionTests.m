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
	XCTAssertNil([BEColor colorWithHexString:@"#GG0000"]);   // non-hex
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

@end
