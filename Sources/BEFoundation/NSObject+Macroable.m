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
static void *BEMacroLockKey = &BEMacroLockKey;

/*!
 @function		BEMacroLockForOwner
 @abstract		Returns the monitor that guards the macro records of a class or object.
 @discussion	The monitor is a private associated object that NSObject+DynamicMethods never
				acquires. Registration holds it while calling into DynamicMethods, so it must not be a
				monitor DynamicMethods also takes on its dispatch path (the class object, or the
				instance) or the two paths acquire the same pair of locks in opposite orders.
 */
static NSObject *BEMacroLockForOwner(id owner)
{
	static NSObject *creationLock = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		creationLock = [NSObject new];
	});

	NSObject *lock = objc_getAssociatedObject(owner, BEMacroLockKey);
	if (lock) {
		return lock;
	}
	@synchronized (creationLock) {
		lock = objc_getAssociatedObject(owner, BEMacroLockKey);
		if (!lock) {
			lock = [NSObject new];
			objc_setAssociatedObject(owner, BEMacroLockKey, lock, OBJC_ASSOCIATION_RETAIN);
		}
	}
	return lock;
}

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
	@synchronized (BEMacroLockForOwner(self.class)) {
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

	@synchronized (BEMacroLockForOwner(self.class)) {
		NSMutableDictionary<NSString*, BEMacroMeta*> *dict = [self macroMetaDictionary];

		if (macroBlock) {
			// Restore the prior record on failure: the installed dynamic method survives a
			// rejected re-registration, so deleting the record outright leaves the macro
			// callable while -hasMacro: reports it gone.
			BEMacroMeta *previous = [dict objectForKey:selectorString];
			BEMacroMeta *meta = [[BEMacroMeta alloc] initWithSelector:selector block:macroBlock];
			[dict setObject:meta forKey:selectorString];
			BOOL success = [self addClassMethod:selector block:macroBlock];
			if (!success) {
				if (previous) {
					[dict setObject:previous forKey:selectorString];
				} else {
					[dict removeObjectForKey:selectorString];
				}
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
	@synchronized (BEMacroLockForOwner(self.class)) {
		return [[self macroMetaDictionary] objectForKey:selectorString] != nil;
	}
}

+ (BOOL)removeMacro:(SEL)selector
{
	if (!selector) {
		return NO;
	}

	NSString *selectorString = NSStringFromSelector(selector);

	@synchronized (BEMacroLockForOwner(self.class)) {
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
	@synchronized (BEMacroLockForOwner(self.class)) {
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
	@synchronized (BEMacroLockForOwner(self)) {
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

	@synchronized (BEMacroLockForOwner(self)) {
		NSMutableDictionary<NSString*, BEMacroMeta*> *dict = [self objectMacroMetaDictionary];

		if (macroBlock) {
			// Restore the prior record on failure; see +macro:macroBlock: for the rationale.
			BEMacroMeta *previous = [dict objectForKey:selectorString];
			BEMacroMeta *meta = [[BEMacroMeta alloc] initWithSelector:selector block:macroBlock];
			[dict setObject:meta forKey:selectorString];
			BOOL success = [self addObjectMethod:selector block:macroBlock];
			if (!success) {
				if (previous) {
					[dict setObject:previous forKey:selectorString];
				} else {
					[dict removeObjectForKey:selectorString];
				}
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
	@synchronized (BEMacroLockForOwner(self)) {
		return [[self objectMacroMetaDictionary] objectForKey:selectorString] != nil;
	}
}

- (BOOL)removeObjectMacro:(SEL)selector
{
	if (!selector) {
		return NO;
	}

	NSString *selectorString = NSStringFromSelector(selector);

	@synchronized (BEMacroLockForOwner(self)) {
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
	@synchronized (BEMacroLockForOwner(self)) {
		NSMutableDictionary<NSString*, BEMacroMeta*> *dict = [self objectMacroMetaDictionary];
		for (NSString *selectorString in dict.allKeys) {
			SEL selector = NSSelectorFromString(selectorString);
			[self removeObjectMethod:selector];
		}
		[dict removeAllObjects];
	}
}

@end
