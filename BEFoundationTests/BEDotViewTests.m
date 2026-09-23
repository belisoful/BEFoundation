/*!
 @file       BEDotViewTests.m
 @copyright  © 2025 Delicense - @belisoful. All rights reserved.
 @date       2025-11-11
 @author     belisoful@icloud.com
 @abstract   Cross-platform unit tests for BEDotView, the port of Prado's TDot.
 @discussion The color computation is the exact, testable part: the preset lookup and
			 the shade cascade must reproduce TDot's output, asserted through BEColor's
			 hex round-trip on every platform. Drawing is checked to run without
			 throwing in both modes, with the platform's own image context.
*/

#import <XCTest/XCTest.h>
#import "BEDotView.h"
#import "BEColor+BExtension.h"

@interface BEDotViewTests : XCTestCase
@end

@implementation BEDotViewTests

- (BEDotView *)dot
{
	return [BEDotView.alloc initWithFrame:CGRectMake(0, 0, 24, 24)];
}

/*! The color as an uppercase "#RRGGBB". */
- (NSString *)hexOf:(BEColor *)color
{
	return color.hexString.uppercaseString;
}

/*! One 0..255 channel (0=R, 1=G, 2=B) read back from the color's hex. */
- (int)channel:(int)index of:(BEColor *)color
{
	NSString *hex = color.hexString;   // "#RRGGBB"
	unsigned int value = 0;
	[[NSScanner scannerWithString:[hex substringWithRange:NSMakeRange(1 + index * 2, 2)]] scanHexInt:&value];
	return (int)value;
}

#pragma mark Preset colors

- (void)testANamedColorUsesItsPresetMainAndHighlight
{
	BEDotView *dot = self.dot;
	dot.colorName = @"Green";
	// TDot preset: green => ['#007000', '#00B000'].
	XCTAssertEqualObjects([self hexOf:dot.mainColor], @"#007000");
	XCTAssertEqualObjects([self hexOf:dot.highlightColor], @"#00B000");
}

- (void)testAnExtendedNamedColorResolvesItsPreset
{
	BEDotView *dot = self.dot;
	dot.colorName = @"DeepSkyBlue";
	// TDot preset: deepskyblue => ['#00A7E7', '#18D7FF'].
	XCTAssertEqualObjects([self hexOf:dot.mainColor], @"#00A7E7");
	XCTAssertEqualObjects([self hexOf:dot.highlightColor], @"#18D7FF");
}

#pragma mark Computed colors

- (void)testAHexColorComputesMainDarkerAndHighlightLighter
{
	BEDotView *dot = self.dot;
	dot.colorName = @"#70FF90";
	// TDot shade() at depth 24: main #57E379, highlight #8AFFA7.
	XCTAssertEqualObjects([self hexOf:dot.mainColor], @"#57E379");
	XCTAssertEqualObjects([self hexOf:dot.highlightColor], @"#8AFFA7");
}

- (void)testAForcedStandardColorComputesFromTheStandardHexNotThePreset
{
	BEDotView *dot = self.dot;
	dot.colorName = @"-Green";
	// Forced: standard green #008000 shaded, not the preset pair (#007000 / #00B000).
	XCTAssertNotEqualObjects([self hexOf:dot.mainColor], @"#007000");
	XCTAssertLessThan([self channel:1 of:dot.mainColor], 0x80, @"the main green darkens below standard");
	XCTAssertGreaterThan([self channel:1 of:dot.highlightColor], 0x80, @"the highlight green lightens above standard");
}

- (void)testShorthandHexExpandsToItsSixDigitForm
{
	BEDotView *shorthand = self.dot;
	shorthand.colorName = @"#7F9";
	BEDotView *full = self.dot;
	full.colorName = @"#77FF99";

	XCTAssertNotNil(shorthand.mainColor);
	XCTAssertEqualObjects([self hexOf:shorthand.mainColor], [self hexOf:full.mainColor]);
	XCTAssertEqualObjects([self hexOf:shorthand.highlightColor], [self hexOf:full.highlightColor]);
}

