/*!
 @header		NSObject+DynamicMethods.h
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract		A comprehensive system for adding and managing dynamic methods to Objective-C objects at runtime using blocks.
 @discussion	This header provides a powerful runtime method injection system that allows you to add methods to existing objects
				and classes using blocks. The system supports both instance methods (added to specific object instances) and
				class methods (added to all instances of a class).
				
				Key Features:
				- Add methods to existing objects without subclassing
				- Support for both instance-specific and class-wide dynamic methods
				- Automatic method signature generation from block signatures
				- Optional selector capture for method implementations
				- Thread-safe method management
				- Memory management with proper cleanup
				
				## Block Signature Requirements
				
				Method implementation blocks must follow this format:
				```
				ReturnType (^)(id self, SEL _cmd, ...parameters)
				```
				
				The `SEL _cmd` parameter is optional. If included, the block will receive the selector
				of the method being called. If omitted, the system automatically adjusts the signature.
				
				## Limitations
				
				NSMethodSignatures cannot properly encode compiler SIMD, vector, or NEON parameter types and will fail.
				Use their base types as arrays or pointers instead for arguments.
				The `_Float16` type also produces errors for malformed Block Signatures.
				
				## Usage Example
				
				```objc
				// Add a dynamic method to a specific object
				NSString *str = @"Hello";
				[str addObjectMethod:@selector(customMethod:) block:^(id self, NSString *param) {
					NSLog(@"Called with: %@", param);
					return [self stringByAppendingString:param];
				}];
				
				// Add a dynamic method to all instances of a class
				[NSString addInstanceMethod:@selector(globalMethod) block:^(id self) {
					return @"Global method called";
				}];
				```
*/

#ifndef NSMethodSignature_BlockSignature_h
#define NSMethodSignature_BlockSignature_h

#import <Foundation/Foundation.h>

@class NSBlock;

#pragma mark - Block Runtime Structures

/*!
 @enum			BlockFlags
 @abstract		Flags that describe the characteristics and capabilities of a block.
 @discussion	These flags are used internally by the block runtime to determine how to handle
				blocks during copying, disposal, and invocation. They are exposed here for
				low-level block introspection.
 @constant		BLOCK_REFCOUNT_MASK		16-bit reference count mask for the block.
 @constant		BLOCK_NEEDS_FREE		Block was allocated and needs to be freed.
 @constant		BLOCK_HAS_COPY_DISPOSE	Block has copy and dispose helper functions.
 @constant		BLOCK_HAS_CTOR			Block has C++ constructor helpers.
 @constant		BLOCK_IS_GC				Block is managed by garbage collection (deprecated).
 @constant		BLOCK_IS_GLOBAL			Block is a global block (allocated in static storage).
 @constant		BLOCK_USE_STRET			Block returns its value in memory (structure return).
 @constant		BLOCK_HAS_SIGNATURE		Block has a type signature.
 @constant		UNKNOWN_BLOCK_FLAG		Reserved for future use.
 */
typedef enum {
	BLOCK_REFCOUNT_MASK =     (0xffff),
	BLOCK_NEEDS_FREE =        (1 << 24),
	BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
	BLOCK_HAS_CTOR =          (1 << 26),
	BLOCK_IS_GC =             (1 << 27),
	BLOCK_IS_GLOBAL =         (1 << 28),
	BLOCK_USE_STRET =         (1 << 29),
	BLOCK_HAS_SIGNATURE =     (1 << 30),
	UNKNOWN_BLOCK_FLAG =	  (1 << 31),
} BlockFlags;

/*!
 @struct		Block_descriptor
 @abstract		Describes the layout and capabilities of a block.
 @discussion	This structure contains metadata about a block, including its size and
				optional helper functions for copying, disposal, and type information.
 @field			reserved		Reserved field, typically NULL.
 @field			size			Size of the block in bytes.
 @field			copy_helper		Optional copy helper function (if BLOCK_HAS_COPY_DISPOSE is set).
 @field			dispose_helper	Optional dispose helper function (if BLOCK_HAS_COPY_DISPOSE is set).
 @field			signature		Optional type signature (if BLOCK_HAS_SIGNATURE is set).
 */
typedef struct Block_descriptor {
	unsigned long int reserved;
	unsigned long int size;
	union {
		struct {
			void (* _Nonnull copy_helper)(void * _Nonnull dst, void * _Nonnull src);
			void (* _Nonnull dispose_helper)(void * _Nonnull src);
			const char * _Nonnull signature;
		} copy_dispose;
		const char * _Nonnull signature;
	};
} Block_descriptor;

