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

#ifndef NSMockNumber_h
#define NSMockNumber_h

#import <Foundation/Foundation.h>

/*!
 @class			NSMockNumber
 @abstract		This is used to simulate different types of NSNumber encodings that may not be implemented.
 @discussion	NSMockNumber should only be used in Testing environments.
 */

@interface NSMockNumber : NSNumber
@property (nonatomic, strong) NSNumber *wrappedValue;
@property (nonatomic, assign) const char *typeEncoding;

+ (instancetype)numberWithChar:(char)value;
+ (instancetype)numberWithUnsignedChar:(unsigned char)value;
+ (instancetype)numberWithShort:(short)value;
+ (instancetype)numberWithUnsignedShort:(unsigned short)value;
+ (instancetype)numberWithInt:(int)value;
+ (instancetype)numberWithUnsignedInt:(unsigned int)value;
+ (instancetype)numberWithInteger:(NSInteger)value;
+ (instancetype)numberWithUnsignedInteger:(NSUInteger)value;
+ (instancetype)numberWithLong:(long)value;
+ (instancetype)numberWithUnsignedLong:(unsigned long)value;
+ (instancetype)numberWithLongLong:(long long)value;
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value;
+ (instancetype)numberWithFloat:(float)value;
+ (instancetype)numberWithDouble:(double)value;
+ (instancetype)numberWithBool:(BOOL)value;
@end

#endif
