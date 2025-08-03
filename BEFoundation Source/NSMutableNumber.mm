/*
 *   Copyright (c) 2015 - 2017 Kulykov Oleh <info@resident.name>
 *
 *   Permission is hereby granted, free of charge, to any person obtaining a copy
 *   of this software and associated documentation files (the "Software"), to deal
 *   in the Software without restriction, including without limitation the rights
 *   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *   copies of the Software, and to permit persons to whom the Software is
 *   furnished to do so, subject to the following conditions:
 *
 *   The above copyright notice and this permission notice shall be included in
 *   all copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *   THE SOFTWARE.
 */
/*
 *   Updated 2025 by belisoful <belisoful@icloud.com> for new functionality
 *   and conformance.
 */


#import "NSMutableNumber.h"
#include "NSMutableNumber.hpp"

@interface NSMutableNumber() {
@private
	NSMPCNumber _number;
}
@end

@implementation NSMutableNumber

#pragma mark - NSSecureCoding
+ (BOOL) supportsSecureCoding {
	return YES;
}

#pragma mark - NSCopying

- (nonnull NSNumber *) copy
{
	return [self copyWithZone:nil];
}

- (NSNumber*) copyWithZone:(nullable NSZone *) zone
{
	_number.lock();
	NSMutableNumber * n = [[NSMutableNumber allocWithZone:zone] init];
	_number.copyDataToNumber(&n->_number);
	_number.unlock();
	return (NSNumber*)n;
}

#pragma mark - NSMutableCopying

- (nonnull NSMutableNumber *) mutableCopy
{
	return [self mutableCopyWithZone:nil];
}


- (nonnull NSMutableNumber *) mutableCopyWithZone:(nullable NSZone *) zone
{
	_number.lock();
	NSMutableNumber * n = [[NSMutableNumber allocWithZone:zone] init];
	_number.copyDataToNumber(&n->_number);
	_number.unlock();
	return n;
}

#pragma mark - NSCoding
- (void) encodeWithCoder:(NSCoder *) coder {
	if (coder) {
		_number.lock();
		const size_t size1 = sizeof(_number.data), size2 = sizeof(_number.serviceInfo);
		uint8_t buff[size1 + size2];
		memcpy(buff, &_number.data, size1);
		memcpy(&buff[size1], &_number.serviceInfo, size2);
		_number.unlock();
		
		// Check if this is a keyed archiver (NSKeyedArchiver) or non-keyed archiver (NSArchiver)
		if ([coder allowsKeyedCoding]) {
			// Keyed archiving (NSKeyedArchiver)
			[coder encodeBytes:buff length:size1 + size2 forKey:@"b"];
		} else {
			// Non-keyed archiving (NSArchiver)
			[coder encodeBytes:buff length:size1 + size2];
		}
	}
}

#pragma mark - NSValue, service getters
- (const char *) objCType {
	return _number.objCtype();
}

- (void) getValue:(nonnull void *) value {
	NSParameterAssert(value);
	_number.getValue(value);
}

- (nonnull instancetype) initWithBytes:(nonnull const void *) value objCType:(nonnull const char *) type {
	self = [super init];
	if (self) {
		NSParameterAssert(value);
		NSParameterAssert(type);
		_number.setWithBytesAndObjCType(value, type);
	}
	return self;
}

- (nullable instancetype) initWithCoder:(nullable NSCoder *) decoder {
	self = [super init];
	if (self) {
		if (decoder) {
			const size_t size1 = sizeof(_number.data);
			const size_t size2 = sizeof(_number.serviceInfo);
			NSUInteger len = 0;
			const uint8_t * bytes = nil;
			
			// Check if this is a keyed archiver or non-keyed archiver
			if ([decoder allowsKeyedCoding]) {
				// Keyed archiving (NSKeyedUnarchiver)
				bytes = [decoder decodeBytesForKey:@"b" returnedLength:&len];
			} else {
				// Non-keyed archiving (NSUnarchiver)
				bytes = (const uint8_t *)[decoder decodeBytesWithReturnedLength:&len];
			}
			
			if (bytes && len == (size1 + size2)) {
				memcpy(&_number.data, bytes, size1);
				memcpy(&_number.serviceInfo, &bytes[size1], size2);
				return self;
			}
		}
	}
	return nil;
}

#pragma mark - NSObject init
- (nonnull instancetype) init {
	self = [super init];
	if (self) _number.set<int>(0, NSMNumberValueTypeI);
	return self;
}

- (Class) classForCoder {
	return [NSMutableNumber class];
}

- (Class) classForKeyedArchiver {
	return [NSMutableNumber class];
}

