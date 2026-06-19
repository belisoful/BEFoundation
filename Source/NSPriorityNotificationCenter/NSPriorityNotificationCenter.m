/*!
 @file			NSPriorityNotificationCenter.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/

#import "BE_ARC.h"

#import <Foundation/Foundation.h>
#import "NSPriorityNotificationCenter.h"
#import "NSPooledPriorityNotification.h"
#import <dispatch/dispatch.h>
#import <pthread.h>

#pragma mark -
#pragma mark Internal: Interface NSPriorityNotificationObserver


NSInteger const NSPriorityNotificationDefaultPriority = 10;

// Internal Object
@interface _NSPriorityNotificationObserver : NSObject

// Weak, matching NSNotificationCenter: the center must not keep its observers alive.
// It also breaks the self-cycle through _superPostNotification (observer == the center).
@property (nonatomic, readonly, weak) id observer;
@property (nonatomic, readonly) SEL selector;
@property (nonatomic, readonly) NSString *name;
// Weak, matching NSNotificationCenter: the object is a filter, not owned by the center.
@property (nonatomic, readonly, weak) id object;
// Captured at registration so a deallocated object filter (weak object now nil) is not
// mistaken for "registered for all objects".
@property (nonatomic, readonly) BOOL observesAllObjects;
@property (nonatomic, readonly) NSOperationQueue *queue;
@property (nonatomic, readonly) void (^block)(NSNotification *note);
@property (nonatomic, readonly) NSInteger ncPriority;

- (id)initWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object queue:(NSOperationQueue *)queue block:(void (^)(NSNotification *note))block priority:(NSInteger)priority;
@end


#pragma mark -
#pragma mark Internal: Implementation NSPriorityNotificationObserver

@implementation _NSPriorityNotificationObserver

@synthesize ncPriority = _ncPriority;

- (id)initWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object queue:(NSOperationQueue *)queue block:(void (^)(NSNotification *note))block priority:(NSInteger)priority
{
	self = [super init];
	if (self)
	{
		_observer = observer;
		_selector = selector;
		_name = [name copy];
		_object = object;
		_observesAllObjects = (object == nil);
		_queue = NARC_RETAIN(queue);
		_block = BLOCK_COPY(block);
		_ncPriority = priority;
		// For objects conforming to NSNotificationObjectPriorityItem, ncPriority is the offset
	}
	return self;
}

- (void)dealloc
{
	NARC_RELEASE(_name);
	NARC_RELEASE(_queue);
	BLOCK_RELEASE(_block);
	
	SUPER_DEALLOC();
}

- (NSInteger)ncPriority
{
	if ([_observer conformsToProtocol:@protocol(NSNotificationObjectPriorityItem)]) {
		//
		return [((id<NSNotificationObjectPriorityItem>)_observer) ncPriority:_name] + _ncPriority;
	} else {
		return _ncPriority;
	}
}

- (void)postNotification:(NSNotification *)notif
{
	void (^ postBlock)(NSNotification * _Nonnull note) = notif.postBlock;
	if (_queue != nil && _block != NULL)
	{
		// Queued observers run after this post returns, by which point a pooled source
		// notification may have been recycled. Async observers receive a stable copy decoupled
		// from the pool. The copy preserves name, object, and userInfo (userInfo is shared by
		// reference), so an async observer differs from a synchronous one only in the
		// notification's wrapper identity.
		NSPooledPriorityNotification *notifCopy = [NSPooledPriorityNotification newTempNotificationWithName:notif.name object:notif.object userInfo:notif.userInfo reverse:notif.reverse];
		[_queue addOperationWithBlock:^{
			if (notifCopy.userInfo) {
				@synchronized (notifCopy.userInfo) {
					self->_block(notifCopy);
					if (postBlock) {
						postBlock(notifCopy);
					}
				}
			} else {
				self->_block(notifCopy);
				if (postBlock) {
					postBlock(notifCopy);
				}
			}
			[notifCopy recycle];
		}];
	}
	else if (_block != NULL)
	{
		if(notif.userInfo) {
			@synchronized (notif.userInfo) {
				_block(notif);
				if (postBlock) {
					postBlock(notif);
				}
			}
		} else {
			_block(notif);
			if (postBlock) {
				postBlock(notif);
			}
		}
	}
	else if (_observer != nil && _selector != NULL)
	{
		NSMethodSignature *signature = [_observer methodSignatureForSelector:_selector];

		if (signature) {
			// Create an NSInvocation instance
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			
			// Set the selector and target for the invocation
			[invocation setSelector:_selector];
			[invocation setTarget:_observer];
			
			// Set the parameter (notif) if the method expects one argument
			if (_queue == nil) {
				if ([signature numberOfArguments] > 2) {  // Arguments start at index 2 (first is self, second is _cmd)
					[invocation setArgument:&notif atIndex:2];
				}
				if(notif.userInfo) {
					@synchronized (notif.userInfo) {
						[invocation invoke];
						if (postBlock) {
							postBlock(notif);
						}
					}
				} else {
					[invocation invoke];
					if (postBlock) {
						postBlock(notif);
					}
				}
			} else {
				NSPooledPriorityNotification *notifCopy = [NSPooledPriorityNotification newTempNotificationWithName:notif.name object:notif.object userInfo:notif.userInfo reverse:notif.reverse];
				if ([signature numberOfArguments] > 2) {  // Arguments start at index 2 (first is self, second is _cmd)
					[invocation setArgument:&notifCopy atIndex:2];
				}
				// The invocation runs asynchronously, so it must own its target and arguments;
				// NSInvocation does not retain them by default, and the weak observer may
				// otherwise deallocate before the operation runs (use-after-free).
				[invocation retainArguments];
				[_queue addOperationWithBlock:^{
					if (notifCopy.userInfo) {
						@synchronized (notifCopy.userInfo) {
							[invocation invoke];
							if (postBlock) {
								postBlock(notifCopy);
							}
						}
					} else {
						[invocation invoke];
						if (postBlock) {
							postBlock(notifCopy);
						}
					}
					[notifCopy recycle];
				}];
			}
		} else {
			NSLog(@"Error: Method signature for selector %@ not found", NSStringFromSelector(_selector));
		}
	}
}

@end


#pragma mark -
#pragma mark NSPriorityNotificationCenter

/*!
 @abstract		This
 @discussion	priority.
 */
