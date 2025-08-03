/*!
 @file			NSPooledPriorityNotification.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Internal implementation when NSPriorityNotificationCenter has an observer
				using a different queue.
 @discussion	Observers on different queues use NSPooledPriorityNotification
				instead of the supplied NSNotification. These instances are pooled and enable proper
				concurrency for posting notifications in NSPriorityNotificationCenter.
*/

#import <BE_ARC.h>

#import <objc/runtime.h>
#import <Foundation/NSNotification.h>
#import "NSPooledPriorityNotification.h"
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSSet.h>

#pragma mark -
#pragma mark NSPooledPriorityNotification

/*!
 @implementation NSPooledPriorityNotification
 @abstract		Implementation of the pooled priority notification class.
 @discussion	This implementation provides notification pooling for observers that use queue.
 */
@implementation NSPooledPriorityNotification

// The pool of NSPooledPriorityNotification
static NSMutableSet *notificationPool = nil;

/*!
 @method		newTempNotificationWithName:object:userInfo:reverse:
 @abstract		Pulls an unused NSPooledPriorityNotification from the pool or creates a new instance.
 @param			name The name of the notification.
 @param			anObject The object of the notification.
 @param			aUserInfo The userInfo of the notification.
 @param			reverse Whether or not the notification operates in reverse.
 @discussion	When NSPriorityNotificationCenter sends a notification to an observer on
				a specific queue, this class contains the information of the NSNotification or
				subclass.
 @result		Returns a NSPooledPriorityNotification containing a NSNotification.
 */
+ (nonnull id)newTempNotificationWithName:(nullable NSString *)name
								   object:(nullable id)anObject
								 userInfo:(nullable NSDictionary *)aUserInfo
								  reverse:(BOOL)reverse
{
	static dispatch_once_t once = 0L;
	dispatch_once(&once, ^{
		notificationPool = [[NSMutableSet alloc] init];
	});

	NSPooledPriorityNotification *notif = nil;
	@synchronized(notificationPool) {
		notif = NARC_RETAIN([notificationPool anyObject]);
		if (notif) {
			[notificationPool removeObject:notif];
			notif = [notif initWithName:name object:anObject userInfo:aUserInfo reverse:reverse];
		}

		if (notif == nil) {
			notif = [NSPooledPriorityNotification.alloc initWithName:name object:anObject userInfo:aUserInfo reverse:reverse];
		}
	}
	return notif;
}

/*!
 @method		recycle
 @abstract		Returns the NSPooledPriorityNotification to the pool.
 @discussion	This must be called after a queue based notification observer.
 */
- (void)recycle
{
	@synchronized(notificationPool) {
		[notificationPool addObject:self];
		NARC_RELEASE(_name);
		NARC_RELEASE(_object);
		NARC_RELEASE(_userInfo);

		NARC_RELEASE_RAW(self);
	}
}

/*!
 @method		description
 @abstract		Returns the loggable information of the instance, mainly for debugging.
 @result		Returns the NSString containing the description of the current object.
 */
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ {name: %@, object: %@, userInfo: %@, reverse:%@}",
			[super description], _name, _object, _userInfo, @(_reverse)];
}

/*!
 @method		unusedNotificationCount
 @abstract		Returns the size of the notification pool.
 @result		Returns the count of unused notifications in the pool.
 */
+ (NSUInteger)unusedNotificationCount
{
	@synchronized(notificationPool) {
		return notificationPool.count;
	}
}

/*!
 @method		clearNotificationPool
 @abstract		Resets the Notification Pool of unused temporary Notifications.
 */
+ (void)clearNotificationPool
{
	if (notificationPool) {
		@synchronized(notificationPool) {
			[notificationPool removeAllObjects];
		}
	}
}

@end
