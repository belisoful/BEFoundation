/*!
 @header		NSCoder+Half.h
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Category extension for NSCoder providing encoding and decoding support for half-precision floats.
 @discussion	This header provides a category extension for NSCoder that adds functionality for
				encoding and decoding half-precision floating-point values (_Float16). The standard
				NSCoder class lacks built-in support for half-precision floats, which are increasingly
				important for memory-efficient applications and GPU computing. This extension fills
				that gap by providing convenient methods that handle the byte-level encoding and
				decoding of _Float16 values.
 */

#ifndef NSCoder_Half_h
#define NSCoder_Half_h

#import <Foundation/Foundation.h>

/*!
 @category		NSCoder (HalfFloat)
 @abstract		Category extension for NSCoder providing half-precision float encoding and decoding.
 @discussion	This category adds methods for encoding and decoding half-precision floating-point
				values (_Float16) to NSCoder. Half-precision floats are 16-bit IEEE 754 floating-point
				numbers that provide a good balance between precision and memory usage. They are
				commonly used in graphics programming, machine learning, and other applications where
				memory efficiency is important.
				
				The implementation uses the existing encodeBytes:length:forKey: and decodeBytesForKey:returnedLength:
				methods to handle the byte-level storage of the _Float16 values, ensuring compatibility
				with all NSCoder subclasses including NSKeyedArchiver and NSKeyedUnarchiver.
 */
@interface NSCoder (HalfFloat)

/*!
 @method		-encodeHalf:forKey:
 @abstract		Encodes a half-precision float value and associates it with a string key.
 @discussion	This method encodes a _Float16 value by converting it to its byte representation
				and storing it using the NSCoder's byte encoding mechanism. The encoded value can
				later be retrieved using decodeHalfForKey: with the same key.
				
				The method handles the conversion from _Float16 to bytes internally, ensuring
				proper byte ordering and alignment for the target platform.
 @param			value The _Float16 half-precision float value to encode.
 @param			key The string key to associate with the encoded value. This key will be used
				to retrieve the value during decoding. Must not be nil.
 @see			decodeHalfForKey:
 */
- (void)encodeHalf:(_Float16)value forKey:(NSString * _Null_unspecified)key;

/*!
 @method		-decodeHalfForKey:
 @abstract		Decodes a half-precision float value that was previously encoded with encodeHalf:forKey:.
 @discussion	This method retrieves and decodes a _Float16 value that was previously stored
				using encodeHalf:forKey: with the same key. The method handles the conversion
				from the stored byte representation back to a _Float16 value.
				
				If the key is not found in the encoded data, or if the stored data is not the
				correct size for a _Float16 value, the method returns NAN to indicate an error
				condition. This provides a safe fallback that won't crash the application.
 @param			key The string key associated with the encoded half-precision float value.
				This should be the same key used when encoding the value.
 @result		Returns the decoded _Float16 value, or NAN if the key is not found or if
				the stored data is invalid.
 @see			encodeHalf:forKey:
 */
- (_Float16)decodeHalfForKey:(NSString * _Null_unspecified)key;

@end

#endif // NSCoder_Half_h
