//
//  BFoundationExtensionTests.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import "BEFoundation/BEPredicateRule.h"

@interface BEPredicateRuleTests : XCTestCase

@end


@implementation BEPredicateRuleTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testBEPredicateRule_outcome
{
	BEPredicateRule *predicate = [BEPredicateRule ruleWithValue:YES];
	
	XCTAssertEqual(predicate.outcome, BEPredicateRuleNA);
	
	predicate.outcome = BEPredicateRuleAccept;
	XCTAssertEqual(predicate.outcome, BEPredicateRuleAccept);
	
	predicate.outcome = BEPredicateRuleReject;
	XCTAssertEqual(predicate.outcome, BEPredicateRuleReject);
	
	predicate.outcome = BEPredicateRuleNA;
	XCTAssertEqual(predicate.outcome, BEPredicateRuleNA);
}

- (void)testBEPredicateRule_defaultItemPriority
{
	BEPredicateRule *predicate = BEPredicateRule.new;
	XCTAssertEqualObjects(predicate.defaultItemPriority, @(BEPredicateRuleDefaultPriority));
	predicate.itemPriority = @(3);
	XCTAssertEqualObjects(predicate.defaultItemPriority, @(BEPredicateRuleDefaultPriority));
	
	BEPredicateRule *predicate2 = [BEPredicateRule ruleWithValue:YES];
	XCTAssertEqualObjects(predicate2.defaultItemPriority, @(BEPredicateRuleDefaultPriority));
	XCTAssertNotEqualObjects(predicate2.itemPriority, predicate.itemPriority);
}

- (void)testBEPredicateRule_itemPriority
{
	BEPredicateRule *predicate = BEPredicateRule.new;
	
	XCTAssertEqual(predicate.itemPriority, predicate.defaultItemPriority);
	predicate.itemPriority = @(10);
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(10));
	XCTAssertEqual(predicate.itemPriorityInteger, 10);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)10);
	
	predicate.itemPriority = @(0);
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(0));
	XCTAssertEqual(predicate.itemPriorityInteger, 0);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)0);
	
	predicate.itemPriority = @(-10);
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(-10));
	XCTAssertEqual(predicate.itemPriorityInteger, -10);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)-10);
	
	predicate.itemPriority = nil;
	XCTAssertEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqual(predicate.itemPriorityInteger, predicate.defaultItemPriority.integerValue);
	XCTAssertEqual(predicate.itemPriorityDouble, predicate.defaultItemPriority.doubleValue);
	
	predicate.itemPriority = (NSNumber*)NSObject.new;
	
	XCTAssertEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqual(predicate.itemPriorityInteger, predicate.defaultItemPriority.integerValue);
	XCTAssertEqual(predicate.itemPriorityDouble, predicate.defaultItemPriority.doubleValue);
	
	predicate.itemPriority = @(-10);
	predicate.itemPriority = (NSNumber*)NSObject.new;
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(-10));
	XCTAssertEqual(predicate.itemPriorityInteger, -10);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)-10);
}

- (void)testBEPredicateRule_itemPriorityInteger
{
	BEPredicateRule *predicate = BEPredicateRule.new;
	
	XCTAssertEqual(predicate.itemPriority, predicate.defaultItemPriority);
	predicate.itemPriorityInteger = 10;
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(10));
	XCTAssertEqual(predicate.itemPriorityInteger, 10);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)10);
	
	predicate.itemPriorityInteger = 0;
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(0));
	XCTAssertEqual(predicate.itemPriorityInteger, 0);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)0);
	
	predicate.itemPriorityInteger = -10;
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(-10));
	XCTAssertEqual(predicate.itemPriorityInteger, -10);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)-10);
}

- (void)testBEPredicateRule_itemPriorityDouble
{
	BEPredicateRule *predicate = BEPredicateRule.new;
	
	XCTAssertEqual(predicate.itemPriority, predicate.defaultItemPriority);
	predicate.itemPriorityDouble = 11.1;
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(11.1));
	XCTAssertEqual(predicate.itemPriorityInteger, 11);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)11.1);
	
	predicate.itemPriorityDouble = 10;
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(10));
	XCTAssertEqual(predicate.itemPriorityInteger, 10);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)10);
	
	predicate.itemPriorityDouble = 0;
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(0));
	XCTAssertEqual(predicate.itemPriorityInteger, 0);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)0);
	
	predicate.itemPriorityDouble = -10;
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(-10));
	XCTAssertEqual(predicate.itemPriorityInteger, -10);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)-10);
	
	predicate.itemPriorityDouble = -11.1;
	XCTAssertNotEqual(predicate.itemPriority, predicate.defaultItemPriority);
	XCTAssertEqualObjects(predicate.itemPriority, @(-11.1));
	XCTAssertEqual(predicate.itemPriorityInteger, -11);
	XCTAssertEqual(predicate.itemPriorityDouble, (double)-11.1);
}


