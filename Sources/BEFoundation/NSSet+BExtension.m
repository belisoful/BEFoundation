/*!
 @file			NSSet+BExtension.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		NSSet and NSMutableSet BExtension category provides mapping,
 				filtering, and object metadata like Class and
				class name.
 @discussion	The BExtension category extends Foundation's NSSet and NSMutableSet.
*/

#import "NSSet+BExtension.h"

/*!
 @category		BExtension
 @abstract		Adds set mapping, filtering, and object meta functionality.
 @discussion	This category provides map, filter, and objects meta-data
 				methods.
 
 The following methods are provided by this category to `NSSet`:
 
 `-mapUsingBlock:`: Maps each object into a new set; objects mapped to `nil` or rejected by the block are dropped.

 `-objectsClasses`:  Gets and counts  the `Class` of the objects in the set.
 
 `-objectsClassNames`:  Gets and counts  the class name of the objects in the set.
 
 `-objectsUniqueClasses`:  Gets and counts  the `Class` of the objects in the set.
 
 `-objectsUniqueClassNames`:  Gets and counts  the class name of the objects in the set.
 
 `-toClassesFromStrings`: Converts a set of `NSString` into their `Class`.
 
 The following methods are provided by this category to `NSMutableSet`:
 
 `-filterUsingBlock:`: filters the set in place, removing `NULL` mappings and objects the block rejects.
 */
@implementation NSSet (BExtension)



/*!
 @method		-objectsClasses
 @abstract		Gets the `class` of the objects in the set and how many of each
 				there are.
 @discussion 	This loops through each object in the set and gets their
 				`class`.  It adds each object class to the `NSCountedSet`.
 @result		A new `NSCountedSet<Class>`  of the objects' classes and their
 				count.
 */
- (nonnull NSCountedSet<Class> *)objectsClasses
{
	NSCountedSet *classes = NSCountedSet.new;
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
		[classes addObject:[obj class]];
	}];
	return classes;
}


/*!
 @method		-objectsClassNames
 @abstract		Gets the class name of the objects in the set and how many of
 				each there are.
 @discussion 	This loops through each object in the set and gets their class name
				(`NSStringFromClass`).  It adds each object class name to the `NSCountedSet`.
 @result		A new `NSCountedSet<NSString*>`  of the objects' class names and
 				their count.
 */
- (nonnull NSCountedSet<NSString*> *)objectsClassNames
{
	NSCountedSet *classes = NSCountedSet.new;
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
		[classes addObject:NSStringFromClass([obj class])];
	}];
	return classes;
}


/*!
 @method		-objectsUniqueClasses
 @abstract		Gets the unique `class` of the objects in the set and how many
 				of each there are.
 @discussion 	This loops through each object in the set and gets their
				`class`.  It adds each object class to the NSCountedSet.
 @result		A new `NSCountedSet<Class>`  of the objects' classes and their
 				count.
 */
- (nonnull NSCountedSet<Class> *)objectsUniqueClasses
{
	return [self objectsClasses];
}


/*!
 @method		-objectsUniqueClassNames
 @abstract		Gets the unique class name of the objects in the set and how
 				many of each there are.
 @discussion 	This loops through each object in the set and gets their class name
				(`NSStringFromClass`).  It adds each object class name to the NSCountedSet.
 @result		A new `NSCountedSet<NSString*>`  of the objects' class names and
 				their count.
 */
- (nonnull NSCountedSet<NSString*> *)objectsUniqueClassNames
{
	return [self objectsClassNames];
}


/*!
 @method		-toClassesFromStrings
 @abstract		Converts a set of `NSString` class names to a set of `Class`
 				objects.
 @discussion	This method maps each string in the set to its `Class` object
 				using the `NSClassFromString` function.
 
				Only valid class names (strings that match registered class
 				names) are transformed. Invalid or unknown class names map
 				to `nil` and are not included in the result.
 @result		A new object of the same class as the receiver containing
 				the `Class` objects for the class names in the set.
 */
- (instancetype)toClassesFromStrings
{
	return [self mapUsingBlock:^BOOL(id *obj, BOOL *stop) {
		if (![*obj isKindOfClass:NSString.class]) {
			return NO;
		}
		*obj = NSClassFromString(*obj);
		return *obj != NULL;
	}];
}


/*!
 @method		-mapUsingBlock:
 @abstract		Maps each object in the set
 @param			block	The block is applied to each object in the set. The
						block could mutate the object, or set it to `nil` if
						the object should be excluded from the resulting set.
						This must return YES for an object to be included in
						the mapped set.
 @discussion	This method applies a mapping method (via the provided `block`)
				to each object of the set and returns a new @c instancetype
				containing the new mapped objects.
				If object maps to nil or the method returns NO, the object is
				excluded from the new set.
 @result		Returns a new instance of the same Class containing each passing
				object from the `block` function.
 */
- (nonnull instancetype)mapUsingBlock:(BOOL (^_Nullable)(id _Nullable *_Nonnull obj, BOOL *_Nonnull stop))block
{
	if (!block) {
		return [self.class setWithSet:self];
	}
	if (!self.count) {
		return [self.class set];
	}
	// Preserve multiplicity for NSCountedSet: enumeration visits each unique object once, so
	// without re-adding countForObject: times the result would collapse every count to 1.
	NSCountedSet *counted = [self isKindOfClass:NSCountedSet.class] ? (NSCountedSet *)self : nil;
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
		   NSUInteger n = counted ? [counted countForObject:obj] : 1;
		   if (block(&obj, stop) && obj) {
			   for (NSUInteger i = 0; i < n; i++) { [result addObject:obj]; }
		   }
	   }];
	return [self.class setWithArray:result];
}

@end



#pragma mark -

@implementation NSMutableSet (BExtension)

/*!
 @method		-filterUsingBlock:
 @abstract		Filters the NSMutableSet by applying the block to each
 				object in the set.
 @param			filterBlock	The block is applied to each element in the set. Return NO,
 							or set the object to `nil`, to remove the element from
 							the set.
 @discussion	This method applies a transformation and filtering (via `block`)
 				to each object of the set. `obj` can be dereferenced, used,
 				mutated, and the new different element returned within `obj`.
 @result		Returns `self` after filtering its own elements through `block`.
 */
- (nonnull instancetype)filterUsingBlock:(BOOL (^_Nullable)(id _Nullable *_Nonnull obj, BOOL *_Nonnull stop))filterBlock
{
	if (!filterBlock || !self.count) {
		return self;
	}
	
	// Preserve multiplicity for NSCountedSet: enumeration visits each unique object once, so
	// without re-adding countForObject: times an identity filter would collapse counts to 1.
	NSCountedSet *counted = [self isKindOfClass:NSCountedSet.class] ? (NSCountedSet *)self : nil;
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
	[self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
		NSUInteger n = counted ? [counted countForObject:obj] : 1;
		if (filterBlock(&obj, stop) && obj) {
			   for (NSUInteger i = 0; i < n; i++) { [result addObject:obj]; }
		   }
	   }];
	[self removeAllObjects];
	[self addObjectsFromArray:result];
	result = nil;
	
	return self;
}

@end
