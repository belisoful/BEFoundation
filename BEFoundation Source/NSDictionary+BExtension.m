/*!
 @file			NSDictionary+BExtension.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/

#import <objc/runtime.h>
#import "NSDictionary+BExtension.h"
#import "NSArray+BExtension.h"
#import "BEMutable.h"

@implementation NSDictionary  (BExtension)


- (id)objectAtIndexedSubscript:(NSUInteger)index
{
	NSNumber *indexNumber = @(index);
	id obj = [self objectForKey:indexNumber];
	if (obj) {
		return obj;
	}
	return [self objectForKey:indexNumber.stringValue];
}


/*!
	@method		-objectsClasses
	@abstract	Gets the `class` of the objects in the set.
	@discussion This method maps each class object in the receiver to its corresponding class name string using
				the `className` method. The result is a new `NSSet` containing class name strings corresponding
				to the class objects in the original set.
 
	@result		A new `NSSet` containing `Class` corresponding to the objects in the receiver set.
 */
- (nonnull NSDictionary<id, Class> *)objectsClasses
{
	NSMutableDictionary *classes = NSMutableDictionary.new;
	[self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		[classes setObject:[obj class] forKey:key];
	}];
	return classes.copy;
}


/*!
	@method		-objectsClassNames
	@abstract	Converts a set of `Class` to a set of object `classNames` (of type `NSString`).
	@discussion This method maps each class object in the receiver to its corresponding class name string using
				the `className` method. The result is a new `NSSet` containing class name strings corresponding
				to the class objects in the original set.
 
	@result		A new `NSSet` containing class name strings corresponding to the class objects in the receiver set.
 */
- (nonnull NSDictionary<id, NSString*> *)objectsClassNames
{
	NSMutableDictionary *classes = NSMutableDictionary.new;
	[self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		[classes setObject:[obj className] forKey:key];
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
	[self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
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
	[self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
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
- (nonnull instancetype)toClassesFromStrings
{
	return [self mapUsingBlock:^BOOL(id _Nonnull * _Nonnull key, id _Nullable *_Nonnull obj, BOOL *stop) {
		if (![*obj isKindOfClass:NSString.class]) {
			return NO;
		}
		*obj = NSClassFromString(*obj);
		return YES;
	}];
}

/*!
 
 @note		This method defines the
 */
- (nonnull instancetype)mapUsingBlock:(BOOL (^_Nullable)(id _Nullable *_Nonnull key, id _Nullable *_Nonnull obj, BOOL *_Nonnull stop))block
{
	if (!block) {
		return [self.class dictionaryWithDictionary:self];
	}
	if (!self.count) {
		return [self.class dictionary];
	}
	NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:self.count];
	[self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull currentObject, BOOL *stop) {
		if (block(&key, &currentObject, stop) && key && currentObject) {
			result[key] = currentObject;
		}
	}];
	if ([self isKindOfClass:NSMutableDictionary.class]) {
		return result;
	}
	return [self.class dictionaryWithDictionary:result];
}


- (nonnull instancetype)swapped
{
	return [self mapUsingBlock:^BOOL(id _Nullable *_Nonnull key, id _Nullable *_Nonnull obj, BOOL *stop) {
		if (![*obj conformsToProtocol:@protocol(NSCopying)]) {
			return NO;
		}
		id t = *key;
		*key = *obj;
		*obj = t;
		return YES;
	}];
}

- (id)dictionaryByAddingDictionary:(NSDictionary *)otherDictionary
{
	if (!otherDictionary) {
		return [self copy];
	}
	
	if (![otherDictionary isKindOfClass:NSDictionary.class]) {
		
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: argument is not an NSDictionary",
		 NSMutableDictionary.className, NSStringFromSelector(_cmd)];
	}
	
	if (!otherDictionary.count) {
		return [self copy];
	}
	
	NSMutableDictionary *mergedDict = [self mutableCopy];
	[mergedDict addEntriesFromDictionary:otherDictionary];
	
	if ([self isKindOfClass:NSMutableDictionary.class]) {
		return mergedDict;
	}
	return [self.class dictionaryWithDictionary:mergedDict];
}


- (id)dictionaryByMergingDictionary:(NSDictionary *)otherDictionary
{
	if (!otherDictionary) {
		return [self copy];
	}
	
	if (![otherDictionary isKindOfClass:NSDictionary.class]) {
		
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: argument is not an NSDictionary",
		 NSMutableDictionary.className, NSStringFromSelector(_cmd)];
	}
	
	if (!otherDictionary.count) {
		return [self copy];
	}
	
	NSMutableDictionary *mergedDict = [self mutableCopy];
	[mergedDict mergeEntriesFromDictionary:otherDictionary];
	
	if ([self isKindOfClass:NSMutableDictionary.class]) {
		return mergedDict;
	}
	return [self.class dictionaryWithDictionary:mergedDict];
}