/*!
 @struct		Block_literal
 @abstract		The runtime representation of a block object.
 @discussion	This structure defines the memory layout of a block as it exists at runtime.
				It contains the block's class pointer, flags, implementation function, and descriptor.
 @field			isa			Class pointer, typically &_NSConcreteStackBlock or &_NSConcreteGlobalBlock.
 @field			flags		Block flags indicating capabilities and characteristics.
 @field			reserved	Reserved field for alignment.
 @field			invoke		Function pointer to the block's implementation.
 @field			descriptor	Pointer to the block's descriptor structure.
 */
typedef struct Block_literal {
	void * _Nonnull isa;
	int flags;
	int reserved;
	void (*_Nonnull invoke)(struct Block_literal * _Nonnull);
	Block_descriptor * _Nonnull descriptor;
} Block_literal;

/*!
 @defined		NSSignatureForBlock
 @abstract		Macro to extract the type signature from a block.
 @param			block	The block object to examine.
 @discussion	This macro safely extracts the type signature from a block if it has one.
				It handles both blocks with and without copy/dispose helpers.
 @return		A C string containing the block's type signature, or nil if no signature is available.
 */
#define NSSignatureForBlock(block) \
(  (((__bridge Block_literal *)block)->flags & BLOCK_HAS_SIGNATURE) ? \
(\
	(((__bridge Block_literal *)block)->flags & BLOCK_HAS_COPY_DISPOSE) ? \
	((__bridge Block_literal *)block)->descriptor->copy_dispose.signature : ((__bridge Block_literal *)block)->descriptor->signature \
) : \
nil \
	)

#pragma mark - Method Signature Parsing

/*!
 @enum			BEMethodSignatureParseFlags
 @abstract		Flags that control how block signatures are parsed and converted to method signatures.
 @discussion	These flags determine how the block signature parser handles various aspects of
				signature conversion, including block parameter retention and selector handling.
 @constant		BENoMethodSignatureFlag		No special parsing flags.
 @constant		BEKeepBlockArgumentFlag		Keep the block argument in the parsed signature.
 @constant		BERequireSelectorFlag		Require a selector argument in the method signature.
 @constant		BEReplicateSelectorFlag		Replicate the selector argument in the signature.
 */
typedef NS_ENUM(NSInteger, BEMethodSignatureParseFlags) {
	BENoMethodSignatureFlag = 0,
	BEKeepBlockArgumentFlag = (1 << 0),
	BERequireSelectorFlag = (1 << 1),
	BEReplicateSelectorFlag = (1 << 2),
};

#pragma mark - NSMethodSignature Block Extensions

/*!
 @category		NSMethodSignature (BlockMethods)
 @abstract		Extensions to NSMethodSignature for working with blocks.
 @discussion	This category provides methods for creating method signatures from blocks
				and utilities for working with method signature data.
 */
@interface NSMethodSignature (BlockSignatures)

/*!
 @method		signatureFromBlock:
 @abstract		Creates a method signature directly from a block's signature.
 @param			block	The block to extract the signature from.
 @return		An NSMethodSignature object, or nil if the block has no signature.
 @discussion	This method creates a method signature that matches the block's signature exactly.
				The resulting signature includes the block pointer as the first parameter and
				self as the second parameter, as they appear in the block's raw signature.
 */
+ (nullable NSMethodSignature *)signatureFromBlock:(nonnull id)block;

/*!
 @method		methodSignatureFromBlock:
 @abstract		Creates a method signature suitable for dynamic method implementation from a block.
 @param			block	The block to convert to a method signature.
 @return		An NSMethodSignature object suitable for method implementation, or nil if conversion fails.
 @discussion	This method transforms a block signature into a proper method signature by:
				- Removing the initial block pointer parameter
				- Keeping self as the first parameter
				- Adding SEL _cmd as the second parameter if not already present
				
				The resulting signature can be used with class_addMethod or similar runtime functions.
 */
+ (nullable NSMethodSignature *)methodSignatureFromBlock:(nonnull id)block;

/*!
 @property		methodReturnTypeString
 @abstract		The method's return type as a string.
 @return		An NSString containing the encoded return type.
 @discussion	This property provides a convenient way to get the return type as a string
				rather than a C string. Useful for debugging and introspection.
 */
@property (readonly, nonnull) NSString *methodReturnTypeString;

