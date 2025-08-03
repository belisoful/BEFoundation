/*!
 @file			NSPriorityNotification.m
 @copyright		© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com 
 @abstract		Implementation of NSPriorityNotification class and NSNotification priority extensions.
 @discussion	This file implements the NSPriorityNotification class which extends NSNotification
				with priority-based processing capabilities including reverse ordering and
				post-processing blocks. It also provides compatibility extensions for standard
				NSNotification objects to work with the priority notification system.
*/

#import <BE_ARC.h>

#import <objc/runtime.h>
#import <Foundation/NSNotification.h>
#import "NSPriorityNotification.h"
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import "NSObject+GlobalRegistry.h"

#pragma mark - NSPriorityNotification Implementation

@implementation NSPriorityNotification

@synthesize name = _name;
@synthesize object = _object;
@synthesize userInfo = _userInfo;
@synthesize reverse = _reverse;
@synthesize postBlock = _postBlock;

/*!
 @const			NSReverseKey
 @abstract		Key used for storing reverse flag in user info dictionary during legacy operations.
 @discussion	This constant is reserved for potential future use in storing the reverse
				flag within the notification's userInfo dictionary for compatibility purposes.
 */
static NSString * const NSReverseKey = @"NSPriorityNotification.reverse";

#pragma mark - Class Factory Methods

/*!
 @method		notificationWithName:object:
 @abstract		Creates a new priority notification with basic parameters.
 @param			aName		The notification name. Must not be nil.
 @param			anObject	The associated object. May be nil.
 @return		A new NSPriorityNotification instance.
 @discussion	This method creates a notification with default settings:
				- No user info dictionary
				- Reverse processing disabled
				- No post-processing block
 */
+ (instancetype)notificationWithName:(NSNotificationName)aName object:(nullable id)anObject
{
	return [self notificationWithName:aName object:anObject userInfo:nil reverse:NO postBlock:nil];
}

/*!
 @method		notificationWithName:object:userInfo:
 @abstract		Creates a new priority notification with user info.
 @param			aName		The notification name. Must not be nil.
 @param			anObject	The associated object. May be nil.
 @param			userInfo	Additional data dictionary. May be nil.
 @return		A new NSPriorityNotification instance.
 @discussion	This method creates a notification with user information but default
				processing settings (no reverse processing, no post-processing block).
 */
+ (instancetype)notificationWithName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)userInfo
{
	return [self notificationWithName:aName object:anObject userInfo:userInfo reverse:NO postBlock:nil];
}

/*!
 @method		notificationWithName:object:postBlock:
 @abstract		Creates a new priority notification with a post-processing block.
 @param			aName		The notification name. Must not be nil.
 @param			anObject	The associated object. May be nil.
 @param			postBlock	Block to execute after each observer. May be nil.
 @return		A new NSPriorityNotification instance.
 @discussion	The post-processing block is called after each observer handles the notification.
				This is useful for logging, debugging, or cleanup operations.
 */
+ (instancetype)notificationWithName:(NSNotificationName)aName object:(nullable id)anObject postBlock:(void (NS_SWIFT_SENDABLE ^_Nullable)(NSNotification *notification))postBlock
{
	return [self notificationWithName:aName object:anObject userInfo:nil reverse:NO postBlock:postBlock];
}

/*!
 @method		notificationWithName:object:userInfo:postBlock:
 @abstract		Creates a new priority notification with user info and post-processing block.
 @param			aName		The notification name. Must not be nil.
 @param			anObject	The associated object. May be nil.
 @param			userInfo	Additional data dictionary. May be nil.
 @param			postBlock	Block to execute after each observer. May be nil.
 @return		A new NSPriorityNotification instance.
 @discussion	This method combines user information with post-processing capabilities
				while using normal (non-reverse) observer processing order.
 */
+ (instancetype)notificationWithName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)userInfo postBlock:(void (NS_SWIFT_SENDABLE ^_Nullable)(NSNotification *notification))postBlock
{
	return [self notificationWithName:aName object:anObject userInfo:userInfo reverse:NO postBlock:postBlock];
}