@implementation NSPriorityNotificationCenter
{
	NSMutableArray<_NSPriorityNotificationObserver*> *_observers;
	_NSPriorityNotificationObserver	*_superPostNotification;
}


+ (BOOL)isSingleton
{
	return YES;
}

+ (id)defaultCenter
{
	return self.__BESingleton;
}


// Normal init doesn't install with the defaultCenter
- (id)init
{
	self = [super init];
	if (self)
	{
		_defaultPriority = NSPriorityNotificationDefaultPriority;
		_observers = [[NSMutableArray alloc] init];
		
		// Calls the super post at default priority. The observer is the center itself (a
		// PriorityItem), so the ncPriority getter adds the center's live ncPriority
		// (== defaultPriority). The stored offset is therefore 0 — the same net result the
		// addObserver: PriorityItem path produces (priority -= defaultPriority) — so the
		// super-post sits exactly at defaultPriority and tracks runtime changes to it.
		// Passing _defaultPriority here instead would double it (offset + live == 20).
		_superPostNotification = [[_NSPriorityNotificationObserver alloc] initWithObserver:self selector:@selector(_raiseSuperPostNotification:) name:nil object:nil queue:nil block:NULL priority:0];
		
		// Register self as an observer to the default notification center
		[NSNotificationCenter.defaultCenter addObserver:self
				  selector:@selector(_handleSuperNotification:)
					  name:nil
					object:nil];
	}
	return self;
}

- (void)cleanup
{
	// self registered on the system default center (not on itself), so removal must target
	// that center; [super removeObserver:self] would no-op against self's own empty table.
	[NSNotificationCenter.defaultCenter removeObserver:self];
	_superPostNotification = nil;
}

