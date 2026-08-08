/*!
 @file       BEColor+BEWebColor.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @author     belisoful@icloud.com
 @abstract   The CSS/SVG color keyword table and its accessors.
*/

#import "BEColor+BEWebColor.h"
#import "BEColor+BExtension.h"

#pragma mark - Web color name constants

NSString * const BEWebColorNameWhite = @"White";
NSString * const BEWebColorNameSilver = @"Silver";
NSString * const BEWebColorNameGray = @"Gray";
NSString * const BEWebColorNameBlack = @"Black";
NSString * const BEWebColorNameRed = @"Red";
NSString * const BEWebColorNameMaroon = @"Maroon";
NSString * const BEWebColorNameOrange = @"Orange";
NSString * const BEWebColorNameYellow = @"Yellow";
NSString * const BEWebColorNameOlive = @"Olive";
NSString * const BEWebColorNameLime = @"Lime";
NSString * const BEWebColorNameGreen = @"Green";
NSString * const BEWebColorNameAqua = @"Aqua";
NSString * const BEWebColorNameCyan = @"Cyan";
NSString * const BEWebColorNameTeal = @"Teal";
NSString * const BEWebColorNameBlue = @"Blue";
NSString * const BEWebColorNameNavy = @"Navy";
NSString * const BEWebColorNameFuchsia = @"Fuchsia";
NSString * const BEWebColorNameMagenta = @"Magenta";
NSString * const BEWebColorNamePurple = @"Purple";
NSString * const BEWebColorNameDarkSlateGray = @"DarkSlateGray";
NSString * const BEWebColorNameDimGray = @"DimGray";
NSString * const BEWebColorNameSlateGray = @"SlateGray";
NSString * const BEWebColorNameLightSlateGray = @"LightSlateGray";
NSString * const BEWebColorNameDarkGray = @"DarkGray";
NSString * const BEWebColorNameLightGray = @"LightGray";
NSString * const BEWebColorNameGainsboro = @"Gainsboro";
NSString * const BEWebColorNameMistyRose = @"MistyRose";
NSString * const BEWebColorNameAntiqueWhite = @"AntiqueWhite";
NSString * const BEWebColorNameLinen = @"Linen";
NSString * const BEWebColorNameBeige = @"Beige";
NSString * const BEWebColorNameWhiteSmoke = @"WhiteSmoke";
NSString * const BEWebColorNameLavenderBlush = @"LavenderBlush";
NSString * const BEWebColorNameOldLace = @"OldLace";
NSString * const BEWebColorNameAliceBlue = @"AliceBlue";
NSString * const BEWebColorNameSeashell = @"Seashell";
NSString * const BEWebColorNameGhostWhite = @"GhostWhite";
NSString * const BEWebColorNameHoneydew = @"Honeydew";
NSString * const BEWebColorNameFloralWhite = @"FloralWhite";
NSString * const BEWebColorNameAzure = @"Azure";
NSString * const BEWebColorNameMintCream = @"MintCream";
NSString * const BEWebColorNameSnow = @"Snow";
NSString * const BEWebColorNameIvory = @"Ivory";
NSString * const BEWebColorNameMediumVioletRed = @"MediumVioletRed";
NSString * const BEWebColorNameDeepPink = @"DeepPink";
NSString * const BEWebColorNamePaleVioletRed = @"PaleVioletRed";
NSString * const BEWebColorNameHotPink = @"HotPink";
NSString * const BEWebColorNameLightPink = @"LightPink";
NSString * const BEWebColorNamePink = @"Pink";
NSString * const BEWebColorNameDarkRed = @"DarkRed";
NSString * const BEWebColorNameFirebrick = @"Firebrick";
NSString * const BEWebColorNameCrimson = @"Crimson";
NSString * const BEWebColorNameIndianRed = @"IndianRed";
NSString * const BEWebColorNameLightCoral = @"LightCoral";
NSString * const BEWebColorNameSalmon = @"Salmon";
NSString * const BEWebColorNameDarkSalmon = @"DarkSalmon";
NSString * const BEWebColorNameLightSalmon = @"LightSalmon";
NSString * const BEWebColorNameOrangeRed = @"OrangeRed";
NSString * const BEWebColorNameTomato = @"Tomato";
NSString * const BEWebColorNameDarkOrange = @"DarkOrange";
NSString * const BEWebColorNameCoral = @"Coral";
NSString * const BEWebColorNameDarkKhaki = @"DarkKhaki";
NSString * const BEWebColorNameGold = @"Gold";
NSString * const BEWebColorNameKhaki = @"Khaki";
NSString * const BEWebColorNamePeachPuff = @"PeachPuff";
NSString * const BEWebColorNamePaleGoldenrod = @"PaleGoldenrod";
NSString * const BEWebColorNameMoccasin = @"Moccasin";
NSString * const BEWebColorNamePapayaWhip = @"PapayaWhip";
NSString * const BEWebColorNameLightGoldenrodYellow = @"LightGoldenrodYellow";
NSString * const BEWebColorNameLemonChiffon = @"LemonChiffon";
NSString * const BEWebColorNameLightYellow = @"LightYellow";
NSString * const BEWebColorNameBrown = @"Brown";
NSString * const BEWebColorNameSaddleBrown = @"SaddleBrown";
NSString * const BEWebColorNameSienna = @"Sienna";
NSString * const BEWebColorNameChocolate = @"Chocolate";
NSString * const BEWebColorNameDarkGoldenrod = @"DarkGoldenrod";
NSString * const BEWebColorNamePeru = @"Peru";
NSString * const BEWebColorNameRosyBrown = @"RosyBrown";
NSString * const BEWebColorNameGoldenrod = @"Goldenrod";
NSString * const BEWebColorNameSandyBrown = @"SandyBrown";
NSString * const BEWebColorNameTan = @"Tan";
NSString * const BEWebColorNameBurlyWood = @"BurlyWood";
NSString * const BEWebColorNameWheat = @"Wheat";
NSString * const BEWebColorNameNavajoWhite = @"NavajoWhite";
NSString * const BEWebColorNameBisque = @"Bisque";
NSString * const BEWebColorNameBlanchedAlmond = @"BlanchedAlmond";
NSString * const BEWebColorNameCornsilk = @"Cornsilk";
NSString * const BEWebColorNameDarkGreen = @"DarkGreen";
NSString * const BEWebColorNameDarkOliveGreen = @"DarkOliveGreen";
NSString * const BEWebColorNameForestGreen = @"ForestGreen";
NSString * const BEWebColorNameSeaGreen = @"SeaGreen";
NSString * const BEWebColorNameOliveDrab = @"OliveDrab";
NSString * const BEWebColorNameMediumSeaGreen = @"MediumSeaGreen";
NSString * const BEWebColorNameLimeGreen = @"LimeGreen";
NSString * const BEWebColorNameSpringGreen = @"SpringGreen";
NSString * const BEWebColorNameMediumSpringGreen = @"MediumSpringGreen";
NSString * const BEWebColorNameDarkSeaGreen = @"DarkSeaGreen";
NSString * const BEWebColorNameMediumAquamarine = @"MediumAquamarine";
NSString * const BEWebColorNameYellowGreen = @"YellowGreen";
NSString * const BEWebColorNameLawnGreen = @"LawnGreen";
NSString * const BEWebColorNameChartreuse = @"Chartreuse";
NSString * const BEWebColorNameLightGreen = @"LightGreen";
NSString * const BEWebColorNameGreenYellow = @"GreenYellow";
NSString * const BEWebColorNamePaleGreen = @"PaleGreen";
NSString * const BEWebColorNameDarkCyan = @"DarkCyan";
NSString * const BEWebColorNameLightSeaGreen = @"LightSeaGreen";
NSString * const BEWebColorNameCadetBlue = @"CadetBlue";
NSString * const BEWebColorNameDarkTurquoise = @"DarkTurquoise";
NSString * const BEWebColorNameMediumTurquoise = @"MediumTurquoise";
NSString * const BEWebColorNameTurquoise = @"Turquoise";
NSString * const BEWebColorNameAquamarine = @"Aquamarine";
NSString * const BEWebColorNamePaleTurquoise = @"PaleTurquoise";
NSString * const BEWebColorNameLightCyan = @"LightCyan";
NSString * const BEWebColorNameMidnightBlue = @"MidnightBlue";
NSString * const BEWebColorNameDarkBlue = @"DarkBlue";
NSString * const BEWebColorNameMediumBlue = @"MediumBlue";
NSString * const BEWebColorNameRoyalBlue = @"RoyalBlue";
NSString * const BEWebColorNameSteelBlue = @"SteelBlue";
NSString * const BEWebColorNameDodgerBlue = @"DodgerBlue";
NSString * const BEWebColorNameDeepSkyBlue = @"DeepSkyBlue";
NSString * const BEWebColorNameCornflowerBlue = @"CornflowerBlue";
NSString * const BEWebColorNameSkyBlue = @"SkyBlue";
NSString * const BEWebColorNameLightSkyBlue = @"LightSkyBlue";
NSString * const BEWebColorNameLightSteelBlue = @"LightSteelBlue";
NSString * const BEWebColorNameLightBlue = @"LightBlue";
NSString * const BEWebColorNamePowderBlue = @"PowderBlue";
NSString * const BEWebColorNameIndigo = @"Indigo";
NSString * const BEWebColorNameDarkMagenta = @"DarkMagenta";
NSString * const BEWebColorNameDarkViolet = @"DarkViolet";
NSString * const BEWebColorNameDarkSlateBlue = @"DarkSlateBlue";
NSString * const BEWebColorNameBlueViolet = @"BlueViolet";
NSString * const BEWebColorNameDarkOrchid = @"DarkOrchid";
NSString * const BEWebColorNameSlateBlue = @"SlateBlue";
NSString * const BEWebColorNameMediumSlateBlue = @"MediumSlateBlue";
NSString * const BEWebColorNameMediumOrchid = @"MediumOrchid";
NSString * const BEWebColorNameMediumPurple = @"MediumPurple";
NSString * const BEWebColorNameOrchid = @"Orchid";
NSString * const BEWebColorNameViolet = @"Violet";
NSString * const BEWebColorNamePlum = @"Plum";
NSString * const BEWebColorNameThistle = @"Thistle";
NSString * const BEWebColorNameLavender = @"Lavender";
NSString * const BEWebColorNameRebeccaPurple = @"RebeccaPurple";

