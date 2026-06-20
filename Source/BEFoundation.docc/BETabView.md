# ``BETabView``

An `NSTabView` subclass that supports hiding and showing tabs dynamically.

## Overview

`BETabView` extends `NSTabView` to add the ability to hide and show individual tab items while maintaining their position in the tab order. Hidden tabs are removed from the visible interface but remain in memory and can be shown again at any time.

This is useful for conditional UI where certain tabs should only be visible under specific circumstances, such as:
- Progressive disclosure (show advanced tabs only when needed)
- Permission-based tab visibility
- Wizard-style interfaces with conditional steps
- Dynamic tab bars that adapt to context

![A BETabView whose bar shows General, Advanced, and Privacy, with the Network tab removed because its hidden property is set to YES.](betabview)

## Usage

### Main Class

- [BETabView](doc:BETabView)

### Tab Item Categories

- [NSTabViewItem (TabViewItemHidden)](doc:NSTabViewItem-TabViewItemHidden)
- [NSTabView (TabViewItemIdentifier)](doc:NSTabView-TabViewItemIdentifier)

### Delegate Protocol

- [BETabViewDelegate](doc:BETabViewDelegate)

## Usage

### Basic Tab Hiding and Showing

```objc
BETabView *tabView = [[BETabView alloc] initWithFrame:frame];
tabView.delegate = self;

// Add tabs
NSTabViewItem *basicTab = [[NSTabViewItem alloc] initWithIdentifier:@"basic"];
NSTabViewItem *advancedTab = [[NSTabViewItem alloc] initWithIdentifier:@"advanced"];
[tabView addTabViewItem:basicTab];
[tabView addTabViewItem:advancedTab];

// Hide advanced tab initially
advancedTab.hidden = YES;

// Show it when user upgrades
if (userIsPro) {
    advancedTab.hidden = NO;
}

// Access all tabs including hidden ones
NSLog(@"Total tabs: %ld", tabView.numberOfAllTabViewItems);
```

### Delegate Implementation

```objc
- (void)tabView:(NSTabView *)tabView willHideTabViewItem:(NSTabViewItem *)item {
    NSLog(@"Tab '%@' is about to be hidden", item.label);
}

- (void)tabView:(NSTabView *)tabView didHideTabViewItem:(NSTabViewItem *)item {
    NSLog(@"Tab '%@' was hidden", item.label);
    [self updateTabCount];
}

- (void)tabView:(NSTabView *)tabView willShowTabViewItem:(NSTabViewItem *)item {
    NSLog(@"Tab '%@' is about to be shown", item.label);
}

- (void)tabView:(NSTabView *)tabView didShowTabViewItem:(NSTabViewItem *)item {
    NSLog(@"Tab '%@' was shown", item.label);
    [self refreshTabContent:item];
}
```

### Finding Tabs by Identifier

```objc
// Find visible tab by identifier
NSTabViewItem *settingsTab = [tabView tabViewItemWithIdentifier:@"settings"];
if (settingsTab) {
    [tabView selectTabViewItem:settingsTab];
}

// Find any tab (including hidden) by identifier
NSTabViewItem *hiddenTab = [tabView allTabViewItemWithIdentifier:@"advanced"];
if (hiddenTab) {
    if (hiddenTab.hidden) {
        NSLog(@"Advanced tab exists but is hidden");
    } else {
        [tabView selectTabViewItem:hiddenTab];
    }
}
```

## BETabView

### Properties

#### allTabViewItems

```objc
@property (nonnull, copy) NSArray<__kindof NSTabViewItem *> *allTabViewItems;
```

All tab view items, including both visible and hidden tabs.

This property provides access to all tabs that have been added to the tab view, regardless of their visibility state. The order of items in this array determines the position where tabs will appear when shown.

The inherited `tabViewItems` property returns only visible tabs, while `allTabViewItems` returns all tabs.

#### numberOfAllTabViewItems

```objc
@property (readonly) NSInteger numberOfAllTabViewItems;
```

The total count of all tab view items (visible and hidden).

### Methods

#### hideTabViewItem:

```objc
- (void)hideTabViewItem:(nonnull NSTabViewItem *)tabViewItem;
```

Hides the specified tab view item.

Removes the tab from the visible interface but keeps it in `allTabViewItems`. The tab's position is preserved so it can be shown again at the same location.

#### showTabViewItem:

```objc
- (void)showTabViewItem:(nonnull NSTabViewItem *)tabViewItem;
```

Shows a previously hidden tab view item.

Adds the tab back to the visible interface at its preserved position.

#### hideTabViewItemWithIdentifier:

```objc
- (void)hideTabViewItemWithIdentifier:(nonnull id)identifier;
```

Hides the tab view item with the specified identifier.

#### showTabViewItemWithIdentifier:

```objc
- (void)showTabViewItemWithIdentifier:(nonnull id)identifier;
```

Shows the tab view item with the specified identifier.

#### displayIndexAtIndex:

```objc
- (NSInteger)displayIndexAtIndex:(NSInteger)index;
```

Returns the display index for a tab at the given index in `allTabViewItems`.

#### allTabViewItemWithIdentifier:

```objc
- (nullable NSTabViewItem *)allTabViewItemWithIdentifier:(nonnull id)identifier;
```

Returns the tab with the specified identifier (searches all tabs including hidden).

## NSTabViewItem (TabViewItemHidden)

### Properties

#### hidden

```objc
@property (nonatomic) BOOL hidden;
```

Whether this tab view item is currently hidden.

Setting this property to `YES` hides the tab (removes it from the visible tab bar and content area). Setting it to `NO` shows the tab (adds it back to the visible interface at its preserved position).

This property only works when the tab item is part of a `BETabView`. Using it with a standard `NSTabView` will raise an `NSInternalInconsistencyException`.

## NSTabView (TabViewItemIdentifier)

### Methods

#### tabViewItemWithIdentifier:

```objc
- (nullable NSTabViewItem *)tabViewItemWithIdentifier:(nonnull id)identifier;
```

Returns the visible tab view item with the specified identifier.

For `BETabView`, this only searches visible tabs. To search all tabs including hidden ones, use `allTabViewItemWithIdentifier:` instead.

## BETabViewDelegate

### Optional Methods

#### tabView:willHideTabViewItem:

```objc
- (void)tabView:(nonnull NSTabView *)tabView willHideTabViewItem:(nullable NSTabViewItem *)tabViewItem NS_SWIFT_UI_ACTOR;
```

Notifies delegate that a tab item is about to be hidden.

#### tabView:didHideTabViewItem:

```objc
- (void)tabView:(nonnull NSTabView *)tabView didHideTabViewItem:(nullable NSTabViewItem *)tabViewItem NS_SWIFT_UI_ACTOR;
```

Notifies delegate that a tab item was hidden.

#### tabView:willShowTabViewItem:

```objc
- (void)tabView:(nonnull NSTabView *)tabView willShowTabViewItem:(nullable NSTabViewItem *)tabViewItem NS_SWIFT_UI_ACTOR;
```

Notifies delegate that a tab item is about to be shown.

#### tabView:didShowTabViewItem:

```objc
- (void)tabView:(nonnull NSTabView *)tabView didShowTabViewItem:(nullable NSTabViewItem *)tabViewItem NS_SWIFT_UI_ACTOR;
```

Notifies delegate that a tab item was shown.

## Relationships

See Also: [BEPathControl](doc:BEPathControl), [BEWindowController](doc:BEWindowController)
