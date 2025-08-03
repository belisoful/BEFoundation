/*!
 @header		BECharacterSet.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-06-10
 @abstract		This provides a differentiable versions of NSCharacterSet and NSMutableCharacterSet.
 @discussion	BECharacterSet is a replacement for NSCharacterSet, and BEMutableCharacterSet is a
				replacement for NSMutableCharacterSet.
 
				There is no way to programmatically differentiate a NSCharacterSet from a
				NSMutableCharacterSet because both contain the NSCharacterSet and NSMutableCharacterSet
				as a subclass.  As in, instancing a NSCharacterSet will result in a NSMutableCharacterSet.
 
				The BECharacterSet replacement is to provide similar differentiation as NSString vs
				NSMutableString.
*/


#import "BECharacterSet.h"
#import <CoreFoundation/CFCharacterSet.h>
#import <objc/runtime.h>

/*!
 @implementation BECharacterSet
 @abstract		The replacement for NSCharacterSet.
 @discussion	This duplicates the functionality of NSCharacterSet while being differentiable
				from BEMutableCharacterSet.
 */
@implementation BECharacterSet

@synthesize characterSet = _characterSet;

/*!
 @property		isClassEqualToNSCharacterSet
 @abstract		Specifies if the BECharacterSet classes should generally equate to NSCharacterSets.
 @return		the class variable as BECharacterSetEquality, and NSCharacterSetUnequal if unset.
 @discussion	This is used if a specific BECharacterSet is not specifically set to equate to NSCharacterSet.
 */
+ (BECharacterSetEquality)isClassEqualToNSCharacterSet
{
	NSNumber *isNSCharacterSetEqual = objc_getAssociatedObject(self, @selector(isClassEqualToNSCharacterSet));
	if (isNSCharacterSetEqual) {
		return isNSCharacterSetEqual.intValue;
	}
	return NSCharacterSetUnequal;
}

/*!
 @method		setIsClassEqualToNSCharacterSet
 @param			value the value tot set isClassEqualToNSCharacterSet.
 @abstract		Specifies if the BECharacterSet classes should generally equate to NSCharacterSets.
 @discussion	This is used if a specific BECharacterSet is not specifically set to equate to NSCharacterSet.
 */
+ (void)setIsClassEqualToNSCharacterSet:(BECharacterSetEquality)value
{
	if (value < NSCharacterSetAllUnequal) {
		value = NSCharacterSetAllUnequal;
	} else if (value > NSCharacterSetAllEqual) {
		value = NSCharacterSetAllEqual;
	} else if (value == NSCharacterSetClassStyle) {
		objc_setAssociatedObject(self, @selector(isClassEqualToNSCharacterSet), nil, OBJC_ASSOCIATION_ASSIGN);
		return;
	}
	objc_setAssociatedObject(self, @selector(isClassEqualToNSCharacterSet), @(value), OBJC_ASSOCIATION_RETAIN);
}

/*!
 @method		init
 @abstract		Initializes the instance.
 @discussion	This sets the characterSet if a blank NSCharacterSet is set.  This also sets the instance isEqualToNSCharacterSet to
 NSCharacterSetClassStyle unless the isClassEqualToNSCharacterSet is set to NSCharacterSetAllUnequal or NSCharacterSetAllEqual,
 in which case isEqualToNSCharacterSet is then set to NSCharacterSetUnequal or NSCharacterSetEqual, respectively.
 */
- (id)init
{
	self = [super init];
	if (self) {
		if (!_characterSet) {
			_characterSet = NSCharacterSet.new;
		}
		if (self.class.isClassEqualToNSCharacterSet == NSCharacterSetAllUnequal) {
			_isEqualToNSCharacterSet = NSCharacterSetUnequal;
		} else if(self.class.isClassEqualToNSCharacterSet == NSCharacterSetAllEqual) {
			_isEqualToNSCharacterSet = NSCharacterSetEqual;
		} else {
			_isEqualToNSCharacterSet = NSCharacterSetClassStyle;
		}
	}
	return self;
}

/*!
 @method		initWithSet:
 @param			charSet NSCharacterSet or BECharacterSet
 @abstract		Initializes the instance with a specific character set.
 @discussion	This sets the characterSet if none is set.  This also sets the instance isEqualToNSCharacterSet to
 NSCharacterSetClassStyle unless the isClassEqualToNSCharacterSet is set to NSCharacterSetAllUnequal or NSCharacterSetAllEqual,
 in which case isEqualToNSCharacterSet is then set to NSCharacterSetUnequal or NSCharacterSetEqual, respectively.
 */
