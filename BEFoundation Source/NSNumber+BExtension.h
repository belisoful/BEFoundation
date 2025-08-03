/*!
 @header NSNumber+BExtension.h
 @copyright -© 2025 Delicense - @belisoful. All rights released.
 @date 2025-01-01
 @abstract Mathematical operations extension for NSNumber with type-safe arithmetic operations.
 @discussion This header provides a category extension for NSNumber that enables type-safe mathematical operations between NSNumber instances and primitive types. The extension preserves type precision and handles overflow detection for integer operations. It includes support for basic arithmetic operations (addition, subtraction, multiplication, division), modulus operations, power operations, and bitwise XOR operations.
 
 The implementation uses a type precedence system to determine the appropriate return type based on the operands, ensuring that operations maintain the highest precision required by the input types.
 */

#ifndef NSNumber_BExtension_h
#define NSNumber_BExtension_h

#import <Foundation/Foundation.h>

/*!
 @enum NSNumberMathOperation
 @abstract Enumeration of supported mathematical operations.
 @discussion This enumeration defines the mathematical operations that can be performed using the numberOperation function.
 @constant NSNumberMathOperationAdd Addition operation (+)
 @constant NSNumberMathOperationSubtract Subtraction operation (-)
 @constant NSNumberMathOperationMultiply Multiplication operation (*)
 @constant NSNumberMathOperationDivide Division operation (/)
 @constant NSNumberMathOperationModulus Modulus operation (%)
 @constant NSNumberMathOperationPower Power operation (^)
 @constant NSNumberMathOperationXor Bitwise XOR operation
 */
typedef enum NSNumberMathOperation  {
	NSNumberMathOperationAdd = 1,
	NSNumberMathOperationSubtract = 2,
	NSNumberMathOperationMultiply = 3,
	NSNumberMathOperationDivide = 4,
	NSNumberMathOperationModulus = 5,
	NSNumberMathOperationPower = 6,
	NSNumberMathOperationXor = 7
} NSNumberMathOperation;

/*!
 @function pow_int64
 @abstract Computes integer power using exponentiation by squaring for signed 64-bit integers.
 @discussion This function efficiently computes base^exponent using the exponentiation by squaring algorithm, which provides O(log n) time complexity. It includes overflow detection and returns 0 when overflow occurs. Negative exponents are not supported as they would require floating-point results.
 @param base The base value (signed 64-bit integer)
 @param exponent The exponent value (unsigned 64-bit integer)
 @return The result of base^exponent, or 0 if overflow occurs
 */
int64_t pow_int64(int64_t base, uint64_t exponent);

/*!
 @function pow_uint64
 @abstract Computes integer power using exponentiation by squaring for unsigned 64-bit integers.
 @discussion This function efficiently computes base^exponent using the exponentiation by squaring algorithm for unsigned integers. It includes overflow detection and returns 0 when overflow occurs.
 @param base The base value (unsigned 64-bit integer)
 @param exponent The exponent value (unsigned 64-bit integer)
 @return The result of base^exponent, or 0 if overflow occurs
 */
uint64_t pow_uint64(uint64_t base, uint64_t exponent);

/*!
 @category NSNumber(Extension)
 @abstract Mathematical operations extension for NSNumber.
 @discussion This category extends NSNumber with convenient methods for performing mathematical operations with other NSNumber instances or primitive types. All operations preserve type precision and handle overflow conditions appropriately.
 
 The methods are organized into two groups:
 - Operations with NSNumber instances (addNumber:, subtractNumber:, etc.)
 - Operations with primitive types (addInt:, addUInt:, addDouble:, etc.)
 
 Type precedence follows this order (lowest to highest):
 char, short, int, long, long long, BOOL, unsigned char, unsigned short, unsigned int, unsigned long, unsigned long long, float, double
 */
@interface NSNumber (Extension)

#pragma mark - Operations with NSNumber