/*!
 @method		notificationWithName:object:reverse:
 @abstract		Creates a new priority notification with reverse processing.
 @param			aName		The notification name. Must not be nil.
 @param			anObject	The associated object. May be nil.
 @param			reverse		Whether to process observers in reverse order.
 @return		A new NSPriorityNotification instance.
 @discussion	When reverse is YES, observers are processed in LIFO (last-in-first-out) order,
				which can be useful for implementing cascading cancellation or override patterns.
 */
+ (instancetype)notificationWithName:(NSNotificationName)aName object:(nullable id)anObject reverse:(BOOL)reverse
{
	return [self notificationWithName:aName object:anObject userInfo:nil reverse:reverse postBlock:nil];
}

/*!
 @method		notificationWithName:object:userInfo:reverse:
 @abstract		Creates a new priority notification with user info and reverse processing.
 @param			aName		The notification name. Must not be nil.
 @param			anObject	The associated object. May be nil.
 @param			userInfo	Additional data dictionary. May be nil.
 @param			reverse		Whether to process observers in reverse order.
 @return		A new NSPriorityNotification instance.
 @discussion	This method combines user information with reverse processing capabilities,
				allowing for complex notification handling patterns.
 */
+ (instancetype)notificationWithName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)userInfo reverse:(BOOL)reverse
{
	return [self notificationWithName:aName object:anObject userInfo:userInfo reverse:reverse postBlock:nil];
}

/*!
 @method		notificationWithName:object:reverse:postBlock:
 @abstract		Creates a new priority notification with reverse processing and post-processing block.
 @param			aName		The notification name. Must not be nil.
 @param			anObject	The associated object. May be nil.
 @param			reverse		Whether to process observers in reverse order.
 @param			postBlock	Block to execute after each observer. May be nil.
 @return		A new NSPriorityNotification instance.
 @discussion	This method combines reverse processing with post-processing capabilities.
				The post block executes after each observer regardless of processing order.
 */
+ (instancetype)notificationWithName:(NSNotificationName)aName object:(nullable id)anObject reverse:(BOOL)reverse postBlock:(void (NS_SWIFT_SENDABLE ^_Nullable)(NSNotification *notification))postBlock
{
	return [self notificationWithName:aName object:anObject userInfo:nil reverse:reverse postBlock:postBlock];
}

/*!
 @method		notificationWithName:object:userInfo:reverse:postBlock:
 @abstract		Creates a new priority notification with full configuration options.
 @param			aName		The notification name. Must not be nil.
 @param			anObject	The associated object. May be nil.
 @param			userInfo	Additional data dictionary. May be nil.
 @param			reverse		Whether to process observers in reverse order.
 @param			postBlock	Block to execute after each observer. May be nil.
 @return		A new NSPriorityNotification instance.
 @discussion	This is the master factory method that all other factory methods delegate to.
				It provides access to all NSPriorityNotification features in a single call.
 */
+ (instancetype)notificationWithName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)userInfo reverse:(BOOL)reverse postBlock:(void (NS_SWIFT_SENDABLE ^_Nullable)(NSNotification *notification))postBlock
{
	// All class factory methods delegate to this implementation
	return [self.alloc initWithName:aName object:anObject userInfo:userInfo reverse:reverse postBlock:postBlock];
}

#pragma mark - Initialization Methods

/*!
 @method		initWithName:object:userInfo:
 @abstract		Initializes a priority notification with basic parameters.
 @param			name		The notification name. Must not be nil.
 @param			object		The associated object. May be nil.
 @param			userInfo	Additional data dictionary. May be nil.
 @return		An initialized NSPriorityNotification instance.
 @discussion	This designated initializer creates a notification with:
				- The specified name, object, and user info
				- Reverse processing disabled
				- No post-processing block
 */
- (instancetype)initWithName:(NSNotificationName)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo
{
	if (self) {
		_name = name;
		_object = object;
		_userInfo = userInfo;
		_reverse = NO;
		_postBlock = NULL;
	}
	return self;
}

