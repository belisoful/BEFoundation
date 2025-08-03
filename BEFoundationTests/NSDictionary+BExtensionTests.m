//
//  NSDictionary+BExtension.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import <BEFoundation/NSDictionary+BExtension.h>

@interface NSDictionaryBExtensionTests : XCTestCase

@property (nonatomic, strong, readonly) NSString *expectedValueOne;
@property (nonatomic, strong, readonly) NSString *expectedValueTwo;
@property (nonatomic, strong, readonly) NSString *expectedValueThree;
@property (nonatomic, strong, readonly) NSString *expectedValueFour;

@end
#pragma mark NSDictionary BExtension Tests

@implementation NSDictionaryBExtensionTests


- (NSString *)expectedValueOne {
	return @"One";
}

- (NSString *)expectedValueTwo {
	return @"Two";
}

- (NSString *)expectedValueThree {
	return @"Three";
}

- (NSString *)expectedValueFour {
	return @"Four";
}


- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


#pragma mark - NSDictionary: Indexed Key Subscript

- (void)testNSDictionary_ObjectAtIndexedSubscript_WithIntegerKey {
	// Create a dictionary with integer keys (NSNumber objects)
	NSDictionary *dict = @{ @(1) : self.expectedValueOne, @(2) : self.expectedValueTwo, @(3) : self.expectedValueThree };
	
	// Test accessing using the objectAtIndexedSubscript
	XCTAssertEqualObjects([dict objectAtIndexedSubscript:1], self.expectedValueOne, @"The object for key 1 should be %@", self.expectedValueOne);
	XCTAssertEqualObjects([dict objectAtIndexedSubscript:2], self.expectedValueTwo, @"The object for key 2 should be %@", self.expectedValueTwo);
	XCTAssertEqualObjects([dict objectAtIndexedSubscript:3], self.expectedValueThree, @"The object for key 3 should be %@", self.expectedValueThree);
}

- (void)testNSDictionary_ObjectAtIndexedSubscript_WithStringKey {
	// Create a dictionary with string keys
	NSDictionary *dict = @{ @"1" : self.expectedValueOne, @"2" : self.expectedValueTwo, @"3" : self.expectedValueThree };
	
	// Test accessing using the objectAtIndexedSubscript
	XCTAssertEqualObjects([dict objectAtIndexedSubscript:1], self.expectedValueOne, @"The object for key 1 (as NSNumber) should be %@", self.expectedValueOne);
	XCTAssertEqualObjects([dict objectAtIndexedSubscript:2], self.expectedValueTwo, @"The object for key 2 (as NSNumber) should be %@", self.expectedValueTwo);
	XCTAssertEqualObjects([dict objectAtIndexedSubscript:3], self.expectedValueThree, @"The object for key 3 (as NSNumber) should be %@", self.expectedValueThree);
}

- (void)testNSDictionary_ObjectAtIndexedSubscript_WithInvalidIndex {
	// Create a dictionary with numeric keys
	NSDictionary *dict = @{ @(1) : self.expectedValueOne, @(2) : self.expectedValueTwo, @(3) : self.expectedValueThree };
	
	// Test an invalid index (key not present)
	XCTAssertNil([dict objectAtIndexedSubscript:4], @"There should be no object for key 4.");
	XCTAssertNil([dict objectAtIndexedSubscript:999], @"There should be no object for key 999.");
}

- (void)testNSDictionary_ObjectAtIndexedSubscript_WithEmptyDictionary {
	// Create an empty dictionary
	NSDictionary *dict = @{};
	
	// Test with an empty dictionary
	XCTAssertNil([dict objectAtIndexedSubscript:0], @"An empty dictionary should return nil.");
}

- (void)testNSDictionary_ObjectAtIndexedSubscript_WithMixedTypeKeys {
	// Create a dictionary with both NSNumber and NSString keys
	NSDictionary *dict = @{ @(1) : self.expectedValueOne, @"2" : self.expectedValueTwo, @(3) : self.expectedValueThree, @"4" : self.expectedValueFour };
	
	// Test accessing NSNumber keys
	XCTAssertEqualObjects([dict objectAtIndexedSubscript:1], self.expectedValueOne, @"The object for key 1 (NSNumber) should be %@", self.expectedValueOne);
	XCTAssertEqualObjects([dict objectAtIndexedSubscript:3], self.expectedValueThree, @"The object for key 3 (NSNumber) should be %@", self.expectedValueThree);
	
	// Test accessing NSString keys (as numeric strings)
	XCTAssertEqualObjects([dict objectAtIndexedSubscript:2], self.expectedValueTwo, @"The object for key 2 (NSNumber) should be %@", self.expectedValueTwo);
	XCTAssertEqualObjects([dict objectAtIndexedSubscript:4], self.expectedValueFour, @"The object for key 4 (NSNumber) should be %@", self.expectedValueFour);
}

- (void)testNSDictionary_ObjectAtIndexedSubscript_WithNonNumericStringKey {
	// Create a dictionary with non-numeric string keys
	NSDictionary *dict = @{ @"alpha" : @"A", @"beta" : @"B" };
	
	// Test with non-numeric string keys (should not match via numeric index)
	XCTAssertNil([dict objectAtIndexedSubscript:0], @"No object should be found for key 0.");
	XCTAssertNil([dict objectAtIndexedSubscript:1], @"No object should be found for key 1.");
}

- (void)testNSDictionary_ObjectAtIndexedSubscript_Performance {
	// Performance test for large dataset
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	// Add a large number of items
	for (NSUInteger i = 0; i < 100000; i++) {
		dict[@(i)] = [NSString stringWithFormat:@"Object %lu", (unsigned long)i];
	}
	
	[self measureBlock:^{
		// Access several items from the dictionary
		for (NSUInteger i = 0; i < 100000; i++) {
			[dict objectAtIndexedSubscript:i];
		}
	}];
}



#pragma mark MapWithBlock Correctness Tests

- (void)testNSDictionary_MapWithBlock_TransformsElements
{
	NSDictionary *input = @{@"A": @1, @"B": @2, @"C": @3};
	
	NSDictionary *result = [input mapUsingBlock:^BOOL(id * _Nonnull key, id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
		*obj = @([*obj integerValue] * 2);
		return YES;
	}];
	XCTAssertTrue([result isKindOfClass:NSDictionary.class]);
	XCTAssertEqual(result.count, 3);
	
	NSDictionary *reference = @{@"A": @2, @"B": @4, @"C": @6};
	XCTAssertEqualObjects(result, reference);
	
}



- (void)testNSDictionary_MapWithBlock_HandlesEmptySet {
	NSDictionary *input = [NSDictionary dictionary];
	
	// Both synchronous and concurrent tests for empty set
	NSDictionary *result = [input mapUsingBlock:^BOOL(id * _Nonnull key, id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
		*obj = @([*obj integerValue] * 2);
		return YES;
	}];
	XCTAssertTrue([result isKindOfClass:NSDictionary.class]);
	XCTAssertEqual(result.count, 0);
}

- (void)testNSDictionary_MapWithBlock_HandlesNilElementsGracefully_Synchronous {
	NSDictionary *input = @{@"A": @"1", @"B": [NSNull null], @"C": @"3", @"D": @"test"};
	
	// Test synchronous behavior (no NSEnumerationConcurrent)
	NSDictionary *result = [input mapUsingBlock:^BOOL(id * _Nonnull key, id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
		if (*obj == [NSNull null]) {
			return [NSNull null];  // Return nil for the NSNull element
		}
		if (![*obj integerValue]) {
			return nil;
		}
		*obj = @([*obj integerValue] * 2);
		return YES;
	}];
	
	NSDictionary *reference = @{@"A": @2, @"B": [NSNull null], @"C": @6};
	XCTAssertEqualObjects(result, reference);
	XCTAssertEqual(result.count, 3);
}


