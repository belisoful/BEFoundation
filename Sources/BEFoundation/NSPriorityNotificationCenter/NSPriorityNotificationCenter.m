/*!
 @file			NSPriorityNotificationCenter.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		A notification center that delivers to observers in priority order.
 @discussion	Implements NSPriorityNotificationCenter and its private observer record. The
				default center is bridged to NSNotificationCenter.defaultCenter in both directions.
*/

#import "BE_ARC.h"

#import <Foundation/Foundation.h>
#import "NSPriorityNotificationCenter.h"
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
// Set on the internal super-post record: it is not a caller-registered observer, so its
// delivery must not run the notification's once-per-observer postBlock.
@property (nonatomic, assign) BOOL suppressesPostBlock;

- (id)initWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object queue:(NSOperationQueue *)queue block:(void (^)(NSNotification *note))block priority:(NSInteger)priority;

/*!
 @method		postNotification:fromSuper:
 @abstract		Delivers a notification to this observer record.
 @param			notif		The notification to deliver.
 @param			fromSuper	YES when the notification arrived from NSNotificationCenter.defaultCenter
							rather than from the priority center's own post methods.
 @discussion	A notification from the super center may carry an opaque CF pointer as its object.
				SceneKit, for example, posts C structs through CFNotificationCenterPostNotification.
				Retaining such a pointer crashes, so queued delivery of a super-center notification
				forwards the notification itself, as NSNotificationCenter does, instead of copying it
				into an NSPriorityNotification.
 */
- (void)postNotification:(NSNotification *)notif fromSuper:(BOOL)fromSuper;
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
	id observer = self.observer;
	if ([observer conformsToProtocol:@protocol(NSNotificationObjectPriorityItem)]) {
		return [((id<NSNotificationObjectPriorityItem>)observer) ncPriority:self.name] + _ncPriority;
	}
	return _ncPriority;
}

// Queued observers run after this post returns, by which point the poster's notification may
// be gone. A center-originated post receives a stable copy decoupled from the source (userInfo
// is shared by reference). A super-center notification is forwarded as-is: the copy would
// retain notif.object, which may be an opaque CF pointer.
- (NSNotification *)notificationForQueuedDelivery:(NSNotification *)notif fromSuper:(BOOL)fromSuper
{
	if (fromSuper) {
		return notif;
	}
	return [[NSPriorityNotification alloc] initWithName:notif.name object:notif.object userInfo:notif.userInfo reverse:notif.reverse];
}

// Delivery takes no lock around the call-out. userInfo is shared by reference with every
// observer, as NSNotificationCenter shares it, and an observer that mutates a mutable
// userInfo synchronizes that itself.
- (void)postNotification:(NSNotification *)notif fromSuper:(BOOL)fromSuper
{
	void (^ postBlock)(NSNotification * _Nonnull note) = self.suppressesPostBlock ? NULL : notif.postBlock;
	if (self.block != NULL) {
		[self deliverBlockWithNotification:notif fromSuper:fromSuper postBlock:postBlock];
	} else {
		[self deliverSelectorWithNotification:notif fromSuper:fromSuper postBlock:postBlock];
	}
}

- (void)deliverBlockWithNotification:(NSNotification *)notif fromSuper:(BOOL)fromSuper postBlock:(void (^ _Nullable)(NSNotification * _Nonnull note))postBlock
{
	void (^ block)(NSNotification * _Nonnull note) = self.block;
	NSOperationQueue *queue = self.queue;
	if (queue == nil) {
		block(notif);
		if (postBlock) {
			postBlock(notif);
		}
		return;
	}
	NSNotification *notifCopy = [self notificationForQueuedDelivery:notif fromSuper:fromSuper];
	[queue addOperationWithBlock:^{
		block(notifCopy);
		if (postBlock) {
			postBlock(notifCopy);
		}
	}];
}

