#import <TargetConditionals.h>
#if TARGET_OS_OSX
/*!
 @file       BETabView.m
 @copyright  -© 2025 Delicense - @belisoful. All rights released.
 @date       2025-11-11
 @author     belisoful@icloud.com
 @abstract   Implementation of BETabView with dynamic tab visibility support.
 @discussion This implementation extends NSTabView to support hiding and showing tabs
			 while maintaining their position in the tab order. Uses associated objects
			 to track hidden state and synchronization to ensure thread safety.
			 
			 Key implementation details:
			 - Associated objects store hidden state on NSTabViewItem instances
			 - @synchronized ensures thread-safe access to internal state
			 - Delegate is temporarily disabled during hide/show to prevent unwanted callbacks
			 - Position preservation uses display index calculation
			 - Weak reference (hiddenTabView) prevents retain cycles
 */

#import "BETabView.h"
#import <objc/runtime.h>


#pragma mark - Zeroing-Weak Back-Reference Wrapper

/*!
 @class      BEWeakTabViewRef
 @abstract   A tiny box holding a zeroing-weak reference to a BETabView.
 @discussion Associated objects cannot be stored with true (zeroing) weak semantics —
			 OBJC_ASSOCIATION_ASSIGN leaves a dangling pointer once the BETabView
			 deallocates. We instead retain a wrapper that itself holds a __weak pointer,
			 so the reference automatically becomes nil on dealloc (no use-after-free) and
			 no retain cycle is created (the wrapper does not retain the tab view).
 */
@interface BEWeakTabViewRef : NSObject
@property (nonatomic, weak) BETabView *tabView;
@end

@implementation BEWeakTabViewRef
@end


#pragma mark - NSTabViewItem Hidden Extension

/*!
 @category   NSTabViewItem (TabViewItemHidden)
 @abstract   Implementation of hidden property support for tab items.
 @discussion Uses associated objects to store the hidden state. The hidden property
			 setter validates that the item belongs to a BETabView before performing
			 hide/show operations to prevent misuse with standard NSTabView instances.
			 
			 The hiddenTabView property maintains a zeroing-weak reference to the owning
			 BETabView (via a retained BEWeakTabViewRef wrapper), which does not retain the
			 tab view. This prevents retain cycles since BETabView retains all items in its
			 allTabViewItems array, and prevents a dangling pointer if the BETabView
			 deallocates while an item still references it.
 */
@implementation NSTabViewItem (TabViewItemHidden)

/*!
 @method     hidden
 @abstract   Returns whether this tab item is currently hidden.
 @discussion Retrieves the hidden state from associated objects. The state is stored
			 as an NSNumber wrapped BOOL value.
			 
			 Returns NO by default if the hidden state has never been set, which is
			 correct since tabs are visible by default.
 @return     YES if the tab is hidden, NO if visible or state not set.
 */
- (BOOL)hidden
{
	NSNumber *hidden = objc_getAssociatedObject(self, @selector(hidden));
	return [hidden boolValue];
}

/*!
 @method     setHidden:
 @abstract   Sets the hidden state of this tab item.
 @param      hidden YES to hide the tab, NO to show it.
 @discussion This method validates that the tab belongs to a BETabView instance
			 before attempting to hide/show operations. This prevents programming
			 errors where developers might try to use the hidden property with a
			 standard NSTabView, which doesn't support this functionality.
			 
			 The method retrieves the owning BETabView from either:
			 - self.tabView (if the tab is currently visible)
			 - self.hiddenTabView (if the tab is currently hidden)
			 
			 If the current hidden state matches the requested state, no action is taken.
			 
			 Implementation notes:
			 - Uses isKindOfClass: instead of isMemberOfClass: to support BETabView subclasses
			 - Raises exception for non-BETabView instances to fail fast
			 - Delegates actual hide/show to BETabView methods
 @exception  NSInternalInconsistencyException Raised if the tab is not in a BETabView.
 */
- (void)setHidden:(BOOL)hidden
{
	BETabView *tabView = (BETabView*)(self.tabView ?: self.hiddenTabView);
	if (!tabView) {
		objc_setAssociatedObject(self, @selector(hidden), @(hidden), OBJC_ASSOCIATION_RETAIN);
		return;
	}
	if (![tabView isKindOfClass:[BETabView class]]) {
		[NSException raise:NSInternalInconsistencyException
					format:@"Error in %@::%@: NSTabView does not support NSTabViewItem.hidden; use BETabView rather than NSTabView for hidden tabs.",
					self.className, NSStringFromSelector(_cmd)];
	}
	if (hidden != [self hidden]) {
		if (hidden) {
			[tabView hideTabViewItem:self];
		} else {
			[tabView showTabViewItem:self];
		}
	}
}

