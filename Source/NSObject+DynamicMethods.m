/*!
 @file			NSObject+DynamicMethods.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Implements the NSObject (DynamicMethods) runtime method-injection system.
 @discussion	Adds per-object and per-class methods (and protocol/target forwarding) at runtime using
				blocks, by swizzling methodSignatureForSelector:/forwardInvocation:/respondsToSelector:/
				conformsToProtocol: and storing metadata in associated objects guarded by per-scope locks.
*/

#import "NSObject+DynamicMethods.h"
#import "NSObject+DynamicMethodsHelpers.h"
#import "NSDictionary+BExtension.h"
#import "BERuntime.h"
#import "BE_ARC.h"
#import <CommonCrypto/CommonDigest.h>

@interface BEDynamicMethodInstanceProtocolMeta : NSObject
@property (readonly)					Protocol		*protocol;
@property (readonly, strong)			NSString		*protocolName;
@property (readonly, nullable, strong)	NSOrderedSet	*parentProtocols;
@property (readonly)					Class			impClass;

- (instancetype)initWithProtocol:(nullable Protocol *)protocol impClass:(Class)impClass;
@end

@implementation BEDynamicMethodInstanceProtocolMeta
@synthesize protocol = _protocol;
@synthesize protocolName = _protocolName;
@synthesize parentProtocols = _parentProtocols;
@synthesize impClass = _impClass;

- (instancetype)initWithProtocol:(nullable Protocol *)protocol impClass:(Class)impClass
{
	if (protocol == @protocol(NSNoProtocol)) {
		protocol = nil;
	}
	if (!protocol && !impClass) {
		return nil;
	}
	
	self = [super init];
	if (self) {
		_protocol = protocol;
		_protocolName = protocol ? NSStringFromProtocol(protocol) : nil;
		_parentProtocols = recursiveProtocolsFromProtocol(protocol);
		_impClass = impClass;
	}
	return self;
}
@end


@interface BEDynamicMethodProtocolTargetMeta : NSObject
@property (readonly, nullable)			Protocol				*protocol;
@property (readonly, nullable, strong)	NSString				*protocolName;
@property (readonly, nullable, strong)	NSOrderedSet			*parentProtocols;
@property (readonly, nonnull, strong)	id						target;	// this can return [NSNull null] for a nil value
@property (readonly)					BOOL					isInstanceTarget;
@property (readonly, weak) BEDynamicMethodInstanceProtocolMeta	*instanceMeta;

- (instancetype)initWithProtocol:(nullable Protocol *)protocol target:(id)target instanceMeta:(nullable BEDynamicMethodInstanceProtocolMeta*)instanceMeta;
@end

@implementation BEDynamicMethodProtocolTargetMeta
@synthesize protocol = _protocol;
@synthesize protocolName = _protocolName;
@synthesize parentProtocols = _parentProtocols;
@synthesize target = _target;
@synthesize isInstanceTarget = _isInstanceTarget;
@synthesize instanceMeta = _instanceMeta;

- (instancetype)initWithProtocol:(nullable Protocol *)protocol target:(id)target instanceMeta:(nullable BEDynamicMethodInstanceProtocolMeta*)instanceMeta
{
	if (protocol == @protocol(NSNoProtocol)) {
		protocol = nil;
	}
	if (!target) {
		target = [NSNull null];
	}
	if (!protocol && target == [NSNull null]) {
		return nil;
	}
	
	self = [super init];
	if (self) {
		_protocol = protocol;
		_protocolName = protocol ? NSStringFromProtocol(protocol) : nil;
		_parentProtocols = recursiveProtocolsFromProtocol(protocol);
		_target = target;
		_isInstanceTarget = instanceMeta != nil;
		_instanceMeta = instanceMeta;
	}
	return self;
}
@end


#pragma mark - Dynamic Method Metadata


@implementation BEDynamicMethodMeta

@synthesize selector = _selector;
@synthesize blockSignature = _blockSignature;
@synthesize methodSignature = _methodSignature;
@synthesize isCapturingCmd = _isCapturingCmd;
@synthesize block = _block;
@synthesize implementation = _implementation;

- (nullable instancetype)initWithSelector:(nonnull SEL)aSelector
									block:(nonnull id)block
{
	self = [super init];
	if (self) {
		_blockSignature = [BEMethodSignatureHelper invocableMethodSignatureFromBlock:block];
		if (!_blockSignature) {
			return nil;
		}
		_selector = aSelector;
		_methodSignature = [NSMethodSignature methodSignatureFromBlock:block];
		_isCapturingCmd = (_blockSignature.numberOfArguments > 2) ? [_blockSignature getArgumentTypeAtIndex:2][0] == @encode(SEL)[0] : false;
		_implementation = imp_implementationWithBlock(block);
		_block = imp_getBlock(_implementation);
	}
	return self;
}

- (void)dealloc
{
	// Tear down the IMP trampoline when THIS object is deallocated — not when it is removed/replaced
	// in the methods dictionary. The dispatch path holds a strong reference to the meta while it
	// invokes -implementation, so an in-flight call keeps the IMP alive even if another thread removes
	// or replaces the method concurrently; the trampoline is freed only once no one references it,
	// avoiding the prior use-after-free. (_block is a strong ivar released by ARC; do NOT also
	// Block_release it — that was an unbalanced over-release.)
	if (_implementation) {
		imp_removeBlock(_implementation);
		_implementation = NULL;
	}
}

@end




static NSString * const BEDMProtocolTargetLUTKey = @"__reverseTargetLUT";



#pragma mark - NSObject (DynamicMethods)

#pragma mark Associated Object Keys

@implementation NSObject (DynamicMethods)
/*!
 @method _dynamicMethodsAllowNSKey
 @abstract Associated-object key for the per-class "allow dynamic methods on NS* classes" flag.
 */
+ (void *)_dynamicMethodsAllowNSKey
{
	return @selector(_dynamicMethodsAllowNSKey);
}

+ (void *)_dynamicMethodsEnabledKey
{
	return @selector(_dynamicMethodsEnabledKey);
}




- (void *)_dynamicMethodsObjectLockKey
{
	return @selector(_dynamicMethodsObjectLockKey);
}

+ (void *)_dynamicMethodsInstanceLockKey
{
	return @selector(_dynamicMethodsInstanceLockKey);
}

- (void *)_dynamicMethodsObjectProtocolLockKey
{
	return @selector(_dynamicMethodsObjectProtocolLockKey);
}

- (void *)_dynamicMethodsInstanceProtocolLockKey
{
	return @selector(_dynamicMethodsInstanceProtocolLockKey);
}



- (void *)_dynamicObjectMethodsMetaKey
{
	return @selector(_dynamicObjectMethodsMetaKey);
}

+ (void *)_dynamicClassMethodsMetaKey
{
	return @selector(_dynamicClassMethodsMetaKey);
}

- (void *)_dynamicObjectProtocolMetaKey
{
	return @selector(_dynamicObjectProtocolMetaKey);
}

+ (void *)_dynamicInstanceProtocolMetaKey
{
	return @selector(_dynamicInstanceProtocolMetaKey);
}



- (void *)_dynamicInstanceProtocolSelfHashKey
{
	return @selector(_dynamicInstanceProtocolSelfHashKey);
}





#pragma mark Dynamic Method Enabled Properties

+ (const NSArray*)getDynamicMethodsSwizzlePairs
{
	static NSArray *swizzler = nil;
	if (!swizzler) {
		swizzler = @[
			//instance  - methods to swizzle
			[BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(conformsToProtocol:) withSelector:@selector(swizzleConformsToProtocol:)],
			[BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(methodSignatureForSelector:) withSelector:@selector(swizzleMethodSignatureForSelector:)],
			[BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(respondsToSelector:) withSelector:@selector(swizzleRespondsToSelector:)],
			[BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(forwardInvocation:) withSelector:@selector(swizzleForwardInvocation:)],
			
			//class for instance + methods to swizzle
			[BEDynamicMethodSwizzleSelectors swizzleMetaOriginal:@selector(instanceMethodSignatureForSelector:) withSelector:@selector(swizzleClassClassMethodSignatureForSelector:)],
			[BEDynamicMethodSwizzleSelectors swizzleMetaOriginal:@selector(instancesRespondToSelector:) withSelector:@selector(swizzleClassInstancesRespondToSelector:)],
			
			// Meta-Class - methods to swizzle
			[BEDynamicMethodSwizzleSelectors swizzleMetaOriginal:@selector(conformsToProtocol:) withSelector:@selector(swizzleClassConformsToProtocol:)],
			[BEDynamicMethodSwizzleSelectors swizzleMetaOriginal:@selector(methodSignatureForSelector:) withSelector:@selector(swizzleClassMethodSignatureForSelector:)],
			[BEDynamicMethodSwizzleSelectors swizzleMetaOriginal:@selector(respondsToSelector:) withSelector:@selector(swizzleClassRespondsToSelector:)],
			[BEDynamicMethodSwizzleSelectors swizzleMetaOriginal:@selector(forwardInvocation:) withSelector:@selector(swizzleClassForwardInvocation:)]
		];
	}
	return swizzler;
}

