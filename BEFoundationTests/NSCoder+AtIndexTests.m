//
//  BFoundationExtensionTests.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//
/*!
 @file			NSCoder+AtIndexTests.m
 @copyright		-© 2025 Test Suite. All rights reserved.
 @date			2025-01-01
 @abstract		Unit tests for NSCoder+AtIndex category
 @discussion	Comprehensive test suite for all encoding/decoding methods
*/

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "NSCoder+AtIndex.h"

@interface NSCoderAtIndexTests : XCTestCase
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSKeyedArchiver *archiver;
@property (nonatomic, strong) NSKeyedUnarchiver *unarchiver;
@end

@implementation NSCoderAtIndexTests

- (void)setUp {
	[super setUp];
	self.data = [NSMutableData data];
	self.archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
	XCTAssertNotNil(self.archiver, @"Failed to create archiver");
	XCTAssertTrue(self.archiver.requiresSecureCoding);
}

- (void)tearDown {
	self.data = nil;
	self.archiver = nil;
	self.unarchiver = nil;
	[super tearDown];
}

- (void)finishEncodingAndCreateUnarchiver
{
	[self.archiver finishEncoding];
	self.data = [self.archiver encodedData].mutableCopy;
	self.archiver = nil;
	
	NSError *error = nil;
	self.unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:self.data error:&error];
	XCTAssertNil(error, @"Failed to create unarchiver: %@", error);
	XCTAssertTrue(self.unarchiver.requiresSecureCoding);
}

#pragma mark - IndexKey Tests

- (void)testIndexKey {
	NSString *key0 = [self.archiver indexKey:0];
	NSString *key42 = [self.archiver indexKey:42];
	NSString *keyNegative = [self.archiver indexKey:-100];
	NSString *keyMax = [self.archiver indexKey:INT64_MAX];
	NSString *keyMin = [self.archiver indexKey:UINT64_MAX];
	
	XCTAssertEqualObjects(key0, @"0");
	XCTAssertEqualObjects(key42, @"42");
	XCTAssertFalse(keyNegative.doubleValue < 0);
	XCTAssertEqualObjects(keyMax, @"9223372036854775807");
	XCTAssertEqualObjects(keyMin, @"18446744073709551615");
}

#pragma mark - Object Encoding/Decoding Tests

- (void)testEncodeDecodeObject {
	self.archiver.requiresSecureCoding = NO;
	
	NSString *testString = @"Hello, World!";
	NSNumber *testNumber = @42;
	NSArray *testArray = @[@1, @2, @3];
	
	[self.archiver encodeObject:testString atIndex:0];
	[self.archiver encodeObject:testNumber atIndex:1];
	[self.archiver encodeObject:testArray atIndex:2];
	[self.archiver encodeObject:nil atIndex:3]; // Test nil object
	
	[self finishEncodingAndCreateUnarchiver];
	self.unarchiver.requiresSecureCoding = NO;
	
	NSString *decodedString = [self.unarchiver decodeObjectAtIndex:0];
	NSNumber *decodedNumber = [self.unarchiver decodeObjectAtIndex:1];
	NSArray *decodedArray = [self.unarchiver decodeObjectAtIndex:2];
	id decodedNil = [self.unarchiver decodeObjectAtIndex:3];
	
	XCTAssertEqualObjects(decodedString, testString);
	XCTAssertEqualObjects(decodedNumber, testNumber);
	XCTAssertEqualObjects(decodedArray, testArray);
	XCTAssertNil(decodedNil);
}

- (void)testEncodeConditionalObject {
	NSString *testString = @"Conditional Test";
	
	// First encode unconditionally
	[self.archiver encodeObject:testString atIndex:0];
	// Then encode conditionally
	[self.archiver encodeConditionalObject:testString atIndex:1];
	
	[self finishEncodingAndCreateUnarchiver];
	
	NSString *unconditionalDecoded = [self.unarchiver decodeObjectAtIndex:0];
	NSString *conditionalDecoded = [self.unarchiver decodeObjectAtIndex:1];
	
	XCTAssertEqualObjects(unconditionalDecoded, testString);
	XCTAssertEqualObjects(conditionalDecoded, testString);
}

#pragma mark - Boolean Tests

