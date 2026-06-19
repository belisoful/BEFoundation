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
	@abstract	Returns a dictionary mapping each key to the `class` of its value.
	@discussion Iterates the receiver and replaces each value with `[value class]`, preserving the keys.
	@result		A new `NSDictionary` with the same keys, each mapped to the `Class` of its value.
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
	@abstract	Returns a dictionary mapping each key to the `className` of its value.
	@discussion Iterates the receiver and replaces each value with `[value className]`, preserving the keys.
	@result		A new `NSDictionary` with the same keys, each mapped to the class-name string of its value.
 */
- (nonnull NSDictionary<id, NSString*> *)objectsClassNames
{
	NSMutableDictionary *classes = NSMutableDictionary.new;
	[self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		[classes setObject:NSStringFromClass([obj class]) forKey:key];
	}];
	return classes.copy;
}


/*!
	@method		-objectsUniqueClasses
	@abstract	Returns a counted set of the `class` of each value.
	@discussion Iterates the receiver's values, collecting `[value class]` into an NSCountedSet that
				tracks how many values share each class.
	@result		A new `NSCountedSet` of the values' `Class` objects with their occurrence counts.
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
	@abstract	Returns a counted set of the `className` of each value.
	@discussion Iterates the receiver's values, collecting `[value className]` into an NSCountedSet
				that tracks how many values share each class name.
	@result		A new `NSCountedSet` of the values' class-name strings with their occurrence counts.
 */
- (nonnull NSCountedSet<NSString*> *)objectsUniqueClassNames
{
	NSCountedSet *classes = NSCountedSet.new;
	[self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		[classes addObject:NSStringFromClass([obj class])];
	}];
	return classes;
}


/*!
	@method		-toClassesFromStrings
	@abstract	Maps each value that is a class-name string to the corresponding `Class`, keeping the key.
	@discussion Replaces each string value with `NSClassFromString(value)`, preserving the key. Pairs
				whose value is not a string, or whose class name is not registered (NSClassFromString
				returns nil), are dropped from the result.
	@result		A new dictionary mapping the surviving keys to the `Class` of their class-name value.
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
 @method		-mapUsingBlock:
 @abstract		Maps each key/value pair to a new dictionary.
 @param			block	Applied to each pair via pointers to the key and value; it may mutate either,
						and must return YES for the pair to be kept (a nil key or value drops the pair).
 @discussion	Returns a new dictionary of the kept/transformed pairs; the receiver is not modified.
				The result is mutable if the receiver is an NSMutableDictionary.
 @result		A new dictionary of the pairs the block kept.
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
		 NSStringFromClass(NSMutableDictionary.class), NSStringFromSelector(_cmd)];
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
		 NSStringFromClass(NSMutableDictionary.class), NSStringFromSelector(_cmd)];
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
	@method     -filterUsingBlock:
	@abstract   Filters the receiver in place, running each key/value pair through the block.
	@param      filterBlock		Applied to each pair via pointers to the key and value; it may mutate
								either. Return NO (or nil the key/value) to remove the pair.
	@discussion This mutates the receiver: pairs the block rejects are removed, and any key/value the
				block reassigns replaces the original.
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
									   NSStringFromClass(NSMutableDictionary.class), NSStringFromSelector(_cmd)];
	}
	[otherDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (![self objectForKey:key]) {
			[self setObject:obj forKey:key];
		}
	}];
}

/*!
	@method     -mergeEntriesFromDictionaryRecursive:
	@abstract   Recursively merges another dictionary in, descending into matching nested dictionaries.
	@param      otherDictionary		The dictionary to merge.
	@discussion Like `mergeEntriesFromDictionary` (existing keys are kept, not overwritten), but where
				both sides hold a dictionary for the same key it recurses into it. Uses the default
				combine flags; pass `flags:` to control mutable-copying of nested collections.
 */
- (void)mergeEntriesFromDictionaryRecursive:(NSDictionary *)otherDictionary
{
	[self mergeEntriesFromDictionaryRecursive:otherDictionary flags:BEDictionaryDefaultCombineFlags];
}

/*!
	@method     -mergeEntriesFromDictionaryRecursive:flags:
	@abstract   Recursively merges another dictionary in (existing keys kept), with combine flags.
	@param      otherDictionary		The dictionary to merge.
	@param		combineFlags		Controls mutable-copying of nested collections (see BEDictionaryCombineFlags).
	@discussion Existing keys are kept; matching nested dictionaries are merged recursively. The
				`BEDictionary…MutableCopy`/`…MutableCollectionCopy` flags govern whether nested
				collections are mutable-copied rather than shared by reference.
 */
- (void)mergeEntriesFromDictionaryRecursive:(NSDictionary *)otherDictionary flags:(BEDictionaryCombineFlags)combineFlags
{
	[self combineEntriesFromDictionaryRecursive:otherDictionary flags:BEDictionaryMergeEntriesFlag | combineFlags];
}


/*!
	@method     -addEntriesFromDictionaryRecursive:
	@abstract   Recursively adds another dictionary in (existing keys overwritten), descending into nested dictionaries.
	@param      otherDictionary		The dictionary to add.
	@discussion Like `addEntriesFromDictionary` (existing keys ARE overwritten), but where both sides
				hold a dictionary for the same key it recurses instead of replacing wholesale. Uses the
				default combine flags; pass `flags:` to control mutable-copying of nested collections.
 */
- (void)addEntriesFromDictionaryRecursive:(NSDictionary *)otherDictionary
{
	[self addEntriesFromDictionaryRecursive:otherDictionary flags:BEDictionaryDefaultCombineFlags];
}

/*!
	@method     -addEntriesFromDictionaryRecursive:flags:
	@abstract   Recursively adds another dictionary in (existing keys overwritten), with combine flags.
	@param      otherDictionary		The dictionary to add.
 	@param		combineFlags		Controls mutable-copying of nested collections (see BEDictionaryCombineFlags).
	@discussion Existing keys are overwritten; matching nested dictionaries are merged recursively. The
				`BEDictionary…MutableCopy`/`…MutableCollectionCopy` flags govern whether nested
				collections are mutable-copied rather than shared by reference.
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