- (void)testHexWithNonHexCharactersLeavesBothColorsNil
{
	BEDotView *dot = self.dot;
	dot.colorName = @"#12345Z";
	XCTAssertNil(dot.mainColor);
	XCTAssertNil(dot.highlightColor);

	dot.colorName = @"#12345";
	XCTAssertNil(dot.mainColor, @"five digits is not a supported digit count");
	XCTAssertNil(dot.highlightColor);
}

- (void)testDepthWidensTheComputedSpread
{
	BEDotView *narrow = self.dot;
	narrow.depth = 8;
	narrow.colorName = @"#808080";
	BEDotView *wide = self.dot;
	wide.depth = 48;
	wide.colorName = @"#808080";

	XCTAssertLessThan([self channel:0 of:wide.mainColor], [self channel:0 of:narrow.mainColor],
					  @"a larger depth darkens the main color further");
}

- (void)testDepthRecomputesThePairWhenNoOverrideIsSet
{
	BEDotView *dot = self.dot;
	dot.colorName = @"#808080";
	int mainAt24 = [self channel:0 of:dot.mainColor];

	dot.depth = 48;

	XCTAssertLessThan([self channel:0 of:dot.mainColor], mainAt24);
	XCTAssertEqualObjects(dot.colorName, @"#808080");
}

- (void)testDepthKeepsAnExplicitMainColorOverride
{
	BEDotView *dot = self.dot;
	dot.colorName = @"#808080";
	BEColor *override = [BEColor colorWithHexString:@"#123456"];
	dot.mainColor = override;
	NSString *highlightBefore = [self hexOf:dot.highlightColor];

	dot.depth = 48;

	XCTAssertEqualObjects([self hexOf:dot.mainColor], @"#123456");
	XCTAssertEqualObjects([self hexOf:dot.highlightColor], highlightBefore);
}

- (void)testDepthKeepsAnExplicitHighlightColorOverride
{
	BEDotView *dot = self.dot;
	dot.colorName = @"#808080";
	dot.highlightColor = [BEColor colorWithHexString:@"#FEDCBA"];
	NSString *mainBefore = [self hexOf:dot.mainColor];

	dot.depth = 48;

	XCTAssertEqualObjects([self hexOf:dot.highlightColor], @"#FEDCBA");
	XCTAssertEqualObjects([self hexOf:dot.mainColor], mainBefore);
}

- (void)testSettingColorNameDiscardsExplicitOverrides
{
	BEDotView *dot = self.dot;
	dot.mainColor = [BEColor colorWithHexString:@"#123456"];
	dot.highlightColor = [BEColor colorWithHexString:@"#FEDCBA"];

	dot.colorName = @"Green";

	XCTAssertEqualObjects([self hexOf:dot.mainColor], @"#007000");
	XCTAssertEqualObjects([self hexOf:dot.highlightColor], @"#00B000");

	// The pair derives from colorName again, so depth recomputes it.
	dot.colorName = @"#808080";
	int mainAt24 = [self channel:0 of:dot.mainColor];
	dot.depth = 48;
	XCTAssertLessThan([self channel:0 of:dot.mainColor], mainAt24);
}

#pragma mark State

- (void)testStateMapsToItsStatusColor
{
	BEDotView *dot = self.dot;

	[dot setState:BEDotStateOk];
	XCTAssertEqualObjects(dot.colorName, @"LimeGreen");
	XCTAssertEqualObjects([self hexOf:dot.mainColor], @"#1AB51A");

	[dot setState:BEDotStateError];
	XCTAssertEqualObjects(dot.colorName, @"Red");

	[dot setState:BEDotStateOff];
	XCTAssertEqualObjects(dot.colorName, @"Gray");
}

#pragma mark Defaults & drawing