/*!
 @method     hiddenTabView
 @abstract   Returns the BETabView that owns this item when it is hidden.
 @discussion Retrieves the weak reference to the owning BETabView from associated objects.
			 This property is automatically set by BETabView when a tab is added and
			 cleared when removed.
			 
			 The weak reference is critical to prevent retain cycles:
			 - BETabView retains tab items in allTabViewItems
			 - Tab items need reference back to BETabView
			 - Weak reference breaks the potential cycle
 @return     The BETabView that owns this tab, or nil if not set or deallocated.
 */
- (BETabView*)hiddenTabView
{
	BEWeakTabViewRef *ref = objc_getAssociatedObject(self, @selector(hiddenTabView));
	return ref.tabView; // nil automatically if the BETabView has deallocated
}

/*!
 @method     setHiddenTabView:
 @abstract   Sets the BETabView that owns this item when hidden.
 @param      hiddenTabView The BETabView to associate with this item.
 @discussion Stores a zeroing-weak reference by retaining a BEWeakTabViewRef wrapper whose
			 inner pointer is __weak. This does not retain the tab view (no retain cycle) and
			 becomes nil automatically if the tab view deallocates (no dangling pointer).

			 This property is managed automatically by BETabView:
			 - Set when tab is added to BETabView
			 - Used to find owner when tab is hidden
			 - Cleared when tab is removed from BETabView

			 Client code should not set this property manually.
 */
- (void)setHiddenTabView:(BETabView *)hiddenTabView
{
	BEWeakTabViewRef *ref = nil;
	if (hiddenTabView) {
		ref = [[BEWeakTabViewRef alloc] init];
		ref.tabView = hiddenTabView;
	}
	objc_setAssociatedObject(self, @selector(hiddenTabView), ref, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


#pragma mark - NSTabView Identifier Extension

/*!
 @category   NSTabView (TabViewItemIdentifier)
 @abstract   Implementation of identifier-based tab lookup.
 @discussion Provides a convenience method to find tabs by identifier, complementing
			 the existing indexOfTabViewItemWithIdentifier: method. This makes it
			 easier to work with tabs using identifiers without needing a separate
			 index lookup step.
 */
@implementation NSTabView (TabViewItemIdentifier)

/*!
 @method     tabViewItemWithIdentifier:
 @abstract   Returns the visible tab with the specified identifier.
 @param      identifier The identifier to search for (compared using isEqual:).
 @discussion Uses the existing indexOfTabViewItemWithIdentifier: method to find
			 the tab's index, then retrieves it using tabViewItemAtIndex:.
			 
			 This only searches visible tabs (tabViewItems array). For BETabView,
			 use allTabViewItemWithIdentifier: to search all tabs including hidden ones.
			 
			 Returns nil for nil identifier to provide safe behavior.
 @return     The matching tab item, or nil if not found or identifier is nil.
 */
- (NSTabViewItem *)tabViewItemWithIdentifier:(id)identifier
{
	if (!identifier) {
		return nil;
	}
	NSInteger index = [self indexOfTabViewItemWithIdentifier:identifier];
	if (index == NSNotFound) {
		return nil;
	}
	return [self tabViewItemAtIndex:index];
}

@end


#pragma mark - BETabView Implementation

/*!
 @implementation      BETabView
 @abstract   Implementation of tab view with hide/show support.
 @discussion Maintains a complete array of all tabs (allTabViewItems) alongside the
			 inherited visible tabs array (tabViewItems). Hidden tabs are tracked
			 using associated objects on the NSTabViewItem instances.
			 
			 Threading:
			 Like every NSView, BETabView must be used on the main thread; the AppKit
			 operations it performs (super add/remove, selection, drawing) are not
			 thread-safe and @synchronized does not change that. The @synchronized(self)
			 guarding the internal _allTabViewItems array exists only to keep that
			 bookkeeping consistent — it is not a license to drive the view off-main.

			 Delegate management:
			 When hiding/showing tabs, the delegate is temporarily set to nil to
			 prevent standard NSTabView delegate callbacks (like willSelectTabViewItem)
			 that would be confusing during these operations. Custom hide/show delegate
			 methods are called explicitly. If hiding the selected tab moves the selection,
			 tabView:didSelectTabViewItem: is sent once for the new selection.

			 Number-of-items notifications:
			 tabViewDidChangeNumberOfTabViewItems: tracks the count of ALL tabs
			 (allTabViewItems). Adding or removing a tab — visible or hidden — changes that
			 count and fires the notification; hiding/showing does NOT change the all-tabs
			 count and so does not fire it (use the didHide/didShow callbacks instead).

			 Position preservation:
			 Hidden tabs maintain their position in allTabViewItems. When shown, they
			 are inserted back into tabViewItems at a position that maintains the
			 relative order from allTabViewItems, accounting for other hidden tabs.
 */
@implementation BETabView
{
	NSMutableArray<NSTabViewItem*> *_allTabViewItems;
}

// allTabViewItems/numberOfAllTabViewItems are implemented manually, NOT @synthesize'd: a
// (copy) synthesized setter would store an immutable NSArray in the NSMutableArray ivar.

#pragma mark - Initialization

/*!
 @method     initWithFrame:
 @abstract   Initializes a new BETabView with the specified frame.
 @param      frameRect The frame rectangle for the view in its superview's coordinate system.
 @discussion Calls the superclass initializer and then performs common initialization
			 to set up the allTabViewItems array.
 @return     An initialized BETabView instance.
 */
- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self) {
		[self commonInit];
	}
	return self;
}