- (instancetype)initWithSet:(id)charSet
{
	self = [super init];
	if (self) {
		if ([charSet isKindOfClass:BECharacterSet.class]) {
			_characterSet = [((BECharacterSet*)charSet).characterSet copy];
		} else if (charSet) {
			_characterSet = [charSet copy];
		} else {
			_characterSet = [NSCharacterSet characterSetWithCharactersInString:@""];
		}
		if (self.class.isClassEqualToNSCharacterSet == NSCharacterSetAllUnequal) {
			_isEqualToNSCharacterSet = NSCharacterSetUnequal;
		} else if(self.class.isClassEqualToNSCharacterSet == NSCharacterSetAllEqual) {
			_isEqualToNSCharacterSet = NSCharacterSetEqual;
		} else {
			_isEqualToNSCharacterSet = NSCharacterSetClassStyle;
		}
	}
	return self;
}

/*!
 @method		supportsSecureCoding:
 @abstract		Provides support for secure Coding by returning YES for the class method.
 */
+ (BOOL)supportsSecureCoding
{
	return YES;
}

/*!
 @method		initWithCoder:
 @param			coder The coder to decode the Character Set from
 @abstract		Initializes the BECharacterSet from a coder.
 */
- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if (self) {
		NSNumber *isEqualToNSCharacterSet = [[NSNumber alloc] initWithCoder:coder];
		_isEqualToNSCharacterSet = isEqualToNSCharacterSet.intValue;
		
		NSData *bitmapRepresentation = [[NSData alloc] initWithCoder:coder];
		if ([self isKindOfClass:BEMutableCharacterSet.class]) {
			_characterSet = [NSMutableCharacterSet characterSetWithBitmapRepresentation:bitmapRepresentation];
		} else {
			_characterSet = [NSCharacterSet characterSetWithBitmapRepresentation:bitmapRepresentation];
		}
	}
	return self;
}

/*!
 @method		encodeWithCoder:
 @param			coder The NSCoder to encode the object into.
 @abstract		Provides support for secure Coding by returning YES for the class method.
				This method supports both BECharacterSet and BEMutableCharacterSet.
 */
- (void)encodeWithCoder:(nonnull NSCoder *)coder {
	[@(_isEqualToNSCharacterSet) encodeWithCoder:coder];
	[_characterSet.bitmapRepresentation encodeWithCoder:coder];
}

/*!
 @method		copyWithZone:
 @param			zone The zone to allocate memory from; may be null.
 @abstract		Copies an BECharacterSet or BEMutableCharacterSet into a BECharacterSet.
 */
- (id)copyWithZone:(nullable NSZone *)zone
{
	if([self isMemberOfClass: BECharacterSet.class]) {
		return self;
	}
	return [[BECharacterSet allocWithZone:zone] initWithSet:_characterSet];
}

/*!
 @method		mutableCopyWithZone:
 @param			zone The zone to allocate memory from; may be null.
 @abstract		Copies an  BEMutableCharacterSet or BECharacterSet into a BEMutableCharacterSet.
 */
- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
	return [[BEMutableCharacterSet allocWithZone:zone] initWithSet:_characterSet];
}

/*!
 @method		hash
 @abstract		This returns the hash of the characterSet NSCharacterSet, possibly xor-ed.
 @discussion	If and when the instance or class is set to not equate to NSCharacterSet,
				then this will xor the NSCharacterSet hash with a static number.
				The static number does not change over time and provides BECharacterSet
				hash to be equal if the character sets are the same.
 */
- (NSUInteger)hash
{
	BECharacterSetEquality type = _isEqualToNSCharacterSet ? _isEqualToNSCharacterSet : self.class.isClassEqualToNSCharacterSet;
	NSUInteger hash = [self.characterSet hash];
	if (type <= 0) {
		hash ^= 0x8af00839efdd24bf;
	}
	return hash;
}

/*!
 @method		isEqual
 @param			object The object to check against.
 @abstract		This equates BECharacterSet.characterSet and, upon setting equality, NSCharacterSet.
 @discussion	This checks for equality of the characterSet property.  If
 */
- (BOOL)isEqual:(id)object
{
	if (self == object) {
		return YES;
	}
	
	BECharacterSetEquality type = _isEqualToNSCharacterSet ? _isEqualToNSCharacterSet : self.class.isClassEqualToNSCharacterSet;
	NSCharacterSet *charset = nil;
	
	if ([object isKindOfClass:BECharacterSet.class]) {
		charset = ((BECharacterSet*)object).characterSet;
	} else if (type > 0 && [object isKindOfClass:NSCharacterSet.class]) {
		charset = object;
	} else {
		return NO;
	}
	return [self.characterSet isEqual:charset];
}