+ (BOOL)allowNSDynamicMethods
{
	Class cls = self.class;
	Class priorClass = nil;
	do {
		if ([cls allowSelfNSDynamicMethods]) {
			return YES;
		}
		priorClass = cls;
		cls = [cls superclass];
	} while(cls != priorClass);
	
	return NO;
}

+ (BOOL)allowSelfNSDynamicMethods
{
	@synchronized (self.class) {
		return [(NSNumber*)objc_getAssociatedObject(self.class, [self _dynamicMethodsAllowNSKey]) boolValue];
	}
}

+ (void)setAllowNSDynamicMethods:(BOOL)allowNSClasses
{
	if (self.class == NSObject.class) {
		return;
	}
	@synchronized (self.class) {
		if (allowNSClasses) {
			objc_setAssociatedObject(self.class, [self _dynamicMethodsAllowNSKey], @(YES), OBJC_ASSOCIATION_RETAIN);
		} else {
			objc_setAssociatedObject(self.class, [self _dynamicMethodsAllowNSKey], nil, OBJC_ASSOCIATION_ASSIGN);
		}
	}
}



+ (NSNumber*)isSelfDynamicMethodsEnabledObject {
	if (![self allowNSDynamicMethods] && [NSStringFromClass(self.class) hasPrefix:@"NS"]) {\
		return nil;
	}
	@synchronized (self) {
		return objc_getAssociatedObject(self.class, [self _dynamicMethodsEnabledKey]);
	}
}

+ (BOOL)isSelfDynamicMethodsEnabled {
	@synchronized (self) {
		return [[self isSelfDynamicMethodsEnabledObject] boolValue];
	}
}

+ (void)setIsSelfDynamicMethodsEnabled:(BOOL)enabled {
	@synchronized (self) {
		objc_setAssociatedObject(self.class, [self _dynamicMethodsEnabledKey], [NSNumber numberWithBool:enabled], OBJC_ASSOCIATION_RETAIN);
	}
}

+ (void)resetIsSelfDynamicMethodsEnabled {
	@synchronized (self) {
		objc_setAssociatedObject(self.class, [self _dynamicMethodsEnabledKey], nil, OBJC_ASSOCIATION_ASSIGN);
	}
}


+ (BEDynamicMethodsActivationState)isDynamicMethodsEnabled {
	
	NSNumber *enabledNumber;
	int selfMultiplier = 2;
	int index = 0;
	
	Class cls = self.class;
	Class priorClass = nil;
	
	do {
		enabledNumber = [cls isSelfDynamicMethodsEnabledObject];
		if (enabledNumber) {
			index = [enabledNumber boolValue] ? 1 : -1;
			break;
		}
		selfMultiplier = 1;
		priorClass = cls;
		cls = [cls superclass];
	} while (cls != priorClass);
	
	return index * selfMultiplier;
}

#pragma mark Enable/Disable Dynamic Methods

+ (BOOL)enableDynamicMethods
{
	BEDynamicMethodsActivationState isEnabled = self.isDynamicMethodsEnabled;
	if (isEnabled == DMSelfEnabled || class_isMetaClass(self) || self == NSObject.class) {
		return NO;
	}
	@synchronized (self) {
		isEnabled = self.isDynamicMethodsEnabled;
		
		if (isEnabled == DMSelfEnabled) {
			return NO;
		}
		
		[self swizzleDynamicMethods];
		[self setIsSelfDynamicMethodsEnabled:YES];
	}
	return YES;
}

+ (BOOL)disableDynamicMethods
{
	BEDynamicMethodsActivationState isEnabled = self.isDynamicMethodsEnabled;
	if (isEnabled == DMSelfDisabled || class_isMetaClass(self) || self == NSObject.class) {
		return NO;
	}
	@synchronized (self) {
		isEnabled = [self isDynamicMethodsEnabled];
		
		if (isEnabled == DMSelfDisabled) {
			return NO;
		}
		
		[self setIsSelfDynamicMethodsEnabled:NO];
	}
	return YES;
}

+ (BOOL)resetDynamicMethods {
	BEDynamicMethodsActivationState isEnabled = self.isDynamicMethodsEnabled;
	if (!isDynamicMethodsSelf(isEnabled) || class_isMetaClass(self) || self == NSObject.class) {
		//DMSelfEnabled or DMSelfDisabled
		return NO;
	}
	@synchronized (self) {
		isEnabled = self.isDynamicMethodsEnabled;
		
		if (!isDynamicMethodsSelf(isEnabled)) {
			return NO;
		}
		
		[self resetIsSelfDynamicMethodsEnabled];
	}
	return YES;
}

+ (void)swizzleDynamicMethods
{
	Class cls = self.class;
	
	//If a parent or self is swizzled, no need to swizzle
	if ([BEDynamicMethodSwizzleSelectors statusParentsAreSwizzled:cls] || [BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:cls]) {
		return;
	}
	
	const NSArray<BEDynamicMethodSwizzleSelectors *> *swizzles = [cls getDynamicMethodsSwizzlePairs];
	for (size_t j = 0; j < swizzles.count; j++) {
		[swizzles[j] swizzleMethodsOnClass:cls];
	}
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:YES];
}


#pragma mark Dynamic Method Swizzle Methods

/*!
 @notes self is the instanced object
 */
- (NSMethodSignature *)swizzleMethodSignatureForSelector:(SEL)aSelector
{
	NSMethodSignature *signature = [self dynamicMethodSignatureForSelector:aSelector];
	
	if (signature) {
		return signature;
	}
	
	return [self swizzleMethodSignatureForSelector:aSelector];
}

/*!
 @notes self is the instanced object
 */
- (BOOL)swizzleRespondsToSelector:(SEL)aSelector
{
	if ([self dynamicRespondsToSelector:aSelector]) {
		return YES;
	}
	return [self swizzleRespondsToSelector:aSelector];
}

/*!
 @notes self is the instanced object
 */
- (void)swizzleForwardInvocation:(NSInvocation *)anInvocation
{
	if([self dynamicForwardInvocation:anInvocation]) {
		return;
	}
	[self swizzleForwardInvocation:anInvocation];
}
/*!
 @note self is the Class object.
 */
- (BOOL)swizzleConformsToProtocol:(nullable Protocol *)aProtocol
{
	if ([self dynamicConformsToProtocol:aProtocol]) {
		return YES;
	}
	return [self swizzleConformsToProtocol:aProtocol];
}





/*!
 @note self is the Class object.   when "+" then self is the Class, when "-" then the self is the Meta-Class.
 */
+ (nullable NSMethodSignature *)swizzleClassClassMethodSignatureForSelector:(nonnull SEL)aSelector
{
	NSMethodSignature *signature = [self dynamicInstanceMethodSignatureForSelector:aSelector];

	if (signature) {
		return signature;
	}

	return [self swizzleClassClassMethodSignatureForSelector:aSelector];
}

/*!
 @note self is the Class object.   when "+" then self is the Class, when "-" then the self is the Meta-Class.
 */
+ (BOOL)swizzleClassInstancesRespondToSelector:(nonnull SEL)aSelector
{
	if ([self dynamicInstancesRespondToSelector:aSelector]) {
		return YES;
	}
	return [self swizzleClassInstancesRespondToSelector:aSelector];
}


/*!
 @note self is the Class object.   when "+" then self is the Class, when "-" then the self is the Meta-Class.
 */
+ (NSMethodSignature *)swizzleClassMethodSignatureForSelector:(SEL)aSelector
{
	NSMethodSignature *signature = [self dynamicClassMethodSignatureForSelector:aSelector];
	
	if (signature) {
		return signature;
	}
	
	return [self swizzleClassMethodSignatureForSelector:aSelector];
}

/*!
 @note self is the Class object.   when "+" then self is the Class, when "-" then the self is the Meta-Class.
 */
+ (BOOL)swizzleClassRespondsToSelector:(SEL)aSelector
{
	if ([self dynamicClassRespondsToSelector:aSelector]) {
		return YES;
	}
	return [self swizzleClassRespondsToSelector:aSelector];
}