/*!
 @method     init
 @abstract   Initializes a new BETabView with a default frame.
 @discussion Calls the superclass initializer and then performs common initialization.
			 The default frame is determined by NSTabView.
 @return     An initialized BETabView instance.
 */
- (instancetype)init {
	self = [super init];
	if (self) {
		[self commonInit];
	}
	return self;
}

/*!
 @method     initWithCoder:
 @abstract   Initializes a BETabView decoded from a nib/storyboard archive.
 @param      coder The NSCoder to decode from.
 @discussion BETabView is Interface-Builder-instantiable. NSTabView decodes its (visible)
			 tab items via super; we then run commonInit so the allTabViewItems bookkeeping
			 and each item's hiddenTabView back-pointer are established. Without this override,
			 correct setup would depend solely on awakeFromNib being invoked.

			 Note: per-item hidden state is stored in associated objects and is NOT archived,
			 so tabs hidden at runtime do not persist across encode/decode. There is no
			 design-time mechanism to mark a tab hidden in Interface Builder.
 @return     An initialized BETabView instance.
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self commonInit];
	}
	return self;
}

/*!
 @method     awakeFromNib
 @abstract   Performs additional initialization after loading from a nib file.
 @discussion Called when the view is unarchived from a nib or storyboard. Initializes
			 the allTabViewItems array with any tabs that were added in Interface Builder.
			 
			 The commonInit check prevents double initialization if the view was
			 already initialized programmatically.
 */
- (void)awakeFromNib {
	[super awakeFromNib];
	[self commonInit];
}

/*!
 @method     commonInit
 @abstract   Shared initialization code for all init paths.
 @discussion Initializes the _allTabViewItems array with any existing tabs from the
			 superclass's tabViewItems array. This ensures that tabs added via
			 Interface Builder or during construction are properly tracked.
			 
			 Also sets the hiddenTabView property on each item to enable the hidden
			 property to function correctly.
			 
			 The nil check prevents double initialization if called multiple times
			 (e.g., from both init and awakeFromNib).
 */
- (void)commonInit
{
	// Idempotent: adopt any not-yet-tracked visible tabs and (re)assert ownership. Handles
	// every init ordering, including tabs added to the superclass between init and
	// awakeFromNib. Hidden tabs aren't in the superclass's list, so they're untouched.
	if (!_allTabViewItems) {
		_allTabViewItems = [NSMutableArray array];
	}

	for (NSTabViewItem *item in self.tabViewItems) {
		if (![_allTabViewItems containsObject:item]) {
			[_allTabViewItems addObject:item];
		}
		item.hiddenTabView = self;
	}
}


#pragma mark - Display Index Calculation

/*!
 @method     displayIndexAtIndex:
 @abstract   Converts an allTabViewItems index to a tabViewItems (display) index.
 @param      index The index in the allTabViewItems array (0-based).
 @discussion This is a convenience method that calls displayIndexAtIndex:insertMode:
			 with insertMode=NO. It's used to determine where a tab appears in the
			 visible tab bar given its position in the complete array.
			 
			 Returns NSNotFound if the tab at the given index is hidden or if the
			 index is out of range.
 @return     The corresponding index in tabViewItems, or NSNotFound.
 */
- (NSInteger)displayIndexAtIndex:(NSInteger)index
{
	return [self displayIndexAtIndex:index insertMode:NO];
}