/*!
 @property		characterSet
 @abstract		This is the reference to the internal NSCharacterSet.
 @return		Returns the instance NSCharacterSet
 */
- (NSCharacterSet *)characterSet
{
	return _characterSet;
}

/*!
 @property		controlCharacterSet
 @abstract		A character set containing the characters in Unicode General Category Cc and Cf.
 @return		A character set containing all the control characters.
 @discussion	These characters include, for example, the soft hyphen (U+00AD),
				control characters to support bi-directional text, and IETF language tag characters.
 */
+ (BECharacterSet *)controlCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.controlCharacterSet];
}

/*!
 @property		whitespaceCharacterSet
 @abstract		A character set containing the characters in Unicode General Category Zs and CHARACTER TABULATION (U+0009).
 @return		A character set containing all the whitespace characters.
 @discussion	This set doesn’t contain the newline or carriage return characters.
 */
+ (BECharacterSet *)whitespaceCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.whitespaceCharacterSet];
}

/*!
 @property		whitespaceAndNewlineCharacterSet
 @abstract		A character set containing characters in Unicode General Category Z*, U+000A ~ U+000D, and U+0085.
 @return		A character set containing all the whitespace and newline characters.
 */
+ (BECharacterSet *)whitespaceAndNewlineCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

/*!
 @property		decimalDigitCharacterSet
 @abstract		A character set containing the characters in the category of Decimal Numbers.
 @return		A character set containing all the decimal digit characters.
 @discussion	Informally, this set is the set of all characters used to represent the decimal values 0 through 9. These characters include, for example, the decimal digits of the Indic scripts and Arabic.
 */
+ (BECharacterSet *)decimalDigitCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.decimalDigitCharacterSet];
}

/*!
 @property		letterCharacterSet
 @abstract		A character set containing the characters in Unicode General Category L* & M*.
 @return		A character set containing all the letter characters.
 @discussion	Informally, this set is the set of all characters used as letters of alphabets and ideographs.
 */
+ (BECharacterSet *)letterCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.letterCharacterSet];
}

/*!
 @property		lowercaseLetterCharacterSet
 @abstract		A character set containing the characters in Unicode General Category Ll.
 @return		A character set containing all the lowercase letter characters.
 @discussion	Informally, this set is the set of all characters used as lowercase letters in alphabets that make case distinctions.
 */
+ (BECharacterSet *)lowercaseLetterCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.lowercaseLetterCharacterSet];
}

/*!
 @property		uppercaseLetterCharacterSet
 @abstract		A character set containing the characters in Unicode General Category Lu and Lt.
 @return		A character set containing all the uppercase letter characters.
 @discussion	Informally, this set is the set of all characters used as uppercase letters in alphabets that make case distinctions.
 */
+ (BECharacterSet *)uppercaseLetterCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.uppercaseLetterCharacterSet];
}

/*!
 @property		nonBaseCharacterSet
 @abstract		A character set containing the characters in Unicode General Category M*.
 @return		A character set containing all the non-base characters.
 @discussion	This set is also defined as all legal Unicode characters with a non-spacing priority greater than 0. Informally, this set is the set of all characters used as modifiers of base characters.
 */
+ (BECharacterSet *)nonBaseCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.nonBaseCharacterSet];
}

/*!
 @property		alphanumericCharacterSet
 @abstract		A character set containing the characters in Unicode General Categories L*, M*, and N*.
 @return		A character set containing all the alphanumeric characters.
 @discussion	Informally, this set is the set of all characters used as basic units of alphabets, syllabaries, ideographs, and digits.
 */
+ (BECharacterSet *)alphanumericCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.alphanumericCharacterSet];
}

/*!
 @property		decomposableCharacterSet
 @abstract		A character set containing individual Unicode characters that can also
				be represented as composed character sequences (such as for letters with accents),
				by the definition of “standard decomposition” in version 3.2 of the Unicode
				character encoding standard.
 @return		A character set containing all the decomposable characters.
 @discussion	These characters include compatibility characters as well as pre-composed characters.
 @note			This character set doesn’t currently include the Hangul characters defined in version 2.0 of the Unicode standard.
 */
+ (BECharacterSet *)decomposableCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.decomposableCharacterSet];
}

/*!
 @property		illegalCharacterSet
 @abstract		A character set containing values in the category of Non-Characters or
				that have not yet been defined in version 3.2 of the Unicode standard.
 @return		A character set containing all the illegal characters.
 */
+ (BECharacterSet *)illegalCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.illegalCharacterSet];
}

/*!
 @property		punctuationCharacterSet
 @abstract		A character set containing the characters in Unicode General Category P*.
 @return		A character set containing all the punctuation characters.
 @discussion	Informally, this set is the set of all non-whitespace characters used to
				separate linguistic units in scripts, such as periods, dashes, parentheses, and so on.
 */