/*!
 @note self is the Class object.   when "+" then self is the Class, when "-" then the self is the Meta-Class.
 */
+ (void)swizzleClassForwardInvocation:(NSInvocation *)anInvocation
{
	if([self dynamicClassForwardInvocation:anInvocation]) {
		return;
	}
	[self swizzleClassForwardInvocation:anInvocation];
}


/*!
 @note self is the Class object.   when "+" then self is the Class, when "-" then the self is the Meta-Class.
 */
+ (BOOL)swizzleClassConformsToProtocol:(nullable Protocol *)aProtocol
{
	if ([self dynamicClassConformsToProtocol:aProtocol]) {
		return YES;
	}
	return [self swizzleClassConformsToProtocol:aProtocol];
}



#pragma mark Locks


- (NSObject*)dynamicMethodsObjectLock
{
	void *objectLockKey = [self _dynamicMethodsObjectLockKey];
	
	NSObject *lock = objc_getAssociatedObject(self, objectLockKey);
	if (!lock) {
		@synchronized (self) {
			lock = objc_getAssociatedObject(self, objectLockKey);
			if (!lock) {
				lock = NSObject.new;
				objc_setAssociatedObject(self, objectLockKey, lock, OBJC_ASSOCIATION_RETAIN);
			}
		}
	}
	
	return lock;
}

+ (NSObject*)dynamicMethodsInstanceLock
{
	void *metaClassLockKey = [self _dynamicMethodsInstanceLockKey];
	
	NSObject *lock = objc_getAssociatedObject(self.class, metaClassLockKey);
	if (!lock) {
		@synchronized (self) {
			lock = objc_getAssociatedObject(self.class, metaClassLockKey);
			if (!lock) {
				lock = NSObject.new;
				objc_setAssociatedObject(self.class, metaClassLockKey, lock, OBJC_ASSOCIATION_RETAIN);
			}
		}
	}
	
	return lock;
}

- (NSObject*)dynamicMethodsObjectProtocolLock
{
	void *objectLockKey = [self _dynamicMethodsObjectProtocolLockKey];
	
	NSObject *lock = objc_getAssociatedObject(self, objectLockKey);
	if (!lock) {
		@synchronized (self) {
			lock = objc_getAssociatedObject(self, objectLockKey);
			if (!lock) {
				lock = NSObject.new;
				objc_setAssociatedObject(self, objectLockKey, lock, OBJC_ASSOCIATION_RETAIN);
			}
		}
	}
	
	return lock;
}

+ (NSObject*)dynamicMethodsInstanceProtocolLock
{
	void *objectLockKey = [self _dynamicMethodsInstanceProtocolLockKey];
	
	NSObject *lock = objc_getAssociatedObject(self, objectLockKey);
	if (!lock) {
		@synchronized (self) {
			lock = objc_getAssociatedObject(self, objectLockKey);
			if (!lock) {
				lock = NSObject.new;
				objc_setAssociatedObject(self, objectLockKey, lock, OBJC_ASSOCIATION_RETAIN);
			}
		}
	}
	
	return lock;
}



#pragma mark - Instance Dynamic Methods

+ (nonnull NSMutableDictionary<NSString*, BEDynamicMethodMeta*> *)dynamicSelfClassMethodsDictionary
{
	@synchronized ([self dynamicMethodsInstanceLock]) {
		return objc_getAssociatedObject(self, [self _dynamicClassMethodsMetaKey]);
	}
}


+ (BEDynamicMethodMeta *)dynamicClassMethodMeta:(nonnull SEL)selector
{
	if(!selector) {
		return nil;
	}
	
	@synchronized ([self dynamicMethodsInstanceLock]) {
		NSString *selectorString = NSStringFromSelector(selector);
		
		Class cls = self.class;
		BEDynamicMethodMeta	*meta = nil;
		do {
			if (!meta) {
				meta = [[cls dynamicSelfClassMethodsDictionary] objectForKey:selectorString];
			}
			if (meta) {
				BEDynamicMethodsActivationState status = [cls isDynamicMethodsEnabled];
				if (isDynamicMethodsEnabled(status)) {
					//when enabled, return
					return meta;
				} else if (isDynamicMethodsDisabled(status)) {
					//when found and disabled, reset
					meta = nil;
				} else {
					break;
				}
			}
			cls = cls.superclass;
		} while (cls != NSObject.class);
		return nil;
	}
}


+ (BOOL)isDynamicClassMethod:(nonnull SEL)selector
{
	if(!selector) {
		return NO;
	}
	return [self dynamicClassMethodMeta:selector] != nil;
}

/*!
 @method		+addClassMethod
 @abstract		Dynamically adds a class method to all instances of a class using a block.
 @param			selector	This is the selector of the new method.
 @param			block		This is the implementation of the new method.
 @discussion	This method adds a new class method available to all instances of this
 				class and its subclasses. The block signature is used to construct the
 				method signature.
 				The block should follow the format: `ReturnType (^)(id _self, ...)`
 				When adding the method, the block can be given the SEL as a second parameter.
 */
+ (BOOL)addClassMethod:(SEL)selector block:(nullable id)block
{
	if (!selector || !block || ![block isKindOfClass:NSClassFromString(@"NSBlock")]) {
		return NO;
	}
	
	NSString *selectorString = NSStringFromSelector(selector);
	BEDynamicMethodMeta	*meta = [BEDynamicMethodMeta.alloc initWithSelector:selector block:block];
	
	if (!meta) {
		return NO;
	}
	
	@synchronized ([self dynamicMethodsInstanceLock]) {
		NSMutableDictionary<NSString*, BEDynamicMethodMeta*> *dynamicMethods = [self dynamicSelfClassMethodsDictionary];
		
		if (!dynamicMethods) {
			dynamicMethods = NSMutableDictionary.new;
			objc_setAssociatedObject(self, [self _dynamicClassMethodsMetaKey], dynamicMethods, OBJC_ASSOCIATION_RETAIN);
		}
		// Replacing the entry releases any prior meta; its IMP is torn down in -dealloc once no
		// in-flight dispatch still references it.
		[dynamicMethods setObject:meta forKey:selectorString];
	}
	return YES;
}


/*!
 @method		+removeClassMethod:
 @abstract		Removes a dynamic class method from this class.
 @param			selector	The selector of the class method to remove.
 @discussion	This method removes a previously added dynamic class method.
 				The associated block is properly released and all metadata is cleaned up.
 @return 		YES if the method was removed, NO if it wasn't found.
 */
+ (BOOL)removeClassMethod:(SEL)selector
{
	if (!selector) {
		return NO;
	}
	
	NSString *selectorString = NSStringFromSelector(selector);
	
	@synchronized ([self dynamicMethodsInstanceLock]) {
		NSMutableDictionary<NSString*, BEDynamicMethodMeta*> *dynamicMethods = [self dynamicSelfClassMethodsDictionary];
		if (!dynamicMethods) {
			return NO;
		}
		
		BEDynamicMethodMeta	*meta = [dynamicMethods objectForKey:selectorString];
		
		if (!meta) {
			return NO;
		}
		
		// Unlink only; the meta's IMP is torn down in -dealloc once no in-flight dispatch references it.
		[dynamicMethods removeObjectForKey:selectorString];
		meta = nil;
		
		if (!dynamicMethods.count) {
			objc_setAssociatedObject(self.class, [self _dynamicClassMethodsMetaKey], nil, OBJC_ASSOCIATION_ASSIGN);
		}
		return YES;
	}
}



#pragma mark Object Dynamic Methods

- (nonnull NSMutableDictionary<NSString*, BEDynamicMethodMeta*> *)dynamicSelfObjectMethodsDictionary
{
	@synchronized ([self dynamicMethodsObjectLock]) {
		return objc_getAssociatedObject(self, [self _dynamicObjectMethodsMetaKey]);
	}
}


- (BEDynamicMethodMeta *)dynamicObjectMethodMeta:(nonnull SEL)selector
{
	if(!selector) {
		return nil;
	}
	
	@synchronized ([self dynamicMethodsObjectLock]) {
		NSString *selectorString = NSStringFromSelector(selector);
		if (!object_isClass(self)) {
			// when self is a normal object and enabled
			if (isDynamicMethodsEnabled([self.class isDynamicMethodsEnabled])) {
				return [[self dynamicSelfObjectMethodsDictionary] objectForKey:selectorString];
			}
			return nil;
		}
		
		// when self is a Class, traverse until NSObject
		Class cls = self.class;
		BEDynamicMethodMeta	*meta = nil;
		do {
			if (!meta) {
				meta = [[cls dynamicSelfObjectMethodsDictionary] objectForKey:selectorString];
			}
			if (meta) {
				BEDynamicMethodsActivationState status = [cls isDynamicMethodsEnabled];
				if (isDynamicMethodsEnabled(status)) {
					//when enabled, return
					return meta;
				} else if (isDynamicMethodsDisabled(status)) {
					//when found and disabled, reset
					meta = nil;
				} else {
					break;
				}
			}
			cls = [cls superclass];
		} while (cls != NSObject.class);
		return nil;
	}
}


