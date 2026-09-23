/*!
 @header		BEPredicateRule.h
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		This checks an object against an array or set of BEPredicateRule to check if the object is accepted, rejected, or NA.
*/

#ifndef BEPredicateRule_h
#define BEPredicateRule_h

#import <Foundation/Foundation.h>
#import <BEFoundation/BEPriorityExtensions.h>

/*!
 @const			BEPredicateRuleDefaultPriority
 @abstract		The priority of a rule whose `itemPriority` is unset. The value is 0.
 */
extern NSInteger	const  BEPredicateRuleDefaultPriority;


/*!
 @typedef		BEPredicateRuleOutcome
 @abstract		This is the result of checking a collection (NSArray, NSSet, NSOrderedSet)
				of BEPredicateRules.
				If a rule set is not matched `BEPredicateRuleNA` is returned.
				If a rule is matched in a rule set, then its outcome is returned as
				`BEPredicateRuleAccept` (value: 1) or
				`BEPredicateRuleReject` (value: -1)
 */
typedef NSInteger BEPredicateRuleOutcome;
NS_ENUM(BEPredicateRuleOutcome) {
	/*!
	 @constant		BEPredicateRuleReject
	 @abstract		The rule rejects the evaluated object. The value is -1.
	 */
	BEPredicateRuleReject = -1,
	/*!
	 @constant		BEPredicateRuleNA
	 @abstract		No outcome. The value is 0.
	 @discussion	A matching rule with this outcome is skipped. A rule set with no matching
					rule reports this outcome. It is the default outcome of a new rule.
	 */
	BEPredicateRuleNA = 0,
	/*!
	 @constant		BEPredicateRuleAccept
	 @abstract		The rule accepts the evaluated object. The value is 1.
	 */
	BEPredicateRuleAccept = 1,
};





/*!
 @interface		BEPredicateRule
 @abstract		An NSPredicate paired with an outcome (accept, reject, or N/A) and a sortable priority.
 @discussion	Collect rules in an NSArray, NSSet, or NSOrderedSet and ask for the outcome of the
				highest-priority matching rule with -ruleOutcomeWithObject:. Rules are evaluated in
				ascending priority order; the first match with a non-N/A outcome wins.

				@code
				NSArray *rules = @[
					[BEPredicateRule ruleWithOutcome:BEPredicateRuleReject priorityInteger:0 format:@"age < %d", 18],
					[BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept priorityInteger:10 format:@"age >= %d", 18],
				];
				BEPredicateRuleOutcome outcome = [rules ruleOutcomeWithObject:@{@"age": @21}];
				// outcome == BEPredicateRuleAccept
				@endcode

				A new rule has outcome `BEPredicateRuleNA` and priority `BEPredicateRuleDefaultPriority`
				unless a factory or initializer sets them.

				Changed in 1.2.0: the `+rule...` factories return `instancetype`, so a subclass receives
				its own type. Changed in 1.2.0: a nil predicate passed to any `initWithPredicate:...`
				initializer raises `NSInvalidArgumentException`.
 */
@interface BEPredicateRule : NSPredicate <NSSecureCoding, NSCopying, BEPriorityItem>

/*!
 @property		predicate
 @abstract		The NSPredicate this rule evaluates.
 */
@property (readonly, nonnull) NSPredicate *predicate;

/*!
 @property		outcome
 @abstract		The outcome reported for this rule when its predicate matches.
 */
@property (readwrite, nonatomic) BEPredicateRuleOutcome outcome;


/*!
 @property		defaultItemPriority
 @abstract		The priority used when `itemPriority` is unset: `BEPredicateRuleDefaultPriority`.
 */
@property (readonly, nonatomic, nonnull) NSNumber *defaultItemPriority;

/*!
 @property		itemPriority
 @abstract		The rule's sort priority within a rule set, or `defaultItemPriority` when unset.
 @discussion	Rules are evaluated in ascending priority order. `itemPriorityInteger` and
				`itemPriorityDouble` are convenience accessors for the same underlying value.
 */
@property (readwrite, nonatomic, nullable) NSNumber *itemPriority;