/*!
 @method     displayIndexAtIndex:insertMode:
 @abstract   Converts an allTabViewItems index to a tabViewItems index with insert mode.
 @param      index The index in the allTabViewItems array (0-based).
 @param      insertMode If YES, allows index to equal count for insertion operations.
 @discussion This method calculates where a tab at a given position in allTabViewItems
			 should appear (or be inserted) in the visible tabViewItems array.
			 
			 The calculation counts how many visible tabs come before the specified
			 index in allTabViewItems. This count becomes the display index.
			 
			 Insert mode behavior:
			 - insertMode=NO (display mode):
			   * Returns NSNotFound if index >= count
			   * Returns NSNotFound if the tab at index is hidden
			   * Used when querying where a visible tab appears
			 
			 - insertMode=YES (insertion mode):
			   * Allows index == count (for appending)
			   * Returns insertion point regardless of hidden state
			   * Used when determining where to insert a newly-shown tab
			 
			 Example with allTabViewItems = [T0, T1(hidden), T2, T3(hidden), T4]:
			 - displayIndexAtIndex:0 insertMode:NO  → 0  (T0 is first visible)
			 - displayIndexAtIndex:1 insertMode:NO  → NSNotFound (T1 is hidden)
			 - displayIndexAtIndex:2 insertMode:NO  → 1  (T2 is second visible)
			 - displayIndexAtIndex:2 insertMode:YES → 1  (insert before T2's position)
			 - displayIndexAtIndex:5 insertMode:YES → 3  (insert after all visible)
 @return     The display index, or NSNotFound if invalid.
 */
- (NSInteger)displayIndexAtIndex:(NSInteger)index insertMode:(BOOL)insertMode
{
	NSInteger count = (NSInteger)_allTabViewItems.count;
	
	// Validate index range
	// Allow index == count only when inserting (for appending)
	if (index < 0 || index > count || (index == count && !insertMode)) {
		return NSNotFound;
	}
	
	// In non-insert mode, return NSNotFound for hidden tabs
	if (!insertMode && index < count && _allTabViewItems[index].hidden) {
		return NSNotFound;
	}
	
	NSInteger visibleCountBefore = 0;
	
	// Count visible tab items before the specified index
	for (NSInteger i = 0; i < index && i < count; i++) {
		NSTabViewItem *item = _allTabViewItems[i];
		if (!item.hidden) {
			visibleCountBefore++;
		}
	}
	
	return visibleCountBefore;
}


#pragma mark - Adding and Removing Tabs

/*!
 @method     addTabViewItem:
 @abstract   Adds a tab item to the end of the tab view.
 @param      tabViewItem The tab item to add (must not be nil).
 @discussion Adds the tab to the end of allTabViewItems and, if not hidden, to the
			 end of the visible tabs array.
			 
			 Process:
			 1. Returns early if tabViewItem is nil or already in allTabViewItems
			 2. Sets hiddenTabView property for hidden state support
			 3. Adds to allTabViewItems array
			 4. If not hidden, calls super to add to visible tabs
			 5. If hidden, manually notifies delegate of tab count change
			 
			 The hiddenTabView property is set to enable the hidden property to
			 function correctly even when the tab is not currently in a tabView.
			 
			 Thread-safe with @synchronized.
 */
- (void)addTabViewItem:(NSTabViewItem *)tabViewItem
{
	@synchronized (self) {
		[self insertTabViewItem:tabViewItem atIndex:(NSInteger)_allTabViewItems.count];
	}
}

/*!
 @method     insertTabViewItem:atIndex:
 @abstract   Inserts a tab item at the specified index in allTabViewItems.
 @param      tabViewItem The tab item to insert (must not be nil).
 @param      index The index in allTabViewItems where the item should be inserted (0-based).
 @discussion Inserts the tab at the specified position in allTabViewItems. If not hidden,
			 also inserts it at the appropriate position in the visible tabs based on
			 how many visible tabs come before it.
			 
			 Process:
			 1. Returns early if tabViewItem is nil or already in allTabViewItems
			 2. Sets hiddenTabView property
			 3. Inserts into allTabViewItems at specified index
			 4. If not hidden:
				- Calculates display index using displayIndexAtIndex:insertMode:YES
				- Calls super to insert at calculated display index
			 5. If hidden, manually notifies delegate
			 
			 The insertMode:YES parameter allows the method to calculate where to
			 insert the tab even if it's going at the end of the array.
			 
			 Thread-safe with @synchronized.
 @exception  NSRangeException Raised by NSMutableArray if index is out of bounds.
 */
