/*!
 @file			BEPredicateRule.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Implements BEPredicateRule and the BEPredicateRuleSupport collection categories.
 @discussion	BEPredicateRule wraps an NSPredicate with an outcome, a sortable priority, and
				NSSecureCoding/NSCopying support. The NSArray, NSSet, and NSOrderedSet categories
				evaluate rules in ascending priority order via ruleOutcomeWithObject: and return
				the outcome of the first matching non-N/A rule.
*/

#import <CommonCrypto/CommonDigest.h>
#import "BEPriorityExtensions.h"
#import "BEPredicateRule.h"

NSInteger	const  BEPredicateRuleDefaultPriority = 0;


static void BEPredicateRuleRequirePredicate(NSPredicate *predicate, Class cls, SEL cmd)
{
	if (predicate == nil) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: predicate is nil", NSStringFromClass(cls), NSStringFromSelector(cmd)];
	}
}


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
	return _itemPriority != nil ? _itemPriority : self.defaultItemPriority;
}


- (void)setItemPriority:(NSNumber *)priority
{
	if (priority == nil || [priority isKindOfClass:NSNumber.class])
		_itemPriority = priority;
}


- (NSInteger)itemPriorityInteger
{
	return _itemPriority != nil ? _itemPriority.integerValue : BEPredicateRuleDefaultPriority;
}


- (void)setItemPriorityInteger:(NSInteger)priority
{
	_itemPriority = [NSNumber numberWithInteger:priority];
}


- (double)itemPriorityDouble
{
	return _itemPriority != nil ? _itemPriority.doubleValue : (double)BEPredicateRuleDefaultPriority;
}


- (void)setItemPriorityDouble:(double)priority
{
	_itemPriority = [NSNumber numberWithDouble:priority];
}



+ (nonnull instancetype)ruleWithFormat:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [self ruleWithFormat:predicateFormat arguments:args];
	va_end(args);
	return rule;
}
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [self ruleWithFormat:predicateFormat arguments:args outcome:outcome];
	va_end(args);
	return rule;
}
+ (nonnull instancetype)ruleWithPriority:(NSNumber * _Nonnull)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [self ruleWithFormat:predicateFormat arguments:args priority:priority];
	va_end(args);
	return rule;
}

+ (nonnull instancetype)ruleWithPriorityInteger:(NSInteger)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [self ruleWithFormat:predicateFormat arguments:args priorityInteger:priority];
	va_end(args);
	return rule;
}
+ (nonnull instancetype)ruleWithPriorityDouble:(double)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [self ruleWithFormat:predicateFormat arguments:args priorityDouble:priority];
	va_end(args);
	return rule;
}

+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [self ruleWithFormat:predicateFormat arguments:args outcome:outcome priority:priority];
	va_end(args);
	return rule;
}
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [self ruleWithFormat:predicateFormat arguments:args outcome:outcome priorityInteger:priority];
	va_end(args);
	return rule;
}
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority format:(NSString * _Nonnull)predicateFormat, ...
{
	va_list args;
	va_start(args, predicateFormat);
	BEPredicateRule *rule = [self ruleWithFormat:predicateFormat arguments:args outcome:outcome priorityDouble:priority];
	va_end(args);
	return rule;
}



+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
	return [[self alloc] initWithPredicate:predicate];
}
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
	return [[self alloc] initWithPredicate:predicate outcome:outcome];
}

+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
	return [[self alloc] initWithPredicate:predicate priority:priority];
}
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priorityInteger:(NSInteger)priority
{
	return [self ruleWithFormat:predicateFormat argumentArray:arguments priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priorityDouble:(double)priority
{
	return [self ruleWithFormat:predicateFormat argumentArray:arguments priority:[NSNumber numberWithDouble:priority]];
}

+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
	return [[self alloc] initWithPredicate:predicate outcome:outcome priority:priority];
}
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority
{
	return [self ruleWithFormat:predicateFormat argumentArray:arguments outcome:outcome priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority
{
	return [self ruleWithFormat:predicateFormat argumentArray:arguments outcome:outcome priority:[NSNumber numberWithDouble:priority]];
}



+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:argList];
	return [[self alloc] initWithPredicate:predicate];
}
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:argList];
	return [[self alloc] initWithPredicate:predicate outcome:outcome];
}

