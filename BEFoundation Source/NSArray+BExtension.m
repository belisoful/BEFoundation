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
	@abstract	Gets the `class` of the objects in the set.
	@discussion This method maps each class object in the receiver to its corresponding class name string using
				the `className` method. The result is a new `NSSet` containing class name strings corresponding
				to the class objects in the original set.
 
	@result		A new `NSSet` containing `Class` corresponding to the objects in the receiver set.
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
	@method		-setClassNames
	@abstract	Converts a set of `Class` to a set of object `classNames` (of type `NSString`).
	@discussion This method maps each class object in the receiver to its corresponding class name string using
				the `className` method. The result is a new `NSSet` containing class name strings corresponding
				to the class objects in the original set.
 
	@result		A new `NSSet` containing class name strings corresponding to the class objects in the receiver set.
 */
- (nonnull NSArray<NSString*> *)objectsClassNames
{
	NSMutableArray *classes = NSMutableArray.new;
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[classes addObject:[obj className]];
	}];
	return classes.copy;
}


/*!
	@method		-objectsUniqueClasses
	@abstract	Gets the `class` of the objects in the set.
	@discussion This method maps each class object in the receiver to its corresponding class name string using
				the `className` method. The result is a new `NSSet` containing class name strings corresponding
				to the class objects in the original set.
 
	@result		A new `NSSet` containing `Class` corresponding to the objects in the receiver set.
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
	@abstract	Converts a set of `Class` to a set of object `classNames` (of type `NSString`).
	@discussion This method maps each class object in the receiver to its corresponding class name string using
				the `className` method. The result is a new `NSSet` containing class name strings corresponding
				to the class objects in the original set.
 
	@result		A new `NSSet` containing class name strings corresponding to the class objects in the receiver set.
 */
- (nonnull NSCountedSet<NSString*> *)objectsUniqueClassNames
{
	NSCountedSet *classes = NSCountedSet.new;
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[classes addObject:[obj className]];
	}];
	return classes;
}


/*!
	@method		-toClassesFromStrings
	@abstract	Converts a set of `NSString` representations of class names to a set of `Class` objects.
	@discussion This method maps each string in the receiver (which represents a class name) to the corresponding
				`Class` object using the `NSClassFromString` function. The result is a new `NSSet`
				containing `Class` objects derived from the class name strings in the original set.
 
				Only valid class names (strings that match registered class names) are transformed. Invalid or
				unknown class names will return `nil` and will not be included in the result set.
 
	@result		A new `NSSet` containing `Class` objects corresponding to the class names in the receiver set.
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
					format:@"*** -[%@ %@]: nil array argument", NSArray.className, NSStringFromSelector(_cmd)];
	} else if (![otherArray isKindOfClass:NSArray.class]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: argument not an NSArray", NSArray.className, NSStringFromSelector(_cmd)];
	} else if (index > self.count) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: index more than %@", NSArray.className, NSStringFromSelector(_cmd), @(self.count)];
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
					format:@"*** -[%@ %@]: nil array argument", NSArray.className, NSStringFromSelector(_cmd)];
	} else if (![objects isKindOfClass:NSArray.class]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: argument not an NSArray", NSArray.className, NSStringFromSelector(_cmd)];
	} else if (index > self.count) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: index more than %@", NSArray.className, NSStringFromSelector(_cmd), @(self.count)];
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
	@method     -filterUsingBlock
	@abstract   This runs each element through the block.
	@param      filterBlock		A function block to process each element, removing
								the element if the block returns NULL.
	@discussion This processes each element in the set.  If an element is returned as
				NULL, then it is removed.
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