- (void)dealloc
{
	[NSNotificationCenter.defaultCenter removeObserver:self];
	NARC_RELEASE(_observers);
	SUPER_DEALLOC();
}


- (void)addObserver:(id)observer
		   selector:(SEL)aSelector
			   name:(NSString *)aName
			 object:(id)anObject
{
	[self addObserver:observer selector:aSelector name:aName object:anObject priority:self.defaultPriority queue:nil];
}


- (void)addObserver:(id)observer
		   selector:(SEL)aSelector
			   name:(NSString *)aName
			 object:(id)anObject
			  queue:(nullable NSOperationQueue *)queue
{
	[self addObserver:observer selector:aSelector name:aName object:anObject priority:self.defaultPriority queue:queue];
}

- (void)addObserver:(id)observer
		   selector:(SEL)aSelector
			   name:(NSString *)aName
			 object:(id)anObject
		   priority:(NSInteger)priority
{
	[self addObserver:observer selector:aSelector name:aName object:anObject priority:priority queue:nil];
}

- (void)addObserver:(id)observer
		   selector:(SEL)aSelector
			   name:(NSString *)aName
			 object:(id)anObject
		   priority:(NSInteger)priority
			  queue:(nullable NSOperationQueue *)queue
{
	if ([observer conformsToProtocol:@protocol(NSNotificationObjectPriorityCapture)]) {
		[observer setNcPriority:priority name:aName];
		if ([observer conformsToProtocol:@protocol(NSNotificationObjectPriorityItem)]) {
			//The priority is retrieved from the observer, so set to zero
			priority = 0;
		}
	} else if ([observer conformsToProtocol:@protocol(NSNotificationObjectPriorityItem)]) {
		//If the observer is a NSNotificationObjectPriorityItem:
		//	then the input priority is an offset from default
		// The input priority gets added to the returned real time value returned from
		// NSNotificationObjectPriorityItem::ncPriority when sorting observers.
		priority -= self.defaultPriority;
	}
	
	_NSPriorityNotificationObserver *notifObserver = [[_NSPriorityNotificationObserver alloc] initWithObserver:observer selector:aSelector name:aName object:anObject queue:queue block:NULL priority:priority];
	
	@synchronized (_observers) {
		[_observers addObject:notifObserver];
	}
	NARC_RELEASE(notifObserver);
}


- (nonnull id<NSObject>)addObserverForName:(nullable NSNotificationName)aName object:(nullable id)obj queue:(nullable NSOperationQueue *)queue usingBlock:(void (^ _Nonnull)(NSNotification * _Nonnull))block
{
	return [self addObserverForName:aName object:obj priority:self.defaultPriority queue:queue usingBlock:block];
}

- (nonnull id<NSObject>)addObserverForName:(nullable NSNotificationName)aName object:(nullable id)anObject priority:(NSInteger)priority queue:(nullable NSOperationQueue *)queue usingBlock:(void (^ _Nonnull)(NSNotification * _Nonnull))block 
{
	_NSPriorityNotificationObserver *notifObserver = [[_NSPriorityNotificationObserver alloc] initWithObserver:nil selector:NULL name:aName object:anObject queue:queue block:block priority:priority];
	@synchronized (_observers) {
		[_observers addObject:notifObserver];
	}
	return notifObserver;
}


- (void)removeObserver:(nonnull id)observer
{
	@synchronized (_observers) {
		NSIndexSet *indicies = [_observers indexesOfObjectsPassingTest:^BOOL(_NSPriorityNotificationObserver *notifObserver, NSUInteger idx, BOOL *stop) {
			// observer may be a user controlled object, or an instance of _NSNotificationObserver if the block version of
			// addObserverForName was used
			return notifObserver == observer || notifObserver.observer == observer;
		}];
		[_observers removeObjectsAtIndexes:indicies];
	}
}