- (nonnull NSNumber *) immutableCopy {
	NSNumber * immutableNumber = nil;
	_number.lock();
	if (_number.isUnsigned()) {
		if (_number.reserved[0] == sizeof(unsigned char)) immutableNumber = [[NSNumber alloc] initWithUnsignedChar:_number.get<unsigned char>()];
		else if (_number.reserved[0] == sizeof(unsigned short)) immutableNumber = [[NSNumber alloc] initWithUnsignedShort:_number.get<unsigned short>()];
		else if (_number.reserved[0] == sizeof(unsigned int)) immutableNumber = [[NSNumber alloc] initWithUnsignedInt:_number.get<unsigned int>()];
		else immutableNumber = [[NSNumber alloc] initWithUnsignedLongLong:_number.get<unsigned long long>()];
	} else if (_number.isReal()) {
		if (_number.reserved[0] == sizeof(float)) immutableNumber = [[NSNumber alloc] initWithFloat:_number.get<float>()];
		else immutableNumber = [[NSNumber alloc] initWithDouble:_number.get<double>()];
	} else {
		if (_number.reserved[0] == sizeof(char)) immutableNumber = [[NSNumber alloc] initWithChar:_number.get<char>()];
		else if (_number.reserved[0] == sizeof(short)) immutableNumber = [[NSNumber alloc] initWithShort:_number.get<short>()];
		else if (_number.reserved[0] == sizeof(int)) immutableNumber = [[NSNumber alloc] initWithInt:_number.get<int>()];
		else immutableNumber = [[NSNumber alloc] initWithLongLong:_number.get<long long>()];
	}
	_number.unlock();
	return immutableNumber;
}

- (BOOL) isKindOfClass:(Class) aClass {
	return (aClass == [NSNumber class] || aClass == [NSValue class]) ? YES : [super isKindOfClass:aClass];
}

#pragma mark - NSMutableNumber Extensions

- (NSMutableNumber *)bitNot
{
	NSMutableNumber * bitNotNumber = nil;
	_number.lock();
	if (_number.isUnsigned()) {
		if (_number.reserved[0] == sizeof(unsigned char)) bitNotNumber = [[NSMutableNumber alloc] initWithUnsignedChar:~_number.get<unsigned char>()];
		else if (_number.reserved[0] == sizeof(unsigned short)) bitNotNumber = [[NSMutableNumber alloc] initWithUnsignedShort:~_number.get<unsigned short>()];
		else if (_number.reserved[0] == sizeof(unsigned int)) bitNotNumber = [[NSMutableNumber alloc] initWithUnsignedInt:~_number.get<unsigned int>()];
		else bitNotNumber = [[NSMutableNumber alloc] initWithUnsignedLongLong:~_number.get<unsigned long long>()];
	} else if (_number.isReal()) {
		if (_number.reserved[0] == sizeof(float)) bitNotNumber = [[NSMutableNumber alloc] initWithLongLong:~(long long)_number.get<float>()];
		else bitNotNumber = [[NSMutableNumber alloc] initWithLongLong:~(long long)_number.get<double>()];
	} else {
		if (_number.reserved[0] == sizeof(char)) bitNotNumber = [[NSMutableNumber alloc] initWithChar:~_number.get<char>()];
		else if (_number.reserved[0] == sizeof(short)) bitNotNumber = [[NSMutableNumber alloc] initWithShort:~_number.get<short>()];
		else if (_number.reserved[0] == sizeof(int)) bitNotNumber = [[NSMutableNumber alloc] initWithInt:~_number.get<int>()];
		else bitNotNumber = [[NSMutableNumber alloc] initWithLongLong:~_number.get<long long>()];
	}
	_number.unlock();
	return bitNotNumber;
}

- (unsigned long long)bitNotValue
{
	unsigned long long bitNot = 0;
	_number.lock();
	if (_number.isUnsigned()) {
		if (_number.reserved[0] == sizeof(unsigned char)) bitNot = ~_number.get<unsigned char>();
		else if (_number.reserved[0] == sizeof(unsigned short)) bitNot = ~_number.get<unsigned short>();
		else if (_number.reserved[0] == sizeof(unsigned int)) bitNot = ~_number.get<unsigned int>();
		else bitNot = ~_number.get<unsigned long long>();
	} else if (_number.isReal()) {
		if (_number.reserved[0] == sizeof(float)) bitNot = ~(long long)_number.get<float>();
		else bitNot = ~(long long)_number.get<double>();
	} else {
		if (_number.reserved[0] == sizeof(char)) bitNot = ~_number.get<char>();
		else if (_number.reserved[0] == sizeof(short)) bitNot = ~_number.get<short>();
		else if (_number.reserved[0] == sizeof(int)) bitNot = ~_number.get<int>();
		else bitNot = ~_number.get<long long>();
	}
	_number.unlock();
	return bitNot;
}

