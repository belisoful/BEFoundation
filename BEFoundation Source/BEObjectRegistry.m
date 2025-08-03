/*!
 @file			NSObject+DynamicMethods.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract
 @discussion
*/
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
#import "BEObjectRegistry.h"

NSExceptionName	const  NSDuplicateUUIDException = @"NSDuplicateUUIDException";


#define CounterObjectKey(object)  [NSValue valueWithPointer:(void*)(object)]

static NSMutableDictionary *gSaltLocks;

@implementation BEObjectRegistry

@synthesize requireRegistryProtocol = _requireRegistryProtocol;
@synthesize objectCountKey = _objectCountKey;
@synthesize uuidKey = _uuidKey;
@synthesize keySalt = _keySalt;

+ (NSPointerFunctionsOptions)keyOptions
{
	return NSPointerFunctionsStrongMemory;
}

+ (NSPointerFunctionsOptions)valueOptions
{
	return NSPointerFunctionsWeakMemory;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		_requireRegistryProtocol = YES;
		_keySalt = 0;
		_uuidKey = 0;
		
		// Create a map table with weak references to instances
		registryTable = [NSMapTable mapTableWithKeyOptions:self.class.keyOptions
											  valueOptions:self.class.valueOptions];
		objectCounter = NSCountedSet.new;
		
		static dispatch_once_t once;
		dispatch_once(&once, ^{
			gSaltLocks = NSMutableDictionary.new;
			gSaltLocks[@0] = NSObject.new;
		});
	}
	return self;
}


- (instancetype)initWithKeySalt:(NSUInteger)salt
{
	self = [self init];
	if (self) {
		_keySalt = salt;
		
		NSNumber *saltLockKey = @(salt);
		@synchronized(gSaltLocks) {
			if(![gSaltLocks objectForKey:saltLockKey])
				gSaltLocks[saltLockKey] = NSObject.new;
		}
	}
	return self;
}


- (void)dealloc
{
	[self clearAllRegisteredObjects];
}


- (void *)uuidKey
{
	if (!_uuidKey) {
		unsigned char digest[CC_SHA1_DIGEST_LENGTH];	// is 20 bytes
		CC_SHA1(&_keySalt, (CC_LONG)sizeof(_keySalt), digest);
		NSUInteger salt = *(NSUInteger *)digest; //8 bytes long long so is fine,
		_uuidKey = (void *)(((NSUInteger)((void*)_cmd)) ^ salt);
	}
	return _uuidKey;
}

- (void *)objectCountKey
{
	if (!_objectCountKey) {
		unsigned char digest[CC_SHA1_DIGEST_LENGTH];	// is 20 bytes
		CC_SHA1(&_keySalt, (CC_LONG)sizeof(_keySalt), digest);
		NSUInteger salt = *(NSUInteger *)digest; //8 bytes long long so is fine,
		_objectCountKey = (void *)(((NSUInteger)((void*)_cmd)) ^ salt);
	}
	return _objectCountKey;
}

- (id)saltLock
{
	NSNumber *saltLockKey = @(_keySalt);
	return [gSaltLocks objectForKey:saltLockKey];
}

- (NSUInteger)registeredObjectsCount
{
	@synchronized(registryTable) {
		return registryTable.count;
	}
}

- (NSString *)simpleRegistryUUIDForObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		return nil;
	}
	NSString *instanceUUID = nil;
	
	@synchronized (registryTable) {
		void* uuidKey = [self uuidKey];
		instanceUUID = objc_getAssociatedObject(object, uuidKey);
		
		//	If the object conforms to the CustomRegistryUUID, call the object and set
		if (!instanceUUID && [object conformsToProtocol:@protocol(CustomRegistryUUID)]) {
			instanceUUID = [(id<CustomRegistryUUID>)object objectRegistryUUID:self];
			objc_setAssociatedObject(object, uuidKey, instanceUUID, OBJC_ASSOCIATION_RETAIN);
		}
	}
	return instanceUUID;
}


- (NSString *)setSimpleRegistryUUID:(NSString *)uuid forObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		return nil;
	}
	// Don't set CustomRegistryUUID objects
	if ([object conformsToProtocol:@protocol(CustomRegistryUUID)]) {
		return uuid;
	}
	@synchronized (registryTable) {
		if (uuid) {
			id<NSObject> instance = [registryTable objectForKey:uuid];
			if (instance && instance != object) {
				[NSException raise:NSDuplicateUUIDException
							format:@"*** -[%@ %@]: uuid '%@' is already used for '%@' at %p but trying to set it to '%@' at %p",
				 self.className, NSStringFromSelector(_cmd), uuid, ((NSObject*)instance).className, instance, ((NSObject*)object).className, object];
			}
			NSString *priorUUID = [self simpleRegistryUUIDForObject:object];
			if (!priorUUID || ![uuid isEqual:priorUUID]) {
				objc_setAssociatedObject(object, [self uuidKey], uuid, OBJC_ASSOCIATION_RETAIN);
			}
			return priorUUID;
		} else {
			objc_setAssociatedObject(object, [self uuidKey], nil, OBJC_ASSOCIATION_ASSIGN);
		}
		return nil;
	}
}