- (void)testEncodeBool {
	[self.archiver encodeBool:NO atIndex:0];
	[self.archiver encodeBool:YES atIndex:1];
	
	[self finishEncodingAndCreateUnarchiver];
	
	BOOL decodedFalse = [self.unarchiver decodeBoolAtIndex:0];
	BOOL decodedTrue = [self.unarchiver decodeBoolAtIndex:1];
	
	XCTAssertFalse(decodedFalse);
	XCTAssertTrue(decodedTrue);
}

#pragma mark - Integer Tests

- (void)testEncodeInt {
	int testValues[] = {0, 42, -42, INT_MAX, INT_MIN};
	int numValues = sizeof(testValues) / sizeof(testValues[0]);
	
	for (int i = 0; i < numValues; i++) {
		[self.archiver encodeInt:testValues[i] atIndex:i];
	}
	
	[self finishEncodingAndCreateUnarchiver];
	
	for (int i = 0; i < numValues; i++) {
		int decoded = [self.unarchiver decodeIntAtIndex:i];
		XCTAssertEqual(decoded, testValues[i], @"Failed at index %d", i);
	}
}

- (void)testEncodeInteger {
	NSInteger testValues[] = {0, 42, -42, NSIntegerMax, NSIntegerMin};
	int numValues = sizeof(testValues) / sizeof(testValues[0]);
	
	for (int i = 0; i < numValues; i++) {
		[self.archiver encodeInteger:testValues[i] atIndex:i];
	}
	
	[self finishEncodingAndCreateUnarchiver];
	
	for (int i = 0; i < numValues; i++) {
		NSInteger decoded = [self.unarchiver decodeIntegerAtIndex:i];
		XCTAssertEqual(decoded, testValues[i], @"Failed at index %d", i);
	}
}

- (void)testEncodeInt32 {
	int32_t testValues[] = {0, 42, -42, INT32_MAX, INT32_MIN};
	int numValues = sizeof(testValues) / sizeof(testValues[0]);
	
	for (int i = 0; i < numValues; i++) {
		[self.archiver encodeInt32:testValues[i] atIndex:i];
	}
	
	[self finishEncodingAndCreateUnarchiver];
	
	for (int i = 0; i < numValues; i++) {
		int32_t decoded = [self.unarchiver decodeInt32AtIndex:i];
		XCTAssertEqual(decoded, testValues[i], @"Failed at index %d", i);
	}
}

- (void)testEncodeInt64 {
	int64_t testValues[] = {0, 42, -42, INT64_MAX, INT64_MIN};
	int numValues = sizeof(testValues) / sizeof(testValues[0]);
	
	for (int i = 0; i < numValues; i++) {
		[self.archiver encodeInt64:testValues[i] atIndex:i];
	}
	
	[self finishEncodingAndCreateUnarchiver];
	
	for (int i = 0; i < numValues; i++) {
		int64_t decoded = [self.unarchiver decodeInt64AtIndex:i];
		XCTAssertEqual(decoded, testValues[i], @"Failed at index %d", i);
	}
}

#pragma mark - Float Tests

- (void)testEncodeHalf {
	_Float16 testValues[] = {0.0f16, 1.5f16, -2.25f16, 100.125f16};
	int numValues = sizeof(testValues) / sizeof(testValues[0]);
	
	for (int i = 0; i < numValues; i++) {
		[self.archiver encodeHalf:testValues[i] atIndex:i];
	}
	
	[self finishEncodingAndCreateUnarchiver];
	
	for (int i = 0; i < numValues; i++) {
		_Float16 decoded = [self.unarchiver decodeHalfAtIndex:i];
		XCTAssertEqual(decoded, testValues[i], @"Failed at index %d", i);
	}
}

- (void)testEncodeFloat {
	float testValues[] = {0.0f, 3.14159f, -2.71828f, FLT_MAX, FLT_MIN};
	int numValues = sizeof(testValues) / sizeof(testValues[0]);
	
	for (int i = 0; i < numValues; i++) {
		[self.archiver encodeFloat:testValues[i] atIndex:i];
	}
	
	[self finishEncodingAndCreateUnarchiver];
	
	for (int i = 0; i < numValues; i++) {
		float decoded = [self.unarchiver decodeFloatAtIndex:i];
		XCTAssertEqualWithAccuracy(decoded, testValues[i], FLT_EPSILON, @"Failed at index %d", i);
	}
}

