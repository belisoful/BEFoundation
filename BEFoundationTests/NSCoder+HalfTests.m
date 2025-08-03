//
//  BFoundationExtensionTests.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//
#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "NSCoder+HalfFloat.h" // Include your category header

@interface NSCoderHalfTests : XCTestCase
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSKeyedArchiver *archiver;
@property (nonatomic, strong) NSKeyedUnarchiver *unarchiver;
@end

@implementation NSCoderHalfTests

- (void)setUp {
	[super setUp];
	self.data = [NSMutableData data];
	self.archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
	XCTAssertNotNil(self.archiver, @"Failed to create archiver");
}

- (void)tearDown {
	self.data = nil;
	self.archiver = nil;
	self.unarchiver = nil;
	[super tearDown];
}

- (void)finishArchivingAndCreateUnarchiver {
	[self.archiver finishEncoding];
	self.data = [self.archiver encodedData].mutableCopy;
	self.archiver = nil;
	
	NSError *error = nil;
	self.unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:self.data error:&error];
	XCTAssertNotNil(self.unarchiver, @"Failed to create unarchiver: %@", error);
	XCTAssertNil(error, @"Error creating unarchiver: %@", error);
}

#pragma mark - Basic Functionality Tests

- (void)testEncodeDecodePositiveValue {
	_Float16 originalValue = 3.14159f;
	NSString *key = @"testKey";
	
	[self.archiver encodeHalf:originalValue forKey:key];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	XCTAssertEqual(originalValue, decodedValue, @"Decoded value should match original");
	
	[self.unarchiver finishDecoding];
}

- (void)testEncodeDecodeNegativeValue {
	_Float16 originalValue = -2.718f;
	NSString *key = @"negativeKey";
	
	[self.archiver encodeHalf:originalValue forKey:key];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	XCTAssertEqual(originalValue, decodedValue, @"Decoded negative value should match original");
	
	[self.unarchiver finishDecoding];
}

- (void)testEncodeDecodeZero {
	_Float16 originalValue = 0.0f;
	NSString *key = @"zeroKey";
	
	[self.archiver encodeHalf:originalValue forKey:key];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	XCTAssertEqual(originalValue, decodedValue, @"Decoded zero should match original");
	
	[self.unarchiver finishDecoding];
}

- (void)testEncodeDecodeNegativeZero {
	_Float16 originalValue = -0.0f;
	NSString *key = @"negZeroKey";
	
	[self.archiver encodeHalf:originalValue forKey:key];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	// For floating point comparison of negative zero
	XCTAssertEqual(signbit(originalValue), signbit(decodedValue), @"Sign bit should be preserved for negative zero");
	XCTAssertEqual(originalValue, decodedValue, @"Decoded negative zero should match original");
	
	[self.unarchiver finishDecoding];
}

#pragma mark - Special Values Tests

- (void)testEncodeDecodeInfinity {
	_Float16 originalValue = INFINITY;
	NSString *key = @"infinityKey";
	
	[self.archiver encodeHalf:originalValue forKey:key];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	XCTAssertTrue(isinf(decodedValue), @"Decoded value should be infinity");
	XCTAssertEqual(originalValue, decodedValue, @"Decoded infinity should match original");
	
	[self.unarchiver finishDecoding];
}

- (void)testEncodeDecodeNegativeInfinity {
	_Float16 originalValue = -INFINITY;
	NSString *key = @"negInfinityKey";
	
	[self.archiver encodeHalf:originalValue forKey:key];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	XCTAssertTrue(isinf(decodedValue), @"Decoded value should be infinity");
	XCTAssertTrue(signbit(decodedValue), @"Decoded value should be negative infinity");
	XCTAssertEqual(originalValue, decodedValue, @"Decoded negative infinity should match original");
	
	[self.unarchiver finishDecoding];
}