/*!
 @property		itemPriorityInteger
 @abstract		`itemPriority` as an NSInteger.
 @discussion	Reading returns the `integerValue` of `itemPriority`, or `BEPredicateRuleDefaultPriority`
				when the priority is unset. Writing stores the value in `itemPriority` as an NSNumber.
 */
@property (readwrite, nonatomic) NSInteger itemPriorityInteger;

/*!
 @property		itemPriorityDouble
 @abstract		`itemPriority` as a double.
 @discussion	Reading returns the `doubleValue` of `itemPriority`, or `BEPredicateRuleDefaultPriority`
				when the priority is unset. Writing stores the value in `itemPriority` as an NSNumber.
 */
@property (readwrite, nonatomic) double itemPriorityDouble;

/*!
 @property		isUniqueItemPriority
 @abstract		Whether `itemPriority` participates in `-isEqual:` and `-hash`. Default NO.
 @discussion	Two rules are equal only when this flag matches on both. When YES, their
				priorities must also match, which lets the same rule appear with different
				priorities in an NSSet or NSOrderedSet.
 */
@property (readwrite) BOOL isUniqueItemPriority;

/*!
 @method		+supportsSecureCoding
 @abstract		Returns YES. `BEPredicateRule` archives and unarchives with NSSecureCoding.
 @result		YES.
 */
+ (BOOL)supportsSecureCoding;

