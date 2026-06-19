/*!
 @file			NSObject+GlobalRegistry.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Implements the NSObject (BEGlobalRegistry) category over the shared BEObjectRegistry singleton.
 @discussion	Provides the lazily-created, process-wide globalRegistry and the per-instance
				registration helpers (registerGlobalInstance / unregisterGlobalInstance and the
				BERegistryProtocol accessors), each forwarding to the singleton registry.
*/
#import <objc/runtime.h>
#import "NSObject+GlobalRegistry.h"


@implementation NSObject (BEGlobalRegistry)

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


- (void)setGlobalRegistryUUID:(NSString *)uuid
{
	[NSObject.globalRegistry setRegistryUUID:uuid forObject:(id)self];
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

// BEUnregisterStatus: 0 = not registered, 1 = decremented, 3 = fully unregistered.
- (BEUnregisterStatus)unregisterGlobalInstance
{
	return [NSObject.globalRegistry unregisterObject:(id)self];
}

@end
