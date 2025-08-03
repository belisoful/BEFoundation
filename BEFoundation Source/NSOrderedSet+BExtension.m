/*!
 @file			NSOrderedSet+BExtension.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		NSOrderedSet and NSMutableOrderedSet BExtension category
 				provides mapping, filtering, and object metadata like Class and
 				className.
 @discussion	The BExtension category provides missing functionality to the
				Core Foundation.
*/

#import "NSOrderedSet+BExtension.h"

/*!
 @category		BExtension
 @abstract		Adds set mapping, filtering, and object meta functionality.
 @discussion	This category provides map, filter, and objects meta-date methods.
 
 The following methods are provided by this category to `NSOrderedSet`:
 
 `-map:`: Maps all objects to a new set, removing `NULL` mappings and not passing.
 
 `-objectsClasses`:  Gets and counts  the `Class` of the objects in the set.
 
 `-objectsClassNames`:  Gets and counts  the `className` of the objects in the set.
 
 `-objectsUniqueClasses`:  Gets and counts  the `Class` of the objects in the set.
 
 `-objectsUniqueClassNames`:  Gets and counts  the `className` of the objects in the set.
 
 `-toClassesFromStrings`: Converts a set of `NSString` into their `Class`.
 
 The following methods are provided by this category to `NSMutableOrderedSet`:
 
 `-filter:`: filters all objects to a different set, removing `NULL` mappings and not passing.
 
	These methods provide mapping and class conversion to `NSOrderedSet` and filter for
 `NSMutableOrderedSet`
 */
@implementation NSOrderedSet (BExtension)


/*!
 @method		-objectsClasses
 @abstract		Gets the `class` of the objects in the set and how many of each
				there are.
 @discussion 	This loops through each object in the ordered set and gets their
				`class`.  It adds each object class to the resulting
 				`NSOrderedSet`.
 @result		A new `NSOrderedSet<Class>`  of the objects' classes.
 */
- (nonnull NSOrderedSet<Class> *)objectsClasses
{
	NSMutableOrderedSet *classes = NSMutableOrderedSet.new;
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[classes addObject:[obj class]];
	}];
	return classes.copy;
}


/*!
 @method		-objectsClassNames
 @abstract		Gets the `className` of the objects in the ordered set and how
 				many of each there are.
 @discussion 	This loops through each object in the ordered set and gets their
				`className`.  It adds each object className to the `NSOrderedSet`.
 @result		A new `NSCountedSet<NSString*>`  of the objects' classNames and
				their count.
 */
- (nonnull NSOrderedSet<NSString*> *)objectsClassNames
{
	NSMutableOrderedSet *classes = NSMutableOrderedSet.new;
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[classes addObject:[obj className]];
	}];
	return classes.copy;
}


/*!
 @method		-objectsUniqueClasses
 @abstract		Gets the unique `class` of the objects in the ordered set and
 				how many of each there are.
 @discussion 	This loops through each object in the ordered set and gets their
				`class`.  It adds each object class to the NSCountedSet.
 @result		A new `NSCountedSet<Class>`  of the objects' classes and their
				count.
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
 @abstract		Gets the unique `className` of the objects in the ordered set
 				and how many of each there are.
 @discussion 	This loops through each object in the ordered set and gets their
				`className`.  It adds each object className to the NSCountedSet.
 @result		A new `NSCountedSet<NSString*>`  of the objects' classNames and
				their count.
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
 @abstract		Converts a set of `NSString` class names to an ordered set of
 				`Class` objects.
 @discussion	This method maps each string in the ordered set  to its `Class`
 				object using the `NSClassFromString` function.
 
				Only valid class names (strings that match registered class
				names) are transformed. Invalid or unknown class names will
				return `nil` and will not be included in the result.
 @result		A new Object of the same class as the receiver but containing
				the `Class` objects from to the class name objects in the set.
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

/*!
 @method		-mapUsingBlock
 @abstract		Maps each object in the ordered set
 @param			block	The block is applied to each object in the ordered set.
						The block could mutate the object, or set it to `nil` if
						the object should be excluded from the resulting set.
						This must return YES for an object to be included in
						the new mapped ordered set.
 @discussion	This method applies a mapping method (via the provided `block`)
				to each object of the ordered set and returns a new
				@c instancetype containing the mapped objects.
				If object maps to nil or the method returns NO, the object is
				excluded from the new ordered set.
 @result		Returns a new instance of the same Class containing each passing
				object from the `block` function.
 */
