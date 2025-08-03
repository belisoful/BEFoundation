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
 @discussion	This adds compatibility methods to NSNotification so it can be posted by the system's
				`NSNotificationCenter` and observed by the `NSPriorityNotificationCenter`.
 
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


- (NSSet *)__copyRecursive:(BOOL)copyAllMutable
{
	NSMutableSet *immutable = [[NSMutableSet alloc] initWithCapacity:self.count];
	
	for (id obj in self) {
		id immutableObj = obj;
		if ([obj isKindOfClass:BEMutableCharacterSet.class]) {
			immutableObj = obj;
		}
		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			immutableObj = [obj __copyRecursive:copyAllMutable];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSCopying)]) {
			immutableObj = [obj copy];
		}
		
		[immutable addObject:immutableObj];
	}
	
	return immutable.copy;
}


- (NSSet *)copyRecursive
{
	return [self __copyRecursive:YES];
}

- (NSSet *)copyCollectionRecursive
{
	 return [self __copyRecursive:NO];
}



- (NSMutableSet *)__mutableCopyRecursive:(BOOL)copyAllMutable
{
	NSMutableSet *mutable = [[NSMutableSet alloc] initWithCapacity:self.count];
	
	for (id obj in self) {
		id mutableObj = obj;
		
		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			mutableObj = [obj __mutableCopyRecursive:copyAllMutable];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSMutableCopying)]) {
			mutableObj = [obj mutableCopy];
		}
		
		[mutable addObject:mutableObj];
	}
	
	return mutable;
}


- (NSMutableSet *)mutableCopyRecursive
{
	return [self __mutableCopyRecursive:YES];
}

- (NSMutableSet *)mutableCopyCollectionRecursive
{
	return [self __mutableCopyRecursive:NO];
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

- (NSOrderedSet *)__copyRecursive:(BOOL)copyAllMutable
{
	NSMutableOrderedSet *immutable = [[NSMutableOrderedSet alloc] initWithCapacity:self.count];
	
	for (id obj in self) {
		id immutableObj = obj;
		
		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			immutableObj = [obj __copyRecursive:copyAllMutable];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSCopying)]) {
			immutableObj = [obj copy];
		}
		
		[immutable addObject:immutableObj];
	}
	
	return immutable.copy;
}


- (NSOrderedSet *)copyRecursive
{
	return [self __copyRecursive:YES];
}

- (NSOrderedSet *)copyCollectionRecursive
{
	 return [self __copyRecursive:NO];
}



- (NSMutableOrderedSet *)__mutableCopyRecursive:(BOOL)copyAllMutable
{
	NSMutableOrderedSet *mutable = [[NSMutableOrderedSet alloc] initWithCapacity:self.count];
	
	for (id obj in self) {
		id mutableObj = obj;
		
		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			mutableObj = [obj __mutableCopyRecursive:copyAllMutable];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSMutableCopying)]) {
			mutableObj = [obj mutableCopy];
		}
		
		[mutable addObject:mutableObj];
	}
	
	return mutable;
}


- (NSMutableOrderedSet *)mutableCopyRecursive
{
	return [self __mutableCopyRecursive:YES];
}

- (NSMutableOrderedSet *)mutableCopyCollectionRecursive
{
	return [self __mutableCopyRecursive:NO];
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

- (NSArray *)__copyRecursive:(BOOL)copyAllMutable
{
	NSMutableArray *immutable = [[NSMutableArray alloc] initWithCapacity:self.count];
	
	for (id obj in self) {
		id immutableObj = obj;
		
		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			immutableObj = [obj __copyRecursive:copyAllMutable];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSCopying)]) {
			immutableObj = [obj copy];
		}
		
		[immutable addObject:immutableObj];
	}
	
	return immutable.copy;
}


- (NSArray *)copyRecursive
{
	return [self __copyRecursive:YES];
}

- (NSArray *)copyCollectionRecursive
{
	 return [self __copyRecursive:NO];
}



- (NSMutableArray *)__mutableCopyRecursive:(BOOL)copyAllMutable
{
	NSMutableArray *mutable = [[NSMutableArray alloc] initWithCapacity:self.count];
	
	for (id obj in self) {
		id mutableObj = obj;
		
		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			mutableObj = [obj __mutableCopyRecursive:copyAllMutable];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSMutableCopying)]) {
			mutableObj = [obj mutableCopy];
		}
		
		[mutable addObject:mutableObj];
	}
	
	return mutable;
}


- (NSMutableArray *)mutableCopyRecursive
{
	return [self __mutableCopyRecursive:YES];
}

- (NSMutableArray *)mutableCopyCollectionRecursive
{
	return [self __mutableCopyRecursive:NO];
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

- (NSDictionary *)__copyRecursive:(BOOL)copyAllMutable
{
	NSMutableDictionary *immutable = [[NSMutableDictionary alloc] initWithCapacity:self.count];
	
	for (id key in self) {
		id obj = self[key];
		
		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			obj = [obj __copyRecursive:copyAllMutable];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSCopying)]) {
			obj = [obj copy];
		}
		
		[immutable setObject:obj forKey:key];
	}
	
	return immutable.copy;
}


- (NSDictionary *)copyRecursive
{
	return [self __copyRecursive:YES];
}

- (NSDictionary *)copyCollectionRecursive
{
	 return [self __copyRecursive:NO];
}



- (NSMutableDictionary *)__mutableCopyRecursive:(BOOL)copyAllMutable
{
	NSMutableDictionary *mutable = [[NSMutableDictionary alloc] initWithCapacity:self.count];
	
	for (id key in self) {
		id obj = self[key];
		
		if ([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
			obj = [obj __mutableCopyRecursive:copyAllMutable];
		} else if (copyAllMutable && [obj conformsToProtocol:@protocol(NSMutableCopying)]) {
			obj = [obj mutableCopy];
		}
		
		[mutable setObject:obj forKey:key];
	}
	
	return mutable;
}


- (NSMutableDictionary *)mutableCopyRecursive
{
	return [self __mutableCopyRecursive:YES];
}

- (NSMutableDictionary *)mutableCopyCollectionRecursive
{
	return [self __mutableCopyRecursive:NO];
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

#if kExcludeImmutableClassesWithMutableImplementation
// Instances of NSCharacterSet are implemented by NSMutableCharacterSet
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

+ (BOOL)isMutable {
	/*
	@try {
		[self.new performSelector:@selector(setString:) withObject:@""];
		return YES;
	}
	@catch (NSException *exception) {
	}
	if(![self.className isEqualToString:@"__NSCFConstantString"]) {
		return YES;
	}*/
	
	
	NSString *className = self.className;
	if(![className isEqualToString:@"__NSCFConstantString"]) {
		if([className isEqualToString:@"__NSCFString"] || [self conformsToProtocol:@protocol(BEMutable)]) {
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)isMutable {
	/*
	@try {
		[self performSelector:@selector(setString:) withObject:self];
		return YES;
	}
	@catch (NSException *exception) {
	} */
	
	if(![self.className isEqualToString:@"__NSCFConstantString"]) {
		if([self.className isEqualToString:@"__NSCFString"]) {
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