/*!
 @method		+ruleWithFormat:
 @abstract		Creates a rule from a variadic predicate format with outcome `BEPredicateRuleNA` and the default priority.
 @param			predicateFormat	The predicate format string, followed by its arguments.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(NSString * _Nonnull)predicateFormat, ...;

/*!
 @method		+ruleWithOutcome:format:
 @abstract		Creates a rule from a variadic predicate format with `outcome` and the default priority.
 @param			outcome			The outcome reported when the predicate matches.
 @param			predicateFormat	The predicate format string, followed by its arguments.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome format:(NSString * _Nonnull)predicateFormat, ...;

/*!
 @method		+ruleWithPriority:format:
 @abstract		Creates a rule from a variadic predicate format with outcome `BEPredicateRuleNA` and `priority`.
 @param			priority		The rule's sort priority.
 @param			predicateFormat	The predicate format string, followed by its arguments.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithPriority:(NSNumber * _Nonnull)priority format:(NSString * _Nonnull)predicateFormat, ...;

/*!
 @method		+ruleWithPriorityInteger:format:
 @abstract		Creates a rule from a variadic predicate format with outcome `BEPredicateRuleNA` and an integer priority.
 @param			priority		The rule's sort priority.
 @param			predicateFormat	The predicate format string, followed by its arguments.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithPriorityInteger:(NSInteger)priority format:(NSString * _Nonnull)predicateFormat, ...;

/*!
 @method		+ruleWithPriorityDouble:format:
 @abstract		Creates a rule from a variadic predicate format with outcome `BEPredicateRuleNA` and a double priority.
 @param			priority		The rule's sort priority.
 @param			predicateFormat	The predicate format string, followed by its arguments.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithPriorityDouble:(double)priority format:(NSString * _Nonnull)predicateFormat, ...;

/*!
 @method		+ruleWithOutcome:priority:format:
 @abstract		Creates a rule from a variadic predicate format with `outcome` and `priority`.
 @param			outcome			The outcome reported when the predicate matches.
 @param			priority		The rule's sort priority.
 @param			predicateFormat	The predicate format string, followed by its arguments.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority format:(NSString * _Nonnull)predicateFormat, ...;

/*!
 @method		+ruleWithOutcome:priorityInteger:format:
 @abstract		Creates a rule from a variadic predicate format with `outcome` and an integer priority.
 @param			outcome			The outcome reported when the predicate matches.
 @param			priority		The rule's sort priority.
 @param			predicateFormat	The predicate format string, followed by its arguments.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority format:(NSString * _Nonnull)predicateFormat, ...;

/*!
 @method		+ruleWithOutcome:priorityDouble:format:
 @abstract		Creates a rule from a variadic predicate format with `outcome` and a double priority.
 @param			outcome			The outcome reported when the predicate matches.
 @param			priority		The rule's sort priority.
 @param			predicateFormat	The predicate format string, followed by its arguments.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority format:(NSString * _Nonnull)predicateFormat, ...;

/*!
 @method		+ruleWithFormat:argumentArray:
 @abstract		Creates a rule from a predicate format and an argument array with outcome `BEPredicateRuleNA` and the default priority.
 @param			predicateFormat	The predicate format string.
 @param			arguments		The values substituted for the format's placeholders, or nil.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments;

/*!
 @method		+ruleWithFormat:argumentArray:outcome:
 @abstract		Creates a rule from a predicate format and an argument array with `outcome` and the default priority.
 @param			predicateFormat	The predicate format string.
 @param			arguments		The values substituted for the format's placeholders, or nil.
 @param			outcome			The outcome reported when the predicate matches.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome;

/*!
 @method		+ruleWithFormat:argumentArray:priority:
 @abstract		Creates a rule from a predicate format and an argument array with outcome `BEPredicateRuleNA` and `priority`.
 @param			predicateFormat	The predicate format string.
 @param			arguments		The values substituted for the format's placeholders, or nil.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priority:(NSNumber * _Nonnull)priority;

/*!
 @method		+ruleWithFormat:argumentArray:priorityInteger:
 @abstract		Creates a rule from a predicate format and an argument array with outcome `BEPredicateRuleNA` and an integer priority.
 @param			predicateFormat	The predicate format string.
 @param			arguments		The values substituted for the format's placeholders, or nil.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priorityInteger:(NSInteger)priority;

/*!
 @method		+ruleWithFormat:argumentArray:priorityDouble:
 @abstract		Creates a rule from a predicate format and an argument array with outcome `BEPredicateRuleNA` and a double priority.
 @param			predicateFormat	The predicate format string.
 @param			arguments		The values substituted for the format's placeholders, or nil.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments priorityDouble:(double)priority;

/*!
 @method		+ruleWithFormat:argumentArray:outcome:priority:
 @abstract		Creates a rule from a predicate format and an argument array with `outcome` and `priority`.
 @param			predicateFormat	The predicate format string.
 @param			arguments		The values substituted for the format's placeholders, or nil.
 @param			outcome			The outcome reported when the predicate matches.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority;

/*!
 @method		+ruleWithFormat:argumentArray:outcome:priorityInteger:
 @abstract		Creates a rule from a predicate format and an argument array with `outcome` and an integer priority.
 @param			predicateFormat	The predicate format string.
 @param			arguments		The values substituted for the format's placeholders, or nil.
 @param			outcome			The outcome reported when the predicate matches.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority;

/*!
 @method		+ruleWithFormat:argumentArray:outcome:priorityDouble:
 @abstract		Creates a rule from a predicate format and an argument array with `outcome` and a double priority.
 @param			predicateFormat	The predicate format string.
 @param			arguments		The values substituted for the format's placeholders, or nil.
 @param			outcome			The outcome reported when the predicate matches.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority;

/*!
 @method		+ruleWithFormat:arguments:
 @abstract		Creates a rule from a predicate format and a `va_list` with outcome `BEPredicateRuleNA` and the default priority.
 @param			predicateFormat	The predicate format string.
 @param			argList			The `va_list` holding the format's arguments.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList;

/*!
 @method		+ruleWithFormat:arguments:outcome:
 @abstract		Creates a rule from a predicate format and a `va_list` with `outcome` and the default priority.
 @param			predicateFormat	The predicate format string.
 @param			argList			The `va_list` holding the format's arguments.
 @param			outcome			The outcome reported when the predicate matches.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome;

/*!
 @method		+ruleWithFormat:arguments:priority:
 @abstract		Creates a rule from a predicate format and a `va_list` with outcome `BEPredicateRuleNA` and `priority`.
 @param			predicateFormat	The predicate format string.
 @param			argList			The `va_list` holding the format's arguments.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priority:(NSNumber * _Nonnull)priority;

/*!
 @method		+ruleWithFormat:arguments:priorityInteger:
 @abstract		Creates a rule from a predicate format and a `va_list` with outcome `BEPredicateRuleNA` and an integer priority.
 @param			predicateFormat	The predicate format string.
 @param			argList			The `va_list` holding the format's arguments.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priorityInteger:(NSInteger)priority;

/*!
 @method		+ruleWithFormat:arguments:priorityDouble:
 @abstract		Creates a rule from a predicate format and a `va_list` with outcome `BEPredicateRuleNA` and a double priority.
 @param			predicateFormat	The predicate format string.
 @param			argList			The `va_list` holding the format's arguments.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList priorityDouble:(double)priority;

/*!
 @method		+ruleWithFormat:arguments:outcome:priority:
 @abstract		Creates a rule from a predicate format and a `va_list` with `outcome` and `priority`.
 @param			predicateFormat	The predicate format string.
 @param			argList			The `va_list` holding the format's arguments.
 @param			outcome			The outcome reported when the predicate matches.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority;

/*!
 @method		+ruleWithFormat:arguments:outcome:priorityInteger:
 @abstract		Creates a rule from a predicate format and a `va_list` with `outcome` and an integer priority.
 @param			predicateFormat	The predicate format string.
 @param			argList			The `va_list` holding the format's arguments.
 @param			outcome			The outcome reported when the predicate matches.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority;

/*!
 @method		+ruleWithFormat:arguments:outcome:priorityDouble:
 @abstract		Creates a rule from a predicate format and a `va_list` with `outcome` and a double priority.
 @param			predicateFormat	The predicate format string.
 @param			argList			The `va_list` holding the format's arguments.
 @param			outcome			The outcome reported when the predicate matches.
 @param			priority		The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority;

/*!
 @method		+ruleWithValue:
 @abstract		Creates a rule whose predicate always evaluates to `value`, with outcome `BEPredicateRuleNA` and the default priority.
 @param			value	YES for a predicate that always matches; NO for one that never matches.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithValue:(BOOL)value;

/*!
 @method		+ruleWithValue:outcome:
 @abstract		Creates a rule whose predicate always evaluates to `value`, with `outcome` and the default priority.
 @param			value	YES for a predicate that always matches; NO for one that never matches.
 @param			outcome	The outcome reported when the predicate matches.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome;

/*!
 @method		+ruleWithValue:priority:
 @abstract		Creates a rule whose predicate always evaluates to `value`, with outcome `BEPredicateRuleNA` and `priority`.
 @param			value		YES for a predicate that always matches; NO for one that never matches.
 @param			priority	The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithValue:(BOOL)value priority:(NSNumber * _Nonnull)priority;

/*!
 @method		+ruleWithValue:priorityInteger:
 @abstract		Creates a rule whose predicate always evaluates to `value`, with outcome `BEPredicateRuleNA` and an integer priority.
 @param			value		YES for a predicate that always matches; NO for one that never matches.
 @param			priority	The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithValue:(BOOL)value priorityInteger:(NSInteger)priority;

/*!
 @method		+ruleWithValue:priorityDouble:
 @abstract		Creates a rule whose predicate always evaluates to `value`, with outcome `BEPredicateRuleNA` and a double priority.
 @param			value		YES for a predicate that always matches; NO for one that never matches.
 @param			priority	The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithValue:(BOOL)value priorityDouble:(double)priority;

/*!
 @method		+ruleWithValue:outcome:priority:
 @abstract		Creates a rule whose predicate always evaluates to `value`, with `outcome` and `priority`.
 @param			value		YES for a predicate that always matches; NO for one that never matches.
 @param			outcome		The outcome reported when the predicate matches.
 @param			priority	The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority;

/*!
 @method		+ruleWithValue:outcome:priorityInteger:
 @abstract		Creates a rule whose predicate always evaluates to `value`, with `outcome` and an integer priority.
 @param			value		YES for a predicate that always matches; NO for one that never matches.
 @param			outcome		The outcome reported when the predicate matches.
 @param			priority	The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority;

/*!
 @method		+ruleWithValue:outcome:priorityDouble:
 @abstract		Creates a rule whose predicate always evaluates to `value`, with `outcome` and a double priority.
 @param			value		YES for a predicate that always matches; NO for one that never matches.
 @param			outcome		The outcome reported when the predicate matches.
 @param			priority	The rule's sort priority.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithValue:(BOOL)value outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority;

/*!
 @method		+ruleWithBlock:
 @abstract		Creates a rule whose predicate calls `block`, with outcome `BEPredicateRuleNA` and the default priority.
 @param			block	The block that evaluates an object and its variable bindings.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithBlock:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/*!
 @method		+ruleWithOutcome:block:
 @abstract		Creates a rule whose predicate calls `block`, with `outcome` and the default priority.
 @param			outcome	The outcome reported when the predicate matches.
 @param			block	The block that evaluates an object and its variable bindings.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/*!
 @method		+ruleWithPriority:block:
 @abstract		Creates a rule whose predicate calls `block`, with outcome `BEPredicateRuleNA` and `priority`.
 @param			priority	The rule's sort priority.
 @param			block		The block that evaluates an object and its variable bindings.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithPriority:(NSNumber * _Nonnull)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/*!
 @method		+ruleWithPriorityInteger:block:
 @abstract		Creates a rule whose predicate calls `block`, with outcome `BEPredicateRuleNA` and an integer priority.
 @param			priority	The rule's sort priority.
 @param			block		The block that evaluates an object and its variable bindings.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithPriorityInteger:(NSInteger)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/*!
 @method		+ruleWithPriorityDouble:block:
 @abstract		Creates a rule whose predicate calls `block`, with outcome `BEPredicateRuleNA` and a double priority.
 @param			priority	The rule's sort priority.
 @param			block		The block that evaluates an object and its variable bindings.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithPriorityDouble:(double)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/*!
 @method		+ruleWithOutcome:priority:block:
 @abstract		Creates a rule whose predicate calls `block`, with `outcome` and `priority`.
 @param			outcome		The outcome reported when the predicate matches.
 @param			priority	The rule's sort priority.
 @param			block		The block that evaluates an object and its variable bindings.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/*!
 @method		+ruleWithOutcome:priorityInteger:block:
 @abstract		Creates a rule whose predicate calls `block`, with `outcome` and an integer priority.
 @param			outcome		The outcome reported when the predicate matches.
 @param			priority	The rule's sort priority.
 @param			block		The block that evaluates an object and its variable bindings.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/*!
 @method		+ruleWithOutcome:priorityDouble:block:
 @abstract		Creates a rule whose predicate calls `block`, with `outcome` and a double priority.
 @param			outcome		The outcome reported when the predicate matches.
 @param			priority	The rule's sort priority.
 @param			block		The block that evaluates an object and its variable bindings.
 @result		A new rule of the receiving class.
 */