- (nonnull instancetype)mapUsingBlock:(BOOL (^_Nullable)(id _Nullable * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop))block
{
	if (!block) {
		return [self.class orderedSetWithOrderedSet:self];
	}
	if (!self.count) {
		return [self.class orderedSet];
	}
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
	[self enumerateObjectsUsingBlock:^(id currentObject, NSUInteger idx, BOOL *stop) {
		   if (block(&currentObject, idx, stop) && currentObject) {
			   [result addObject:currentObject];
		   }
	   }];
	return [self.class orderedSetWithArray:result];
}

@end


#pragma mark -

@implementation NSMutableOrderedSet (BExtension)

/*!
 @method		-intersectArray:
 @abstract		Removes from the receiving ordered set each object that isn’t a
 				member of the other array.
 @param			other	The array with which to perform the intersection.
 @discussion	UnionArray and MinusArray are implemented by addObjectsFromArray
 				and removeObjectsInArray, respectively
 */
- (void)intersectArray:(NSArray<id> *)other
{
	[self intersectOrderedSet:[NSOrderedSet orderedSetWithArray:other]];
}


/*!
 @method		-setArray:
 @abstract		Sets the ordered set from a NSArray.
 @param			array	The array to set the NSOrderedSet to.
 @discussion	This implements the set method as the get `array` property is
				already in the parent.
 */
- (void)setArray:(nullable NSArray *)array
{
	[self removeAllObjects];
	if (array && array.count) {
		[self addObjectsFromArray:array];
	}
}


/*!
 @method		-setSet:
 @abstract		Sets the ordered set to the NSSet.
 @param			set	The array to set the NSOrderedSet to.
 @discussion	This implements the set method as the get `set` property is
				already in the parent.
 */
- (void)setSet:(nullable NSSet *)set
{
	[self removeAllObjects];
	if (set && set.count) {
		[self addObjectsFromArray:set.allObjects];
	}
}


/*!
 @method		-removeFirstObject
 @abstract		Removes the first object in the receiver ordered set.
 */
- (void)removeFirstObject
{
	if (self.count) {
		[self removeObjectAtIndex:0];
	}
}


/*!
 @method		-removeLastObject
 @abstract		Removes the last object in the receiver ordered set.
 */
- (void)removeLastObject
{
	if (self.count) {
		[self removeObjectAtIndex:self.count - 1];
	}
}


/*!
 @method		-filter:
 @abstract		Filters the the NSMutableOrderedSet by applying the block to
 				each object in the ordered set.
 @param			filterBlock	The block is applied to each element in the ordered
 							set. If it returns NO, or the object is set to `nil`, to
 							remove the element from the orderedset.
 @discussion	This method applies a transformation and filtering (via `block`)
				to each object of the ordered set. `obj` can be dereferenced,
 				used, mutated, and the new different element returned within
 				`obj`.
 @result		Returns `self` after filtering its own elements through `block`.
 */
- (nonnull instancetype)filterUsingBlock:(BOOL (^ _Nullable)(id _Nullable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop))filterBlock
{
	if (!filterBlock || !self.count) {
		return self;
	}
	
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
	[self enumerateObjectsWithOptions:0 usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if (filterBlock(&obj, idx, stop) && obj) {
			[result addObject:obj];
		}
	   }];
	[self setArray:result];
	
	return self;
}

@end


