/*!
 @file			BEObjectRegistry.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
#import "BEObjectRegistry.h"

NSExceptionName	const  NSDuplicateUUIDException = @"NSDuplicateUUIDException";


static NSMutableDictionary *gSaltLocks;

@implementation BEObjectRegistry
{
	// The shared lock for this registry's salt, resolved once at init. Caching it keeps the
	// global gSaltLocks lock off the hot path and guarantees a non-nil lock (a nil lock would
	// turn @synchronized([self saltLock]) into a silent no-op).
	id _saltLock;
}

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

		static dispatch_once_t once;
		dispatch_once(&once, ^{
			gSaltLocks = NSMutableDictionary.new;
			gSaltLocks[@0] = NSObject.new;
		});
		@synchronized(gSaltLocks) {
			_saltLock = gSaltLocks[@0];
		}
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
			_saltLock = gSaltLocks[saltLockKey];
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
	// Resolved once at init and never changes (gSaltLocks entries are never removed).
	return _saltLock;
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
				 NSStringFromClass(self.class), NSStringFromSelector(_cmd), uuid, NSStringFromClass(((NSObject*)instance).class), instance, NSStringFromClass(((NSObject*)object).class), object];
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

// Per-registry-instance registration count. Keyed by the registry itself and stored as an
// associated object on the registered object, so it is released automatically when that object
// deallocates — leaving no stale pointer-keyed entry (no slow leak, and no pointer-reuse where a
// new object at a freed address would inherit a prior count). Callers hold @synchronized(registryTable).
- (NSUInteger)instanceCountForObject:(id<NSObject>)object
{
	NSNumber *count = objc_getAssociatedObject(object, (__bridge void *)self);
	return count.unsignedIntegerValue;
}

- (void)setInstanceCount:(NSUInteger)count forObject:(id<NSObject>)object
{
	objc_setAssociatedObject(object, (__bridge void *)self, count ? @(count) : nil, OBJC_ASSOCIATION_RETAIN);
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
		 NSStringFromClass(self.class), NSStringFromSelector(_cmd)];
	}
	if (uuid && ![uuid isKindOfClass:NSString.class]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: uuid is not a NSString nor nil",
		 NSStringFromClass(self.class), NSStringFromSelector(_cmd)];
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
	// registerObject:/unregisterObject:/clear* all take registryTable before saltLock; acquire
	// them in the same order here, otherwise saltLock-then-registryTable risks an AB-BA deadlock.
	@synchronized (registryTable) {
		@synchronized ([self saltLock]) {
			return [self simpleCountForObject:object];
		}
	}
}

- (NSUInteger)registeredCountForObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		return 0;
	}
	@synchronized (registryTable) {
		return [self instanceCountForObject:object];
	}
}

- (NSString *)registerObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: object is nil",
		 NSStringFromClass(self.class), NSStringFromSelector(_cmd)];
	} else if(self.requireRegistryProtocol && ![object conformsToProtocol:@protocol(BERegistryProtocol)]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: object does not conform to BERegistryProtocol",
		 NSStringFromClass(self.class), NSStringFromSelector(_cmd)];
	}
	
	NSString *uuid;
	
	@synchronized (registryTable) {
		// Check if already has a UUID
		uuid = [self registryUUIDForObject:object];
		
		NSObject *instance = [registryTable objectForKey:uuid];
		if (instance && instance != object) {
			[NSException raise:NSDuplicateUUIDException
						format:@"*** -[%@ %@]: uuid '%@' is already used for '%@' at %p but trying to set it to '%@' at %p",
			 NSStringFromClass(self.class), NSStringFromSelector(_cmd), uuid, NSStringFromClass(instance.class), instance, NSStringFromClass(((NSObject*)object).class), object];
		} else if (!instance) {
			[registryTable setObject:object forKey:uuid];
		}

		[self setInstanceCount:[self instanceCountForObject:object] + 1 forObject:object];
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
		return [self instanceCountForObject:object] > 0;
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
	@synchronized(registryTable) {
		return [registryTable dictionaryRepresentation];
	}
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



- (BEUnregisterStatus)unregisterObject:(id<BERegistryProtocol, NSObject>)object
{
	if (!object) {
		return BEUnregisterStatus_NotRegistered;
	}
	@synchronized(registryTable) {
		NSUInteger count = [self instanceCountForObject:object];
		if (count) {
			[self setInstanceCount:count - 1 forObject:object];
			@synchronized([self saltLock]) {
				[self setSimpleCount:[self simpleCountForObject:object] - 1 forObject:object];
			}
			if (count <= 1) {
				if ([self clearObject:object]) {
					return BEUnregisterStatus_Unregistered; // BEUnregisterStatus_DecrementedBit | BEUnregisterStatus_UnregisteredBit; set bit 1 and bit 0
				}
			}
			return BEUnregisterStatus_Decremented;
		}
		return BEUnregisterStatus_NotRegistered;
	}
}

- (BEUnregisterStatus)unregisterObjectByUUID:(NSString *)uuid
{
	if (!uuid || ![uuid isKindOfClass:NSString.class]) {
		return BEUnregisterStatus_NotRegistered;
	}

	@synchronized(registryTable) {
		id object = [registryTable objectForKey:uuid];
		if (!object) {
			return BEUnregisterStatus_NotRegistered;
		}
		// Delegate so both unregister paths return identical BEUnregisterStatus codes.
		return [self unregisterObject:object];
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

		NSUInteger count = [self instanceCountForObject:object];
		@synchronized([self saltLock]) {
			[self setSimpleCount:[self simpleCountForObject:object] - count forObject:object];
		}
		[self setInstanceCount:0 forObject:object];
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
			NSUInteger count = [self instanceCountForObject:object];

			@synchronized([self saltLock]) {
				[self setSimpleCount:[self simpleCountForObject:object] - count forObject:object];
			}
			[self setInstanceCount:0 forObject:object];
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