- (void)testBEPredicateRule_init
{
	NSPredicate *referencePredicate = [NSPredicate predicateWithValue:NO];
	BEPredicateRule *rule = [[BEPredicateRule alloc] init];
	
	XCTAssertEqualObjects(rule.predicate, referencePredicate);
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqual(rule.itemPriority, rule.defaultItemPriority);
	
	XCTAssertEqual(rule.itemPriorityInteger, BEPredicateRuleDefaultPriority);
	XCTAssertEqual(rule.itemPriorityDouble, (double)BEPredicateRuleDefaultPriority);
}

- (void)testBEPredicateRule_initWithPredicate
{
	NSPredicate *referencePredicate = [NSPredicate predicateWithValue:YES];
	BEPredicateRule *rule = [[BEPredicateRule alloc] initWithPredicate:referencePredicate];
	
	XCTAssertEqualObjects(rule.predicate, referencePredicate);
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqual(rule.itemPriority, rule.defaultItemPriority);
}

- (void)testBEPredicateRule_initWithPredicate_Outcome
{
	NSPredicate *referencePredicate = [NSPredicate predicateWithValue:YES];
	BEPredicateRule *rule = [[BEPredicateRule alloc] initWithPredicate:referencePredicate outcome:BEPredicateRuleAccept];
	
	XCTAssertEqualObjects(rule.predicate, referencePredicate);
	XCTAssertEqual(rule.outcome, BEPredicateRuleAccept);
	XCTAssertEqual(rule.itemPriority, rule.defaultItemPriority);
}

- (void)testBEPredicateRule_initWithPredicate_ArrayPriority
{
	NSPredicate *referencePredicate = [NSPredicate predicateWithValue:YES];
	BEPredicateRule *rule = [[BEPredicateRule alloc] initWithPredicate:referencePredicate priority:@(10)];
	
	XCTAssertEqualObjects(rule.predicate, referencePredicate);
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @(10));
}

- (void)testBEPredicateRule_initWithPredicate_ArrayPriorityInteger
{
	NSPredicate *referencePredicate = [NSPredicate predicateWithValue:YES];
	BEPredicateRule *rule = [[BEPredicateRule alloc] initWithPredicate:referencePredicate priorityInteger:7];
	
	XCTAssertEqualObjects(rule.predicate, referencePredicate);
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @(7));
}

- (void)testBEPredicateRule_initWithPredicate_ArrayPriorityDouble
{
	NSPredicate *referencePredicate = [NSPredicate predicateWithValue:YES];
	BEPredicateRule *rule = [[BEPredicateRule alloc] initWithPredicate:referencePredicate priorityDouble:2.3];
	
	XCTAssertEqualObjects(rule.predicate, referencePredicate);
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @(2.3));
}

- (void)testBEPredicateRule_initWithPredicate_ArrayPriority_Outcome
{
	NSPredicate *referencePredicate = [NSPredicate predicateWithValue:YES];
	BEPredicateRule *rule = [[BEPredicateRule alloc] initWithPredicate:referencePredicate outcome:BEPredicateRuleReject priority:@(11)];
	
	XCTAssertEqualObjects(rule.predicate, referencePredicate);
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @(11));
}

- (void)testBEPredicateRule_initWithPredicate_ArrayPriorityInteger_Outcome
{
	NSPredicate *referencePredicate = [NSPredicate predicateWithValue:YES];
	BEPredicateRule *rule = [[BEPredicateRule alloc] initWithPredicate:referencePredicate outcome:BEPredicateRuleAccept priorityInteger:500];
	
	XCTAssertEqualObjects(rule.predicate, referencePredicate);
	XCTAssertEqual(rule.outcome, BEPredicateRuleAccept);
	XCTAssertEqualObjects(rule.itemPriority, @(500));
}

- (void)testBEPredicateRule_initWithPredicate_ArrayPriorityDouble_Outcome
{
	NSPredicate *referencePredicate = [NSPredicate predicateWithValue:YES];
	BEPredicateRule *rule = [[BEPredicateRule alloc] initWithPredicate:referencePredicate outcome:BEPredicateRuleReject priorityDouble:2.1];
	
	XCTAssertEqualObjects(rule.predicate, referencePredicate);
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @(2.1));
}

- (void)testBEPredicateRule_InitWithCoder_and_allowEvaluation
{
	BEPredicateRule	*reference = [BEPredicateRule ruleWithFormat:@"age >= %d" argumentArray:@[@30]];
	
	XCTAssertTrue([BEPredicateRule supportsSecureCoding]);
	NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:reference requiringSecureCoding:YES error:nil];
	XCTAssertNotNil(archivedData);
	BEPredicateRule *result = [NSKeyedUnarchiver unarchivedObjectOfClass:BEPredicateRule.class fromData:archivedData error:nil];
	
	XCTAssertNotNil(result);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertEqual(result.itemPriority, reference.itemPriority);
	
	NSArray *people = @[
			@{@"name": @"Alice", @"age": @30},
			@{@"name": @"Bob", @"age": @40},
			@{@"name": @"Charlie", @"age": @25}
		];
	XCTAssertThrowsSpecificNamed([result evaluateWithObject:people[0]], NSException,
							NSInternalInconsistencyException);

	[result allowEvaluation];
	XCTAssertTrue([result evaluateWithObject:people[1]]);
	XCTAssertFalse([result evaluateWithObject:people[2]]);
}