+ (BECharacterSet *)punctuationCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.punctuationCharacterSet];
}

/*!
 @property		capitalizedLetterCharacterSet
 @abstract		A character set containing the characters in Unicode General Category Lt.
 @return		A character set containing all the capitalized letter characters.
 */
+ (BECharacterSet *)capitalizedLetterCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.capitalizedLetterCharacterSet];
}

/*!
 @property		symbolCharacterSet
 @abstract		A character set containing the characters in Unicode General Category S*.
 @return		A character set containing all the symbol characters.
 @discussion	These characters include, for example, the dollar sign ($) and the plus (+) sign.
 */
+ (BECharacterSet *)symbolCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.symbolCharacterSet];
}

/*!
 @property		newlineCharacterSet
 @abstract		A character set containing the newline characters (U+000A ~ U+000D, U+0085, U+2028, and U+2029).
 @return		A character set containing all the newline characters.
 */
+ (BECharacterSet *)newlineCharacterSet
{
	return [[BECharacterSet alloc] initWithSet:NSCharacterSet.newlineCharacterSet];
}

/*!
 @method		characterSetWithRange:
 @param			aRange A range of Unicode values. aRange.location is the value of the first character to return; aRange.location + aRange.length – 1 is the value of the last.
 @abstract		Returns a character set containing characters with Unicode values in a given range.
 @return		A character set containing characters whose Unicode values are given by aRange. If aRange.length is 0, returns an empty character set.
 @discussion	This code excerpt creates a character set object containing the lowercase English alphabetic characters:
 ```
 NSRange lcEnglishRange;
 NSCharacterSet *lcEnglishLetters;
  
 lcEnglishRange.location = (unsigned int)'a';
 lcEnglishRange.length = 26;
 lcEnglishLetters = [NSCharacterSet characterSetWithRange:lcEnglishRange];
 ```
 */
+ (BECharacterSet *)characterSetWithRange:(NSRange)aRange
{
	return [[BECharacterSet alloc] initWithSet:[NSCharacterSet characterSetWithRange:aRange]];
}

/*!
 @method		characterSetWithCharactersInString:
 @param			aString A string containing characters for the new character set.
 @abstract		Returns a character set containing the characters in a given string.
 @return		A character set containing the characters in aString. Returns an empty character set if aString is empty.
 */
+ (BECharacterSet *)characterSetWithCharactersInString:(NSString *)aString
{
	return [[BECharacterSet alloc] initWithSet:[NSCharacterSet characterSetWithCharactersInString:aString]];
}

/*!
 @method		characterSetWithBitmapRepresentation:
 @param			data A bitmap representation of a character set.
 @abstract		Returns a character set containing characters determined by a given bitmap representation.
 @return		A character set containing characters determined by data.
 @discussion	This method is useful for creating a character set object with data
				from a file or other external data source.
 
				A raw bitmap representation of a character set is a byte array with the first 2^16 bits (that is, 8192 bytes) representing the code point range of the the Basic Multilingual Plane (BMP), such that the value of the bit at position n represents the presence in the character set of the character with decimal Unicode value n. A bitmap representation may contain zero to sixteen additional 8192 byte segments to for each additional Unicode plane containing a character in a character set, with each 8192 byte segment prepended with a single plane index byte.
 
 To add a character in the Basic Multilingual Plane (BMP) with decimal Unicode value n to a raw bitmap representation, you might do the following:
 ```
 unsigned char bitmapRep[8192];
 bitmapRep[n >> 3] |= (((unsigned int)1) << (n & 7));
 ```
 
 To remove that character:
 ```
 bitmapRep[n >> 3] &= ~(((unsigned int)1) << (n & 7));
 ```
 */
+ (BECharacterSet *)characterSetWithBitmapRepresentation:(NSData *)data
{
	return [[BECharacterSet alloc] initWithSet:[NSCharacterSet characterSetWithBitmapRepresentation:data]];
}

/*!
 @method		characterSetWithContentsOfFile:
 @param			fName A path to a file containing a bitmap representation of a character set. The path name must end with the extension .bitmap.
 @abstract		Returns a character set read from the bitmap representation stored in the file a given path.
 @return		A character set read from the bitmap representation stored in the file at path.
 @discussion	This method doesn’t use filenames to check for the uniqueness of the character sets it creates. To prevent duplication of character sets in memory, cache them and make them available through an API that checks whether the requested set has already been loaded.
 
 To read a bitmap representation from any file, use the NSData methoddataWithContentsOfFile:options:error: and pass the result to characterSetWithBitmapRepresentation:.
 */