@end



#pragma mark - 

@implementation NSMutableDictionary  (BExtension)

- (void)setIsIndexedSubscriptNumeric:(BOOL)isNumeric {
	objc_setAssociatedObject(self, @selector(isIndexedSubscriptNumeric), @(isNumeric), OBJC_ASSOCIATION_RETAIN);
}

// or String if NO
- (BOOL)isIndexedSubscriptNumeric {
	NSNumber *value = objc_getAssociatedObject(self, @selector(isIndexedSubscriptNumeric));
	__block BOOL useNumeric = NO;
	if (value) {
		useNumeric = value.boolValue;
	} else {
		__block BOOL useString = NO;
		[self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
			if ([key isKindOfClass:NSNumber.class]) {
				useNumeric = YES;
				*stop = true;
			} else if ([key isKindOfClass:NSString.class]) {
				NSScanner *sc = [NSScanner scannerWithString: key];
				if ( [sc scanInteger:NULL] ) {
					useString = [sc isAtEnd];
					*stop = useString;
				}
			}
		}];
		// If nothing is available then default to using Numeric
		if (!useNumeric && !useString) {
			useNumeric = YES;
		}
		objc_setAssociatedObject(self, @selector(isIndexedSubscriptNumeric), @(useNumeric), OBJC_ASSOCIATION_RETAIN);
	}
	return useNumeric;
}

- (void)setObject:(nonnull id)obj atIndexedSubscript:(NSUInteger)idx
{
	NSNumber *index = @(idx);
	[self setObject:obj forKey:self.isIndexedSubscriptNumeric ? index : index.stringValue];
}


- (nonnull instancetype)swap
{
	return [self filterUsingBlock:^BOOL(id _Nullable *_Nonnull key, id _Nullable *_Nonnull obj, BOOL *stop) {
		if (![*obj conformsToProtocol:@protocol(NSCopying)]) {
			return NO;
		}
		id t = *key;
		*key = *obj;
		*obj = t;
		return YES;
	}];
}


/*!
	@method     -filterPairs
	@abstract   This runs each key/value  through the block for new keys
	@param      filterBlock		A function block to process each element, removing
								the element if the block returns NULL.
	@discussion This processes each element in the set.  If an element is returned as
				NULL, then it is removed.
	@result		Returns self after filtering.
 */
- (nonnull instancetype)filterUsingBlock:(BOOL (^_Nullable)(id _Nullable *_Nonnull key, id _Nullable *_Nonnull obj, BOOL *_Nonnull stop))filterBlock
{
	if (!filterBlock || !self.count) {
		return self;
	}
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
	[self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull currentObject, BOOL *stop) {
		if (filterBlock(&key, &currentObject, stop) && key && currentObject) {
			result[key] = currentObject;
		}
	}];
	[self setDictionary:result];
	return self;
}


/*!
	@method     -mergeEntriesFromDictionary
	@abstract   This merges entries of one dictionary into another without overwriting existing entries.
	@param      otherDictionary		The dictionary to merge.
	@discussion Unlike `addEntriesFromDictionary` this does not overwrite existing entries in
 				the mutable dictionary
 */
- (void)mergeEntriesFromDictionary:(NSDictionary *)otherDictionary
{
	if (!otherDictionary) {
		return;
	}
	if (![otherDictionary isKindOfClass:NSDictionary.class]) {
		[NSException raise:NSInvalidArgumentException
								format:@"*** -[%@ %@]: dictionary argument is not an NSDictionary",
									   NSMutableDictionary.className, NSStringFromSelector(_cmd)];
	}
	[otherDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (![self objectForKey:key]) {
			[self setObject:obj forKey:key];
		}
	}];
}

/*!
	@method     -mergeEntriesFromDictionary
	@abstract   This merges entries of one dictionary into another without overwriting existing entries.
	@param      otherDictionary		The dictionary to merge.
	@discussion Unlike `addEntriesFromDictionary` this does not overwrite existing entries in
				the mutable dictionary.  Any mutable collection classes are mutableCopy-ed.
 */