- (void)testBEPredicateRule_InitWithCoder_nonDefaultPriority
{
	BEPredicateRule	*reference = [BEPredicateRule ruleWithFormat:@"age >= %d" argumentArray:@[@30]];
	reference.itemPriorityInteger = 33;
	
	XCTAssertTrue([BEPredicateRule supportsSecureCoding]);
	NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:reference requiringSecureCoding:YES error:nil];
	XCTAssertNotNil(archivedData);
	BEPredicateRule *result = [NSKeyedUnarchiver unarchivedObjectOfClass:BEPredicateRule.class fromData:archivedData error:nil];
	
	XCTAssertNotNil(result);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertEqual(result.itemPriority, reference.itemPriority);
	
	NSArray *people = @[
			@{@"name": @"Alice", @"age": @30},
			@{@"name": @"Bob", @"age": @40},
			@{@"name": @"Charlie", @"age": @25}
		];
	XCTAssertThrowsSpecificNamed([result evaluateWithObject:people[0]], NSException,
							NSInternalInconsistencyException);

	[result allowEvaluation];
	XCTAssertTrue([result evaluateWithObject:people[1]]);
	XCTAssertFalse([result evaluateWithObject:people[2]]);
}

- (void)testBEPredicateRule_copy
{
	BEPredicateRule	*reference = [BEPredicateRule ruleWithFormat:@"age >= %d" argumentArray:@[@30]];
	
	BEPredicateRule *result = [reference copy];
	XCTAssertNotNil(result);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertEqual(result.itemPriority, reference.itemPriority);
	
	NSArray *people = @[
			@{@"name": @"Alice", @"age": @30},
			@{@"name": @"Bob", @"age": @40},
			@{@"name": @"Charlie", @"age": @25}
		];
	
	XCTAssertTrue([result evaluateWithObject:people[1]]);
	XCTAssertFalse([result evaluateWithObject:people[2]]);
}

- (void)testBEPredicateRule_hash
{
	BEPredicateRule	*reference = [BEPredicateRule ruleWithFormat:@"age >= %d", 30];
	BEPredicateRule	*reference2 = [BEPredicateRule ruleWithFormat:@"age >= %d", 30];
	BEPredicateRule	*reference3 = [BEPredicateRule ruleWithFormat:@"age >= %d", 45];
	
	XCTAssertNotEqual([reference.predicate hash], [reference hash]);
	XCTAssertNotEqual([reference2.predicate hash], [reference2 hash]);
	XCTAssertNotEqual([reference2.predicate hash], [reference hash]);
	
	XCTAssertEqual([reference2 hash], [reference hash]);
	XCTAssertNotEqual([reference3 hash], [reference hash]);
	reference.itemPriorityInteger = 0;
	reference2.itemPriorityInteger = 1;
	XCTAssertEqual([reference2 hash], [reference hash]);
	
	reference.isUniqueItemPriority = true;
	XCTAssertNotEqual([reference2 hash], [reference hash]);
	reference2.isUniqueItemPriority = true;
	XCTAssertNotEqual([reference2 hash], [reference hash]);
	
	reference.isUniqueItemPriority = false;
	reference2.isUniqueItemPriority = false;
	XCTAssertEqual([reference2 hash], [reference hash]);
	
	reference2.itemPriorityInteger = 0;
	XCTAssertEqual([reference2 hash], [reference hash]);
	
	reference2.outcome = BEPredicateRuleAccept;
	XCTAssertNotEqual([reference2 hash], [reference hash]);
	
	reference.outcome = BEPredicateRuleAccept;
	XCTAssertEqual([reference2 hash], [reference hash]);
	
	
	
}


- (void)testBEPredicateRule_isEqual
{
	BEPredicateRule	*reference = [BEPredicateRule ruleWithFormat:@"age >= %d", 30];
	BEPredicateRule	*reference2 = [BEPredicateRule ruleWithFormat:@"age >= %d", 30];
	BEPredicateRule	*reference3 = [BEPredicateRule ruleWithFormat:@"age >= %d", 45];
	
	XCTAssertTrue([reference isEqual:reference]);
	XCTAssertFalse([reference isEqual:NSObject.new]);
	XCTAssertTrue([reference2 isEqual:reference]);
	XCTAssertFalse([reference3 isEqual:reference]);
	
	reference2.itemPriorityInteger = 100;
	XCTAssertTrue([reference2 isEqual:reference]);
	
	reference2.isUniqueItemPriority = true;
	XCTAssertFalse([reference2 isEqual:reference]);
	reference.isUniqueItemPriority = true;
	XCTAssertFalse([reference2 isEqual:reference]);
	reference2.isUniqueItemPriority = false;
	XCTAssertFalse([reference2 isEqual:reference]);
	reference.isUniqueItemPriority = false;
	XCTAssertTrue([reference2 isEqual:reference]);
	
	reference2.outcome = BEPredicateRuleAccept;
	XCTAssertFalse([reference2 isEqual:reference]);
	
	reference.outcome = BEPredicateRuleAccept;
	XCTAssertTrue([reference2 isEqual:reference]);
}