+ (BECharacterSet *)characterSetWithContentsOfFile:(NSString *)fName
{
	return [[BECharacterSet alloc] initWithSet:[NSCharacterSet characterSetWithContentsOfFile:fName]];
}

/*!
 @method		characterIsMember:
 @param			aCharacter The character to test for membership of the receiver.
 @abstract		Returns a Boolean value that indicates whether a given character is in the receiver.
 @return		true if aCharacter is in the receiving character set, otherwise false.
 */
- (BOOL)characterIsMember:(unichar)aCharacter
{
	return [self.characterSet characterIsMember:aCharacter];
}

/*!
  @property		bitmapRepresentation
  @abstract		An NSData object encoding the receiver in binary format.
  @discussion	This format is suitable for saving to a file or otherwise transmitting or archiving.
 
 A raw bitmap representation of a character set is a byte array with the first 2^16 bits (that is, 8192 bytes) representing the code point range of the the Basic Multilingual Plane (BMP), such that the value of the bit at position n represents the presence in the character set of the character with decimal Unicode value n. A bitmap representation may contain zero to sixteen additional 8192 byte segments to for each additional Unicode plane containing a character in a character set, with each 8192 byte segment prepended with a single plane index byte.
 
 For example, a character set containing only Basic Latin (ASCII) characters, which are contained by the Basic Multilingual Plane (BMP, plane 0), has a bitmap representation with a size of 8192 bytes, whereas a character set containing both Basic Latin (ASCII) characters and emoji characters, which are contained by the Supplementary Multilingual Plane (SMP, plane 1), has a bitmap representation with a size of 16385 bytes (8192 bytes for BMP, followed by the byte 0x01 for the plane index of SMP, followed by 8192 bytes for SMP).
 
 To test for the presence of a character in the Basic Multilingual Plane (BMP) with decimal Unicode value n in a raw bitmap representation, you might do the following:
 ```
 unsigned char bitmapRep[8192];
 if (bitmapRep[n >> 3] & (((unsigned int)1) << (n  & 7))) {
	 / * Character is present. * /
 }
```
 */
- (NSData *)bitmapRepresentation
{
	return self.characterSet.bitmapRepresentation;
}

/*!
  @property		invertedSet
  @abstract		A character set containing only characters that don’t exist in the receiver.
  @discussion	Using the inverse of an immutable character set is much more efficient than inverting a mutable character set.
 */
- (BECharacterSet *)invertedSet {
	return [[BECharacterSet alloc] initWithSet:_characterSet.invertedSet];
}

/*!
  @method		longCharacterIsMember
  @param 		theLongChar	A UTF32 character.
  @abstract		Returns a Boolean value that indicates whether a given long character is a member of the receiver.
  @return		true if theLongChar is in the receiver, otherwise false.
  @discussion	This method supports the specification of 32-bit characters.
 */
- (BOOL)longCharacterIsMember:(UTF32Char)theLongChar
{
	return [_characterSet longCharacterIsMember:theLongChar];
}

/*!
  @method		isSupersetOfSet
  @param 		theOtherSet	A character set.
  @abstract		Returns a Boolean value that indicates whether the receiver is a superset of another given character set.
  @return		true if the receiver is a superset of theOtherSet, otherwise false.
 */
- (BOOL)isSupersetOfSet:(id)theOtherSet
{
	if ([theOtherSet isKindOfClass:BECharacterSet.class]) {
		return [_characterSet isSupersetOfSet:((BECharacterSet*)theOtherSet).characterSet];
	}
	return [_characterSet isSupersetOfSet:theOtherSet];
}

/*!
  @method		hasMemberInPlane
  @param 		thePlane	A character plane.
  @abstract		Returns a Boolean value that indicates whether the receiver has at least one member in a given character plane.
  @return		true if the receiver has at least one member in thePlane, otherwise false.
 */
- (BOOL)hasMemberInPlane:(uint8_t)thePlane
{
	return [_characterSet hasMemberInPlane:thePlane];
}

@end


/*!
 @implementation			BEMutableCharacterSet
 @abstract		The replacement for NSMutableCharacterSet.
 @discussion	This duplicates the functionality of NSMutableCharacterSet while being differentiable
				from BECharacterSet.
 */
@implementation BEMutableCharacterSet

- (id)init
{
	if (self) {
		if (!_characterSet) {
			_characterSet = NSMutableCharacterSet.new;
		}
	}
	self = [super init];
	return self;
}

- (instancetype)initWithSet:(id)charSet
{
	if (self) {
		if ([charSet isKindOfClass:BECharacterSet.class]) {
			_characterSet = [((BECharacterSet*)charSet).characterSet mutableCopy];
		} else if (charSet) {
			_characterSet = [charSet mutableCopy];
		}
	}
	self = [super init];
	return self;
}

