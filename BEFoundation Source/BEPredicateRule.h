/*!
 @header		BEPredicateRule.h
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract		(This needs to be filled in)
 @discussion	
*/

#ifndef BEPredicateRule_h
#define BEPredicateRule_h

#import <Foundation/Foundation.h>
#import <BEFoundation/BEPriorityExtensions.h>

extern NSInteger	const  BEPredicateRuleDefaultPriority;


/*!
 @typedef		NSPredicateRuleOutcome
 @abstract		This is the result of checking a collection (NSArray, NSSet, NSOrderedSet)
				of NSPredicate or NSPredicateRules.
				If a rule set is not matched `NSPredicateRuleNA` is return.
				If a rule is matched is a rule set, then it's outcome is returned as
				`NSPredicateRuleAccept` (value: 1) or
				`NSPredicateRuleReject` (value: -1)
 */
typedef NSInteger BEPredicateRuleOutcome;
NS_ENUM(BEPredicateRuleOutcome) {
	BEPredicateRuleReject = -1,
	BEPredicateRuleNA = 0,
	BEPredicateRuleAccept = 1,
};





/*!
 @interface		BEPredicateRule
 @abstract		Implements an `outcome`, `defaultPriority`, and
 				`priority` for subclasses.
 */
@interface BEPredicateRule : NSPredicate <NSSecureCoding, NSCopying, BEPriorityItem>

/*!
 @property		outcome
 @result		Returns `NSPredicateRuleOutcome` of the result if the NSPredicate matches.
 */
@property (readonly, nonnull) NSPredicate *predicate;

/*!
 @property		outcome
 @result		Returns `NSPredicateRuleOutcome` of the result if the NSPredicate matches.
 */
@property (readwrite, nonatomic) BEPredicateRuleOutcome outcome;


/*!
 @property		defaultPriority
 @result		When there is no `priority`, `BEPredicateRuleDefaultPriority`
				is the default.
 */
@property (readonly, nonatomic, nonnull) NSNumber *defaultItemPriority;

/*!
 @property		priority
 @abstract		This returns the NSPredicate rule set priorty and if none is set then this returns `defaultPriority`.
 @result		Returns the NSNumber index of the BEPredicateRule in the rule set.
 */
@property (readwrite, nonatomic, nullable) NSNumber *itemPriority;
@property (readwrite, nonatomic) NSInteger itemPriorityInteger;
@property (readwrite, nonatomic) double itemPriorityDouble;

/*!
 @property		isUniqueItemPriority
 @abstract		This is to specify if the itemPriority should be used to determine equality when YES. Default NO.
 @result		Returns BOOL if itemPriority is used to determine class equality.
 @discussion	By default this is NO.   This is useful when using the same rule with different itemPriority in
 				a NSSet or NSOrderedSet.
 */
@property (readwrite) BOOL isUniqueItemPriority;

+ (BOOL)supportsSecureCoding;

+ (nonnull BEPredicateRule *)ruleWithFormat:(NSString * _Nonnull)predicateFormat, ...;
+ (nonnull BEPredicateRule *)ruleWithOutcome:(BEPredicateRuleOutcome)outcome format:(NSString * _Nonnull)predicateFormat, ...;
+ (nonnull BEPredicateRule *)ruleWithPriority:(NSNumber * _Nonnull)priority format:(NSString * _Nonnull)predicateFormat, ...;
+ (nonnull BEPredicateRule *)ruleWithPriorityInteger:(NSInteger)priority format:(NSString * _Nonnull)predicateFormat, ...;
+ (nonnull BEPredicateRule *)ruleWithPriorityDouble:(double)priority format:(NSString * _Nonnull)predicateFormat, ...;
+ (nonnull BEPredicateRule *)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority format:(NSString * _Nonnull)predicateFormat, ...;
+ (nonnull BEPredicateRule *)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority format:(NSString * _Nonnull)predicateFormat, ...;
+ (nonnull BEPredicateRule *)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority format:(NSString * _Nonnull)predicateFormat, ...;

// Parse predicateFormat and return an appropriate predicate
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priority:(NSNumber * _Nonnull)priority;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priorityInteger:(NSInteger)priority;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priorityDouble:(double)priority;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority;

+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priority:(NSNumber * _Nonnull)priority;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priorityInteger:(NSInteger)priority;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priorityDouble:(double)priority;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority;
+ (nonnull BEPredicateRule *)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority;

+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value;    // return predicates that always evaluate to true/false
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome;    // return predicates that always evaluate to true/false
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value priority:(NSNumber * _Nonnull)priority;
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value priorityInteger:(NSInteger)priority;
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value priorityDouble:(double)priority;
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority;
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority;
+ (nonnull BEPredicateRule *)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority;

+ (nonnull BEPredicateRule*)ruleWithBlock:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
+ (nonnull BEPredicateRule*)ruleWithOutcome:(BEPredicateRuleOutcome)outcome block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));;
+ (nonnull BEPredicateRule*)ruleWithPriority:(NSNumber * _Nonnull)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
+ (nonnull BEPredicateRule*)ruleWithPriorityInteger:(NSInteger)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
+ (nonnull BEPredicateRule*)ruleWithPriorityDouble:(double)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
+ (nonnull BEPredicateRule*)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
+ (nonnull BEPredicateRule*)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
+ (nonnull BEPredicateRule*)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

@property (readonly, nonatomic, copy, nonnull) NSString *predicateFormat;    // returns the format string of the predicate

