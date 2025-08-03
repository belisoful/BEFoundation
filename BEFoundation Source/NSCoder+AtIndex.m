/*!
 @file			NSCoder+AtIndex.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract
 @discussion
*/

#import <objc/runtime.h>
#import "NSSet+BExtension.h"
#import "NSCoder+AtIndex.h"
#import "NSCoder+HalfFloat.h"


/*!
 @category		NSCode (AtIndex)
 @abstract		Adds the encoding and decoding of integer index based keys.
 @discussion	This adds functionality to encode and decode at an index rather
				than a key.  The AtIndex (in each method) is converted into a
 				string of the number to be used as the key for the data.
 */
@implementation NSCoder (AtIndex)

/*!
 @method		-indexKey:
 @abstract		This is a private utility method for changing the signed
 				long long index to a string key for the coder.
 @param			index	The index to convert into an NSString for the Coder.
 @discussion	This adds functionality to encode and decode at an index rather
				than a key.  The AtIndex (in each method) is converted into a
				string of the number to be used as the key for the data.
 */
- (nonnull NSString *)indexKey:(uint64_t)index
{
	return [NSString stringWithFormat:@"%llu", index];
}


/*!
 @method		-encodeObject::
 @abstract		Encodes an object and associates it with the integer index.
 @param			object	The object to encode.
 @param			index	The index to associate the object data with.
 */
- (void)encodeObject:(nullable id)object atIndex:(uint64_t)index
{
	[self encodeObject:object forKey:[self indexKey:index]];
}


/*!
 @method		-encodeConditionalObject::
 @abstract		An encoding method for subclasses to override to conditionally
 				encode an object, preserving common references to it, only if
 				it has been unconditionally encoded.
 @param			index	The index to associate the object data with.
 @discussion	The encoded object is decoded with the decodeObjectForKey:
 				method. If objv was never encoded unconditionally,
 				decodeObjectForKey: returns nil in place of objv.
 */
- (void)encodeConditionalObject:(nullable id)object atIndex:(uint64_t)index
{
	[self encodeConditionalObject:object forKey:[self indexKey:index]];
}

/*!
 @method		-encodeBool::
 @abstract		Encodes a Boolean value and associates it with the integer index.
 @param			value	The BOOL value to encode.
 @param			index	The index to associate the Boolean data with.
 */
- (void)encodeBool:(BOOL)value atIndex:(uint64_t)index
{
	[self encodeBool:value forKey:[self indexKey:index]];
}


/*!
 @method		-encodeInt::
 @abstract		Encodes a C integer value and associates it with the integer
 				index.
 @param			value	The C integer value to encode.
 @param			index	The index to associate the C Integer data with.
 */
- (void)encodeInt:(int)value atIndex:(uint64_t)index
{
	[self encodeInt:value forKey:[self indexKey:index]];
}


/*!
 @method		-encodeInteger::
 @abstract		Encodes a system sized NSInteger value and associates it with
				the integer index.
 @param			value	The system sized NSInteger value to encode.
 @param			index	The index to associate the float data with.
 */
- (void)encodeInteger:(NSInteger)value atIndex:(uint64_t)index
{
	[self encodeInteger:value forKey:[self indexKey:index]];
}


/*!
 @method		-encodeInt32::
 @abstract		Encodes a 32 bit integer value and associates it with the
 				integer index.
 @param			value	The 32 bit integer value to encode.
 @param			index	The index to associate the Integer data with.
 */
- (void)encodeInt32:(int32_t)value atIndex:(uint64_t)index
{
	[self encodeInt32:value forKey:[self indexKey:index]];
}


/*!
 @method		-encodeInt64::
 @abstract		Encodes a 64 bit integer value and associates it with the
				integer index.
 @param			value	The 64 bit integer value to encode.
 @param			index	The index to associate the Integer data with.
 */
- (void)encodeInt64:(int64_t)value atIndex:(uint64_t)index
{
	[self encodeInt64:value forKey:[self indexKey:index]];
}


