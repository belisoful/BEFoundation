/*!
 @file			NSObject+DynamicMethods.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract
 @discussion
*/

#import "NSObject+DynamicMethods.h"
#import "NSObject+DynamicMethodsHelpers.h"
#import <objc/runtime.h>


NSOrderedSet<Protocol *> *recursiveProtocolsFromProtocol(Protocol *protocol)
{
	if (!protocol) {
		return [NSOrderedSet orderedSet];
	}
	
	NSMutableOrderedSet<Protocol *> *pending = [NSMutableOrderedSet orderedSet];
	NSMutableOrderedSet<Protocol *> *visited = [NSMutableOrderedSet orderedSet];
	
	[pending addObject:protocol];
	
	while ([pending count] > 0) {
		Protocol *current = [pending firstObject];
		[pending removeObjectAtIndex:0];
		[visited addObject:current];
		
		unsigned int count = 0;
		Protocol *__unsafe_unretained *parents = protocol_copyProtocolList(current, &count);
		
		for (unsigned int i = 0; i < count; i++) {
			Protocol *parent = parents[i];
			if (![visited containsObject:parent]) {
				[pending addObject:parent];
			}
		}
		
		free(parents);
	}
	
	return [visited copy];
}

@implementation BEDynamicMethodSwizzleSelectors
@synthesize isMetaClass = _isMetaClass, originalSelector = _originalSelector, swizzleSelector = _swizzleSelector;

+ (nonnull)swizzleOriginal:(SEL)originalSelector withSelector:(SEL)aSelector
{
	return [BEDynamicMethodSwizzleSelectors.alloc initWithOriginal:originalSelector swizzleSelector:aSelector isMetaClass:NO];
}

+ (nonnull)swizzleMetaOriginal:(SEL)originalSelector withSelector:(SEL)aSelector
{
	return [BEDynamicMethodSwizzleSelectors.alloc initWithOriginal:originalSelector swizzleSelector:aSelector isMetaClass:YES];
}

- (nullable instancetype)initWithOriginal:(SEL)originalSelector swizzleSelector:(SEL)aSelector isMetaClass:(BOOL)isMetaClass
{
	self = [super init];
	if (self) {
		_isMetaClass = isMetaClass;
		_originalSelector = originalSelector;
		_swizzleSelector = aSelector;
	}
	return self;
}

- (int)swizzleMethodsOnClass:(Class)targetClass
{
	if (!targetClass) {
		return 0;
	}
	
	// if we need to swizzle the meta-class, target the meta class
	// this will replace the methods on the meta-class of the object rather than the Class of the object:
	//   swizzleing + class objects will work the same way as - on the class object
	//	but swizzling the instance method of the class object, like -(BOOL)respondsToSelector:(SEL) on the class object requires swizzleing the metaclass
	if (self.isMetaClass) {
		targetClass = object_getClass(targetClass);
	}
	SEL originalSelector = self.originalSelector;
	SEL swizzleSelector = self.swizzleSelector;
	
	Method originalMethod = class_getInstanceMethod(targetClass, originalSelector);
	if (!originalMethod) {
		return 0;
	}
	
	Method swizzleMethod = class_getInstanceMethod(targetClass, swizzleSelector);
	if (!swizzleMethod) {
		return 0; // Swizzle Selector not found
	}

	const char *originalTypeEncoding = method_getTypeEncoding(originalMethod);
	const char *swizzledTypeEncoding = method_getTypeEncoding(swizzleMethod);

	if (strcmp(originalTypeEncoding, swizzledTypeEncoding) != 0) {
		return 0; // Signature mismatch
	}

	BOOL didAddMethod = class_addMethod(targetClass,
										originalSelector,
										method_getImplementation(swizzleMethod),
										swizzledTypeEncoding);

	if (didAddMethod) {
		// If original method didn't exist in target class, replace the replacementSelector
		class_replaceMethod(targetClass,
							swizzleSelector,
							method_getImplementation(originalMethod),
							originalTypeEncoding);
		return -1;
	} else {
		// Exchange implementations in the target class/meta-class
		method_exchangeImplementations(originalMethod, swizzleMethod);
	}

	return 1;
}


+ (void*)swizzleKey {
	return @selector(swizzleKey);
}


+ (BOOL)statusClassHasSwizzle:(Class _Nonnull)cls
{
	return objc_getAssociatedObject(cls, [self swizzleKey]) != nil;
}