+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:argList];
	return [[self alloc] initWithPredicate:predicate priority:priority];
}
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priorityInteger:(NSInteger)priority
{
	return [self ruleWithFormat:predicateFormat arguments:argList priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priorityDouble:(double)priority
{
	return [self ruleWithFormat:predicateFormat arguments:argList priority:[NSNumber numberWithDouble:priority]];
}

+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:argList];
	return [[self alloc] initWithPredicate:predicate outcome:outcome priority:priority];
}
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority
{
	return [self ruleWithFormat:predicateFormat arguments:argList outcome:outcome priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority
{
	return [self ruleWithFormat:predicateFormat arguments:argList outcome:outcome priority:[NSNumber numberWithDouble:priority]];
}



+ (nonnull instancetype)ruleWithValue:(BOOL)value
{
	NSPredicate *predicate = [NSPredicate predicateWithValue:value];
	return [[self alloc] initWithPredicate:predicate];
}
+ (nonnull instancetype)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome
{
	NSPredicate *predicate = [NSPredicate predicateWithValue:value];
	return [[self alloc] initWithPredicate:predicate outcome:outcome];
}

+ (nonnull instancetype)ruleWithValue:(BOOL)value priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithValue:value];
	return [[self alloc] initWithPredicate:predicate priority:priority];
}
+ (nonnull instancetype)ruleWithValue:(BOOL)value priorityInteger:(NSInteger)priority
{
	return [self ruleWithValue:value priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull instancetype)ruleWithValue:(BOOL)value priorityDouble:(double)priority
{
	return [self ruleWithValue:value priority:[NSNumber numberWithDouble:priority]];
}

+ (nonnull instancetype)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber *)priority
{
	NSPredicate *predicate = [NSPredicate predicateWithValue:value];
	return [[self alloc] initWithPredicate:predicate outcome:outcome priority:priority];
}
+ (nonnull instancetype)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority
{
	return [self ruleWithValue:value outcome:outcome priority:[NSNumber numberWithInteger:priority]];
}
+ (nonnull instancetype)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority
{
	return [self ruleWithValue:value outcome:outcome priority:[NSNumber numberWithDouble:priority]];
}



+ (nonnull instancetype)ruleWithBlock:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
	return [[self alloc] initWithPredicate:predicate];
}
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
	return [[self alloc] initWithPredicate:predicate outcome:outcome];
}

+ (nonnull instancetype)ruleWithPriority:(NSNumber *)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
	return [[self alloc] initWithPredicate:predicate priority:priority];
}
+ (nonnull instancetype)ruleWithPriorityInteger:(NSInteger)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	return [self ruleWithPriority:[NSNumber numberWithInteger:priority] block:block];
}
+ (nonnull instancetype)ruleWithPriorityDouble:(double)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	return [self ruleWithPriority:[NSNumber numberWithDouble:priority] block:block];
}

+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber *)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
	return [[self alloc] initWithPredicate:predicate outcome:outcome priority:priority];
}
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	return [self ruleWithOutcome:outcome priority:[NSNumber numberWithInteger:priority] block:block];
}
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block
{
	return [self ruleWithOutcome:outcome priority:[NSNumber numberWithDouble:priority] block:block];
}



- (instancetype)init
{
	self = [super init];
	if (self) {
		if (!_predicate) {
			_predicate = [NSPredicate predicateWithValue:NO];
		}
	}
	return self;
}

- (nonnull instancetype)initWithPredicate:(NSPredicate *)predicate
{
	BEPredicateRuleRequirePredicate(predicate, self.class, _cmd);
	self = [super init];
	if (self) {
		if (!_predicate) {
			_predicate = predicate;
		}
	}
	return self;
}

- (nonnull instancetype)initWithPredicate:(NSPredicate *)predicate outcome:(BEPredicateRuleOutcome)outcome
{
	BEPredicateRuleRequirePredicate(predicate, self.class, _cmd);
	self = [super init];
	if (self) {
		if (!_predicate) {
			_predicate = predicate;
			_outcome = outcome;
		}
	}
	return self;
}

