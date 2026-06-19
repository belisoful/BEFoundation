/*!
 @file          NSString+CharacterCounterTests.m
 @abstract      Unit tests for the `NSString (CharacterCounter)` category.
*/

#import <XCTest/XCTest.h>
#import "NSString+BExtension.h"

/*!
 @class         NSString_CharacterCounterTests
 @abstract      An `XCTestCase` subclass for testing the `NSString (CharacterCounter)` category.
*/
@interface NSString_CharacterCounterTests : XCTestCase
@end

@implementation NSString_CharacterCounterTests

#pragma mark - Test Cases for -countCharactersInSet:

/*!
 @method        testFullStringCountSimple
 @abstract      Tests the non-ranged method with a simple ASCII string.
*/
- (void)testFullStringCountSimple {
	NSString *testString = @"Hello, World!";
	NSCharacterSet *vowels = [NSCharacterSet characterSetWithCharactersInString:@"aeiouAEIOU"];
	NSUInteger count = [testString countCharactersInSet:vowels];
	XCTAssertEqual(count, 3, @"Should find 3 vowels in 'Hello, World!'");
}

/*!
 @method        testFullStringCountUnicode
 @abstract      Tests the non-ranged method with Unicode and composed characters (emoji).
 @discussion    This test is crucial to verify that `NSStringEnumerationByComposedCharacterSequences` is working as intended, treating emoji as single characters.
*/
- (void)testFullStringCountUnicode {
	NSString *testString = @"Test: 👩‍👩‍👧‍👦, 👍, and Z͑ͫ̓ͣ"; // Family emoji, thumbs up, Zalgo text
	
	// 1. Test for emoji
	NSCharacterSet *emojiSet = [NSCharacterSet characterSetWithCharactersInString:@"👍"];
	NSUInteger count = [testString countCharactersInSet:emojiSet];
	XCTAssertEqual(count, 0, @"emojis don't work in NSCharacterSet.");
	
	// 2. Test for letters
	NSCharacterSet *letterSet = [NSCharacterSet letterCharacterSet];
	count = [testString countCharactersInSet:letterSet];
	// Should count T, e, s, t, a, n, d, Z
	// The family emoji (👩‍👩‍👧‍👦) and thumbs up (👍) are not letters.
	// The Zalgo text (Z͑ͫ̓ͣ) starts with a letter 'Z'.
	XCTAssertEqual(count, 8, @"Should count 8 letters, ignoring emoji and diacritics on their own.");
}

/*!
 @method        testFullStringCountEmptyString
 @abstract      Tests the non-ranged method with an empty string.
*/
- (void)testFullStringCountEmptyString {
	NSString *testString = @"";
	NSCharacterSet *allChars = [NSCharacterSet alphanumericCharacterSet];
	NSUInteger count = [testString countCharactersInSet:allChars];
	XCTAssertEqual(count, 0, @"Empty string should return 0.");
}

/*!
 @method        testFullStringCountEmptySet
 @abstract      Tests the non-ranged method with an empty character set.
*/
- (void)testFullStringCountEmptySet {
	NSString *testString = @"Hello, World!";
	NSCharacterSet *emptySet = [NSCharacterSet characterSetWithCharactersInString:@""];
	NSUInteger count = [testString countCharactersInSet:emptySet];
	XCTAssertEqual(count, 0, @"Empty set should return 0.");
}

/*!
 @method        testFullStringCountNilSet
 @abstract      Tests the non-ranged method with a nil character set.
*/
- (void)testFullStringCountNilSet {
	NSString *testString = @"Hello, World!";
	NSCharacterSet *nullSet = nil;
	NSUInteger count = [testString countCharactersInSet:nullSet];
	XCTAssertEqual(count, 0, @"Nil character set should return 0.");
}

#pragma mark - Test Cases for -countCharactersInSet:range:

/*!
 @method        testRangedCountSimple
 @abstract      Tests the ranged method with a simple ASCII string and a sub-range.
*/
- (void)testRangedCountSimple {
	NSString *testString = @"Hello, World!"; // H(0) e(1) l(2) l(3) o(4) ,(5) (6) W(7) o(8) r(9) l(10) d(11) !(12)
	NSCharacterSet *vowels = [NSCharacterSet characterSetWithCharactersInString:@"aeiouAEIOU"];
	
	// Range = "Hello"
	NSRange range = NSMakeRange(0, 5);
	NSUInteger count = [testString countCharactersInSet:vowels range:range];
	XCTAssertEqual(count, 2, @"Should find 2 vowels in 'Hello'");
	
	// Range = "o, Wo"
	range = NSMakeRange(4, 5);
	count = [testString countCharactersInSet:vowels range:range];
	XCTAssertEqual(count, 2, @"Should find 2 vowels in 'o, Wo'");
}

/*!
 @method        testRangedCountUnicode
 @abstract      Tests the ranged method with Unicode strings.
*/
- (void)testRangedCountUnicode {
	NSString *testString = @"ABC👍DEF"; // Length is 7 (composed)
	NSCharacterSet *emojiSet = [NSCharacterSet characterSetWithCharactersInString:@"👍"];
	
	// Range = "ABC👍"
	NSRange range = NSMakeRange(0, 4);
	NSUInteger count = [testString countCharactersInSet:emojiSet range:range];
	XCTAssertEqual(count, 0, @"Should find 0 emoji in 'ABC👍'");
	
	// Range = "👍DEF"
	range = NSMakeRange(3, 4);
	count = [testString countCharactersInSet:emojiSet range:range];
	XCTAssertEqual(count, 0, @"Should find 0 emoji in '👍DEF'");
	
	// Range = "ABC"
	range = NSMakeRange(0, 3);
	count = [testString countCharactersInSet:emojiSet range:range];
	XCTAssertEqual(count, 0, @"Should find 0 emoji in 'ABC'");
}

/*!
 @method        testRangedCountInvalidRange
 @abstract      Tests the ranged method with invalid or out-of-bounds ranges.
*/
- (void)testRangedCountInvalidRange {
	NSString *testString = @"Hello, World!";
	NSCharacterSet *vowels = [NSCharacterSet characterSetWithCharactersInString:@"aeiouAEIOU"];
	
	// 1. Range location out of bounds
	NSRange range = NSMakeRange(100, 5);
	NSUInteger count = [testString countCharactersInSet:vowels range:range];
	XCTAssertEqual(count, 0, @"Range location out of bounds should return 0.");

	// 2. Range length extends beyond string length
	range = NSMakeRange(0, 100);
	count = [testString countCharactersInSet:vowels range:range];
	XCTAssertEqual(count, 0, @"Range length out of bounds should return 0.");
	
	// 3. Range location is NSNotFound
	range = NSMakeRange(NSNotFound, 5);
	count = [testString countCharactersInSet:vowels range:range];
	XCTAssertEqual(count, 0, @"NSNotFound range location should return 0.");
}

/*!
 @method        testRangedCountNilSet
 @abstract      Tests the ranged method with a nil character set.
*/
- (void)testRangedCountNilSet {
	NSString *testString = @"Hello, World!";
	NSRange range = NSMakeRange(0, 5);
	NSCharacterSet *nullSet = nil;
	NSUInteger count = [testString countCharactersInSet:nullSet range:range];
	XCTAssertEqual(count, 0, @"Nil character set with range should return 0.");
}

/*!
 @method        testRangedCountFullRange
 @abstract      Tests that the ranged method with a full range is equivalent to the non-ranged method.
*/
- (void)testRangedCountFullRange {
	NSString *testString = @"Test: 👩‍👩‍👧‍👦, 👍, and Z͑ͫ̓ͣ";
	NSCharacterSet *letters = [NSCharacterSet letterCharacterSet];
	
	NSUInteger rangedCount = [testString countCharactersInSet:letters range:NSMakeRange(0, testString.length)];
	NSUInteger fullCount = [testString countCharactersInSet:letters];
	
	XCTAssertEqual(rangedCount, 8);
	XCTAssertEqual(rangedCount, fullCount, @"Ranged count with full range should equal non-ranged count.");
}

@end