- (BOOL)isDynamicObjectMethod:(nonnull SEL)selector
{
	if(!selector) {
		return NO;
	}
	return [self dynamicObjectMethodMeta:selector] != nil;
}


/*!
 @method		-addObjectMethod
 @abstract		Dynamically adds a method to an existing object using a block.
 @param			selector	This is the object selector of the new method.
 @param			block		This is the implementation of the new method.
 @discussion	This method adds a new method to an existing object with an implementing @c block.
				It derives the method signature from the block's signature by dropping the leading
				block (@c "?") parameter and treating the block's first explicit parameter as @c self.

				The block must be of the form @c (ReturnType (^)(id self, ...)) — the @c SEL @c _cmd is
				OPTIONAL: if the block's second parameter is a @c SEL it is delivered the selector
				being invoked; if omitted, the system adjusts the signature so the remaining arguments
				line up. So both @c ^(id self, NSString *arg) and @c ^(id self, SEL _cmd, NSString *arg)
				are valid.

				If a dynamic method already exists for @c selector it is replaced.
 */
- (BOOL)addObjectMethod:(SEL)selector block:(nullable id)block
{
	if (!selector || !block || ![block isKindOfClass:NSClassFromString(@"NSBlock")]) {
		return NO;
	}
	
	NSString *selectorString = NSStringFromSelector(selector);
	
	BEDynamicMethodMeta	*meta = [BEDynamicMethodMeta.alloc initWithSelector:selector block:block];
	if (!meta) {
		return NO;
	}
	
	@synchronized ([self dynamicMethodsObjectLock]) {
		NSMutableDictionary<NSString*, BEDynamicMethodMeta*> *dynamicObjectMethods = [self dynamicSelfObjectMethodsDictionary];
		
		if (!dynamicObjectMethods) {
			dynamicObjectMethods = NSMutableDictionary.new;
			objc_setAssociatedObject(self, [self _dynamicObjectMethodsMetaKey], dynamicObjectMethods, OBJC_ASSOCIATION_RETAIN);
		}
		// Replacing the entry releases any prior meta; its IMP is torn down in -dealloc once no
		// in-flight dispatch still references it.
		[dynamicObjectMethods setObject:meta forKey:selectorString];
	}
	return YES;
}


/*!
 @method		-removeObjectMethod:
 @abstract		Removes dynamic method from an existing object.
 @param			selector	The dynamic method to remove.
 @discussion	This method adds a new method to an existing object with an
				implementing @c block.
 @return 		Was the dynamic block method removed.
 
 */
- (BOOL)removeObjectMethod:(SEL)selector
{
	if (!selector) {
		return NO;
	}
	
	NSString *selectorString = NSStringFromSelector(selector);
	@synchronized ([self dynamicMethodsObjectLock]) {
		NSMutableDictionary<NSString*, BEDynamicMethodMeta*> *dynamicObjectMethods = [self dynamicSelfObjectMethodsDictionary];
		if (!dynamicObjectMethods) {
			return NO;
		}
		
		BEDynamicMethodMeta	*meta = [dynamicObjectMethods objectForKey:selectorString];
		
		if (!meta) {
			return NO;
		}
		
		// Unlink only; the meta's IMP is torn down in -dealloc once no in-flight dispatch references it.
		[dynamicObjectMethods removeObjectForKey:selectorString];
		meta = nil;
		
		if (!dynamicObjectMethods.count) {
			objc_setAssociatedObject(self, [self _dynamicObjectMethodsMetaKey], nil, OBJC_ASSOCIATION_ASSIGN);
		}
		return YES;
	}
}




#pragma mark - Instance Dynamic Protocols

// value is either BEDynamicMethodProtocolTargetMeta or NSMutableArray
+ (nonnull NSMutableDictionary<NSString*, id> *)dynamicSelfInstanceProtocolsDictionary
{
	@synchronized ([self dynamicMethodsObjectProtocolLock]) {
		return objc_getAssociatedObject(self, [self _dynamicInstanceProtocolMetaKey]);
	}
}

+ (id)dynamicClassForSelector:(SEL _Nonnull)selector isInstance:(BOOL)isInstance returnSignature:(BOOL)returnSignature
{
	if (!selector || self == NSObject.class) {
		return nil;
	}
	
	NSMutableDictionary<NSString*, id> *dynamicInstanceProtocols = [self dynamicSelfInstanceProtocolsDictionary];
	if (dynamicInstanceProtocols && isDynamicMethodsEnabled([self isDynamicMethodsEnabled])) {
		
		// 1) Loop through all the object protocols
		NSEnumerator *enumerator = [dynamicInstanceProtocols objectEnumerator];
		id object = nil;
		while ((object = [enumerator nextObject])) {
			if (![object isKindOfClass:BEDynamicMethodInstanceProtocolMeta.class]) {
				continue;
			}
			struct objc_method_description desc;
			
			BEDynamicMethodInstanceProtocolMeta *meta = object;
			Protocol *protocol = meta.protocol;
			
			// check Required Protocol Methods
			desc = protocol_getMethodDescription(protocol, selector, YES, isInstance);
			if (desc.name && desc.types) {
				if (returnSignature) {
					return [NSMethodSignature signatureWithObjCTypes:desc.types];
				}
				return meta.impClass;
			}
			
			// check Optional Protocol Methods
			desc = protocol_getMethodDescription(protocol, selector, NO, isInstance);
			if (desc.name && desc.types) {
				Class cls = meta.impClass;
				
				// check if the target responds to Selector
				if ((isInstance && [cls instancesRespondToSelector:selector]) || (!isInstance && [cls respondsToSelector:selector])) {
					if (returnSignature) {
						return [NSMethodSignature signatureWithObjCTypes:desc.types];
					}
					return cls;
				}
			}
		}
		
		// 2) Check the non-protocol targets if they respond to selector
		NSMutableArray<NSString*> *noProtocolTargets = [dynamicInstanceProtocols objectForKey:NSStringFromProtocol(@protocol(NSNoProtocol))];
			
		if (noProtocolTargets) {
			NSString *className;
			// enumerate through the non-protocol targets and search for the object that responds
			enumerator = [noProtocolTargets objectEnumerator];
			while ((className = [enumerator nextObject])) {
				Class cls = NSClassFromString(className);
				if ((isInstance && [cls instancesRespondToSelector:selector]) || (!isInstance && [cls respondsToSelector:selector])) {
					// Found
					if (returnSignature) {
						if (isInstance) {
							return [cls instanceMethodSignatureForSelector:selector];
						} else {
							return [cls methodSignatureForSelector:selector];
						}
					}
					return cls;
				}
			}
		}
	}
	
	// Check the class parents up the chain
	return [self.superclass dynamicClassForSelector:selector isInstance:isInstance returnSignature:returnSignature];
}


+ (id)dynamicClassForProtocol:(Protocol * _Nullable)protocol hasProtocol:(BOOL *)hasProtocol
{
	if (hasProtocol) {
		*hasProtocol = NO;
	}
	
	if (!protocol || self == NSObject.class) {
		return nil;
	}
	
	NSMutableDictionary<NSString*, id> *dynamicInstanceProtocols = [self dynamicSelfInstanceProtocolsDictionary];
	if (dynamicInstanceProtocols) {
		
		Protocol *noProtocol = @protocol(NSNoProtocol);
		
		NSString *protocolString = NSStringFromProtocol(protocol);
		id meta = [dynamicInstanceProtocols objectForKey:protocolString];
		
		// 1) check if the protocol is found with a target
		if (protocol == noProtocol) {
			// for a nil protocol, return the mutable array of basic targets
			return meta;
		} else if (meta) {
			if (hasProtocol) {
				*hasProtocol = YES;
			}
			return ((BEDynamicMethodInstanceProtocolMeta*)meta).impClass;
		}
		
		
		// 2) check all the protocol parents
		//		This is slower due to iterating, and why it's second.
		NSEnumerator *enumerator = [dynamicInstanceProtocols objectEnumerator];
		id object = nil;
		while ((object = [enumerator nextObject])) {
			if (![object isKindOfClass:BEDynamicMethodInstanceProtocolMeta.class]) {
				continue;
			}
			BEDynamicMethodInstanceProtocolMeta *meta = object;
			if ([meta.parentProtocols containsObject:protocol]) {
				if (hasProtocol) {
					*hasProtocol = YES;
				}
				return meta.impClass;
			}
		}
	}
	
	//Check the class parents up the chain
	return [self.superclass dynamicClassForProtocol:protocol hasProtocol:hasProtocol];
}