- (nonnull instancetype)initWithPredicate:(NSPredicate *)predicate priority:(NSNumber *)priority
{
	BEPredicateRuleRequirePredicate(predicate, self.class, _cmd);
	self = [super init];
	if (self) {
		if (!_predicate) {
			_predicate = predicate;
			_itemPriority = priority;
		}
	}
	return self;
}

- (nonnull instancetype)initWithPredicate:(NSPredicate *)predicate priorityInteger:(NSInteger)priority
{
	return [self initWithPredicate:predicate priority:[NSNumber numberWithInteger:priority]];
}

- (nonnull instancetype)initWithPredicate:(NSPredicate *)predicate priorityDouble:(double)priority
{
	return [self initWithPredicate:predicate priority:[NSNumber numberWithDouble:priority]];
}

- (nonnull instancetype)initWithPredicate:(NSPredicate *)predicate outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber *)priority
{
	BEPredicateRuleRequirePredicate(predicate, self.class, _cmd);
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

- (nonnull instancetype)initWithPredicate:(NSPredicate *)predicate outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority
{
	return [self initWithPredicate:predicate outcome:outcome priority:[NSNumber numberWithInteger:priority]];
}

- (nonnull instancetype)initWithPredicate:(NSPredicate *)predicate outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority
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
		_isUniqueItemPriority = [coder decodeBoolForKey:@"isUniqueItemPriority"];
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
	[coder encodeBool:_isUniqueItemPriority forKey:@"isUniqueItemPriority"];
	[coder encodeBool:(_itemPriority == nil) forKey:@"defaultItemPriority"];
	if (_itemPriority != nil) {
		[coder encodeObject:_itemPriority forKey:@"priority"];
	}
}

- (id)copyWithZone:(nullable NSZone *)zone
{
	BEPredicateRule *rule = [[self.class allocWithZone:zone] initWithPredicate:self.predicate outcome:self.outcome priority:_itemPriority];
	rule.isUniqueItemPriority = _isUniqueItemPriority;
	return rule;
}

- (NSString *)predicateFormat
{
	return _predicate.predicateFormat;
}

- (NSUInteger)hash
{
	const NSInteger BEPredicateRuleSalt = (sizeof(NSInteger) >= 8) ? 0x388e4b6d1b5d9071 : 0x1b5d9071;

	NSString *valueString = [NSString stringWithFormat:@"%d", (int)_outcome];
	const char *cStr = [valueString UTF8String];

	unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(cStr, (CC_LONG)strlen(cStr), digest);

	NSUInteger result = 0;
	memcpy(&result, digest, sizeof(NSUInteger));

	// Priority is folded in only for isUniqueItemPriority rules. This stays consistent with
	// -isEqual: because -isEqual: requires the isUniqueItemPriority flag itself to match, so two
	// equal rules always agree on whether priority participates in both equality and the hash.
	// Fold the accessor's value, never the raw ivar: -isEqual: compares self.itemPriority (a nil
	// ivar resolves to the default priority), so an unset priority must hash like the default.
	if (_isUniqueItemPriority) {
		valueString = self.itemPriority.stringValue;
		 const char *cStr2 = [valueString UTF8String];

		 CC_SHA1(cStr2, (CC_LONG)strlen(cStr2), digest);

		 NSUInteger result2 = 0;
		 memcpy(&result2, digest, sizeof(NSUInteger));
		result ^= result2;
	}

	return [_predicate hash] ^ result ^ BEPredicateRuleSalt;
}

- (void)substitutePredicateVariables:(NSDictionary<NSString *, id> * _Nullable)variables
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

	// The isUniqueItemPriority flag is itself part of identity. Requiring it to match (rather than
	// the looser "either is unique") keeps -hash consistent: two equal rules always agree on
	// whether priority participates, so the conditional priority term in -hash can never make
	// equal rules hash differently.
	if (_isUniqueItemPriority != rule.isUniqueItemPriority) {
		return NO;
	}
	BOOL samePriority = YES;
	if (_isUniqueItemPriority) {
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