/*!
 @method		-encodeHalf::
 @abstract		Encodes a 16 bit float value and associates it with the
				integer index.
 @param			value	The 16 bit float value to encode.
 @param			index	The index to associate the float data with.
 */
- (void)encodeHalf:(_Float16)value atIndex:(uint64_t)index
{
	[self encodeHalf:value forKey:[self indexKey:index]];
}


/*!
 @method		-encodeFloat::
 @abstract		Encodes a 32 bit float value and associates it with the
				integer index.
 @param			value	The 32 bit float value to encode.
 @param			index	The index to associate the float data with.
 */
- (void)encodeFloat:(float)value atIndex:(uint64_t)index
{
	[self encodeFloat:value forKey:[self indexKey:index]];
}


/*!
 @method		-encodeDouble::
 @abstract		Encodes a 64 bit float value and associates it with the
				integer index.
 @param			value	The 64 bit float value to encode.
 @param			index	The index to associate the float data with.
 */
- (void)encodeDouble:(double)value atIndex:(uint64_t)index
{
	[self encodeDouble:value forKey:[self indexKey:index]];
}


/*!
 @method		-encodeBytes::
 @abstract		Encodes a buffer of data, given its length and a pointer, and
 				associates it with the integer index.
 @param			bytes	The pointer to the bytes to encode.
 @param			length	The length of data in bytes to encode.
 @param			index	The index to associate the float data with.
 */
- (void)encodeBytes:(nullable const uint8_t *)bytes length:(NSUInteger)length atIndex:(uint64_t)index
{
	[self encodeBytes:bytes length:length forKey:[self indexKey:index]];
}



/*!
 @method		-containsValueAtIndex:
 @abstract		Returns a Boolean value that indicates whether an encoded value
 				is available for a string.
 @param			index	The index to check if it contains data.
 @discussion	The index integer is converted to a string as key.
 @return		Returns YES if the Coder contains data AtIndex.
 */
- (BOOL)containsValueAtIndex:(uint64_t)index
{
	return [self containsValueForKey:[self indexKey:index]];
}




/*!
 @method		-decodeObjectAtIndex:
 @abstract		Decodes and returns a previously-encoded object that was
 				previously encoded with encodeObject:atIndex: or
 				encodeConditionalObject:atIndex: and associated with the
 				integer index.
 @param			index	The integer index of the data to decode.
 @return		The decoded object, or nil if decoding fails.
 */
- (nullable id)decodeObjectAtIndex:(uint64_t)index
{
	return [self decodeObjectForKey:[self indexKey:index]];
}


/*!
 @method		-decodeTopLevelObjectAtIndex:
 @abstract		Decodes the previously-encoded object associated by an integer
 				index, populating an error if decoding fails.
 @param			index	The integer index that identifies the object to decode.
 @param			error	An NSError reference. On return, if this value is not
 				nil, it represents an error encountered while decoding.
 @return		The decoded object, or nil if decoding fails.
 */
- (nullable id)decodeTopLevelObjectAtIndex:(uint64_t)index error:(NSError **)error
{
	return [self decodeTopLevelObjectForKey:[self indexKey:index] error:error];
}


/*!
 @method		-decodeBoolAtIndex:
 @abstract		Decodes and returns a boolean value that was previously encoded
 				with encodeBool:atIndex: and associated with the integer index.
 @param			index	The integer index that identifies the object to decode.
 @return		The decoded Boolean.
 */
- (BOOL)decodeBoolAtIndex:(uint64_t)index
{
	return [self decodeBoolForKey:[self indexKey:index]];
}


/*!
 @method		-decodeIntAtIndex:
 @abstract		Decodes and returns an int value that was previously encoded
				with encodeInt:atIndex:, encodeInteger:atIndex:,
 				encodeInt32:atIndex:, or encodeInt64:atIndex: and associated with
 				the integer index.
 @param			index	The integer index that identifies the object to decode.
 @return		The decoded integer.
 */