- (void)testDefaults
{
	BEDotView *dot = self.dot;
	XCTAssertEqual(dot.depth, (NSInteger)24);
	XCTAssertEqualWithAccuracy(dot.shadowOpacity, 0.618, 1e-9);
	XCTAssertFalse(dot.flat);
	XCTAssertTrue(dot.flatBorder);
	XCTAssertEqualWithAccuracy(dot.flatBorderWidthFraction, 0.05, 1e-9);
}

- (void)testInitWithCoderAppliesTheDefaults
{
	NSError *error = nil;
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.dot requiringSecureCoding:NO error:&error];
	XCTAssertNotNil(data, @"%@", error);

	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
	XCTAssertNotNil(unarchiver, @"%@", error);
	unarchiver.requiresSecureCoding = NO;
	BEDotView *decoded = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
	[unarchiver finishDecoding];

	XCTAssertTrue([decoded isKindOfClass:BEDotView.class]);
	XCTAssertEqual(decoded.depth, (NSInteger)24);
	XCTAssertEqualWithAccuracy(decoded.shadowOpacity, 0.618, 1e-9);
	XCTAssertFalse(decoded.flat);
	XCTAssertTrue(decoded.flatBorder);
	XCTAssertEqualWithAccuracy(decoded.flatBorderWidthFraction, 0.05, 1e-9);
#if !TARGET_OS_OSX
	XCTAssertFalse(decoded.opaque);
	XCTAssertEqual(decoded.contentMode, UIViewContentModeRedraw);
	XCTAssertEqualObjects(decoded.backgroundColor, UIColor.clearColor);
#endif

	decoded.colorName = @"#70FF90";
	XCTAssertEqualObjects([self hexOf:decoded.mainColor], @"#57E379", @"the decoded depth drives the shade cascade");
}

- (void)testBothRenderModesDrawWithoutThrowing
{
	for (int flat = 0; flat <= 1; flat++) {
		@autoreleasepool {
			BEDotView *dot = self.dot;
			dot.colorName = @"DodgerBlue";
			dot.flat = (flat == 1);

#if TARGET_OS_OSX
			NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																		   pixelsWide:24
																		   pixelsHigh:24
																		bitsPerSample:8
																	  samplesPerPixel:4
																			 hasAlpha:YES
																			 isPlanar:NO
																	   colorSpaceName:NSCalibratedRGBColorSpace
																		  bytesPerRow:0
																		 bitsPerPixel:0];
			XCTAssertNotNil(rep);
			[NSGraphicsContext saveGraphicsState];
			NSGraphicsContext.currentContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
			XCTAssertNoThrow([dot drawRect:dot.bounds], @"flat=%d", flat);
			[NSGraphicsContext restoreGraphicsState];
#else
			UIGraphicsBeginImageContextWithOptions(CGSizeMake(24, 24), NO, 0.0);
			XCTAssertNoThrow([dot drawRect:dot.bounds], @"flat=%d", flat);
			UIGraphicsEndImageContext();
#endif
		}
	}
}


#pragma mark Self-assignment

- (void)testAssigningTheCurrentColorNameKeepsTheComputedPair
{
	BEDotView *dot = self.dot;
	dot.colorName = @"#808080";
	NSString *main = [self hexOf:dot.mainColor];
	NSString *highlight = [self hexOf:dot.highlightColor];

	dot.colorName = dot.colorName;

	XCTAssertEqualObjects(dot.colorName, @"#808080");
	XCTAssertEqualObjects([self hexOf:dot.mainColor], main);
	XCTAssertEqualObjects([self hexOf:dot.highlightColor], highlight);
}

- (void)testAssigningTheCurrentMainAndHighlightColorsKeepsThem
{
	BEDotView *dot = self.dot;
	dot.mainColor = [BEColor colorWithHexString:@"#123456"];
	dot.highlightColor = [BEColor colorWithHexString:@"#654321"];

	dot.mainColor = dot.mainColor;
	dot.highlightColor = dot.highlightColor;

	XCTAssertEqualObjects([self hexOf:dot.mainColor], @"#123456");
	XCTAssertEqualObjects([self hexOf:dot.highlightColor], @"#654321");
}

@end
