/*!
 @file			BESingleton.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/

#import <objc/runtime.h>
#import "BESingleton.h"
#import "NSDictionary+BExtension.h"

@implementation NSObject (BESingleton)

/*!
	@property   isSingleton
	@abstract   Determines if the object is a singleton implementation
	@discussion	This is checked by @c __NSSingleton to ensure that it can do singleton things
	@result     The method returns NO by default unless the subclass override returns YES.
 */
+ (BOOL)isSingleton
{
	return NO;
}

+ (NSDictionary*)singletonInitInfo
{
	NSMutableDictionary *initInfo = nil;
	
	if ([self conformsToProtocol:@protocol(BESingleton)] && self.isSingleton) {
		Class singletonChain = self;
		do {
			NSDictionary *instanceInfo = objc_getAssociatedObject(singletonChain, @selector(singletonInitInfo));
			singletonChain = singletonChain.superclass;
			if (instanceInfo) {
				if (![instanceInfo isKindOfClass:NSDictionary.class]) {
					return instanceInfo;
				}
				if(!initInfo) {
					initInfo = [NSMutableDictionary dictionaryWithDictionary:instanceInfo];
				} else {
					[initInfo mergeEntriesFromDictionary:instanceInfo];
				}
			}
		} while([singletonChain conformsToProtocol:@protocol(BESingleton)] && ![singletonChain isMemberOfClass:NSObject.class]);
	}
	return initInfo;
}

+ (void)setSingletonInitInfo:(NSDictionary*)info
{
	// Only execute this code if the class actually conforms to BESingleton
	if (![self conformsToProtocol:@protocol(BESingleton)] || !self.isSingleton) {
		return;
	}
	if (!info) {
		objc_setAssociatedObject(self, @selector(singletonInitInfo), nil, OBJC_ASSOCIATION_ASSIGN);
		return;
	}
	
	id<BESingleton> singletonInstance = objc_getAssociatedObject(self, @selector(__BESingleton));
	
	// If already instanced, skip the set
	if (singletonInstance) {
		return;
	}
	
	objc_setAssociatedObject(self, @selector(singletonInitInfo), info, OBJC_ASSOCIATION_RETAIN);
	
}

 
/*!
	@method		@c __BESingleton
	@abstract   Provides the main backing function for @c BESingleton protocol.
	@discussion	This constructs a self object with @c -init  or with @c -initForSingleton: if
				optionally available.  This method is thread safe.  The BESingleton protocol must be
				implemented and @c -isSingleton return YES for this method to work.
	@result     Returns the instance type of the implementing class.
 */

+ (instancetype)__BESingleton NS_RETURNS_RETAINED
{
	// Only execute this code if the class actually conforms to BESingleton
	if (![self conformsToProtocol:@protocol(BESingleton)] || ![self isSingleton]) {
		return nil;
	}
	
	// First, try to retrieve the singleton instance (no need for synchronization yet)
	id<BESingleton> singletonInstance = objc_getAssociatedObject(self, @selector(__BESingleton));

	// If the singleton is not found, synchronize to ensure only one thread creates it
	if (!singletonInstance) {
		@synchronized (self) {
			// Check again inside the synchronized block (to handle the case where another thread created it)
			singletonInstance = objc_getAssociatedObject(self, @selector(__BESingleton));

			// If still not found, create the singleton instance
			if (!singletonInstance) {
				// Check if the class implements the initForSingleton: method (optional in the protocol)
				if ([self instancesRespondToSelector:@selector(initForSingleton:)]) {
					singletonInstance = [self.alloc initForSingleton:self.singletonInitInfo];
				} else {
					singletonInstance = [self.alloc init]; // Fallback to regular init if initForSingleton is not implemented
				}
				
#if !__has_feature(objc_arc)
				[[singletonInstance retain] autorelease];
 #endif
				
				// children can set the parent class singleton
				Class singletonChain = self;
				id<BESingleton> singletonChainInstance = singletonInstance;
				do {
					id<BESingleton> chainInstance = objc_getAssociatedObject(singletonChain, @selector(__BESingleton));
					if(chainInstance) {
						singletonChainInstance = chainInstance;
					} else {
						objc_setAssociatedObject(singletonChain, @selector(__BESingleton), singletonChainInstance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);  // <- already made "atomic" by @synchronized.
					}
					singletonChain = singletonChain.superclass;
				} while([singletonChain conformsToProtocol:@protocol(BESingleton)] && ![singletonChain isMemberOfClass:NSObject.class]);
				
				if (singletonInstance) {
					__weak Class _weakSelf = self;
					void (^cleanupBlock)(void) = ^{
						__strong Class _self = _weakSelf;
						if (_self) {
							@synchronized(_self) {
								Class singletonChain = _self;
								do {
									objc_setAssociatedObject(singletonChain, @selector(__BESingleton), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);  // <- already made "atomic" by @synchronized.
									singletonChain = singletonChain.superclass;
								} while([singletonChain conformsToProtocol:@protocol(BESingleton)] && ![singletonChain isMemberOfClass:NSObject.class]);
							}
						}
					};
					
					atexit_b(cleanupBlock);
				}
			}
		}
	}

	return (id)singletonInstance;
}

@end