+ (BOOL)statusClassIsSwizzled:(Class _Nonnull)cls
{
	return [objc_getAssociatedObject(cls, [self swizzleKey]) boolValue];
}


+ (BEDynamicMethodsSwizzleState)statusClassSwizzled:(Class _Nonnull)cls
{
	NSNumber *isSwizzled = objc_getAssociatedObject(cls, [self swizzleKey]);
	if (!isSwizzled) {
		return DMSwizzleNone;
	}
	return isSwizzled.boolValue ? DMSwizzleOn : DMSwizzleOff;
}

+ (void)setClass:(Class _Nonnull)cls swizzle:(BEDynamicMethodsSwizzleState)status
{
	if (cls == NSObject.class) {
		return;
	}
	if (status == DMSwizzleNone) {
		objc_setAssociatedObject(cls, [self swizzleKey], nil, OBJC_ASSOCIATION_ASSIGN);
	} else {
		objc_setAssociatedObject(cls, [self swizzleKey], @(status == DMSwizzleOn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
}

+ (BOOL)statusParentsAreSwizzled:(Class _Nonnull)cls
{
	Class priorCls = nil;
	cls = [cls superclass];
	
	while (cls && cls != priorCls) {
		@synchronized (cls) {
			if ([self statusClassIsSwizzled:cls]) {
				return YES;
			}
			priorCls = cls;
			cls = [cls superclass];
		}
	}
	
	return NO;
}
	
@end





@implementation BEMethodSignatureHelper (DynamicMethods)

+ (nullable NSMethodSignature *)invocableMethodSignatureFromBlock:(nonnull id)block
{
	if(!block) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: nil argument", NSMethodSignature.className, NSStringFromSelector(_cmd)];
	} else if (![block isKindOfClass:NSClassFromString(@"NSBlock")]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: Argument is not a NSBlock", NSMethodSignature.className, NSStringFromSelector(_cmd)];
	}
	
	const char *rawBlockSignature = [BEMethodSignatureHelper rawBlockSignatureChar:block];
	
	if (!rawBlockSignature) {
		return nil;
	}
	
	NSString* blockSignature = [BEMethodSignatureHelper parseBlockSignature:rawBlockSignature
																 parseFlags:BERequireSelectorFlag | BEReplicateSelectorFlag];
	
	if (!blockSignature) {
		return nil;
	}
	
	return [NSMethodSignature signatureWithObjCTypes:[blockSignature cStringUsingEncoding:NSASCIIStringEncoding]];
}


+ (NSInvocation*)mutateInvocation:(NSInvocation *)invocation withMeta:(BEDynamicMethodMeta *)meta
{
	if (!invocation || ![invocation isKindOfClass:NSInvocation.class]){
		return nil;
	}
	if (!meta || ![meta isKindOfClass:BEDynamicMethodMeta.class] || !meta.blockSignature) {
		return nil;
	}
	
	int additionalSEL = meta.isCapturingCmd ? 1 : 0;
	NSUInteger methodArgumentCount = invocation.methodSignature.numberOfArguments;
	NSUInteger blockArgumentCount = meta.blockSignature.numberOfArguments;
	
	if(methodArgumentCount + additionalSEL != blockArgumentCount) {
		return nil;
	}
	NSInvocation *mutatedInvocation = [NSInvocation invocationWithMethodSignature:meta.blockSignature];
	
	SEL selector = invocation.selector;
	
	mutatedInvocation.target = invocation.target;
	mutatedInvocation.selector = selector;
	if (additionalSEL) {
		[mutatedInvocation setArgument:&selector atIndex:2];
	}
	
	if (methodArgumentCount >= 2) {
#define InitialArgumentSize 256
		NSUInteger dsize = InitialArgumentSize;
		void *data = malloc(dsize);
		for(int i = 2; i < methodArgumentCount; i++) {
			NSUInteger size = [invocation.methodSignature getArgumentSizeAtIndex:i];
			if (size > dsize) {
				free(data);
				dsize = size;
				data = malloc(dsize);
			}
			[invocation getArgument:data atIndex:i];
			[mutatedInvocation setArgument:data atIndex:i + additionalSEL];
		}
		free(data);
	}
	
	if (invocation.argumentsRetained) {
		[mutatedInvocation retainArguments];
	}
	
	return mutatedInvocation;
}

@end