- (void)testBEPredicateRule_ruleWithSubstitutionVariables
{
	BEPredicateRule	*reference = [BEPredicateRule ruleWithFormat:@"age >= $AGE" argumentArray:@[@30]];
	
	NSDictionary *substitutions = @{@"AGE": @30};
	
	// ruleWithSubstitutionVariables uses substitutePredicateVariables to solidify and replace its predicate
	BEPredicateRule *result = [reference ruleWithSubstitutionVariables:substitutions];
	
	XCTAssertNotNil(result);
	XCTAssertEqualObjects(result.predicateFormat, @"age >= 30");
	XCTAssertEqual(result.outcome, reference.outcome);
	XCTAssertEqualObjects(result.itemPriority, reference.itemPriority);
	
	NSDictionary *person1 = @{@"age": @30, @"name": @"Alice"};
	XCTAssertTrue([result evaluateWithObject:person1]);
	
	NSDictionary *person2 = @{@"age": @29, @"name": @"Bob"};
	XCTAssertFalse([result evaluateWithObject:person2]);
}


- (void)testBEPredicateRule_evaluateWithObject
{
	BEPredicateRule	*rule = [BEPredicateRule ruleWithFormat:@"age >= 30" argumentArray:nil];
	
	NSDictionary *person1 = @{@"age": @30, @"name": @"Alice"};
	XCTAssertTrue([rule evaluateWithObject:person1]);
	
	NSDictionary *person2 = @{@"age": @29, @"name": @"Bob"};
	XCTAssertFalse([rule evaluateWithObject:person2]);
}

- (void)testBEPredicateRule_evaluateWithObject_substitutionVariables
{
	BEPredicateRule	*rule = [BEPredicateRule ruleWithFormat:@"age >= $AGE" argumentArray:nil];
	
	NSDictionary *person1 = @{@"age": @30, @"name": @"Alice"};
	XCTAssertTrue([rule evaluateWithObject:person1 substitutionVariables:@{@"AGE": @30}]);
	
	XCTAssertFalse([rule evaluateWithObject:person1 substitutionVariables:@{@"AGE": @31}]);
}

#pragma mark - Class Constructors

- (void)testBEPredicateRule_ruleWithFormat
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:@"age >= %d", 29];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 29");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, rule.defaultItemPriority);
	
	NSDictionary *person29 = @{@"NAME": @"Alice", @"age": @29};
	NSDictionary *person25 = @{@"NAME": @"Bob", @"age": @25};
	
	XCTAssertTrue([rule evaluateWithObject:person29]);
	XCTAssertFalse([rule evaluateWithObject:person25]);
}

- (void)testBEPredicateRule_ruleWithOutcome_Format
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age >= %d", 28];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 28");
	XCTAssertEqual(rule.outcome, BEPredicateRuleAccept);
	XCTAssertEqualObjects(rule.itemPriority, rule.defaultItemPriority);
}

- (void)testBEPredicateRule_ruleWithPriority_Format
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithPriority:@10 format:@"age >= %d", 27];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 27");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @10);
}

- (void)testBEPredicateRule_ruleWithPriorityInteger_Format
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithPriorityInteger:10 format:@"age >= %d", 26];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 26");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @10);
}

- (void)testBEPredicateRule_ruleWithPriorityDouble_Format
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithPriorityDouble:2.3 format:@"age >= %d", 25];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 25");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @2.3);
}


- (void)testBEPredicateRule_ruleWithOutcome_Priority_Format
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject priority:@10 format:@"age >= %d", 24];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 24");
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @10);
}

- (void)testBEPredicateRule_ruleWithOutcome_PriorityInteger_Format
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject priorityInteger:10 format:@"age >= %d", 23];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 23");
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @10);
}

- (void)testBEPredicateRule_ruleWithOutcome_PriorityDouble_Format
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject priorityDouble:2.1 format:@"age >= %d", 22];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 22");
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @2.1);
}


// predicateFormat argumentArray

- (void)testBEPredicateRule_ruleWithFormat_argumentArray
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:@"age >= %d" argumentArray:@[@21]];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 21");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, rule.defaultItemPriority);
}

