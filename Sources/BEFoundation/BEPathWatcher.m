/*!
 @file			BEPathWatcher.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/

#import "BEPathWatcher.h"
#import "BE_ARC.h"


unsigned long const BEPathWatcherDefaultEventMask =
			DISPATCH_VNODE_WRITE |
			DISPATCH_VNODE_DELETE |
			DISPATCH_VNODE_EXTEND |
			DISPATCH_VNODE_RENAME;

@implementation BEPathWatcher
{
	// Watching configuration
	dispatch_source_t _dispatchSource;

	// Callback mechanisms
	__weak id	_target;                 // Target for selector
	SEL			_selector;                     // Selector to be called on target
	void		(^_block)(BEPathWatcher *, unsigned long);
	id			_lock;
}

@synthesize path = _path;
@synthesize eventMask = _eventMask;
@synthesize eventHandler = _block;

- (BOOL)isActive {
	return _dispatchSource != nil;
}

- (void)setIsActive:(BOOL)value {
	@synchronized (_lock) {
		if (value && !_dispatchSource) {
			[self startMonitoring];
			
		} else if (!value && _dispatchSource) {
			[self stopMonitoring];
		}
	}
}


- (unsigned long)eventMask {
	return _eventMask;
}

- (void)setEventMask:(unsigned long)value {
	
	@synchronized (_lock) {
		BOOL isActive = _dispatchSource != nil;
		if (isActive) {
			[self stopMonitoring];
		}
		
		_eventMask = value;
		
		if (isActive) {
			[self startMonitoring];
		}
	}
}


- (NSString *)path {
	// Synchronized: setPath: reassigns the strong _path under _lock, so an unguarded read could
	// race the release of the old value.
	@synchronized (_lock) {
		return _path;
	}
}

- (void)setPath:(NSString *)value {
	@synchronized (_lock) {
		// Compare under the lock; reading _path unguarded could race setPath: on another thread.
		// isEqualToString: is symmetric and nil-tolerant, so one direction suffices.
		if ((!_path && !value) || _path == value || (value && [_path isEqualToString:value])) {
			return;
		}

		BOOL isActive = _dispatchSource != nil;
		if (isActive) {
			[self stopMonitoring];
		}

		_path = [value copy];

		if (isActive) {
			[self startMonitoring];
		}
	}
}

// Synchronized like the path getter: the mutators below reassign target, selector, and
// eventHandler as a unit under _lock, so an unguarded read could race the swap.
- (id)target {
	@synchronized (_lock) {
		return _target;
	}
}

- (SEL)selector {
	@synchronized (_lock) {
		return _selector;
	}
}

- (void (^)(BEPathWatcher *, unsigned long))eventHandler {
	@synchronized (_lock) {
		return _block;
	}
}

- (void)setTarget:(id)target selector:(SEL)selector
{
	@synchronized (_lock) {
		_target = target;
		_selector = selector;
		_block = nil;
	}
}

- (void)setEventHandler:(void (^)(BEPathWatcher * _Nonnull, unsigned long))eventHandler
{
	@synchronized (_lock) {
		_target = nil;
		_selector = nil;
		_block = [eventHandler copy];
	}
}

#pragma mark - Lifecycle

- (instancetype)init {
	if (self = [super init]) {
		_dispatchSource = nil;
		_lock = NSObject.new;
		
		self.path = nil;
		self.eventMask = BEPathWatcherDefaultEventMask;
		[self setTarget:nil selector:nil];
		
	}
	return self;
}

- (void)dealloc {
	[self stopMonitoring];
	_lock = nil;
}

#pragma mark - Class Factory Methods

+ (nullable instancetype)watcherForPath:(NSString *)path target:(id)target selector:(SEL)selector {
	return [[self alloc] initWithPath:path target:target selector:selector];
}

+ (nullable instancetype)watcherForPath:(NSString *)path withBlock:(void (^_Nonnull)(BEPathWatcher *watcher, unsigned long event))block {
	return [[self alloc] initWithPath:path withBlock:block];
}



+ (nullable instancetype)watcherForPath:(NSString *)path eventMask:(unsigned long)eventMask target:(id)target selector:(SEL)selector {
	return [[self alloc] initWithPath:path eventMask:eventMask target:target selector:selector];
}

+ (nullable instancetype)watcherForPath:(NSString *)path eventMask:(unsigned long)eventMask withBlock:(void (^_Nonnull)(BEPathWatcher *watcher, unsigned long event))block {
	return [[self alloc] initWithPath:path eventMask:eventMask withBlock:block];
}

#pragma mark - Initializers


- (nullable instancetype)initWithPath:(NSString *)path {
	return [self initWithPath:path eventMask:BEPathWatcherDefaultEventMask];
}

- (nullable instancetype)initWithPath:(NSString *)path eventMask:(unsigned long)eventMask {
	if (self = [self init]) {
		self.path = path;
		self.eventMask = eventMask;
	}
	return self;
}



- (nullable instancetype)initWithTarget:(id)target selector:(SEL)selector {
	return [self initWithEventMask:BEPathWatcherDefaultEventMask target:target selector:selector];
}

- (nullable instancetype)initWithBlock:(void (^_Nonnull)(BEPathWatcher *watcher, unsigned long event))block {
	return [self initWithEventMask:BEPathWatcherDefaultEventMask withBlock:block];
}




- (nullable instancetype)initWithEventMask:(unsigned long)eventMask target:(id)target selector:(SEL)selector {
	if (self = [self init]) {
		self.eventMask = eventMask;
		[self setTarget:target selector:selector];
	}
	return self;
}

- (nullable instancetype)initWithEventMask:(unsigned long)eventMask withBlock:(void (^_Nonnull)(BEPathWatcher *watcher, unsigned long event))block {
	if (self = [self init]) {
		self.eventMask = eventMask;
		self.eventHandler = block;
	}
	return self;
}




- (nullable instancetype)initWithPath:(NSString *)path target:(id)target selector:(SEL)selector {
	return [self initWithPath:path eventMask:BEPathWatcherDefaultEventMask target:target selector:selector];
}

- (nullable instancetype)initWithPath:(NSString *)path withBlock:(void (^_Nonnull)(BEPathWatcher *watcher, unsigned long event))block {
	return [self initWithPath:path eventMask:BEPathWatcherDefaultEventMask withBlock:block];
}



- (nullable instancetype)initWithPath:(NSString *)path eventMask:(unsigned long)eventMask target:(id)target selector:(SEL)selector {
	if (self = [self init]) {
		if (![self watchPath:path eventMask:eventMask target:target selector:selector]) {
			return nil;
		}
	}
	return self;
}

- (nullable instancetype)initWithPath:(NSString *)path eventMask:(unsigned long)eventMask withBlock:(void (^_Nonnull)(BEPathWatcher *watcher, unsigned long event))block {
	if (self = [self init]) {
		if (![self watchPath:path eventMask:eventMask withBlock:block]) {
			return nil;
		}
	}
	return self;
}

#pragma mark - Public Watching Methods

- (BOOL)watchPath:(NSString *)path {
	@synchronized (_lock) {
		[self stopMonitoring]; // Stop any previous watching session
		
		self.path = path;
		
		return [self startMonitoring];
	}
}



- (BOOL)watchPath:(NSString *)path target:(id)target selector:(SEL)selector {
	return [self watchPath:path eventMask:_eventMask target:target selector:selector];
}

- (BOOL)watchPath:(NSString *)path withBlock:(void (^_Nonnull)(BEPathWatcher *watcher, unsigned long event))block {
	return [self watchPath:path eventMask:_eventMask withBlock:block];
}



- (BOOL)watchPath:(NSString *)path eventMask:(unsigned long)eventMask target:(id)target selector:(SEL)selector {
	@synchronized (_lock) {
		[self stopMonitoring];
		self.path = path;
		self.eventMask = eventMask;
		[self setTarget:target selector:selector];
		return [self startMonitoring];
	}
}

- (BOOL)watchPath:(NSString *)path eventMask:(unsigned long)eventMask withBlock:(void (^_Nonnull)(BEPathWatcher *watcher, unsigned long event))block {
	@synchronized (_lock) {
		[self stopMonitoring];
		self.path = path;
		self.eventMask = eventMask;
		self.eventHandler = block;
		return [self startMonitoring];
	}
}



- (BOOL)watchWithTarget:(id)target selector:(SEL)selector
{
	@synchronized (_lock) {
		[self stopMonitoring];
		[self setTarget:target selector:selector];
		return [self startMonitoring];
	}
}

/**
 * Starts watching a directory and uses a simple dispatch block for notifications.
 * @return YES if watching started successfully, otherwise NO.
 */