- (void)insertTabViewItem:(NSTabViewItem *)tabViewItem atIndex:(NSInteger)index
{
	@synchronized (self) {
		if (!tabViewItem || [_allTabViewItems containsObject:tabViewItem]) {
			return;
		}
		
		tabViewItem.hiddenTabView = self;
		[_allTabViewItems insertObject:tabViewItem atIndex:index];
		
		if (!tabViewItem.hidden) {
			NSInteger displayIndex = [self displayIndexAtIndex:index insertMode:YES];
			
			[super insertTabViewItem:tabViewItem atIndex:displayIndex];
		} else {
			// Manually notify delegate for hidden tabs
			id<BETabViewDelegate> delegate = (id<BETabViewDelegate>)self.delegate;
			
			if ([delegate respondsToSelector:@selector(tabViewDidChangeNumberOfTabViewItems:)]) {
				[delegate tabViewDidChangeNumberOfTabViewItems:self];
			}
		}
	}
}

/*!
 @method     removeTabViewItem:
 @abstract   Removes a tab item from the tab view completely.
 @param      tabViewItem The tab item to remove (must not be nil).
 @discussion Removes the tab from both allTabViewItems and (if visible) the visible
			 tabs array. Unlike hiding, this completely removes the tab from the
			 tab view and it cannot be shown again without re-adding.
			 
			 Process:
			 1. Returns early if tabViewItem is nil or not in allTabViewItems
			 2. If visible, calls super to remove from visible tabs
			 3. If hidden, manually notifies delegate
			 4. Removes from allTabViewItems
			 5. Clears hiddenTabView property
			 
			 After removal, the tab's hiddenTabView property is set to nil to prevent
			 stale references.
			 
			 Thread-safe with @synchronized.
 */
- (void)removeTabViewItem:(NSTabViewItem *)tabViewItem
{
	@synchronized (self) {
		if (!tabViewItem || ![_allTabViewItems containsObject:tabViewItem]) {
			return;
		}
		
		if (!tabViewItem.hidden) {
			[super removeTabViewItem:tabViewItem];
		} else {
			// Manually notify delegate for hidden tabs
			id<BETabViewDelegate> delegate = (id<BETabViewDelegate>)self.delegate;
			
			if ([delegate respondsToSelector:@selector(tabViewDidChangeNumberOfTabViewItems:)]) {
				[delegate tabViewDidChangeNumberOfTabViewItems:self];
			}
		}
		[_allTabViewItems removeObject:tabViewItem];
		tabViewItem.hiddenTabView = nil;
	}
}


#pragma mark - Hiding Tabs

/*!
 @method     hideTabViewItem:
 @abstract   Hides the specified tab item.
 @param      tabViewItem The tab item to hide (must not be nil).
 @discussion Removes the tab from the visible tabs array but keeps it in allTabViewItems
			 at its current position. The tab can be shown again later at the same position.
			 
			 Process:
			 1. Validates tab is in allTabViewItems and not already hidden
			 2. Gets the tab's index for validation
			 3. Calls delegate's willHideTabViewItem: if implemented
			 4. Temporarily saves and clears the delegate reference
			 5. Calls super.removeTabViewItem: to remove from visible tabs
			 6. Restores the delegate reference
			 7. Sets the hidden associated object to YES
			 8. Calls delegate's didHideTabViewItem: if implemented
			 
			 Delegate management:
			 The delegate is temporarily set to nil during removal to prevent
			 NSTabView's standard delegate callbacks (willSelectTabViewItem:, etc.)
			 which would be confusing during hide operations. The custom hide
			 delegate methods are called explicitly before and after.
			 
			 Thread-safe with @synchronized.
 */
- (void)hideTabViewItem:(NSTabViewItem *)tabViewItem
{
	@synchronized (self) {
		if (!tabViewItem) {
			return;
		}
		if (tabViewItem.hidden) {
			return;
		}
		NSInteger index = [self indexOfAllTabViewItem:tabViewItem];
		if (index == NSNotFound) {
			return;
		}
		
		id<BETabViewDelegate> delegate = (id<BETabViewDelegate>)self.delegate;

		// Capture the selection: hiding the selected tab moves it, and we suppress the
		// delegate during the structural removal below, so we report the change ourselves.
		NSTabViewItem *previouslySelected = self.selectedTabViewItem;

		// Notify delegate before hiding
		if ([delegate respondsToSelector:@selector(tabView:willHideTabViewItem:)]) {
			[delegate tabView:self willHideTabViewItem:tabViewItem];
		}

		// Temporarily remove delegate to prevent unwanted callbacks during removal
		id savedDelegate = self.delegate;
		self.delegate = nil;
		[super removeTabViewItem:tabViewItem];
		self.delegate = savedDelegate;

		// Mark as hidden using associated object
		objc_setAssociatedObject(tabViewItem, @selector(hidden), @(YES), OBJC_ASSOCIATION_RETAIN);

		// Notify delegate after hiding
		if ([delegate respondsToSelector:@selector(tabView:didHideTabViewItem:)]) {
			[delegate tabView:self didHideTabViewItem:tabViewItem];
		}

		// If hiding moved the selection off the hidden tab, report the new selection once.
		NSTabViewItem *nowSelected = self.selectedTabViewItem;
		if (previouslySelected == tabViewItem && nowSelected != nil && nowSelected != tabViewItem) {
			if ([delegate respondsToSelector:@selector(tabView:didSelectTabViewItem:)]) {
				[delegate tabView:self didSelectTabViewItem:nowSelected];
			}
		}
	}
}

