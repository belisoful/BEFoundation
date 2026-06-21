/*!
 @file			BEMutable.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/


#import "BEMutable.h"
#import <CoreFoundation/CFCharacterSet.h>

/*!
 @category		BEMutableProtocol
 @abstract		This provides compatibility properties and methods to `NSObject` to check for mutability.
 @discussion	This adds the mutability-check properties to `NSObject` so any object answers whether it
				is mutable. The base implementation reports immutable; mutable subclasses override it.
 
 The following properties are provided by this category:
 
 `isMutable`: Class property. Returns NO because only specific classes are mutable.
 
 `isMutable`: Instance property. Returns the same as the class property of the same.
 
 */
@implementation NSObject (BEMutableProtocol)

+ (BOOL)isMutable {
	return [self conformsToProtocol:@protocol(BEMutable)];
}

- (BOOL)isMutable {
	return [self conformsToProtocol:@protocol(BEMutable)];
}

@end



@implementation NSSet (BEMutableProtocol)


- (NSSet *)__copyRecursive:(BOOL)copyAllMutable visited:(NSMutableSet *)visited
{
	// Break reference cycles: a collection that transitively contains itself would
	// otherwise recurse until the stack overflows.
	NSValue *selfKey = [NSValue valueWithNonretainedObject:self];
	if ([visited containsObject:selfKey]) {
		return self;
	}
	[visited addObject:selfKey];

	NSMutableSet *immutable = [[NSMutableSet alloc] initWithCapacity:self.count];

	for (id obj in self) {
		id immutableObj = obj;
		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			immutableObj = [obj __copyRecursive:copyAllMutable visited:visited];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSCopying)]) {
			immutableObj = [obj copy];
		}

		[immutable addObject:immutableObj];
	}

	[visited removeObject:selfKey];
	return immutable.copy;
}


- (NSSet *)copyRecursive
{
	return [self __copyRecursive:YES visited:[NSMutableSet set]];
}

- (NSSet *)copyCollectionRecursive
{
	 return [self __copyRecursive:NO visited:[NSMutableSet set]];
}



- (NSMutableSet *)__mutableCopyRecursive:(BOOL)copyAllMutable visited:(NSMutableSet *)visited
{
	NSValue *selfKey = [NSValue valueWithNonretainedObject:self];
	if ([visited containsObject:selfKey]) {
		return (NSMutableSet *)self;
	}
	[visited addObject:selfKey];

	NSMutableSet *mutable = [[NSMutableSet alloc] initWithCapacity:self.count];

	for (id obj in self) {
		id mutableObj = obj;

		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			mutableObj = [obj __mutableCopyRecursive:copyAllMutable visited:visited];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSMutableCopying)]) {
			mutableObj = [obj mutableCopy];
		}

		[mutable addObject:mutableObj];
	}

	[visited removeObject:selfKey];
	return mutable;
}


- (NSMutableSet *)mutableCopyRecursive
{
	return [self __mutableCopyRecursive:YES visited:[NSMutableSet set]];
}

- (NSMutableSet *)mutableCopyCollectionRecursive
{
	return [self __mutableCopyRecursive:NO visited:[NSMutableSet set]];
}

@end


@implementation NSMutableSet (BEMutableProtocol)

+ (BOOL)isMutable {
	return YES;
}

- (BOOL)isMutable {
	return YES;
}

@end




@implementation NSOrderedSet (BEMutableProtocol)

- (NSOrderedSet *)__copyRecursive:(BOOL)copyAllMutable visited:(NSMutableSet *)visited
{
	NSValue *selfKey = [NSValue valueWithNonretainedObject:self];
	if ([visited containsObject:selfKey]) {
		return self;
	}
	[visited addObject:selfKey];

	NSMutableOrderedSet *immutable = [[NSMutableOrderedSet alloc] initWithCapacity:self.count];

	for (id obj in self) {
		id immutableObj = obj;

		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			immutableObj = [obj __copyRecursive:copyAllMutable visited:visited];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSCopying)]) {
			immutableObj = [obj copy];
		}

		[immutable addObject:immutableObj];
	}

	[visited removeObject:selfKey];
	return immutable.copy;
}


- (NSOrderedSet *)copyRecursive
{
	return [self __copyRecursive:YES visited:[NSMutableSet set]];
}

- (NSOrderedSet *)copyCollectionRecursive
{
	 return [self __copyRecursive:NO visited:[NSMutableSet set]];
}



- (NSMutableOrderedSet *)__mutableCopyRecursive:(BOOL)copyAllMutable visited:(NSMutableSet *)visited
{
	NSValue *selfKey = [NSValue valueWithNonretainedObject:self];
	if ([visited containsObject:selfKey]) {
		return (NSMutableOrderedSet *)self;
	}
	[visited addObject:selfKey];

	NSMutableOrderedSet *mutable = [[NSMutableOrderedSet alloc] initWithCapacity:self.count];

	for (id obj in self) {
		id mutableObj = obj;

		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			mutableObj = [obj __mutableCopyRecursive:copyAllMutable visited:visited];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSMutableCopying)]) {
			mutableObj = [obj mutableCopy];
		}

		[mutable addObject:mutableObj];
	}

	[visited removeObject:selfKey];
	return mutable;
}