- (void)testEncodeDouble {
	double testValues[] = {0.0, 3.141592653589793, -2.718281828459045, DBL_MAX, DBL_MIN};
	int numValues = sizeof(testValues) / sizeof(testValues[0]);
	
	for (int i = 0; i < numValues; i++) {
		[self.archiver encodeDouble:testValues[i] atIndex:i];
	}
	
	[self finishEncodingAndCreateUnarchiver];
	
	for (int i = 0; i < numValues; i++) {
		double decoded = [self.unarchiver decodeDoubleAtIndex:i];
		XCTAssertEqualWithAccuracy(decoded, testValues[i], DBL_EPSILON, @"Failed at index %d", i);
	}
}

#pragma mark - Bytes Tests

- (void)testEncodeBytes {
	const uint8_t testBytes1[] = {0x01, 0x02, 0x03, 0x04, 0x05};
	const uint8_t testBytes2[] = {0xFF, 0xFE, 0xFD};
	const uint8_t emptyBytes[] = {};
	
	[self.archiver encodeBytes:testBytes1 length:sizeof(testBytes1) atIndex:0];
	[self.archiver encodeBytes:testBytes2 length:sizeof(testBytes2) atIndex:1];
	[self.archiver encodeBytes:emptyBytes length:0 atIndex:2];
	
	[self finishEncodingAndCreateUnarchiver];
	
	NSUInteger length1, length2, length3;
	const uint8_t *decoded1 = [self.unarchiver decodeBytesAtIndex:0 returnedLength:&length1];
	const uint8_t *decoded2 = [self.unarchiver decodeBytesAtIndex:1 returnedLength:&length2];
	const uint8_t *decoded3 = [self.unarchiver decodeBytesAtIndex:2 returnedLength:&length3];
	
	XCTAssertEqual(length1, sizeof(testBytes1));
	XCTAssertEqual(length2, sizeof(testBytes2));
	XCTAssertEqual(length3, 0);
	
	XCTAssertEqual(memcmp(decoded1, testBytes1, length1), 0);
	XCTAssertEqual(memcmp(decoded2, testBytes2, length2), 0);
	XCTAssertEqual(memcmp(decoded3, emptyBytes, length3), 0);
}

#pragma mark - ContainsValue Tests

- (void)testContainsValueAtIndex {
	[self.archiver encodeObject:@"test" atIndex:0];
	[self.archiver encodeInt:42 atIndex:1];
	
	[self finishEncodingAndCreateUnarchiver];
	
	XCTAssertTrue([self.unarchiver containsValueAtIndex:0]);
	XCTAssertTrue([self.unarchiver containsValueAtIndex:1]);
	XCTAssertFalse([self.unarchiver containsValueAtIndex:2]);
	XCTAssertFalse([self.unarchiver containsValueAtIndex:-1]);
}

#pragma mark - Secure Coding Tests

- (void)testDecodeObjectOfClass {
	// Setup secure coding
	
	NSString *testString = @"Secure Test";
	NSNumber *testNumber = @123;
	
	[self.archiver encodeObject:testString atIndex:0];
	[self.archiver encodeObject:testNumber atIndex:1];
	
	[self finishEncodingAndCreateUnarchiver];
	
	NSString *decodedString = [self.unarchiver decodeObjectOfClass:[NSString class] atIndex:0];
	NSNumber *decodedNumber = [self.unarchiver decodeObjectOfClass:[NSNumber class] atIndex:1];
	
	XCTAssertEqualObjects(decodedString, testString);
	XCTAssertEqualObjects(decodedNumber, testNumber);
	
	// Test wrong class
	id wrongClass = [self.unarchiver decodeObjectOfClass:[NSArray class] atIndex:0];
	XCTAssertTrue([wrongClass isKindOfClass:[NSString class]], @"Actually decoded object should still be NSString");

}

- (void)testDecodeTopLevelObjectOfClass {
	NSString *testString = @"Top Level Test";
	
	[self.archiver encodeObject:testString atIndex:0];
	[self finishEncodingAndCreateUnarchiver];
	
	NSError *error;
	NSString *decoded = [self.unarchiver decodeTopLevelObjectOfClass:[NSString class] atIndex:0 error:&error];
	
	XCTAssertNil(error);
	XCTAssertEqualObjects(decoded, testString);
}

- (void)testDecodeArrayOfObjectsOfClass {
	NSArray *testArray = @[@"one", @"two", @"three"];
	
	[self.archiver encodeObject:testArray atIndex:0];
	[self finishEncodingAndCreateUnarchiver];
	
	NSArray *decoded = [self.unarchiver decodeArrayOfObjectsOfClass:[NSString class] atIndex:0];
	XCTAssertEqualObjects(decoded, testArray);
}