+ (nonnull instancetype)ruleWithOutcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority block:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));


/*!
 @method		+predicateWithFormat:argumentArray:
 @abstract		Unavailable on BEPredicateRule. Use `+ruleWithFormat:argumentArray:`.
 @discussion	The NSPredicate factories are declared `NS_UNAVAILABLE` so that a call site is
				directed at compile time to the `+rule...` factory that returns a rule.
 */
+ (nonnull NSPredicate *)predicateWithFormat:(nonnull NSString *)predicateFormat argumentArray:(nullable NSArray *)arguments NS_UNAVAILABLE;

/*!
 @method		+predicateWithFormat:
 @abstract		Unavailable on BEPredicateRule. Use `+ruleWithFormat:`.
 */
+ (nonnull NSPredicate *)predicateWithFormat:(nonnull NSString *)predicateFormat, ... NS_UNAVAILABLE;

/*!
 @method		+predicateWithFormat:arguments:
 @abstract		Unavailable on BEPredicateRule. Use `+ruleWithFormat:arguments:`.
 */
+ (nonnull NSPredicate *)predicateWithFormat:(nonnull NSString *)predicateFormat arguments:(va_list)argList NS_UNAVAILABLE;

/*!
 @method		+predicateFromMetadataQueryString:
 @abstract		Unavailable on BEPredicateRule. Build the predicate with `+[NSPredicate predicateFromMetadataQueryString:]` and wrap it with `initWithPredicate:`.
 */
