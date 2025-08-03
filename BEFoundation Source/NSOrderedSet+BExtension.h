/*!
 @header		NSOrderedSet+BExtension.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract		NSOrderedSet and NSMutableOrderedSet BExtension category
				provides mapping, filtering, and object metadata like Class and
				className.
 @discussion	The BExtension category provides missing functionality to the
				Core Foundation.
*/

#ifndef NSOrderedSet_Extension_h
#define NSOrderedSet_Extension_h

#import <Foundation/Foundation.h>

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
@interface NSOrderedSet <ObjectType> (BExtension)

/*!
 @property		objectsClasses
 @abstract		Gets the `class` of the objects in the set and how many of each
				there are.
 @discussion 	This loops through each object in the ordered set and gets their
				`class`.  It adds each object class to the resulting
				`NSOrderedSet`.
 @result		A new `NSOrderedSet<Class>`  of the objects' classes.
 */
@property (readonly, nonnull) NSOrderedSet<Class> *objectsClasses;

/*!
 @property		objectsClassNames
 @abstract		Gets the `className` of the objects in the ordered set and how
				many of each there are.
 @discussion 	This loops through each object in the ordered set and gets their
				`className`.  It adds each object className to the `NSOrderedSet`.
 @result		A new `NSCountedSet<NSString*>`  of the objects' classNames and
				their count.
 */
@property (readonly, nonnull) NSOrderedSet<NSString*> *objectsClassNames;

/*!
 @property		objectsUniqueClasses
 @abstract		Gets the unique `class` of the objects in the ordered set and
				how many of each there are.
 @discussion 	This loops through each object in the ordered set and gets their
				`class`.  It adds each object class to the NSCountedSet.
 @result		A new `NSCountedSet<Class>`  of the objects' classes and their
				count.
 */
@property (readonly, nonnull) NSCountedSet<Class> *objectsUniqueClasses;

/*!
 @property		objectsUniqueClassNames
 @abstract		Gets the unique `className` of the objects in the ordered set
				and how many of each there are.
 @discussion 	This loops through each object in the ordered set and gets their
				`className`.  It adds each object className to the NSCountedSet.
 @result		A new `NSCountedSet<NSString*>`  of the objects' classNames and
				their count.
 */
@property (readonly, nonnull) NSCountedSet<NSString*> *objectsUniqueClassNames;


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
- (nonnull instancetype)toClassesFromStrings;

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
- (nonnull instancetype)mapUsingBlock:(BOOL (^_Nullable)(ObjectType _Nullable * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop))block;

@end



@interface NSMutableOrderedSet<ObjectType> (BExtension)

/*!
 @method		-intersectArray:
 @abstract		Removes from the receiving ordered set each object that isn’t a
				member of the other array.
 @param			other	The array with which to perform the intersection.
 @discussion	UnionArray and MinusArray are implemented by addObjectsFromArray
				and removeObjectsInArray, respectively
 */
- (void)intersectArray:(nullable NSArray<ObjectType> *)other;

/*!
 @property		array
 @abstract		Sets the ordered set from a NSArray.
 @discussion	This implements the set method as the get `array` property is
 				already in the parent.
 */
@property (readwrite, strong, nullable) NSArray<ObjectType> *array;

/*!
 @property		setSet:
 @abstract		Sets the ordered set to the NSSet.
 @discussion	This implements the set method as the get `set` property is
				already in the parent.
 */
@property (readwrite, strong, nullable) NSSet<ObjectType> *set;

/*!
 @method		-removeFirstObject
 @abstract		Removes the first object in the receiver ordered set.
 */
- (void)removeFirstObject;

/*!
 @method		-removeLastObject
 @abstract		Removes the last object in the receiver ordered set.
 */
- (void)removeLastObject;

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
- (nonnull instancetype)filterUsingBlock:(BOOL (^ _Nullable)(ObjectType _Nullable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop))filterBlock;

@end


#endif	//	NSOrderedSet_Extension_h