- (NSMutableNumber *)plusOne
{
	NSMutableNumber * plusOneNumber = nil;
	_number.lock();
	if (_number.isUnsigned()) {
		if (_number.reserved[0] == sizeof(unsigned char)) plusOneNumber = [[NSMutableNumber alloc] initWithUnsignedChar:_number.get<unsigned char>() + 1];
		else if (_number.reserved[0] == sizeof(unsigned short)) plusOneNumber = [[NSMutableNumber alloc] initWithUnsignedShort:_number.get<unsigned short>() + 1];
		else if (_number.reserved[0] == sizeof(unsigned int)) plusOneNumber = [[NSMutableNumber alloc] initWithUnsignedInt:_number.get<unsigned int>() + 1];
		else plusOneNumber = [[NSMutableNumber alloc] initWithUnsignedLongLong:_number.get<unsigned long long>() + 1];
	} else if (_number.isReal()) {
		if (_number.reserved[0] == sizeof(float)) plusOneNumber = [[NSMutableNumber alloc] initWithFloat:_number.get<float>() + 1.0];
		else plusOneNumber = [[NSMutableNumber alloc] initWithDouble:_number.get<double>() + 1.0];
	} else {
		if (_number.reserved[0] == sizeof(char)) plusOneNumber = [[NSMutableNumber alloc] initWithChar:_number.get<char>() + 1];
		else if (_number.reserved[0] == sizeof(short)) plusOneNumber = [[NSMutableNumber alloc] initWithShort:_number.get<short>() + 1];
		else if (_number.reserved[0] == sizeof(int)) plusOneNumber = [[NSMutableNumber alloc] initWithInt:_number.get<int>() + 1];
		else plusOneNumber = [[NSMutableNumber alloc] initWithLongLong:_number.get<long long>() + 1];
	}
	_number.unlock();
	return plusOneNumber;
}


- (NSMutableNumber *)subtractOne
{
	NSMutableNumber * subOneNumber = nil;
	_number.lock();
	if (_number.isUnsigned()) {
		if (_number.reserved[0] == sizeof(unsigned char)) subOneNumber = [[NSMutableNumber alloc] initWithUnsignedChar:_number.get<unsigned char>() - 1];
		else if (_number.reserved[0] == sizeof(unsigned short)) subOneNumber = [[NSMutableNumber alloc] initWithUnsignedShort:_number.get<unsigned short>() - 1];
		else if (_number.reserved[0] == sizeof(unsigned int)) subOneNumber = [[NSMutableNumber alloc] initWithUnsignedInt:_number.get<unsigned int>() - 1];
		else subOneNumber = [[NSMutableNumber alloc] initWithUnsignedLongLong:_number.get<unsigned long long>() - 1];
	} else if (_number.isReal()) {
		if (_number.reserved[0] == sizeof(float)) subOneNumber = [[NSMutableNumber alloc] initWithFloat:_number.get<float>() - 1.0];
		else subOneNumber = [[NSMutableNumber alloc] initWithDouble:_number.get<double>() - 1.0];
	} else {
		if (_number.reserved[0] == sizeof(char)) subOneNumber = [[NSMutableNumber alloc] initWithChar:_number.get<char>() - 1];
		else if (_number.reserved[0] == sizeof(short)) subOneNumber = [[NSMutableNumber alloc] initWithShort:_number.get<short>() - 1];
		else if (_number.reserved[0] == sizeof(int)) subOneNumber = [[NSMutableNumber alloc] initWithInt:_number.get<int>() - 1];
		else subOneNumber = [[NSMutableNumber alloc] initWithLongLong:_number.get<long long>() - 1];
	}
	_number.unlock();
	return subOneNumber;
}

- (NSMutableNumber *)addOne
{
	_number.lock();
	if (_number.isUnsigned()) {
		if (_number.reserved[0] == sizeof(unsigned char)) _number.set<unsigned char>(_number.get<unsigned char>() + 1, NSMNumberValueTypeU);
		else if (_number.reserved[0] == sizeof(unsigned short)) _number.set<unsigned short>(_number.get<unsigned short>() + 1, NSMNumberValueTypeU);
		else if (_number.reserved[0] == sizeof(unsigned int)) _number.set<unsigned int>(_number.get<unsigned int>() + 1, NSMNumberValueTypeU);
		else _number.set<unsigned long long>(_number.get<unsigned long long>() + 1, NSMNumberValueTypeU);
	} else if (_number.isReal()) {
		if (_number.reserved[0] == sizeof(float)) _number.set<float>(_number.get<float>() + 1.0, NSMNumberValueTypeR);
		else _number.set<float>(_number.get<float>() + 1.0, NSMNumberValueTypeR);
	} else {
		if (_number.reserved[0] == sizeof(char)) _number.set<char>(_number.get<char>() + 1, NSMNumberValueTypeI);
		else if (_number.reserved[0] == sizeof(short)) _number.set<short>(_number.get<short>() + 1, NSMNumberValueTypeI);
		else if (_number.reserved[0] == sizeof(int)) _number.set<int>(_number.get<int>() + 1, NSMNumberValueTypeI);
		else _number.set<long long>(_number.get<long long>() + 1, NSMNumberValueTypeI);
	}
	_number.unlock();
	return self;
}