+ (nullable NSPredicate *)predicateFromMetadataQueryString:(nonnull NSString *)queryString NS_UNAVAILABLE;

/*!
 @method		+predicateWithValue:
 @abstract		Unavailable on BEPredicateRule. Use `+ruleWithValue:`.
 */
+ (nonnull NSPredicate *)predicateWithValue:(BOOL)value NS_UNAVAILABLE;

/*!
 @method		+predicateWithBlock:
 @abstract		Unavailable on BEPredicateRule. Use `+ruleWithBlock:`.
 */
+ (nonnull NSPredicate*)predicateWithBlock:(BOOL (^ _Nonnull)(id _Nullable evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings))block NS_UNAVAILABLE;

/*!
 @property		predicateFormat
 @abstract		The format string of the wrapped predicate.
 */
@property (readonly, nonatomic, copy, nonnull) NSString *predicateFormat;

/*!
 @method		initWithPredicate:
 @abstract		Initializes a rule that wraps `predicate` with outcome `BEPredicateRuleNA` and the default priority.
 @param			predicate	The predicate the rule evaluates.
 @result		The initialized rule.
 @exception		NSInvalidArgumentException	`predicate` is nil.
 @discussion	Every `initWithPredicate:...` initializer raises on a nil predicate. The `+rule...`
				factories return a rule of the receiving class, so subclasses receive their own type.
 */
