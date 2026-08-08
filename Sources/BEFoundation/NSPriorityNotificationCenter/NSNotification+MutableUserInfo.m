/*!
 @file			NSNotification+MutableUserInfo.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Adds the ability to get the NSNotification userInfo as a NSMutableDictionary
 @discussion	This returns the userInfo of a NSNotification as a NSMutableDictionary if and only if
				it is an NSMutableDictionary.
*/

#import "NSNotification+MutableUserInfo.h"

@implementation NSNotification (MutableUserInfo)

/*!
 @method		mutableUserInfo
 @abstract		Returns userInfo as an NSMutableDictionary if it is one.
 @result		The userInfo as NSMutableDictionary, or nil if not mutable.
 */
- (NSMutableDictionary *)mutableUserInfo
{
	if ([self.userInfo isKindOfClass:NSMutableDictionary.class]) {
		return (NSMutableDictionary *)self.userInfo;
	}
	return nil;
}

@end
