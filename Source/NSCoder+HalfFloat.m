/*!
 @file			NSCoder+HalfFloat.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		The NSCoder HalfFloat category adds encoding and decoding for the
 				half-precision float, `_Float16`.
 @discussion	The Half Float is a missing aspect of the basic NSCoder.
*/

#import "NSCoder+HalfFloat.h"

/*!
 @category		NSCoder (HalfFloat)
 @abstract		Adds the encoding and decoding for Half floats.
 @discussion	This uses encodeBytes and decodeBytesForKey to encode and decode
 				the Half Float `_Float16`.
 */
@implementation NSCoder (HalfFloat)

/*!
 @method		-encodeHalf:
 @abstract		Encodes a half sized float and associates it with a string key.
 @param		value	This is the _Float16 to be encoded.
 @param		key		This is the key associated with the @c value.
 */
- (void)encodeHalf:(_Float16)value forKey:(NSString * _Null_unspecified)key
{
	[self encodeBytes:(void*)&value length:sizeof(_Float16) forKey:key];
}


/*!
 @method		-decodeHalfForKey
 @abstract		Decodes a half sized float that was previously encoded with
				encodeHalf:forKey: and associated with the string key.
 @result		Returns the decoded `_Float16`, or 0 if the key is absent or the stored
				data is the wrong size (matching NSCoder's other scalar decoders).
 */
- (_Float16)decodeHalfForKey:(NSString *_Null_unspecified)key
{
	NSUInteger lengthp = 0;
	const void* p = [self decodeBytesForKey:key returnedLength:&lengthp];
	if (!p || lengthp != sizeof(_Float16)) {
		// Match NSCoder's scalar-decode contract (decodeFloatForKey: et al.): a missing or
		// malformed value reads back as zero. Use -containsValueForKey: to detect absence.
		return 0;
	}
	// The coder's inner pointer is not guaranteed to be 2-byte aligned, so copy the bytes out
	// rather than dereferencing a possibly-misaligned _Float16 * (undefined behavior).
	_Float16 value;
	memcpy(&value, p, sizeof(_Float16));
	return value;
}

@end
