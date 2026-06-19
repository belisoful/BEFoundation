#import <TargetConditionals.h>
#if TARGET_OS_OSX
/*!
 @file          BEWindowControllerManager.m
 @copyright     -© 2025 Delicense - @belisoful. All rights released.
 @date          2025-11-11
 @author        belisoful@icloud.com
 @abstract      Implementation of the `BEWindowControllerManager` class.
*/

#import "BEWindowControllerManager.h"
#import "BEWindowController.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @category      BEWindowControllerManager ()
 @abstract      Private class extension for `BEWindowControllerManager`.
 @discussion    Holds the private mutable ivar for storing window controllers.
*/
@interface BEWindowControllerManager ()
	/*!
	 @var           _windowControllers
	 @abstract      The mutable backing store for all tracked controllers.
	 @discussion    This array is the single source of truth for the manager.
					It holds strong references to the window controllers.
	 */
@property (nonatomic, strong) NSMutableArray<NSWindowController *> *mutableWindowControllers;

@end


@implementation BEWindowControllerManager

/*!
 @method        sharedManager
 @abstract      Returns the application-wide shared manager instance (thread-safe singleton).
 @discussion    The instance is created once via `dispatch_once` and persists for the
				application lifetime. It begins observing window load/close notifications on
				creation. `-init` remains usable for isolated instances (e.g. tests).
 @result        The shared `BEWindowControllerManager`.
*/
+ (instancetype)sharedManager
{
	static BEWindowControllerManager *shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[self alloc] init];
	});
	return shared;
}

/*!
 @method        init
 @abstract      Initializes the manager.
 @discussion    Sets up the internal storage and, most importantly, subscribes to
				`BEWindowDidLoadNotification` and `NSWindowWillCloseNotification`
				to automatically manage the list of controllers.
 @result        A new `BEWindowControllerManager` instance.
*/
- (instancetype)init {
	self = [super init];
	if (self) {
		_mutableWindowControllers = [NSMutableArray arrayWithCapacity:8];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(windowDidLoad:)
													 name:BEWindowDidLoadNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(windowWillClose:)
													 name:NSWindowWillCloseNotification
												   object:nil];
	}
	return self;
}


/*!
 @method        dealloc
 @abstract      Cleans up the manager.
 @discussion    Removes the observer from the notification center and releases the
				controller storage.
*/
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Notification Handlers

/*!
 @method        windowDidLoad:
 @abstract      Notification handler for `BEWindowDidLoadNotification`.
 @discussion    Called when a `BEWindowController`'s window has loaded. This method
				adds the new controller to the tracking array if it's not
				already present.
 @param         notification The notification object. The `object` is the `NSWindow`
				that loaded.
*/
- (void)windowDidLoad:(NSNotification *)notification
{
	NSWindow *window = notification.object;
	if (![window isKindOfClass:[NSWindow class]]) {
		return;
	}
	
	NSWindowController *controller = window.windowController;
	@synchronized (self) {
		if (controller && ![self.mutableWindowControllers containsObject:controller]) {
			[self.mutableWindowControllers addObject:controller];
		}
	}
}


/*!
 @method        windowWillClose:
 @abstract      Notification handler for `NSWindowWillCloseNotification`.
 @discussion    This method performs two crucial tasks:
				1.  **Cascade Close:** It checks if the closing window (`controller`)
					is a parent to any other tracked controllers. If it is, it
					recursively finds all descendants and calls `close` on them
					to ensure child windows never outlive their parent.
				2.  **Cleanup:** It removes the `controller` that is closing (and all of
					its cascade-closed descendants) from the `mutableWindowControllers`
					tracking array.

				The descendant search uses a visited set, so it is idempotent and safe
				against cyclic parent graphs. Descendants are removed from tracking BEFORE
				`-close` is sent, so a controller whose `-close` is overridden to defer
				(e.g. a confirmation sheet) is not leaked by the tracking array.
 @param         notification The notification object. The `object` is the `NSWindow`
				that is about to close.
*/
- (void)windowWillClose:(NSNotification *)notification
{
	NSWindow *window = notification.object;
	if (![window isKindOfClass:[NSWindow class]]) {
		return;
	}

	NSWindowController *controller = window.windowController;
	if (!controller) {
		return;
	}

	// Only react to windows we track; the observer uses object:nil, so otherwise every
	// window close in the app would trigger a cascade scan.
	@synchronized (self) {
		if (![self.mutableWindowControllers containsObject:controller]) {
			return;
		}
	}

	// Cascade close — BFS over descendants. `visited` keeps it idempotent and cycle-safe.
	NSMutableArray<NSWindowController *> *controllersToClose = [NSMutableArray array];
	NSMutableSet<NSWindowController *> *visited = [NSMutableSet setWithObject:controller];
	NSMutableArray<NSWindowController *> *queue = [NSMutableArray arrayWithObject:controller];

	while (queue.count > 0) {
		NSWindowController *parent = queue.firstObject;
		[queue removeObjectAtIndex:0];

		NSArray<NSWindowController *> *snapshot;
		@synchronized (self) {
			snapshot = [self.mutableWindowControllers copy];
		}
		for (NSWindowController *wc in snapshot) {
			if (![wc conformsToProtocol:@protocol(BEChildWindowController)]) {
				continue;
			}

			id<BEChildWindowController> childWC = (id<BEChildWindowController>)wc;
			if (childWC.parentController == parent && ![visited containsObject:wc]) {
				[visited addObject:wc];
				[controllersToClose addObject:wc];
				[queue addObject:wc];
			}
		}
	}

	// Untrack everything up front so removal doesn't rely on each -close re-posting the
	// close notification (an overridden -close may defer it).
	@synchronized (self) {
		[self.mutableWindowControllers removeObject:controller];
		[self.mutableWindowControllers removeObjectsInArray:controllersToClose];
	}

	for (NSWindowController *wc in controllersToClose) {
		[wc close];
	}
}

