/*!
 @file			NSObject+Macroable.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		A simplified, Laravel-style macro façade over NSObject+DynamicMethods.
 @discussion	This implementation provides a lightweight macro system using
				NSObject+DynamicMethods internally for the actual method forwarding.
 */

#import "NSObject+Macroable.h"
#import "NSObject+DynamicMethods.h"
#import "BE_ARC.h"

static void *BEMacroMetaKey = &BEMacroMetaKey;
static void *BEObjectMacroMetaKey = &BEObjectMacroMetaKey;

@implementation BEMacroMeta

@synthesize selector = _selector;
@synthesize block = _block;

- (nullable instancetype)initWithSelector:(SEL)selector block:(nullable id)block
{
	self = [super init];
	if (self) {
		_selector = selector;
		_block = block;
	}
	return self;
}

@end

@implementation NSObject (Macroable)

#pragma mark - Activation

+ (BOOL)enableMacros
{
	return [self enableDynamicMethods];
}

+ (BOOL)disableMacros
{
	return [self disableDynamicMethods];
}

+ (BOOL)isMacrosEnabled
{
	return [self isDynamicMethodsEnabled] > 0;
}

#pragma mark - Class Macros Storage

+ (nonnull NSMutableDictionary<NSString*, BEMacroMeta*> *)macroMetaDictionary
{
	@synchronized (self.class) {
		NSMutableDictionary *dict = objc_getAssociatedObject(self.class, BEMacroMetaKey);
		if (!dict) {
			dict = [NSMutableDictionary dictionary];
			objc_setAssociatedObject(self.class, BEMacroMetaKey, dict, OBJC_ASSOCIATION_RETAIN);
		}
		return dict;
	}
}

#pragma mark - Macro Registration

+ (BOOL)macro:(SEL)selector macroBlock:(nullable id)macroBlock
{
	if (!selector) {
		return NO;
	}

	[self enableMacros];

	NSString *selectorString = NSStringFromSelector(selector);

	@synchronized (self.class) {
		NSMutableDictionary<NSString*, BEMacroMeta*> *dict = [self macroMetaDictionary];

		if (macroBlock) {
			BEMacroMeta *meta = [[BEMacroMeta alloc] initWithSelector:selector block:macroBlock];
			[dict setObject:meta forKey:selectorString];
			BOOL success = [self addClassMethod:selector block:macroBlock];
			if (!success) {
				[dict removeObjectForKey:selectorString];
				return NO;
			}
			return YES;
		} else {
			[dict removeObjectForKey:selectorString];
			[self removeClassMethod:selector];
			return YES;
		}
	}
}

+ (BOOL)hasMacro:(SEL)selector
{
	if (!selector) {
		return NO;
	}

	NSString *selectorString = NSStringFromSelector(selector);
	@synchronized (self.class) {
		return [[self macroMetaDictionary] objectForKey:selectorString] != nil;
	}
}

+ (BOOL)removeMacro:(SEL)selector
{
	if (!selector) {
		return NO;
	}

	NSString *selectorString = NSStringFromSelector(selector);

	@synchronized (self.class) {
		BEMacroMeta *meta = [[self macroMetaDictionary] objectForKey:selectorString];
		if (!meta) {
			return NO;
		}

		[self removeClassMethod:selector];
		[[self macroMetaDictionary] removeObjectForKey:selectorString];
		return YES;
	}
}

+ (void)flushMacros
{
	@synchronized (self.class) {
		NSMutableDictionary<NSString*, BEMacroMeta*> *dict = [self macroMetaDictionary];
		for (NSString *selectorString in dict.allKeys) {
			SEL selector = NSSelectorFromString(selectorString);
			[self removeClassMethod:selector];
		}
		[dict removeAllObjects];
	}
}

#pragma mark - Object Macros Storage

- (nonnull NSMutableDictionary<NSString*, BEMacroMeta*> *)objectMacroMetaDictionary
{
	@synchronized (self) {
		NSMutableDictionary *dict = objc_getAssociatedObject(self, BEObjectMacroMetaKey);
		if (!dict) {
			dict = [NSMutableDictionary dictionary];
			objc_setAssociatedObject(self, BEObjectMacroMetaKey, dict, OBJC_ASSOCIATION_RETAIN);
		}
		return dict;
	}
}

#pragma mark - Object Macro Registration

- (BOOL)objectMacro:(SEL)selector macroBlock:(nullable id)macroBlock
{
	if (!selector) {
		return NO;
	}

	[[self class] enableMacros];

	NSString *selectorString = NSStringFromSelector(selector);

	@synchronized (self) {
		NSMutableDictionary<NSString*, BEMacroMeta*> *dict = [self objectMacroMetaDictionary];

		if (macroBlock) {
			BEMacroMeta *meta = [[BEMacroMeta alloc] initWithSelector:selector block:macroBlock];
			[dict setObject:meta forKey:selectorString];
			BOOL success = [self addObjectMethod:selector block:macroBlock];
			if (!success) {
				[dict removeObjectForKey:selectorString];
				return NO;
			}
			return YES;
		} else {
			[dict removeObjectForKey:selectorString];
			[self removeObjectMethod:selector];
			return YES;
		}
	}
}

- (BOOL)hasObjectMacro:(SEL)selector
{
	if (!selector) {
		return NO;
	}

	NSString *selectorString = NSStringFromSelector(selector);
	@synchronized (self) {
		return [[self objectMacroMetaDictionary] objectForKey:selectorString] != nil;
	}
}

- (BOOL)removeObjectMacro:(SEL)selector
{
	if (!selector) {
		return NO;
	}

	NSString *selectorString = NSStringFromSelector(selector);

	@synchronized (self) {
		BEMacroMeta *meta = [[self objectMacroMetaDictionary] objectForKey:selectorString];
		if (!meta) {
			return NO;
		}

		[self removeObjectMethod:selector];
		[[self objectMacroMetaDictionary] removeObjectForKey:selectorString];
		return YES;
	}
}

- (void)flushObjectMacros
{
	@synchronized (self) {
		NSMutableDictionary<NSString*, BEMacroMeta*> *dict = [self objectMacroMetaDictionary];
		for (NSString *selectorString in dict.allKeys) {
			SEL selector = NSSelectorFromString(selectorString);
			[self removeObjectMethod:selector];
		}
		[dict removeAllObjects];
	}
}

@end