/*!
 @method		initWithName:object:userInfo:reverse:
 @abstract		Initializes a priority notification with reverse processing option.
 @param			name		The notification name. Must not be nil.
 @param			object		The associated object. May be nil.
 @param			userInfo	Additional data dictionary. May be nil.
 @param			reverse		Whether to process observers in reverse order.
 @return		An initialized NSPriorityNotification instance.
 @discussion	This designated initializer allows control over observer processing order.
				When reverse is YES, observers are called in reverse registration order.
 */
- (instancetype)initWithName:(NSNotificationName)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo reverse:(BOOL)reverse
{
	if (self) {
		_name = name;
		_object = object;
		_userInfo = userInfo;
		_reverse = reverse;
		_postBlock = NULL;
	}
	return self;
}

/*!
 @method		initWithName:object:userInfo:postBlock:
 @abstract		Initializes a priority notification with a post-processing block.
 @param			name		The notification name. Must not be nil.
 @param			object		The associated object. May be nil.
 @param			userInfo	Additional data dictionary. May be nil.
 @param			postBlock	Block to execute after each observer. Must not be nil.
 @return		An initialized NSPriorityNotification instance.
 @discussion	This designated initializer sets up post-processing capabilities.
				The block is copied using BLOCK_COPY for proper memory management.
 */
- (instancetype)initWithName:(NSNotificationName)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo postBlock:(void (NS_SWIFT_SENDABLE ^)(NSNotification *notification))postBlock
{
	if (self) {
		_name = name;
		_object = object;
		_userInfo = userInfo;
		_reverse = NO;
		if(postBlock) {
			_postBlock = BLOCK_COPY(postBlock);
		}
	}
	return self;
}

/*!
 @method		initWithName:object:userInfo:reverse:postBlock:
 @abstract		Initializes a priority notification with full configuration options.
 @param			name		The notification name. Must not be nil.
 @param			object		The associated object. May be nil.
 @param			userInfo	Additional data dictionary. May be nil.
 @param			reverse		Whether to process observers in reverse order.
 @param			postBlock	Block to execute after each observer. Must not be nil.
 @return		An initialized NSPriorityNotification instance.
 @discussion	This is the master designated initializer that provides access to all
				NSPriorityNotification features. The block is copied for proper memory management.
 */
- (instancetype)initWithName:(NSNotificationName)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo reverse:(BOOL)reverse postBlock:(void (NS_SWIFT_SENDABLE ^)(NSNotification *notification))postBlock
{
	if (self) {
		_name = name;
		_object = object;
		_userInfo = userInfo;
		_reverse = reverse;
		if(postBlock) {
			_postBlock = BLOCK_COPY(postBlock);
		}
	}
	return self;
}

#pragma mark - NSSecureCoding Protocol

/*!
 @method		supportsSecureCoding
 @abstract		Indicates support for secure coding.
 @return		YES, confirming NSPriorityNotification supports secure coding.
 @discussion	NSPriorityNotification fully implements NSSecureCoding to ensure safe
				archiving and unarchiving operations. Objects conforming to GlobalRegistryProtocol
				are handled specially to maintain object identity across coding operations.
 */
+ (BOOL)supportsSecureCoding
{
	return YES;
}