/*!
 @method addNumber:
 @abstract Adds another NSNumber to this NSNumber.
 @discussion Performs addition while preserving the highest precision type between the operands.
 @param second The NSNumber to add
 @return A new NSNumber containing the sum
 */
- (NSNumber*)addNumber:(NSNumber*)second;

/*!
 @method subtractNumber:
 @abstract Subtracts another NSNumber from this NSNumber.
 @discussion Performs subtraction while preserving the highest precision type between the operands.
 @param second The NSNumber to subtract
 @return A new NSNumber containing the difference
 */
- (NSNumber*)subtractNumber:(NSNumber*)second;

/*!
 @method multiplyNumber:
 @abstract Multiplies this NSNumber by another NSNumber.
 @discussion Performs multiplication while preserving the highest precision type between the operands.
 @param second The NSNumber to multiply by
 @return A new NSNumber containing the product
 */
- (NSNumber*)multiplyNumber:(NSNumber*)second;

/*!
 @method divideNumber:
 @abstract Divides this NSNumber by another NSNumber.
 @discussion Performs division while preserving the highest precision type between the operands. Returns NaN for integer division by zero, and INFINITY for floating-point division by zero.
 @param second The NSNumber to divide by
 @return A new NSNumber containing the quotient
 */
- (NSNumber*)divideNumber:(NSNumber*)second;

/*!
 @method modulusNumber:
 @abstract Computes the modulus of this NSNumber with another NSNumber.
 @discussion Performs modulus operation while preserving the highest precision type between the operands. For floating-point numbers, uses fmod().
 @param second The NSNumber to compute modulus with
 @return A new NSNumber containing the remainder
 */
- (NSNumber*)modulusNumber:(NSNumber*)second;

/*!
 @method powerNumber:
 @abstract Raises this NSNumber to the power of another NSNumber.
 @discussion Performs exponentiation while preserving the highest precision type between the operands. Uses optimized integer power functions for integer operands.
 @param second The NSNumber exponent
 @return A new NSNumber containing the result
 */
- (NSNumber*)powerNumber:(NSNumber*)second;

/*!
 @method xorNumber:
 @abstract Performs bitwise XOR operation with another NSNumber.
 @discussion Performs bitwise XOR operation. For floating-point numbers, converts to integer before operation.
 @param second The NSNumber to XOR with
 @return A new NSNumber containing the XOR result
 */
- (NSNumber*)xorNumber:(NSNumber*)second;

#pragma mark - Addition Operations with Primitive Types

/*!
 @method addInt:
 @abstract Adds a signed 64-bit integer to this NSNumber.
 @param second The signed integer to add
 @return A new NSNumber containing the sum
 */
- (NSNumber*)addInt:(SInt64)second;

/*!
 @method addUInt:
 @abstract Adds an unsigned 64-bit integer to this NSNumber.
 @param second The unsigned integer to add
 @return A new NSNumber containing the sum
 */
- (NSNumber*)addUInt:(UInt64)second;

/*!
 @method addDouble:
 @abstract Adds a double-precision floating-point number to this NSNumber.
 @param second The double to add
 @return A new NSNumber containing the sum
 */
- (NSNumber*)addDouble:(double)second;

#pragma mark - Subtraction Operations with Primitive Types

/*!
 @method subtractInt:
 @abstract Subtracts a signed 64-bit integer from this NSNumber.
 @param second The signed integer to subtract
 @return A new NSNumber containing the difference
 */
- (NSNumber*)subtractInt:(SInt64)second;

/*!
 @method subtractUInt:
 @abstract Subtracts an unsigned 64-bit integer from this NSNumber.
 @param second The unsigned integer to subtract
 @return A new NSNumber containing the difference
 */
- (NSNumber*)subtractUInt:(UInt64)second;

/*!
 @method subtractDouble:
 @abstract Subtracts a double-precision floating-point number from this NSNumber.
 @param second The double to subtract
 @return A new NSNumber containing the difference
 */