- (void)mergeEntriesFromDictionaryRecursive:(NSDictionary *)otherDictionary
{
	[self mergeEntriesFromDictionaryRecursive:otherDictionary flags:BEDictionaryDefaultCombineFlags];
}

/*!
	@method     -mergeEntriesFromDictionary
	@abstract   This merges entries of one dictionary into another without overwriting existing entries.
	@param      otherDictionary		The dictionary to merge.
	@discussion Unlike `addEntriesFromDictionary` this does not overwrite existing entries in
				the mutable dictionary.  Any mutable collection classes are mutableCopy-ed.
 */
- (void)mergeEntriesFromDictionaryRecursive:(NSDictionary *)otherDictionary flags:(BEDictionaryCombineFlags)combineFlags
{
	[self combineEntriesFromDictionaryRecursive:otherDictionary flags:BEDictionaryMergeEntriesFlag | combineFlags];
}


/*!
	@method     -addEntriesFromDictionaryRecursive
	@abstract   This merges entries of one dictionary into another without overwriting existing entries.
	@param      otherDictionary		The dictionary to merge.
	@discussion Unlike `addEntriesFromDictionary` this does not overwrite existing entries in
				the mutable dictionary.  Any mutable collection classes are mutableCopy-ed.
 */
- (void)addEntriesFromDictionaryRecursive:(NSDictionary *)otherDictionary
{
	[self addEntriesFromDictionaryRecursive:otherDictionary flags:BEDictionaryDefaultCombineFlags];
}

/*!
	@method     -mergeEntriesFromDictionaryRecursive
	@abstract   This merges entries of one dictionary into another without overwriting existing entries.
	@param      otherDictionary		The dictionary to merge.
 	@param		combineFlags		The ways to combine the new entries..
	@discussion Unlike `addEntriesFromDictionary` this does not overwrite existing entries in
				the mutable dictionary.  Any mutable collection classes are mutableCopy-ed.
 */
- (void)addEntriesFromDictionaryRecursive:(NSDictionary *)otherDictionary flags:(BEDictionaryCombineFlags)combineFlags
{
	[self combineEntriesFromDictionaryRecursive:otherDictionary flags:combineFlags & (~BEDictionaryMergeEntriesFlag)];
}

- (void)combineEntriesFromDictionaryRecursive:(NSDictionary *)otherDictionary flags:(BEDictionaryCombineFlags)combineFlags
{
	BOOL overwrite = !(combineFlags & BEDictionaryMergeEntriesFlag);
	BOOL selfMutableCollection = combineFlags & BEDictionarySelfMutableCollectionFlag;
	BOOL mutableCollectionCopy = combineFlags & BEDictionaryMutableCollectionCopyFlag;
	BOOL mutableCopy = combineFlags & BEDictionaryMutableCopyFlag;
	
	[otherDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ([obj isKindOfClass:[NSDictionary class]]) {
			NSDictionary *nestedDict = [self objectForKey:key];
			if ([nestedDict isKindOfClass:NSMutableDictionary.class]) {
				[(NSMutableDictionary*)nestedDict combineEntriesFromDictionaryRecursive:obj flags:combineFlags];
			} else if (selfMutableCollection && [nestedDict isKindOfClass:NSDictionary.class]) {
				nestedDict = nestedDict.mutableCopy;
				[self setObject:nestedDict forKey:key];
				[(NSMutableDictionary*)nestedDict combineEntriesFromDictionaryRecursive:obj flags:combineFlags];
			} else if (overwrite || ![self objectForKey:key]) {
				if ((mutableCopy && [obj conformsToProtocol:@protocol(NSMutableCopying)]) ||
				 	(mutableCollectionCopy && [obj conformsToProtocol:@protocol(BECollectionAbstract)])) {
					obj = [obj mutableCopy];
				}
				[self setObject:obj forKey:key];
			}
		} else if(overwrite || ![self objectForKey:key]) {	//if adding/replacing or not a key in self
			if ((mutableCopy && [obj conformsToProtocol:@protocol(NSMutableCopying)]) ||
				(mutableCollectionCopy && [obj conformsToProtocol:@protocol(BECollectionAbstract)])) {
				obj = [obj mutableCopy];
			}
			[self setObject:obj forKey:key];
		}
	}];
}

@end