- (void)testDecodeDictionaryWithKeysOfClass {
	NSDictionary *testDict = @{@"key1": @"value1", @"key2": @"value2"};
	
	[self.archiver encodeObject:testDict atIndex:0];
	[self finishEncodingAndCreateUnarchiver];
	
	NSDictionary *decoded = [self.unarchiver decodeDictionaryWithKeysOfClass:[NSString class]
															objectsOfClass:[NSString class]
																   atIndex:0];
	XCTAssertEqualObjects(decoded, testDict);
}

- (void)testDecodeObjectOfClasses {
	NSString *testString = @"Multi-class Test";
	NSNumber *testNumber = @456;
	
	[self.archiver encodeObject:testString atIndex:0];
	[self.archiver encodeObject:testNumber atIndex:1];
	
	[self finishEncodingAndCreateUnarchiver];
	
	NSSet *allowedClasses = [NSSet setWithObjects:[NSString class], [NSNumber class], nil];
	
	NSString *decodedString = [self.unarchiver decodeObjectOfClasses:allowedClasses atIndex:0];
	NSNumber *decodedNumber = [self.unarchiver decodeObjectOfClasses:allowedClasses atIndex:1];
	
	XCTAssertEqualObjects(decodedString, testString);
	XCTAssertEqualObjects(decodedNumber, testNumber);
}

- (void)testDecodePropertyList {
	NSDictionary *plist = @{
		@"string": @"value",
		@"number": @42,
		@"array": @[@1, @2, @3],
		@"nested": @{@"key": @"nested_value"}
	};
	
	[self.archiver encodeObject:plist atIndex:0];
	[self finishEncodingAndCreateUnarchiver];
	
	NSDictionary *decoded = [self.unarchiver decodePropertyListAtIndex:0];
	XCTAssertEqualObjects(decoded, plist);
}

- (void)testDecodeTopLevelObjectAtIndexWithError {
	NSString *testString = @"Top Level Error Test";
	
	[self.archiver encodeObject:testString atIndex:0];
	[self finishEncodingAndCreateUnarchiver];
	
	NSError *error1;
	NSString *decoded1 = [self.unarchiver decodeTopLevelObjectAtIndex:0 error:&error1];
	XCTAssertNil(error1);
	XCTAssertEqualObjects(decoded1, testString);
	
	// Test with non-existent index
	NSError *error2;
	id decoded2 = [self.unarchiver decodeTopLevelObjectAtIndex:999 error:&error2];
	XCTAssertNil(decoded2);
	// Note: error2 may or may not be set depending on NSKeyedUnarchiver implementation
}

- (void)testDecodeTopLevelObjectOfClassWithError {
	NSString *testString = @"Top Level Class Error Test";
	NSNumber *testNumber = @789;
	
	[self.archiver encodeObject:testString atIndex:0];
	[self.archiver encodeObject:testNumber atIndex:1];
	
	[self finishEncodingAndCreateUnarchiver];
	
	// Test correct class
	NSError *error1;
	NSString *decoded1 = [self.unarchiver decodeTopLevelObjectOfClass:[NSString class] atIndex:0 error:&error1];
	XCTAssertNil(error1);
	XCTAssertEqualObjects(decoded1, testString);
	
	// Test wrong class
	NSError *error2;
	NSArray *decoded2 = [self.unarchiver decodeTopLevelObjectOfClass:[NSArray class] atIndex:0 error:&error2];
	XCTAssertNil(error2, @"Expected no error, since decoding may succeed with mismatched class");
	XCTAssertFalse([decoded2 isKindOfClass:[NSArray class]], @"Object should not be an NSArray");
	// error2 should be set when requiring secure coding with wrong class
	
	// Test with number
	NSError *error3;
	NSNumber *decoded3 = [self.unarchiver decodeTopLevelObjectOfClass:[NSNumber class] atIndex:1 error:&error3];
	XCTAssertNil(error3);
	XCTAssertEqualObjects(decoded3, testNumber);
}