/*!
 @property		characterSet
 @abstract		This is the reference to the internal NSMutableCharacterSet.
 @return		Returns the instance NSMutableCharacterSet
 @discussion	This NSMutableCharacterSet may be changed and the changes NOT reflect in the BEMutableCharacterSet.
 */
- (NSMutableCharacterSet *)characterSet {
	return (NSMutableCharacterSet*)_characterSet;
}

/*!
 @method		setCharacterSet:
 @param			set The NSCharacterSet or NSMutableCharacterSet
 @abstract		Sets the internal characterSet to a mutable copy of the NSMutableCharacterSet.
 @discussion	A NSCharacterSet may be cast to an NSMutableCharacterSet.
 */
- (void)setCharacterSet:(NSMutableCharacterSet *)set {
	_characterSet = [set mutableCopy];
}

/*!
 @method		addCharactersInRange:
 @param			aRange The range of characters to add. aRange.location is the value of the first character to add; aRange.location + aRange.length – 1 is the value of the last. If aRange.length is 0, this method has no effect.
 @abstract		Adds to the receiver the characters whose Unicode values are in a given range.
 @discussion	This code excerpt adds to a character set the lowercase English alphabetic characters:
 ```
 NSMutableCharacterSet *aCharacterSet = [[NSMutableCharacterSet alloc] init];
 NSRange lcEnglishRange;
  
 lcEnglishRange.location = (unsigned int)'a';
 lcEnglishRange.length = 26;
 [aCharacterSet addCharactersInRange:lcEnglishRange];
 ```
 */
- (void)addCharactersInRange:(NSRange)aRange
{
	[self.characterSet addCharactersInRange:aRange];
}

/*!
 @method		removeCharactersInRange:
 @param			aRange The range of characters to remove. aRange.location is the value of the first character to remove; aRange.location + aRange.length – 1 is the value of the last. If aRange.length is 0, this method has no effect.
 @abstract		Removes from the receiver the characters whose Unicode values are in a given range.
 */
- (void)removeCharactersInRange:(NSRange)aRange
{
	[self.characterSet removeCharactersInRange:aRange];
}

/*!
 @method		addCharactersInString:
 @param			aString The characters to add to the receiver.
 @abstract		Adds to the receiver the characters in a given string.
 @discussion	This method has no effect if aString is empty.
 */
- (void)addCharactersInString:(NSString *)aString
{
	[self.characterSet addCharactersInString:aString];
}

/*!
 @method		removeCharactersInString:
 @param			aString The characters to remove from the receiver.
 @abstract		Removes from the receiver the characters in a given string.
 @discussion	This method has no effect if aString is empty.
 */
- (void)removeCharactersInString:(NSString *)aString
{
	[self.characterSet removeCharactersInString:aString];
}

/*!
 @method		formIntersectionWithCharacterSet:
 @param			otherSet The character set with which to perform the intersection.
 @abstract		Modifies the receiver so it contains only characters that exist in both the receiver and another set.
 */
- (void)formUnionWithCharacterSet:(id)otherSet
{
	if ([otherSet isKindOfClass:BECharacterSet.class]) {
		[self.characterSet formUnionWithCharacterSet:((BECharacterSet*)otherSet).characterSet];
	} else {
		[self.characterSet formUnionWithCharacterSet:otherSet];
	}
}

/*!
 @method		formUnionWithCharacterSet:
 @param			otherSet The character set with which to perform the union.
 @abstract		Modifies the receiver so it contains all characters that exist in either the receiver or another set.
 */
- (void)formIntersectionWithCharacterSet:(id)otherSet
{
	if ([otherSet isKindOfClass:BECharacterSet.class]) {
		[self.characterSet formIntersectionWithCharacterSet:((BECharacterSet*)otherSet).characterSet];
	} else {
		[self.characterSet formIntersectionWithCharacterSet:otherSet];
	}
}

/*!
 @method		invert
 @abstract		Replaces all the characters in the receiver with all the characters it didn’t previously contain.
 @discussion	Inverting a mutable character set, whether by invert or by invertedSet, is much less efficient than inverting an immutable character set with invertedSet.
 */
- (void)invert
{
	[self.characterSet invert];
}

/*!
 @property		controlCharacterSet
 @abstract		A character set containing the characters in Unicode General Category Cc and Cf.
 @return		A character set containing all the control characters.
 @discussion	These characters include, for example, the soft hyphen (U+00AD),
				control characters to support bi-directional text, and IETF language tag characters.
 */
+ (BEMutableCharacterSet *)controlCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.controlCharacterSet];
}

