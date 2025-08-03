/*!
 @file			BEPredicateRule.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/

#import <CommonCrypto/CommonDigest.h>
#import "BEPriorityExtensions.h"
#import "BEPredicateRule.h"

NSInteger	const  BEPredicateRuleDefaultPriority = 0;


@implementation BEPredicateRule
{
	NSNumber *_itemPriority;
}
@synthesize outcome = _outcome;
@synthesize predicate = _predicate;
@synthesize isUniqueItemPriority = _isUniqueItemPriority;



- (NSNumber *)defaultItemPriority
{
	return @(BEPredicateRuleDefaultPriority);
}


- (NSNumber *)itemPriority
{
	return _itemPriority ? _itemPriority : self.defaultItemPriority;
}


- (void)setItemPriority:(NSNumber *)priority
{
	if (!priority || [priority isKindOfClass:NSNumber.class])
		_itemPriority = priority;
}


- (NSInteger)itemPriorityInteger
{
	return _itemPriority ? _itemPriority.integerValue : BEPredicateRuleDefaultPriority;
}


- (void)setItemPriorityInteger:(NSInteger)priority
{
	_itemPriority = [NSNumber numberWithInteger:priority];
}


- (double)itemPriorityDouble
{
	return _itemPriority ? _itemPriority.doubleValue : (double)BEPredicateRuleDefaultPriority;
}


- (void)setItemPriorityDouble:(double)priority
{
	_itemPriority = [NSNumber numberWithDouble:priority];
}



+ (nonnull BEPredicateRule *)ruleWithFormat:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:predicateFormat arguments:args];
	va_end(args);
	return rule;
}
+ (nonnull BEPredicateRule *)ruleWithOutcome:(BEPredicateRuleOutcome)outcome format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:predicateFormat arguments:args outcome:outcome];
	va_end(args);
	return rule;
}
+ (nonnull BEPredicateRule *)ruleWithPriority:(NSNumber * _Nonnull)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:predicateFormat arguments:args priority:priority];
	va_end(args);
	return rule;
}

+ (nonnull BEPredicateRule *)ruleWithPriorityInteger:(NSInteger)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:predicateFormat arguments:args priorityInteger:priority];
	va_end(args);
	return rule;
}
+ (nonnull BEPredicateRule *)ruleWithPriorityDouble:(double)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:predicateFormat arguments:args priorityDouble:priority];
	va_end(args);
	return rule;
}

+ (nonnull BEPredicateRule *)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:predicateFormat arguments:args outcome:outcome priority:priority];
	va_end(args);
	return rule;
}
+ (nonnull BEPredicateRule *)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:predicateFormat arguments:args outcome:outcome priorityInteger:priority];
	va_end(args);
	return rule;
}
+ (nonnull BEPredicateRule *)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:predicateFormat arguments:args outcome:outcome priorityDouble:priority];
	va_end(args);
	return rule;
}



+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
	return [[BEPredicateRule alloc] initWithPredicate:predicate];
}
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
	return [[BEPredicateRule alloc] initWithPredicate:predicate outcome:outcome];
}

+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
	return [[BEPredicateRule alloc] initWithPredicate:predicate priority:priority];
}
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priorityInteger:(NSInteger)priority
{
	return [BEPredicateRule ruleWithFormat:predicateFormat argumentArray:arguments priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priorityDouble:(double)priority
{
	return [BEPredicateRule ruleWithFormat:predicateFormat argumentArray:arguments priority:[NSNumber numberWithDouble:priority]];
}

+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
	return [[BEPredicateRule alloc] initWithPredicate:predicate outcome:outcome priority:priority];
}
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority
{
	return [BEPredicateRule ruleWithFormat:predicateFormat argumentArray:arguments outcome:outcome priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority
{
	return [BEPredicateRule ruleWithFormat:predicateFormat argumentArray:arguments outcome:outcome priority:[NSNumber numberWithDouble:priority]];
}



+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:argList];
	return [[BEPredicateRule alloc] initWithPredicate:predicate];
}
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:argList];
	return [[BEPredicateRule alloc] initWithPredicate:predicate outcome:outcome];
}

+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:argList];
	return [[BEPredicateRule alloc] initWithPredicate:predicate priority:priority];
}
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priorityInteger:(NSInteger)priority
{
	return [BEPredicateRule ruleWithFormat:predicateFormat arguments:argList priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priorityDouble:(double)priority
{
	return [BEPredicateRule ruleWithFormat:predicateFormat arguments:argList priority:[NSNumber numberWithDouble:priority]];
}

+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:argList];
	return [[BEPredicateRule alloc] initWithPredicate:predicate outcome:outcome priority:priority];
}
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority
{
	return [BEPredicateRule ruleWithFormat:predicateFormat arguments:argList outcome:outcome priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority
{
	return [BEPredicateRule ruleWithFormat:predicateFormat arguments:argList outcome:outcome priority:[NSNumber numberWithDouble:priority]];
}



+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value
{
	NSPredicate *predicate = [NSPredicate predicateWithValue:value];
	return [[BEPredicateRule alloc] initWithPredicate:predicate];
}
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome
{
	NSPredicate *predicate = [NSPredicate predicateWithValue:value];
	return [[BEPredicateRule alloc] initWithPredicate:predicate outcome:outcome];
}

+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithValue:value];
	return [[BEPredicateRule alloc] initWithPredicate:predicate priority:priority];
}
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value priorityInteger:(NSInteger)priority
{
	return [BEPredicateRule ruleWithValue:value priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value priorityDouble:(double)priority
{
	return [BEPredicateRule ruleWithValue:value priority:[NSNumber numberWithDouble:priority]];
}

+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithValue:value];
	return [[BEPredicateRule alloc] initWithPredicate:predicate outcome:outcome priority:priority];
}
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority
{
	return [BEPredicateRule ruleWithValue:value outcome:outcome priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority
{
	return [BEPredicateRule ruleWithValue:value outcome:outcome priority:[NSNumber numberWithDouble:priority]];
}



+ (nonnull BEPredicateRule*)ruleWithBlock:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
	return [[BEPredicateRule alloc] initWithPredicate:predicate];
}
+ (nonnull BEPredicateRule*)ruleWithOutcome:(BEPredicateRuleOutcome)outcome block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
	return [[BEPredicateRule alloc] initWithPredicate:predicate outcome:outcome];
}

+ (nonnull BEPredicateRule*)ruleWithPriority:(NSNumber *)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
	return [[BEPredicateRule alloc] initWithPredicate:predicate priority:priority];
}
+ (nonnull BEPredicateRule *)ruleWithPriorityInteger:(NSInteger)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	return [BEPredicateRule ruleWithPriority:[NSNumber numberWithInteger:priority] block:block];
}
+ (nonnull BEPredicateRule *)ruleWithPriorityDouble:(double)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	return [BEPredicateRule ruleWithPriority:[NSNumber numberWithDouble:priority] block:block];
}

+ (nonnull BEPredicateRule*)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber *)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
	return [[BEPredicateRule alloc] initWithPredicate:predicate outcome:outcome priority:priority];
}
+ (nonnull BEPredicateRule *)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	return [BEPredicateRule ruleWithOutcome:outcome priority:[NSNumber numberWithInteger:priority] block:block];
}
+ (nonnull BEPredicateRule *)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	return [BEPredicateRule ruleWithOutcome:outcome priority:[NSNumber numberWithDouble:priority] block:block];
}



- (nullable instancetype)init
{
	self = [super init];
	if (self) {
		if (!_predicate) {
			_predicate = [NSPredicate predicateWithValue:NO];
		}
	}
	return self;
}

- (nullable instancetype)initWithPredicate:(NSPredicate *)predicate
{
	self = [super init];
	if (self) {
		if (!_predicate) {
			_predicate = predicate;
		}
	}
	return self;
}

- (nullable instancetype)initWithPredicate:(NSPredicate *)predicate outcome:(BEPredicateRuleOutcome)outcome
{
	self = [super init];
	if (self) {
		if (!_predicate) {
			_predicate = predicate;
			_outcome = outcome;
		}
	}
	return self;
}

- (nullable instancetype)initWithPredicate:(NSPredicate *)predicate priority:(NSNumber *)priority
{
	self = [super init];
	if (self) {
		if (!_predicate) {
			_predicate = predicate;
			_itemPriority = priority;
		}
	}
	return self;
}

- (nullable instancetype)initWithPredicate:(NSPredicate *)predicate priorityInteger:(NSInteger)priority
{
	return [self initWithPredicate:predicate priority:[NSNumber numberWithInteger:priority]];
}

- (nullable instancetype)initWithPredicate:(NSPredicate *)predicate priorityDouble:(double)priority
{
	return [self initWithPredicate:predicate priority:[NSNumber numberWithDouble:priority]];
}

- (nullable instancetype)initWithPredicate:(NSPredicate *)predicate outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber *)priority
{
	self = [super init];
	if (self) {
		if (!_predicate) {
			_predicate = predicate;
			_itemPriority = priority;
			_outcome = outcome;
		}
	}
	return self;
}

- (nullable instancetype)initWithPredicate:(NSPredicate *)predicate outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority
{
	return [self initWithPredicate:predicate outcome:outcome priority:[NSNumber numberWithInteger:priority]];
}

- (nullable instancetype)initWithPredicate:(NSPredicate *)predicate outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority
{
	return [self initWithPredicate:predicate outcome:outcome priority:[NSNumber numberWithDouble:priority]];
}

+ (BOOL)supportsSecureCoding
{
	return YES;
}

- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder
{
	self = [super init];
	if (self) {
		_predicate = [coder decodeObjectOfClass:NSPredicate.class forKey:@"predicate"];
		_outcome = [coder decodeIntegerForKey:@"outcome"];
		if(![coder decodeBoolForKey:@"defaultItemPriority"]) {
			_itemPriority = [coder decodeObjectOfClass:NSNumber.class forKey:@"priority"];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder * _Nonnull)coder
{
	[coder encodeObject:_predicate forKey:@"predicate"];
	[coder encodeInteger:_outcome forKey:@"outcome"];
	[coder encodeBool:!_itemPriority forKey:@"defaultItemPriority"];
	if (_itemPriority) {
		[coder encodeObject:_itemPriority forKey:@"priority"];
	}
}

- (id)copyWithZone:(nullable NSZone *)zone
{
	return [[BEPredicateRule allocWithZone:zone] initWithPredicate:self.predicate outcome:self.outcome priority:self.itemPriority];
}

- (NSString *)predicateFormat
{
	return _predicate.predicateFormat;
}

- (NSUInteger)hash
{
	const NSInteger BEPredicateRuleSalt = (sizeof(NSInteger) >= 8) ? 0x388e4b6d1b5d9071 : 0x1b5d9071;
	
	// Convert integer to string
	NSString *valueString = [NSString stringWithFormat:@"%d", (int)_outcome];
	const char *cStr = [valueString UTF8String];
	
	// Compute SHA1 hash
	unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(cStr, (CC_LONG)strlen(cStr), digest);
	
	// Use first sizeof(NSUInteger) bytes of digest to create hash
	NSUInteger result = 0;
	memcpy(&result, digest, sizeof(NSUInteger));
	
	if (_isUniqueItemPriority) {
		valueString = [NSString stringWithFormat:@"%@", _itemPriority];
		 const char *cStr2 = [valueString UTF8String];
		 
		 // Compute SHA1 hash
		 CC_SHA1(cStr2, (CC_LONG)strlen(cStr2), digest);
		 
		 // Use first sizeof(NSUInteger) bytes of digest to create hash
		 NSUInteger result2 = 0;
		 memcpy(&result2, digest, sizeof(NSUInteger));
		result ^= result2;
	}
	
	return [_predicate hash] ^ result ^ BEPredicateRuleSalt;
}

- (void)substitutePredicateVariables:(NSDictionary<NSString *, id> * _Nullable)variables     // substitute constant values for variables
{
	_predicate = [_predicate predicateWithSubstitutionVariables:variables];
}

- (nonnull instancetype)ruleWithSubstitutionVariables:(NSDictionary<NSString *, id> * _Nullable)variables
{
	BEPredicateRule *rule = [self copy];
	
	[rule substitutePredicateVariables:variables];
	
	return rule;
}


- (BOOL)isEqual:(id)object
{
	if (self == object) {
		return YES;
	}
	
	if (![object isKindOfClass:BEPredicateRule.class]) {
		return NO;
	}
	BEPredicateRule *rule = (BEPredicateRule *)object;
	BOOL samePriority = YES;
	
	if (_isUniqueItemPriority || rule.isUniqueItemPriority) {
		samePriority = ([self.itemPriority compare:rule.itemPriority] == NSOrderedSame);
	}
	
	return samePriority && self.outcome == rule.outcome && [self.predicate isEqual:rule.predicate];
}


- (BOOL)evaluateWithObject:(nullable id)object
{
	return [self.predicate evaluateWithObject:object];
}


- (BOOL)evaluateWithObject:(nullable id)object substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings
{
	return [self.predicate evaluateWithObject:object substitutionVariables:bindings];
}


- (void)allowEvaluation
{
	[self.predicate allowEvaluation];
}

@end



@implementation NSArray (BEPredicateRuleSupport)

- (BEPredicateRuleOutcome)ruleOutcomeWithObject: (id)object
{
	return [self ruleOutcomeWithObject:object substitutionVariables:NULL];
}

- (BEPredicateRuleOutcome)ruleOutcomeWithObject: (id)object
							   substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings
{
	for (BEPredicateRule *predicate in self.sortedArrayUsingItemPriority) {
		if (![predicate isKindOfClass:BEPredicateRule.class]) {
			continue;
		}
		if (![predicate evaluateWithObject:object substitutionVariables:bindings]) {
			continue;
		}
		if (predicate.outcome) {
			return predicate.outcome;
		}
	}
	return BEPredicateRuleNA;
}

@end



@implementation NSSet (BEPredicateRuleSupport)

- (BEPredicateRuleOutcome)ruleOutcomeWithObject: (id)object
{
	return [self ruleOutcomeWithObject:object substitutionVariables:NULL];
}

- (BEPredicateRuleOutcome)ruleOutcomeWithObject: (id)object
							   substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings
{
	for (BEPredicateRule *predicate in self.allObjects.sortedArrayUsingItemPriority) {
		if (![predicate isKindOfClass:BEPredicateRule.class]) {
			continue;
		}
		if (![predicate evaluateWithObject:object substitutionVariables:bindings]) {
			continue;
		}
		if (predicate.outcome) {
			return predicate.outcome;
		}
	}
	return BEPredicateRuleNA;
}

@end



@implementation NSOrderedSet (BEPredicateRuleSupport)

- (BEPredicateRuleOutcome)ruleOutcomeWithObject: (id)object
{
	return [self ruleOutcomeWithObject:object substitutionVariables:NULL];
}

- (BEPredicateRuleOutcome)ruleOutcomeWithObject: (id)object
							   substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings
{	
	for (BEPredicateRule *predicate in self.sortedArrayUsingItemPriority) {
		if (![predicate isKindOfClass:BEPredicateRule.class]) {
			continue;
		}
		if (![predicate evaluateWithObject:object substitutionVariables:bindings]) {
			continue;
		}
		if (predicate.outcome) {
			return predicate.outcome;
		}
	}
	return BEPredicateRuleNA;
}

@end