- (int)decodeIntAtIndex:(uint64_t)index
{
	return [self decodeIntForKey:[self indexKey:index]];
}


/*!
 @method		-decodeIntegerAtIndex:
 @abstract		Decodes and returns an NSInteger value that was previously
 				encoded with encodeInt:atIndex:, encodeInteger:atIndex:,
 				encodeInt32:atIndex:, or encodeInt64:atIndex: and associated
 				with the integer index.
 @param			index	The integer index that identifies the object to decode.
 @return		The decoded integer.
 */
- (NSInteger)decodeIntegerAtIndex:(uint64_t)index
{
	return [self decodeIntegerForKey:[self indexKey:index]];
}


/*!
 @method		-decodeInt32AtIndex:
 @abstract		Decodes and returns a 32-bit integer value that was previously
 				encoded with encodeInt:atIndex:, encodeInteger:atIndex:,
 				encodeInt32:atIndex:, or encodeInt64:atIndex: and associated
 				with the integer index.
 @param			index	The integer index that identifies the object to decode.
 @return		The decoded integer.
 */
- (int32_t)decodeInt32AtIndex:(uint64_t)index
{
	return [self decodeInt32ForKey:[self indexKey:index]];
}


/*!
 @method		-decodeInt64AtIndex:
 @abstract		Decodes and returns a 64-bit integer value that was previously
 				encoded with encodeInt:atIndex:, encodeInteger:atIndex:,
 				encodeInt32:atIndex:, or encodeInt64:atIndex: and associated
 				with the string key.
 @param			index	The integer index that identifies the object to decode.
 @return		The decoded integer.
 */
- (int64_t)decodeInt64AtIndex:(uint64_t)index
{
	return [self decodeInt64ForKey:[self indexKey:index]];
}


/*!
 @method		-decodeHalfAtIndex:
 @abstract		Decodes and returns a 16-bit float value that was previously
				encoded with encodeHalf:atIndex: and associated with the integer
 				index.
 @param			index	The integer index that identifies the object to decode.
 @return		The decoded `_Float16`.
 */
- (_Float16)decodeHalfAtIndex:(uint64_t)index
{
	return [self decodeHalfForKey:[self indexKey:index]];
}


/*!
 @method		-decodeFloatAtIndex:
 @abstract		Decodes and returns a float value that was previously encoded
 				with encodeFloat:atIndex: or encodeDouble:atIndex: and
 				associated with the string key.
 @param			index	The integer index that identifies the object to decode.
 @return		The decoded float.
 */
- (float)decodeFloatAtIndex:(uint64_t)index
{
	return [self decodeFloatForKey:[self indexKey:index]];
}


/*!
 @method		-decodeDoubleAtIndex:
 @abstract		Decodes and returns a 64 bit double value that was previously
 				encoded with either encodeFloat:atIndex: or encodeDouble:atIndex:
 				and associated with the string key.
 @param			index	The integer index that identifies the object to decode.
 @return		The decoded double.
 */
- (double)decodeDoubleAtIndex:(uint64_t)index
{
	return [self decodeDoubleForKey:[self indexKey:index]];
}


/*!
 @method		-decodeBytesAtIndex::
 @abstract		Decodes a buffer of data that was previously encoded with
 				encodeBytes:length:forKey: and associated with the integer index.
 @param			index	The integer index that identifies the object to decode.
 @param			lengthp	the returned length of the decoded Bytes at the @c index.
 @return		The decoded double.
 @discussion	The buffer’s length is returned by reference in lengthp. The
 				returned bytes are immutable.
 */
- (nullable const uint8_t *)decodeBytesAtIndex:(uint64_t)index returnedLength:(nullable NSUInteger *)lengthp NS_RETURNS_INNER_POINTER
{	//	NS_RETURNS_INNER_POINTER   // returned bytes immutable!
	return [self decodeBytesForKey:[self indexKey:index] returnedLength:lengthp];
}