- (NSUInteger)simpleCountForObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		return 0;
	}
	NSNumber *countNumber = nil;
	
	@synchronized (registryTable) {
		countNumber = objc_getAssociatedObject(object, [self objectCountKey]);
	}
	return countNumber.unsignedIntegerValue;
}


- (void)setSimpleCount:(NSUInteger)count forObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		return;
	}
	@synchronized (registryTable) {
		if (count) {
			objc_setAssociatedObject(object, [self objectCountKey], [NSNumber numberWithUnsignedInteger:count], OBJC_ASSOCIATION_RETAIN);
		} else {
			objc_setAssociatedObject(object, [self objectCountKey], nil, OBJC_ASSOCIATION_ASSIGN);
		}
	}
}



- (NSString *)registryUUIDForObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object || (self.requireRegistryProtocol && ![object conformsToProtocol:@protocol(BERegistryProtocol)])) {
		return nil;
	}
	NSString *instanceUUID = nil;
	
	@synchronized (registryTable) {
		instanceUUID = [self simpleRegistryUUIDForObject:object];
		if (!instanceUUID) {
			instanceUUID = [[NSUUID UUID] UUIDString];
			[self setSimpleRegistryUUID:instanceUUID forObject:object];
		}
	}
	return instanceUUID;
}

- (void)setRegistryUUID:(NSString *)uuid forObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object || (self.requireRegistryProtocol && ![object conformsToProtocol:@protocol(BERegistryProtocol)])) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: object does not conform to BERegistryProtocol",
		 NSMutableDictionary.className, NSStringFromSelector(_cmd)];
	}
	if (uuid && ![uuid isKindOfClass:NSString.class]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: uuid is not a NSString nor nil",
		 NSMutableDictionary.className, NSStringFromSelector(_cmd)];
	}
	NSString *priorUUID = [self setSimpleRegistryUUID:uuid forObject:object];
	if (priorUUID) {
		@synchronized (registryTable) {
			if ([registryTable objectForKey:priorUUID]) {
				[registryTable removeObjectForKey:priorUUID];
				if (uuid) {
					[registryTable setObject:object forKey:uuid];
				}
			}
		}
	}
}


- (NSUInteger)countForObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		return 0;
	}
	@synchronized ([self saltLock]) {
		return [self simpleCountForObject:object];
	}
}

- (NSUInteger)registeredCountForObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		return 0;
	}
	@synchronized (registryTable) {
		return [objectCounter countForObject:CounterObjectKey(object)];
	}
}

- (NSString *)registerObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: object is nil",
		 NSMutableDictionary.className, NSStringFromSelector(_cmd)];
	} else if(self.requireRegistryProtocol && ![object conformsToProtocol:@protocol(BERegistryProtocol)]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: object does not conform to BERegistryProtocol",
		 NSMutableDictionary.className, NSStringFromSelector(_cmd)];
	}
	
	NSString *uuid;
	
	@synchronized (registryTable) {
		// Check if already has a UUID
		uuid = [self registryUUIDForObject:object];
		
		NSObject *instance = [registryTable objectForKey:uuid];
		if (instance && instance != object) {
			[NSException raise:NSDuplicateUUIDException
						format:@"*** -[%@ %@]: uuid '%@' is already used for '%@' at %p but trying to set it to '%@' at %p",
			 self.className, NSStringFromSelector(_cmd), uuid, instance.className, instance, ((NSObject*)object).className, object];
		} else if (!instance) {
			[registryTable setObject:object forKey:uuid];
		}
		
		[objectCounter addObject:CounterObjectKey(object)];
		@synchronized([self saltLock]) {
			[self setSimpleCount:[self simpleCountForObject:object] + 1 forObject:object];
		}
	}
	
	return uuid;
}


- (BOOL)isObjectRegistered:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		return NO;
	}
	@synchronized (registryTable) {
		return [objectCounter countForObject:CounterObjectKey(object)] > 0;
	}
}

- (id)registeredObjectForUUID:(NSString *)uuid
{
	if (!uuid || ![uuid isKindOfClass:NSString.class]) {
		return nil;
	}
	
	id object;
	
	@synchronized(registryTable) {
		object = [registryTable objectForKey:uuid];
	}
	return object;
}

- (NSDictionary *)allRegisteredObjects
{
	return [registryTable dictionaryRepresentation];
	/*
	NSMutableDictionary *instances = [NSMutableDictionary dictionary];
	
	@synchronized(registryTable) {
		
		// Get all key-value pairs from the map table
		NSEnumerator *keyEnumerator = [registryTable keyEnumerator];
		NSString *key;
		while ((key = [keyEnumerator nextObject])) {
			id instance = [registryTable objectForKey:key];
			if (instance) { // Make sure weak reference is still valid
				instances[key] = instance;
			}
		}
	}
	return [instances copy];*/
	
}