- (NSMutableOrderedSet *)mutableCopyRecursive
{
	return [self __mutableCopyRecursive:YES visited:[NSMutableSet set]];
}

- (NSMutableOrderedSet *)mutableCopyCollectionRecursive
{
	return [self __mutableCopyRecursive:NO visited:[NSMutableSet set]];
}


@end

@implementation NSMutableOrderedSet (BEMutableProtocol)

+ (BOOL)isMutable {
	return YES;
}

- (BOOL)isMutable {
	return YES;
}

@end



@implementation NSArray (BEMutableProtocol)

- (NSArray *)__copyRecursive:(BOOL)copyAllMutable visited:(NSMutableSet *)visited
{
	NSValue *selfKey = [NSValue valueWithNonretainedObject:self];
	if ([visited containsObject:selfKey]) {
		return self;
	}
	[visited addObject:selfKey];

	NSMutableArray *immutable = [[NSMutableArray alloc] initWithCapacity:self.count];

	for (id obj in self) {
		id immutableObj = obj;

		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			immutableObj = [obj __copyRecursive:copyAllMutable visited:visited];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSCopying)]) {
			immutableObj = [obj copy];
		}

		[immutable addObject:immutableObj];
	}

	[visited removeObject:selfKey];
	return immutable.copy;
}


- (NSArray *)copyRecursive
{
	return [self __copyRecursive:YES visited:[NSMutableSet set]];
}

- (NSArray *)copyCollectionRecursive
{
	 return [self __copyRecursive:NO visited:[NSMutableSet set]];
}



- (NSMutableArray *)__mutableCopyRecursive:(BOOL)copyAllMutable visited:(NSMutableSet *)visited
{
	NSValue *selfKey = [NSValue valueWithNonretainedObject:self];
	if ([visited containsObject:selfKey]) {
		return (NSMutableArray *)self;
	}
	[visited addObject:selfKey];

	NSMutableArray *mutable = [[NSMutableArray alloc] initWithCapacity:self.count];

	for (id obj in self) {
		id mutableObj = obj;

		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			mutableObj = [obj __mutableCopyRecursive:copyAllMutable visited:visited];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSMutableCopying)]) {
			mutableObj = [obj mutableCopy];
		}

		[mutable addObject:mutableObj];
	}

	[visited removeObject:selfKey];
	return mutable;
}


- (NSMutableArray *)mutableCopyRecursive
{
	return [self __mutableCopyRecursive:YES visited:[NSMutableSet set]];
}

- (NSMutableArray *)mutableCopyCollectionRecursive
{
	return [self __mutableCopyRecursive:NO visited:[NSMutableSet set]];
}

@end

@implementation NSMutableArray (BEMutableProtocol)

+ (BOOL)isMutable {
	return YES;
}

- (BOOL)isMutable {
	return YES;
}

@end



@implementation NSDictionary (BEMutableProtocol)

- (NSDictionary *)__copyRecursive:(BOOL)copyAllMutable visited:(NSMutableSet *)visited
{
	NSValue *selfKey = [NSValue valueWithNonretainedObject:self];
	if ([visited containsObject:selfKey]) {
		return self;
	}
	[visited addObject:selfKey];

	// Keys are not deep-copied: NSDictionary copies keys on insertion and they are
	// expected to be immutable. Only values are recursed.
	NSMutableDictionary *immutable = [[NSMutableDictionary alloc] initWithCapacity:self.count];

	for (id key in self) {
		id obj = self[key];

		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			obj = [obj __copyRecursive:copyAllMutable visited:visited];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSCopying)]) {
			obj = [obj copy];
		}

		[immutable setObject:obj forKey:key];
	}

	[visited removeObject:selfKey];
	return immutable.copy;
}


- (NSDictionary *)copyRecursive
{
	return [self __copyRecursive:YES visited:[NSMutableSet set]];
}

- (NSDictionary *)copyCollectionRecursive
{
	 return [self __copyRecursive:NO visited:[NSMutableSet set]];
}



- (NSMutableDictionary *)__mutableCopyRecursive:(BOOL)copyAllMutable visited:(NSMutableSet *)visited
{
	NSValue *selfKey = [NSValue valueWithNonretainedObject:self];
	if ([visited containsObject:selfKey]) {
		return (NSMutableDictionary *)self;
	}
	[visited addObject:selfKey];

	NSMutableDictionary *mutable = [[NSMutableDictionary alloc] initWithCapacity:self.count];

	for (id key in self) {
		id obj = self[key];

		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			obj = [obj __mutableCopyRecursive:copyAllMutable visited:visited];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSMutableCopying)]) {
			obj = [obj mutableCopy];
		}

		[mutable setObject:obj forKey:key];
	}

	[visited removeObject:selfKey];
	return mutable;
}