#pragma mark Window Controller Getters

/*!
 @method        windowControllers
 @abstract      Getter for the `windowControllers` property.
 @discussion    Honors the `copy` attribute by returning an immutable snapshot
				of the internal mutable array.
 @result        An `NSArray` copy of the tracked controllers.
*/
- (NSArray<NSWindowController *> *)windowControllers {
	@synchronized (self) {
		return [self.mutableWindowControllers copy];
	}
}

/*!
 @method        firstWindowControllerOfKind:
 @abstract      Finds the first window controller that is an instance of a given class.
 @param         wcClass The `Class` to search for.
 @result        The matching `NSWindowController`, or `nil` if not found.
*/
- (nullable NSWindowController *)firstWindowControllerOfKind:(nullable Class)wcClass
{
	if (!wcClass) {
		return nil;
	}
	@synchronized (self) {
		for (NSWindowController *wc in self.mutableWindowControllers) {
			if ([wc isKindOfClass:wcClass]) {
				return wc;
			}
		}
	}
	return nil;
}

/*!
 @method        windowControllersOfKind:
 @abstract      Finds all window controllers that are instances of a given class.
 @param         wcClass The `Class` to search for.
 @result        An array of matching `NSWindowController` instances.
*/
- (NSArray<NSWindowController *> *)windowControllersOfKind:(nullable Class)wcClass
{
	if (!wcClass) {
		return @[];
	}

	NSMutableArray *matches = [NSMutableArray array];
	@synchronized (self) {
		for (NSWindowController *wc in self.mutableWindowControllers) {
			if ([wc isKindOfClass:wcClass]) {
				[matches addObject:wc];
			}
		}
	}
	return [matches copy];
}

#pragma mark Subscript Getters and Enumeration


/*!
 @method        objectAtIndexedSubscript:
 @abstract      Provides support for indexed subscripting (e.g., `manager[0]`).
 @param         idx The index of the window controller to retrieve.
 @return        The `NSWindowController` at the specified index.
*/
- (nullable NSWindowController *)objectAtIndexedSubscript:(NSUInteger)idx
{
	@synchronized (self) {
		if (idx >= self.mutableWindowControllers.count) {
			return nil;
		}
		return self.mutableWindowControllers[idx];
	}
}


/*!
 @method        objectForKeyedSubscript:
 @abstract      Provides support for keyed subscripting (e.g., `manager[MyClass.class]`).
 @param         key A `Class` object.
 @return        The first matching `NSWindowController`, or `nil`.
*/
- (nullable NSWindowController *)objectForKeyedSubscript:(Class)key
{
	return [self firstWindowControllerOfKind:key];
}

/*!
 @method        countByEnumeratingWithState:objects:count:
 @abstract      Provides support for `NSFastEnumeration` (e.g., `for...in` loops).
 @discussion    Enumerates over the internal `mutableWindowControllers` array. Intended for
				main-thread use; do not mutate the manager from another thread during a
				for-in loop.
 @param         state A structure to hold the state of the enumeration.
 @param         stackbuf A C-style array buffer for returned objects.
 @param         len The maximum number of objects to return in `stackbuf`.
 @return        The number of objects returned in `stackbuf`.
*/
- (NSUInteger)countByEnumeratingWithState:(nonnull NSFastEnumerationState *)state objects:(__unsafe_unretained id _Nonnull [_Nonnull])stackbuf count:(NSUInteger)len
{
	// Enumerate the live array (lifetime-correct). Like any NSMutableArray, mutating during
	// a for-in over the manager raises "mutated while being enumerated"; iterate the
	// `windowControllers` snapshot if you need to mutate while looping. A per-call snapshot
	// can't be used: fast enumeration vends __unsafe_unretained pointers an autoreleased copy
	// could outlive.
	@synchronized (self) {
		return [self.mutableWindowControllers countByEnumeratingWithState:state objects:stackbuf count:len];
	}
}


@end

NS_ASSUME_NONNULL_END
#endif // TARGET_OS_OSX
