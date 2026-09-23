/*!
 @file			BESingleton.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Backing implementation of the NSObject(BESingleton) class-singleton category.
 @discussion	Stores the shared instance and its init info as associated objects on the class,
				creates it lazily under double-checked locking, and propagates it to BESingleton-
				conforming ancestors so a subclass and its superclasses share one instance.
*/

#import <objc/runtime.h>
#import "BESingleton.h"
#import "NSDictionary+BExtension.h"

@implementation NSObject (BESingleton)

/*!
	@property   isSingleton
	@abstract   Determines if the object is a singleton implementation
	@discussion	@c __BESingleton checks this before it creates or returns the shared instance.
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
	if (![self conformsToProtocol:@protocol(BESingleton)] || !self.isSingleton) {
		return;
	}
	if (!info) {
		objc_setAssociatedObject(self, @selector(singletonInitInfo), nil, OBJC_ASSOCIATION_ASSIGN);
		return;
	}
	
	id<BESingleton> singletonInstance = objc_getAssociatedObject(self, @selector(__BESingleton));
	
	if (singletonInstance) {
		return;
	}
	
	objc_setAssociatedObject(self, @selector(singletonInitInfo), info, OBJC_ASSOCIATION_RETAIN);
	
}

 
/*!
 * @abstract  Returns the topmost ancestor of @p cls that still conforms to BESingleton.
 *
 * @discussion
 *   Creating a singleton propagates the instance up the whole conforming chain, so the
 *   creation must exclude every class in that chain.  Locking on @c self locks one class
 *   only: a thread on a subclass and a thread on its superclass hold different tokens and
 *   both pass their nil checks, so each installs a different instance and the chain ends
 *   up inconsistent.  Every class in one chain resolves to the same root here, and
 *   separate chains keep separate tokens.  The walk matches the propagation loop below.
 */
static Class BESingletonChainRoot(Class cls)
{
	Class root = cls;
	Class next = [root superclass];
	while (next && [next conformsToProtocol:@protocol(BESingleton)]
		   && ![next isMemberOfClass:NSObject.class]) {
		root = next;
		next = [root superclass];
	}
	return root;
}

/*!
	@method		__BESingleton
	@abstract   Provides the main backing function for @c BESingleton protocol.
	@discussion	This constructs a self object with @c -init  or with @c -initForSingleton: if
				optionally available.  This method is thread safe.  The BESingleton protocol must be
				implemented and @c -isSingleton return YES for this method to work.
	@result     The shared instance, or nil when the receiver is not a singleton.
 */
+ (instancetype)__BESingleton NS_RETURNS_RETAINED
{
	if (![self conformsToProtocol:@protocol(BESingleton)] || ![self isSingleton]) {
		return nil;
	}
	
	id<BESingleton> singletonInstance = objc_getAssociatedObject(self, @selector(__BESingleton));

	if (!singletonInstance) {
		@synchronized (BESingletonChainRoot(self)) {
			singletonInstance = objc_getAssociatedObject(self, @selector(__BESingleton));

			if (!singletonInstance) {
				if ([self instancesRespondToSelector:@selector(initForSingleton:)]) {
					singletonInstance = [self.alloc initForSingleton:self.singletonInitInfo];
				} else {
					singletonInstance = [self.alloc init];
				}
				
#if !__has_feature(objc_arc)
				[[singletonInstance retain] autorelease];
 #endif
				
				// Install the instance on every conforming ancestor that has none.
				Class singletonChain = self;
				id<BESingleton> singletonChainInstance = singletonInstance;
				do {
					id<BESingleton> chainInstance = objc_getAssociatedObject(singletonChain, @selector(__BESingleton));
					if(chainInstance) {
						singletonChainInstance = chainInstance;
					} else {
						objc_setAssociatedObject(singletonChain, @selector(__BESingleton), singletonChainInstance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);  // @synchronized serializes this store, so nonatomic is safe.
					}
					singletonChain = singletonChain.superclass;
				} while([singletonChain conformsToProtocol:@protocol(BESingleton)] && ![singletonChain isMemberOfClass:NSObject.class]);
				
				if (singletonInstance) {
					__weak Class _weakSelf = self;
					void (^cleanupBlock)(void) = ^{
						__strong Class _self = _weakSelf;
						if (_self) {
							@synchronized(BESingletonChainRoot(_self)) {
								Class singletonChain = _self;
								do {
									objc_setAssociatedObject(singletonChain, @selector(__BESingleton), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);  // @synchronized serializes this store, so nonatomic is safe.
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