/*! Keyword (lowercased) to hex, the CSS/SVG extended color set. */
static NSDictionary<NSString *, NSString *> *BEWebColorHexTable(void)
{
	static NSDictionary *table = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		table = @{
			@"white": @"#FFFFFF",
			@"silver": @"#C0C0C0",
			@"gray": @"#808080",
			@"black": @"#000000",
			@"red": @"#FF0000",
			@"maroon": @"#800000",
			@"orange": @"#FFA500",
			@"yellow": @"#FFFF00",
			@"olive": @"#808000",
			@"lime": @"#00FF00",
			@"green": @"#008000",
			@"aqua": @"#00FFFF",
			@"cyan": @"#00FFFF",
			@"teal": @"#008080",
			@"blue": @"#0000FF",
			@"navy": @"#000080",
			@"fuchsia": @"#FF00FF",
			@"magenta": @"#FF00FF",
			@"purple": @"#800080",
			@"darkslategray": @"#2F4F4F",
			@"dimgray": @"#696969",
			@"slategray": @"#708090",
			@"lightslategray": @"#778899",
			@"darkgray": @"#A9A9A9",
			@"lightgray": @"#D3D3D3",
			@"gainsboro": @"#DCDCDC",
			@"mistyrose": @"#FFE4E1",
			@"antiquewhite": @"#FAEBD7",
			@"linen": @"#FAF0E6",
			@"beige": @"#F5F5DC",
			@"whitesmoke": @"#F5F5F5",
			@"lavenderblush": @"#FFF0F5",
			@"oldlace": @"#FDF5E6",
			@"aliceblue": @"#F0F8FF",
			@"seashell": @"#FFF5EE",
			@"ghostwhite": @"#F8F8FF",
			@"honeydew": @"#F0FFF0",
			@"floralwhite": @"#FFFAF0",
			@"azure": @"#F0FFFF",
			@"mintcream": @"#F5FFFA",
			@"snow": @"#FFFAFA",
			@"ivory": @"#FFFFF0",
			@"mediumvioletred": @"#C71585",
			@"deeppink": @"#FF1493",
			@"palevioletred": @"#DB7093",
			@"hotpink": @"#FF69B4",
			@"lightpink": @"#FFB6C1",
			@"pink": @"#FFC0CB",
			@"darkred": @"#8B0000",
			@"firebrick": @"#B22222",
			@"crimson": @"#DC143C",
			@"indianred": @"#CD5C5C",
			@"lightcoral": @"#F08080",
			@"salmon": @"#FA8072",
			@"darksalmon": @"#E9967A",
			@"lightsalmon": @"#FFA07A",
			@"orangered": @"#FF4500",
			@"tomato": @"#FF6347",
			@"darkorange": @"#FF8C00",
			@"coral": @"#FF7F50",
			@"darkkhaki": @"#BDB76B",
			@"gold": @"#FFD700",
			@"khaki": @"#F0E68C",
			@"peachpuff": @"#FFDAB9",
			@"palegoldenrod": @"#EEE8AA",
			@"moccasin": @"#FFE4B5",
			@"papayawhip": @"#FFEFD5",
			@"lightgoldenrodyellow": @"#FAFAD2",
			@"lemonchiffon": @"#FFFACD",
			@"lightyellow": @"#FFFFE0",
			@"brown": @"#A52A2A",
			@"saddlebrown": @"#8B4513",
			@"sienna": @"#A0522D",
			@"chocolate": @"#D2691E",
			@"darkgoldenrod": @"#B8860B",
			@"peru": @"#CD853F",
			@"rosybrown": @"#BC8F8F",
			@"goldenrod": @"#DAA520",
			@"sandybrown": @"#F4A460",
			@"tan": @"#D2B48C",
			@"burlywood": @"#DEB887",
			@"wheat": @"#F5DEB3",
			@"navajowhite": @"#FFDEAD",
			@"bisque": @"#FFE4C4",
			@"blanchedalmond": @"#FFEBCD",
			@"cornsilk": @"#FFF8DC",
			@"darkgreen": @"#006400",
			@"darkolivegreen": @"#556B2F",
			@"forestgreen": @"#228B22",
			@"seagreen": @"#2E8B57",
			@"olivedrab": @"#6B8E23",
			@"mediumseagreen": @"#3CB371",
			@"limegreen": @"#32CD32",
			@"springgreen": @"#00FF7F",
			@"mediumspringgreen": @"#00FA9A",
			@"darkseagreen": @"#8FBC8F",
			@"mediumaquamarine": @"#66CDAA",
			@"yellowgreen": @"#9ACD32",
			@"lawngreen": @"#7CFC00",
			@"chartreuse": @"#7FFF00",
			@"lightgreen": @"#90EE90",
			@"greenyellow": @"#ADFF2F",
			@"palegreen": @"#98FB98",
			@"darkcyan": @"#008B8B",
			@"lightseagreen": @"#20B2AA",
			@"cadetblue": @"#5F9EA0",
			@"darkturquoise": @"#00CED1",
			@"mediumturquoise": @"#48D1CC",
			@"turquoise": @"#40E0D0",
			@"aquamarine": @"#7FFFD4",
			@"paleturquoise": @"#AFEEEE",
			@"lightcyan": @"#E0FFFF",
			@"midnightblue": @"#191970",
			@"darkblue": @"#00008B",
			@"mediumblue": @"#0000CD",
			@"royalblue": @"#4169E1",
			@"steelblue": @"#4682B4",
			@"dodgerblue": @"#1E90FF",
			@"deepskyblue": @"#00BFFF",
			@"cornflowerblue": @"#6495ED",
			@"skyblue": @"#87CEEB",
			@"lightskyblue": @"#87CEFA",
			@"lightsteelblue": @"#B0C4DE",
			@"lightblue": @"#ADD8E6",
			@"powderblue": @"#B0E0E6",
			@"indigo": @"#4B0082",
			@"darkmagenta": @"#8B008B",
			@"darkviolet": @"#9400D3",
			@"darkslateblue": @"#483D8B",
			@"blueviolet": @"#8A2BE2",
			@"darkorchid": @"#9932CC",
			@"slateblue": @"#6A5ACD",
			@"mediumslateblue": @"#7B68EE",
			@"mediumorchid": @"#BA55D3",
			@"mediumpurple": @"#9370DB",
			@"orchid": @"#DA70D6",
			@"violet": @"#EE82EE",
			@"plum": @"#DDA0DD",
			@"thistle": @"#D8BFD8",
			@"lavender": @"#E6E6FA",
			@"rebeccapurple": @"#663399",
		};
	});
	return table;
}