/*!
 @method		-decodeObjectOfClass::
 @abstract		Decodes an object for the key, restricted to the specified class.
 @param			aClass	The expected class of the object being decoded.
 @param			index	The integer index that identifies the object to decode.
 @discussion	If the coder responds YES to requiresSecureCoding, then an
				exception will be thrown if the class to be decoded does not
 				implement NSSecureCoding or is not isKindOfClass: of aClass.
 
 				If the coder responds NO to requiresSecureCoding, then the class
				argument is ignored and no check of the class of the decoded
 				object is performed, exactly as if decodeObjectForKey: had been
 				called.
 @return		The decoded object.
 */
- (nullable id)decodeObjectOfClass:(Class _Nonnull)aClass atIndex:(uint64_t)index
{
	return [self decodeObjectOfClass:aClass forKey:[self indexKey:index]];
}


/*!
 @method		-decodeTopLevelObjectOfClass:::
 @abstract		Decode an object as an expected type, failing if the archived
 				type does not match.
 @param			aClass	The expected class of the object being decoded.
 @param			index	The integer index that identifies the object to decode.
 @param			error	On return, an NSError indicating why decoding failed,
 						or nil if no error occurred.
 @discussion	If the coder responds YES to requiresSecureCoding, then the
 				coder calls failWithError: in either the following cases:
 
 				- The class indicated by cls does not implement NSSecureCoding.
 				- The unarchived class does not match cls, nor do any of its
 				  superclasses.

				If the coder does not require secure coding, it ignores the cls
 				parameter and does not check the decoded object.
 @return		The decoded object, or nil if decoding fails.
 */
- (nullable id)decodeTopLevelObjectOfClass:(Class)aClass atIndex:(uint64_t)index error:(NSError **)error
{
	return [self decodeTopLevelObjectOfClass:aClass forKey:[self indexKey:index] error:error];
}


/*!
 @method		-decodeArrayOfObjectsOfClass::
 @abstract		Decodes an array of objects for the integer index, restricted
				to the specified class.
 @param			aClass	The expected class of the object being decoded.
 @param			index	The integer index that identifies the object to decode.
 @discussion	Decodes the \c NSArray object for the given  \c index, which
 				should be an \c NSArray<cls>, containing the given
 				non-collection class (no nested arrays or arrays of
 				dictionaries, etc) from the coder.
 
 				
 @return		Returns \c nil if the object for \c index is not of the expected
 				types, or cannot be decoded, and sets the \c error on the
 				decoder.
 @throws		Requires \c NSSecureCoding otherwise an exception is thrown and
 				sets the \c decodingFailurePolicy to
 				\c NSDecodingFailurePolicySetErrorAndReturn.
 */
- (nullable NSArray *)decodeArrayOfObjectsOfClass:(Class)aClass atIndex:(uint64_t)index
{
	return [self decodeArrayOfObjectsOfClass:aClass forKey:[self indexKey:index]];
}


/*!
 @method		-decodeDictionaryWithKeysOfClass:::
 @abstract		Decodes a dictionary of objects for the integer index, restricted
				to the specified key class and object class.
 @param			keyCls		The expected class of the dictionary keys being
 							decoded.
 @param			objectCls	The expected class of the dictionary objects being
 							decoded.
 @param			index		The integer index that identifies the object to
 							decode.
 @return		Returns \c nil if the object for \c index is not of the expected
				types, or cannot be decoded, and sets the \c error on the
				decoder.
 */
- (nullable NSDictionary *)decodeDictionaryWithKeysOfClass:(Class)keyCls objectsOfClass:(Class)objectCls atIndex:(uint64_t)index
{
	return [self decodeDictionaryWithKeysOfClass:keyCls objectsOfClass:objectCls forKey:[self indexKey:index]];
}


