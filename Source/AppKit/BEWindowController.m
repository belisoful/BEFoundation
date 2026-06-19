#import <TargetConditionals.h>
#if TARGET_OS_OSX
/*!
 @file          BEWindowController.m
 @copyright     -© 2025 Delicense - @belisoful. All rights released.
 @date          2025-11-11
 @author        belisoful@icloud.com
 @abstract      Implementation of the `BEWindowController` base class.
*/

#import "BEWindowController.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @const         BEWindowDidLoadNotification
 @abstract      Notification posted when a `BEWindowController`'s window has loaded.
*/
NSNotificationName const BEWindowDidLoadNotification = @"BEWindowDidLoadNotification";

@implementation BEWindowController
{
	/*!
	 @var           _childControllers
	 @abstract      The backing store for the `BEParentWindowController` protocol.
	 @discussion    This `NSMutableSet` holds strong references to all child window controllers. It is lazily instantiated when the first child is added.
	*/
	NSMutableSet                *_childControllers;
	
	/*!
	 @var           _parentController
	 @abstract      The backing store for the `BEChildWindowController` protocol.
	 @discussion    This is a weak reference to the parent window controller to prevent retain cycles.
	*/
	__weak NSWindowController   *_parentController;

	/*!
	 @var           _isClosing
	 @abstract      Re-entrancy guard for -close.
	 @discussion    Prevents the document-wide cascade from recursing infinitely when two or
					more controllers in the same document are both primary (A closes B, B's
					cascade closes A, …). Once a controller has begun closing, a re-entrant
					-close is a no-op.
	*/
	BOOL                        _isClosing;
}

/*!
 @method        initWithWindow:
 @abstract      Initializes the window controller with a window.
 @param         window The `NSWindow` to manage.
 @result        An initialized `BEWindowController` instance.
*/
- (instancetype)initWithWindow:(nullable NSWindow *)window
{
	self = [super initWithWindow:window];
	if (self) {
		_isPrimaryWindowController = NO;
	}
	return self;
}

#pragma NSCoder methods

/*!
 @method        supportsSecureCoding
 @abstract      Declares NSSecureCoding support.
 @discussion    Verified against AppKit: although NSWindowController / NSResponder / NSWindow
				do NOT themselves adopt NSSecureCoding, NSKeyedArchiver keys its secure-coding
				check on the most-derived class. Because BEWindowController adopts the protocol,
				it round-trips correctly through requiringSecureCoding:YES + a secure decode.
				The only state this class adds, @c isPrimaryWindowController, is a BOOL
				(secure-coding-safe). The managed NSWindow is not part of this archive (it is
				recreated from the nib on load), so NSWindow's lack of NSSecureCoding adoption
				does not affect decoding.
 @result        YES.
*/
+ (BOOL)supportsSecureCoding
{
	return YES;
}

/*!
 @method        initWithCoder:
 @abstract      Initializes the window controller from an archive (e.g., state restoration).
 @param         coder The `NSCoder` to decode from.
 @result        An initialized `BEWindowController` instance.
*/
- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		_isPrimaryWindowController = [coder decodeBoolForKey:kBEIsPrimaryWindowControllerKey];
	}
	return self;
}

/*!
 @method        encodeWithCoder:
 @abstract      Encodes the window controller's state for archiving.
 @param         coder The `NSCoder` to encode with.
*/
- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	// Use the recommended secure-coding-safe pattern
	[coder encodeBool:self.isPrimaryWindowController forKey:kBEIsPrimaryWindowControllerKey];
}

#pragma NSWindowController load/close

/*!
 @method        windowDidLoad
 @abstract      Called when the window nib has been successfully loaded.
 @discussion    This method calls super, then notifies its delegate via `windowDidLoad:`, and finally posts the global `BEWindowDidLoadNotification`. This ensures delegates and observers can safely perform setup.
*/
- (void)windowDidLoad {
	[super windowDidLoad];
	
	NSNotification *notification = [NSNotification notificationWithName:BEWindowDidLoadNotification object:self.window];
	
	// Notify Delegate, NSWindowDelegate can implement windowDidLoad:(NSNotification*)notification without BEWindowDelegate
	id<BEWindowDelegate> delegate = (id<BEWindowDelegate>)self.window.delegate;
	if ([delegate respondsToSelector:@selector(windowDidLoad:)]) {
		[delegate windowDidLoad:notification];
	}
	
	// Post Notification
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	
}