/*!
 @method		initWithCoder:
 @abstract		Initializes a notification by decoding from an archive.
 @param			aDecoder	The decoder containing archived notification data.
 @return		An initialized NSPriorityNotification instance, or nil if decoding fails.
 @discussion	This method supports both keyed and non-keyed coding formats:
 
				**Keyed Coding:**
				- Decodes name, userInfo, and reverse flag using specific keys
				- Handles GlobalRegistryProtocol objects via UUID lookup
				
				**Non-Keyed Coding:**
				- Decodes objects in sequence: name, registry flag, UUID (if applicable), userInfo, reverse
				- Maintains backward compatibility with older archive formats
				
				**Global Registry Handling:**
				Objects conforming to GlobalRegistryProtocol are restored using their global
				registry UUID rather than direct object archiving, ensuring object identity
				is preserved across coding operations.
				
				**Post-Processing Blocks:**
				Blocks are not archived for security reasons and will be NULL after decoding.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self) {
		if ([aDecoder allowsKeyedCoding]) {
			// Keyed coding path - more robust and preferred
			_name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
			
			// Handle GlobalRegistryProtocol objects
			NSString *uuid = [aDecoder decodeObjectForKey:@"ObjectGlobalRegistryUUID"];
			if (uuid) {
				_object = [NSObject.globalRegistry registeredObjectForUUID:uuid];
			}
			
			_userInfo = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:@"userInfo"];
			_reverse = [aDecoder decodeBoolForKey:@"reverse"];
		} else {
			// Non-keyed coding path - for backward compatibility
			_name = [aDecoder decodeObject];
			
			// Check if object uses GlobalRegistryProtocol
			NSNumber *hasGlobalRegistry = [aDecoder decodeObject];
			if (hasGlobalRegistry.boolValue) {
				NSString *uuid = [aDecoder decodeObject];
				if (uuid) {
					_object = [NSObject.globalRegistry registeredObjectForUUID:uuid];
				}
			}
			
			_userInfo = [aDecoder decodeObject];
			_reverse = ((NSNumber*)[aDecoder decodeObject]).boolValue;
		}
		
		// Post-processing blocks are not archived for security reasons
		_postBlock = NULL;
	}
	return self;
}

/*!
 @method		encodeWithCoder:
 @abstract		Encodes the notification to an archive.
 @param			aCoder		The encoder to write notification data to.
 @discussion	This method supports both keyed and non-keyed coding formats:
 
				**Keyed Coding:**
				- Encodes name, userInfo, and reverse flag with specific keys
				- Handles GlobalRegistryProtocol objects by encoding their UUID
				
				**Non-Keyed Coding:**
				- Encodes objects in sequence for backward compatibility
				- Includes registry flag to indicate GlobalRegistryProtocol usage
				
				**Global Registry Handling:**
				Objects conforming to GlobalRegistryProtocol are automatically registered
				globally if not already registered, then their UUID is encoded instead of
				the object itself. This ensures object identity is preserved across
				coding operations.
				
				**Post-Processing Blocks:**
				Blocks are intentionally not encoded for security reasons. They cannot
				be safely archived and restored across process boundaries.
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if ([aCoder allowsKeyedCoding]) {
		// Keyed coding path - more robust and preferred
		[aCoder encodeObject:self.name forKey:@"name"];
		
		// Handle GlobalRegistryProtocol objects
		if ([self.object conformsToProtocol:@protocol(BERegistryProtocol)]) {
			if (![self.object isGlobalRegistered]) {
				[self.object registerGlobalInstance];
			}
			NSString *uuid = [self.object globalRegistryUUID];
			if (uuid) {
				[aCoder encodeObject:uuid forKey:@"ObjectGlobalRegistryUUID"];
			}
		}
		
		[aCoder encodeObject:self.userInfo forKey:@"userInfo"];
		[aCoder encodeBool:self.reverse forKey:@"reverse"];
	} else {
		// Non-keyed coding path - for backward compatibility
		[aCoder encodeObject:self.name];
		
		// Handle GlobalRegistryProtocol objects
		if ([self.object conformsToProtocol:@protocol(BERegistryProtocol)]) {
			if (![self.object isGlobalRegistered]) {
				[self.object registerGlobalInstance];
			}
			NSString *uuid = [self.object globalRegistryUUID];
			[aCoder encodeObject:@(uuid != nil)];
			if (uuid) {
				[aCoder encodeObject:uuid];
			}
		} else {
			[aCoder encodeObject:@NO];
		}
		
		[aCoder encodeObject:self.userInfo];
		[aCoder encodeObject:@(self.reverse)];
	}
	
	// Post-processing blocks are intentionally not encoded for security reasons
}

/*!
 @method		classForCoder
 @abstract		Returns the class to use for non-keyed archiving.
 @return		The NSPriorityNotification class.
 @discussion	This method ensures that the correct class is used when archiving
				with non-keyed archivers, maintaining proper class identity.
 */
- (Class)classForCoder
{
	return self.class;
}

/*!
 @method		classForKeyedArchiver
 @abstract		Returns the class to use for keyed archiving.
 @return		The NSPriorityNotification class.
 @discussion	This method ensures that the correct class is used when archiving
				with keyed archivers, maintaining proper class identity.
 */