+ (BOOL)isDynamicInstanceProtocol:(nonnull Protocol*)protocol
{
	BOOL hasProtocol = NO;
	[self dynamicClassForProtocol:protocol hasProtocol:&hasProtocol];
	return hasProtocol;
}
+ (BOOL)addInstanceForwardClass:(nonnull Class)targetClass
{
	return [self addInstanceProtocol:nil withClass:targetClass];
}
+ (BOOL)addInstanceProtocol:(nonnull Protocol *)protocol
{
	return [self addInstanceProtocol:protocol withClass:nil];
}
+ (BOOL)addInstanceProtocol:(nullable Protocol *)aProtocol withClass:(nullable Class)targetClass
{
	BOOL isNoProtocol = !aProtocol || aProtocol == @protocol(NSNoProtocol);
	BOOL isNoTargetClass = !targetClass;
	
	if (isNoProtocol && isNoTargetClass) {
		return NO;
	}
	if (!aProtocol) {
		aProtocol = @protocol(NSNoProtocol);
	}
	
	@synchronized([self dynamicMethodsInstanceProtocolLock]) {
		NSMutableDictionary<NSString*, id> *dynamicInstanceProtocols = [self dynamicSelfInstanceProtocolsDictionary];
		
		if (!dynamicInstanceProtocols) {
			// Set the Dynamic Protocol-Target Dictionary
			dynamicInstanceProtocols = NSMutableDictionary.new;
			[dynamicInstanceProtocols setObject:NSMutableDictionary.new forKey:BEDMProtocolTargetLUTKey];
			objc_setAssociatedObject(self, [self _dynamicInstanceProtocolMetaKey], dynamicInstanceProtocols, OBJC_ASSOCIATION_RETAIN);
		}
		
		NSString *protocolString = NSStringFromProtocol(aProtocol);
		NSUInteger hash = 0;
		unsigned char digest[CC_SHA1_DIGEST_LENGTH];	// is 20 bytes
		if (isNoProtocol) {
			NSMutableArray<NSString*> *noProtocolClasses = [dynamicInstanceProtocols objectForKey:protocolString];
			if (!noProtocolClasses) {
				// Set the No Protocol list of targets.
				noProtocolClasses = NSMutableArray.new;
				[dynamicInstanceProtocols setObject:noProtocolClasses forKey:protocolString];
			}
			NSString *targetClassName = NSStringFromClass(targetClass);
			if ([noProtocolClasses containsObject:targetClassName]) {
				return NO;
			}
			[noProtocolClasses addObject:targetClassName];
			
			CC_SHA1(&targetClass, (CC_LONG)sizeof(Class), digest);
		} else {
			if ([dynamicInstanceProtocols objectForKey:protocolString]) {
				// there was already a class for the protocol, return failed
				return NO;
			}
			
			BEDynamicMethodInstanceProtocolMeta *meta = [BEDynamicMethodInstanceProtocolMeta.alloc initWithProtocol:aProtocol impClass:targetClass];
			[dynamicInstanceProtocols setObject:meta forKey:protocolString];
			
			CC_SHA1(&aProtocol, (CC_LONG)sizeof(Protocol*), digest);
		}
		
		hash = *(NSUInteger *)digest; //8 bytes long long so is fine,
		
		NSUInteger classHash = [self dynamicProtocolSelfHash];
		classHash ^= hash;
		[self setDynamicProtocolSelfHash:classHash];
		
		NSMutableDictionary<NSValue*, id> *reverseTargetLUT = [dynamicInstanceProtocols objectForKey:BEDMProtocolTargetLUTKey];
		if (!isNoTargetClass && !isNoProtocol) {
			// add the class to the reverse LUT
			[reverseTargetLUT setObject:protocolString forKey:[NSValue valueWithPointer:(__bridge const void *)(targetClass)]];
		}
	}
	return YES;
}
+ (BOOL)removeInstanceProtocol:(nonnull Protocol *)aProtocol
{
	return [self removeInstanceProtocol:aProtocol withClass:nil];
}
+ (BOOL)removeInstanceForwardClass:(nonnull Class)targetClass
{
	return [self removeInstanceProtocol:nil withClass:targetClass];
}
+ (BOOL)removeInstanceProtocol:(nullable Protocol *)aProtocol withClass:(nullable Class)targetClass
{
	BOOL isNoProtocol = !aProtocol || aProtocol == @protocol(NSNoProtocol);
	BOOL isNoTargetClass = !targetClass;
	
	if (isNoProtocol && isNoTargetClass) {
		return NO;
	}
	if (!aProtocol) {
		aProtocol = @protocol(NSNoProtocol);
	}
	
	NSString *protocolString = NSStringFromProtocol(aProtocol);
	BOOL removed = NO;
	
	@synchronized([self dynamicMethodsInstanceProtocolLock]) {
		NSMutableDictionary<NSString*, id> *dynamicInstanceProtocols = [self dynamicSelfInstanceProtocolsDictionary];
		
		if (!dynamicInstanceProtocols) {
			return NO;
		}
		
		NSMutableDictionary<NSValue*, id> *reverseTargetLUT = [dynamicInstanceProtocols objectForKey:BEDMProtocolTargetLUTKey];
		NSValue *targetClassValue = (targetClass) ? [NSValue valueWithPointer:(__bridge const void *)(targetClass)] : nil;
		if (isNoProtocol) {
			// if no protocol, look up protocol based on target from reverseTargetLUT
			id reverseProtocol = [reverseTargetLUT objectForKey:targetClassValue];
			if (reverseProtocol && reverseProtocol != [NSNull null]) {
				isNoProtocol = NO;
				protocolString = reverseProtocol;
			}
		}
		
		NSUInteger hash = 0;
		unsigned char digest[CC_SHA1_DIGEST_LENGTH];	// is 20 bytes
		if (isNoProtocol) {
			NSMutableArray<NSString*> *noProtocolTargets = [dynamicInstanceProtocols objectForKey:protocolString];
			if (!noProtocolTargets) {
				return NO;
			}
			NSString *targetClassName = NSStringFromClass(targetClass);
			BOOL hasTarget = [noProtocolTargets containsObject:targetClassName];
			if (hasTarget) {
				[noProtocolTargets removeObject:targetClassName];
				removed = YES;
				if (!noProtocolTargets.count) {
					[dynamicInstanceProtocols removeObjectForKey:protocolString];
				}
				[reverseTargetLUT removeObjectForKey:targetClassValue];
				CC_SHA1(&targetClass, (CC_LONG)sizeof(Class), digest);
			}
		} else {
			BEDynamicMethodInstanceProtocolMeta *protocolClass = [dynamicInstanceProtocols objectForKey:protocolString];
			
			if (!protocolClass || ![protocolClass isKindOfClass:BEDynamicMethodInstanceProtocolMeta.class] || (targetClass && protocolClass.impClass != targetClass)) {
				return NO;
			}
			[dynamicInstanceProtocols removeObjectForKey:protocolString];
			removed = YES;
			CC_SHA1(&aProtocol, (CC_LONG)sizeof(Protocol*), digest);
			
			if (targetClassValue) {
				[reverseTargetLUT removeObjectForKey:targetClassValue];
			}
		}
		
		hash = *(NSUInteger *)digest; //8 bytes long long so is fine,
		
		NSUInteger classHash = [self dynamicProtocolSelfHash];
		classHash ^= hash;
		[self setDynamicProtocolSelfHash:classHash];
		
		// if none or just the reverseTargetLUT
		NSUInteger protocolCount = dynamicInstanceProtocols.count;
		if (removed && (!protocolCount || (protocolCount == 1 && reverseTargetLUT))) {
			objc_setAssociatedObject(self, [self _dynamicInstanceProtocolMetaKey], nil, OBJC_ASSOCIATION_ASSIGN);
		}
	}
	return removed;
}



#pragma mark Object Dynamic Protocols