/*!
 @method        close
 @abstract      Overrides the default `close` method to add hierarchy and document-wide closing logic.
 @discussion    If this is a primary window, it first triggers `closeDocumentWindowControllers` to close all other windows associated with its document.
				It then automatically nils its `parentController` relationship, which causes it to be removed from its parent's list of children.

				Note: closing a controller does NOT itself close or detach its own
				`childControllers`. Recursive closing of descendants is performed by
				`BEWindowControllerManager` in response to `NSWindowWillCloseNotification`. If you
				are not using the manager and need children closed, close them explicitly.

				AppKit window controllers are main-thread-only; call this on the main thread.
*/
- (void)close
{
	// Re-entrancy guard: two primary controllers closing each other would otherwise recurse
	// forever ([super close], which removes self from the document, is never reached).
	if (_isClosing) {
		return;
	}
	_isClosing = YES;

	// If this is the main window, close all other windows for this document first.
	if(self.isPrimaryWindowController) {
		[self closeDocumentWindowControllers];
	}

	// Use the public setter to nil out the parent, which will
	// automatically remove self from the parent's child set.
	[self setParentController:nil];

	[super close];
}

/*!
 @method        closeDocumentWindowControllers
 @abstract      Closes all other window controllers that share the same `document` as this controller.
 @discussion    This method iterates over `self.document.windowControllers` and calls `close` on every controller except for `self`. It copies the array before iteration to prevent mutation-during-enumeration errors.
*/
- (void)closeDocumentWindowControllers
{
	NSDocument *document = self.document;
	
	if (document) {
		// Copy the array to avoid mutation-during-enumeration issues
		// as closing controllers will modify the document's array.
		NSArray *controllers = [document.windowControllers copy];
		
		for(NSWindowController *wc in controllers) {
			if (wc == self) {
				continue;
			}
			[wc close];
		}
	}
}

#pragma mark BEChildWindowControllerBase Protocol Implementation

/*!
 @method        parentController
 @abstract      Gets the parent window controller.
 @result        The parent, or `nil`.
*/
- (nullable NSWindowController *)parentController
{
	return _parentController;
}

/*!
 @method        setParentController:
 @abstract      Sets the parent window controller, updating both the old and new parent's child lists.
 @discussion    This is the core logic for managing the parent-child relationship.
				- If setting a new parent, it adds self to the new parent.
				- If setting to nil, it removes self from the old parent.
 @param         parentController The new parent, or `nil` to remove from the current parent.
*/
- (void)setParentController:(nullable NSWindowController *)parentController
{
	// to set the parent controller, it must conform to BEChildWindowController
	if (![self conformsToProtocol:@protocol(BEChildWindowController)]) {
#ifdef DEBUG
			NSLog(@"ERROR: %@ must conform to %@ to %@", self.className, NSStringFromProtocol(@protocol(BEChildWindowController)), NSStringFromSelector(_cmd));
#endif
		return;
	}

	// No-op on no change; this also terminates the re-entrant round-trip with
	// add/removeChildWindowController:.
	if (_parentController == parentController) {
		return;
	}

	// Detach from the existing parent before attaching to the new one, so reparenting
	// (A -> B) leaves the child in exactly one parent's child set.
	NSWindowController *oldParent = _parentController;
	if (oldParent && [oldParent conformsToProtocol:@protocol(BEParentWindowController)]) {
		id<BEParentWindowController> beOldParent = (id<BEParentWindowController>)oldParent;
		if ([beOldParent containsChildWindowController:self]) {
			[beOldParent removeChildWindowController:self];
		}
	}
	_parentController = nil;

	if (!parentController) {
		return;
	}

	_parentController = parentController;
	if ([parentController conformsToProtocol:@protocol(BEParentWindowController)]) {
		id<BEParentWindowController> beNewParent = (id<BEParentWindowController>)parentController;
		if (![beNewParent containsChildWindowController:self]) {
			[beNewParent addChildWindowController:self];
		}
	} else {
#ifdef DEBUG
		NSLog(@"ERROR: cannot add self/child to Parent Controller class %@ because parent doesn't conform to %@.", parentController.className, NSStringFromProtocol(@protocol(BEParentWindowController)));
#endif
	}
}