- (NSMutableNumber *) minusOne
{
	_number.lock();
	if (_number.isUnsigned()) {
		if (_number.reserved[0] == sizeof(unsigned char)) _number.set<unsigned char>(_number.get<unsigned char>() - 1, NSMNumberValueTypeU);
		else if (_number.reserved[0] == sizeof(unsigned short)) _number.set<unsigned short>(_number.get<unsigned short>() - 1, NSMNumberValueTypeU);
		else if (_number.reserved[0] == sizeof(unsigned int)) _number.set<unsigned int>(_number.get<unsigned int>() - 1, NSMNumberValueTypeU);
		else _number.set<unsigned long long>(_number.get<unsigned long long>() - 1, NSMNumberValueTypeU);
	} else if (_number.isReal()) {
		if (_number.reserved[0] == sizeof(float)) _number.set<float>(_number.get<float>() - 1.0, NSMNumberValueTypeR);
		else _number.set<float>(_number.get<float>() - 1.0, NSMNumberValueTypeR);
	} else {
		if (_number.reserved[0] == sizeof(char)) _number.set<char>(_number.get<char>() - 1, NSMNumberValueTypeI);
		else if (_number.reserved[0] == sizeof(short)) _number.set<short>(_number.get<short>() - 1, NSMNumberValueTypeI);
		else if (_number.reserved[0] == sizeof(int)) _number.set<int>(_number.get<int>() - 1, NSMNumberValueTypeI);
		else _number.set<long long>(_number.get<long long>() - 1, NSMNumberValueTypeI);
	}
	_number.unlock();
	return self;
}

- (BOOL)isNegativeOne
{
	return [self compare:@-1] == NSOrderedSame;
}

- (BOOL)isZero
{
	return [self compare:@0] == NSOrderedSame;
}

- (BOOL)isPositiveZero
{
	double value = self.doubleValue;
	return value == 0.0 && !signbit(value);
}

- (BOOL)isNegativeZero
{
	double value = self.doubleValue;
	return value == 0.0 && signbit(value);
}

- (BOOL)isOne
{
	return [self compare:@1] == NSOrderedSame;
}

- (BOOL)isTwo
{
	return [self compare:@2] == NSOrderedSame;
}

- (BOOL)isThree
{
	return [self compare:@3] == NSOrderedSame;
}

- (BOOL)isFour
{
	return [self compare:@4] == NSOrderedSame;
}

- (BOOL)isFive
{
	return [self compare:@5] == NSOrderedSame;
}

- (BOOL)isNotANumber
{
	return isnan(self.doubleValue);
}

- (BOOL)isInfinity
{
	return [self compare:@(INFINITY)] == NSOrderedSame;
}

- (BOOL)isNegativeInfinity
{
	return [self compare:@(-INFINITY)] == NSOrderedSame;
}

#pragma mark - NSMutableNumber initializers

- (nonnull NSMutableNumber *) initWithChar:(char) value {
	self = [super init];
	if (self) _number.set<char>(value, NSMNumberValueTypeI);
	return self;
}

- (nonnull NSMutableNumber *) initWithUnsignedChar:(unsigned char) value {
	self = [super init];
	if (self) _number.set<unsigned char>(value, NSMNumberValueTypeU);
	return self;
}

- (nonnull NSMutableNumber *) initWithShort:(short) value {
	self = [super init];
	if (self) _number.set<short>(value, NSMNumberValueTypeI);
	return self;
}

- (nonnull NSMutableNumber *) initWithUnsignedShort:(unsigned short) value {
	self = [super init];
	if (self) _number.set<unsigned short>(value, NSMNumberValueTypeU);
	return self;
}

- (nonnull NSMutableNumber *) initWithUnichar:(unichar) value {
	self = [super init];
	if (self) _number.set<unichar>(value, NSMNumberValueTypeU);
	return self;
}

- (nonnull NSMutableNumber *) initWithInt:(int) value {
	self = [super init];
	if (self) _number.set<int>(value, NSMNumberValueTypeI);
	return self;
}

- (nonnull NSMutableNumber *) initWithUnsignedInt:(unsigned int) value {
	self = [super init];
	if (self) _number.set<unsigned int>(value, NSMNumberValueTypeU);
	return self;
}

- (nonnull NSMutableNumber *) initWithLong:(long) value {
	self = [super init];
	if (self) _number.set<long>(value, NSMNumberValueTypeI);
	return self;
}

- (nonnull NSMutableNumber *) initWithUnsignedLong:(unsigned long) value {
	self = [super init];
	if (self) _number.set<unsigned long>(value, NSMNumberValueTypeU);
	return self;
}

- (nonnull NSMutableNumber *) initWithLongLong:(long long) value {
	self = [super init];
	if (self) _number.set<long long>(value, NSMNumberValueTypeI);
	return self;
}

- (nonnull NSMutableNumber *) initWithUnsignedLongLong:(unsigned long long) value {
	self = [super init];
	if (self) _number.set<unsigned long long>(value, NSMNumberValueTypeU);
	return self;
}

- (nonnull NSMutableNumber *) initWithFloat:(float) value {
	self = [super init];
	if (self) _number.set<float>(value, NSMNumberValueTypeR);
	return self;
}

- (nonnull NSMutableNumber *) initWithDouble:(double) value {
	self = [super init];
	if (self) _number.set<double>(value, NSMNumberValueTypeR);
	return self;
}

- (nonnull NSMutableNumber *) initWithBool:(BOOL) value {
	self = [super init];
	if (self) _number.set<char>(value ? (char)1 : (char)0, NSMNumberValueTypeI);
	return self;
}