- (void)testBEPredicateRule_ruleWithFormat_argumentArray_Outcome
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:@"age >= %d" argumentArray:@[@31] outcome:BEPredicateRuleAccept];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 31");
	XCTAssertEqual(rule.outcome, BEPredicateRuleAccept);
	XCTAssertEqualObjects(rule.itemPriority, rule.defaultItemPriority);
}

- (void)testBEPredicateRule_ruleWithFormat_argumentArray_Priority
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:@"age >= %d" argumentArray:@[@32] priority:@15];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 32");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @15);
}

- (void)testBEPredicateRule_ruleWithFormat_argumentArray_PriorityInteger
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:@"age >= %d" argumentArray:@[@33] priorityInteger:10];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 33");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @10);
}

- (void)testBEPredicateRule_ruleWithFormat_argumentArray_PriorityDouble
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:@"age >= %d" argumentArray:@[@34] priorityDouble:2.4];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 34");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @2.4);
}


- (void)testBEPredicateRule_ruleWithFormat_argumentArray_Outcome_Priority_
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:@"age >= %d" argumentArray:@[@35] outcome:BEPredicateRuleReject priority:@10];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 35");
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @10);
}

- (void)testBEPredicateRule_ruleWithFormat_argumentArray_Outcome_PriorityInteger
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:@"age >= %d" argumentArray:@[@36] outcome:BEPredicateRuleReject priorityInteger:10];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 36");
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @10);
}

- (void)testBEPredicateRule_ruleWithFormat_argumentArray_Outcome_PriorityDouble_
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:@"age >= %d" argumentArray:@[@37] outcome:BEPredicateRuleReject priorityDouble:2.5];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 37");
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @2.5);
}


// predicateFormat arguments

- (BEPredicateRule*)ruleWithType:(int)type outcome:(BEPredicateRuleOutcome)outcome priority:(NSNumber*)priority format:(NSString*)format, ...
{
	va_list args;
	va_start(args, format);
	
	BEPredicateRule *rule;
	switch(type) {
		case 0:
			rule = [BEPredicateRule ruleWithFormat:@"age >= %d" arguments:args];
			break;
		case 1:
			rule = [BEPredicateRule ruleWithFormat:@"age >= %d" arguments:args outcome:outcome];
			break;
		case 2:
			rule = [BEPredicateRule ruleWithFormat:@"age >= %d" arguments:args priority:priority];
			break;
		case 3:
			rule = [BEPredicateRule ruleWithFormat:@"age >= %d" arguments:args priorityInteger:priority.integerValue];
			break;
		case 4:
			rule = [BEPredicateRule ruleWithFormat:@"age >= %d" arguments:args priorityDouble:priority.doubleValue];
			break;
		case 5:
			rule = [BEPredicateRule ruleWithFormat:@"age >= %d" arguments:args outcome:outcome priority:priority];
			break;
		case 6:
			rule = [BEPredicateRule ruleWithFormat:@"age >= %d" arguments:args outcome:outcome priorityInteger:priority.integerValue];
			break;
		case 7:
			rule = [BEPredicateRule ruleWithFormat:@"age >= %d" arguments:args outcome:outcome priorityDouble:priority.doubleValue];
			break;
			
	}
	
	va_end(args);
	
	return rule;
}

- (void)testBEPredicateRule_ruleWithFormat_arguments
{
	BEPredicateRule *rule = [self ruleWithType:0 outcome:10 priority:@1 format:@"age >= @d", 38];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 38");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, rule.defaultItemPriority);
}

- (void)testBEPredicateRule_ruleWithFormat_arguments_Outcome
{
	BEPredicateRule *rule = [self ruleWithType:1 outcome:BEPredicateRuleAccept priority:@1 format:@"age >= @d", 39];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 39");
	XCTAssertEqual(rule.outcome, BEPredicateRuleAccept);
	XCTAssertEqualObjects(rule.itemPriority, rule.defaultItemPriority);
}

- (void)testBEPredicateRule_ruleWithFormat_arguments_Priority
{
	BEPredicateRule *rule = [self ruleWithType:2 outcome:BEPredicateRuleAccept priority:@10 format:@"age >= @d", 40];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 40");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @10);
}

- (void)testBEPredicateRule_ruleWithFormat_arguments_PriorityInteger
{
	BEPredicateRule *rule = [self ruleWithType:3 outcome:BEPredicateRuleAccept priority:@11 format:@"age >= @d", 41];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 41");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @11);
}

- (void)testBEPredicateRule_ruleWithFormat_arguments_PriorityDouble
{
	BEPredicateRule *rule = [self ruleWithType:4 outcome:BEPredicateRuleAccept priority:@11.8 format:@"age >= @d", 42];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 42");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @11.8);
}


- (void)testBEPredicateRule_ruleWithFormat_arguments_Outcome_Priority
{
	BEPredicateRule *rule = [self ruleWithType:5 outcome:BEPredicateRuleReject priority:@12 format:@"age >= @d", 43];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 43");
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @12);
}