- (NSNumber*)subtractDouble:(double)second;

#pragma mark - Multiplication Operations with Primitive Types

/*!
 @method multiplyInt:
 @abstract Multiplies this NSNumber by a signed 64-bit integer.
 @param second The signed integer to multiply by
 @return A new NSNumber containing the product
 */
- (NSNumber*)multiplyInt:(SInt64)second;

/*!
 @method multiplyUInt:
 @abstract Multiplies this NSNumber by an unsigned 64-bit integer.
 @param second The unsigned integer to multiply by
 @return A new NSNumber containing the product
 */
- (NSNumber*)multiplyUInt:(UInt64)second;

/*!
 @method multiplyDouble:
 @abstract Multiplies this NSNumber by a double-precision floating-point number.
 @param second The double to multiply by
 @return A new NSNumber containing the product
 */
- (NSNumber*)multiplyDouble:(double)second;

#pragma mark - Division Operations with Primitive Types

/*!
 @method divideInt:
 @abstract Divides this NSNumber by a signed 64-bit integer.
 @param second The signed integer to divide by
 @return A new NSNumber containing the quotient
 */
- (NSNumber*)divideInt:(SInt64)second;

/*!
 @method divideUInt:
 @abstract Divides this NSNumber by an unsigned 64-bit integer.
 @param second The unsigned integer to divide by
 @return A new NSNumber containing the quotient
 */
- (NSNumber*)divideUInt:(UInt64)second;

/*!
 @method divideDouble:
 @abstract Divides this NSNumber by a double-precision floating-point number.
 @param second The double to divide by
 @return A new NSNumber containing the quotient
 */
- (NSNumber*)divideDouble:(double)second;

#pragma mark - Modulus Operations with Primitive Types

/*!
 @method modulusInt:
 @abstract Computes the modulus of this NSNumber with a signed 64-bit integer.
 @param second The signed integer to compute modulus with
 @return A new NSNumber containing the remainder
 */
- (NSNumber*)modulusInt:(SInt64)second;

/*!
 @method modulusUInt:
 @abstract Computes the modulus of this NSNumber with an unsigned 64-bit integer.
 @param second The unsigned integer to compute modulus with
 @return A new NSNumber containing the remainder
 */
- (NSNumber*)modulusUInt:(UInt64)second;

/*!
 @method modulusDouble:
 @abstract Computes the modulus of this NSNumber with a double-precision floating-point number.
 @param second The double to compute modulus with
 @return A new NSNumber containing the remainder
 */
- (NSNumber*)modulusDouble:(double)second;

#pragma mark - Power Operations with Primitive Types

/*!
 @method powerUInt:
 @abstract Raises this NSNumber to the power of an unsigned 64-bit integer.
 @discussion Uses optimized integer exponentiation algorithms for better performance and overflow detection.
 @param second The unsigned integer exponent
 @return A new NSNumber containing the result
 */
- (NSNumber*)powerUInt:(UInt64)second;

/*!
 @method powerDouble:
 @abstract Raises this NSNumber to the power of a double-precision floating-point number.
 @param second The double exponent
 @return A new NSNumber containing the result
 */
- (NSNumber*)powerDouble:(double)second;

#pragma mark - Bitwise XOR Operations with Primitive Types

/*!
 @method xorInt:
 @abstract Performs bitwise XOR operation with a signed 64-bit integer.
 @param second The signed integer to XOR with
 @return A new NSNumber containing the XOR result
 */
- (NSNumber*)xorInt:(SInt64)second;

/*!
 @method xorUInt:
 @abstract Performs bitwise XOR operation with an unsigned 64-bit integer.
 @param second The unsigned integer to XOR with
 @return A new NSNumber containing the XOR result
 */
- (NSNumber*)xorUInt:(UInt64)second;

@end

#endif // NSNumber_BExtension_h