/*!
 @property		whitespaceCharacterSet
 @abstract		A character set containing the characters in Unicode General Category Zs and CHARACTER TABULATION (U+0009).
 @return		A character set containing all the whitespace characters.
 @discussion	This set doesn’t contain the newline or carriage return characters.
 */
+ (BEMutableCharacterSet *)whitespaceCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.whitespaceCharacterSet];
}

/*!
 @property		whitespaceAndNewlineCharacterSet
 @abstract		A character set containing characters in Unicode General Category Z*, U+000A ~ U+000D, and U+0085.
 @return		A character set containing all the whitespace and newline characters.
 */
+ (BEMutableCharacterSet *)whitespaceAndNewlineCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.whitespaceAndNewlineCharacterSet];
}

/*!
 @property		decimalDigitCharacterSet
 @abstract		A character set containing the characters in the category of Decimal Numbers.
 @return		A character set containing all the decimal digit characters.
 @discussion	Informally, this set is the set of all characters used to represent the decimal values 0 through 9. These characters include, for example, the decimal digits of the Indic scripts and Arabic.
 */
+ (BEMutableCharacterSet *)decimalDigitCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.decimalDigitCharacterSet];
}

/*!
 @property		letterCharacterSet
 @abstract		A character set containing the characters in Unicode General Category L* & M*.
 @return		A character set containing all the letter characters.
 @discussion	Informally, this set is the set of all characters used as letters of alphabets and ideographs.
 */
+ (BEMutableCharacterSet *)letterCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.letterCharacterSet];
}

/*!
 @property		lowercaseLetterCharacterSet
 @abstract		A character set containing the characters in Unicode General Category Ll.
 @return		A character set containing all the lowercase letter characters.
 @discussion	Informally, this set is the set of all characters used as lowercase letters in alphabets that make case distinctions.
 */
+ (BEMutableCharacterSet *)lowercaseLetterCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.lowercaseLetterCharacterSet];
}

/*!
 @property		uppercaseLetterCharacterSet
 @abstract		A character set containing the characters in Unicode General Category Lu and Lt.
 @return		A character set containing all the uppercase letter characters.
 @discussion	Informally, this set is the set of all characters used as uppercase letters in alphabets that make case distinctions.
 */
+ (BEMutableCharacterSet *)uppercaseLetterCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.uppercaseLetterCharacterSet];
}

/*!
 @property		nonBaseCharacterSet
 @abstract		A character set containing the characters in Unicode General Category M*.
 @return		A character set containing all the non-base characters.
 @discussion	This set is also defined as all legal Unicode characters with a non-spacing priority greater than 0. Informally, this set is the set of all characters used as modifiers of base characters.
 */
+ (BEMutableCharacterSet *)nonBaseCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.nonBaseCharacterSet];
}

/*!
 @property		alphanumericCharacterSet
 @abstract		A character set containing the characters in Unicode General Categories L*, M*, and N*.
 @return		A character set containing all the alphanumeric characters.
 @discussion	Informally, this set is the set of all characters used as basic units of alphabets, syllabaries, ideographs, and digits.
 */
+ (BEMutableCharacterSet *)alphanumericCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.alphanumericCharacterSet];
}

/*!
 @property		decomposableCharacterSet
 @abstract		A character set containing individual Unicode characters that can also
				be represented as composed character sequences (such as for letters with accents),
				by the definition of “standard decomposition” in version 3.2 of the Unicode
				character encoding standard.
 @return		A character set containing all the decomposable characters.
 @discussion	These characters include compatibility characters as well as pre-composed characters.
 @note			This character set doesn’t currently include the Hangul characters defined in version 2.0 of the Unicode standard.
 */
+ (BEMutableCharacterSet *)decomposableCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.decomposableCharacterSet];
}

/*!
 @property		illegalCharacterSet
 @abstract		A character set containing values in the category of Non-Characters or
				that have not yet been defined in version 3.2 of the Unicode standard.
 @return		A character set containing all the illegal characters.
 */
+ (BEMutableCharacterSet *)illegalCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.illegalCharacterSet];
}

/*!
 @property		punctuationCharacterSet
 @abstract		A character set containing the characters in Unicode General Category P*.
 @return		A character set containing all the punctuation characters.
 @discussion	Informally, this set is the set of all non-whitespace characters used to
				separate linguistic units in scripts, such as periods, dashes, parentheses, and so on.
 */
+ (BEMutableCharacterSet *)punctuationCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.punctuationCharacterSet];
}

/*!
 @property		capitalizedLetterCharacterSet
 @abstract		A character set containing the characters in Unicode General Category Lt.
 @return		A character set containing all the capitalized letter characters.
 */