- (void)testBEPredicateRule_ruleWithFormat_arguments_Outcome_PriorityInteger
{
	BEPredicateRule *rule = [self ruleWithType:6 outcome:BEPredicateRuleReject priority:@13 format:@"age >= @d", 44];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 44");
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @13);
}

- (void)testBEPredicateRule_ruleWithFormat_arguments_Outcome_PriorityDouble
{
	BEPredicateRule *rule = [self ruleWithType:7 outcome:BEPredicateRuleReject priority:@14.4 format:@"age >= @d", 45];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"age >= 45");
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @14.4);
}



// ruleWithValue

- (void)testBEPredicateRule_ruleWithValue
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithValue:YES];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"TRUEPREDICATE");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, rule.defaultItemPriority);
}

- (void)testBEPredicateRule_ruleWithValue_Outcome
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithValue:NO outcome:BEPredicateRuleAccept];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"FALSEPREDICATE");
	XCTAssertEqual(rule.outcome, BEPredicateRuleAccept);
	XCTAssertEqualObjects(rule.itemPriority, rule.defaultItemPriority);
}

- (void)testBEPredicateRule_ruleWithValue_Priority
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithValue:NO priority:@45];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"FALSEPREDICATE");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @45);
}

- (void)testBEPredicateRule_ruleWithValue_PriorityInteger
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithValue:YES priorityInteger:46];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"TRUEPREDICATE");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @46);
}

- (void)testBEPredicateRule_ruleWithValue_PriorityDouble
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithValue:YES priorityDouble:46.5];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"TRUEPREDICATE");
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @46.5);
}


- (void)testBEPredicateRule_ruleWithValue_Outcome_Priority
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithValue:YES outcome:BEPredicateRuleReject priority:@50];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"TRUEPREDICATE");
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @50);
}

- (void)testBEPredicateRule_ruleWithValue_Outcome_PriorityInteger
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithValue:YES outcome:BEPredicateRuleAccept priorityInteger:51];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"TRUEPREDICATE");
	XCTAssertEqual(rule.outcome, BEPredicateRuleAccept);
	XCTAssertEqualObjects(rule.itemPriority, @51);
}

- (void)testBEPredicateRule_ruleWithValue_Outcome_PriorityDouble
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithValue:NO outcome:BEPredicateRuleReject priorityDouble:52.1];
	
	XCTAssertEqualObjects(rule.predicateFormat, @"FALSEPREDICATE");
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, @52.1);
}



// ruleWithBlock

- (void)testBEPredicateRule_ruleWithBlock
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		if(![evaluatedObject isKindOfClass:NSDictionary.class])
			return NO;
		return [evaluatedObject[@"return"] boolValue];
	}];
	
	XCTAssertTrue([rule.predicateFormat hasPrefix:@"BLOCKPREDICATE"]);
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, rule.defaultItemPriority);
}

- (void)testBEPredicateRule_ruleWithOutcome_Block
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject block:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		if(![evaluatedObject isKindOfClass:NSDictionary.class])
			return NO;
		return [evaluatedObject[@"return"] boolValue];
	}];
	
	XCTAssertTrue([rule.predicateFormat hasPrefix:@"BLOCKPREDICATE"]);
	XCTAssertEqual(rule.outcome, BEPredicateRuleReject);
	XCTAssertEqualObjects(rule.itemPriority, rule.defaultItemPriority);
}

- (void)testBEPredicateRule_ruleWithPriority_Block
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithPriority:@100 block:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		if(![evaluatedObject isKindOfClass:NSDictionary.class])
			return NO;
		return [evaluatedObject[@"return"] boolValue];
	}];
	
	XCTAssertTrue([rule.predicateFormat hasPrefix:@"BLOCKPREDICATE"]);
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @100);
}

- (void)testBEPredicateRule_ruleWithPriorityInteger_Block
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithPriorityInteger:101 block:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		if(![evaluatedObject isKindOfClass:NSDictionary.class])
			return NO;
		return [evaluatedObject[@"return"] boolValue];
	}];
	
	XCTAssertTrue([rule.predicateFormat hasPrefix:@"BLOCKPREDICATE"]);
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @101);
}

- (void)testBEPredicateRule_ruleWithPriorityDouble_Block
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithPriorityDouble:99.9 block:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		if(![evaluatedObject isKindOfClass:NSDictionary.class])
			return NO;
		return [evaluatedObject[@"return"] boolValue];
	}];
	
	XCTAssertTrue([rule.predicateFormat hasPrefix:@"BLOCKPREDICATE"]);
	XCTAssertEqual(rule.outcome, BEPredicateRuleNA);
	XCTAssertEqualObjects(rule.itemPriority, @99.9);
}


- (void)testBEPredicateRule_ruleWithOutcome_Priority_Block
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept priority:@80 block:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		if(![evaluatedObject isKindOfClass:NSDictionary.class])
			return NO;
		return [evaluatedObject[@"return"] boolValue];
	}];
	
	XCTAssertTrue([rule.predicateFormat hasPrefix:@"BLOCKPREDICATE"]);
	XCTAssertEqual(rule.outcome, BEPredicateRuleAccept);
	XCTAssertEqualObjects(rule.itemPriority, @80);
}