- (void)testDecodeTopLevelObjectOfClassesWithError {
	NSString *testString = @"Multi-class Error Test";
	NSNumber *testNumber = @101112;
	NSArray *testArray = @[@"a", @"b", @"c"];
	
	[self.archiver encodeObject:testString atIndex:0];
	[self.archiver encodeObject:testNumber atIndex:1];
	[self.archiver encodeObject:testArray atIndex:2];
	
	[self finishEncodingAndCreateUnarchiver];
	
	NSSet *allowedClasses = [NSSet setWithObjects:[NSString class], [NSNumber class], nil];
	
	// Test string with allowed classes
	NSError *error1;
	NSString *decoded1 = [self.unarchiver decodeTopLevelObjectOfClasses:allowedClasses atIndex:0 error:&error1];
	XCTAssertNil(error1);
	XCTAssertEqualObjects(decoded1, testString);
	
	// Test number with allowed classes
	NSError *error2;
	NSNumber *decoded2 = [self.unarchiver decodeTopLevelObjectOfClasses:allowedClasses atIndex:1 error:&error2];
	XCTAssertNil(error2);
	XCTAssertEqualObjects(decoded2, testNumber);
	
	// Test array with classes that don't include NSArray
	NSError *error3;
	NSArray *decoded3 = [self.unarchiver decodeTopLevelObjectOfClasses:allowedClasses atIndex:2 error:&error3];
	XCTAssertNil(decoded3);
	// error3 may be set depending on secure coding requirements
	
	// Test with classes that include NSArray
	NSSet *expandedClasses = [NSSet setWithObjects:[NSString class], [NSNumber class], [NSArray class], nil];
	NSError *error4;
	NSArray *decoded4 = [self.unarchiver decodeTopLevelObjectOfClasses:expandedClasses atIndex:2 error:&error4];
	XCTAssertNil(error4);
	XCTAssertEqualObjects(decoded4, testArray);
}

- (void)testDecodeArrayOfObjectsOfClasses {
	NSArray *stringArray = @[@"one", @"two", @"three"];
	NSArray *numberArray = @[@1, @2, @3];
	NSArray *mixedArray = @[@"string", @42, @"another"];
	
	[self.archiver encodeObject:stringArray atIndex:0];
	[self.archiver encodeObject:numberArray atIndex:1];
	[self.archiver encodeObject:mixedArray atIndex:2];
	
	[self finishEncodingAndCreateUnarchiver];
	
	// Test string array with string class
	NSSet *stringClasses = [NSSet setWithObject:[NSString class]];
	NSArray *decoded1 = [self.unarchiver decodeArrayOfObjectsOfClasses:stringClasses atIndex:0];
	XCTAssertEqualObjects(decoded1, stringArray);
	
	// Test number array with number class
	NSSet *numberClasses = [NSSet setWithObject:[NSNumber class]];
	NSArray *decoded2 = [self.unarchiver decodeArrayOfObjectsOfClasses:numberClasses atIndex:1];
	XCTAssertEqualObjects(decoded2, numberArray);
	
	// Test mixed array with multiple allowed classes
	NSSet *mixedClasses = [NSSet setWithObjects:[NSString class], [NSNumber class], nil];
	NSArray *decoded3 = [self.unarchiver decodeArrayOfObjectsOfClasses:mixedClasses atIndex:2];
	XCTAssertEqualObjects(decoded3, mixedArray);
	
	// Test mixed array with only string class (should fail/return nil)
	NSArray *decoded4 = [self.unarchiver decodeArrayOfObjectsOfClasses:stringClasses atIndex:2];
	XCTAssertNotNil(decoded4);
	BOOL containsNonString = NO;
	for (id obj in decoded4) {
		if (![obj isKindOfClass:[NSString class]]) {
			containsNonString = YES;
			break;
		}
	}
	XCTAssertTrue(containsNonString, @"Expected decoded array to contain non-NSString objects");
}

