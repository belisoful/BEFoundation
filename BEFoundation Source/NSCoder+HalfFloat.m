/*!
 @file			NSCoder+AtIndex.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		The NSCode Half Category adds encoding and decoding for Half
 				float, `_Float16`
 @discussion	The Half Float is a missing aspect of the basic NSCoder.
*/

#import "NSCoder+HalfFloat.h"

/*!
 @category		NSCode (Half)
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
 @result		Returns a `_Float16` half sized (16 bit) float.
 */
- (_Float16)decodeHalfForKey:(NSString *_Null_unspecified)key
{
	NSUInteger lengthp = 0;
	const void* p = [self decodeBytesForKey:key returnedLength:&lengthp];
	if (!p || lengthp != sizeof(_Float16)) {
		return NAN;
	}
	return *(_Float16 *)p;
}

@end
