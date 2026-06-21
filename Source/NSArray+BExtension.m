/*!
 @file			NSArray+BExtension.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/

#import "BEMutable.h"
#import "NSArray+BExtension.h"
//#import "NSDictionary+BExtension.h"

@implementation NSArray (BExtension)

- (NSOrderedSet *)orderedSet {
	return [NSOrderedSet orderedSetWithArray:self];
}

- (NSSet *)set {
	return [NSSet setWithArray:self];
}


/*!
	@method		-objectsClasses
	@abstract	Returns the `class` of each element in the array.
	@discussion Iterates the receiver and collects `[obj class]` for every element. Duplicates
				are preserved — the result has one entry per element, in order.
	@result		A new `NSArray` of `Class` objects, one per element.
 */
- (nonnull NSArray<Class> *)objectsClasses
{
	NSMutableArray *classes = NSMutableArray.new;
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[classes addObject:[obj class]];
	}];
	return classes.copy;
}


/*!
	@method		-objectsClassNames
	@abstract	Returns the `className` of each element in the array.
	@discussion Iterates the receiver and collects `[obj className]` for every element. Duplicates
				are preserved — the result has one entry per element, in order.
	@result		A new `NSArray` of `NSString` class names, one per element.
 */
- (nonnull NSArray<NSString*> *)objectsClassNames
{
	NSMutableArray *classes = NSMutableArray.new;
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[classes addObject:NSStringFromClass([obj class])];
	}];
	return classes.copy;
}


/*!
	@method		-objectsUniqueClasses
	@abstract	Returns a counted set of the `class` of each element.
	@discussion Iterates the receiver, collecting `[obj class]` into an NSCountedSet that tracks
				both uniqueness and the number of occurrences of each class.
	@result		A new `NSCountedSet` of unique `Class` objects with their occurrence counts.
 */
- (nonnull NSCountedSet<Class> *)objectsUniqueClasses
{
	NSCountedSet *classes = NSCountedSet.new;
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[classes addObject:[obj class]];
	}];
	return classes;
}


/*!
	@method		-objectsUniqueClassNames
	@abstract	Returns a counted set of the `className` of each element.
	@discussion Iterates the receiver, collecting `[obj className]` into an NSCountedSet that
				tracks both uniqueness and the number of occurrences of each class name.
	@result		A new `NSCountedSet` of unique class-name strings with their occurrence counts.
 */
- (nonnull NSCountedSet<NSString*> *)objectsUniqueClassNames
{
	NSCountedSet *classes = NSCountedSet.new;
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[classes addObject:NSStringFromClass([obj class])];
	}];
	return classes;
}


/*!
	@method		-toClassesFromStrings
	@abstract	Maps an array of class-name strings to the corresponding `Class` objects.
	@discussion Maps each string element via `NSClassFromString`. Non-string elements and names
				with no registered class (where `NSClassFromString` returns nil) are filtered out.
	@result		A new array of `Class` objects for the valid class names in the receiver.
 */
- (instancetype)toClassesFromStrings
{
	return [self mapUsingBlock:^BOOL(id *obj, NSUInteger idx, BOOL *stop) {
		if (![*obj isKindOfClass:NSString.class]) {
			return NO;
		}
		*obj = NSClassFromString(*obj);
		return YES;
	}];
}


- (nonnull NSArray *)arrayByInsertingObjectsFromArray:(nonnull NSArray *)otherArray atIndex:(NSUInteger)index {
	// Validate parameters
	if (otherArray == nil) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: nil array argument", NSStringFromClass(NSArray.class), NSStringFromSelector(_cmd)];
	} else if (![otherArray isKindOfClass:NSArray.class]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: argument not an NSArray", NSStringFromClass(NSArray.class), NSStringFromSelector(_cmd)];
	} else if (index > self.count) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: index more than %@", NSStringFromClass(NSArray.class), NSStringFromSelector(_cmd), @(self.count)];
	}
	
	// Handle empty array case
	if (otherArray.count == 0) {
		return [self copy];
	}
	
	// Create mutable copy for building the result
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count + otherArray.count];
	
	// Add objects before insertion point
	if (index > 0) {
		[result addObjectsFromArray:[self subarrayWithRange:NSMakeRange(0, index)]];
	}
	
	// Add objects from other array
	[result addObjectsFromArray:otherArray];
	
	// Add remaining objects after insertion point
	if (index < self.count) {
		[result addObjectsFromArray:[self subarrayWithRange:NSMakeRange(index, self.count - index)]];
	}
	
	return [result copy];
}


- (nonnull instancetype)mapUsingBlock:(BOOL (^_Nullable)(id _Nullable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop))block
{
	if (!block) {
		return [self.class arrayWithArray:self];
	}
	if (!self.count) {
		return [self.class array];
	}
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
	[self enumerateObjectsUsingBlock:^(id currentObject, NSUInteger idx, BOOL *stop) {
		   if (block(&currentObject, idx, stop) && currentObject) {
			   [result addObject:currentObject];
		   }
	   }];
	if ([self isKindOfClass:NSMutableArray.class]) {
		return result;
	}
	return [self.class arrayWithArray:result];
}

@end



/*!
	@category   BExtension
	@discussion	adds basic filter function
 */
@implementation NSMutableArray (BExtension)


- (void)removeFirstObject
{
	if (self.count) {
		[self removeObjectAtIndex:0];
	}
}

- (void)insertObjects:(nonnull NSArray *)objects atIndex:(NSUInteger)index
{
	// Validate parameters
	if (objects == nil) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: nil array argument", NSStringFromClass(NSArray.class), NSStringFromSelector(_cmd)];
	} else if (![objects isKindOfClass:NSArray.class]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: argument not an NSArray", NSStringFromClass(NSArray.class), NSStringFromSelector(_cmd)];
	} else if (index > self.count) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: index more than %@", NSStringFromClass(NSArray.class), NSStringFromSelector(_cmd), @(self.count)];
	}
	
	// Handle empty array case
	if (objects.count == 0) {
		return;
	}
	
	// Create an index set for the insertion range
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, objects.count)];
	
	// Insert the objects at the specified indexes
	[self insertObjects:objects atIndexes:indexSet];
}

- (void)setOrderedSet:(nullable NSOrderedSet *)other {
	[self setArray:other.array];
}

- (void)setSet:(nullable NSSet *)other {
	[self setArray:other.allObjects];
}


/*!
	@method     -filterUsingBlock:
	@abstract   This runs each element through the block.
	@param      filterBlock		A function block to process each element. Return `NO`, or set
								`*obj` to nil, to remove the element.
	@discussion This processes each element in the array.  If the block returns `NO` or sets
				the element to nil, the element is removed.
	@result		Returns self after filtering.
 */
- (nonnull instancetype)filterUsingBlock:(BOOL (^_Nullable)(id _Nullable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop))filterBlock
{
	if (!filterBlock || !self.count) {
		return self;
	}
	
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
	[self enumerateObjectsWithOptions:0 usingBlock:^(id currentObject, NSUInteger idx, BOOL *stop) {
		if (filterBlock(&currentObject, idx, stop) && currentObject) {
			[result addObject:currentObject];
		}
	   }];
	[self setArray:result];
	
	return self;
}

@end