- (void)deliverSelectorWithNotification:(NSNotification *)notif fromSuper:(BOOL)fromSuper postBlock:(void (^ _Nullable)(NSNotification * _Nonnull note))postBlock
{
	// The observer is weak. One strong load keeps the same object alive from the signature
	// lookup through the synchronous invoke.
	id observer = self.observer;
	SEL selector = self.selector;
	if (observer == nil || selector == NULL) {
		return;
	}
	NSMethodSignature *signature = [observer methodSignatureForSelector:selector];
	if (signature == nil) {
		NSLog(@"Error: Method signature for selector %@ not found", NSStringFromSelector(selector));
		return;
	}

	NSOperationQueue *queue = self.queue;
	NSNotification *delivered = (queue == nil) ? notif : [self notificationForQueuedDelivery:notif fromSuper:fromSuper];

	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.selector = selector;
	invocation.target = observer;
	if (signature.numberOfArguments > 2) {  // index 0 is self, index 1 is _cmd
		[invocation setArgument:&delivered atIndex:2];
	}

	if (queue == nil) {
		[invocation invoke];
		if (postBlock) {
			postBlock(delivered);
		}
		return;
	}
	// The invocation runs asynchronously, so it must own its target and arguments;
	// NSInvocation does not retain them by default, and the weak observer may
	// otherwise deallocate before the operation runs.
	[invocation retainArguments];
	[queue addOperationWithBlock:^{
		[invocation invoke];
		if (postBlock) {
			postBlock(delivered);
		}
	}];
}

@end


#pragma mark -
#pragma mark NSPriorityNotificationCenter