- (BOOL)watchWithBlock:(void (^_Nonnull)(BEPathWatcher *watcher, unsigned long event))block
{
	@synchronized (_lock) {
		[self stopMonitoring];
		self.eventHandler = block;
		return [self startMonitoring];
	}
}

/**
 * Starts watching a directory and uses a target-selector for notifications.
 * @param target The object that receives the notification. This is stored as a weak reference.
 * @param selector The selector to call on the target. It takes the watcher alone, the watcher and the event flags, or the event flags alone.
 * @return YES if watching started successfully, otherwise NO.
 */
- (BOOL)watchWithEventMask:(unsigned long)eventMask target:(id)target selector:(SEL)selector
{
	@synchronized (_lock) {
		[self stopMonitoring];
		self.eventMask = eventMask;
		[self setTarget:target selector:selector];
		return [self startMonitoring];
	}
}

/**
 * Starts watching a directory and uses a simple dispatch block for notifications.
 * @return YES if watching started successfully, otherwise NO.
 */
- (BOOL)watchWithEventMask:(unsigned long)eventMask withBlock:(void (^_Nonnull)(BEPathWatcher *watcher, unsigned long event))block;
{
	@synchronized (_lock) {
		[self stopMonitoring];
		self.eventMask = eventMask;
		self.eventHandler = block;
		return [self startMonitoring];
	}
}

