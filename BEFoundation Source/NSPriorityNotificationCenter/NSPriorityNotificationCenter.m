/*!
 @file			NSPriorityNotificationCenter.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
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

@property (nonatomic, readonly) id observer;
@property (nonatomic, readonly) SEL selector;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) id object;
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
	//	@warning TODO: Should not copy. If you post an NSNotification, you should get the same object on all listeners, regardless of thread, userInfo is the same.
		// make a copy for now, as recycling needs a bit of reworking
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
		
		// Inserted when Priority postNotification is called, for calling the super post notification at default priority
		_superPostNotification = [[_NSPriorityNotificationObserver alloc] initWithObserver:self selector:@selector(_raiseSuperPostNotification:) name:nil object:nil queue:nil block:NULL priority:_defaultPriority];
		
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
	[super removeObserver:self];
	_superPostNotification = nil;
}

- (void)dealloc
{
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
			return notifObserver.observer == observer && matchesObject && [notifObserver.name isEqualToString:aName];
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
	[super postNotification:notification];
	notification.isPriorityPost = NO;
}

- (void)postNotification:(NSNotification *)notification
{
	[self raiseNotification:notification fromDefault:YES];
}

- (void)raiseNotification:(NSNotification *)notification fromDefault:(BOOL)fromDefault
{
	NSString *name = [notification name];
	id object = [notification object];
	
	// Mmake observers mutable to filter with predicate
	NSMutableArray<_NSPriorityNotificationObserver*> *observers = nil;
	@synchronized (_observers) {
		observers = [_observers mutableCopy];
	}
	
	NSPredicate *objectPredicate = [NSPredicate predicateWithBlock:^BOOL(_NSPriorityNotificationObserver *obs, NSDictionary *bindings) {
		return (name == nil || obs.name == nil || [obs.name isEqualToString:name]) && (object == nil || obs.object == nil || object == obs.object);
		}];
		
	[observers filterUsingPredicate:objectPredicate];
	
	if (fromDefault && _superPostNotification) {
		[observers addObject:_superPostNotification];
	}
	
	
	// Sort observers based on priority
	[observers sortUsingComparator:^NSComparisonResult(_NSPriorityNotificationObserver *obj1, _NSPriorityNotificationObserver *obj2) {
		return MAX(MIN(obj1.ncPriority - obj2.ncPriority, 1), -1);
	}];
	
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