- (nonnull NSMutableNumber *) initWithInteger:(NSInteger) value {
	self = [super init];
	if (self) _number.set<NSInteger>(value, NSMNumberValueTypeI);
	return self;
}

- (nonnull NSMutableNumber *) initWithUnsignedInteger:(NSUInteger) value {
	self = [super init];
	if (self) _number.set<NSUInteger>(value, NSMNumberValueTypeU);
	return self;
}

#pragma mark - NSMutableNumber typed getters & setters
- (char) charValue {
	return _number.get<char>();
}

- (void) setCharValue:(char) value {
	_number.set<char>(value, NSMNumberValueTypeI);
}

- (unsigned char) unsignedCharValue {
	return _number.get<unsigned char>();
}

- (void) setUnsignedCharValue:(unsigned char) value {
	_number.set<unsigned char>(value, NSMNumberValueTypeU);
}

- (short) shortValue {
	return _number.get<short>();
}

- (void) setShortValue:(short) value {
	_number.set<short>(value, NSMNumberValueTypeI);
}

- (unsigned short) unsignedShortValue {
	return _number.get<unsigned short>();
}

- (void) setUnsignedShortValue:(unsigned short) value {
	_number.set<unsigned short>(value, NSMNumberValueTypeU);
}

- (unichar) unicharValue {
	return _number.get<unichar>();
}

- (void) setUnicharValue:(unichar) value {
	_number.set<unichar>(value, NSMNumberValueTypeU);
}

- (int) intValue {
	return _number.get<int>();
}

- (void) setIntValue:(int) value {
	_number.set<int>(value, NSMNumberValueTypeI);
}

- (unsigned int) unsignedIntValue {
	return _number.get<unsigned int>();
}

- (void) setUnsignedIntValue:(unsigned int) value {
	_number.set<unsigned int>(value, NSMNumberValueTypeU);
}

- (long) longValue {
	return _number.get<long>();
}

- (void) setLongValue:(long) value {
	_number.set<long>(value, NSMNumberValueTypeI);
}

- (unsigned long) unsignedLongValue {
	return _number.get<unsigned long>();
}

- (void) setUnsignedLongValue:(unsigned long) value {
	_number.set<unsigned long>(value, NSMNumberValueTypeU);
}

- (long long) longLongValue {
	return _number.get<long long>();
}

- (void) setLongLongValue:(long long) value {
	_number.set<long long>(value, NSMNumberValueTypeI);
}

- (unsigned long long) unsignedLongLongValue {
	return _number.get<unsigned long long>();
}

- (void) setUnsignedLongLongValue:(unsigned long long) value {
	_number.set<unsigned long long>(value, NSMNumberValueTypeU);
}

- (float) floatValue {
	return _number.get<float>();
}

- (void) setFloatValue:(float) value {
	_number.set<float>(value, NSMNumberValueTypeR);
}

- (double) doubleValue {
	return _number.get<double>();
}

- (void) setDoubleValue:(double) value {
	_number.set<double>(value, NSMNumberValueTypeR);
}

- (BOOL) boolValue {
	return (_number.get<long long>() == 0) ? NO : YES;
}

- (void) setBoolValue:(BOOL) value {
	_number.set<char>(value ? (char)1 : (char)0, NSMNumberValueTypeI);
}

- (NSInteger) integerValue {
	return _number.get<NSInteger>();
}

- (void) setIntegerValue:(NSInteger) value {
	_number.set<NSInteger>(value, NSMNumberValueTypeI);
}

- (NSUInteger) unsignedIntegerValue {
	return _number.get<NSUInteger>();
}

- (void) setUnsignedIntegerValue:(NSUInteger) value {
	_number.set<NSUInteger>(value, NSMNumberValueTypeU);
}

- (NSString * _Nonnull) stringValue {
	char buff[44];
	_number.copyToString(buff, 44);
	return [NSString stringWithUTF8String:buff];
}

- (NSComparisonResult) compareWithSigned:(nullable id) otherNumber {
	const long long right = [otherNumber longLongValue];
	if (_number.isUnsigned()) {
		if (right < 0) return NSOrderedDescending; // right is negative, while self is positive
		const unsigned long long left = _number.get<unsigned long long>();
		if (left > right) return NSOrderedDescending;
		else if (left < right) return NSOrderedAscending;
	} else if (_number.isReal()) {
		const double left = _number.get<double>();
		if (left > right) return NSOrderedDescending;
		else if (left < right) return NSOrderedAscending;
		else if (isnan(left)) {
			if (right >= 0) return NSOrderedAscending;
			return NSOrderedDescending;
		}
	} else {
		const long long left = _number.get<long long>();
		if (left > right) return NSOrderedDescending;
		else if (left < right) return NSOrderedAscending;
	}
	return NSOrderedSame;
}