- (nonnull instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate;

/*!
 @method		initWithPredicate:outcome:
 @abstract		Initializes a rule that wraps `predicate` with `outcome` and the default priority.
 @param			predicate	The predicate the rule evaluates.
 @param			outcome		The outcome reported when the predicate matches.
 @result		The initialized rule.
 @exception		NSInvalidArgumentException	`predicate` is nil.
 */
- (nonnull instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate outcome:(BEPredicateRuleOutcome)outcome;

/*!
 @method		initWithPredicate:priority:
 @abstract		Initializes a rule that wraps `predicate` with outcome `BEPredicateRuleNA` and `priority`.
 @param			predicate	The predicate the rule evaluates.
 @param			priority	The rule's sort priority.
 @result		The initialized rule.
 @exception		NSInvalidArgumentException	`predicate` is nil.
 */
- (nonnull instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate priority:(NSNumber * _Nonnull)priority;

/*!
 @method		initWithPredicate:priorityInteger:
 @abstract		Initializes a rule that wraps `predicate` with outcome `BEPredicateRuleNA` and an integer priority.
 @param			predicate	The predicate the rule evaluates.
 @param			priority	The rule's sort priority.
 @result		The initialized rule.
 @exception		NSInvalidArgumentException	`predicate` is nil.
 */
- (nonnull instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate priorityInteger:(NSInteger)priority;

/*!
 @method		initWithPredicate:priorityDouble:
 @abstract		Initializes a rule that wraps `predicate` with outcome `BEPredicateRuleNA` and a double priority.
 @param			predicate	The predicate the rule evaluates.
 @param			priority	The rule's sort priority.
 @result		The initialized rule.
 @exception		NSInvalidArgumentException	`predicate` is nil.
 */
- (nonnull instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate priorityDouble:(double)priority;

/*!
 @method		initWithPredicate:outcome:priority:
 @abstract		Initializes a rule that wraps `predicate` with `outcome` and `priority`.
 @param			predicate	The predicate the rule evaluates.
 @param			outcome		The outcome reported when the predicate matches.
 @param			priority	The rule's sort priority.
 @result		The initialized rule.
 @exception		NSInvalidArgumentException	`predicate` is nil.
 */
- (nonnull instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber * _Nonnull)priority;

/*!
 @method		initWithPredicate:outcome:priorityInteger:
 @abstract		Initializes a rule that wraps `predicate` with `outcome` and an integer priority.
 @param			predicate	The predicate the rule evaluates.
 @param			outcome		The outcome reported when the predicate matches.
 @param			priority	The rule's sort priority.
 @result		The initialized rule.
 @exception		NSInvalidArgumentException	`predicate` is nil.
 */
- (nonnull instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate outcome:(BEPredicateRuleOutcome)outcome priorityInteger:(NSInteger)priority;

/*!
 @method		initWithPredicate:outcome:priorityDouble:
 @abstract		Initializes a rule that wraps `predicate` with `outcome` and a double priority.
 @param			predicate	The predicate the rule evaluates.
 @param			outcome		The outcome reported when the predicate matches.
 @param			priority	The rule's sort priority.
 @result		The initialized rule.
 @exception		NSInvalidArgumentException	`predicate` is nil.
 */
- (nonnull instancetype)initWithPredicate:(NSPredicate * _Nonnull)predicate outcome:(BEPredicateRuleOutcome)outcome priorityDouble:(double)priority;

/*!
 @method		initWithCoder:
 @abstract		Initializes a rule from an archive written by `encodeWithCoder:`.
 @param			coder	The decoder.
 @result		The decoded rule.
 @discussion	Decodes the predicate, outcome, `isUniqueItemPriority`, and the priority. A rule
				archived with an unset priority decodes with an unset priority.
 */
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder;

/*!
 @method		encodeWithCoder:
 @abstract		Archives the predicate, outcome, `isUniqueItemPriority`, and the priority when one is set.
 @param			coder	The encoder.
 */
- (void)encodeWithCoder:(NSCoder * _Nonnull)coder;

/*!
 @method		substitutePredicateVariables:
 @abstract		Replaces the wrapped predicate, in place, with a copy whose variables are substituted from `variables`.
 @param			variables	The values substituted for the predicate's variable expressions, or nil.
 @discussion	This mutates the receiver. `ruleWithSubstitutionVariables:` returns a substituted copy
				and leaves the receiver unchanged.
 */
- (void)substitutePredicateVariables:(NSDictionary<NSString *, id> * _Nullable)variables;

/*!
 @method		ruleWithSubstitutionVariables:
 @abstract		Returns a copy of the rule whose predicate has its variables substituted from `variables`.
 @param			variables	The values substituted for the predicate's variable expressions, or nil.
 @result		A new rule of the receiver's class with the same outcome, priority, and `isUniqueItemPriority`. The receiver is unchanged.
 */
- (nonnull instancetype)ruleWithSubstitutionVariables:(NSDictionary<NSString *, id> * _Nullable)variables;

/*!
 @method		copyWithZone:
 @abstract		Returns a rule of the receiver's class with the same predicate, outcome, priority, and `isUniqueItemPriority`.
 @param			zone	The allocation zone, or NULL.
 @result		The copied rule. An unset priority stays unset in the copy.
 */
- (nonnull id)copyWithZone:(nullable NSZone *)zone;

/*!
 @method		evaluateWithObject:
 @abstract		Evaluates the wrapped predicate against `object`.
 @param			object	The object to test.
 @result		YES when the predicate matches `object`.
 */
- (BOOL)evaluateWithObject:(nullable id)object;

/*!
 @method		evaluateWithObject:substitutionVariables:
 @abstract		Evaluates the wrapped predicate against `object` in a single pass, substituting `bindings` for its variable expressions.
 @param			object		The object to test.
 @param			bindings	The values substituted for variable expressions, or nil.
 @result		YES when the predicate matches `object`.
 */
- (BOOL)evaluateWithObject:(nullable id)object substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings API_AVAILABLE(macos(10.5), ios(3.0), watchos(2.0), tvos(9.0));

/*!
 @method		allowEvaluation
 @abstract		Forwards to the wrapped predicate's `allowEvaluation`, which permits evaluation of a securely decoded predicate.
 @discussion	Available on macOS 10.9, iOS 7.0, watchOS 2.0, and tvOS 9.0 or later.
 */
- (void)allowEvaluation API_AVAILABLE(macos(10.9), ios(7.0), watchos(2.0), tvos(9.0));

@end



/*!
 @category		BEPredicateRuleSupport
 @abstract		This implements a Rule set of `BEPredicateRule` where it orders the
				rules, and matches to the first (lowest) priority rule whose outcome is not
				`BEPredicateRuleNA` and returns that outcome. A matching rule with an NA
				outcome is skipped. If no rule is matched, `BEPredicateRuleNA` is returned.
 */
@interface NSArray (BEPredicateRuleSupport)

/*!
 @method		-ruleOutcomeWithObject:
 @abstract		This loops through the internal BEPredicateRule elements (non-BEPredicateRule elements are ignored)
 				in priority order (lowest first) and returns the outcome of the first matching
				rule whose outcome is not `BEPredicateRuleNA`; a matching NA rule is skipped.
 @param		object	The object to test against the predicates.
 @result		The outcome of the first matching rule whose outcome is not `BEPredicateRuleNA`,
				or `BEPredicateRuleNA` when no rule matches.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object;

/*!
 @method		-ruleOutcomeWithObject:substitutionVariables:
 @abstract		This loops through the internal BEPredicateRule elements (non-BEPredicateRule elements are ignored)
				in priority order (lowest first) and returns the outcome of the first matching
				rule whose outcome is not `BEPredicateRuleNA`; a matching NA rule is skipped.
 @param		object		The object to test against the predicates.
 @param		bindings	The values substituted for the variable expressions in each rule's predicate, or nil.
				Evaluation runs in a single pass.
 @result		The outcome of the first matching rule whose outcome is not `BEPredicateRuleNA`,
				or `BEPredicateRuleNA` when no rule matches.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings API_AVAILABLE(macos(10.5), ios(3.0), watchos(2.0), tvos(9.0));
@end



/*!
 @category		BEPredicateRuleSupport
 @abstract		This implements a Rule set of `BEPredicateRule` where it orders the
				rules, and matches to the first (lowest) priority rule and
				returns the `BEPredicateRuleOutcome` of its outcome.
				If no rule is matched, `BEPredicateRuleNA` is returned.
 */
@interface NSSet (BEPredicateRuleSupport)

/*!
 @method		-ruleOutcomeWithObject:
 @abstract		This loops through the internal BEPredicateRule elements (non-BEPredicateRule elements are ignored)
				in priority order (lowest first) and returns the outcome of the first matching
				rule whose outcome is not `BEPredicateRuleNA`; a matching NA rule is skipped.
 @param		object	The object to test against the predicates.
 @result		The outcome of the first matching rule whose outcome is not `BEPredicateRuleNA`,
				or `BEPredicateRuleNA` when no rule matches.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object;

/*!
 @method		-ruleOutcomeWithObject:substitutionVariables:
 @abstract		This loops through the internal BEPredicateRule elements (non-BEPredicateRule elements are ignored)
				in priority order (lowest first) and returns the outcome of the first matching
				rule whose outcome is not `BEPredicateRuleNA`; a matching NA rule is skipped.
 @param		object		The object to test against the predicates.
 @param		bindings	The values substituted for the variable expressions in each rule's predicate, or nil.
				Evaluation runs in a single pass.
 @result		The outcome of the first matching rule whose outcome is not `BEPredicateRuleNA`,
				or `BEPredicateRuleNA` when no rule matches.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings API_AVAILABLE(macos(10.5), ios(3.0), watchos(2.0), tvos(9.0));
@end



/*!
 @category		BEPredicateRuleSupport
 @abstract		This implements a Rule set of `BEPredicateRule` where it orders the
 				rules, and matches to the first (lowest) priority rule and
				returns the `BEPredicateRuleOutcome` of its outcome.
				If no rule is matched, `BEPredicateRuleNA` is returned.
 */
@interface NSOrderedSet (BEPredicateRuleSupport)

/*!
 @method		-ruleOutcomeWithObject:
 @abstract		This loops through the internal BEPredicateRule elements (non-BEPredicateRule elements are ignored)
				in priority order (lowest first) and returns the outcome of the first matching
				rule whose outcome is not `BEPredicateRuleNA`; a matching NA rule is skipped.
 @param		object	The object to test against the predicates.
 @result		The outcome of the first matching rule whose outcome is not `BEPredicateRuleNA`,
				or `BEPredicateRuleNA` when no rule matches.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object;

/*!
 @method		-ruleOutcomeWithObject:substitutionVariables:
 @abstract		This loops through the internal BEPredicateRule elements (non-BEPredicateRule elements are ignored)
				in priority order (lowest first) and returns the outcome of the first matching
				rule whose outcome is not `BEPredicateRuleNA`; a matching NA rule is skipped.
 @param		object		The object to test against the predicates.
 @param		bindings	The values substituted for the variable expressions in each rule's predicate, or nil.
				Evaluation runs in a single pass.
 @result		The outcome of the first matching rule whose outcome is not `BEPredicateRuleNA`,
				or `BEPredicateRuleNA` when no rule matches.
 */
- (BEPredicateRuleOutcome)ruleOutcomeWithObject:(nullable id)object substitutionVariables:(nullable NSDictionary<NSString *, id> *)bindings API_AVAILABLE(macos(10.5), ios(3.0), watchos(2.0), tvos(9.0));

@end

#endif	//	BEPredicateRule_h