- (void)removeObserver:(nonnull id)observer name:(nullable NSNotificationName)aName object:(nullable id)anObject
{
	@synchronized (_observers) {
		NSIndexSet *indicies = [_observers indexesOfObjectsPassingTest:^BOOL(_NSPriorityNotificationObserver *notifObserver, NSUInteger idx, BOOL *stop) {
			BOOL matchesObject = YES;
			if (anObject != nil)
			{
				matchesObject = notifObserver.object == anObject;
			}
			// A nil aName matches every name, per the documented "nil to remove all names".
			BOOL matchesName = (aName == nil) || [notifObserver.name isEqualToString:aName];
			return notifObserver.observer == observer && matchesObject && matchesName;
		}];
		[_observers removeObjectsAtIndexes:indicies];
	}
}


// method called when the normal defaultCenter posts notification
// this is the notification trap to raise defaultCenter priority items.
- (void)_handleSuperNotification:(NSNotification *)notification
{
	if (!notification.isPriorityPost) {
		[self raiseNotification:notification fromDefault:NO];
	}
}

// Inserted into a Priority postNotification when self is the singleton to post to the super
- (void)_raiseSuperPostNotification:(NSNotification *)notification
{
	if (notification.isPriorityPost) {
		return;
	}
	notification.isPriorityPost = YES;
	// Clear the guard even if an observer raises, so the notification is not left flagged.
	@try {
		[super postNotification:notification];
	} @finally {
		notification.isPriorityPost = NO;
	}
}

- (void)postNotification:(NSNotification *)notification
{
	[self raiseNotification:notification fromDefault:YES];
}

- (void)raiseNotification:(NSNotification *)notification fromDefault:(BOOL)fromDefault
{
	NSString *name = [notification name];
	id object = [notification object];
	
	// Snapshot the observers, dropping selector/target observers whose target has
	// deallocated (weak observer now nil). Block observers (block != NULL) and live
	// observers are kept; _superPostNotification is not in _observers, so it is unaffected.
	NSMutableArray<_NSPriorityNotificationObserver*> *observers = nil;
	@synchronized (_observers) {
		NSIndexSet *dead = [_observers indexesOfObjectsPassingTest:^BOOL(_NSPriorityNotificationObserver *obs, NSUInteger idx, BOOL *stop) {
			return obs.observer == nil && obs.block == NULL;
		}];
		if (dead.count) {
			[_observers removeObjectsAtIndexes:dead];
		}
		observers = [_observers mutableCopy];
	}

	NSPredicate *objectPredicate = [NSPredicate predicateWithBlock:^BOOL(_NSPriorityNotificationObserver *obs, NSDictionary *bindings) {
		BOOL matchesName = (name == nil || obs.name == nil || [obs.name isEqualToString:name]);
		// obs.observesAllObjects distinguishes "registered for all objects" from "object
		// filter has since deallocated", so a dead filter does not become a wildcard.
		BOOL matchesObject = (object == nil || obs.observesAllObjects || object == obs.object);
		return matchesName && matchesObject;
		}];
		
	[observers filterUsingPredicate:objectPredicate];
	
	if (fromDefault && _superPostNotification) {
		[observers addObject:_superPostNotification];
	}


	// Snapshot each observer's priority with its registration index, then sort by
	// (priority, index). Snapshotting addresses three issues with sorting on the live
	// getter: a dynamic ncPriority that changes mid-sort makes the comparator
	// inconsistent (which NSMutableArray can raise on); comparing two NSIntegers by
	// subtraction overflows for extreme priorities; and equal priorities must keep
	// registration order, as NSNotificationCenter delivers in registration order.
	NSMutableArray<NSArray *> *ordering = [NSMutableArray arrayWithCapacity:observers.count];
	[observers enumerateObjectsUsingBlock:^(_NSPriorityNotificationObserver *obs, NSUInteger idx, BOOL *stop) {
		[ordering addObject:@[@(obs.ncPriority), @(idx), obs]];
	}];
	[ordering sortUsingComparator:^NSComparisonResult(NSArray *a, NSArray *b) {
		NSComparisonResult byPriority = [a[0] compare:b[0]];
		return byPriority != NSOrderedSame ? byPriority : [a[1] compare:b[1]];
	}];
	[observers removeAllObjects];
	for (NSArray *entry in ordering) {
		[observers addObject:entry[2]];
	}

	// Invoke observers
	NSEnumerationOptions options = notification.reverse ? NSEnumerationReverse : 0;
	if (notification.userInfo) {
		[observers enumerateObjectsWithOptions:options usingBlock:^(id observer, NSUInteger idx, BOOL *stop) {
			@synchronized (notification.userInfo) {
				[observer postNotification:notification];
			}
		}];
	} else {
		[observers enumerateObjectsWithOptions:options usingBlock:^(id observer, NSUInteger idx, BOOL *stop) {
			[observer postNotification:notification];
		}];
	}
	NARC_RELEASE(observers);
}