- (nullable instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate;

- (nullable instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate outcome:(BEPredicateRuleOutcome)outcome;

- (nullable instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate priority:(NSNumber * _Nonnull)priority;
- (nullable instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate priorityInteger:(NSInteger)priority;
- (nullable instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate priorityDouble:(double)priority;

- (nullable instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority;
- (nullable instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority;
- (nullable instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority;

- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder; // NS_DESIGNATED_INITIALIZER

- (void)encodeWithCoder:(NSCoder * _Nonnull)coder;

- (void)substitutePredicateVariables:(NSDictionary<NSString *, id> * _Nullable)variables;     // substitute constant values for variables
- (nonnull instancetype)ruleWithSubstitutionVariables:(NSDictionary<NSString *, id> * _Nullable)variables;

- (nonnull id)copyWithZone:(nullable NSZone *)zone;

- (BOOL)evaluateWithObject:(nullable id)object;    // evaluate a predicate against a single object

- (BOOL)evaluateWithObject:(nullable id)object substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings API_AVAILABLE(macos(10.5), ios(3.0), watchos(2.0), tvos(9.0)); // single pass evaluation substituting variables from the bindings dictionary for any variable expressions encountered

- (void)allowEvaluation API_AVAILABLE(macos(10.9), ios(7.0), watchos(2.0), tvos(9.0)); // Force a predicate which was securely decoded to allow evaluation

@end



/*!
 @category		NSPredicateRuleSupport
 @abstract		This implements a Rule set of `BEPredicateRule` where it orders the
				rules, and matches to the first (lowest) priority rule and
				returns the `NSPredicateRuleOutcome` of its outcome.
				If no rule is matched, `NSPredicateRuleNA` is returned.
 */
@interface NSArray (BEPredicateRuleSupport)

/*!
 @method		-predicateOutcomeWithObject
 @abstract		This loops through all the internal NSPredicate and NSPredicateRule
 				in priority order (lowest first) and returns the outcome of the first matching.
 @param		object	The object to test against the predicates.
 @discussion	.
 @result		Returns `NSPredicateRuleOutcome` based on the object matching
 				a rule, it's outcome, and if there is no match.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object;

/*!
 @method		-predicateOutcomeWithObject
 @abstract		This loops through all the internal NSPredicate and NSPredicateRule
				in priority order (lowest first) and returns the outcome of the first matching.
 @param		object		The object to test against the predicates.
 @param		bindings	The bindings to replace any variable expressions. Every variable
 				in every `NSPredicate`/`PredicateRule`
 @discussion	.
 @result		Returns `NSPredicateRuleOutcome` based on the object matching
				a rule, it's outcome, and if there is no match.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings API_AVAILABLE(macos(10.5), ios(3.0), watchos(2.0), tvos(9.0)); // single pass evaluation substituting variables from the bindings dictionary for any variable expressions encountered
@end



/*!
 @category		NSPredicateRuleSupport
 @abstract		This implements a Rule set of `BEPredicateRule` where it orders the
				rules, and matches to the first (lowest) priority rule and
				returns the `NSPredicateRuleOutcome` of its outcome.
				If no rule is matched, `NSPredicateRuleNA` is returned.
 */
@interface NSSet (BEPredicateRuleSupport)

/*!
 @method		-predicateOutcomeWithObject
 @abstract		This loops through all the internal NSPredicate and NSPredicateRule
				in priority order (lowest first) and returns the outcome of the first matching.
 @param		object	The object to test against the predicates.
 @discussion	.
 @result		Returns `NSPredicateRuleOutcome` based on the object matching
				a rule, it's outcome, and if there is no match.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object;

/*!
 @method		-predicateOutcomeWithObject
 @abstract		This loops through all the internal NSPredicate and NSPredicateRule
				in priority order (lowest first) and returns the outcome of the first matching.
 @param		object		The object to test against the predicates.
 @param		bindings	The bindings to replace any variable expressions. Every variable
				in every `NSPredicate`/`PredicateRule`
 @discussion	.
 @result		Returns `NSPredicateRuleOutcome` based on the object matching
				a rule, it's outcome, and if there is no match.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings API_AVAILABLE(macos(10.5), ios(3.0), watchos(2.0), tvos(9.0)); // single pass evaluation substituting variables from the bindings dictionary for any variable expressions encountered
@end



/*!
 @category		NSPredicateRuleSupport
 @abstract		This implements a Rule set of `BEPredicateRule` where it orders the
 				rules, and matches to the first (lowest) priority rule and
				returns the `NSPredicateRuleOutcome` of its outcome.
				If no rule is matched, `NSPredicateRuleNA` is returned.
 */
@interface NSOrderedSet (BEPredicateRuleSupport)

/*!
 @method		-predicateOutcomeWithObject
 @abstract		This loops through all the internal NSPredicate and NSPredicateRule
				in priority order (lowest first) and returns the outcome of the first matching.
 @param		object	The object to test against the predicates.
 @discussion	.
 @result		Returns `NSPredicateRuleOutcome` based on the object matching
				a rule, it's outcome, and if there is no match.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object;

/*!
 @method		-predicateOutcomeWithObject
 @abstract		This loops through all the internal NSPredicate and NSPredicateRule
				in priority order (lowest first) and returns the outcome of the first matching.
 @param		object		The object to test against the predicates.
 @param		bindings	The bindings to replace any variable expressions. Every variable
				in every `NSPredicate`/`PredicateRule`
 @discussion	.
 @result		Returns `NSPredicateRuleOutcome` based on the object matching
				a rule, it's outcome, and if there is no match.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings API_AVAILABLE(macos(10.5), ios(3.0), watchos(2.0), tvos(9.0)); // single pass evaluation substituting variables from the bindings dictionary for any variable expressions encountered

@end

#endif	//	BEPredicateRule_h