/*!
 @method		getArgumentTypeStringAtIndex:
 @abstract		Returns the type of the argument at the specified index as a string.
 @param			idx		The index of the argument to examine.
 @return		An NSString containing the encoded argument type.
 @discussion	This method converts the C string argument type to an NSString for easier
				handling and comparison. The index follows the same conventions as
				getArgumentTypeAtIndex:.
 */
- (nonnull NSString *)getArgumentTypeStringAtIndex:(NSUInteger)idx;

/*!
 @method		getArgumentSizeAtIndex:
 @abstract		Returns the size in bytes of the argument at the specified index.
 @param			idx		The index of the argument to examine.
 @return		The size of the argument in bytes.
 @discussion	This method provides the size of arguments based on their encoded types.
				It's useful for memory allocation and argument copying operations.
				Returns 0 for unknown or invalid types.
 */
- (NSUInteger)getArgumentSizeAtIndex:(NSUInteger)idx;

@end




#pragma mark - Method Signature Helper

/*!
 @class			BEMethodSignatureHelper
 @abstract		Utility class for parsing and manipulating method signatures.
 @discussion	This class provides low-level utilities for working with block signatures,
				parsing type encodings, and converting between different signature formats.
				It handles the complex task of transforming block signatures into method
				signatures suitable for runtime use.
 */
@interface BEMethodSignatureHelper : NSObject

/*!
 @method		rawBlockSignatureChar:
 @abstract		Extracts the raw type signature from a block as a C string.
 @param			block	The block to examine.
 @return		A C string containing the block's type signature, or NULL if unavailable.
 @discussion	This method directly accesses the block's internal structure to retrieve
				its type signature. The signature includes all parameters, with the block
				pointer as the first parameter and self as the second.
 */
+ (nullable const char *)rawBlockSignatureChar:(nonnull id)block;

/*!
 @method		rawBlockSignatureString:
 @abstract		Extracts the raw type signature from a block as an NSString.
 @param			block	The block to examine.
 @return		An NSString containing the block's type signature, or nil if unavailable.
 @discussion	This method provides the same functionality as rawBlockSignatureChar:
				but returns an NSString for easier handling in Objective-C code.
 */
+ (nullable NSString *)rawBlockSignatureString:(nonnull id)block;

/*!
 @method		blockSignatureString:
 @abstract		Returns a processed block signature string suitable for NSMethodSignature.
 @param			block	The block to process.
 @return		A processed signature string, or nil if processing fails.
 @discussion	This method takes a block's raw signature and processes it to create
				a signature string that can be used with NSMethodSignature. It handles
				the removal of the block parameter and other necessary transformations.
 */
+ (nullable NSString *)blockSignatureString:(nonnull id)block;

/*!
 @method		parseBlockSignature:parseFlags:
 @abstract		Parses a block signature string with specified parsing options.
 @param			signature	The raw signature string to parse.
 @param			flags		Flags controlling the parsing behavior.
 @return		A parsed signature string, or nil if parsing fails.
 @discussion	This method performs the complex task of parsing and transforming block
				signatures. It handles parameter removal, selector injection, and other
				transformations needed to convert block signatures to method signatures.
 */
+ (nullable NSString *)parseBlockSignature:(nonnull const char *)signature parseFlags:(BEMethodSignatureParseFlags)flags;

/*!
 @method		parseTypeAtPointer:
 @abstract		Parses a single type encoding from a signature string.
 @param			pointer	Pointer to the position in the signature string (updated during parsing).
 @return		The parsed type as an NSString, or nil if parsing fails.
 @discussion	This method parses a single type encoding from an Objective-C type signature.
				It handles complex types including structures, unions, arrays, and pointers.
				The pointer parameter is updated to point to the next unparsed character.
 */
+ (nullable NSString *)parseTypeAtPointer:(const char * _Nonnull * _Nonnull)pointer;

/*!
 @method		parseNumberAtPointer:
 @abstract		Parses a number from a signature string.
 @param			pointer	Pointer to the position in the signature string (updated during parsing).
 @return		The parsed number as an NSInteger.
 @discussion	This method parses numeric values from type signatures, such as array sizes,
				structure offsets, and frame sizes. The pointer parameter is updated to
				point to the next unparsed character.
 */
+ (NSInteger)parseNumberAtPointer:(const char * _Nonnull * _Nonnull)pointer;

@end


#endif	//	NSMethodSignature_BlockSignature_h