- (void)postNotificationName:(NSNotificationName)aName object:(id)anObject
{
	[self postNotificationName:aName object:anObject userInfo:nil reverse:NO postBlock:NULL];
}

- (void)postNotificationName:(NSNotificationName)aName object:(id)anObject postBlock:(void (NS_SWIFT_SENDABLE ^_Nullable)(NSNotification * _Nonnull notification))postBlock
{
	[self postNotificationName:aName object:anObject userInfo:nil reverse:NO postBlock:postBlock];
}


- (void)postNotificationName:(NSNotificationName)aName
					  object:(id)anObject
					userInfo:(NSDictionary *)aUserInfo
{
	[self postNotificationName:aName object:anObject userInfo:aUserInfo reverse:NO postBlock:NULL];
}

- (void)postNotificationName:(NSNotificationName)aName
					  object:(id)anObject
					userInfo:(NSDictionary *)aUserInfo
				   postBlock:(void (NS_SWIFT_SENDABLE ^_Nullable)(NSNotification * _Nonnull notification))postBlock
{
	[self postNotificationName:aName object:anObject userInfo:aUserInfo reverse:NO postBlock:postBlock];
}


- (void)postNotificationName:(NSNotificationName)aName object:(id)anObject reverse:(BOOL)reverse
{
	[self postNotificationName:aName object:anObject userInfo:nil reverse:reverse postBlock:NULL];
}
- (void)postNotificationName:(NSNotificationName)aName object:(id)anObject reverse:(BOOL)reverse postBlock:(void (NS_SWIFT_SENDABLE ^_Nullable)(NSNotification * _Nonnull notification))postBlock
{
	[self postNotificationName:aName object:anObject userInfo:nil reverse:reverse postBlock:postBlock];
}

- (void)postNotificationName:(NSNotificationName)aName
					  object:(id)anObject
					userInfo:(NSDictionary *)aUserInfo
					 reverse:(BOOL)reverse
{
	[self postNotificationName:aName object:anObject userInfo:aUserInfo reverse:reverse postBlock:NULL];
}

- (void)postNotificationName:(NSNotificationName)aName
					  object:(id)anObject
					userInfo:(NSDictionary *)aUserInfo
					reverse:(BOOL)reverse
				   postBlock:(void (NS_SWIFT_SENDABLE ^_Nullable)(NSNotification * _Nonnull notification))postBlock
{
	[self postNotification:[NSPriorityNotification notificationWithName:aName object:anObject userInfo:aUserInfo reverse:reverse postBlock:postBlock]];
}

#pragma mark -
#pragma mark NSNotificationObjectPriorityItem

/*!
 @method		-ncPriority
 @abstract		This is the priority of the NSPriorityNotificationCenter when being called by the normal
 				NSNotification.
 @return		Returns the NSString containing the description of the current object.
 */
// Priority of the super NSNotificationCenter for @c -_raiseSuperPostNotification:
- (NSInteger)ncPriority:(nullable NSNotificationName)aName
{
	return self.defaultPriority;
}


@end