@implementation BEColor (BEWebColor)

#pragma mark - Web color lookup

+ (nullable BEColor *)webColorNamed:(NSString *)name
{
	if (![name isKindOfClass:NSString.class]) {
		return nil;
	}
	NSString *key = [[name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] lowercaseString];
	if (key.length == 0) {
		return nil;
	}
	// Resolved colors are cached: the properties below are the common path and each one
	// would otherwise re-parse its hex on every read.
	static NSCache<NSString *, BEColor *> *cache = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{ cache = [NSCache new]; });
	BEColor *cached = [cache objectForKey:key];
	if (cached != nil) {
		return cached;
	}
	NSString *hex = BEWebColorHexTable()[key];
	if (hex == nil) {
		return nil;
	}
	BEColor *color = [self colorWithHexString:hex];
	if (color != nil) {
		[cache setObject:color forKey:key];
	}
	return color;
}

+ (nullable NSString *)webColorNameForColor:(BEColor *)color
{
	if (color == nil) {
		return nil;
	}
	NSString *hex = [color.hexString uppercaseString];
	if (hex.length == 0) {
		return nil;
	}
	for (NSString *canonical in [self webColorNames]) {
		if ([BEWebColorHexTable()[canonical.lowercaseString].uppercaseString isEqualToString:hex]) {
			return canonical;
		}
	}
	return nil;
}