- (NSComparisonResult) compareWithUnsigned:(nullable id) otherNumber {
	if (_number.isUnsigned()) {
		const unsigned long long left = _number.get<unsigned long long>();
		const unsigned long long right = [otherNumber unsignedLongLongValue];
		if (left > right) return NSOrderedDescending;
		else if (left < right) return NSOrderedAscending;
	} else if (_number.isReal()) {
		const double left = _number.get<double>();
		const unsigned long long right = [otherNumber unsignedLongLongValue];
		if (left > right) return NSOrderedDescending;
		else if (left < right) return NSOrderedAscending;
		else if (isnan(left)) return NSOrderedAscending;
	} else {
		const long long left = _number.get<long long>();
		if (left < 0) return NSOrderedAscending;
		const unsigned long long right = [otherNumber unsignedLongLongValue];
		if (left < right) return NSOrderedAscending;
		else if (left > right) return NSOrderedDescending;
	}
	return NSOrderedSame;
}

- (NSComparisonResult) compareWithReal:(nullable id) otherNumber {
	const double left = _number.get<double>();
	const double right = [otherNumber doubleValue];
	if (left > right) {
		return NSOrderedDescending;
	} else if (left < right) {
		return NSOrderedAscending;
	} else if (isnan(right)) {
		if (isnan(left)) return NSOrderedSame;
		else if (signbit(left)) return NSOrderedAscending;
		return NSOrderedDescending;
	} else if (isnan(left)) {
		if (signbit(right)) return NSOrderedDescending;
		return NSOrderedAscending;
	}
	return NSOrderedSame;
}

- (NSComparisonResult) compare:(nullable id) object {
	NSComparisonResult r = NSOrderedDescending; // left operand is greater than the right(nil or unsupported)
	_number.lock();
	if (object && ([object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSMutableNumber class]])) {
		const NSUInteger type = NSMNumberCTypeFromEncoded([object objCType]);
		if (NSMNumberCTypeIsUnsigned(type)) r = [self compareWithUnsigned:object];
		else if (NSMNumberCTypeIsReal(type)) r = [self compareWithReal:object];
		else r = [self compareWithSigned:object];
	}
	_number.unlock();
	return r;
}

- (BOOL) isEqualToNumber:(nullable id) number {
	return ([self compare:number] == NSOrderedSame);
}

- (BOOL) isEqual:(id) object {
	return ([self compare:object] == NSOrderedSame);
}

- (nonnull NSString *) descriptionWithLocale:(nullable id) locale {
	return self.stringValue;
}

- (NSString *) debugDescription {
	return self.stringValue;
}

- (NSString *) description {
	return self.stringValue;
}

- (NSUInteger) hash {
	return [[self immutableCopy] hash];
}

@end

#pragma mark - NSMutableNumber static initializers
@implementation NSMutableNumber (NSMutableNumberCreation)


+ (nonnull NSMutableNumber *)infinity { return [[NSMutableNumber alloc] initWithDouble:INFINITY]; }
+ (nonnull NSMutableNumber *)minusInfinity { return [[NSMutableNumber alloc] initWithDouble:-INFINITY]; }
+ (nonnull NSMutableNumber *)notANumber { return [[NSMutableNumber alloc] initWithDouble:NAN]; }
+ (nonnull NSMutableNumber *)zero { return [[NSMutableNumber alloc] initWithLongLong:0]; }
+ (nonnull NSMutableNumber *)negativeZero { return [[NSMutableNumber alloc] initWithDouble:-0.0]; }
+ (nonnull NSMutableNumber *)one { return [[NSMutableNumber alloc] initWithLongLong:1]; }

+ (nonnull NSMutableNumber *) numberWithChar:(char) number { return [[NSMutableNumber alloc] initWithChar:number]; }
+ (nonnull NSMutableNumber *) numberWithUnsignedChar:(unsigned char) number { return [[NSMutableNumber alloc] initWithUnsignedChar:number]; }
+ (nonnull NSMutableNumber *) numberWithShort:(short) number { return [[NSMutableNumber alloc] initWithShort:number]; }
+ (nonnull NSMutableNumber *) numberWithUnsignedShort:(unsigned short) number { return [[NSMutableNumber alloc] initWithUnsignedShort:number]; }
+ (nonnull NSMutableNumber *) numberWithUnichar:(unichar) number { return [[NSMutableNumber alloc] initWithUnichar:number]; }
+ (nonnull NSMutableNumber *) numberWithInt:(int) number { return [[NSMutableNumber alloc] initWithInt:number]; }
+ (nonnull NSMutableNumber *) numberWithUnsignedInt:(unsigned int) number { return [[NSMutableNumber alloc] initWithUnsignedInt:number]; }
+ (nonnull NSMutableNumber *) numberWithLong:(long) number { return [[NSMutableNumber alloc] initWithLong:number]; }
+ (nonnull NSMutableNumber *) numberWithUnsignedLong:(unsigned long) number { return [[NSMutableNumber alloc] initWithUnsignedLong:number]; }
+ (nonnull NSMutableNumber *) numberWithLongLong:(long long) number { return [[NSMutableNumber alloc] initWithLongLong:number]; }
+ (nonnull NSMutableNumber *) numberWithUnsignedLongLong:(unsigned long long) number { return [[NSMutableNumber alloc] initWithUnsignedLongLong:number]; }
+ (nonnull NSMutableNumber *) numberWithFloat:(float) number { return [[NSMutableNumber alloc] initWithFloat:number]; }
+ (nonnull NSMutableNumber *) numberWithDouble:(double) number { return [[NSMutableNumber alloc] initWithDouble:number]; }
+ (nonnull NSMutableNumber *) numberWithBool:(BOOL) number { return [[NSMutableNumber alloc] initWithBool:number]; }
+ (nonnull NSMutableNumber *) numberWithInteger:(NSInteger) number { return [[NSMutableNumber alloc] initWithInteger:number]; }
+ (nonnull NSMutableNumber *) numberWithUnsignedInteger:(NSUInteger) number { return [[NSMutableNumber alloc] initWithUnsignedInteger:number]; }