- (void)testBEPredicateRule_ruleWithOutcome_PriorityInteger_Block
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept priorityInteger:81 block:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		if(![evaluatedObject isKindOfClass:NSDictionary.class])
			return NO;
		return [evaluatedObject[@"return"] boolValue];
	}];
	
	XCTAssertTrue([rule.predicateFormat hasPrefix:@"BLOCKPREDICATE"]);
	XCTAssertEqual(rule.outcome, BEPredicateRuleAccept);
	XCTAssertEqualObjects(rule.itemPriority, @81);
}

- (void)testBEPredicateRule_ruleWithOutcome_PriorityDouble_Block
{
	BEPredicateRule *rule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept priorityDouble:81.1 block:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		if(![evaluatedObject isKindOfClass:NSDictionary.class])
			return NO;
		return [evaluatedObject[@"return"] boolValue];
	}];
	
	XCTAssertTrue([rule.predicateFormat hasPrefix:@"BLOCKPREDICATE"]);
	XCTAssertEqual(rule.outcome, BEPredicateRuleAccept);
	XCTAssertEqualObjects(rule.itemPriority, @81.1);
}


#pragma mark - NSArray ruleOutcomeWithObject

- (void)testNSArray_ruleOutcomeWithObject
{
	NSDictionary *child = @{@"name": @"Alice", @"age": @17};
	NSDictionary *adult = @{@"name": @"Bob", @"age": @21};
	NSDictionary *middleAge = @{@"name": @"Bob", @"age": @30};
	NSDictionary *elder = @{@"name": @"Bob", @"age": @65};
	
	BEPredicateRule *olderRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age >= 65"];
	BEPredicateRule *adultRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age < 65"];
	BEPredicateRule *equalRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject format:@"age = 30"];
	BEPredicateRule *youngerRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject format:@"age < 18"];
	
	NSArray *rules = @[youngerRule, olderRule, equalRule, adultRule];
	
	XCTAssertEqual([rules ruleOutcomeWithObject:child], BEPredicateRuleReject);
	XCTAssertEqual([rules ruleOutcomeWithObject:adult], BEPredicateRuleAccept);
	XCTAssertEqual([rules ruleOutcomeWithObject:middleAge], BEPredicateRuleReject);
	equalRule.itemPriorityInteger = 10;
	XCTAssertEqual([rules ruleOutcomeWithObject:middleAge], BEPredicateRuleAccept);
	XCTAssertEqual([rules ruleOutcomeWithObject:elder], BEPredicateRuleAccept);
	
	rules = @[];
	XCTAssertEqual([rules ruleOutcomeWithObject:child], BEPredicateRuleNA);
}

- (void)testNSArray_ruleOutcomeWithObject_substitution
{
	NSDictionary *person = @{@"name": @"Alice", @"age": @20};
	
	BEPredicateRule *olderRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age > $AGE"];
	BEPredicateRule *equalRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age = $AGE2"];
	BEPredicateRule *youngerRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject format:@"age < $AGE3"];
	
	NSArray *rules = @[NSObject.new, olderRule, equalRule, youngerRule];
	
	NSDictionary *bindings = @{@"AGE": @30, @"AGE2": @20, @"AGE3": @30};
	NSDictionary *bindings2 = @{@"AGE": @30, @"AGE2": @21, @"AGE3": @30};
	
	XCTAssertEqual([rules ruleOutcomeWithObject:person substitutionVariables:bindings], BEPredicateRuleAccept);
	equalRule.itemPriorityInteger = 10; //change order
	XCTAssertEqual([rules ruleOutcomeWithObject:person substitutionVariables:bindings], BEPredicateRuleReject);
	equalRule.itemPriority = nil;
	XCTAssertEqual([rules ruleOutcomeWithObject:person substitutionVariables:bindings2], BEPredicateRuleReject);
}


#pragma mark - NSSet predicateOutcomeWithObject

- (void)testNSSet_ruleOutcomeWithObject
{
	NSDictionary *child = @{@"name": @"Alice", @"age": @17};
	NSDictionary *adult = @{@"name": @"Bob", @"age": @21};
	NSDictionary *middleAge = @{@"name": @"Bob", @"age": @30};
	NSDictionary *elder = @{@"name": @"Bob", @"age": @65};
	
	BEPredicateRule *olderRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age >= 65"];
	BEPredicateRule *adultRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age < 65 && age >= 18"];
	BEPredicateRule *equalRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject priorityInteger:-1 format:@"age = 30"];
	BEPredicateRule *youngerRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject format:@"age < 18"];
	
	NSSet *rules = [NSSet setWithArray:@[NSObject.new, youngerRule, olderRule, equalRule, adultRule]];
	
	XCTAssertEqual([rules ruleOutcomeWithObject:child], BEPredicateRuleReject);
	XCTAssertEqual([rules ruleOutcomeWithObject:adult], BEPredicateRuleAccept);
	XCTAssertEqual([rules ruleOutcomeWithObject:middleAge], BEPredicateRuleReject);
	equalRule.itemPriorityInteger = 10;
	XCTAssertEqual([rules ruleOutcomeWithObject:middleAge], BEPredicateRuleAccept);
	XCTAssertEqual([rules ruleOutcomeWithObject:elder], BEPredicateRuleAccept);
	
	rules = [NSSet setWithArray:@[]];
	XCTAssertEqual([rules ruleOutcomeWithObject:child], BEPredicateRuleNA);
}