+ (NSArray<NSString *> *)webColorNames
{
	static NSArray *names = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{ names = @[
		BEWebColorNameWhite,
		BEWebColorNameSilver,
		BEWebColorNameGray,
		BEWebColorNameBlack,
		BEWebColorNameRed,
		BEWebColorNameMaroon,
		BEWebColorNameOrange,
		BEWebColorNameYellow,
		BEWebColorNameOlive,
		BEWebColorNameLime,
		BEWebColorNameGreen,
		BEWebColorNameAqua,
		BEWebColorNameCyan,
		BEWebColorNameTeal,
		BEWebColorNameBlue,
		BEWebColorNameNavy,
		BEWebColorNameFuchsia,
		BEWebColorNameMagenta,
		BEWebColorNamePurple,
		BEWebColorNameDarkSlateGray,
		BEWebColorNameDimGray,
		BEWebColorNameSlateGray,
		BEWebColorNameLightSlateGray,
		BEWebColorNameDarkGray,
		BEWebColorNameLightGray,
		BEWebColorNameGainsboro,
		BEWebColorNameMistyRose,
		BEWebColorNameAntiqueWhite,
		BEWebColorNameLinen,
		BEWebColorNameBeige,
		BEWebColorNameWhiteSmoke,
		BEWebColorNameLavenderBlush,
		BEWebColorNameOldLace,
		BEWebColorNameAliceBlue,
		BEWebColorNameSeashell,
		BEWebColorNameGhostWhite,
		BEWebColorNameHoneydew,
		BEWebColorNameFloralWhite,
		BEWebColorNameAzure,
		BEWebColorNameMintCream,
		BEWebColorNameSnow,
		BEWebColorNameIvory,
		BEWebColorNameMediumVioletRed,
		BEWebColorNameDeepPink,
		BEWebColorNamePaleVioletRed,
		BEWebColorNameHotPink,
		BEWebColorNameLightPink,
		BEWebColorNamePink,
		BEWebColorNameDarkRed,
		BEWebColorNameFirebrick,
		BEWebColorNameCrimson,
		BEWebColorNameIndianRed,
		BEWebColorNameLightCoral,
		BEWebColorNameSalmon,
		BEWebColorNameDarkSalmon,
		BEWebColorNameLightSalmon,
		BEWebColorNameOrangeRed,
		BEWebColorNameTomato,
		BEWebColorNameDarkOrange,
		BEWebColorNameCoral,
		BEWebColorNameDarkKhaki,
		BEWebColorNameGold,
		BEWebColorNameKhaki,
		BEWebColorNamePeachPuff,
		BEWebColorNamePaleGoldenrod,
		BEWebColorNameMoccasin,
		BEWebColorNamePapayaWhip,
		BEWebColorNameLightGoldenrodYellow,
		BEWebColorNameLemonChiffon,
		BEWebColorNameLightYellow,
		BEWebColorNameBrown,
		BEWebColorNameSaddleBrown,
		BEWebColorNameSienna,
		BEWebColorNameChocolate,
		BEWebColorNameDarkGoldenrod,
		BEWebColorNamePeru,
		BEWebColorNameRosyBrown,
		BEWebColorNameGoldenrod,
		BEWebColorNameSandyBrown,
		BEWebColorNameTan,
		BEWebColorNameBurlyWood,
		BEWebColorNameWheat,
		BEWebColorNameNavajoWhite,
		BEWebColorNameBisque,
		BEWebColorNameBlanchedAlmond,
		BEWebColorNameCornsilk,
		BEWebColorNameDarkGreen,
		BEWebColorNameDarkOliveGreen,
		BEWebColorNameForestGreen,
		BEWebColorNameSeaGreen,
		BEWebColorNameOliveDrab,
		BEWebColorNameMediumSeaGreen,
		BEWebColorNameLimeGreen,
		BEWebColorNameSpringGreen,
		BEWebColorNameMediumSpringGreen,
		BEWebColorNameDarkSeaGreen,
		BEWebColorNameMediumAquamarine,
		BEWebColorNameYellowGreen,
		BEWebColorNameLawnGreen,
		BEWebColorNameChartreuse,
		BEWebColorNameLightGreen,
		BEWebColorNameGreenYellow,
		BEWebColorNamePaleGreen,
		BEWebColorNameDarkCyan,
		BEWebColorNameLightSeaGreen,
		BEWebColorNameCadetBlue,
		BEWebColorNameDarkTurquoise,
		BEWebColorNameMediumTurquoise,
		BEWebColorNameTurquoise,
		BEWebColorNameAquamarine,
		BEWebColorNamePaleTurquoise,
		BEWebColorNameLightCyan,
		BEWebColorNameMidnightBlue,
		BEWebColorNameDarkBlue,
		BEWebColorNameMediumBlue,
		BEWebColorNameRoyalBlue,
		BEWebColorNameSteelBlue,
		BEWebColorNameDodgerBlue,
		BEWebColorNameDeepSkyBlue,
		BEWebColorNameCornflowerBlue,
		BEWebColorNameSkyBlue,
		BEWebColorNameLightSkyBlue,
		BEWebColorNameLightSteelBlue,
		BEWebColorNameLightBlue,
		BEWebColorNamePowderBlue,
		BEWebColorNameIndigo,
		BEWebColorNameDarkMagenta,
		BEWebColorNameDarkViolet,
		BEWebColorNameDarkSlateBlue,
		BEWebColorNameBlueViolet,
		BEWebColorNameDarkOrchid,
		BEWebColorNameSlateBlue,
		BEWebColorNameMediumSlateBlue,
		BEWebColorNameMediumOrchid,
		BEWebColorNameMediumPurple,
		BEWebColorNameOrchid,
		BEWebColorNameViolet,
		BEWebColorNamePlum,
		BEWebColorNameThistle,
		BEWebColorNameLavender,
		BEWebColorNameRebeccaPurple,
	]; });
	return names;
}