- (NSMutableDictionary *)mutableCopyRecursive
{
	return [self __mutableCopyRecursive:YES visited:[NSMutableSet set]];
}

- (NSMutableDictionary *)mutableCopyCollectionRecursive
{
	return [self __mutableCopyRecursive:NO visited:[NSMutableSet set]];
}

@end


@implementation NSMutableDictionary (BEMutableProtocol)

+ (BOOL)isMutable {
	return YES;
}

- (BOOL)isMutable {
	return YES;
}

@end


#pragma mark - BEHasMutable

@implementation NSIndexSet (BEMutableProtocol)

+ (BOOL)isMutable {
	return NO;
}

- (BOOL)isMutable {
	return NO;
}

@end


@implementation NSNumber (BEMutableProtocol)

+ (BOOL)isMutable {
	return NO;
}

- (BOOL)isMutable {
	return NO;
}

@end

@implementation NSString (BEMutableProtocol)

+ (BOOL)isMutable {
	return NO;
}

#if kIncludeImmutableClassesWithMutableImplementation
// NSString instances may be backed by the mutable __NSCFString implementation, so an
// instance-level answer is unreliable; this is only compiled in when explicitly opted into.
- (BOOL)isMutable {
	return NO;
}
#endif

@end


@implementation NSData (BEMutableProtocol)

+ (BOOL)isMutable {
	return NO;
}

- (BOOL)isMutable {
	return NO;
}

@end


@implementation NSAttributedString (BEMutableProtocol)

+ (BOOL)isMutable {
	return NO;
}

- (BOOL)isMutable {
	return NO;
}

@end


@implementation NSURLRequest (BEMutableProtocol)

+ (BOOL)isMutable {
	return NO;
}

- (BOOL)isMutable {
	return NO;
}

@end


/**
 NSCharacterSet has object hierarchy
 	NSObject
 	NSCharacterSet
 	NSMutableCharacterSet
 */
@implementation NSCharacterSet (BEMutableProtocol)

+ (BOOL)isMutable {
	return NO;
}

#if kIncludeImmutableClassesWithMutableImplementation
// Instances of NSCharacterSet are implemented by NSMutableCharacterSet
- (BOOL)isMutable {
	return NO;
}
#endif

@end

@implementation BECharacterSet (BEMutableProtocol)

+ (BOOL)isMutable {
	return NO;
}

- (BOOL)isMutable {
	return NO;
}
@end


#pragma mark - BEMutable

@implementation NSMutableIndexSet (BEMutableProtocol)

+ (BOOL)isMutable {
	return YES;
}

- (BOOL)isMutable {
	return YES;
}

@end


@implementation NSMutableNumber (BEMutableProtocol)

+ (BOOL)isMutable {
	return YES;
}

- (BOOL)isMutable {
	return YES;
}

@end


@implementation NSMutableString (BEMutableProtocol)

// NSString is a class cluster: the static type does not determine mutability, so the answer
// is inferred from the concrete CF backing class. __NSCFConstantString is always immutable;
// __NSCFString backs genuinely mutable instances. A BEMutable-conforming custom subclass is
// also treated as mutable.
+ (BOOL)isMutable {
	NSString *className = NSStringFromClass(self.class);
	if(![className isEqualToString:@"__NSCFConstantString"]) {
		if([className isEqualToString:@"__NSCFString"] || [self conformsToProtocol:@protocol(BEMutable)]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)isMutable {
	if(![NSStringFromClass(self.class) isEqualToString:@"__NSCFConstantString"]) {
		if([NSStringFromClass(self.class) isEqualToString:@"__NSCFString"]) {
			return YES;
		}
	}
	return NO;
}

@end


@implementation NSMutableData (BEMutableProtocol)

+ (BOOL)isMutable {
	return YES;
}

- (BOOL)isMutable {
	return YES;
}

@end




@implementation NSMutableAttributedString (BEMutableProtocol)

+ (BOOL)isMutable {
	return YES;
}

- (BOOL)isMutable {
	return YES;
}

@end


@implementation NSMutableURLRequest (BEMutableProtocol)

+ (BOOL)isMutable {
	return YES;
}

- (BOOL)isMutable {
	return YES;
}

@end

@implementation NSMutableCharacterSet (BEMutableProtocol)

   + (BOOL)isMutable {
	   return kCharSetDifferentiable;
   }

   - (BOOL)isMutable {
	   return kCharSetDifferentiable;
   }

@end


@implementation BEMutableCharacterSet (BEMutableProtocol)

+ (BOOL)isMutable {
	return YES;
}

- (BOOL)isMutable {
	return YES;
}

@end