/*!
 @method     hideTabViewItemAtIndex:
 @abstract   Hides the tab at the specified index in allTabViewItems.
 @param      index The index in the allTabViewItems array (0-based).
 @discussion Convenience method that retrieves the tab at the given index and hides it.
			 Does nothing if the index is out of range (allTabViewItemAtIndex: returns nil).
			 
			 Thread-safe with @synchronized.
 */
- (void)hideTabViewItemAtIndex:(NSInteger)index
{
	@synchronized (self) {
		NSTabViewItem *item = [self allTabViewItemAtIndex:index];
		if (item) {
			[self hideTabViewItem:item];
		}
	}
}

/*!
 @method     hideTabViewItemWithIdentifier:
 @abstract   Hides the tab with the specified identifier.
 @param      identifier The identifier to search for (must not be nil).
 @discussion Finds the tab with matching identifier in allTabViewItems and hides it.
			 Uses isEqual: for comparison.
			 
			 Returns early if identifier is nil (allTabViewItemWithIdentifier: returns nil).
			 Does nothing if no matching tab is found.
			 
			 Thread-safe with @synchronized.
 */
- (void)hideTabViewItemWithIdentifier:(id)identifier
{
	if (!identifier) {
		return;
	}
	
	@synchronized (self) {
		NSTabViewItem *item = [self allTabViewItemWithIdentifier:identifier];
		if (item) {
			[self hideTabViewItem:item];
		}
	}
}


#pragma mark - Showing Tabs

/*!
 @method     showTabViewItem:
 @abstract   Shows a previously hidden tab item.
 @param      tabViewItem The tab item to show (must not be nil).
 @discussion Adds the tab back to the visible tabs array at its preserved position.
			 The position is calculated based on the tab's index in allTabViewItems
			 and how many visible tabs come before it.
			 
			 Process:
			 1. Validates tab is in allTabViewItems and currently hidden
			 2. Gets the tab's index in allTabViewItems
			 3. Calls delegate's willShowTabViewItem: if implemented
			 4. Calculates display index using displayIndexAtIndex:insertMode:YES
			 5. Temporarily saves and clears the delegate reference
			 6. Calls super.insertTabViewItem:atIndex: to add to visible tabs
			 7. Restores the delegate reference
			 8. Sets the hidden associated object to NO
			 9. Calls delegate's didShowTabViewItem: if implemented
			 
			 Delegate management:
			 The delegate is temporarily set to nil during insertion to prevent
			 NSTabView's standard delegate callbacks which would be confusing during
			 show operations. The custom show delegate methods are called explicitly.
			 
			 Position calculation:
			 Uses insertMode:YES to get the correct insertion point even if the tab
			 is being added at the end of the visible tabs array.
			 
			 Thread-safe with @synchronized.
 */
- (void)showTabViewItem:(NSTabViewItem *)tabViewItem
{
	@synchronized (self) {
		if (!tabViewItem) {
			return;
		}
		if (!tabViewItem.hidden) {
			return;
		}
		NSInteger index = [self indexOfAllTabViewItem:tabViewItem];
		if (index == NSNotFound) {
			return;
		}
		
		id<BETabViewDelegate> delegate = (id<BETabViewDelegate>)self.delegate;
		
		// Notify delegate before showing
		if ([delegate respondsToSelector:@selector(tabView:willShowTabViewItem:)]) {
			[delegate tabView:self willShowTabViewItem:tabViewItem];
		}
		
		// Calculate where to insert the tab
		NSInteger displayIndex = [self displayIndexAtIndex:index insertMode:YES];
		
		// Temporarily remove delegate to prevent unwanted callbacks during insertion
		id savedDelegate = self.delegate;
		self.delegate = nil;
		[super insertTabViewItem:tabViewItem atIndex:displayIndex];
		self.delegate = savedDelegate;
		
		// Mark as not hidden using associated object
		objc_setAssociatedObject(tabViewItem, @selector(hidden), @(NO), OBJC_ASSOCIATION_RETAIN);
		
		// Notify delegate after showing
		if ([delegate respondsToSelector:@selector(tabView:didShowTabViewItem:)]) {
			[delegate tabView:self didShowTabViewItem:tabViewItem];
		}
	}
}