+ (uint64_t)dynamicProtocolHash
{
	uint64_t cummulativeHash = 0;
	Class cls = self;
	id priorObj = nil;
	do {
		if (isDynamicMethodsEnabled([cls isDynamicMethodsEnabled])) {
			cummulativeHash ^= [cls dynamicProtocolSelfHash];
		}
		priorObj = cls;
		cls = [cls superclass];
	} while (cls != priorObj);
	return cummulativeHash;
}
/*
- (void)setDynamicProtocolHash:(uint64_t)hash
{
	if (hash) {
		objc_setAssociatedObject(self, [self.class _dynamicInstanceProtocolHashKey], [NSNumber numberWithInteger:hash], OBJC_ASSOCIATION_RETAIN);
	} else {
		objc_setAssociatedObject(self, [self.class _dynamicInstanceProtocolHashKey], nil, OBJC_ASSOCIATION_ASSIGN);
	}
}*/

- (uint64_t)dynamicProtocolSelfHash
{
	return [objc_getAssociatedObject(self, [self.class _dynamicInstanceProtocolSelfHashKey]) unsignedIntegerValue];
}
- (void)setDynamicProtocolSelfHash:(uint64_t)hash
{
	if (hash) {
		objc_setAssociatedObject(self, [self.class _dynamicInstanceProtocolSelfHashKey], [NSNumber numberWithInteger:hash], OBJC_ASSOCIATION_RETAIN);
	} else {
		objc_setAssociatedObject(self, [self.class _dynamicInstanceProtocolSelfHashKey], nil, OBJC_ASSOCIATION_ASSIGN);
	}
}

// value is either BEDynamicMethodProtocolTargetMeta or NSMutableArray
- (nonnull NSMutableDictionary<NSString*, id> *)dynamicSelfObjectProtocolsDictionary
{
	@synchronized ([self dynamicMethodsObjectProtocolLock]) {
		return objc_getAssociatedObject(self, [self _dynamicObjectProtocolMetaKey]);
	}
}

- (BOOL)synchronizeWithClassProtocols
{
	BOOL returnValue = NO;
	@synchronized([self dynamicMethodsObjectProtocolLock]) {
		NSUInteger objectHash;
		NSUInteger classHash;
		@synchronized([self.class dynamicMethodsInstanceProtocolLock]) {
			objectHash = [self dynamicProtocolSelfHash];
			classHash = [self.class dynamicProtocolHash];
			if (objectHash == classHash) {
				return NO;
			}
		}
		
		NSString *noProtocolString = NSStringFromProtocol(@protocol(NSNoProtocol));
		NSMutableDictionary<NSString*, id> *instanceProtocols = NSMutableDictionary.new;
		NSMutableSet<NSString*>		*instanceClassTargets = NSMutableSet.new;
		Class cls = self.class;
		do {
			@synchronized([cls dynamicMethodsInstanceProtocolLock]) {
				if (isDynamicMethodsEnabled([cls isDynamicMethodsEnabled])) {
					NSMutableDictionary<NSString*, id> *dynamicInstanceProtocols = [cls dynamicSelfInstanceProtocolsDictionary];
					
					if (dynamicInstanceProtocols) {
						[instanceProtocols addEntriesFromDictionary:dynamicInstanceProtocols];
						[instanceProtocols removeObjectForKey:BEDMProtocolTargetLUTKey];
						NSMutableArray<NSString*> *instanceClasses = [instanceProtocols objectForKey:noProtocolString];
						if (instanceClasses) {
							[instanceClassTargets addObjectsFromArray:instanceClasses];
							[instanceProtocols removeObjectForKey:noProtocolString];
						}
					}
				}
				cls = cls.superclass;
			}
		} while (cls != NSObject.class);
		
		NSMutableDictionary *selfObjectProtocols = [self dynamicSelfObjectProtocolsDictionary];
		
		NSSet<NSString*> *classProtocols = [NSSet setWithArray:[instanceProtocols allKeys]];
		NSMutableSet<NSString*> *objectProtocols = [NSMutableSet setWithArray:[selfObjectProtocols allKeys]];
		[objectProtocols removeObject:noProtocolString];
		[objectProtocols removeObject:BEDMProtocolTargetLUTKey];

		NSMutableSet *addedProtocols = classProtocols.mutableCopy;
		[addedProtocols minusSet:objectProtocols];
		NSMutableSet *removedProtocols = objectProtocols.mutableCopy;
		[removedProtocols minusSet:classProtocols];
		
		if (addedProtocols.count) {
			[addedProtocols enumerateObjectsUsingBlock:^(NSString*  _Nonnull key, BOOL * _Nonnull stop) {
				BEDynamicMethodInstanceProtocolMeta *meta = [instanceProtocols objectForKey:key];
				[self addObjectProtocol:meta.protocol withTarget:meta];
			}];
		}
		if (removedProtocols.count) {
			[removedProtocols enumerateObjectsUsingBlock:^(NSString*  _Nonnull key, BOOL * _Nonnull stop) {
				BEDynamicMethodInstanceProtocolMeta *meta = [selfObjectProtocols objectForKey:key];
				
				[self removeObjectProtocol:meta.protocol];
			}];
		}
		
		NSMutableSet<NSString*>		*objectClassTargets = NSMutableSet.new;
		NSMutableDictionary<NSString*, id> *noProtocolTargets = nil;
		if (selfObjectProtocols) {
			noProtocolTargets = [selfObjectProtocols objectForKey:NSStringFromProtocol(@protocol(NSNoProtocol))];
			if (noProtocolTargets) {
				[noProtocolTargets enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull className, id  _Nonnull obj, BOOL * _Nonnull stop) {
					[objectClassTargets addObject:className];
				}];
			}
		}
		
		
		NSMutableSet<NSString*> *addedSet = instanceClassTargets.mutableCopy;
		[addedSet minusSet:objectClassTargets];
		
		if (addedSet.count) {
			[addedSet enumerateObjectsUsingBlock:^(NSString*  _Nonnull className, BOOL * _Nonnull stop) {
				Class cls = NSClassFromString(className);
				[self addObjectForwardTarget:[cls.alloc init]];
			}];
		}
		
		NSMutableSet<NSString*> *removedSet = objectClassTargets.mutableCopy;
		[removedSet minusSet:instanceClassTargets];
		
		if (noProtocolTargets && removedSet.count) {
			// Iterate the (smaller) removed set and look each target up directly in
			// the className→target map, rather than scanning every no-protocol target.
			for (NSString *className in removedSet) {
				id obj = noProtocolTargets[className];
				if (obj) {
					[self removeObjectForwardTarget:obj];
				}
			}
		}

		// Targets in both sets (instanceClassTargets ∩ objectClassTargets) are already
		// in sync, so they need no action.
		[self setDynamicProtocolSelfHash:classHash];
		// Reaching here means the object's protocol hash differed from the class's, so a
		// synchronization was performed. (The early-out above returns NO when already in sync.)
		returnValue = YES;
	}

	return returnValue;
}


- (id)dynamicObjectTargetForProtocol:(Protocol * _Nullable)protocol
{
	[self synchronizeWithClassProtocols];
	
	NSMutableDictionary<NSString*, id> *dynamicObjectProtocols = [self dynamicSelfObjectProtocolsDictionary];
	if (!dynamicObjectProtocols) {
		return nil;
	}
	
	Protocol *noProtocol = @protocol(NSNoProtocol);
	
	if (!protocol) {
		protocol = noProtocol;
	}
	
	NSString *protocolString = NSStringFromProtocol(protocol);
	id meta = [dynamicObjectProtocols objectForKey:protocolString];
	
	// 1) check if the protocol is found with a target
	if (protocol == noProtocol) {
		// for a nil protocol, return the mutable array of basic targets
		return meta;
	} else if (meta) {
		return ((BEDynamicMethodProtocolTargetMeta*)meta).target;
	}
	
	
	// 2) check all the protocol parents
	//		This is slower due to iterating, and why it's second.
	NSEnumerator *enumerator = [dynamicObjectProtocols objectEnumerator];
	id object = nil;
	while ((object = [enumerator nextObject])) {
		if (![object isKindOfClass:BEDynamicMethodProtocolTargetMeta.class]) {
			continue;
		}
		BEDynamicMethodProtocolTargetMeta *meta = object;
		if ([meta.parentProtocols containsObject:protocol]) {
			return meta.target;
		}
	}
	return nil;
}