+ (NSDictionary<NSString *, BEColor *> *)webColors
{
	static NSDictionary *colors = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		NSMutableDictionary *m = [NSMutableDictionary dictionaryWithCapacity:BEWebColorHexTable().count];
		for (NSString *canonical in [self webColorNames]) {
			BEColor *c = [self webColorNamed:canonical];
			if (c != nil) {
				m[canonical] = c;
			}
		}
		colors = [m copy];
	});
	return colors;
}

#pragma mark Web color properties

+ (BEColor *)webWhite { return [self webColorNamed:BEWebColorNameWhite]; }
+ (BEColor *)webSilver { return [self webColorNamed:BEWebColorNameSilver]; }
+ (BEColor *)webGray { return [self webColorNamed:BEWebColorNameGray]; }
+ (BEColor *)webBlack { return [self webColorNamed:BEWebColorNameBlack]; }
+ (BEColor *)webRed { return [self webColorNamed:BEWebColorNameRed]; }
+ (BEColor *)webMaroon { return [self webColorNamed:BEWebColorNameMaroon]; }
+ (BEColor *)webOrange { return [self webColorNamed:BEWebColorNameOrange]; }
+ (BEColor *)webYellow { return [self webColorNamed:BEWebColorNameYellow]; }
+ (BEColor *)webOlive { return [self webColorNamed:BEWebColorNameOlive]; }
+ (BEColor *)webLime { return [self webColorNamed:BEWebColorNameLime]; }
+ (BEColor *)webGreen { return [self webColorNamed:BEWebColorNameGreen]; }
+ (BEColor *)webAqua { return [self webColorNamed:BEWebColorNameAqua]; }
+ (BEColor *)webCyan { return [self webColorNamed:BEWebColorNameCyan]; }
+ (BEColor *)webTeal { return [self webColorNamed:BEWebColorNameTeal]; }
+ (BEColor *)webBlue { return [self webColorNamed:BEWebColorNameBlue]; }
+ (BEColor *)webNavy { return [self webColorNamed:BEWebColorNameNavy]; }
+ (BEColor *)webFuchsia { return [self webColorNamed:BEWebColorNameFuchsia]; }
+ (BEColor *)webMagenta { return [self webColorNamed:BEWebColorNameMagenta]; }
+ (BEColor *)webPurple { return [self webColorNamed:BEWebColorNamePurple]; }
+ (BEColor *)webDarkSlateGray { return [self webColorNamed:BEWebColorNameDarkSlateGray]; }
+ (BEColor *)webDimGray { return [self webColorNamed:BEWebColorNameDimGray]; }
+ (BEColor *)webSlateGray { return [self webColorNamed:BEWebColorNameSlateGray]; }
+ (BEColor *)webLightSlateGray { return [self webColorNamed:BEWebColorNameLightSlateGray]; }
+ (BEColor *)webDarkGray { return [self webColorNamed:BEWebColorNameDarkGray]; }
+ (BEColor *)webLightGray { return [self webColorNamed:BEWebColorNameLightGray]; }
+ (BEColor *)webGainsboro { return [self webColorNamed:BEWebColorNameGainsboro]; }
+ (BEColor *)webMistyRose { return [self webColorNamed:BEWebColorNameMistyRose]; }
+ (BEColor *)webAntiqueWhite { return [self webColorNamed:BEWebColorNameAntiqueWhite]; }
+ (BEColor *)webLinen { return [self webColorNamed:BEWebColorNameLinen]; }
+ (BEColor *)webBeige { return [self webColorNamed:BEWebColorNameBeige]; }
+ (BEColor *)webWhiteSmoke { return [self webColorNamed:BEWebColorNameWhiteSmoke]; }
+ (BEColor *)webLavenderBlush { return [self webColorNamed:BEWebColorNameLavenderBlush]; }
+ (BEColor *)webOldLace { return [self webColorNamed:BEWebColorNameOldLace]; }
+ (BEColor *)webAliceBlue { return [self webColorNamed:BEWebColorNameAliceBlue]; }
+ (BEColor *)webSeashell { return [self webColorNamed:BEWebColorNameSeashell]; }
+ (BEColor *)webGhostWhite { return [self webColorNamed:BEWebColorNameGhostWhite]; }
+ (BEColor *)webHoneydew { return [self webColorNamed:BEWebColorNameHoneydew]; }
+ (BEColor *)webFloralWhite { return [self webColorNamed:BEWebColorNameFloralWhite]; }
+ (BEColor *)webAzure { return [self webColorNamed:BEWebColorNameAzure]; }
+ (BEColor *)webMintCream { return [self webColorNamed:BEWebColorNameMintCream]; }
+ (BEColor *)webSnow { return [self webColorNamed:BEWebColorNameSnow]; }
+ (BEColor *)webIvory { return [self webColorNamed:BEWebColorNameIvory]; }
+ (BEColor *)webMediumVioletRed { return [self webColorNamed:BEWebColorNameMediumVioletRed]; }
+ (BEColor *)webDeepPink { return [self webColorNamed:BEWebColorNameDeepPink]; }
+ (BEColor *)webPaleVioletRed { return [self webColorNamed:BEWebColorNamePaleVioletRed]; }
+ (BEColor *)webHotPink { return [self webColorNamed:BEWebColorNameHotPink]; }
+ (BEColor *)webLightPink { return [self webColorNamed:BEWebColorNameLightPink]; }
+ (BEColor *)webPink { return [self webColorNamed:BEWebColorNamePink]; }
+ (BEColor *)webDarkRed { return [self webColorNamed:BEWebColorNameDarkRed]; }
+ (BEColor *)webFirebrick { return [self webColorNamed:BEWebColorNameFirebrick]; }
+ (BEColor *)webCrimson { return [self webColorNamed:BEWebColorNameCrimson]; }
+ (BEColor *)webIndianRed { return [self webColorNamed:BEWebColorNameIndianRed]; }
+ (BEColor *)webLightCoral { return [self webColorNamed:BEWebColorNameLightCoral]; }
+ (BEColor *)webSalmon { return [self webColorNamed:BEWebColorNameSalmon]; }
+ (BEColor *)webDarkSalmon { return [self webColorNamed:BEWebColorNameDarkSalmon]; }
+ (BEColor *)webLightSalmon { return [self webColorNamed:BEWebColorNameLightSalmon]; }
+ (BEColor *)webOrangeRed { return [self webColorNamed:BEWebColorNameOrangeRed]; }
+ (BEColor *)webTomato { return [self webColorNamed:BEWebColorNameTomato]; }
+ (BEColor *)webDarkOrange { return [self webColorNamed:BEWebColorNameDarkOrange]; }
+ (BEColor *)webCoral { return [self webColorNamed:BEWebColorNameCoral]; }
+ (BEColor *)webDarkKhaki { return [self webColorNamed:BEWebColorNameDarkKhaki]; }
+ (BEColor *)webGold { return [self webColorNamed:BEWebColorNameGold]; }
+ (BEColor *)webKhaki { return [self webColorNamed:BEWebColorNameKhaki]; }
+ (BEColor *)webPeachPuff { return [self webColorNamed:BEWebColorNamePeachPuff]; }
+ (BEColor *)webPaleGoldenrod { return [self webColorNamed:BEWebColorNamePaleGoldenrod]; }
+ (BEColor *)webMoccasin { return [self webColorNamed:BEWebColorNameMoccasin]; }
+ (BEColor *)webPapayaWhip { return [self webColorNamed:BEWebColorNamePapayaWhip]; }
+ (BEColor *)webLightGoldenrodYellow { return [self webColorNamed:BEWebColorNameLightGoldenrodYellow]; }
+ (BEColor *)webLemonChiffon { return [self webColorNamed:BEWebColorNameLemonChiffon]; }
+ (BEColor *)webLightYellow { return [self webColorNamed:BEWebColorNameLightYellow]; }
+ (BEColor *)webBrown { return [self webColorNamed:BEWebColorNameBrown]; }
+ (BEColor *)webSaddleBrown { return [self webColorNamed:BEWebColorNameSaddleBrown]; }
+ (BEColor *)webSienna { return [self webColorNamed:BEWebColorNameSienna]; }
+ (BEColor *)webChocolate { return [self webColorNamed:BEWebColorNameChocolate]; }
+ (BEColor *)webDarkGoldenrod { return [self webColorNamed:BEWebColorNameDarkGoldenrod]; }
+ (BEColor *)webPeru { return [self webColorNamed:BEWebColorNamePeru]; }
+ (BEColor *)webRosyBrown { return [self webColorNamed:BEWebColorNameRosyBrown]; }
+ (BEColor *)webGoldenrod { return [self webColorNamed:BEWebColorNameGoldenrod]; }
+ (BEColor *)webSandyBrown { return [self webColorNamed:BEWebColorNameSandyBrown]; }
+ (BEColor *)webTan { return [self webColorNamed:BEWebColorNameTan]; }
+ (BEColor *)webBurlyWood { return [self webColorNamed:BEWebColorNameBurlyWood]; }
+ (BEColor *)webWheat { return [self webColorNamed:BEWebColorNameWheat]; }
+ (BEColor *)webNavajoWhite { return [self webColorNamed:BEWebColorNameNavajoWhite]; }
+ (BEColor *)webBisque { return [self webColorNamed:BEWebColorNameBisque]; }
+ (BEColor *)webBlanchedAlmond { return [self webColorNamed:BEWebColorNameBlanchedAlmond]; }
+ (BEColor *)webCornsilk { return [self webColorNamed:BEWebColorNameCornsilk]; }
+ (BEColor *)webDarkGreen { return [self webColorNamed:BEWebColorNameDarkGreen]; }
+ (BEColor *)webDarkOliveGreen { return [self webColorNamed:BEWebColorNameDarkOliveGreen]; }
+ (BEColor *)webForestGreen { return [self webColorNamed:BEWebColorNameForestGreen]; }
+ (BEColor *)webSeaGreen { return [self webColorNamed:BEWebColorNameSeaGreen]; }
+ (BEColor *)webOliveDrab { return [self webColorNamed:BEWebColorNameOliveDrab]; }
+ (BEColor *)webMediumSeaGreen { return [self webColorNamed:BEWebColorNameMediumSeaGreen]; }
+ (BEColor *)webLimeGreen { return [self webColorNamed:BEWebColorNameLimeGreen]; }
+ (BEColor *)webSpringGreen { return [self webColorNamed:BEWebColorNameSpringGreen]; }
+ (BEColor *)webMediumSpringGreen { return [self webColorNamed:BEWebColorNameMediumSpringGreen]; }
+ (BEColor *)webDarkSeaGreen { return [self webColorNamed:BEWebColorNameDarkSeaGreen]; }
+ (BEColor *)webMediumAquamarine { return [self webColorNamed:BEWebColorNameMediumAquamarine]; }
+ (BEColor *)webYellowGreen { return [self webColorNamed:BEWebColorNameYellowGreen]; }
+ (BEColor *)webLawnGreen { return [self webColorNamed:BEWebColorNameLawnGreen]; }
+ (BEColor *)webChartreuse { return [self webColorNamed:BEWebColorNameChartreuse]; }
+ (BEColor *)webLightGreen { return [self webColorNamed:BEWebColorNameLightGreen]; }
+ (BEColor *)webGreenYellow { return [self webColorNamed:BEWebColorNameGreenYellow]; }
+ (BEColor *)webPaleGreen { return [self webColorNamed:BEWebColorNamePaleGreen]; }
+ (BEColor *)webDarkCyan { return [self webColorNamed:BEWebColorNameDarkCyan]; }
+ (BEColor *)webLightSeaGreen { return [self webColorNamed:BEWebColorNameLightSeaGreen]; }
+ (BEColor *)webCadetBlue { return [self webColorNamed:BEWebColorNameCadetBlue]; }
+ (BEColor *)webDarkTurquoise { return [self webColorNamed:BEWebColorNameDarkTurquoise]; }
+ (BEColor *)webMediumTurquoise { return [self webColorNamed:BEWebColorNameMediumTurquoise]; }
+ (BEColor *)webTurquoise { return [self webColorNamed:BEWebColorNameTurquoise]; }
+ (BEColor *)webAquamarine { return [self webColorNamed:BEWebColorNameAquamarine]; }
+ (BEColor *)webPaleTurquoise { return [self webColorNamed:BEWebColorNamePaleTurquoise]; }
+ (BEColor *)webLightCyan { return [self webColorNamed:BEWebColorNameLightCyan]; }
+ (BEColor *)webMidnightBlue { return [self webColorNamed:BEWebColorNameMidnightBlue]; }
+ (BEColor *)webDarkBlue { return [self webColorNamed:BEWebColorNameDarkBlue]; }
+ (BEColor *)webMediumBlue { return [self webColorNamed:BEWebColorNameMediumBlue]; }
+ (BEColor *)webRoyalBlue { return [self webColorNamed:BEWebColorNameRoyalBlue]; }
+ (BEColor *)webSteelBlue { return [self webColorNamed:BEWebColorNameSteelBlue]; }
+ (BEColor *)webDodgerBlue { return [self webColorNamed:BEWebColorNameDodgerBlue]; }
+ (BEColor *)webDeepSkyBlue { return [self webColorNamed:BEWebColorNameDeepSkyBlue]; }
+ (BEColor *)webCornflowerBlue { return [self webColorNamed:BEWebColorNameCornflowerBlue]; }
+ (BEColor *)webSkyBlue { return [self webColorNamed:BEWebColorNameSkyBlue]; }
+ (BEColor *)webLightSkyBlue { return [self webColorNamed:BEWebColorNameLightSkyBlue]; }
+ (BEColor *)webLightSteelBlue { return [self webColorNamed:BEWebColorNameLightSteelBlue]; }
+ (BEColor *)webLightBlue { return [self webColorNamed:BEWebColorNameLightBlue]; }
+ (BEColor *)webPowderBlue { return [self webColorNamed:BEWebColorNamePowderBlue]; }
+ (BEColor *)webIndigo { return [self webColorNamed:BEWebColorNameIndigo]; }
+ (BEColor *)webDarkMagenta { return [self webColorNamed:BEWebColorNameDarkMagenta]; }
+ (BEColor *)webDarkViolet { return [self webColorNamed:BEWebColorNameDarkViolet]; }
+ (BEColor *)webDarkSlateBlue { return [self webColorNamed:BEWebColorNameDarkSlateBlue]; }
+ (BEColor *)webBlueViolet { return [self webColorNamed:BEWebColorNameBlueViolet]; }
+ (BEColor *)webDarkOrchid { return [self webColorNamed:BEWebColorNameDarkOrchid]; }
+ (BEColor *)webSlateBlue { return [self webColorNamed:BEWebColorNameSlateBlue]; }
+ (BEColor *)webMediumSlateBlue { return [self webColorNamed:BEWebColorNameMediumSlateBlue]; }
+ (BEColor *)webMediumOrchid { return [self webColorNamed:BEWebColorNameMediumOrchid]; }
+ (BEColor *)webMediumPurple { return [self webColorNamed:BEWebColorNameMediumPurple]; }
+ (BEColor *)webOrchid { return [self webColorNamed:BEWebColorNameOrchid]; }
+ (BEColor *)webViolet { return [self webColorNamed:BEWebColorNameViolet]; }
+ (BEColor *)webPlum { return [self webColorNamed:BEWebColorNamePlum]; }
+ (BEColor *)webThistle { return [self webColorNamed:BEWebColorNameThistle]; }
+ (BEColor *)webLavender { return [self webColorNamed:BEWebColorNameLavender]; }
+ (BEColor *)webRebeccaPurple { return [self webColorNamed:BEWebColorNameRebeccaPurple]; }

@end