#pragma mark BEParentWindowControllerBase Protocol Implementation

/*!
 @method        childControllers
 @abstract      Gets all child window controllers.
 @result        An array of children. Returns an empty array if no children.
*/
- (NSArray*)childControllers
{
	// Return a copy of all objects, or an empty array if the set is nil.
	return _childControllers.allObjects ?: @[];
}

/*!
 @method        containsChildWindowController:
 @abstract      Tests whether the given controller is in this parent's set of children.
 @param         childController The window controller to test for membership.
 @return		YES if the parent window controller contains @c childController.
*/
- (BOOL)containsChildWindowController:(NSWindowController *)childController
{
	return [_childControllers containsObject:childController];
}

/*!
 @method        addChildWindowController:
 @abstract      Adds a window controller to the child set.
 @discussion    Lazily instantiates the `_childControllers` set if this is the first child being added.
 @param         childController The controller to add.
*/
- (void)addChildWindowController:(NSWindowController *)childController
{
	// to set the parent controller, it must conform to BEChildWindowController
	if (![self conformsToProtocol:@protocol(BEParentWindowController)]) {
#ifdef DEBUG
		NSLog(@"ERROR: %@ must conform to %@ to %@", self.className, NSStringFromProtocol(@protocol(BEParentWindowController)), NSStringFromSelector(_cmd));
#endif
		return;
	}

	// -[NSMutableSet addObject:] raises on nil (the nonnull annotation isn't enforced at runtime).
	if (!childController) {
		return;
	}

	if (!_childControllers) {
		_childControllers = [NSMutableSet set];
	}

	[_childControllers addObject:childController];
	
	if ([childController conformsToProtocol:@protocol(BEChildWindowController)]) {
		id<BEChildWindowController> beChildController = (id<BEChildWindowController>) childController;
		if (!beChildController.parentController) {
			((id<BEChildWindowController>)childController).parentController = self;
		} else if (beChildController.parentController != self) {
#ifdef DEBUG
			NSLog(@"ERROR: child.parentController be set to self as parent");
#endif
		}
	}
}

/*!
 @method        removeChildWindowController:
 @abstract      Removes a window controller from the child set.
 @discussion    If removing the last child, the `_childControllers` set is nilled out to release its memory.
 @param         childController The controller to remove.
 @result        `YES` if the controller was found and removed.
*/
- (BOOL)removeChildWindowController:(NSWindowController *)childController
{
	// to set the parent controller, it must conform to BEChildWindowController
	if (![self conformsToProtocol:@protocol(BEParentWindowController)]) {
#ifdef DEBUG
		NSLog(@"ERROR: %@ must conform to %@ to %@", self.className, NSStringFromProtocol(@protocol(BEParentWindowController)), NSStringFromSelector(_cmd));
#endif
		return NO;
	}
	
	
	if (![_childControllers containsObject:childController]) {
		return NO;
	}
	
	[_childControllers removeObject:childController];
	
	if ([childController conformsToProtocol:@protocol(BEChildWindowController)]) {
		id<BEChildWindowController> beChildController = (id<BEChildWindowController>) childController;
		if (beChildController.parentController == self) {
			((id<BEChildWindowController>)childController).parentController = nil;
		} else {
#ifdef DEBUG
			NSLog(@"ERROR: child.parentController is not self and cannot be set to nil");
#endif
		}
	}
	
	// If the set is now empty, nil it out.
	if (!_childControllers.count) {
		_childControllers = nil;
	}
	
	return YES;
}

@end

NS_ASSUME_NONNULL_END
#endif // TARGET_OS_OSX