/*!
 @method     showTabViewItemAtIndex:
 @abstract   Shows the tab at the specified index in allTabViewItems.
 @param      index The index in the allTabViewItems array (0-based).
 @discussion Convenience method that retrieves the tab at the given index and shows it.
			 Does nothing if the index is out of range (allTabViewItemAtIndex: returns nil).
			 
			 Thread-safe with @synchronized.
 */
- (void)showTabViewItemAtIndex:(NSInteger)index
{
	@synchronized (self) {
		NSTabViewItem *item = [self allTabViewItemAtIndex:index];
		if (item) {
			[self showTabViewItem:item];
		}
	}
}

/*!
 @method     showTabViewItemWithIdentifier:
 @abstract   Shows the tab with the specified identifier.
 @param      identifier The identifier to search for (must not be nil).
 @discussion Finds the tab with matching identifier in allTabViewItems and shows it.
			 Uses isEqual: for comparison.
			 
			 Returns early if identifier is nil (allTabViewItemWithIdentifier: returns nil).
			 Does nothing if no matching tab is found.
			 
			 Thread-safe with @synchronized.
 */
- (void)showTabViewItemWithIdentifier:(id)identifier
{
	if (!identifier) {
		return;
	}
	@synchronized (self) {
		NSTabViewItem *item = [self allTabViewItemWithIdentifier:identifier];
		if (item) {
			[self showTabViewItem:item];
		}
	}
}


#pragma mark - Accessing All Tabs

/*!
 @method     allTabViewItems
 @abstract   Returns an immutable snapshot of all tabs (visible and hidden), in order.
 @discussion Returns a copy, so callers cannot mutate the internal store (use the
			 add/insert/remove/hide/show methods, or the setter, to modify the tabs).
 @return     An array of all tab view items.
 */
- (NSArray<__kindof NSTabViewItem *> *)allTabViewItems
{
	@synchronized (self) {
		return [_allTabViewItems copy];
	}
}

/*!
 @method     setAllTabViewItems:
 @abstract   Replaces all tabs (visible and hidden) with the provided array.
 @param      allTabViewItems The new complete set of tabs, in display order. Items already
			 marked hidden remain hidden; the rest become visible.
 @discussion This implements the documented setter contract that the previous (broken)
			 @synthesize did not: it copies into a mutable backing store, removes the old
			 visible items from the superclass, sets each new item's hiddenTabView
			 back-pointer, and rebuilds the superclass's visible tabs in order. The delegate
			 is suppressed during the structural rebuild; if the rebuild changes the selected
			 tab, tabView:didSelectTabViewItem: is sent once for the new selection.

			 Duplicate entries and NSNull/non-tab entries in the input are ignored (an item
			 can appear at most once). As with NSTabView, each item must not already belong to
			 another tab view.
 */
- (void)setAllTabViewItems:(NSArray<__kindof NSTabViewItem *> *)allTabViewItems
{
	@synchronized (self) {
		// De-duplicate and drop non-tab entries: NSTabView cannot hold the same item twice,
		// and a duplicate would raise in super addTabViewItem: and corrupt the index bookkeeping.
		NSMutableArray<NSTabViewItem *> *sanitized = [NSMutableArray arrayWithCapacity:allTabViewItems.count];
		for (NSTabViewItem *item in (allTabViewItems ?: @[])) {
			if ([item isKindOfClass:[NSTabViewItem class]] && ![sanitized containsObject:item]) {
				[sanitized addObject:item];
			}
		}

		id savedDelegate = self.delegate;
		self.delegate = nil;

		NSTabViewItem *previouslySelected = self.selectedTabViewItem;

		// Tear down the current visible tabs and clear old back-pointers.
		for (NSTabViewItem *item in [self.tabViewItems copy]) {
			[super removeTabViewItem:item];
		}
		for (NSTabViewItem *item in _allTabViewItems) {
			item.hiddenTabView = nil;
		}

		_allTabViewItems = sanitized;

		// Re-establish ownership and rebuild the visible tabs in order.
		for (NSTabViewItem *item in _allTabViewItems) {
			item.hiddenTabView = self;
			if (!item.hidden) {
				[super addTabViewItem:item];
			}
		}

		self.delegate = savedDelegate;

		// A wholesale replace changes the selection; report it once (as hideTabViewItem: does).
		NSTabViewItem *nowSelected = self.selectedTabViewItem;
		if (nowSelected != nil && nowSelected != previouslySelected) {
			id<BETabViewDelegate> delegate = (id<BETabViewDelegate>)savedDelegate;
			if ([delegate respondsToSelector:@selector(tabView:didSelectTabViewItem:)]) {
				[delegate tabView:self didSelectTabViewItem:nowSelected];
			}
		}
	}
}

