/*
 DELICENSE

 This is free and unencumbered software released into the public domain.

 All are free to copy, modify, publish, use, compile, sell, or
 distribute this software, either in source code form or as a compiled
 binary, for any purpose, commercial or non-commercial, and by any
 means.

 In jurisdictions constructing and/or recognizing copyright, the author
 or authors of this software dedicate any and all copyright interest in the
 software to the public domain. We make this dedication for the universal
 benefit of everyone and to the honor of all as heirs and successors.
 This dedication is an overt act of relinquishment of this software
 under all copyright law, code, articles, regulations, statutes, and treaties.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 -----------
 
 Originated by: Brad Anderson <belisoful@icloud.com>
 
 */

#import "NSMockNumber.h"

@implementation NSMockNumber

#pragma mark - Factory Methods

#define DEFINE_FACTORY_METHOD(SELECTOR, TYPE, ENCODE) \
+ (instancetype)SELECTOR:(TYPE)value { \
	NSNumber *wrappedNumber = [NSNumber SELECTOR:value]; \
	return [NSMockNumber.alloc initWithWrappedNumber:wrappedNumber objCType:ENCODE]; \
}

DEFINE_FACTORY_METHOD(numberWithBool,				BOOL,				@encode(BOOL))

DEFINE_FACTORY_METHOD(numberWithChar,				char,				@encode(char))
DEFINE_FACTORY_METHOD(numberWithUnsignedChar,		unsigned char,		@encode(unsigned char))
DEFINE_FACTORY_METHOD(numberWithShort,				short,				@encode(short))
DEFINE_FACTORY_METHOD(numberWithUnsignedShort,		unsigned short,		@encode(unsigned short))
DEFINE_FACTORY_METHOD(numberWithInt,				int,				@encode(int))
DEFINE_FACTORY_METHOD(numberWithUnsignedInt,		unsigned int,		@encode(unsigned int))
DEFINE_FACTORY_METHOD(numberWithInteger,			NSInteger,			@encode(NSInteger))
DEFINE_FACTORY_METHOD(numberWithUnsignedInteger,	NSUInteger,			@encode(NSUInteger))
DEFINE_FACTORY_METHOD(numberWithLong,				long,				@encode(long))
DEFINE_FACTORY_METHOD(numberWithUnsignedLong,		unsigned long,		@encode(unsigned long))
DEFINE_FACTORY_METHOD(numberWithLongLong,			long long,			@encode(long long))
DEFINE_FACTORY_METHOD(numberWithUnsignedLongLong,	unsigned long long,	@encode(unsigned long long))

DEFINE_FACTORY_METHOD(numberWithFloat,				float,				@encode(float))
DEFINE_FACTORY_METHOD(numberWithDouble,				double,				@encode(double))

#pragma mark - Initializer

- (instancetype)initWithWrappedNumber:(NSNumber *)wrapped objCType:(const char *)type {
	self = [super init];
	if (self) {
		_wrappedValue = wrapped;
		_typeEncoding = type;
	}
	return self;
}

#pragma mark - NSNumber Overrides

- (const char *)objCType {
	return _typeEncoding;
}

- (void)getValue:(void *)value {
	[_wrappedValue getValue:value];
}

- (BOOL)boolValue                { return _wrappedValue.boolValue; }
- (char)charValue                { return _wrappedValue.charValue; }
- (unsigned char)unsignedCharValue   { return _wrappedValue.unsignedCharValue; }
- (short)shortValue              { return _wrappedValue.shortValue; }
- (unsigned short)unsignedShortValue        { return _wrappedValue.unsignedShortValue; }
- (int)intValue                  { return _wrappedValue.intValue; }
- (unsigned int)unsignedIntValue     { return _wrappedValue.unsignedIntValue; }
- (NSInteger)integerValue        { return _wrappedValue.integerValue; }
- (NSUInteger)unsignedIntegerValue          { return _wrappedValue.unsignedIntegerValue; }
- (long)longValue                { return _wrappedValue.longValue; }
- (unsigned long)unsignedLongValue          { return _wrappedValue.unsignedLongValue; }
- (long long)longLongValue       { return _wrappedValue.longLongValue; }
- (unsigned long long)unsignedLongLongValue { return _wrappedValue.unsignedLongLongValue; }
- (float)floatValue              { return _wrappedValue.floatValue; }
- (double)doubleValue            { return _wrappedValue.doubleValue; }

@end