- (void)testEncodeDecodeNaN {
	_Float16 originalValue = NAN;
	NSString *key = @"nanKey";
	
	[self.archiver encodeHalf:originalValue forKey:key];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	XCTAssertTrue(isnan(decodedValue), @"Decoded value should be NaN");
	
	[self.unarchiver finishDecoding];
}

#pragma mark - Edge Cases Tests

- (void)testDecodeNonExistentKey {
	// Don't encode anything, just try to decode
	[self.archiver encodeInt:42 forKey:@"someOtherKey"]; // Encode something else
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:@"nonExistentKey"];
	
	XCTAssertTrue(isnan(decodedValue), @"Decoding non-existent key should return NaN");
	
	[self.unarchiver finishDecoding];
}

- (void)testDecodeWrongDataType {
	NSString *key = @"wrongTypeKey";
	
	// Encode a different type of data with the same key
	[self.archiver encodeInt:42 forKey:key];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	// This should return NaN because the data length doesn't match sizeof(_Float16)
	XCTAssertTrue(isnan(decodedValue), @"Decoding wrong data type should return NaN");
	
	[self.unarchiver finishDecoding];
}

- (void)testMultipleKeysEncoding {
	_Float16 value1 = 1.5f;
	_Float16 value2 = 2.5f;
	_Float16 value3 = -3.5f;
	
	NSString *key1 = @"key1";
	NSString *key2 = @"key2";
	NSString *key3 = @"key3";
	
	[self.archiver encodeHalf:value1 forKey:key1];
	[self.archiver encodeHalf:value2 forKey:key2];
	[self.archiver encodeHalf:value3 forKey:key3];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decoded1 = [self.unarchiver decodeHalfForKey:key1];
	_Float16 decoded2 = [self.unarchiver decodeHalfForKey:key2];
	_Float16 decoded3 = [self.unarchiver decodeHalfForKey:key3];
	
	XCTAssertEqual(value1, decoded1, @"First value should match");
	XCTAssertEqual(value2, decoded2, @"Second value should match");
	XCTAssertEqual(value3, decoded3, @"Third value should match");
	
	[self.unarchiver finishDecoding];
}

- (void)testOverwriteKey {
	NSString *key = @"overwriteKey";
	_Float16 originalValue = 1.0f;
	_Float16 newValue = 2.0f;
	
	[self.archiver encodeHalf:originalValue forKey:key];
	[self.archiver encodeHalf:newValue forKey:key]; // Overwrite
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	XCTAssertEqual(newValue, decodedValue, @"Decoded value should be the last encoded value");
	
	[self.unarchiver finishDecoding];
}

#pragma mark - Boundary Values Tests

- (void)testEncodeDecodeVerySmallValue {
	// Test a very small positive value near the limit of _Float16 precision
	_Float16 originalValue = 0.00006103515625f; // 2^-14, smallest normal _Float16
	NSString *key = @"smallKey";
	
	[self.archiver encodeHalf:originalValue forKey:key];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	XCTAssertEqual(originalValue, decodedValue, @"Very small value should be preserved");
	
	[self.unarchiver finishDecoding];
}

- (void)testEncodeDecodeLargeValue {
	// Test a large value near the limit of _Float16 range
	_Float16 originalValue = 65504.0f; // Largest finite _Float16
	NSString *key = @"largeKey";
	
	[self.archiver encodeHalf:originalValue forKey:key];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	XCTAssertEqual(originalValue, decodedValue, @"Large value should be preserved");
	
	[self.unarchiver finishDecoding];
}

#pragma mark - Nil/Empty Key Tests

- (void)testEncodeWithEmptyKey {
	_Float16 originalValue = 1.0f;
	NSString *key = @""; // Empty string key
	
	[self.archiver encodeHalf:originalValue forKey:key];
	[self finishArchivingAndCreateUnarchiver];
	
	_Float16 decodedValue = [self.unarchiver decodeHalfForKey:key];
	
	XCTAssertEqual(originalValue, decodedValue, @"Empty key should work");
	
	[self.unarchiver finishDecoding];
}

@end
