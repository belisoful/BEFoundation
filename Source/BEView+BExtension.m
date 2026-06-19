/*!
 @file       BEView+BExtension.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @author     belisoful@icloud.com
 @abstract   Implementation of the Auto Layout conveniences on BEView.
 */

#import <BEFoundation/BEView+BExtension.h>

@implementation BEView (BExtension)

- (NSArray<NSLayoutConstraint *> *)pinEdgesToSuperview {
	return [self pinEdgesToSuperviewWithInsets:BEEdgeInsetsMake(0, 0, 0, 0)];
}

- (NSArray<NSLayoutConstraint *> *)pinEdgesToSuperviewWithInsets:(BEEdgeInsets)insets {
	BEView *superview = self.superview;
	if (superview == nil) {
		return @[];
	}
	return [self pinEdgesToView:superview insets:insets];
}

- (NSArray<NSLayoutConstraint *> *)pinEdgesToView:(BEView *)view insets:(BEEdgeInsets)insets {
	if (view == nil) {
		return @[];
	}
	self.translatesAutoresizingMaskIntoConstraints = NO;
	NSArray<NSLayoutConstraint *> *constraints = @[
		[self.topAnchor      constraintEqualToAnchor:view.topAnchor      constant:insets.top],
		[self.leadingAnchor  constraintEqualToAnchor:view.leadingAnchor  constant:insets.left],
		[self.bottomAnchor   constraintEqualToAnchor:view.bottomAnchor   constant:-insets.bottom],
		[self.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-insets.right],
	];
	[NSLayoutConstraint activateConstraints:constraints];
	return constraints;
}

- (NSArray<NSLayoutConstraint *> *)centerInSuperview {
	BEView *superview = self.superview;
	if (superview == nil) {
		return @[];
	}
	self.translatesAutoresizingMaskIntoConstraints = NO;
	NSArray<NSLayoutConstraint *> *constraints = @[
		[self.centerXAnchor constraintEqualToAnchor:superview.centerXAnchor],
		[self.centerYAnchor constraintEqualToAnchor:superview.centerYAnchor],
	];
	[NSLayoutConstraint activateConstraints:constraints];
	return constraints;
}

- (NSArray<NSLayoutConstraint *> *)constrainToSize:(CGSize)size {
	return [self constrainToWidth:size.width height:size.height];
}

- (NSArray<NSLayoutConstraint *> *)constrainToWidth:(CGFloat)width height:(CGFloat)height {
	self.translatesAutoresizingMaskIntoConstraints = NO;
	NSArray<NSLayoutConstraint *> *constraints = @[
		[self.widthAnchor  constraintEqualToConstant:width],
		[self.heightAnchor constraintEqualToConstant:height],
	];
	[NSLayoutConstraint activateConstraints:constraints];
	return constraints;
}

@end