+ (BEMutableCharacterSet *)capitalizedLetterCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.capitalizedLetterCharacterSet];
}

/*!
 @property		symbolCharacterSet
 @abstract		A character set containing the characters in Unicode General Category S*.
 @return		A character set containing all the symbol characters.
 @discussion	These characters include, for example, the dollar sign ($) and the plus (+) sign.
 */
+ (BEMutableCharacterSet *)symbolCharacterSet
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.symbolCharacterSet];
}

/*!
 @property		newlineCharacterSet
 @abstract		A character set containing the newline characters (U+000A ~ U+000D, U+0085, U+2028, and U+2029).
 @return		A character set containing all the newline characters.
 */
+ (BEMutableCharacterSet *)newlineCharacterSet API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0))
{
	return [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.newlineCharacterSet];
}

/*!
 @method		characterSetWithRange:
 @param			aRange A range of Unicode values. aRange.location is the value of the first character to return; aRange.location + aRange.length – 1 is the value of the last.
 @abstract		Returns a character set containing characters with Unicode values in a given range.
 @return		A character set containing characters whose Unicode values are given by aRange. If aRange.length is 0, returns an empty character set.
 @discussion	This code excerpt creates a character set object containing the lowercase English alphabetic characters:
 ```
 NSRange lcEnglishRange;
 NSCharacterSet *lcEnglishLetters;
  
 lcEnglishRange.location = (unsigned int)'a';
 lcEnglishRange.length = 26;
 lcEnglishLetters = [NSCharacterSet characterSetWithRange:lcEnglishRange];
 ```
 */
+ (BEMutableCharacterSet *)characterSetWithRange:(NSRange)aRange
{
	return [[BEMutableCharacterSet alloc] initWithSet:[NSMutableCharacterSet characterSetWithRange:aRange]];
}

/*!
 @method		characterSetWithCharactersInString:
 @param			aString A string containing characters for the new character set.
 @abstract		Returns a character set containing the characters in a given string.
 @return		A character set containing the characters in aString. Returns an empty character set if aString is empty.
 */
+ (BEMutableCharacterSet *)characterSetWithCharactersInString:(NSString *)aString
{
	return [[BEMutableCharacterSet alloc] initWithSet:[NSMutableCharacterSet characterSetWithCharactersInString:aString]];
}

/*!
 @method		characterSetWithBitmapRepresentation:
 @param			data A bitmap representation of a character set.
 @abstract		Returns a character set containing characters determined by a given bitmap representation.
 @return		A character set containing characters determined by data.
 @discussion	This method is useful for creating a character set object with data
				from a file or other external data source.
 
				A raw bitmap representation of a character set is a byte array with the first 2^16 bits (that is, 8192 bytes) representing the code point range of the the Basic Multilingual Plane (BMP), such that the value of the bit at position n represents the presence in the character set of the character with decimal Unicode value n. A bitmap representation may contain zero to sixteen additional 8192 byte segments to for each additional Unicode plane containing a character in a character set, with each 8192 byte segment prepended with a single plane index byte.
 
 To add a character in the Basic Multilingual Plane (BMP) with decimal Unicode value n to a raw bitmap representation, you might do the following:
 ```
 unsigned char bitmapRep[8192];
 bitmapRep[n >> 3] |= (((unsigned int)1) << (n & 7));
 ```
 
 To remove that character:
 ```
 bitmapRep[n >> 3] &= ~(((unsigned int)1) << (n & 7));
 ```
 */
+ (BEMutableCharacterSet *)characterSetWithBitmapRepresentation:(NSData *)data
{
	return [[BEMutableCharacterSet alloc] initWithSet:[NSMutableCharacterSet characterSetWithBitmapRepresentation:data]];
}

/*!
 @method		characterSetWithContentsOfFile:
 @param			fName A path to a file containing a bitmap representation of a character set. The path name must end with the extension .bitmap.
 @abstract		Returns a character set read from the bitmap representation stored in the file a given path.
 @return		A character set read from the bitmap representation stored in the file at path.
 @discussion	This method doesn’t use filenames to check for the uniqueness of the character sets it creates. To prevent duplication of character sets in memory, cache them and make them available through an API that checks whether the requested set has already been loaded.
 
 To read a bitmap representation from any file, use the NSData methoddataWithContentsOfFile:options:error: and pass the result to characterSetWithBitmapRepresentation:.
 */
+ (BEMutableCharacterSet *)characterSetWithContentsOfFile:(NSString *)fName
{
	return [[BEMutableCharacterSet alloc] initWithSet:[NSMutableCharacterSet characterSetWithContentsOfFile:fName]];
}

@end
