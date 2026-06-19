/*!
 @file			NSNotification+ExtraProperties.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/

#import "NSNotification+ExtraProperties.h"
#import <objc/runtime.h>

@implementation NSNotification (ExtraProperties)

/*!
 @method		tag
 @abstract		Gets the tag of the notification.
 @result		NSInteger of the tag.
 */
- (NSInteger)tag
{
	NSNumber *tag = objc_getAssociatedObject(self, @selector(tag));
	if (!tag) {
		if ([self.object respondsToSelector:@selector(tag)]) {
			return [self.object tag];
		}
		NSNumber *tag = self.userInfo[@"tag"];
		if (tag && [tag isKindOfClass:NSNumber.class]) {
			return tag.integerValue;
		}
		return 0;
	}
	return tag.integerValue;
}

/*!
 @method		setTag
 @abstract		Sets the tag of the notification..
 @param		tag		 The NSInteger of the tag.
 */
- (void)setTag:(NSInteger)tag
{
	NSNumber *value = nil;
	if (tag) {
		value = [NSNumber numberWithInteger:tag];
	}
	objc_setAssociatedObject(self, @selector(tag), value, OBJC_ASSOCIATION_RETAIN);
}

/*!
 @method		identifier
 @abstract		Gets the identifier of the notification.
 @result		id of the tag object
 */
- (id)identifier
{
	id identifier = objc_getAssociatedObject(self, @selector(identifier));
	
	if (!identifier) {
		if ([self.object respondsToSelector:@selector(identifier)]) {
			return [self.object identifier];
		}
		identifier = self.userInfo[@"identifier"];
	}
	return identifier;
}

/*!
 @method		setIdentifier
 @abstract		Sets the identifier of the notification..
 @param		identifier		 The id of the identifier.
 */
- (void)setIdentifier:(id)identifier
{
	if ([identifier conformsToProtocol:@protocol(NSCopying)]) {
		identifier = [identifier copy];
	}
	objc_setAssociatedObject(self, @selector(identifier), identifier, OBJC_ASSOCIATION_RETAIN);
}

@end
