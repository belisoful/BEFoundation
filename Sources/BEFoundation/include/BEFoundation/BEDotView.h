/*!
 @header     BEDotView.h
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @date       2025-11-11
 @author     belisoful@icloud.com
 @abstract   A cross-platform status-indicator dot view, a port of Prado's TDot.
 @discussion BEDotView draws a three-dimensional dot: a radial gradient from the
			 highlight color at the lower center to the main color at the rim, a white
			 specular reflection near the top, and a soft drop shadow. Setting @c flat
			 draws a plain filled circle with an optional border instead.

			 It is a @c BEView subclass, so it renders on every platform BEFoundation
			 supports: @c NSView on macOS, @c UIView on iOS. The drawing is a
			 top-left, y-down coordinate system on every platform (macOS overrides
			 @c isFlipped), so a single Core Graphics path serves them all.

			 The appearance is set from a single color. @c colorName accepts a web color
			 name (@c "Green", @c "DeepSkyBlue"), a name prefixed with @c "-" to force the
			 standard color over any preset, or a hex value (@c "#70FF90", or the @c "#7F9"
			 shorthand). A named color uses TDot's preset main and highlight pair; a hex
			 value computes the main darker and the highlight lighter by @c depth, through
			 the same shade cascade TDot uses. A hex value with non-hex characters or an
			 unsupported digit count leaves both colors @c nil. @c mainColor and
			 @c highlightColor override the pair directly.

			 The defaults apply on every init path, including a nib or storyboard decode
			 through @c initWithCoder: .

			 For indicator use, @c setState: maps a BEDotState to its status color:
			 Off gray, Ok LimeGreen, Warning Yellow, Error Red, Active Blue.

			 The color presets, the shade cascade, and the tuning constants reproduce
			 Prado TDot's output (framework/Web/UI/WebControls/TDot.php); the SVG document
			 becomes Core Graphics radial-gradient drawing.
 @since      1.1
 */

#ifndef BEDotView_h
#define BEDotView_h

#import <BEFoundation/BEPlatformTypes.h>

/*!
 @typedef    BEDotState
 @abstract   The named states a status dot conveys, each mapped to a web color.
 @constant   BEDotStateOff      Gray.
 @constant   BEDotStateOk       LimeGreen.
 @constant   BEDotStateWarning  Yellow.
 @constant   BEDotStateError    Red.
 @constant   BEDotStateActive   Blue.
 */
typedef NS_ENUM(NSInteger, BEDotState) {
	BEDotStateOff		= 0,
	BEDotStateOk		= 1,
	BEDotStateWarning	= 2,
	BEDotStateError		= 3,
	BEDotStateActive	= 4,
};

/*!
 @class      BEDotView
 @abstract   A cross-platform status-indicator dot view, a port of Prado's TDot.
 */
@interface BEDotView : BEView

/*! A web color name, a @c "-"-forced name, or a hex value. Setting computes main/highlight
	and discards any explicit mainColor or highlightColor. */
@property (nonatomic, copy, nullable) NSString *colorName;

/*! The rim and upper color; overrides the pair computed from colorName. An explicit value
	survives a depth change. */
@property (nonatomic, copy, nullable) BEColor *mainColor;

/*! The lower-center highlight color; overrides the pair computed from colorName. An explicit
	value survives a depth change. */
@property (nonatomic, copy, nullable) BEColor *highlightColor;

/*! The color offset used to compute main/highlight from a hex colorName. Clamped to
	[0, 255]; defaults to 24. Setting recomputes the pair from colorName only while neither
	mainColor nor highlightColor is set explicitly. */
@property (nonatomic, assign) NSInteger depth;

/*! The drop-shadow opacity of the 3D dot. Clamped to [0, 1]; defaults to 0.618. */
@property (nonatomic, assign) CGFloat shadowOpacity;

/*! Draws a flat 2D circle instead of the 3D dot. Defaults to NO. */
@property (nonatomic, assign) BOOL flat;

/*! Whether the flat circle carries a border. Defaults to YES. */
@property (nonatomic, assign) BOOL flatBorder;

/*! The flat border stroke width as a fraction of the dot diameter. Defaults to 0.05. */
@property (nonatomic, assign) CGFloat flatBorderWidthFraction;

/*! Sets colorName to the web color mapped from the state. */
- (void)setState:(BEDotState)state;

@end

#endif /* BEDotView_h */
