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
	int			_dirFD;
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
	return _path;
}

- (void)setPath:(NSString *)value {
	if ((!_path && !value) || _path == value || (_path && [_path isEqualToString:value]) || (value && [value isEqualToString:_path])) {
		return;
	}
	
	@synchronized (_lock) {
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
	_target = nil;
	_selector = nil;
	_block = eventHandler;
}

#pragma mark - Lifecycle

- (instancetype)init {
	if (self = [super init]) {
		_dirFD = -1;
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
 * @param target The object that will receive the notification. This is stored as a weak reference.
 * @param selector The selector to be called on the target. It must take one argument: the BEDirectoryWatcher instance.
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
		
		// Open the directory/file and get a file descriptor.
		_dirFD = open([self.path fileSystemRepresentation], O_EVTONLY);
		if (_dirFD < 0) {
			// Failed to open the directory/file, clear path and return failure.
			_path = nil;
			return NO;
		}
		
		// Create a dispatch source to monitor the directory/file for various events.
		// DISPATCH_VNODE_WRITE: For file content changes (writing, truncating) and directory content changes (file/subdir creation/deletion/renaming).
		// DISPATCH_VNODE_DELETE: For when the watched file/directory itself is deleted.
		// DISPATCH_VNODE_ATTRIB: For changes to attributes (permissions, ownership, last access/modification time).
		// DISPATCH_VNODE_EXTEND: For when the file is extended (e.g., appended to).
		// DISPATCH_VNODE_LINK: For changes to the link count.
		// DISPATCH_VNODE_RENAME: For when the watched file/directory itself is renamed.
		// DISPATCH_VNODE_REVOKE: For when access to the file descriptor is revoked (less common, but good for completeness).
		
		_dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, (uintptr_t)_dirFD, self.eventMask, dispatch_get_main_queue());
		
		// Set the event handler for the dispatch source.
		__weak typeof(self) weakSelf = self;
		dispatch_source_set_event_handler(_dispatchSource, ^{
			__strong typeof(weakSelf) strongSelf = weakSelf;
			if (!strongSelf) {
				return; //just in case, may never be called.
			}
			
			// Get the specific event flags that triggered the handler
			unsigned long eventFlags = dispatch_source_get_data(strongSelf->_dispatchSource);
			[strongSelf handleEventWithFlags:eventFlags];
		});
		
		// Set the cancellation handler to close the file descriptor.
		dispatch_source_set_cancel_handler(_dispatchSource, ^{
			__strong typeof(weakSelf) strongSelf = weakSelf;
			if (!strongSelf) {
				return;
			}
			close(strongSelf->_dirFD);
			strongSelf->_dirFD = -1;
		});
		
		// Resume the dispatch source to start monitoring.
		dispatch_resume(_dispatchSource);
		
		return YES;
	}
}

/**
 * Handles a file system event by invoking callbacks and performing cleanup.
 */
- (void)handleEventWithFlags:(unsigned long)flags {

	@synchronized (_lock) {
		// 1. Call the internal hook for subclasses.
		if([self respondsToSelector:@selector(pathDidChangeWithFlags:)]) {
			[self pathDidChangeWithFlags:flags];
		}
		
		// 2. Trigger the appropriate public callback.
		if (self.eventHandler) {
			self.eventHandler(self, flags);
		} else if (self.target && self.selector) {
			// Build the invocation to safely call the selector
			__strong id		target = self.target;
			SEL		selector = self.selector;
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
		
		// 3. If the watched path itself was deleted or renamed, the file descriptor
		// becomes invalid, so we must stop monitoring.
		if (flags & (DISPATCH_VNODE_DELETE | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE)) {
			[self stopMonitoring];
		}
	}
}

- (void)stopMonitoring {
	@synchronized (_lock) {
		// If there is a dispatch source, cancel it. This will trigger the cancel handler.
		if (_dispatchSource) {
			dispatch_source_cancel(_dispatchSource);
			_dispatchSource = nil;
		}
	}
}

#pragma mark - Internal Hooks
/*
 - (void)pathDidChangeWithFlags:(unsigned long)flags {
	// This is an internal method called whenever the path changes.
	// Subclasses can override this method to add custom behavior without
	// interfering with the public callbacks.

	NSLog(@"Internal hook: Path at '%@' changed.", self.path);

	// You can now inspect the 'flags' to determine the specific change
	if (flags & DISPATCH_VNODE_WRITE) {
		NSLog(@"  - Content written or directory contents changed (creation/deletion/rename of children).");
	}
	if (flags & DISPATCH_VNODE_DELETE) {
		NSLog(@"  - Path was deleted. BEPathWatcher will automatically stopMonitoring.");
	}
	if (flags & DISPATCH_VNODE_ATTRIB) {
		NSLog(@"  - Attributes (permissions, modification date, etc.) changed.");
	}
	if (flags & DISPATCH_VNODE_EXTEND) {
		NSLog(@"  - File size extended.");
	}
	if (flags & DISPATCH_VNODE_LINK) {
		NSLog(@"  - Link count changed.");
	}
	if (flags & DISPATCH_VNODE_RENAME) {
		NSLog(@"  - Path was renamed. BEPathWatcher will automatically stopMonitoring.");
	}
	if (flags & DISPATCH_VNODE_REVOKE) {
		NSLog(@"  - Access to the file descriptor was revoked. BEPathWatcher will automatically stopMonitoring.");
	}
}
*/

@end