- (id)dynamicObjectTargetForSelector:(SEL _Nonnull)selector returnSignature:(BOOL)returnSignature
{
	if (!selector) {
		return nil;
	}
	
	[self synchronizeWithClassProtocols];
	
	NSMutableDictionary<NSString*, id> *dynamicObjectProtocols = [self dynamicSelfObjectProtocolsDictionary];
	if (!dynamicObjectProtocols) {
		return nil;
	}
	
	// 1) Loop through all the object protocols
	NSEnumerator *enumerator = [dynamicObjectProtocols objectEnumerator];
	id object = nil;
	while ((object = [enumerator nextObject])) {
		if (![object isKindOfClass:BEDynamicMethodProtocolTargetMeta.class]) {
			continue;
		}
		struct objc_method_description desc;
		
		BEDynamicMethodProtocolTargetMeta *meta = object;
		Protocol *protocol = meta.protocol;
		
		// check Required Protocol Methods
		desc = protocol_getMethodDescription(protocol, selector, YES, YES);
		if (desc.name && desc.types) {
			if (returnSignature) {
				return [NSMethodSignature signatureWithObjCTypes:desc.types];
			}
			return meta.target;
		}
		
		// check Optional Protocol Methods
		desc = protocol_getMethodDescription(protocol, selector, NO, YES);
		if (desc.name && desc.types) {
			id target = meta.target;
			
			// check if the target responds to Selector
			if ([target respondsToSelector:selector]) {
				if (returnSignature) {
					return [NSMethodSignature signatureWithObjCTypes:desc.types];
				}
				return target;
			}
		}
	}
	
	// 2) Check the non-protocol targets if they respond to selector
	NSMutableDictionary<NSString*, id> *noProtocolTargets = [dynamicObjectProtocols objectForKey:NSStringFromProtocol(@protocol(NSNoProtocol))];
	if (!noProtocolTargets) {
		return nil;
	}
	
	// enumerate through the non-protocol targets and search for the object that responds
	enumerator = [noProtocolTargets objectEnumerator];
	while ((object = [enumerator nextObject])) {
		if ([object respondsToSelector:selector]) {
			if (returnSignature) {
				return [object methodSignatureForSelector:selector];
			}
			return object;
		}
	}
	
	return nil;
}


- (id)targetForProtocol:(Protocol *)protocol
{
	id target = [self dynamicObjectTargetForProtocol:protocol];
	if ([target isKindOfClass:NSMutableDictionary.class]) {
		return [target allValues];
	}
	return target;
}


- (BOOL)isDynamicObjectProtocol:(nonnull Protocol *)protocol
{
	if(!protocol) {
		return NO;
	}
	id target = [self dynamicObjectTargetForProtocol:protocol];
	return target && ![target isKindOfClass:NSMutableDictionary.class]; // && ![target isKindOfClass:NSMutableArray.class]
}

- (BOOL)addObjectProtocol:(nonnull Protocol *)aProtocol
{
	return [self addObjectProtocol:aProtocol withTarget:nil];
}

- (BOOL)addObjectForwardTarget:(nonnull id)target
{
	return [self addObjectProtocol:nil withTarget:target];
}

- (BOOL)addObjectProtocol:(nullable Protocol *)aProtocol withTarget:(nullable id)target
{
	BEDynamicMethodInstanceProtocolMeta *classMeta = nil;
	
	if ([target isKindOfClass:BEDynamicMethodInstanceProtocolMeta.class]) {
		// target isa BEDynamicMethodInstanceProtocolMeta, extract objects
		classMeta = target;
		id impObject = nil;
		
		Class targetClass = classMeta.impClass;
		if (targetClass) {
			//construct new target from class
			impObject = [[targetClass alloc] init];
			if ([impObject respondsToSelector:@selector(setOriginalObject:)]) {
				// set original object
				// @warning generate this test
				
				[impObject setOriginalObject:self];
			}
		}
		target = impObject;
	}
	
	BOOL isNoProtocol = !aProtocol || aProtocol == @protocol(NSNoProtocol);
	BOOL isNoTarget = !target || target == [NSNull null];
	
	if (isNoProtocol && isNoTarget) {
		return NO;
	}
	if (!aProtocol) {
		aProtocol = @protocol(NSNoProtocol);
	}
	
	@synchronized([self dynamicMethodsObjectProtocolLock]) {
		NSMutableDictionary<NSString*, id> *dynamicObjectProtocols = [self dynamicSelfObjectProtocolsDictionary];
		
		if (!dynamicObjectProtocols) {
			// Set the Dynamic Protocol-Target Dictionary
			dynamicObjectProtocols = NSMutableDictionary.new;
			[dynamicObjectProtocols setObject:NSMutableDictionary.new forKey:BEDMProtocolTargetLUTKey];
			objc_setAssociatedObject(self, [self _dynamicObjectProtocolMetaKey], dynamicObjectProtocols, OBJC_ASSOCIATION_RETAIN);
		}
		
		id protocolString = NSStringFromProtocol(aProtocol);
		if (isNoProtocol) {
			//	 protocolString = NSStringFromProtocol(@protocol(NSNoProtocol));
			NSMutableDictionary<NSString*, id> *noProtocolTargets = [dynamicObjectProtocols objectForKey:protocolString];
			if (!noProtocolTargets) {
				// Set the No Protocol list of targets.
				noProtocolTargets = NSMutableDictionary.new;
				[dynamicObjectProtocols setObject:noProtocolTargets forKey:protocolString];
			}
			NSString *targetClassName = NSStringFromClass([target class]);
			id classTarget = [noProtocolTargets objectForKey:targetClassName];
			if (classTarget) {
				// not the same target for the class
				return NO;
			}
			[noProtocolTargets setObject:target forKey:targetClassName];
			
			//without a protocol, the object in the reverseTargetLUT must be [NSNull null]
			protocolString = [NSNull null];
		} else {
			if ([dynamicObjectProtocols objectForKey:protocolString]) {
				// there was already a target for the protocol, return failed
				return NO;
			}
			
			BEDynamicMethodProtocolTargetMeta *meta = [BEDynamicMethodProtocolTargetMeta.alloc initWithProtocol:aProtocol target:target instanceMeta:classMeta];
			[dynamicObjectProtocols setObject:meta forKey:protocolString];
		}
		
		NSMutableDictionary<NSValue*, id> *reverseTargetLUT = [dynamicObjectProtocols objectForKey:BEDMProtocolTargetLUTKey];
		if (!isNoTarget) {
			// add the target to the reverse LUT
			[reverseTargetLUT setObject:protocolString forKey:[NSValue valueWithPointer:(__bridge const void *)(target)]];
		}
	}
	return YES;
}

- (BOOL)removeObjectProtocol:(nonnull Protocol *)aProtocol
{
	return [self removeObjectProtocol:aProtocol withTarget:nil];
}

- (BOOL)removeObjectForwardTarget:(nonnull id)target
{
	return [self removeObjectProtocol:nil withTarget:target];
}

- (BOOL)removeObjectProtocol:(nullable Protocol *)aProtocol withTarget:(nullable id)target
{
	BOOL isNoProtocol = !aProtocol || aProtocol == @protocol(NSNoProtocol);
	BOOL isNoTarget = !target || target == [NSNull null];
	
	if (isNoProtocol && isNoTarget) {
		return NO;
	}
	if (!aProtocol) {
		aProtocol = @protocol(NSNoProtocol);
	}
	
	NSString *protocolString = NSStringFromProtocol(aProtocol);
	BOOL removed = NO;
	
	@synchronized([self dynamicMethodsObjectProtocolLock]) {
		NSMutableDictionary<NSString*, id> *dynamicObjectProtocols = [self dynamicSelfObjectProtocolsDictionary];
		
		if (!dynamicObjectProtocols) {
			return NO;
		}
		
		NSMutableDictionary<NSValue*, id> *reverseTargetLUT = [dynamicObjectProtocols objectForKey:BEDMProtocolTargetLUTKey];
		NSValue *targetValue = (target) ? [NSValue valueWithPointer:(__bridge const void *)(target)] : nil;
		if (isNoProtocol) {
			// if no protocol, look up protocol based on target from reverseTargetLUT
			id reverseProtocol = [reverseTargetLUT objectForKey:targetValue];
			if (reverseProtocol && reverseProtocol != [NSNull null]) {
				isNoProtocol = NO;
				protocolString = reverseProtocol;
			}
		}
		if (isNoProtocol) {
			NSMutableDictionary<NSString*, id> *noProtocolTargets = [dynamicObjectProtocols objectForKey:protocolString];
			if (!noProtocolTargets) {
				return NO;
			}
			NSString *targetClassName = NSStringFromClass([target class]);
			id classTarget = [noProtocolTargets objectForKey:targetClassName];
			if (classTarget == target) {
				[noProtocolTargets removeObjectForKey:targetClassName];
				removed = YES;
				if (!noProtocolTargets.count) {
					[dynamicObjectProtocols removeObjectForKey:protocolString];
				}
				[reverseTargetLUT removeObjectForKey:targetValue]; // objectForKey is NSNull
			}
		} else {
			BEDynamicMethodProtocolTargetMeta *protocolTarget = [dynamicObjectProtocols objectForKey:protocolString];
			
			if (!protocolTarget || ![protocolTarget isKindOfClass:BEDynamicMethodProtocolTargetMeta.class] || (target && protocolTarget.target != target)) {
				return NO;
			}
			[dynamicObjectProtocols removeObjectForKey:protocolString];
			removed = YES;
			if (protocolTarget.target) {
				[reverseTargetLUT removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(protocolTarget.target)]];
			}
		}
		
		// if removed and (count is none or just the reverseTargetLUT)
		NSUInteger protocolCount = dynamicObjectProtocols.count;
		if (removed && (!protocolCount || (protocolCount == 1 && reverseTargetLUT))) {
			objc_setAssociatedObject(self, [self _dynamicObjectProtocolMetaKey], nil, OBJC_ASSOCIATION_ASSIGN);
		}
	}
	return removed;
}