- (void)testNSSet_ruleOutcomeWithObject_substitution
{
	NSDictionary *person = @{@"name": @"Alice", @"age": @20};
	
	BEPredicateRule *olderRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age > $AGE"];
	BEPredicateRule *equalRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept priorityInteger:-1 format:@"age = $AGE2"];
	BEPredicateRule *youngerRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject format:@"age < $AGE3"];
	
	NSSet *rules = [NSSet setWithArray:@[NSObject.new, olderRule, equalRule, youngerRule]];
	
	NSDictionary *bindings = @{@"AGE": @30, @"AGE2": @20, @"AGE3": @30};
	NSDictionary *bindings2 = @{@"AGE": @30, @"AGE2": @21, @"AGE3": @30};
	
	XCTAssertEqual([rules ruleOutcomeWithObject:person substitutionVariables:bindings], BEPredicateRuleAccept);
	equalRule.itemPriorityInteger = 10; //change order
	XCTAssertEqual([rules ruleOutcomeWithObject:person substitutionVariables:bindings], BEPredicateRuleReject);
	equalRule.itemPriority = nil;
	XCTAssertEqual([rules ruleOutcomeWithObject:person substitutionVariables:bindings2], BEPredicateRuleReject);
}


#pragma mark - NSOrderedSet ruleOutcomeWithObject

- (void)testNSOrderedSet_ruleOutcomeWithObject
{
	NSDictionary *child = @{@"name": @"Alice", @"age": @17};
	NSDictionary *adult = @{@"name": @"Bob", @"age": @21};
	NSDictionary *middleAge = @{@"name": @"Bob", @"age": @30};
	NSDictionary *elder = @{@"name": @"Bob", @"age": @65};
	
	BEPredicateRule *olderRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age >= 65"];
	BEPredicateRule *adultRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age < 65"];
	BEPredicateRule *equalRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject format:@"age = 30"];
	BEPredicateRule *youngerRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject format:@"age < 18"];
	
	NSOrderedSet *rules = [NSOrderedSet orderedSetWithArray:@[NSObject.new, youngerRule, olderRule, equalRule, adultRule]];
	
	XCTAssertEqual([rules ruleOutcomeWithObject:child], BEPredicateRuleReject);
	XCTAssertEqual([rules ruleOutcomeWithObject:adult], BEPredicateRuleAccept);
	XCTAssertEqual([rules ruleOutcomeWithObject:middleAge], BEPredicateRuleReject);
	equalRule.itemPriorityInteger = 10;
	XCTAssertEqual([rules ruleOutcomeWithObject:middleAge], BEPredicateRuleAccept);
	XCTAssertEqual([rules ruleOutcomeWithObject:elder], BEPredicateRuleAccept);
	
	rules = [NSOrderedSet orderedSetWithArray:@[]];
	XCTAssertEqual([rules ruleOutcomeWithObject:child], BEPredicateRuleNA);
}

- (void)testNSOrderedSet_ruleOutcomeWithObject_substitution
{
	NSDictionary *person = @{@"name": @"Alice", @"age": @20};
	
	BEPredicateRule *olderRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age > $AGE"];
	BEPredicateRule *equalRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept format:@"age = $AGE2"];
	BEPredicateRule *youngerRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject format:@"age < $AGE3"];
	
	NSOrderedSet *rules = [NSOrderedSet orderedSetWithArray:@[NSObject.new, olderRule, equalRule, youngerRule]];
	
	NSDictionary *bindings = @{@"AGE": @30, @"AGE2": @20, @"AGE3": @30};
	NSDictionary *bindings2 = @{@"AGE": @30, @"AGE2": @21, @"AGE3": @30};
	
	XCTAssertEqual([rules ruleOutcomeWithObject:person substitutionVariables:bindings], BEPredicateRuleAccept);
	equalRule.itemPriorityInteger = 10; //change order
	XCTAssertEqual([rules ruleOutcomeWithObject:person substitutionVariables:bindings], BEPredicateRuleReject);
	equalRule.itemPriority = nil;
	XCTAssertEqual([rules ruleOutcomeWithObject:person substitutionVariables:bindings2], BEPredicateRuleReject);
}

@end
