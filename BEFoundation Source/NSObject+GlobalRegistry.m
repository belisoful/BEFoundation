/*!
 @file			NSObject+DynamicMethods.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract
 @discussion
*/
#import <objc/runtime.h>
#import "NSObject+GlobalRegistry.h"


@implementation NSObject (GlobalRegistry)

+ (BEObjectRegistry *)globalRegistry
{
	__block BEObjectRegistry *registry = objc_getAssociatedObject(BEObjectRegistry.class, @selector(globalRegistry));
	if (!registry) {
		@synchronized(BEObjectRegistry.class) {
			registry = objc_getAssociatedObject(BEObjectRegistry.class, @selector(globalRegistry));
			if (!registry) {
				static dispatch_once_t globalRegistryOnce;
				dispatch_once(&globalRegistryOnce, ^{
					registry = BEObjectRegistry.new;
					objc_setAssociatedObject(BEObjectRegistry.class, @selector(globalRegistry), registry, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
				});
			}
		}
	}
	return registry;
}

- (NSString *)globalRegistryUUID
{
	return [NSObject.globalRegistry registryUUIDForObject:(id)self];
}

- (NSUInteger)globalRegistryCount
{
	return [NSObject.globalRegistry registeredCountForObject:(id)self];
}

- (BOOL)isGlobalRegistered
{
	return [NSObject.globalRegistry isObjectRegistered:(id)self];
}



- (NSString *)registerGlobalInstance
{
	return [NSObject.globalRegistry registerObject:(id)self];
}

// 0 is not registered, 1 is decreasing the registration count, 2 is full unregistration.
- (int)unregisterGlobalInstance
{
	return [NSObject.globalRegistry unregisterObject:(id)self];
}

@end
