/*!
 @header		NSPooledPriorityNotification.h
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Internal implementation when NSPriorityNotificationCenter has an observer
				using a different queue. This is a Project Only Class for Functional Implementation.
 @discussion	Observers on different queues use NSPooledPriorityNotification
				instead of the supplied NSNotification. These instances are pooled and enable proper
				concurrency for posting notifications in NSPriorityNotificationCenter.
*/

#ifndef NSPooledPriorityNotification_h
#define NSPooledPriorityNotification_h

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "NSPriorityNotification.h"

/*!
 @class			NSPooledPriorityNotification
 @abstract		Internal class for processing Notifications in queues.
 @discussion	This pools notifications for observers that use queue. This is to ensure that a notification
				is processed concurrently properly. newTempNotificationWithName should be
				used to get a NSPooledPriorityNotification from the internal pool.
 @superclass	NSPriorityNotification
 */
@interface NSPooledPriorityNotification : NSPriorityNotification

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
								  reverse:(BOOL)reverse;

/*!
 @method		recycle
 @abstract		Returns the NSPooledPriorityNotification to the pool.
 @discussion	This must be called after a queue based notification observer.
 */
- (void)recycle;

/*!
 @method		description
 @abstract		Returns the loggable information of the instance, mainly for debugging.
 @result		Returns the NSString containing the description of the current object.
 */
- (nonnull NSString *)description;

/*!
 @method		unusedNotificationCount
 @abstract		Returns the size of the notification pool.
 @result		Returns the count of unused notifications in the pool.
 */
+ (NSUInteger)unusedNotificationCount;

/*!
 @method		clearNotificationPool
 @abstract		Resets the Notification Pool of unused temporary Notifications.
 */
+ (void)clearNotificationPool;

@end

#endif