#pragma mark - Combined Checking Methods

- (BOOL)isDynamicMethod:(nonnull SEL)selector
{
	if(!selector) {
		return NO;
	}
	if ([self isDynamicObjectMethod:selector]) {
		return YES;
	}
	// Protocol-conforming targets (required, and optional when the target responds) and
	// no-protocol forward targets.  This also synchronizes the receiver's class instance
	// protocols, so a selector handled only via instance/object protocol forwarding is found.
	if ([self dynamicObjectTargetForSelector:selector returnSignature:NO] != nil) {
		return YES;
	}
	if (object_isClass(self)) {
		return NO;
	}
	return [self.class isDynamicClassMethod:selector];
}



#pragma mark Functional Method Resolution


- (BOOL)dynamicConformsToProtocol:(nonnull Protocol *)aProtocol
{
	if (!aProtocol) {
		return NO;
	}
	
	id target = [self dynamicObjectTargetForProtocol:aProtocol];
	
	return target != nil && ![target isKindOfClass:NSMutableArray.class] && ![target isKindOfClass:NSMutableDictionary.class];
}


- (nullable NSMethodSignature *)dynamicMethodSignatureForSelector:(nonnull SEL)aSelector
{
	if (!aSelector) {
		return nil;
	}
	
	BEDynamicMethodMeta *meta = [self dynamicObjectMethodMeta:aSelector];
	
	if (!meta && !object_isClass(self)) {
		meta = [self.class dynamicClassMethodMeta:aSelector];
	}
	
	if (meta) {
		return meta.methodSignature;
	}
	
	return [self dynamicObjectTargetForSelector:aSelector returnSignature:YES];
}


- (BOOL)dynamicRespondsToSelector:(nonnull SEL)aSelector
{
	if (!aSelector) {
		return NO;
	}
	
	BEDynamicMethodMeta *meta = [self dynamicObjectMethodMeta:aSelector];
	
	if (!meta && !object_isClass(self)) {
		meta = [self.class dynamicClassMethodMeta:aSelector];
	}
	if (meta) {
		return YES;
	}
	
	id target = [self dynamicObjectTargetForSelector:aSelector returnSignature:NO];
	
	return target != nil;
}


- (BOOL)dynamicForwardInvocation:(nonnull NSInvocation *)invocation
{
	if (!invocation) {
		return NO;
	}
	
	SEL aSelector = invocation.selector;
	
	BEDynamicMethodMeta *meta = [self dynamicObjectMethodMeta:aSelector];
	
	if (!meta && !object_isClass(self)) {
		meta = [self.class dynamicClassMethodMeta:aSelector];
	}
	
	if (meta) {
		NSInvocation *impInvocation = invocation;
		if (meta.isCapturingCmd) {
			impInvocation = [BEMethodSignatureHelper mutateInvocation:impInvocation withMeta:meta];
		}
		
		[impInvocation invokeUsingIMP:meta.implementation];
		
		if (meta.isCapturingCmd) {
			NSUInteger returnLength = invocation.methodSignature.methodReturnLength;
			if (returnLength) {
				BOOL largeReturnLength = returnLength >= 256;
				void *returnData = largeReturnLength ? malloc(returnLength) : alloca(returnLength);
				
				[impInvocation getReturnValue:returnData];
				[invocation setReturnValue:returnData];
				
				if (largeReturnLength) {
					free(returnData);
				}
			}
		}
		
		return YES;
	} else {
		id target = [self dynamicObjectTargetForSelector:aSelector returnSignature:NO];
		if (target) {
			[invocation invokeWithTarget:target];
			return YES;
		}
	}
	return NO;
}



+ (BOOL)dynamicInstancesRespondToSelector:(nonnull SEL)aSelector
{
   if (!aSelector) {
	   return NO;
   }

   BEDynamicMethodMeta *meta = [self.class dynamicClassMethodMeta:aSelector];
   if (meta) {
	   return YES;
   }

	return [self dynamicClassForSelector:aSelector isInstance:YES returnSignature:NO] != nil;
}


+ (nullable NSMethodSignature *)dynamicInstanceMethodSignatureForSelector:(nonnull SEL)aSelector
{
	if (!aSelector) {
		return nil;
	}

	BEDynamicMethodMeta *meta = [self dynamicClassMethodMeta:aSelector];
	if (meta) {
		return meta.methodSignature;
	}

	return [self dynamicClassForSelector:aSelector isInstance:YES returnSignature:YES];
}

+ (BOOL)dynamicClassConformsToProtocol:(nonnull Protocol *)aProtocol
{
	if (!aProtocol) {
		return NO;
	}
	
	BOOL hasProtocol = NO;
	[self dynamicClassForProtocol:aProtocol hasProtocol:&hasProtocol];
	
	return hasProtocol;
}


+ (nullable NSMethodSignature *)dynamicClassMethodSignatureForSelector:(nonnull SEL)aSelector
{
	if (!aSelector) {
		return nil;
	}

	// Check methods added via addObjectMethod: directly on the class object.
	// (addClassMethod: entries are instance-facing and must NOT appear here.)
	BEDynamicMethodMeta *meta = [self dynamicObjectMethodMeta:aSelector];
	if (meta) {
		return meta.methodSignature;
	}

	// Check protocol-based class-level methods (isInstance:NO).
	return [self dynamicClassForSelector:aSelector isInstance:NO returnSignature:YES];
}


+ (BOOL)dynamicClassRespondsToSelector:(nonnull SEL)aSelector
{
	if (!aSelector) {
		return NO;
	}

	// Check methods added via addObjectMethod: directly on the class object.
	if ([self dynamicObjectMethodMeta:aSelector]) {
		return YES;
	}

	// Check protocol-based class-level methods (isInstance:NO).
	id target = [self dynamicClassForSelector:aSelector isInstance:NO returnSignature:NO];

	return target != nil;
}


+ (BOOL)dynamicClassForwardInvocation:(nonnull NSInvocation *)invocation
{
	if (!invocation) {
		return NO;
	}

	SEL aSelector = invocation.selector;

	// Check methods added via addObjectMethod: directly on the class object.
	BEDynamicMethodMeta *meta = [self dynamicObjectMethodMeta:aSelector];
	
	if (meta) {
		NSInvocation *impInvocation = invocation;
		if (meta.isCapturingCmd) {
			impInvocation = [BEMethodSignatureHelper mutateInvocation:impInvocation withMeta:meta];
		}
		
		[impInvocation invokeUsingIMP:meta.implementation];
		
		if (meta.isCapturingCmd) {
			NSUInteger returnLength = invocation.methodSignature.methodReturnLength;
			if (returnLength) {
				BOOL largeReturnLength = returnLength >= 256;
				void *returnData = largeReturnLength ? malloc(returnLength) : alloca(returnLength);
				
				[impInvocation getReturnValue:returnData];
				[invocation setReturnValue:returnData];
				
				if (largeReturnLength) {
					free(returnData);
				}
			}
		}
		return YES;
	} else {
		id target = [self dynamicClassForSelector:aSelector isInstance:NO returnSignature:NO];
		if (target) {
			[invocation invokeWithTarget:target];
			return YES;
		}
	}
	return NO;
}

@end




#pragma mark - NSDynamicObject

@implementation NSDynamicObject

+ (void)load
{
	NSDynamicObject.allowNSDynamicMethods = YES;
	[self enableDynamicMethods];
}

@end
