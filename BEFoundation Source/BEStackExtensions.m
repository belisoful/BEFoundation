/*!
 @file			CIImage+BExtension.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/

#import <objc/runtime.h>
#import <BEFoundation/BEStackExtensions.h>
#import "NSArray+BExtension.h"
#import "NSOrderedSet+BExtension.h"

@implementation NSMutableArray (StackAdditions)



- (nonnull instancetype)push:(id _Nullable)obj
{
	if (obj) {
		[self addObject:obj];
	}
	return self;
}

- (nonnull instancetype)pushObjects:(nullable id)obj, ...
{
	if (obj) {
		va_list args;
		va_start(args, obj);
		
		id arg = obj;
		while (arg != nil) {
			[self addObject:arg];
			arg = va_arg(args, id);
		}
		
		va_end(args);
	}
	return self;
}

- (nonnull instancetype)pushArray:(nullable NSArray*)array
{
	if (array) {
		[self addObjectsFromArray:array];
	}
	return self;
}

- (nullable id)pop
{
#if __has_feature(objc_arc)
	id lastObject = [self lastObject];
#else
	id lastObject = [[[self lastObject] retain] autorelease];
#endif
	if (lastObject) {
		[self removeLastObject];
	}
	return lastObject;
}

- (nullable id)shift
{
#if __has_feature(objc_arc)
	id firstObject = [self firstObject];
#else
	id firstObject = [[[self firstObject] retain] autorelease];
#endif
	if (firstObject) {
		[self removeFirstObject];
	}
	return firstObject;
}

@end



@implementation NSMutableOrderedSet (StackAdditions)


- (void)setIsPushOnTop:(BOOL)value {
	objc_setAssociatedObject(self, @selector(isPushOnTop), @(value), OBJC_ASSOCIATION_RETAIN);
}

// or String if NO
- (BOOL)isPushOnTop {
	NSNumber *value = objc_getAssociatedObject(self, @selector(isPushOnTop));
	if (!value) {
		return YES;
	}
	return value.boolValue;
}



- (nonnull instancetype)push:(id _Nullable)obj
{
	if(obj) {
		if (self.isPushOnTop) {
			[self removeObject:obj];
		}
		[self addObject: obj];
	}
	return self;
}

- (nonnull instancetype)pushObjects:(nullable id)obj, ...
{
	if (obj) {
		va_list args;
		va_start(args, obj);
		
		id arg = obj;
		while (arg != nil) {
			[self push:arg];
			arg = va_arg(args, id);
		}
		
		va_end(args);
	}
	return self;
}


- (nonnull instancetype)pushArray:(id _Nullable)array
{
	if(array) {
		if (self.isPushOnTop) {
			[self removeObjectsInArray:array];
		}
		[self addObjectsFromArray:array];
	}
	return self;
}

- (nullable id)pop
{
	// nil if [self count] == 0
#if __has_feature(objc_arc)
	id lastObject = [self lastObject];
#else
	id lastObject = [[[self lastObject] retain] autorelease];
#endif
	if (lastObject) {
		[self removeLastObject];
	}
	return lastObject;
}

- (nullable id)shift
{
#if __has_feature(objc_arc)
	id firstObject = [self firstObject];
#else
	id firstObject = [[[self firstObject] retain] autorelease];
#endif
	if (firstObject) {
		[self removeFirstObject];
	}
	return firstObject;
}

@end