/*!
 @method		-decodeObjectOfClasses::
 @abstract		Decodes an object for the integer index, restricted to the
 				specified classes.
 @param			classes		A set of the expected classes.
 @param			index		The integer index that identifies the object to
							decode.
 @discussion	The class of the object may be any class in the classes set, or
 				a subclass of any class in the set. Otherwise, the behavior is
 				the same as decodeObjectOfClass:atIndex:.
 @return		The decoded object.
 */
- (nullable id)decodeObjectOfClasses:(nullable NSSet<Class> *)classes atIndex:(uint64_t)index
{
	return [self decodeObjectOfClasses:classes forKey:[self indexKey:index]];
}


/*!
 @method		-decodeTopLevelObjectOfClasses:::
 @abstract		Decode an object as one of several expected types, failing if
 				the archived type does not match.
 @param			classes		A set of expected classes that the object being
 							decoded should match at least one of.
 @param			index		The integer index that identifies the object to
							decode.
 @param			error		On return, an NSError indicating why decoding
 							failed, or nil if no error occurred.
 @discussion	This method is equivalent to decodeObject(of:forKey:), but
				allows you to specify a set of classes that the decoded object
 				can match. If requiresSecureCoding is YES, the decoded object’s
 				class must be a member of the classes parameter, or a sublcass
 				of a member.
 @return		The decoded object, or nil if decoding fails.
 */
- (nullable id)decodeTopLevelObjectOfClasses:(nullable NSSet<Class> *)classes atIndex:(uint64_t)index error:(NSError **)error
{
	return [self decodeTopLevelObjectOfClasses:classes forKey:[self indexKey:index] error:error];
}


/*!
 @method		-decodeArrayOfObjectsOfClasses::
 @abstract		Decodes an array of objects for the integer index, restricted
				to the specified classes.
 @param			classes	The expected classes of the objects being decoded.
 @param			index	The integer index that identifies the object to decode.
 @discussion	Decodes the \c NSArray object for the given  \c index, which
				contain the given non-collection class (no nested arrays or
 				arrays of dictionaries, etc) from the coder.
 @return		Returns \c nil if the object for \c index is not of the expected
				types, or cannot be decoded, and sets the \c error on the
				decoder.
 @throws		Requires \c NSSecureCoding otherwise an exception is thrown and
				sets the \c decodingFailurePolicy to
				\c NSDecodingFailurePolicySetErrorAndReturn.
 */

- (nullable NSArray *)decodeArrayOfObjectsOfClasses:(NSSet<Class> *)classes atIndex:(uint64_t)index
{
	return [self decodeArrayOfObjectsOfClasses:classes forKey:[self indexKey:index]];
}

/*!
 @method		-decodeDictionaryWithKeysOfClasses:::
 @abstract		Decodes a dictionary of objects for the integer index, restricted
				to the specified key class and object classes.
 @param			keyClasses	The expected classes of the dictionary keys being
							decoded.
 @param			objectClasses The expected classes of the dictionary objects
 							being decoded.
 @param			index		The integer index that identifies the object to
							decode.
 @return		Returns \c nil if the object for \c index is not of the expected
				types, or cannot be decoded, and sets the \c error on the
				decoder.
 */
- (nullable NSDictionary *)decodeDictionaryWithKeysOfClasses:(NSSet<Class> *)keyClasses objectsOfClasses:(NSSet<Class> *)objectClasses atIndex:(uint64_t)index
{
	return [self decodeDictionaryWithKeysOfClasses:keyClasses objectsOfClasses:objectClasses forKey:[self indexKey:index]];
}

/*!
 @method		-decodePropertyListAtIndex:
 @abstract		Decodes a property list for the integer index.
 @param			index	The integer index that identifies the propery list to
 						decode.
 @return		Returns \c nil if the object for \c index is not of the expected
				types, or cannot be decoded, and sets the \c error on the
				decoder.
 */
- (nullable id)decodePropertyListAtIndex:(uint64_t)index
{
	return [self decodePropertyListForKey:[self indexKey:index]];
}


@end