/*!
 @abstract		A notification center that delivers to observers in priority order.
 @discussion	At each post the observers are sorted by priority, then by registration order.
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


- (instancetype)init
{
	return [self initBridgingDefaultCenter:NO];
}

// BESingleton creates the shared instance through this initializer, so only +defaultCenter
// is bridged to NSNotificationCenter.defaultCenter.
- (instancetype)initForSingleton:(nullable NSDictionary *)initInfo
{
	return [self initBridgingDefaultCenter:YES];
}

- (instancetype)initBridgingDefaultCenter:(BOOL)bridgesDefaultCenter
{
	self = [super init];
	if (self)
	{
		_defaultPriority = NSPriorityNotificationDefaultPriority;
		_observers = [[NSMutableArray alloc] init];
		if (bridgesDefaultCenter) {
			[self installDefaultCenterBridge];
		}
	}
	return self;
}

// Forwards this center's posts to NSNotificationCenter.defaultCenter and receives its posts.
- (void)installDefaultCenterBridge
{
	// The super-post record's observer is the center itself (a PriorityItem), so the ncPriority
	// getter adds the center's live defaultPriority. A stored offset of 0 therefore places the
	// super-post exactly at defaultPriority and tracks runtime changes to it; passing
	// _defaultPriority here would double it.
	_superPostNotification = [[_NSPriorityNotificationObserver alloc] initWithObserver:self selector:@selector(_raiseSuperPostNotification:) name:nil object:nil queue:nil block:NULL priority:0];
	_superPostNotification.suppressesPostBlock = YES;

	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(_handleSuperNotification:)
											   name:nil
											 object:nil];
}

- (void)cleanup
{
	// self registered on the system default center (not on itself), so removal must target
	// that center; [super removeObserver:self] would no-op against self's own empty table.
	[NSNotificationCenter.defaultCenter removeObserver:self];
	@synchronized (_observers) {
		_superPostNotification = nil;
	}
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
			// The observer supplies its own priority; the stored offset is zero.
			priority = 0;
		}
	} else if ([observer conformsToProtocol:@protocol(NSNotificationObjectPriorityItem)]) {
		// For an NSNotificationObjectPriorityItem observer the stored value is an offset from
		// defaultPriority; the ncPriority getter adds it back when observers are sorted.
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
	if (observer == nil) {
		return;    // a nil observer would match every block registration
	}
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
	if (observer == nil) {
		return;    // a nil observer would match every block registration
	}
	@synchronized (_observers) {
		NSIndexSet *indicies = [_observers indexesOfObjectsPassingTest:^BOOL(_NSPriorityNotificationObserver *notifObserver, NSUInteger idx, BOOL *stop) {
			BOOL matchesObject = YES;
			if (anObject != nil)
			{
				matchesObject = notifObserver.object == anObject;
			}
			// A nil aName matches every name, per the documented "nil to remove all names".
			BOOL matchesName = (aName == nil) || [notifObserver.name isEqualToString:aName];
			// Match the token returned by addObserverForName:… as well as a plain observer, as
			// -removeObserver: does; a block registration has a nil .observer.
			BOOL matchesObserver = (notifObserver == observer || notifObserver.observer == observer);
			return matchesObserver && matchesObject && matchesName;
		}];
		[_observers removeObjectsAtIndexes:indicies];
	}
}


// Receives every NSNotificationCenter.defaultCenter post on the bridged center.
- (void)_handleSuperNotification:(NSNotification *)notification
{
	if (!notification.isPriorityPost) {
		[self raiseNotification:notification fromDefault:NO];
	}
}

// The bridged center's super-post record delivers here at defaultPriority.
- (void)_raiseSuperPostNotification:(NSNotification *)notification
{
	if (notification.isPriorityPost) {
		return;
	}
	notification.isPriorityPost = YES;
	// Clear the guard even if an observer raises, so the notification is not left flagged.
	@try {
		// Post through NSNotificationCenter.defaultCenter: this center's own NSNotificationCenter
		// table never holds the observers registered with +defaultCenter.
		// isPriorityPost (set above) stops -_handleSuperNotification: re-entering.
		[NSNotificationCenter.defaultCenter postNotification:notification];
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
	// Unretained: a super-center notification's object may be an opaque CF pointer, not an
	// Objective-C object (SceneKit posts C structs through CFNotificationCenterPostNotification).
	// It is only compared by identity here, never retained.
	__unsafe_unretained id object = [notification object];
	
	// Snapshot the observers, dropping selector/target observers whose target has
	// deallocated (weak observer now nil). Block observers (block != NULL) and live
	// observers are kept; _superPostNotification is not in _observers, so it is unaffected.
	NSMutableArray<_NSPriorityNotificationObserver*> *observers = nil;
	// Snapshot the super-post record under the same lock that -cleanup nils it, so a concurrent
	// teardown cannot leave a nil to be appended to the observer list below.
	_NSPriorityNotificationObserver *superPost = nil;
	@synchronized (_observers) {
		NSIndexSet *dead = [_observers indexesOfObjectsPassingTest:^BOOL(_NSPriorityNotificationObserver *obs, NSUInteger idx, BOOL *stop) {
			return obs.observer == nil && obs.block == NULL;
		}];
		if (dead.count) {
			[_observers removeObjectsAtIndexes:dead];
		}
		observers = [_observers mutableCopy];
		superPost = _superPostNotification;
	}

	NSPredicate *objectPredicate = [NSPredicate predicateWithBlock:^BOOL(_NSPriorityNotificationObserver *obs, NSDictionary *bindings) {
		// Wildcards belong to the observer, not the notification: matching NSNotificationCenter,
		// an observer registered for all names or all objects receives everything, while a
		// notification posted with a nil name or nil object reaches only those wildcard
		// observers rather than every registration.
		BOOL matchesName = (obs.name == nil || [obs.name isEqualToString:name]);
		// obs.observesAllObjects distinguishes "registered for all objects" from "object
		// filter has since deallocated", so a dead filter does not become a wildcard.
		BOOL matchesObject = (obs.observesAllObjects || object == obs.object);
		return matchesName && matchesObject;
		}];
		
	[observers filterUsingPredicate:objectPredicate];
	
	if (fromDefault && superPost) {
		[observers addObject:superPost];
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

	NSEnumerationOptions options = notification.reverse ? NSEnumerationReverse : 0;
	BOOL fromSuper = !fromDefault;
	[observers enumerateObjectsWithOptions:options usingBlock:^(_NSPriorityNotificationObserver *observer, NSUInteger idx, BOOL *stop) {
		[observer postNotification:notification fromSuper:fromSuper];
	}];
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
 @method		ncPriority:
 @abstract		The priority of the center's own super-post record.
 @param			aName	Ignored.
 @return		The center's defaultPriority.
 */
- (NSInteger)ncPriority:(nullable NSNotificationName)aName
{
	return self.defaultPriority;
}


@end