#pragma mark - Core Logic


- (BOOL)startMonitoring {
	@synchronized (_lock) {
		if (_dispatchSource) {
			return YES;
		}
		if (!self.eventMask || !self.path || ([self isMemberOfClass:BEPathWatcher.class] && !(self.target && self.selector) && !self.eventHandler)) {
			return NO;
		}
		
		int newFD = open([self.path fileSystemRepresentation], O_EVTONLY);
		if (newFD < 0) {
			_path = nil;
			return NO;
		}

		// DISPATCH_VNODE_WRITE: For file content changes (writing, truncating) and directory content changes (file/subdir creation/deletion/renaming).
		// DISPATCH_VNODE_DELETE: For when the watched file/directory itself is deleted.
		// DISPATCH_VNODE_ATTRIB: For changes to attributes (permissions, ownership, last access/modification time).
		// DISPATCH_VNODE_EXTEND: For when the file is extended (e.g., appended to).
		// DISPATCH_VNODE_LINK: For changes to the link count.
		// DISPATCH_VNODE_RENAME: For when the watched file/directory itself is renamed.
		// DISPATCH_VNODE_REVOKE: For when access to the file descriptor is revoked (less common, but good for completeness).

		dispatch_source_t newSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, (uintptr_t)newFD, self.eventMask, dispatch_get_main_queue());
		if (!newSource) {
			close(newFD);
			return NO;
		}
		_dispatchSource = newSource;

		// Capture the source and FD in locals. The cancel handler can be queued before a new
		// startMonitoring assigns a fresh _dispatchSource; without local captures the cancel
		// handler (and event handler) would reference the wrong source / close the new FD.
		__weak typeof(self) weakSelf = self;
		dispatch_source_set_event_handler(newSource, ^{
			__strong typeof(weakSelf) strongSelf = weakSelf;
			if (!strongSelf) {
				return; //just in case, may never be called.
			}

			unsigned long eventFlags = dispatch_source_get_data(newSource);
			[strongSelf handleEventWithFlags:eventFlags source:newSource];
		});

		dispatch_source_set_cancel_handler(newSource, ^{
			close(newFD);
		});

		dispatch_resume(newSource);
		
		return YES;
	}
}

/**
 * Handles a file system event by invoking callbacks and performing cleanup.
 * @param source The dispatch source that fired, used to validate the auto-stop is still relevant.
 */
- (void)handleEventWithFlags:(unsigned long)flags source:(dispatch_source_t)source {

	// Snapshot the callback configuration under the lock, then invoke callbacks without holding
	// it. The callbacks are user/subclass code that may call back into the watcher (potentially
	// from another thread), which would deadlock if the lock were held across the call-out.
	void (^handler)(BEPathWatcher *, unsigned long) = nil;
	__strong id target = nil;
	SEL selector = NULL;
	@synchronized (_lock) {
		handler = _block;
		target = _target;
		selector = _selector;
	}

	if ([self respondsToSelector:@selector(pathDidChangeWithFlags:)]) {
		[self pathDidChangeWithFlags:flags];
	}

	if (handler) {
		handler(self, flags);
	} else if (target && selector) {
		NSMethodSignature *signature = [target methodSignatureForSelector:selector];
		if (signature) {
			const char *argType = signature.numberOfArguments > 2 ? [signature getArgumentTypeAtIndex:2] : "";
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			invocation.target = target;
			invocation.selector = selector;
			if (signature.numberOfArguments == 3 && (!strcmp(argType, @encode(long)) || !strcmp(argType, @encode(unsigned long)))) {
				[invocation setArgument:(void *)&flags atIndex:2];
			} else if (signature.numberOfArguments > 2) {
				[invocation setArgument:(void *)&self atIndex:2]; // Arguments start at index 2
			}
			if (signature.numberOfArguments > 3) {
				[invocation setArgument:(void *)&flags atIndex:3];
			}
			[invocation invoke];
		}
	}

	// If the watched path itself was deleted or renamed, the file descriptor becomes invalid,
	// so monitoring must stop, but only if this is still the active source. Callbacks run
	// outside the lock, so another thread may have reconfigured the watcher (installing a new
	// source) during the callback; the old source's delete must not cancel that new source.
	if (flags & (DISPATCH_VNODE_DELETE | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE)) {
		@synchronized (_lock) {
			if (_dispatchSource == source) {
				[self stopMonitoring];
			}
		}
	}
}

- (void)stopMonitoring {
	@synchronized (_lock) {
		// Cancelling the source runs the cancel handler, which closes the file descriptor.
		if (_dispatchSource) {
			dispatch_source_cancel(_dispatchSource);
			_dispatchSource = nil;
		}
	}
}

#pragma mark - Internal Hooks

@end
