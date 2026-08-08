# ``BEPredicateRule``

Predicate evaluation with accept/reject/NA outcomes and priority ordering.

```objc
#import <BEFoundation/BEPredicateRule.h>
```

## Overview

[BEPredicateRule](doc:BEPredicateRule) extends `NSPredicate` with outcomes (accept, reject, NA) and priority ordering. It allows evaluation of objects against a collection of rules, returning the outcome of the first matching rule by priority.

![A flow of rules evaluated in ascending priority order, where the first rule that matches with a non-N/A outcome decides accept or reject, otherwise the result is N/A.](bepredicaterule-flow)

## Usage

### Creating Rules

```objc
// Create a rule with format
BEPredicateRule *rule = [BEPredicateRule ruleWithFormat:@"self > %@", @5];

// Create with outcome
BEPredicateRule *acceptRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept
                                                       format:@"self.stringValue.length > 0"];

BEPredicateRule *rejectRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject
                                                       format:@"self.isEmpty == YES"];

// Create with priority
BEPredicateRule *priorityRule = [BEPredicateRule ruleWithPriorityInteger:10
                                                                format:@"self.type == %@", @"special"];
```

### Rule Outcomes

```objc
typedef NSInteger BEPredicateRuleOutcome;

enum {
    BEPredicateRuleReject = -1,  // Rule matched and rejected
    BEPredicateRuleNA = 0,       // Rule did not match
    BEPredicateRuleAccept = 1,   // Rule matched and accepted
};
```

### Evaluating Rules

```objc
BEPredicateRule *rule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept
                                                 format:@"self > %@", @5];

// Evaluate against an object
id object = @10;
BOOL matches = [rule evaluateWithObject:object];
// Returns YES if predicate matches
```

### Rule Sets

```objc
// Create array of rules
NSArray *rules = @[
    [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject 
                            priority:@1 
                             format:@"self.isBlocked == YES"],
    [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept 
                            priority:@2 
                             format:@"self.isValid == YES"],
    [BEPredicateRule ruleWithOutcome:BEPredicateRuleReject 
                            priority:@3 
                             format:@"self.isRestricted == YES"],
];

// Evaluate object against all rules
// Returns outcome of first matching rule (by lowest priority number)
BEPredicateRuleOutcome outcome = [rules ruleOutcomeWithObject:someObject];
```

### Block-Based Rules

```objc
BEPredicateRule *blockRule = [BEPredicateRule ruleWithOutcome:BEPredicateRuleAccept
                                                        block:^BOOL(id object, NSDictionary *bindings) {
    return [object count] > 0;
}];
```

## See Also

- [BEPriorityExtensions](doc:BEPriorityExtensions)