- (void)testNSDictionary_MapWithBlock_WithNilBlock {
	NSDictionary *input = @{@"A": @1, @"B": @2, @"C": @3};
	
	// Test both synchronous and concurrent with a nil block
	NSDictionary *result = [input mapUsingBlock:nil];
	XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
	XCTAssertNotNil(result);
	XCTAssertEqual(result.count, 3);
}


- (void)testNSDictionary_MapWithBlock_Performance {
	NSMutableDictionary *largeInput = [NSMutableDictionary dictionary];
	for (NSInteger i = 0; i < 100000; i++) {
		NSString *str = [NSString stringWithFormat:@"%ld", (long)i];
		[largeInput setObject:str forKey:str];
	}
	
	NSDictionary *input = largeInput.copy;
	// Measure performance for large input with synchronous processing
	[self measureBlock:^{
		[input mapUsingBlock:^BOOL(id * _Nonnull key, id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
	}];
}





#pragma mark objectsClasses Tests

- (void)testNSArray_ObjectsClasses_Correctness {
	{ // object classes
		NSDictionary *input = @{@0: @"NSObject", @1: @"NSNumber", @2: @11, @3: @[@1, @2], @4: [NSNull null], @5: @{@"A": @1, @"B": @2}};
		
		// Map to Class objects
		NSDictionary *result = [input objectsClasses];
		
		
		NSDictionary *reference = @{@0: @"NSObject".class, @1: @"NSNumber".class, @2: @(11).class, @3: @[@1, @2].class, @4: [NSNull null].class, @5: @{@"A": @1, @"B": @2}.class};
		
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSDictionary *input = @{};
		
		NSDictionary *result = [input objectsClasses];
		
		NSDictionary *reference = @{};
		// An empty set should return an empty set
		XCTAssertEqualObjects(result, reference);
	}
}


#pragma mark objectsClassNames Tests

- (void)testNSArray_ObjectsClassNames_Correctness {
	{ // object classes
		NSDictionary *input = @{@0: @"NSObject", @1: @"NSNumber", @2: @11, @3: @[@1, @2], @4: [NSNull null], @5: @{@"A": @1, @"B": @2}};
		
		// Map to Class objects
		NSDictionary *result = [input objectsClassNames];
		
		
		NSDictionary *reference = @{@0: @"NSObject".className, @1: @"NSNumber".className, @2: @(11).className, @3: @[@1, @2].className, @4: [NSNull null].className, @5: @{@"A": @1, @"B": @2}.className};
		// Verify that each element has been converted to the correct Class object
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSDictionary *input = @{};
		
		NSDictionary *result = [input objectsClassNames];
		
		NSDictionary *reference = @{};
		
		// An empty set should return an empty set
		XCTAssertEqual(result.count, reference.count);
	}
}


#pragma mark objectsUniqueClasses Tests

- (void)testNSArray_ObjectsUniqueClasses_Correctness {
	{ // object classes
		NSDictionary *input = @{@0: @"NSObject", @1: @"NSNumber", @2: @11, @3: @[@1, @2], @4: [NSNull null], @5: @{@"A": @1, @"B": @2}};
		
		// Map to Class objects
		NSCountedSet *result = [input objectsUniqueClasses];
		
		
		NSCountedSet *reference = [NSCountedSet setWithObjects:@"NSObject".class, @"NSNumber".class, @(11).class, @[@1, @2].class, [NSNull null].class, @{@"A": @1, @"B": @2}.class, nil];
		// Verify that each element has been converted to the correct Class object
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSDictionary *input = @{};
		
		NSCountedSet *result = [input objectsUniqueClasses];
		
		NSCountedSet *reference = [NSCountedSet set];
		// An empty set should return an empty set
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqual(result.count, 0);
	}
}

#pragma mark objectsUniqueClassNames Tests

- (void)testNSArray_ObjectsUniqueClassNames_Correctness {
	{ // object classes
		NSDictionary *input = @{@0: @"NSObject", @1: @"NSNumber", @2: @11, @3: @[@1, @2], @4: [NSNull null], @5: @{@"A": @1, @"B": @2}};
		
		// Map to Class objects
		NSCountedSet *result = [input objectsUniqueClassNames];
		
		
		NSCountedSet *reference = [NSCountedSet setWithObjects:@"NSObject".className, @"NSNumber".className, @(11).className, @[@1, @2].className, [NSNull null].className, @{@"A": @1, @"B": @2}.className, nil];
		// Verify that each element has been converted to the correct Class object
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqualObjects(result, reference);
	}
	{ // empty set
		NSDictionary *input = @{};
		
		NSCountedSet *result = [input objectsUniqueClassNames];
		
		NSCountedSet *reference = [NSCountedSet set];
		// An empty set should return an empty set
		XCTAssertTrue([result isKindOfClass:reference.class]);
		XCTAssertEqual(result.count, 0);
	}
}




#pragma mark toClassesFromStrings Correctness Tests

- (void)testNSDictionary_ToClassesFromStrings_ValidClassNames {
	NSDictionary *input = @{@"A": @"NSString", @"B": @"NSNumber", @"C":@"NSArray"};
	
	// Map to Class objects
	NSDictionary *result = [input toClassesFromStrings];
	
	// Verify that each element has been converted to the correct Class object
	NSDictionary *reference = @{@"A": NSString.class, @"B": NSNumber.class, @"C": NSArray.class};
	XCTAssertEqualObjects(result, reference);
	XCTAssertEqual(result.count, 3);
}

- (void)testNSDictionary_ToClassesFromStrings_InvalidClassNames {
	NSDictionary *input = @{@"A": @"InvalidClass", @"B": @"AnotherInvalidClass"};
	
	// Map to Class objects
	NSDictionary *result = [input toClassesFromStrings];
	
	// Verify that invalid class names return [NSNull class]
	XCTAssertEqual(result.count, 0);
}

- (void)testNSDictionary_ToClassesFromStrings_MixedValidAndInvalidClassNames {
	NSDictionary *input = @{@"A": @"NSString", @"B": @"InvalidClass", @"C":@"NSArray"};
	
	// Map to Class objects
	NSDictionary *result = [input toClassesFromStrings];
	
	NSDictionary *reference = @{@"A": NSString.class, @"C": NSArray.class};
	XCTAssertEqualObjects(result, reference);
	XCTAssertEqual(result.count, 2);
}

- (void)testNSDictionary_ToClassesFromStrings_HandlesEmptySet {
	NSDictionary *input = [NSDictionary dictionary];
	
	// Map to Class objects
	NSDictionary *result = [input toClassesFromStrings];
	
	// An empty set should return an empty set
	XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
	XCTAssertNotNil(result);
	XCTAssertEqual(result.count, 0);
}

- (void)testNSDictionary_ToClassesFromStrings_HandlesNilElement {
	NSDictionary *input = @{@"A": @"NSString", @"B": [NSNull null], @"C":@"NSArray"};
	
	// Map to Class objects
	NSDictionary *result = [input toClassesFromStrings];
	
	NSDictionary *reference = @{@"A": NSString.class, @"C": NSArray.class};
	XCTAssertEqualObjects(result, reference);
	XCTAssertEqual(result.count, 2);
}


#pragma mark Swapped

- (void)testNSDictionary_Swapped
{
	NSDictionary *initial = @{@1: @"A", @2: @"B", @3: @"C", @4: @"B", @5: [NSFileHandle fileHandleWithStandardInput]};
	
	NSDictionary *reference = @{@"A": @1, @"B": @4, @"C": @3};
	
	NSDictionary *swapped = [initial swapped];
	
	XCTAssertNotNil(swapped);
	XCTAssertEqualObjects(swapped, reference);
	XCTAssertTrue([swapped isKindOfClass:NSDictionary.class]);
	XCTAssertFalse([swapped isKindOfClass:NSMutableDictionary.class]);
	
	//Swapped on an NSMutableDictionary results in a MutableDictionary.
	swapped = [initial.mutableCopy swapped];
	XCTAssertNotNil(swapped);
	XCTAssertEqualObjects(swapped, reference);
	XCTAssertTrue([swapped isKindOfClass:NSDictionary.class]);
	XCTAssertTrue([swapped isKindOfClass:NSMutableDictionary.class]);
}


#pragma mark Dictionary By Adding/Merging Dictionary

- (void)testNSDictionary_DictionaryByAddingDictionary
{
	NSDictionary *aDict = @{@1: @"A", @2: @"B"};
	NSDictionary *bDict = @{@2: @"C", @3: @"D"};
	
	NSDictionary *reference = @{@1: @"A", @2: @"C", @3: @"D"};
	
	NSDictionary *result = [aDict dictionaryByAddingDictionary:bDict];
	XCTAssertEqualObjects(result, reference);
	XCTAssertTrue([result isKindOfClass:NSDictionary.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableDictionary.class]);
	
	NSDictionary *nilDict = nil;
	XCTAssertEqualObjects([aDict dictionaryByAddingDictionary:nilDict], aDict);
	XCTAssertEqualObjects([aDict dictionaryByAddingDictionary:@{}], aDict);
	
	XCTAssertThrowsSpecificNamed([aDict dictionaryByAddingDictionary:(NSDictionary*)NSObject.new], NSException,
								 NSInvalidArgumentException);
}

- (void)testNSMutableDictionary_DictionaryByAddingDictionary
{
	NSMutableDictionary *aDict = @{@1: @"A", @2: @"B"}.mutableCopy;
	NSMutableDictionary *bDict = @{@2: @"C", @3: @"D"}.mutableCopy;
	
	NSDictionary *reference = @{@1: @"A", @2: @"C", @3: @"D"};
	
	NSDictionary *result = [aDict dictionaryByAddingDictionary:bDict];
	XCTAssertEqualObjects(result, reference);
	XCTAssertTrue([result isKindOfClass:NSDictionary.class]);
	XCTAssertTrue([result isKindOfClass:NSMutableDictionary.class]);
	
	NSDictionary *nilDict = nil;
	XCTAssertEqualObjects([aDict dictionaryByAddingDictionary:nilDict], aDict);
	XCTAssertEqualObjects([aDict dictionaryByAddingDictionary:@{}], aDict);
	
	XCTAssertThrowsSpecificNamed([aDict dictionaryByAddingDictionary:(NSDictionary*)NSObject.new], NSException,
								 NSInvalidArgumentException);
}


- (void)testNSDictionary_DictionaryByMergingDictionary
{
	NSDictionary *aDict = @{@1: @"A", @2: @"B"};
	NSDictionary *bDict = @{@2: @"C", @3: @"D"};
	
	NSDictionary *reference = @{@1: @"A", @2: @"B", @3: @"D"};
	
	NSDictionary *result = [aDict dictionaryByMergingDictionary:bDict];
	
	XCTAssertEqualObjects(result, reference);
	XCTAssertTrue([result isKindOfClass:NSDictionary.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableDictionary.class]);
	
	NSDictionary *nilDict = nil;
	XCTAssertEqualObjects([aDict dictionaryByMergingDictionary:nilDict], aDict);
	XCTAssertEqualObjects([aDict dictionaryByMergingDictionary:@{}], aDict);
	
	XCTAssertThrowsSpecificNamed([aDict dictionaryByMergingDictionary:(NSDictionary*)NSObject.new], NSException,
								 NSInvalidArgumentException);
}


- (void)testNSMutableDictionary_DictionaryByMergingDictionary
{
	NSMutableDictionary *aDict = @{@1: @"A", @2: @"B"}.mutableCopy;
	NSMutableDictionary *bDict = @{@2: @"C", @3: @"D"}.mutableCopy;
	
	NSDictionary *reference = @{@1: @"A", @2: @"B", @3: @"D"};
	
	NSMutableDictionary *result = [aDict dictionaryByMergingDictionary:bDict];
	
	XCTAssertEqualObjects(result, reference);
	XCTAssertTrue([result isKindOfClass:NSDictionary.class]);
	XCTAssertTrue([result isKindOfClass:NSMutableDictionary.class]);
	
	NSDictionary *nilDict = nil;
	XCTAssertEqualObjects([aDict dictionaryByMergingDictionary:nilDict], aDict);
	XCTAssertEqualObjects([aDict dictionaryByMergingDictionary:@{}], aDict);
	
	XCTAssertThrowsSpecificNamed([aDict dictionaryByMergingDictionary:(NSDictionary*)NSObject.new], NSException,
								 NSInvalidArgumentException);
}



#pragma mark - NSMutableDictionary:


- (void)testNSMutableDictionary_IsIndexedSubscriptNumeric_Correctness
{
	NSMutableDictionary *dict = NSMutableDictionary.new;
	
	XCTAssertTrue(dict.isIndexedSubscriptNumeric);
	
	dict.isIndexedSubscriptNumeric = false;
	XCTAssertFalse(dict.isIndexedSubscriptNumeric);
	
	dict.isIndexedSubscriptNumeric = true;
	XCTAssertTrue(dict.isIndexedSubscriptNumeric);
}

- (void)testNSMutableDictionary_IsIndexedSubscriptNumeric_Numeric
{
	NSMutableDictionary *dict = NSMutableDictionary.new;
	
	[dict setObject:@"A" forKey:@1];
	XCTAssertTrue(dict.isIndexedSubscriptNumeric);
}


- (void)testNSMutableDictionary_IsIndexedSubscriptNumeric_NumericString
{
	NSMutableDictionary *dict = NSMutableDictionary.new;
	
	[dict setObject:@"A" forKey:@"1"];
	XCTAssertFalse(dict.isIndexedSubscriptNumeric);
}


- (void)testNSMutableDictionary_setObject_Numeric
{
	NSMutableDictionary *dict = NSMutableDictionary.new;
	
	dict[0] = @"A";
	
	XCTAssertTrue(dict.isIndexedSubscriptNumeric);
	XCTAssertEqualObjects([dict objectForKey:@0], @"A");
	
	
	
	dict = NSMutableDictionary.new;
	[dict setObject:@"B" forKey:@1];
	
	XCTAssertTrue(dict.isIndexedSubscriptNumeric);
	XCTAssertEqualObjects([dict objectForKey:@1], @"B");
}


- (void)testNSMutableDictionary_setObject_NumericString
{
	NSMutableDictionary *dict = NSMutableDictionary.new;
	
	[dict setObject:@"A" forKey:@"0"];
	
	XCTAssertFalse(dict.isIndexedSubscriptNumeric);
	XCTAssertNil([dict objectForKey:@0]);
	XCTAssertEqualObjects([dict objectForKey:@"0"], @"A");
	
	
	
	
	dict = NSMutableDictionary.new;
	dict.isIndexedSubscriptNumeric = false;
	dict[1] = @"B";
	
	XCTAssertFalse(dict.isIndexedSubscriptNumeric);
	XCTAssertNil([dict objectForKey:@1]);
	XCTAssertEqualObjects([dict objectForKey:@"1"], @"B");
}

#pragma mark mapUsingBlock
/*
- (void)testNSMutableDictionary_mapUsingBlock_Correctness
{
	NSMutableDictionary *input = @{@"A": @1, @"B": @2, @"C": @3}.mutableCopy;
	
	NSMutableDictionary *result = [input mapUsingBlock:^BOOL(id * _Nonnull key, id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
		*obj = @([*obj integerValue] * 2);
		return YES;
	}];
	XCTAssertTrue([result isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(result.count, 3);
	
	NSDictionary *reference = @{@"A": @2, @"B": @4, @"C": @6};
	XCTAssertEqualObjects(result, reference);
}*/

#pragma mark Swap

- (void)testNSMutableDictionary_swap
{
	NSMutableDictionary *initial = @{@1: @"A", @2: @"B", @3: @"C", @4: @"B", @5: [NSFileHandle fileHandleWithStandardInput]}.mutableCopy;
	
	NSDictionary *reference = @{@"A": @1, @"B": @4, @"C": @3};
	
	NSMutableDictionary *swapDict = [initial swap];
	
	XCTAssertEqual(swapDict, initial);
	XCTAssertEqualObjects(initial, reference);
}

#pragma mark FilterWithBlock

- (void)testNSMutableDictionary_FilterWithBlock {
	// Test the filter operation with no concurrency (map I -> I*2)
	NSMutableDictionary *input = @{@"A": @1, @"B": @2, @"C": @3, @"D": @4, @"E": @5, @6: [NSNull null]}.mutableCopy;
	NSDictionary *result = [input filterUsingBlock:^BOOL(id * _Nonnull key, id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
		if ([*obj isKindOfClass:NSNull.class]) {
			*obj = nil;
		} else {
			*obj = @([*obj integerValue] * 2);
		}
		return YES;
	}];
	
	NSMutableDictionary *reference = @{@"A": @2, @"B": @4, @"C": @6, @"D": @8, @"E": @10}.mutableCopy;
	XCTAssertEqual(result, input);
	XCTAssertEqualObjects(result, reference, @"The set should contain each element multiplied by 2.");
}


- (void)testNSMutableDictionary_FilterWithBlock_EmptySet {
	// Test the filter operation with an empty set (map I -> I*2)
	NSMutableDictionary *input = [NSMutableDictionary dictionary];
	NSDictionary *result = [input filterUsingBlock:^BOOL(id * _Nonnull key, id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
		*obj = @([*obj integerValue] * 2);
		return YES;
	}];
	
	NSDictionary *expectedSet = [NSDictionary dictionary];
	XCTAssertEqual(result, input, @"The result should be the original.");
	XCTAssertEqualObjects(result, expectedSet, @"The result should be an empty set.");
}


- (void)testNSMutableDictionary_FilterWithBlock_WithNilReturn {
	// Test the filter operation where the block returns nil for certain elements (some elements will be excluded)
	NSMutableDictionary *input = @{@"A": @1, @"B": @2, @"C": @3, @"D": @4, @"E": @5}.mutableCopy;
	NSDictionary *result = [input filterUsingBlock:^BOOL(id * _Nonnull key, id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
		if ([*obj integerValue] % 2) {
			return NO;
		}
		*obj = @([*obj integerValue] * 2);
		return YES;
	}];
	
	NSMutableDictionary *reference = @{@"B": @4, @"D": @8}.mutableCopy; // Only even numbers are doubled
	XCTAssertEqual(result, input, @"The result should be the original.");
	XCTAssertEqualObjects(result, reference, @"The set should contain only even elements, doubled.");
}


- (void)testNSMutableDictionary_FilterWithBlock_Performance {
	// Performance test to check how well the filter works with a large set (map I -> I*2)
	NSMutableDictionary *input = [NSMutableDictionary dictionary];
	for (NSInteger i = 0; i < 100000; i++) {
		NSNumber *n = @(i);
		input[n] = n;
	}
	
	// Measure performance of mapping each element to I*2
	[self measureBlock:^{
		[input filterUsingBlock:^BOOL(id * _Nonnull key, id  _Nullable __autoreleasing * _Nonnull obj, BOOL * _Nonnull stop) {
			*obj = @([*obj integerValue] * 2);
			return YES;
		}];
	}];
}


#pragma mark mergeEntriesFromDictionary

- (void)testNSMutableDictionary_mergeEntriesFromDictionary_Correctness
{
	NSMutableDictionary *original = @{@1: @"A", @2: @"B",
								  @4:@{@10:@"E"},
								  @5:@{@20:@"F"},
								  @6:@{@30:@"G"}.mutableCopy,
								  @7:@{@40:@"H"}.mutableCopy}.mutableCopy;
	NSMutableDictionary *mutableDict = original.mutableCopy;
	
	NSDictionary *otherDict = @{@2: @"C", @3: @"D",
								@4: @{@10: @"I"},
								@5: @{@20: @"J"}.mutableCopy,
								@6: @{@30: @"K"},
								@7: @{@40: @"L"}.mutableCopy,
								@8: @{@50: @"M"},
								@9: @{@60: @"N"}.mutableCopy};
	
	//Fills in non-existing keys, when merging
	[mutableDict mergeEntriesFromDictionary:otherDict];
	NSDictionary *referenceMerge = @{@1: @"A", @2: @"B", @3: @"D",
									 @4:@{@10:@"E"},
									 @5:@{@20:@"F"},
									 @6:@{@30:@"G"},
									 @7:@{@40:@"H"},
									 @8: @{@50: @"M"},
									 @9: @{@60: @"N"}};
	XCTAssertEqualObjects(mutableDict, referenceMerge);
	XCTAssertEqual(mutableDict[@1], original[@1]);
	XCTAssertEqual(mutableDict[@2], original[@2]);
	XCTAssertEqual(mutableDict[@3], otherDict[@3]);
	XCTAssertEqual(mutableDict[@4], original[@4]);
	XCTAssertEqual(mutableDict[@5], original[@5]);
	XCTAssertEqual(mutableDict[@6], original[@6]);
	XCTAssertEqual(mutableDict[@7], original[@7]);
	XCTAssertEqual(mutableDict[@8], otherDict[@8]);
	XCTAssertEqual(mutableDict[@9], otherDict[@9]);
	
	
	mutableDict = original.mutableCopy;
	//overwrites existing keys when adding
	NSDictionary *referenceAdd = @{@1: @"A", @2: @"C", @3: @"D",
								   @4:@{@10:@"I"},
								   @5:@{@20:@"J"},
								   @6:@{@30:@"K"},
								   @7:@{@40:@"L"},
								   @8: @{@50: @"M"},
								   @9: @{@60: @"N"}};
	
	[mutableDict addEntriesFromDictionary:otherDict];
	XCTAssertEqualObjects(mutableDict, referenceAdd);
	
	
	XCTAssertEqual(mutableDict[@1], original[@1]);
	XCTAssertEqual(mutableDict[@2], otherDict[@2]);
	XCTAssertEqual(mutableDict[@3], otherDict[@3]);
	XCTAssertEqual(mutableDict[@4], otherDict[@4]);
	XCTAssertEqual(mutableDict[@5], otherDict[@5]);
	XCTAssertEqual(mutableDict[@6], otherDict[@6]);
	XCTAssertEqual(mutableDict[@7], otherDict[@7]);
	XCTAssertEqual(mutableDict[@8], otherDict[@8]);
	XCTAssertEqual(mutableDict[@9], otherDict[@9]);
}


- (void)testNSMutableDictionary_mergeEntriesFromDictionary_NilDictionary
{
	NSMutableDictionary *dict = @{@1: @"A", @2: @"B"}.mutableCopy;
	NSMutableDictionary *addToDict = dict.mutableCopy;
	NSDictionary *nilDictionary = nil;
	
	//Fills in non-existing keys
	[dict mergeEntriesFromDictionary:nilDictionary];
	NSDictionary *reference = @{@1: @"A", @2: @"B"};
	XCTAssertEqualObjects(dict, reference);
	
	
	//overwrites existing keys
	[addToDict addEntriesFromDictionary:nilDictionary];
	XCTAssertEqualObjects(addToDict, reference);
}


- (void)testNSMutableDictionary_mergeEntriesFromDictionary_NonDictionary
{
	NSMutableDictionary *dict = @{@1: @"A", @2: @"B"}.mutableCopy;
	NSMutableDictionary *addToDict = dict.mutableCopy;
	NSDictionary *nonDictionary = (NSDictionary*)NSObject.new;
	
	//Fills in non-existing keys
	
	XCTAssertThrowsSpecificNamed([dict mergeEntriesFromDictionary:nonDictionary], NSException,
								 NSInvalidArgumentException);
	
	
	//overwrites existing keys
	XCTAssertThrowsSpecificNamed([addToDict addEntriesFromDictionary:nonDictionary], NSException,
								 NSInvalidArgumentException);
}


- (void)testNSMutableDictionary_mergeEntriesFromDictionaryRecursive_Correctness
{
	NSMutableDictionary *original = @{@1: @"A", @2: @"B",
									  @4:@{@10:@"EA", @11:@"EB"},
									  @5:@{@20:@"FA", @21:@"FB"},
									  @6:@{@30:@"GA", @31:@"GB", @33:@{@35:@"GC", @36:@"GD"}}.mutableCopy,
									  @7:@{@40:@"HA", @41:@"HB", @43:@{@45:@"HC", @46:@"HD"}.mutableCopy}.mutableCopy
									}.mutableCopy;
	NSMutableDictionary *mutableDict = original.mutableCopy;
	
	NSDictionary *otherDict = @{@2: @"C", @3: @"D",
								@4: @{@11: @"IA", @12: @"IB"},
								@5: @{@21: @"JA", @22: @"JB"}.mutableCopy,
								@6: @{@31: @"KA", @32: @"KB", @33:@{@36:@"KC", @37:@"KD"}},
								@7: @{@41: @"LA", @42: @"LB", @43:@{@46:@"LC", @47:@"LD"}}.mutableCopy,
								@8: @{@51: @"MA", @52: @"MB"},
								@9: @{@61: @"NA", @62: @"NB"}.mutableCopy};
	
	//Fills in non-existing keys, when merging
	[mutableDict mergeEntriesFromDictionaryRecursive:otherDict];
	NSDictionary *referenceMerge = @{@1: @"A", @2: @"B", @3: @"D",
									 @4:@{@10:@"EA", @11:@"EB"},
									 @5:@{@20:@"FA", @21:@"FB"},
									 @6:@{@30:@"GA", @31:@"GB", @32:@"KB", @33:@{@35:@"GC", @36:@"GD"}},
									 @7:@{@40:@"HA", @41:@"HB", @42:@"LB", @43:@{@45:@"HC", @46:@"HD", @47:@"LD"}},
									 @8: @{@51: @"MA", @52: @"MB"},
									 @9: @{@61: @"NA", @62: @"NB"}};
	XCTAssertEqualObjects(mutableDict, referenceMerge);
	XCTAssertEqual(mutableDict[@1], original[@1]);
	XCTAssertEqual(mutableDict[@2], original[@2]);
	XCTAssertEqual(mutableDict[@3], otherDict[@3]);
	XCTAssertEqual(mutableDict[@4], original[@4]);
	XCTAssertEqual(mutableDict[@5], original[@5]);
	XCTAssertEqual(mutableDict[@6], original[@6]);
	XCTAssertEqual(mutableDict[@7], original[@7]);
	XCTAssertEqual(mutableDict[@8], otherDict[@8]);
	XCTAssertEqual(mutableDict[@9], otherDict[@9]);
}


- (void)testNSMutableDictionary_mergeEntriesFromDictionaryRecursive_SelfMutableCollectionFlag_Correctness
{
	NSMutableDictionary *original = @{@1: @"A", @2: @"B",
									  @4:@{@10:@"EA", @11:@"EB"},
									  @5:@{@20:@"FA", @21:@"FB"},
									  @6:@{@30:@"GA", @31:@"GB"}.mutableCopy,
									  @7:@{@40:@"HA", @41:@"HB"}.mutableCopy}.mutableCopy;
	NSMutableDictionary *mutableDict = original.mutableCopy;
	
	NSDictionary *otherDict = @{@2: @"C", @3: @"D",
								@4: @{@11: @"IA", @12: @"IB"},
								@5: @{@21: @"JA", @22: @"JB"}.mutableCopy,
								@6: @{@31: @"KA", @32: @"KB"},
								@7: @{@41: @"LA", @42: @"LB"}.mutableCopy,
								@8: @{@51: @"MA", @52: @"MB"},
								@9: @{@61: @"NA", @62: @"NB"}.mutableCopy};
	
	//Fills in non-existing keys, when merging
	[mutableDict mergeEntriesFromDictionaryRecursive:otherDict flags:BEDictionarySelfMutableCollectionFlag];
	NSDictionary *referenceMerge = @{@1: @"A", @2: @"B", @3: @"D",
									 @4:@{@10:@"EA", @11:@"EB", @12: @"IB"},
									 @5:@{@20:@"FA", @21:@"FB", @22: @"JB"},
									 @6:@{@30:@"GA", @31:@"GB", @32: @"KB"},
									 @7:@{@40:@"HA", @41:@"HB", @42:@"LB"},
									 @8: @{@51: @"MA", @52: @"MB"},
									 @9: @{@61: @"NA", @62: @"NB"}};
	XCTAssertEqualObjects(mutableDict, referenceMerge);
	XCTAssertEqual(mutableDict[@1], original[@1]);
	XCTAssertEqual(mutableDict[@2], original[@2]);
	XCTAssertEqual(mutableDict[@3], otherDict[@3]);
	XCTAssertNotEqual(mutableDict[@4], original[@4]);
	XCTAssertTrue([mutableDict[@4] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertNotEqual(mutableDict[@5], original[@5]);
	XCTAssertTrue([mutableDict[@5] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(mutableDict[@6], original[@6]);
	XCTAssertEqual(mutableDict[@7], original[@7]);
	XCTAssertEqual(mutableDict[@8], otherDict[@8]);
	XCTAssertEqual(mutableDict[@9], otherDict[@9]);
}


- (void)testNSMutableDictionary_mergeEntriesFromDictionaryRecursive_FlagMutableCollectionCopy_Correctness
{
	NSMutableDictionary *original = @{@1: @"A", @2: @"B",
									  @4:@{@10:@"EA", @11:@"EB"},
									  @5:@{@20:@"FA", @21:@"FB"},
									  @6:@{@30:@"GA", @31:@"GB"}.mutableCopy,
									  @7:@{@40:@"HA", @41:@"HB"}.mutableCopy}.mutableCopy;
	NSMutableDictionary *mutableDict = original.mutableCopy;
	
	NSDictionary *otherDict = @{@2: @"C", @3: @"D",
								@4: @{@11: @"IA", @12: @"IB"},
								@5: @{@21: @"JA", @22: @"JB"}.mutableCopy,
								@6: @{@31: @"KA", @32: @"KB"},
								@7: @{@41: @"LA", @42: @"LB"}.mutableCopy,
								@8: @{@51: @"MA", @52: @"MB"},
								@9: @{@61: @"NA", @62: @"NB"}.mutableCopy};
	
	//Fills in non-existing keys, when merging
	[mutableDict mergeEntriesFromDictionaryRecursive:otherDict flags:BEDictionaryMutableCollectionCopyFlag];
	NSDictionary *referenceMerge = @{@1: @"A", @2: @"B", @3: @"D",
									 @4:@{@10:@"EA", @11:@"EB"},
									 @5:@{@20:@"FA", @21:@"FB"},
									 @6:@{@30:@"GA", @31:@"GB", @32: @"KB"},
									 @7:@{@40:@"HA", @41:@"HB", @42:@"LB"},
									 @8: @{@51: @"MA", @52: @"MB"},
									 @9: @{@61: @"NA", @62: @"NB"}};
	XCTAssertEqualObjects(mutableDict, referenceMerge);
	XCTAssertEqual(mutableDict[@1], original[@1]);
	XCTAssertEqual(mutableDict[@2], original[@2]);
	XCTAssertEqual(mutableDict[@3], otherDict[@3]);
	XCTAssertEqual(mutableDict[@4], original[@4]);
	XCTAssertEqual(mutableDict[@5], original[@5]);
	XCTAssertEqual(mutableDict[@6], original[@6]);
	XCTAssertEqual(mutableDict[@6][@32], original[@6][@32]);
	XCTAssertEqual(mutableDict[@7], original[@7]);
	XCTAssertEqual(mutableDict[@7][@42], original[@7][@42]);
	XCTAssertNotEqual(mutableDict[@8], otherDict[@8]);
	XCTAssertTrue([mutableDict[@8] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertNotEqual(mutableDict[@9], otherDict[@9]);
	XCTAssertTrue([mutableDict[@9] isKindOfClass:NSMutableDictionary.class]);
}



- (void)testNSMutableDictionary_mergeEntriesFromDictionaryRecursive_FlagMutableCopy_Correctness
{
	NSMutableDictionary *original = @{@1: @"A", @2: @"B",
									  @4:@{@10:@"EA", @11:@"EB"},
									  @5:@{@20:@"FA", @21:@"FB"},
									  @6:@{@30:@"GA", @31:@"GB"}.mutableCopy,
									  @7:@{@40:@"HA", @41:@"HB"}.mutableCopy}.mutableCopy;
	NSMutableDictionary *mutableDict = original.mutableCopy;
	
	NSDictionary *otherDict = @{@2: @"C", @3: @"D",
								@4: @{@11: @"IA", @12: @"IB"},
								@5: @{@21: @"JA", @22: @"JB"}.mutableCopy,
								@6: @{@31: @"KA", @32: @"KB"},
								@7: @{@41: @"LA", @42: @"LB"}.mutableCopy,
								@8: @{@51: @"MA", @52: @"MB"},
								@9: @{@61: @"NA", @62: @"NB"}.mutableCopy};
	
	//Fills in non-existing keys, when merging
	[mutableDict mergeEntriesFromDictionaryRecursive:otherDict flags:BEDictionaryMutableCopyFlag];
	NSDictionary *referenceMerge = @{@1: @"A", @2: @"B", @3: @"D",
									 @4:@{@10:@"EA", @11:@"EB"},
									 @5:@{@20:@"FA", @21:@"FB"},
									 @6:@{@30:@"GA", @31:@"GB", @32: @"KB"},
									 @7:@{@40:@"HA", @41:@"HB", @42:@"LB"},
									 @8: @{@51: @"MA", @52: @"MB"},
									 @9: @{@61: @"NA", @62: @"NB"}};
	XCTAssertEqualObjects(mutableDict, referenceMerge);
	XCTAssertEqual(mutableDict[@1], original[@1]);
	XCTAssertEqual(mutableDict[@2], original[@2]);
	XCTAssertNotEqual(mutableDict[@3], otherDict[@3]);
	XCTAssertTrue([mutableDict[@3] isKindOfClass:NSMutableString.class]);
	XCTAssertEqual(mutableDict[@4], original[@4]);
	XCTAssertEqual(mutableDict[@5], original[@5]);
	XCTAssertEqual(mutableDict[@6], original[@6]);
	XCTAssertNotEqual(mutableDict[@6][@32], otherDict[@6][@32]);
	XCTAssertTrue([mutableDict[@6][@32] isKindOfClass:NSMutableString.class]);
	XCTAssertEqual(mutableDict[@7], original[@7]);
	XCTAssertNotEqual(mutableDict[@7][@42], otherDict[@7][@42]);
	XCTAssertTrue([mutableDict[@7][@42] isKindOfClass:NSMutableString.class]);
	XCTAssertNotEqual(mutableDict[@8], otherDict[@8]);
	XCTAssertTrue([mutableDict[@8] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertNotEqual(mutableDict[@9], otherDict[@9]);
}


- (void)testNSMutableDictionary_mergeEntriesFromDictionaryRecursive_NilDictionary
{
	NSMutableDictionary *dict = @{@1: @"A", @2: @"B"}.mutableCopy;
	NSDictionary *nilDictionary = nil;
	
	//Fills in non-existing keys
	[dict mergeEntriesFromDictionaryRecursive:nilDictionary];
	NSDictionary *reference = @{@1: @"A", @2: @"B"};
	XCTAssertEqualObjects(dict, reference);
}


- (void)testNSMutableDictionary_mergeEntriesFromDictionaryRecursive_NonDictionary
{
	NSMutableDictionary *dict = @{@1: @"A", @2: @"B"}.mutableCopy;
	NSDictionary *nonDictionary = (NSDictionary*)NSObject.new;
	
	//Fills in non-existing keys
	
	XCTAssertThrowsSpecificNamed([dict mergeEntriesFromDictionary:nonDictionary], NSException,
								 NSInvalidArgumentException);
}



#pragma mark addEntriesFromDictionaryRecursive

- (void)testNSMutableDictionary_addEntriesFromDictionaryRecursive_Correctness
{
	NSMutableDictionary *original = @{@1: @"A", @2: @"B",
									  @4:@{@10:@"EA", @11:@"EB"},
									  @5:@{@20:@"FA", @21:@"FB"},
									  @6:@{@30:@"GA", @31:@"GB", @33:@{@35:@"GC", @36:@"GD"}}.mutableCopy,
									  @7:@{@40:@"HA", @41:@"HB", @43:@{@45:@"HC", @46:@"HD"}.mutableCopy}.mutableCopy
									}.mutableCopy;
	NSMutableDictionary *mutableDict = original.mutableCopy;
	
	NSDictionary *otherDict = @{@2: @"C", @3: @"D",
								@4: @{@11: @"IA", @12: @"IB"},
								@5: @{@21: @"JA", @22: @"JB"}.mutableCopy,
								@6: @{@31: @"KA", @32: @"KB", @33:@{@36:@"KC", @37:@"KD"}},
								@7: @{@41: @"LA", @42: @"LB", @43:@{@46:@"LC", @47:@"LD"}}.mutableCopy,
								@8: @{@51: @"MA", @52: @"MB"},
								@9: @{@61: @"NA", @62: @"NB"}.mutableCopy};
	
	//Fills in non-existing keys, when merging
	[mutableDict addEntriesFromDictionaryRecursive:otherDict];
	NSDictionary *referenceMerge = @{@1: @"A", @2: @"C", @3: @"D",
									 @4:@{@11:@"IA", @12:@"IB"},
									 @5:@{@21:@"JA", @22:@"JB"},
									 @6:@{@30:@"GA", @31:@"KA", @32:@"KB", @33:@{@36:@"KC", @37:@"KD"}},
									 @7:@{@40:@"HA", @41:@"LA", @42:@"LB", @43:@{@45:@"HC", @46:@"LC", @47:@"LD"}},
									 @8: @{@51: @"MA", @52: @"MB"},
									 @9: @{@61: @"NA", @62: @"NB"}};
	XCTAssertEqualObjects(mutableDict, referenceMerge);
	XCTAssertEqual(mutableDict[@1], original[@1]);
	XCTAssertEqual(mutableDict[@2], otherDict[@2]);
	XCTAssertEqual(mutableDict[@3], otherDict[@3]);
	XCTAssertEqual(mutableDict[@4], otherDict[@4]);
	XCTAssertEqual(mutableDict[@5], otherDict[@5]);
	XCTAssertEqual(mutableDict[@6], original[@6]);
	XCTAssertEqual(mutableDict[@7], original[@7]);
	XCTAssertEqual(mutableDict[@8], otherDict[@8]);
	XCTAssertEqual(mutableDict[@9], otherDict[@9]);
}


- (void)testNSMutableDictionary_addEntriesFromDictionaryRecursive_SelfMutableCollectionFlag_Correctness
{
	NSMutableDictionary *original = @{@1: @"A", @2: @"B",
									  @4:@{@10:@"EA", @11:@"EB"},
									  @5:@{@20:@"FA", @21:@"FB"},
									  @6:@{@30:@"GA", @31:@"GB", @33:@{@35:@"GC", @36:@"GD"}}.mutableCopy,
									  @7:@{@40:@"HA", @41:@"HB", @43:@{@45:@"HC", @46:@"HD"}.mutableCopy}.mutableCopy
									}.mutableCopy;
	NSMutableDictionary *mutableDict = original.mutableCopy;
	
	NSDictionary *otherDict = @{@2: @"C", @3: @"D",
								@4: @{@11: @"IA", @12: @"IB"},
								@5: @{@21: @"JA", @22: @"JB"}.mutableCopy,
								@6: @{@31: @"KA", @32: @"KB", @33:@{@36:@"KC", @37:@"KD"}},
								@7: @{@41: @"LA", @42: @"LB", @43:@{@46:@"LC", @47:@"LD"}}.mutableCopy,
								@8: @{@51: @"MA", @52: @"MB"},
								@9: @{@61: @"NA", @62: @"NB"}.mutableCopy};
	
	//Fills in non-existing keys, when merging
	[mutableDict addEntriesFromDictionaryRecursive:otherDict flags:BEDictionarySelfMutableCollectionFlag];
	NSDictionary *referenceMerge = @{@1: @"A", @2: @"C", @3: @"D",
									 @4:@{@10:@"EA", @11:@"IA", @12:@"IB"},
									 @5:@{@20:@"FA", @21:@"JA", @22:@"JB"},
									 @6:@{@30:@"GA", @31:@"KA", @32:@"KB", @33:@{@35:@"GC", @36:@"KC", @37:@"KD"}},
									 @7:@{@40:@"HA", @41:@"LA", @42:@"LB", @43:@{@45:@"HC", @46:@"LC", @47:@"LD"}},
									 @8: @{@51: @"MA", @52: @"MB"},
									 @9: @{@61: @"NA", @62: @"NB"}};
	XCTAssertEqualObjects(mutableDict, referenceMerge);
	XCTAssertEqual(mutableDict[@1], original[@1]);
	XCTAssertEqualObjects(mutableDict[@1], referenceMerge[@1]);
	XCTAssertEqual(mutableDict[@2], otherDict[@2]);
	XCTAssertEqualObjects(mutableDict[@2], referenceMerge[@2]);
	XCTAssertEqual(mutableDict[@3], otherDict[@3]);
	XCTAssertEqualObjects(mutableDict[@3], referenceMerge[@3]);
	XCTAssertNotEqual(mutableDict[@4], original[@4]);
	XCTAssertEqualObjects(mutableDict[@4], referenceMerge[@4]);
	XCTAssertTrue([mutableDict[@4] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertNotEqual(mutableDict[@5], original[@5]);
	XCTAssertEqualObjects(mutableDict[@5], referenceMerge[@5]);
	XCTAssertTrue([mutableDict[@5] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(mutableDict[@6], original[@6]);
	XCTAssertEqualObjects(mutableDict[@6], referenceMerge[@6]);
	XCTAssertEqual(mutableDict[@7], original[@7]);
	XCTAssertEqualObjects(mutableDict[@7], referenceMerge[@7]);
	XCTAssertEqual(mutableDict[@8], otherDict[@8]);
	XCTAssertEqualObjects(mutableDict[@8], referenceMerge[@8]);
	XCTAssertEqual(mutableDict[@9], otherDict[@9]);
	XCTAssertEqualObjects(mutableDict[@9], referenceMerge[@9]);
}


- (void)testNSMutableDictionary_addEntriesFromDictionaryRecursive_FlagMutableCollectionCopy_Correctness
{
	NSMutableDictionary *original = @{@1: @"A", @2: @"B",
									  @4:@{@10:@"EA", @11:@"EB"},
									  @5:@{@20:@"FA", @21:@"FB"},
									  @6:@{@30:@"GA", @31:@"GB", @33:@{@35:@"GC", @36:@"GD"}}.mutableCopy,
									  @7:@{@40:@"HA", @41:@"HB", @43:@{@45:@"HC", @46:@"HD"}.mutableCopy}.mutableCopy
									}.mutableCopy;
	NSMutableDictionary *mutableDict = original.mutableCopy;
	
	NSDictionary *otherDict = @{@2: @"C", @3: @"D",
								@4: @{@11: @"IA", @12: @"IB"},
								@5: @{@21: @"JA", @22: @"JB"}.mutableCopy,
								@6: @{@31: @"KA", @32: @"KB", @33:@{@36:@"KC", @37:@"KD"}},
								@7: @{@41: @"LA", @42: @"LB", @43:@{@46:@"LC", @47:@"LD"}}.mutableCopy,
								@8: @{@51: @"MA", @52: @"MB"},
								@9: @{@61: @"NA", @62: @"NB"}.mutableCopy};
	
	//Fills in non-existing keys, when merging
	[mutableDict addEntriesFromDictionaryRecursive:otherDict flags:BEDictionaryMutableCollectionCopyFlag];
	NSDictionary *referenceMerge = @{@1: @"A", @2: @"C", @3: @"D",
									 @4: @{@11: @"IA", @12: @"IB"},
									 @5: @{@21: @"JA", @22: @"JB"},
									 @6:@{@30:@"GA", @31:@"KA", @32:@"KB", @33:@{@36:@"KC", @37:@"KD"}},
									 @7:@{@40:@"HA", @41:@"LA", @42:@"LB", @43:@{@45:@"HC", @46:@"LC", @47:@"LD"}},
									 @8: @{@51: @"MA", @52: @"MB"},
									 @9: @{@61: @"NA", @62: @"NB"}};
	XCTAssertEqualObjects(mutableDict, referenceMerge);
	XCTAssertEqual(mutableDict[@1], original[@1]);
	XCTAssertEqualObjects(mutableDict[@1], referenceMerge[@1]);
	XCTAssertEqual(mutableDict[@2], otherDict[@2]);
	XCTAssertEqualObjects(mutableDict[@2], referenceMerge[@2]);
	XCTAssertEqual(mutableDict[@3], otherDict[@3]);
	XCTAssertEqualObjects(mutableDict[@3], referenceMerge[@3]);
	XCTAssertNotEqual(mutableDict[@4], otherDict[@4]);
	XCTAssertEqualObjects(mutableDict[@4], referenceMerge[@4]);
	XCTAssertTrue([mutableDict[@4] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertNotEqual(mutableDict[@5], otherDict[@5]);
	XCTAssertEqualObjects(mutableDict[@5], referenceMerge[@5]);
	XCTAssertTrue([mutableDict[@5] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(mutableDict[@6], original[@6]);
	XCTAssertEqualObjects(mutableDict[@6], referenceMerge[@6]);
	XCTAssertEqual(mutableDict[@7], original[@7]);
	XCTAssertEqualObjects(mutableDict[@7], referenceMerge[@7]);
	XCTAssertNotEqual(mutableDict[@8], otherDict[@8]);
	XCTAssertEqualObjects(mutableDict[@8], referenceMerge[@8]);
	XCTAssertTrue([mutableDict[@8] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertNotEqual(mutableDict[@9], otherDict[@9]);
	XCTAssertEqualObjects(mutableDict[@9], referenceMerge[@9]);
	XCTAssertTrue([mutableDict[@9] isKindOfClass:NSMutableDictionary.class]);
}



- (void)testNSMutableDictionary_addEntriesFromDictionaryRecursive_FlagMutableCopy_Correctness
{
	NSMutableDictionary *original = @{@1: @"A", @2: @"B",
									  @4:@{@10:@"EA", @11:@"EB"},
									  @5:@{@20:@"FA", @21:@"FB"},
									  @6:@{@30:@"GA", @31:@"GB", @33:@{@35:@"GC", @36:@"GD"}}.mutableCopy,
									  @7:@{@40:@"HA", @41:@"HB", @43:@{@45:@"HC", @46:@"HD"}.mutableCopy}.mutableCopy
									}.mutableCopy;
	NSMutableDictionary *mutableDict = original.mutableCopy;
	
	NSDictionary *otherDict = @{@2: @"C", @3: @"D",
								@4: @{@11: @"IA", @12: @"IB"},
								@5: @{@21: @"JA", @22: @"JB"}.mutableCopy,
								@6: @{@31: @"KA", @32: @"KB", @33:@{@36:@"KC", @37:@"KD"}},
								@7: @{@41: @"LA", @42: @"LB", @43:@{@46:@"LC", @47:@"LD"}}.mutableCopy,
								@8: @{@51: @"MA", @52: @"MB"},
								@9: @{@61: @"NA", @62: @"NB"}.mutableCopy};
	
	//Fills in non-existing keys, when merging
	[mutableDict addEntriesFromDictionaryRecursive:otherDict flags:BEDictionaryMutableCopyFlag];
	NSDictionary *referenceMerge = @{@1: @"A", @2: @"C", @3: @"D",
									 @4: @{@11: @"IA", @12: @"IB"},
									 @5: @{@21: @"JA", @22: @"JB"},
									 @6:@{@30:@"GA", @31:@"KA", @32: @"KB", @33:@{@36:@"KC", @37:@"KD"}},
									 @7:@{@40:@"HA", @41:@"LA", @42:@"LB", @43:@{@45:@"HC", @46:@"LC", @47:@"LD"}},
									 @8: @{@51: @"MA", @52: @"MB"},
									 @9: @{@61: @"NA", @62: @"NB"}};
	XCTAssertEqualObjects(mutableDict, referenceMerge);
	XCTAssertEqual(mutableDict[@1], original[@1]);
	XCTAssertEqualObjects(mutableDict[@1], referenceMerge[@1]);
	XCTAssertNotEqual(mutableDict[@2], otherDict[@2]);
	XCTAssertEqualObjects(mutableDict[@2], referenceMerge[@2]);
	XCTAssertTrue([mutableDict[@2] isKindOfClass:NSMutableString.class]);
	XCTAssertNotEqual(mutableDict[@3], otherDict[@3]);
	XCTAssertEqualObjects(mutableDict[@3], referenceMerge[@3]);
	XCTAssertTrue([mutableDict[@3] isKindOfClass:NSMutableString.class]);
	XCTAssertNotEqual(mutableDict[@4], otherDict[@4]);
	XCTAssertEqualObjects(mutableDict[@4], referenceMerge[@4]);
	XCTAssertTrue([mutableDict[@4] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertNotEqual(mutableDict[@5], otherDict[@5]);
	XCTAssertEqualObjects(mutableDict[@5], referenceMerge[@5]);
	XCTAssertTrue([mutableDict[@5] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(mutableDict[@6], original[@6]);
	XCTAssertEqualObjects(mutableDict[@6], referenceMerge[@6]);
	XCTAssertTrue([mutableDict[@6][@32] isKindOfClass:NSMutableString.class]);
	XCTAssertEqual(mutableDict[@7], original[@7]);
	XCTAssertEqualObjects(mutableDict[@7], referenceMerge[@7]);
	XCTAssertTrue([mutableDict[@7][@42] isKindOfClass:NSMutableString.class]);
	XCTAssertNotEqual(mutableDict[@8], otherDict[@8]);
	XCTAssertEqualObjects(mutableDict[@8], referenceMerge[@8]);
	XCTAssertTrue([mutableDict[@8] isKindOfClass:NSMutableDictionary.class]);
	XCTAssertNotEqual(mutableDict[@9], otherDict[@9]);
	XCTAssertEqualObjects(mutableDict[@9], referenceMerge[@9]);
	XCTAssertTrue([mutableDict[@9] isKindOfClass:NSMutableDictionary.class]);
}


- (void)testNSMutableDictionary_addEntriesFromDictionaryRecursive_NilDictionary
{
	NSMutableDictionary *dict = @{@1: @"A", @2: @"B"}.mutableCopy;
	NSDictionary *nilDictionary = nil;
	
	//Fills in non-existing keys
	[dict addEntriesFromDictionaryRecursive:nilDictionary];
	NSDictionary *reference = @{@1: @"A", @2: @"B"};
	XCTAssertEqualObjects(dict, reference);
}


- (void)testNSMutableDictionary_addEntriesFromDictionaryRecursive_NonDictionary
{
	NSMutableDictionary *dict = @{@1: @"A", @2: @"B"}.mutableCopy;
	NSDictionary *nonDictionary = (NSDictionary*)NSObject.new;
	
	//Fills in non-existing keys
	
	XCTAssertThrowsSpecificNamed([dict addEntriesFromDictionaryRecursive:nonDictionary], NSException,
								 NSInvalidArgumentException);
}

@end
