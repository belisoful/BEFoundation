//
//  BFoundationExtensionTests.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import "BEFoundation/BEMutable.h"

@interface BECharacterSetTests : XCTestCase

@end

@implementation BECharacterSetTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
- (void)testBECharacterSet_isClassEqualToNSCharacterSet
{
	BECharacterSet.isClassEqualToNSCharacterSet = 0;
	
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetEqual;
	XCTAssertEqual(BECharacterSet.isClassEqualToNSCharacterSet, NSCharacterSetEqual);
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetUnequal;
	XCTAssertEqual(BECharacterSet.isClassEqualToNSCharacterSet, NSCharacterSetUnequal);
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllEqual;
	XCTAssertEqual(BECharacterSet.isClassEqualToNSCharacterSet, NSCharacterSetAllEqual);
	BECharacterSet.isClassEqualToNSCharacterSet = 3;
	XCTAssertEqual(BECharacterSet.isClassEqualToNSCharacterSet, NSCharacterSetAllEqual);
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllUnequal;
	XCTAssertEqual(BECharacterSet.isClassEqualToNSCharacterSet, NSCharacterSetAllUnequal);
	BECharacterSet.isClassEqualToNSCharacterSet = -3;
	XCTAssertEqual(BECharacterSet.isClassEqualToNSCharacterSet, NSCharacterSetAllUnequal);
	
}

- (void)testBECharacterSet_Init
{
	BECharacterSet.isClassEqualToNSCharacterSet = 0;
	BECharacterSet *charset = [[BECharacterSet alloc] init];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	
	XCTAssertTrue([charset.characterSet isEqual: NSCharacterSet.new]);
	XCTAssertTrue([charset.characterSet isEqual: NSMutableCharacterSet.new]);
	
	XCTAssertFalse([charset.characterSet isEqual: NSCharacterSet.letterCharacterSet]);
	XCTAssertFalse([charset.characterSet isEqual: NSMutableCharacterSet.letterCharacterSet]);
	
	XCTAssertFalse([charset isEqual: NSCharacterSet.new]);
	XCTAssertFalse([charset isEqual: NSMutableCharacterSet.new]);
	
	
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetEqual;
	charset = [[BECharacterSet alloc] init];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetUnequal;
	charset = [[BECharacterSet alloc] init];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllEqual;
	charset = [[BECharacterSet alloc] init];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetEqual);
	
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllUnequal;
	charset = [[BECharacterSet alloc] init];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetUnequal);
}

