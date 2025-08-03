/*!
 @file			BEPriorityExtensions.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract
 @discussion
*/

#import "BE_ARC.h"
#import "BEPriorityExtensions.h"
#import <objc/runtime.h>

NSInteger	const  BEDefaultSortedItemPriority = 0;

@implementation BEPriorityExtensionHelper

+ (NSComparator)priorityComparator
{
	NSNumber *defaultPriority = @(BEDefaultSortedItemPriority);
	return ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
		NSNumber *a, *b;
		
		BOOL aPriorityItem = [obj1 conformsToProtocol:@protocol(BEPriorityItem)];
		BOOL bPriorityItem = [obj2 conformsToProtocol:@protocol(BEPriorityItem)];
		
		if (aPriorityItem) {
			a = [obj1 itemPriority];
		}
		if (!a && [obj1 conformsToProtocol:@protocol(BEPriorityCapture)]) {
			[obj1 setItemPriority:defaultPriority];
			if (aPriorityItem) {
				a = [obj1 itemPriority];
			}
		}
		if (!a) {
			a = defaultPriority;
		}
		if (bPriorityItem) {
			b = [obj2 itemPriority];
		}
		if (!b && [obj2 conformsToProtocol:@protocol(BEPriorityCapture)]) {
			[obj2 setItemPriority:defaultPriority];
			if (bPriorityItem) {
				b = [obj2 itemPriority];
			}
		}
		if (!b) {
			b = defaultPriority;
		}
		
		return [a compare:b];
	};
}
@end



@implementation NSArray (BEPriorityExtensions)

- (NSArray*)sortedArrayUsingItemPriority
{
	return [self sortedArrayWithOptions:NSSortStable usingComparator:BEPriorityExtensionHelper.priorityComparator];
}

@end




@implementation NSMutableArray (BEPriorityExtensions)

- (void)sortArrayUsingItemPriority
{
	[self sortWithOptions:NSSortStable usingComparator:BEPriorityExtensionHelper.priorityComparator];
}

@end



@implementation NSOrderedSet (BEPriorityExtensions)

- (NSArray*)sortedArrayUsingItemPriority
{
	return [self sortedArrayWithOptions:NSSortStable usingComparator:BEPriorityExtensionHelper.priorityComparator];
}

@end



@implementation NSMutableOrderedSet (BEPriorityExtensions)

- (void)sortOrderedSetUsingItemPriority
{
	[self sortWithOptions:NSSortStable usingComparator:BEPriorityExtensionHelper.priorityComparator];
}

@end