- (Class)classForKeyedArchiver
{
	return self.class;
}

#pragma mark - Memory Management

/*!
 @method		dealloc
 @abstract		Cleanup method called when the notification is deallocated.
 @discussion	This method ensures proper cleanup of the post-processing block
				using BLOCK_RELEASE to prevent memory leaks. The method uses
				conditional compilation to support both ARC and non-ARC environments.
 */
- (void)dealloc
{
	if (_postBlock) {
		BLOCK_RELEASE(_postBlock);
	}
	SUPER_DEALLOC();
}

@end

#pragma mark - NSNotification Priority Extension

/*!
 @category		NSNotification(PriorityExtension)
 @abstract		Extends NSNotification for compatibility with NSPriorityNotificationCenter.
 @discussion	This category provides compatibility methods that allow standard NSNotification
				objects to work seamlessly with the priority notification system. The methods
				ensure that NSNotification instances can be processed by NSPriorityNotificationCenter
				while maintaining their standard behavior.
 */
@implementation NSNotification (PriorityExtension)

/*!
 @method		reverse
 @abstract		Returns the reverse processing flag for NSNotification.
 @return		Always returns NO for standard NSNotification objects.
 @discussion	Standard NSNotification objects do not support reverse processing.
				This method provides compatibility with NSPriorityNotification's reverse
				property, allowing polymorphic usage in the priority notification system.
 */
- (BOOL)reverse
{
	return NO;
}

/*!
 @method		postBlock
 @abstract		Returns the post-processing block for NSNotification.
 @return		Always returns NULL for standard NSNotification objects.
 @discussion	Standard NSNotification objects do not support post-processing blocks.
				This method provides compatibility with NSPriorityNotification's postBlock
				property, allowing polymorphic usage in the priority notification system.
 */
- (void (^ _Nullable)(NSNotification * _Nonnull note))postBlock
{
	return NULL;
}

/*!
 @method		isPriorityPost
 @abstract		Determines if the notification has been processed by NSPriorityNotificationCenter.
 @return		YES if the notification has been processed by the priority system, NO otherwise.
 @discussion	This property is used internally by NSPriorityNotificationCenter to prevent
				infinite loops when observing the system NSNotificationCenter. The implementation
				uses associated objects to store the flag without modifying the original
				NSNotification structure.
				
				**Usage Pattern:**
				1. NSPriorityNotificationCenter observes system NSNotificationCenter
				2. When a notification is posted to the system center, it's detected
				3. The priority center sets isPriorityPost to YES before reposting
				4. The flag prevents the notification from being processed again
				
				**Default Value:**
				Returns NO for notifications that haven't been processed by the priority system.
 */
- (BOOL)isPriorityPost
{
	NSNumber *isPriorityPost = objc_getAssociatedObject(self, @selector(isPriorityPost));
	if (!isPriorityPost) {
		return NO;
	}
	return isPriorityPost.boolValue;
}

/*!
 @method		setIsPriorityPost:
 @abstract		Sets whether the notification has been processed by NSPriorityNotificationCenter.
 @param			isPriorityPost	YES to mark as processed by priority system, NO to clear the flag.
 @discussion	This method is used internally by NSPriorityNotificationCenter to track
				processing state. The implementation uses associated objects with retain
				semantics to store the flag.
				
				**Implementation Details:**
				- Uses OBJC_ASSOCIATION_RETAIN for proper memory management
				- Stores nil when isPriorityPost is NO to minimize memory usage
				- Uses the selector as the key for associated object storage
				
				**Automatic Management:**
				This property is automatically managed by NSPriorityNotificationCenter.
				Manual manipulation is rarely necessary and should be done with caution.
 */
- (void)setIsPriorityPost:(BOOL)isPriorityPost
{
	NSNumber *value = nil;
	if (isPriorityPost) {
		value = @(isPriorityPost);
	}
	objc_setAssociatedObject(self, @selector(isPriorityPost), value, OBJC_ASSOCIATION_RETAIN);
}

@end