@end

#pragma mark - NSNumber mutable copy
@implementation NSNumber(NSNumberAlignmentExtension)

- (BOOL)isNegativeOne
{
	return [self compare:@-1] == NSOrderedSame;
}

- (BOOL)isZero
{
	return [self compare:@0] == NSOrderedSame;
}

- (BOOL)isPositiveZero
{
	double value = self.doubleValue;
	return value == 0.0 && !signbit(value);
}

- (BOOL)isNegativeZero
{
	double value = self.doubleValue;
	return value == 0.0 && signbit(value);
}

- (BOOL)isOne
{
	return [self compare:@1] == NSOrderedSame;
}

- (BOOL)isTwo
{
	return [self compare:@2] == NSOrderedSame;
}

- (BOOL)isThree
{
	return [self compare:@3] == NSOrderedSame;
}

- (BOOL)isFour
{
	return [self compare:@4] == NSOrderedSame;
}

- (BOOL)isFive
{
	return [self compare:@5] == NSOrderedSame;
}

- (BOOL)isNotANumber
{
	return isnan(self.doubleValue);
}

- (BOOL)isInfinity
{
	return [self compare:@(INFINITY)] == NSOrderedSame;
}

- (BOOL)isNegativeInfinity
{
	return [self compare:@(-INFINITY)] == NSOrderedSame;
}

+ (NSNumber *)infinity
{
	return @(INFINITY);
}

+ (NSNumber *)minusInfinity
{
	return @(-INFINITY);
}

+ (NSNumber *)notANumber
{
	return @(NAN);
}

+ (NSNumber *)zero
{
	return @(0);
}

+ (NSNumber *)negativeZero
{
	return @(-0.0);
}

+ (NSNumber *)one
{
	return @(1);
}


+ (nonnull NSNumber *) numberWithUnichar:(unichar) number
{
	return [[NSNumber alloc] initWithUnichar:number];
}

- (id) initWithUnichar:(unichar) number
{
	return [self initWithUnsignedShort:(unsigned short)number];
}

- (unichar)unicharValue
{
	return (unichar)[self unsignedShortValue];
}

- (id) mutableCopyWithZone:(NSZone *)zone {
	uint8_t value[32];
	[self getValue:value];
	return [[NSMutableNumber allocWithZone:zone] initWithBytes:value objCType:[self objCType]];
}

- (NSNumber*)bitNot
{
	NSNumber *number = nil;
	switch (NSMNumberCTypeFromEncoded([self objCType])) {
		case NSMNumberCType_BOOL: number = [[NSNumber alloc] initWithBool:!self.boolValue]; break;
		case NSMNumberCType_double: number = [[NSNumber alloc] initWithDouble:~(long long)self.doubleValue]; break;
		case NSMNumberCType_float: number = [[NSNumber alloc] initWithFloat:~(long long)self.floatValue]; break;
		case NSMNumberCType_char: number = [[NSNumber alloc] initWithChar:~self.charValue]; break;
		case NSMNumberCType_unsigned_char: number = [[NSNumber alloc] initWithUnsignedChar:~self.unsignedCharValue]; break;
		case NSMNumberCType_short: number = [[NSNumber alloc] initWithShort:~self.shortValue]; break;
		case NSMNumberCType_unsigned_short: number = [[NSNumber alloc] initWithUnsignedShort:~self.unsignedShortValue]; break;
		case NSMNumberCType_int: number = [[NSNumber alloc] initWithInt:~self.intValue]; break;
		case NSMNumberCType_unsigned_int: number = [[NSNumber alloc] initWithUnsignedInt:~self.unsignedIntValue]; break;
		case NSMNumberCType_long: number = [[NSNumber alloc] initWithLong:~self.longValue]; break;
		case NSMNumberCType_unsigned_long: number = [[NSNumber alloc] initWithUnsignedLong:~self.unsignedLongValue]; break;
		case NSMNumberCType_long_long: number = [[NSNumber alloc] initWithLongLong:~self.longLongValue]; break;
		case NSMNumberCType_unsigned_long_long: number = [[NSNumber alloc] initWithUnsignedLongLong:~self.unsignedLongLongValue]; break;
	}
	return number;
}