- (NSArray *)allRegisteredObjectUUIDs
{
	NSMutableArray *uuids = [NSMutableArray array];
	
	@synchronized(registryTable) {
		NSEnumerator *keyEnumerator = [registryTable keyEnumerator];
		NSString *key;
		while ((key = [keyEnumerator nextObject])) {
			[uuids addObject:key];
		}
	}
	return [uuids copy];
}



- (int)unregisterObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		return 0;
	}
	@synchronized(registryTable) {
		NSUInteger count = [objectCounter countForObject:CounterObjectKey(object)];
		if (count) {
			[objectCounter removeObject:CounterObjectKey(object)];
			@synchronized([self saltLock]) {
				[self setSimpleCount:[self simpleCountForObject:object] - 1 forObject:object];
			}
			if (count <= 1) {
				if ([self clearObject:object]) {
					return 2;
				}
			}
			return 1;
		}
		return 0;
	}
}

- (int)unregisterObjectByUUID:(NSString *)uuid
{
	if (!uuid || ![uuid isKindOfClass:NSString.class]) {
		return 0;
	}
	
	@synchronized(registryTable) {
		id object = [registryTable objectForKey:uuid];
		if (!object) {
			return 0;
		}
		NSUInteger count = [objectCounter countForObject:CounterObjectKey(object)];
		if (count) {
			[objectCounter removeObject:CounterObjectKey(object)];
			@synchronized([self saltLock]) {
				[self setSimpleCount:[self simpleCountForObject:object] - 1 forObject:object];
			}
			if (count <= 1) {
				if ([self clearObject:object]) {
					return 2;
				}
			}
		}
		return 1;
	}
}

- (void)clearObjectsWithoutRegistryProtocol
{
	[self clearObjectsWithoutRegistryProtocol:NO];
}

- (void)clearObjectsWithoutRegistryProtocol:(BOOL)clearObjectUUIDs
{
	@synchronized(registryTable) {
		// Clear UUIDs from all instances before removing from registry
		NSEnumerator *enumerator = [[self allRegisteredObjectUUIDs] objectEnumerator];
		NSString *uuid;
		while (uuid = [enumerator nextObject]) {
			id object = [registryTable objectForKey:uuid];
			if (![object conformsToProtocol:@protocol(BERegistryProtocol)]) {
				[self clearObjectByUUID:uuid];
				if (clearObjectUUIDs && [self countForObject:object] <= 0) {
					[self setSimpleRegistryUUID:nil forObject:object];
				}
			}
		}
	}
}

- (BOOL)clearObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		return NO;
	}
	
	return [self clearObjectByUUID:[self simpleRegistryUUIDForObject:object]];
}

- (BOOL)clearObjectByUUID:(NSString *)uuid
{
	if (!uuid || ![uuid isKindOfClass:NSString.class]) {
		return NO;
	}
	
	@synchronized(registryTable) {
		id object = [registryTable objectForKey:uuid];
		if (!object) {
			return NO;
		}
		[registryTable removeObjectForKey:uuid];
		
		id countKey = CounterObjectKey(object);
		NSUInteger count = [objectCounter countForObject:countKey];
		@synchronized([self saltLock]) {
			[self setSimpleCount:[self simpleCountForObject:object] - count forObject:object];
		}
		while (count-- > 0) {
			[objectCounter removeObject:countKey];
		}
		return YES;
	}
}



- (void)clearAllRegisteredObjects
{
	[self clearAllRegisteredObjects:NO];
}

- (void)clearAllRegisteredObjects:(BOOL)clearObjectUUIDs
{
	@synchronized(registryTable) {
		NSEnumerator *enumerator = [registryTable objectEnumerator];
		id object;
		while ((object = [enumerator nextObject])) {
			id countKey = CounterObjectKey(object);
			NSUInteger count = [objectCounter countForObject:countKey];
			
			@synchronized([self saltLock]) {
				[self setSimpleCount:[self simpleCountForObject:object] - count forObject:object];
			}
			while (count-- > 0) {
				[objectCounter removeObject:countKey];
			}
			if (clearObjectUUIDs && [self countForObject:object] <= 0) {
				// Clear UUID before removing from registry
				[self setSimpleRegistryUUID:nil forObject:object];
			}
		}
		[registryTable removeAllObjects];
	}
}

@end



@implementation BEUniversalObjectRegistry

- (instancetype)init
{
	self = [super init];
	if (self) {
		_requireRegistryProtocol = NO;
	}
	return self;
}

@end



@implementation BEStorageObjectRegistry

+ (NSPointerFunctionsOptions)valueOptions
{
	return NSPointerFunctionsStrongMemory;
}

@end