/*!
 @method     numberOfAllTabViewItems
 @abstract   Returns the total count of all tabs (visible and hidden).
 @discussion This is a convenience property that returns the count of items in the
			 allTabViewItems array. Equivalent to calling allTabViewItems.count.

			 Compare with the inherited numberOfTabViewItems property which returns
			 only the count of visible tabs.
 @return     The number of items in allTabViewItems (>= 0).
 */
- (NSInteger)numberOfAllTabViewItems
{
	return [_allTabViewItems count];
}

/*!
 @method     indexOfAllTabViewItem:
 @abstract   Returns the index of a tab in allTabViewItems.
 @param      tabViewItem The tab item to find (must not be nil).
 @discussion Searches allTabViewItems for the specified tab item using object equality.
			 This searches both visible and hidden tabs.
			 
			 Uses NSArray's indexOfObject: which uses isEqual: for comparison.
 @return     The index in allTabViewItems (0-based), or NSNotFound if not found.
 */
- (NSInteger)indexOfAllTabViewItem:(NSTabViewItem *)tabViewItem
{
	return [_allTabViewItems indexOfObject:tabViewItem];
}

/*!
 @method     allTabViewItemAtIndex:
 @abstract   Returns the tab at the specified index in allTabViewItems.
 @param      index The index in the allTabViewItems array (0-based).
 @discussion Provides direct access to any tab (visible or hidden) by its position
			 in the complete array.
			 
			 Returns nil for out-of-bounds indices instead of raising an exception,
			 which provides safer behavior for client code.
 @return     The tab item at the specified index, or nil if index is out of bounds.
 */
- (NSTabViewItem *)allTabViewItemAtIndex:(NSInteger)index
{
	if (index < 0 || index >= (NSInteger)_allTabViewItems.count) {
		return nil;
	}
	return [_allTabViewItems objectAtIndex:(NSUInteger)index];
}

/*!
 @method     indexOfAllTabViewItemWithIdentifier:
 @abstract   Returns the index of the tab with the specified identifier.
 @param      identifier The identifier to search for (must not be nil).
 @discussion Searches allTabViewItems linearly for a tab whose identifier matches
			 using isEqual:. This searches both visible and hidden tabs.
			 
			 Performance note: This is a linear search. For large numbers of tabs with
			 frequent identifier lookups, consider maintaining a separate dictionary
			 mapping identifiers to tabs.
			 
			 Returns NSNotFound if identifier is nil to provide safe behavior.
 @return     The index in allTabViewItems (0-based), or NSNotFound if not found or
			 identifier is nil.
 */
- (NSInteger)indexOfAllTabViewItemWithIdentifier:(id)identifier
{
	if (!identifier) {
		return NSNotFound;
	}
	NSUInteger count = [_allTabViewItems count];
	for(NSUInteger i = 0; i < count; i++) {
		if ([_allTabViewItems[i].identifier isEqual:identifier]) {
			return (NSInteger)i;
		}
	}
	return NSNotFound;
}

/*!
 @method     allTabViewItemWithIdentifier:
 @abstract   Returns the tab with the specified identifier.
 @param      identifier The identifier to search for (must not be nil).
 @discussion Convenience method that combines indexOfAllTabViewItemWithIdentifier:
			 and allTabViewItemAtIndex:. Searches both visible and hidden tabs.
			 
			 This is useful when you need to access a tab by its identifier without
			 caring whether it's currently visible or hidden.
			 
			 Example:
			 @code
			 NSTabViewItem *settingsTab = [tabView allTabViewItemWithIdentifier:@"settings"];
			 if (settingsTab) {
				 if (settingsTab.hidden) {
					 // Tab exists but is hidden
					 [tabView showTabViewItem:settingsTab];
				 }
				 [tabView selectTabViewItem:settingsTab];
			 }
			 @endcode
 @return     The matching tab item, or nil if not found or identifier is nil.
 */
- (NSTabViewItem *)allTabViewItemWithIdentifier:(id)identifier
{
	if (!identifier) {
		return nil;
	}
	NSInteger index = [self indexOfAllTabViewItemWithIdentifier:identifier];
	if (index == NSNotFound) {
		return nil;
	}
	return [self allTabViewItemAtIndex:index];
}

@end
#endif // TARGET_OS_OSX