- (unsigned long long)bitNotValue
{
	unsigned long long bitNot = 0;
	switch (NSMNumberCTypeFromEncoded([self objCType])) {
		case NSMNumberCType_BOOL: bitNot = ~self.boolValue; break;
		case NSMNumberCType_double: bitNot = ~(long long)self.doubleValue; break;
		case NSMNumberCType_float: bitNot = ~(long long)self.floatValue; break;
		case NSMNumberCType_char: bitNot = ~self.charValue; break;
		case NSMNumberCType_unsigned_char: bitNot = ~self.unsignedCharValue; break;
		case NSMNumberCType_short: bitNot = ~self.shortValue; break;
		case NSMNumberCType_unsigned_short: bitNot = ~self.unsignedShortValue; break;
		case NSMNumberCType_int: bitNot = ~self.intValue; break;
		case NSMNumberCType_unsigned_int: bitNot = ~self.unsignedIntValue; break;
		case NSMNumberCType_long: bitNot = ~self.longValue; break;
		case NSMNumberCType_unsigned_long: bitNot = ~self.unsignedLongValue; break;
		case NSMNumberCType_long_long: bitNot = ~self.longLongValue; break;
		case NSMNumberCType_unsigned_long_long: bitNot = ~self.unsignedLongLongValue; break;
	}
	return bitNot;
}


- (NSNumber*)plusOne
{
	NSNumber *number = nil;
	switch (NSMNumberCTypeFromEncoded([self objCType])) {
		case NSMNumberCType_BOOL: number = [[NSNumber alloc] initWithBool:self.boolValue + 1]; break;
		case NSMNumberCType_double: number = [[NSNumber alloc] initWithDouble:self.doubleValue +1.0]; break;
		case NSMNumberCType_float: number = [[NSNumber alloc] initWithFloat:self.floatValue + 1.0]; break;
		case NSMNumberCType_char: number = [[NSNumber alloc] initWithChar:self.charValue + 1]; break;
		case NSMNumberCType_unsigned_char: number = [[NSNumber alloc] initWithChar:self.unsignedCharValue + 1]; break;
		case NSMNumberCType_short: number = [[NSNumber alloc] initWithShort:self.shortValue + 1]; break;
		case NSMNumberCType_unsigned_short: number = [[NSNumber alloc] initWithUnsignedShort:self.unsignedShortValue + 1]; break;
		case NSMNumberCType_int: number = [[NSNumber alloc] initWithInt:self.intValue + 1]; break;
		case NSMNumberCType_unsigned_int: number = [[NSNumber alloc] initWithUnsignedInt:self.unsignedIntValue + 1]; break;
		case NSMNumberCType_long: number = [[NSNumber alloc] initWithLong:self.longValue + 1]; break;
		case NSMNumberCType_unsigned_long: number = [[NSNumber alloc] initWithUnsignedLong:self.unsignedLongValue + 1]; break;
		case NSMNumberCType_long_long: number = [[NSNumber alloc] initWithLongLong:self.longLongValue + 1]; break;
		case NSMNumberCType_unsigned_long_long: number = [[NSNumber alloc] initWithUnsignedLongLong:self.unsignedLongLongValue + 1]; break;
	}
	return number;
}

- (NSNumber*)subtractOne
{
	NSNumber *number = nil;
	switch (NSMNumberCTypeFromEncoded([self objCType])) {
		case NSMNumberCType_BOOL: number = [[NSNumber alloc] initWithBool:self.boolValue - 1]; break;
		case NSMNumberCType_double: number = [[NSNumber alloc] initWithDouble:self.doubleValue - 1.0]; break;
		case NSMNumberCType_float: number = [[NSNumber alloc] initWithFloat:self.floatValue - 1.0]; break;
		case NSMNumberCType_char: number = [[NSNumber alloc] initWithChar:self.charValue - 1]; break;
		case NSMNumberCType_unsigned_char: number = [[NSNumber alloc] initWithChar:self.unsignedCharValue - 1]; break;
		case NSMNumberCType_short: number = [[NSNumber alloc] initWithShort:self.shortValue - 1]; break;
		case NSMNumberCType_unsigned_short: number = [[NSNumber alloc] initWithUnsignedShort:self.unsignedShortValue - 1]; break;
		case NSMNumberCType_int: number = [[NSNumber alloc] initWithInt:self.intValue - 1]; break;
		case NSMNumberCType_unsigned_int: number = [[NSNumber alloc] initWithUnsignedInt:self.unsignedIntValue - 1]; break;
		case NSMNumberCType_long: number = [[NSNumber alloc] initWithLong:self.longValue - 1]; break;
		case NSMNumberCType_unsigned_long: number = [[NSNumber alloc] initWithUnsignedLong:self.unsignedLongValue - 1]; break;
		case NSMNumberCType_long_long: number = [[NSNumber alloc] initWithLongLong:self.longLongValue - 1]; break;
		case NSMNumberCType_unsigned_long_long: number = [[NSNumber alloc] initWithUnsignedLongLong:self.unsignedLongLongValue - 1]; break;
	}
	return number;
}

@end