- (void)testBECharacterSet_InitWithSet
{
	BECharacterSet.isClassEqualToNSCharacterSet = 0;
	id zero = nil;
	BECharacterSet *zeroCharSet = [[BECharacterSet alloc] initWithSet:zero];
	XCTAssertNotNil(zeroCharSet);
	XCTAssertNotNil(zeroCharSet.characterSet);
	
	BECharacterSet *charset = [[BECharacterSet alloc] initWithSet:NSCharacterSet.alphanumericCharacterSet];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	
	XCTAssertTrue([charset.characterSet isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertTrue([charset.characterSet isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	XCTAssertFalse([charset.characterSet isEqual: NSCharacterSet.letterCharacterSet]);
	XCTAssertFalse([charset.characterSet isEqual: NSMutableCharacterSet.letterCharacterSet]);
	
	XCTAssertFalse([charset isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertFalse([charset isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	
	BECharacterSet *mcharset = [[BECharacterSet alloc] initWithSet:NSMutableCharacterSet.alphanumericCharacterSet];
	
	XCTAssertTrue([mcharset.characterSet isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertTrue([mcharset.characterSet isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	XCTAssertFalse([mcharset.characterSet isEqual: NSCharacterSet.letterCharacterSet]);
	XCTAssertFalse([mcharset.characterSet isEqual: NSMutableCharacterSet.letterCharacterSet]);
	
	XCTAssertFalse([mcharset isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertFalse([mcharset isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	
	BECharacterSet *becharset = [[BECharacterSet alloc] initWithSet:BECharacterSet.alphanumericCharacterSet];
	
	XCTAssertTrue([becharset.characterSet isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertTrue([becharset.characterSet isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	XCTAssertFalse([becharset.characterSet isEqual: NSCharacterSet.letterCharacterSet]);
	XCTAssertFalse([becharset.characterSet isEqual: NSMutableCharacterSet.letterCharacterSet]);
	
	XCTAssertFalse([becharset isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertFalse([becharset isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	
	BECharacterSet *mbecharset = [[BECharacterSet alloc] initWithSet:BEMutableCharacterSet.alphanumericCharacterSet];
	
	XCTAssertTrue([mbecharset.characterSet isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertTrue([mbecharset.characterSet isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	XCTAssertFalse([mbecharset.characterSet isEqual: NSCharacterSet.letterCharacterSet]);
	XCTAssertFalse([mbecharset.characterSet isEqual: NSMutableCharacterSet.letterCharacterSet]);
	
	XCTAssertFalse([mbecharset isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertFalse([mbecharset isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	
	
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetEqual;
	charset = [[BECharacterSet alloc] initWithSet:BECharacterSet.alphanumericCharacterSet];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetUnequal;
	charset = [[BECharacterSet alloc] initWithSet:BECharacterSet.alphanumericCharacterSet];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllEqual;
	charset = [[BECharacterSet alloc] initWithSet:BECharacterSet.alphanumericCharacterSet];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetEqual);
	
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllUnequal;
	charset = [[BECharacterSet alloc] initWithSet:BECharacterSet.alphanumericCharacterSet];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetUnequal);
}


- (void)testBECharacterSet_InitWithCoder
{
	BECharacterSet.isClassEqualToNSCharacterSet = 0;
	BECharacterSet	*reference = BECharacterSet.capitalizedLetterCharacterSet;
	
	XCTAssertTrue([BECharacterSet supportsSecureCoding]);
	NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:reference requiringSecureCoding:YES error:nil];
	XCTAssertNotNil(archivedData);
	BECharacterSet *result = [NSKeyedUnarchiver unarchivedObjectOfClass:BECharacterSet.class fromData:archivedData error:nil];
	
	XCTAssertNotNil(result);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertEqual(result.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	
	
	reference = BECharacterSet.capitalizedLetterCharacterSet;
	reference.isEqualToNSCharacterSet = NSCharacterSetEqual;
	
	archivedData = [NSKeyedArchiver archivedDataWithRootObject:reference requiringSecureCoding:YES error:nil];
	XCTAssertNotNil(archivedData);
	result = [NSKeyedUnarchiver unarchivedObjectOfClass:BECharacterSet.class fromData:archivedData error:nil];
	
	XCTAssertNotNil(result);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertEqual(result.isEqualToNSCharacterSet, NSCharacterSetEqual);
	
	
	reference = BECharacterSet.capitalizedLetterCharacterSet;
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllEqual;
	
	archivedData = [NSKeyedArchiver archivedDataWithRootObject:reference requiringSecureCoding:YES error:nil];
	XCTAssertNotNil(archivedData);
	result = [NSKeyedUnarchiver unarchivedObjectOfClass:BECharacterSet.class fromData:archivedData error:nil];
	
	XCTAssertNotNil(result);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertEqual(result.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
}

- (void)testBECharacterSet_copyWithZone
{
	BECharacterSet	*reference = BECharacterSet.capitalizedLetterCharacterSet;
	
	BECharacterSet *result = [reference copyWithZone:nil];
	
	XCTAssertTrue([result isMemberOfClass:BECharacterSet.class]);
	
	XCTAssertNotNil(result);
	
	XCTAssertEqual(result, reference);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertFalse([result isEqual:BECharacterSet.lowercaseLetterCharacterSet]);
}

- (void)testBECharacterSet_mutableCopyWithZone
{
	BECharacterSet	*reference = BECharacterSet.capitalizedLetterCharacterSet;
	
	BEMutableCharacterSet *result = [reference mutableCopyWithZone:nil];
	
	XCTAssertTrue([result isMemberOfClass:BEMutableCharacterSet.class]);
	
	XCTAssertNotNil(result);
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertFalse([result isEqual:BECharacterSet.lowercaseLetterCharacterSet]);
}

- (void)testBECharacterSet_isEqual
{
	BECharacterSet.isClassEqualToNSCharacterSet = 0;
	BECharacterSet *charset = BECharacterSet.alphanumericCharacterSet;
	
	XCTAssertTrue([charset isEqual:BECharacterSet.alphanumericCharacterSet]);
	XCTAssertFalse([charset isEqual:BECharacterSet.controlCharacterSet]);
	
	XCTAssertTrue([charset isEqual:BEMutableCharacterSet.alphanumericCharacterSet]);
	XCTAssertFalse([charset isEqual:BEMutableCharacterSet.controlCharacterSet]);
	
	XCTAssertFalse([charset isEqual:NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertFalse([charset isEqual:NSCharacterSet.controlCharacterSet]);
	
	// Equality of NSCharacterSet
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetUnequal;
	XCTAssertFalse([charset isEqual:NSCharacterSet.alphanumericCharacterSet]);
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllUnequal;
	XCTAssertFalse([charset isEqual:NSCharacterSet.alphanumericCharacterSet]);
	
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetEqual;
	XCTAssertTrue([charset isEqual:NSCharacterSet.alphanumericCharacterSet]);
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllEqual;
	XCTAssertTrue([charset isEqual:NSCharacterSet.alphanumericCharacterSet]);
	
	BECharacterSet.isClassEqualToNSCharacterSet = 0;
	XCTAssertFalse([charset isEqual:NSCharacterSet.alphanumericCharacterSet]);
	
	charset.isEqualToNSCharacterSet = NSCharacterSetEqual;
	XCTAssertTrue([charset isEqual:NSCharacterSet.alphanumericCharacterSet]);
	
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllUnequal;
	XCTAssertTrue([charset isEqual:NSCharacterSet.alphanumericCharacterSet]);
	
	charset.isEqualToNSCharacterSet = NSCharacterSetUnequal;
	BECharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllEqual;
	XCTAssertFalse([charset isEqual:NSCharacterSet.alphanumericCharacterSet]);
	
	
}

- (void)testBExCharacterSet_controlCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.controlCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.controlCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.controlCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.controlCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_whitespaceCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.whitespaceCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.whitespaceCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.whitespaceCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.whitespaceCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_whitespaceAndNewlineCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.whitespaceAndNewlineCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.whitespaceAndNewlineCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.whitespaceAndNewlineCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.whitespaceAndNewlineCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_decimalDigitCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.decimalDigitCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.decimalDigitCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.decimalDigitCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.decimalDigitCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_letterCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.letterCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.letterCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.letterCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.letterCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_lowercaseLetterCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.lowercaseLetterCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.lowercaseLetterCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.lowercaseLetterCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.lowercaseLetterCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_uppercaseLetterCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.uppercaseLetterCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.uppercaseLetterCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.uppercaseLetterCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.uppercaseLetterCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_nonBaseCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.nonBaseCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.nonBaseCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.nonBaseCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.nonBaseCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_alphanumericCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.alphanumericCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.alphanumericCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_decomposableCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.decomposableCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.decomposableCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.decomposableCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.decomposableCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_illegalCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.illegalCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.illegalCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.illegalCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.illegalCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_punctuationCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.punctuationCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.punctuationCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.punctuationCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.punctuationCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_capitalizedLetterCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.capitalizedLetterCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.capitalizedLetterCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.capitalizedLetterCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.capitalizedLetterCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_symbolCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.symbolCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.symbolCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.symbolCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.symbolCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_newlineCharacterSet
{
	BECharacterSet *charset;
	
	charset = BECharacterSet.newlineCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.newlineCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = BEMutableCharacterSet.newlineCharacterSet;
	XCTAssertTrue([charset.characterSet isEqual:NSCharacterSet.newlineCharacterSet]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_characterSetWithRange
{
	BECharacterSet *charset;
	
	charset = [BECharacterSet characterSetWithRange: NSMakeRange(32, 100)];
	XCTAssertTrue([charset.characterSet isEqual:[NSCharacterSet characterSetWithRange: NSMakeRange(32, 100)]]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = [BEMutableCharacterSet characterSetWithRange: NSMakeRange(32, 101)];
	XCTAssertTrue([charset.characterSet isEqual:[NSCharacterSet characterSetWithRange: NSMakeRange(32, 101)]]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_characterSetWithCharactersInString
{
	BECharacterSet *charset;
	
	charset = [BECharacterSet characterSetWithCharactersInString:@"NSCharacterSet"];
	XCTAssertTrue([charset.characterSet isEqual:[NSCharacterSet characterSetWithCharactersInString:@"NSCharacterSet"]]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = [BEMutableCharacterSet characterSetWithCharactersInString:@"NSMutableCharacterSet"];
	XCTAssertTrue([charset.characterSet isEqual:[NSCharacterSet characterSetWithCharactersInString:@"NSMutableCharacterSet"]]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_characterSetWithBitmapRepresentation
{
	BECharacterSet *charset;
	NSData *bitmapRep = NSCharacterSet.decomposableCharacterSet.bitmapRepresentation;
	
	charset = [BECharacterSet characterSetWithBitmapRepresentation:bitmapRep];
	XCTAssertTrue([charset.characterSet isEqual:[NSCharacterSet characterSetWithBitmapRepresentation:bitmapRep]]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = [BEMutableCharacterSet characterSetWithBitmapRepresentation:bitmapRep];
	XCTAssertTrue([charset.characterSet isEqual:[NSCharacterSet characterSetWithBitmapRepresentation:bitmapRep]]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
}

- (void)testBExCharacterSet_characterSetWithContentsOfFile
{
	BECharacterSet *charset;
	NSString *contents = @"This is the contents of the tmp file.";
	
	NSString *tempDir = NSTemporaryDirectory();
	NSString *tempFile = [tempDir stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];

	NSError *writeError = nil;
	BOOL success = [contents writeToFile:tempFile atomically:YES encoding:NSUTF8StringEncoding error:&writeError];

	XCTAssertTrue(success, @"Unable to write tmp file.");
	if (!success) {
		return;
	}
	NSString *fileContents = [NSString stringWithContentsOfFile:tempFile encoding:NSUTF8StringEncoding error:nil];
	
	XCTAssertTrue(fileContents.length > 0);
	XCTAssertTrue([fileContents isEqualToString:contents]);
	
	charset = [BECharacterSet characterSetWithContentsOfFile:tempFile];
	XCTAssertTrue([charset.characterSet isEqual:[NSCharacterSet characterSetWithContentsOfFile:tempFile]]);
	XCTAssertTrue([charset isMemberOfClass:BECharacterSet.class]);
	
	charset = [BEMutableCharacterSet characterSetWithContentsOfFile:tempFile];
	XCTAssertTrue([charset.characterSet isEqual:[NSCharacterSet characterSetWithContentsOfFile:tempFile]]);
	XCTAssertTrue([charset isMemberOfClass:BEMutableCharacterSet.class]);
	
	
	NSError *deleteError = nil;
	[[NSFileManager defaultManager] removeItemAtPath:tempFile error:&deleteError];
	
	XCTAssertNil(deleteError, @"Unable to delete tmp file.");
}

- (void)testBECharacterSet_characterIsMember
{
	BECharacterSet *charset = BECharacterSet.alphanumericCharacterSet;
	int i = 0;
	for(i; i < 255; i++) {
		XCTAssertEqual([charset characterIsMember:i], [charset.characterSet characterIsMember:i]);
	}
	XCTAssertEqual(i, 255);
}

- (void)testBECharacterSet_longCharacterIsMember
{
	BECharacterSet *charset = BECharacterSet.alphanumericCharacterSet;
	int i = 0;
	for(i; i < 255; i++) {
		XCTAssertEqual([charset longCharacterIsMember:i], [charset.characterSet longCharacterIsMember:i]);
	}
	XCTAssertEqual(i, 255);
}

- (void)testBECharacterSet_bitmapRepresentation
{
	BECharacterSet *charset = BECharacterSet.alphanumericCharacterSet;
	XCTAssertEqualObjects([charset bitmapRepresentation], [charset.characterSet bitmapRepresentation]);
}

- (void)testBECharacterSet_invertedSet
{
	BECharacterSet *charset = BECharacterSet.alphanumericCharacterSet;
	XCTAssertTrue([[charset invertedSet].characterSet isEqual:[charset.characterSet invertedSet]]);
}

- (void)testBECharacterSet_isSupersetOfSet
{
	BECharacterSet *charset = BECharacterSet.alphanumericCharacterSet;
	XCTAssertTrue([charset isSupersetOfSet:BECharacterSet.decimalDigitCharacterSet]);
	XCTAssertTrue([charset isSupersetOfSet:NSCharacterSet.decimalDigitCharacterSet]);
	
	XCTAssertFalse([charset isSupersetOfSet:BECharacterSet.illegalCharacterSet]);
	XCTAssertFalse([charset isSupersetOfSet:NSCharacterSet.illegalCharacterSet]);
}

- (void)testBECharacterSet_hasMemberInPlane
{
	BECharacterSet *charset = BECharacterSet.illegalCharacterSet;
	for(int i = 0; i < 255; i++) {
		XCTAssertEqual([charset hasMemberInPlane:i], [charset.characterSet hasMemberInPlane:i]);
	}
}




- (void)testBEMutableCharacterSet_Init
{
	BEMutableCharacterSet *charset = [[BEMutableCharacterSet alloc] init];

	XCTAssertTrue([charset.characterSet isEqual: NSCharacterSet.new]);
	XCTAssertTrue([charset.characterSet isEqual: NSMutableCharacterSet.new]);

	XCTAssertFalse([charset.characterSet isEqual: NSCharacterSet.letterCharacterSet]);
	XCTAssertFalse([charset.characterSet isEqual: NSMutableCharacterSet.letterCharacterSet]);

	XCTAssertFalse([charset isEqual: NSCharacterSet.new]);
	XCTAssertFalse([charset isEqual: NSMutableCharacterSet.new]);
	[charset invert];
	
	BEMutableCharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetEqual;
	charset = [[BEMutableCharacterSet alloc] init];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	
	BEMutableCharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetUnequal;
	charset = [[BEMutableCharacterSet alloc] init];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	
	BEMutableCharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllEqual;
	charset = [[BEMutableCharacterSet alloc] init];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetEqual);
	
	BEMutableCharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllUnequal;
	charset = [[BEMutableCharacterSet alloc] init];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetUnequal);
}

- (void)testBEMutableCharacterSet_InitWithSet
{
	BEMutableCharacterSet.isClassEqualToNSCharacterSet = 0;
	
	id zero = nil;
	BEMutableCharacterSet *zeroCharSet = [[BEMutableCharacterSet alloc] initWithSet:zero];
	XCTAssertNotNil(zeroCharSet);
	XCTAssertNotNil(zeroCharSet.characterSet);
	
	BEMutableCharacterSet *charset = [[BEMutableCharacterSet alloc] initWithSet:NSCharacterSet.alphanumericCharacterSet];
	
	XCTAssertTrue([charset.characterSet isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertTrue([charset.characterSet isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	XCTAssertFalse([charset.characterSet isEqual: NSCharacterSet.letterCharacterSet]);
	XCTAssertFalse([charset.characterSet isEqual: NSMutableCharacterSet.letterCharacterSet]);
	
	XCTAssertFalse([charset isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertFalse([charset isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	[charset invert]; //Test that it's mutable, doesn't fault
	
	
	BEMutableCharacterSet *mcharset = [[BEMutableCharacterSet alloc] initWithSet:NSMutableCharacterSet.alphanumericCharacterSet];
	
	XCTAssertTrue([mcharset.characterSet isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertTrue([mcharset.characterSet isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	XCTAssertFalse([mcharset.characterSet isEqual: NSCharacterSet.letterCharacterSet]);
	XCTAssertFalse([mcharset.characterSet isEqual: NSMutableCharacterSet.letterCharacterSet]);
	
	XCTAssertFalse([mcharset isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertFalse([mcharset isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	[mcharset invert]; //Test that it's mutable, doesn't fault
	
	
	BEMutableCharacterSet *becharset = [[BEMutableCharacterSet alloc] initWithSet:BECharacterSet.alphanumericCharacterSet];
	
	XCTAssertTrue([becharset.characterSet isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertTrue([becharset.characterSet isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	XCTAssertFalse([becharset.characterSet isEqual: NSCharacterSet.letterCharacterSet]);
	XCTAssertFalse([becharset.characterSet isEqual: NSMutableCharacterSet.letterCharacterSet]);
	
	XCTAssertFalse([becharset isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertFalse([becharset isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	[becharset invert]; //Test that it's mutable, doesn't fault
	
	
	BEMutableCharacterSet *mbecharset = [[BEMutableCharacterSet alloc] initWithSet:BEMutableCharacterSet.alphanumericCharacterSet];
	
	XCTAssertTrue([mbecharset.characterSet isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertTrue([mbecharset.characterSet isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	
	XCTAssertFalse([mbecharset.characterSet isEqual: NSCharacterSet.letterCharacterSet]);
	XCTAssertFalse([mbecharset.characterSet isEqual: NSMutableCharacterSet.letterCharacterSet]);
	
	XCTAssertFalse([mbecharset isEqual: NSCharacterSet.alphanumericCharacterSet]);
	XCTAssertFalse([mbecharset isEqual: NSMutableCharacterSet.alphanumericCharacterSet]);
	[mbecharset invert]; //Test that it's mutable, doesn't fault
	
	
	
	BEMutableCharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetEqual;
	charset = [[BEMutableCharacterSet alloc] initWithSet:BECharacterSet.alphanumericCharacterSet];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	
	BEMutableCharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetUnequal;
	charset = [[BEMutableCharacterSet alloc] initWithSet:BECharacterSet.alphanumericCharacterSet];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	
	BEMutableCharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllEqual;
	charset = [[BEMutableCharacterSet alloc] initWithSet:BECharacterSet.alphanumericCharacterSet];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetEqual);
	
	BEMutableCharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllUnequal;
	charset = [[BEMutableCharacterSet alloc] initWithSet:BECharacterSet.alphanumericCharacterSet];
	XCTAssertEqual(charset.isEqualToNSCharacterSet, NSCharacterSetUnequal);
}

- (void)testBEMutableCharacterSet_InitWithCoder
{
	BEMutableCharacterSet.isClassEqualToNSCharacterSet = 0;
	BEMutableCharacterSet	*reference = BEMutableCharacterSet.capitalizedLetterCharacterSet;
	XCTAssertTrue([BECharacterSet supportsSecureCoding]);
	
	NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:reference requiringSecureCoding:YES error:nil];
	XCTAssertNotNil(archivedData);
	BEMutableCharacterSet *result = [NSKeyedUnarchiver unarchivedObjectOfClass:BEMutableCharacterSet.class fromData:archivedData error:nil];

	XCTAssertNotNil(result);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertEqual(result.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	[result invert];
	
	
	reference = BEMutableCharacterSet.capitalizedLetterCharacterSet;
	reference.isEqualToNSCharacterSet = NSCharacterSetEqual;
	
	archivedData = [NSKeyedArchiver archivedDataWithRootObject:reference requiringSecureCoding:YES error:nil];
	XCTAssertNotNil(archivedData);
	result = [NSKeyedUnarchiver unarchivedObjectOfClass:BEMutableCharacterSet.class fromData:archivedData error:nil];
	
	XCTAssertNotNil(result);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertEqual(result.isEqualToNSCharacterSet, NSCharacterSetEqual);
	[result invert];
	
	
	reference = BEMutableCharacterSet.capitalizedLetterCharacterSet;
	BEMutableCharacterSet.isClassEqualToNSCharacterSet = NSCharacterSetAllEqual;
	
	archivedData = [NSKeyedArchiver archivedDataWithRootObject:reference requiringSecureCoding:YES error:nil];
	XCTAssertNotNil(archivedData);
	result = [NSKeyedUnarchiver unarchivedObjectOfClass:BEMutableCharacterSet.class fromData:archivedData error:nil];
	
	XCTAssertNotNil(result);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertEqual(result.isEqualToNSCharacterSet, NSCharacterSetClassStyle);
	[result invert];
}

- (void)testBEMutableCharacterSet_copyWithZone
{
	BEMutableCharacterSet	*reference = BEMutableCharacterSet.capitalizedLetterCharacterSet;
	
	BECharacterSet *result = [reference copyWithZone:nil];
	
	XCTAssertTrue([result isMemberOfClass:BECharacterSet.class]);
	
	XCTAssertNotNil(result);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertFalse([result isEqual:BECharacterSet.lowercaseLetterCharacterSet]);
}

- (void)testBEMutableCharacterSet_mutableCopyWithZone
{
	BEMutableCharacterSet	*reference = BEMutableCharacterSet.capitalizedLetterCharacterSet;
	
	BEMutableCharacterSet *result = [reference mutableCopyWithZone:nil];
	
	XCTAssertTrue([result isMemberOfClass:BEMutableCharacterSet.class]);
	
	XCTAssertNotNil(result);
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isEqual:reference]);
	XCTAssertFalse([result isEqual:BECharacterSet.lowercaseLetterCharacterSet]);
}


- (void)testBEMutableCharacterSet_addCharactersInRange
{
	BEMutableCharacterSet *charset = BEMutableCharacterSet.new;
	NSMutableCharacterSet *reference = NSMutableCharacterSet.new;
	
	[charset addCharactersInRange:NSMakeRange(32, 50)];
	XCTAssertFalse([charset.characterSet isEqual:reference]);
	
	[reference addCharactersInRange:NSMakeRange(32, 50)];
	XCTAssertTrue([charset.characterSet isEqual:reference]);
}


- (void)testBEMutableCharacterSet_setCharacterSet
{
	BEMutableCharacterSet *charset = BEMutableCharacterSet.new;
	NSMutableCharacterSet *alphaNumericSet = [NSMutableCharacterSet alphanumericCharacterSet];
	charset.characterSet = alphaNumericSet;
	
	int i = 0;
	for(i; i < 255; i++) {
		XCTAssertEqual([charset characterIsMember:i], [alphaNumericSet characterIsMember:i]);
	}
	XCTAssertEqual(i, 255);
}

- (void)testBEMutableCharacterSet_removeCharactersInRange
{
	BEMutableCharacterSet *charset = BEMutableCharacterSet.letterCharacterSet;
	NSMutableCharacterSet *reference = NSMutableCharacterSet.letterCharacterSet;
	
	[charset removeCharactersInRange:NSMakeRange(60, 15)];
	XCTAssertFalse([charset.characterSet isEqual:reference]);
	
	[reference removeCharactersInRange:NSMakeRange(60 , 15)];
	XCTAssertTrue([charset.characterSet isEqual:reference]);
}

- (void)testBEMutableCharacterSet_addCharactersInString
{
	BEMutableCharacterSet *charset = BEMutableCharacterSet.decimalDigitCharacterSet;
	NSMutableCharacterSet *reference = NSMutableCharacterSet.decimalDigitCharacterSet;
	
	[charset addCharactersInString:@"abcdefg"];
	XCTAssertFalse([charset.characterSet isEqual:reference]);
	
	[reference addCharactersInString:@"abcdefg"];
	XCTAssertTrue([charset.characterSet isEqual:reference]);
}


- (void)testBEMutableCharacterSet_removeCharactersInString
{
	BEMutableCharacterSet *charset = BEMutableCharacterSet.letterCharacterSet;
	NSMutableCharacterSet *reference = NSMutableCharacterSet.letterCharacterSet;
	
	[charset removeCharactersInString:@"abcdefg"];
	XCTAssertFalse([charset.characterSet isEqual:reference]);
	
	[reference removeCharactersInString:@"abcdefg"];
	XCTAssertTrue([charset.characterSet isEqual:reference]);
}

- (void)testBEMutableCharacterSet_formUnionWithCharacterSet
{
	BEMutableCharacterSet *charset = BEMutableCharacterSet.letterCharacterSet;
	BECharacterSet *unionCharset = BECharacterSet.decimalDigitCharacterSet;
	NSMutableCharacterSet *reference = NSMutableCharacterSet.letterCharacterSet;
	NSCharacterSet *unionReference = NSCharacterSet.decimalDigitCharacterSet;
	
	[charset formUnionWithCharacterSet:unionCharset];
	XCTAssertFalse([charset.characterSet isEqual:reference]);
	
	[reference formUnionWithCharacterSet:unionReference];
	XCTAssertTrue([charset.characterSet isEqual:reference]);
	
	
	charset = BEMutableCharacterSet.letterCharacterSet;
	[charset formUnionWithCharacterSet:unionReference];
	XCTAssertTrue([charset.characterSet isEqual:reference]);
}

- (void)testBEMutableCharacterSet_formIntersectionWithCharacterSet
{
	BEMutableCharacterSet *charset = BEMutableCharacterSet.alphanumericCharacterSet;
	BECharacterSet *intersectCharset = BECharacterSet.lowercaseLetterCharacterSet;
	NSMutableCharacterSet *reference = NSMutableCharacterSet.alphanumericCharacterSet;
	NSCharacterSet *intersectReference = NSCharacterSet.lowercaseLetterCharacterSet;
	
	[charset formIntersectionWithCharacterSet:intersectCharset];
	XCTAssertFalse([charset.characterSet isEqual:reference]);
	
	[reference formIntersectionWithCharacterSet:intersectReference];
	XCTAssertTrue([charset.characterSet isEqual:reference]);
	
	
	charset = BEMutableCharacterSet.alphanumericCharacterSet;
	[charset formIntersectionWithCharacterSet:intersectReference];
	XCTAssertTrue([charset.characterSet isEqual:reference]);
}

- (void)testBEMutableCharacterSet_invert
{
	BEMutableCharacterSet *charset = BEMutableCharacterSet.alphanumericCharacterSet;
	NSMutableCharacterSet *reference = NSMutableCharacterSet.alphanumericCharacterSet;
	
	[charset invert];
	XCTAssertFalse([charset.characterSet isEqual:reference]);
	
	[reference invert];
	XCTAssertTrue([charset.characterSet isEqual:reference]);
}


@end
