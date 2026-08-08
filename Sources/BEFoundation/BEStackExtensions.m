/*!
 @file			BEStackExtensions.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Stack (LIFO) and queue (FIFO) operations for mutable collections.
*/

#import <objc/runtime.h>
#import <BEFoundation/BEStackExtensions.h>
#import "NSArray+BExtension.h"
#import "NSOrderedSet+BExtension.h"

@implementation NSMutableArray (StackAdditions)

- (nonnull instancetype)pushObject:(id _Nullable)obj
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

- (nullable id)popObject
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
		[self removeObjectAtIndex:0];
	}
	return firstObject;
}

@end



@implementation NSMutableOrderedSet (StackAdditions)


- (void)setIsPushOnTop:(BOOL)value {
	objc_setAssociatedObject(self, @selector(isPushOnTop), @(value), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isPushOnTop {
	NSNumber *value = objc_getAssociatedObject(self, @selector(isPushOnTop));
	if (value == nil) {
		return YES;   // default
	}
	return value.boolValue;
}



- (nonnull instancetype)pushObject:(id _Nullable)obj
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
			[self pushObject:arg];
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

- (nullable id)popObject
{
	// nil if [self count] == 0
#if __has_feature(objc_arc)
	id lastObject = [self lastObject];
#else
	id lastObject = [[[self lastObject] retain] autorelease];
#endif
	if (lastObject) {
		[self removeObjectAtIndex:self.count - 1];
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
		[self removeObjectAtIndex:0];
	}
	return firstObject;
}

@end