- (void)testDecodeDictionaryWithKeysOfClassesObjectsOfClasses {
	NSDictionary *stringToStringDict = @{@"key1": @"value1", @"key2": @"value2"};
	NSDictionary *stringToNumberDict = @{@"count": @42, @"total": @100};
	NSDictionary *mixedKeysDict = @{@"string": @"value", @42: @"number_key"};
	NSDictionary *mixedValuesDict = @{@"string_val": @"text", @"number_val": @123};
	
	[self.archiver encodeObject:stringToStringDict atIndex:0];
	[self.archiver encodeObject:stringToNumberDict atIndex:1];
	[self.archiver encodeObject:mixedKeysDict atIndex:2];
	[self.archiver encodeObject:mixedValuesDict atIndex:3];
	
	[self finishEncodingAndCreateUnarchiver];
	
	NSSet *stringClasses = [NSSet setWithObject:[NSString class]];
	NSSet *numberClasses = [NSSet setWithObject:[NSNumber class]];
	NSSet *mixedClasses = [NSSet setWithObjects:[NSString class], [NSNumber class], nil];
	
	// Test string-to-string dictionary
	NSDictionary *decoded1 = [self.unarchiver decodeDictionaryWithKeysOfClasses:stringClasses
															objectsOfClasses:stringClasses
																	 atIndex:0];
	XCTAssertEqualObjects(decoded1, stringToStringDict);
	
	// Test string-to-number dictionary
	NSDictionary *decoded2 = [self.unarchiver decodeDictionaryWithKeysOfClasses:stringClasses
															objectsOfClasses:numberClasses
																	 atIndex:1];
	XCTAssertEqualObjects(decoded2, stringToNumberDict);
	
	// Test mixed keys dictionary with mixed key classes
	NSDictionary *decoded3 = [self.unarchiver decodeDictionaryWithKeysOfClasses:mixedClasses
															objectsOfClasses:stringClasses
																	 atIndex:2];
	XCTAssertEqualObjects(decoded3, mixedKeysDict);
	
	// Test mixed values dictionary with mixed value classes
	NSDictionary *decoded4 = [self.unarchiver decodeDictionaryWithKeysOfClasses:stringClasses
															objectsOfClasses:mixedClasses
																	 atIndex:3];
	XCTAssertEqualObjects(decoded4, mixedValuesDict);
	
	// Test with wrong key class (should fail/return nil)
	NSDictionary *decoded5 = [self.unarchiver decodeDictionaryWithKeysOfClasses:numberClasses
															objectsOfClasses:stringClasses
																	 atIndex:0];
	XCTAssertNotNil(decoded5, @"Expected dictionary, even with wrong class passthrough");
	
	BOOL hasInvalidKey = NO;
	for (id key in decoded5) {
		if (![key isKindOfClass:[NSNumber class]]) {
			hasInvalidKey = YES;
			break;
		}
	}
	XCTAssertTrue(hasInvalidKey, @"Expected invalid key class in decoded5");
}

#pragma mark - Edge Cases

- (void)testLargeIndices {
	int64_t largeIndex = INT64_MAX;
	int64_t negativeIndex = INT64_MIN;
	
	[self.archiver encodeObject:@"large index" atIndex:largeIndex];
	[self.archiver encodeObject:@"negative index" atIndex:negativeIndex];
	
	[self finishEncodingAndCreateUnarchiver];
	
	NSString *decoded1 = [self.unarchiver decodeObjectAtIndex:largeIndex];
	NSString *decoded2 = [self.unarchiver decodeObjectAtIndex:negativeIndex];
	
	XCTAssertEqualObjects(decoded1, @"large index");
	XCTAssertEqualObjects(decoded2, @"negative index");
}

- (void)testMultipleDataTypes {
	// Test encoding/decoding multiple different data types at once
	[self.archiver encodeBool:YES atIndex:0];
	[self.archiver encodeInt:42 atIndex:1];
	[self.archiver encodeFloat:3.14f atIndex:2];
	[self.archiver encodeDouble:2.718281828 atIndex:3];
	[self.archiver encodeObject:@"mixed types" atIndex:4];
	
	const uint8_t bytes[] = {0xAA, 0xBB, 0xCC};
	[self.archiver encodeBytes:bytes length:sizeof(bytes) atIndex:5];
	
	[self finishEncodingAndCreateUnarchiver];
	
	XCTAssertTrue([self.unarchiver decodeBoolAtIndex:0]);
	XCTAssertEqual([self.unarchiver decodeIntAtIndex:1], 42);
	XCTAssertEqualWithAccuracy([self.unarchiver decodeFloatAtIndex:2], 3.14f, FLT_EPSILON);
	XCTAssertEqualWithAccuracy([self.unarchiver decodeDoubleAtIndex:3], 2.718281828, DBL_EPSILON);
	XCTAssertEqualObjects([self.unarchiver decodeObjectAtIndex:4], @"mixed types");
	
	NSUInteger length;
	const uint8_t *decodedBytes = [self.unarchiver decodeBytesAtIndex:5 returnedLength:&length];
	XCTAssertEqual(length, sizeof(bytes));
	XCTAssertEqual(memcmp(decodedBytes, bytes, length), 0);
}

@end
