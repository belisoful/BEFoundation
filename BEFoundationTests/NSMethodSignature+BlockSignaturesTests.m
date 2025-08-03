//
//  NSOrderedSet+BExtension.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import <BEFoundation/NSObject+DynamicMethods.h>
#import <simd/simd.h>
#import <arm_neon.h>


@interface CustomNSMethodSignature : NSMethodSignature
- (instancetype)init;
- (const char *)getArgumentTypeAtIndex:(NSUInteger)idx;
@end

@implementation CustomNSMethodSignature

- (instancetype)init
{
	//Skip self = [super init]; because [NSMethodSignature init] returns nil;
	return self;
}


- (const char *)getArgumentTypeAtIndex:(NSUInteger)idx
{
	if (idx == 0) {
		return 0;
	} else if (idx == 1) {
		return "l";
	} else if (idx == 2) {
		return "L";
	} else if (idx == 3) {
		return "(union=csi)";
	}
	return 0;
}
@end





@interface NSMethodSignatureBlockSignaturesTests : XCTestCase

@end

#pragma mark - NSObject Dynamic Methods Tests

@implementation NSMethodSignatureBlockSignaturesTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark - NSMethodSignature (DynamicMethods)


- (void)testNSMethodSignature_signatureFromBlock_NoCmdArgument_Minimal
{
	id aBlock = ^BOOL(id self) {
		return YES;
	};
	
	NSMethodSignature *signature = [NSMethodSignature signatureFromBlock:aBlock];
	
	XCTAssertNotNil(signature);
	
	XCTAssertEqual(strcmp([signature methodReturnType], "B"), 0);
	XCTAssertEqual([signature methodReturnLength], 1);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 1);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	
}

- (void)testNSMethodSignature_signatureFromBlock_CmdArgument_Minimal
{
	id aBlock = ^BOOL(id self, SEL _cmd) {
		return YES;
	};
	
	NSMethodSignature *signature = [NSMethodSignature signatureFromBlock:aBlock];
	
	XCTAssertNotNil(signature);
	
	XCTAssertEqual(strcmp([signature methodReturnType], "B"), 0);
	XCTAssertEqual([signature methodReturnLength], 1);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 2);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @":");
}

- (void)testNSMethodSignature_signatureFromBlock_NoCmdArgument
{
	id aBlock = ^BOOL(id self, NSNumber* aNumber, int intValue, double dblValue) {
		return YES;
	};
	
	NSMethodSignature *signature = [NSMethodSignature signatureFromBlock:aBlock];
	
	XCTAssertNotNil(signature);
	
	XCTAssertEqual(strcmp([signature methodReturnType], "B"), 0);
	XCTAssertEqual([signature methodReturnLength], 1);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 4);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @"@\"NSNumber\"");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:2], @"i");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:3], @"d");
	
}

- (void)testNSMethodSignature_signatureFromBlock_CmdArgument
{
	id aBlock = ^BOOL(id self, SEL _cmd, NSNumber* aNumber, int intValue, double dblValue) {
		return YES;
	};
	
	NSMethodSignature *signature = [NSMethodSignature signatureFromBlock:aBlock];
	
	XCTAssertNotNil(signature);
	
	XCTAssertEqual(strcmp([signature methodReturnType], "B"), 0);
	XCTAssertEqual([signature methodReturnLength], 1);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 5);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @":");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:2], @"@\"NSNumber\"");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:3], @"i");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:4], @"d");
}

- (void)testNSMethodSignature_signatureFromBlock_BadArguments
{
	id nilBlock = nil;
	
	XCTAssertThrowsSpecificNamed([NSMethodSignature signatureFromBlock:nilBlock], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([NSMethodSignature signatureFromBlock:(id)NSObject.new], NSException, NSInvalidArgumentException);
	
	Block_literal blockLiteral = {
		.isa = &_NSConcreteGlobalBlock,
		.flags = BLOCK_IS_GLOBAL,  // BLOCK_HAS_SIGNATURE is intentionally omitted
		.reserved = 0,
		.invoke = 0,
		.descriptor = 0};
	XCTAssertNil([NSMethodSignature signatureFromBlock:(__bridge id)&blockLiteral]);
}




- (void)testNSMethodSignature_methodSignatureFromBlock_NoCmdArgument_Minimal
{
	id aBlock = ^int(id self) {
		return YES;
	};
	
	NSMethodSignature *signature = [NSMethodSignature methodSignatureFromBlock:aBlock];
	XCTAssertNotNil(signature);
	
	XCTAssertEqualObjects(signature.methodReturnTypeString, @"i");
	XCTAssertEqual([signature methodReturnLength], 4);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 2);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @":");
}


- (void)testNSMethodSignature_methodSignatureFromBlock_CmdArgument_Minimal
{
	id aBlock = ^int(id self, SEL _cmd) {
		return YES;
	};
	
	NSMethodSignature *signature = [NSMethodSignature methodSignatureFromBlock:aBlock];
	XCTAssertNotNil(signature);
	
	XCTAssertEqualObjects(signature.methodReturnTypeString, @"i");
	XCTAssertEqual([signature methodReturnLength], 4);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 2);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @":");
}

- (void)testNSMethodSignature_methodSignatureFromBlock_NoCmdArgument
{
	id aBlock = ^int(id self, NSNumber* aNumber, int intValue, double dblValue) {
		return YES;
	};
	
	NSMethodSignature *signature = [NSMethodSignature methodSignatureFromBlock:aBlock];
	XCTAssertNotNil(signature);
	
	XCTAssertEqualObjects(signature.methodReturnTypeString, @"i");
	XCTAssertEqual([signature methodReturnLength], 4);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 5);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @":");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:2], @"@\"NSNumber\"");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:3], @"i");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:4], @"d");
}

- (void)testNSMethodSignature_methodSignatureFromBlock_CmdArgument
{
	id aBlock = ^int(id self, SEL _cmd, NSNumber* aNumber, int intValue, double dblValue) {
		return YES;
	};
	
	NSMethodSignature *signature = [NSMethodSignature methodSignatureFromBlock:aBlock];
	XCTAssertNotNil(signature);
	
	XCTAssertEqualObjects(signature.methodReturnTypeString, @"i");
	XCTAssertEqual([signature methodReturnLength], 4);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 5);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @":");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:2], @"@\"NSNumber\"");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:3], @"i");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:4], @"d");
}

- (void)testNSMethodSignature_methodSignatureFromBlock_struct
{
	struct myPoint {
		float x, y, z, w;
	};
	
	
	//array, structures, and without SEL __cmd
	id aBlock = ^int(id self, NSNumber __strong *pt[4], struct myPoint structValue, struct myPoint *structPtrValue, long double ld) {
		return YES;
	};
	NSMethodSignature *signature = [NSMethodSignature methodSignatureFromBlock:aBlock];
	
	XCTAssertNotNil(signature);
	
	XCTAssertEqualObjects(signature.methodReturnTypeString, @"i");
	XCTAssertEqual([signature methodReturnLength], 4);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 6);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @":");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:2], @"[4@]");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:3], @"{myPoint=ffff}");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:4], @"^{myPoint=ffff}");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:5], @"D");
}

- (void)testNSMethodSignature_methodSignatureFromBlock_BadArgument
{
	id nilBlock = nil;
	
	XCTAssertThrowsSpecificNamed([NSMethodSignature methodSignatureFromBlock:nilBlock], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([NSMethodSignature methodSignatureFromBlock:(id)NSObject.new], NSException, NSInvalidArgumentException);
	
	Block_literal blockLiteralNoSignature = {
		.isa = &_NSConcreteGlobalBlock,
		.flags = BLOCK_IS_GLOBAL,  // BLOCK_HAS_SIGNATURE is intentionally omitted
		.reserved = 0,
		.invoke = 0,
		.descriptor = 0};
	XCTAssertNil([NSMethodSignature methodSignatureFromBlock:(__bridge id)&blockLiteralNoSignature]);
	
	Block_descriptor descr = {
		.signature = "v"
	};
	
	Block_literal blockLiteral = {
		.isa = &_NSConcreteGlobalBlock,
		.flags = BLOCK_IS_GLOBAL | BLOCK_HAS_SIGNATURE,  // BLOCK_HAS_SIGNATURE is intentionally omitted
		.reserved = 0,
		.invoke = 0,
		.descriptor = &descr};
	XCTAssertNil([NSMethodSignature methodSignatureFromBlock:(__bridge id)&blockLiteral]);
}






- (void)testNSMethodSignature_getArgumentSizeAtIndex_unionsUnsupported
{
	union manyData {
		float _float;
		int _int;
		long long _longlong;
	};
	
	id aBlock = ^void*(union manyData data) {
		return nil;
	};
	
	XCTAssertThrowsSpecificNamed([NSMethodSignature signatureFromBlock:aBlock], NSException,
								 NSInvalidArgumentException, @"if this fails, write the test code to check union argument types");
}


- (void)testNSMethodSignature_getArgumentSizeAtIndex
{
	struct myPoint {
		float x, y;
		int index;
		char characters[4];
	};
	
	struct myPointUnion {
		float x, y;
		int index;
		char characters[4];
		union {
			float	f, fi;
			double	d;
		};
	};
	
	id aBlock = ^NSNumber*(id _self, SEL _cmd, NSNumber* aNumber, int intValue, double dblValue, float array[3], float multiArray[2][4], double *dbl, double **dblHandle, struct myPoint *pointPtr, struct myPoint point, struct myPointUnion complexPoint) {
		return nil;
	};
	
	NSMethodSignature *signature = [NSMethodSignature signatureFromBlock:aBlock];
	
	XCTAssertNotNil(signature);
	
	XCTAssertEqual(strcmp([signature methodReturnType], "@\"NSNumber\""), 0);
	XCTAssertEqual([signature methodReturnLength], 8);
	XCTAssertEqual([signature frameLength], 248);
	
	XCTAssertEqual(signature.numberOfArguments, 12);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqual([signature getArgumentSizeAtIndex:0], sizeof(long));
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @":");
	XCTAssertEqual([signature getArgumentSizeAtIndex:1], sizeof(long));
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:2], @"@\"NSNumber\"");
	XCTAssertEqual([signature getArgumentSizeAtIndex:2], sizeof(long));
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:3], @"i");
	XCTAssertEqual([signature getArgumentSizeAtIndex:3], sizeof(int));
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:4], @"d");
	XCTAssertEqual([signature getArgumentSizeAtIndex:4], sizeof(double));
	
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:5], @"[3f]");
	XCTAssertEqual([signature getArgumentSizeAtIndex:5], sizeof(long));
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:6], @"[2[4f]]");
	XCTAssertEqual([signature getArgumentSizeAtIndex:6], sizeof(long));
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:7], @"^d");
	XCTAssertEqual([signature getArgumentSizeAtIndex:7], sizeof(long*));
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:8], @"^^d");
	XCTAssertEqual([signature getArgumentSizeAtIndex:8], sizeof(long**));
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:9], @"^{myPoint=ffi[4c]}");
	XCTAssertEqual([signature getArgumentSizeAtIndex:9], sizeof(struct myPoint*));
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:10], @"{myPoint=ffi[4c]}");
	XCTAssertEqual([signature getArgumentSizeAtIndex:10], sizeof(struct myPoint*));
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:11], @"{myPointUnion}");
	XCTAssertEqual([signature getArgumentSizeAtIndex:11], sizeof(struct myPointUnion*));
	
	
	id integerArgumentBlock = ^void(id _self, char c, unsigned char uc, short s, unsigned short us, int i, unsigned int ui, long l, unsigned long ul, long long ll, unsigned long long ull, BOOL b) {
	};
	
	NSMethodSignature *intSignature = [NSMethodSignature signatureFromBlock:integerArgumentBlock];
	
	XCTAssertEqual(intSignature.numberOfArguments, 12);
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:0], sizeof(long));
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:1], @"c");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:1], sizeof(int));
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:2], @"C");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:2], sizeof(int));
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:3], @"s");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:3], sizeof(int));
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:4], @"S");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:4], sizeof(int));
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:5], @"i");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:5], sizeof(int));
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:6], @"I");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:6], sizeof(int));
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:7], @"q");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:7], sizeof(long));
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:8], @"Q");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:8], sizeof(long));
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:9], @"q");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:9], sizeof(long long));
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:10], @"Q");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:10], sizeof(unsigned long long));
	XCTAssertEqualObjects([intSignature getArgumentTypeStringAtIndex:11], @"B");
	XCTAssertEqual([intSignature getArgumentSizeAtIndex:11], sizeof(int));
	
	id floatOtherBlock = ^void(id _self, char *cString, SEL selector, Class aClass, int *ptr, int a[4], struct myPoint pt, float f, double d, long double ld) {
		
	};
	
	NSMethodSignature *floatOtherSignature = [NSMethodSignature signatureFromBlock:floatOtherBlock];
	XCTAssertEqual(floatOtherSignature.numberOfArguments, 10);
	XCTAssertEqualObjects([floatOtherSignature getArgumentTypeStringAtIndex:1], @"*");
	XCTAssertEqual([floatOtherSignature getArgumentSizeAtIndex:1], sizeof(char*));
	XCTAssertEqualObjects([floatOtherSignature getArgumentTypeStringAtIndex:2], @":");
	XCTAssertEqual([floatOtherSignature getArgumentSizeAtIndex:2], sizeof(SEL));
	XCTAssertEqualObjects([floatOtherSignature getArgumentTypeStringAtIndex:3], @"#");
	XCTAssertEqual([floatOtherSignature getArgumentSizeAtIndex:3], sizeof(Class));
	XCTAssertEqualObjects([floatOtherSignature getArgumentTypeStringAtIndex:4], @"^i");
	XCTAssertEqual([floatOtherSignature getArgumentSizeAtIndex:4], sizeof(int*));
	XCTAssertEqualObjects([floatOtherSignature getArgumentTypeStringAtIndex:5], @"[4i]");
	XCTAssertEqual([floatOtherSignature getArgumentSizeAtIndex:5], sizeof(int*));
	XCTAssertEqualObjects([floatOtherSignature getArgumentTypeStringAtIndex:6], @"{myPoint=ffi[4c]}");
	XCTAssertEqual([floatOtherSignature getArgumentSizeAtIndex:6], sizeof(struct myPoint*));
	XCTAssertEqualObjects([floatOtherSignature getArgumentTypeStringAtIndex:7], @"f");
	XCTAssertEqual([floatOtherSignature getArgumentSizeAtIndex:7], sizeof(float));
	XCTAssertEqualObjects([floatOtherSignature getArgumentTypeStringAtIndex:8], @"d");
	XCTAssertEqual([floatOtherSignature getArgumentSizeAtIndex:8], sizeof(double));
	XCTAssertEqualObjects([floatOtherSignature getArgumentTypeStringAtIndex:9], @"D");
	XCTAssertEqual([floatOtherSignature getArgumentSizeAtIndex:9], sizeof(long double));
	
}

- (void)testNSMethodSignature_unsupportedUnion
{
	CustomNSMethodSignature *signature = [CustomNSMethodSignature.alloc init];
	
	
	XCTAssertEqualObjects([signature className], NSStringFromClass(CustomNSMethodSignature.class));
	
	XCTAssertEqual([signature getArgumentSizeAtIndex:0], 0);
	
	if (strcmp(@encode(long), @encode(int)) && strcmp(@encode(long), @encode(long long))) {
		XCTAssertEqual([signature getArgumentSizeAtIndex:1], sizeof(long));
		XCTAssertEqual([signature getArgumentSizeAtIndex:2], sizeof(unsigned long));
	}
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:3], @"(union=csi)");
	XCTAssertEqual([signature getArgumentSizeAtIndex:3], sizeof(void*));
}



#pragma mark - BEMethodSignatureHelper Methods

- (void)testBEMethodSignatureHelper_rawBlockSignatureChar
{
	id aBlock = ^BOOL(id self, SEL _cmd, NSNumber* aNumber, int intValue, double dblValue) {
		return YES;
	};
	
	const char *signatureChars = [BEMethodSignatureHelper rawBlockSignatureChar:aBlock];
	
	XCTAssertTrue(signatureChars != nil);
	
	NSString *signature = [NSString stringWithCString:signatureChars encoding:NSASCIIStringEncoding];
	
	XCTAssertEqualObjects(signature, @"B44@?0@8:16@\"NSNumber\"24i32d36");
}


- (void)testBEMethodSignatureHelper_rawBlockSignatureChar_BadArguments
{
	id nilBlock = nil;
	
	XCTAssertThrowsSpecificNamed([BEMethodSignatureHelper rawBlockSignatureChar:nilBlock], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([BEMethodSignatureHelper rawBlockSignatureChar:(id)NSObject.new], NSException, NSInvalidArgumentException);
	
	Block_literal blockLiteral = {
		.isa = &_NSConcreteGlobalBlock,
		.flags = BLOCK_IS_GLOBAL,  // BLOCK_HAS_SIGNATURE is intentionally omitted
		.reserved = 0,
		.invoke = 0,
		.descriptor = 0};
	XCTAssertEqual([BEMethodSignatureHelper rawBlockSignatureChar:(__bridge id)&blockLiteral], nil);
}


- (void)testBEMethodSignatureHelper_rawBlockSignatureString
{
	id aBlock = ^BOOL(id self, SEL _cmd, NSNumber* aNumber, int intValue, double dblValue) {
		return YES;
	};
	
	NSString *signature = [BEMethodSignatureHelper rawBlockSignatureString:aBlock];
	
	XCTAssertTrue(signature != nil);
	
	XCTAssertEqualObjects(signature, @"B44@?0@8:16@\"NSNumber\"24i32d36");
}


- (void)testBEMethodSignatureHelper_rawBlockSignatureString_BadArguments
{
	id nilBlock = nil;
	
	XCTAssertThrowsSpecificNamed([BEMethodSignatureHelper rawBlockSignatureString:nilBlock], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([BEMethodSignatureHelper rawBlockSignatureString:(id)NSObject.new], NSException, NSInvalidArgumentException);
	
	Block_literal blockLiteral = {
		.isa = &_NSConcreteGlobalBlock,
		.flags = BLOCK_IS_GLOBAL,  // BLOCK_HAS_SIGNATURE is intentionally omitted
		.reserved = 0,
		.invoke = 0,
		.descriptor = 0};
	XCTAssertNil([BEMethodSignatureHelper rawBlockSignatureString:(__bridge id)&blockLiteral]);
}


- (void)testBEMethodSignatureHelper_blockSignatureString_NoCmdArgument
{
	id aBlock = ^BOOL(id self, NSNumber* aNumber, int intValue, double dblValue) {
		return YES;
	};
	
	NSString *signature = [BEMethodSignatureHelper blockSignatureString:aBlock];
	
	XCTAssertTrue(signature != nil);
	
	XCTAssertEqualObjects(signature, @"B28@0@\"NSNumber\"8i16d20");
}


- (void)testBEMethodSignatureHelper_blockSignatureString_cmdArgument
{
	id aBlock = ^BOOL(id self, SEL _cmd, NSNumber* aNumber, int intValue, double dblValue) {
		return YES;
	};
	
	NSString *signature = [BEMethodSignatureHelper blockSignatureString:aBlock];
	
	XCTAssertTrue(signature != nil);
	
	XCTAssertEqualObjects(signature, @"B36@0:8@\"NSNumber\"16i24d28");
}


- (void)testBEMethodSignatureHelper_blockSignatureString_BadArguments
{
	id nilBlock = nil;
	
	XCTAssertThrowsSpecificNamed([BEMethodSignatureHelper blockSignatureString:nilBlock], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([BEMethodSignatureHelper blockSignatureString:(id)NSObject.new], NSException, NSInvalidArgumentException);
	
	Block_literal blockLiteral = {
		.isa = &_NSConcreteGlobalBlock,
		.flags = BLOCK_IS_GLOBAL,  // BLOCK_HAS_SIGNATURE is intentionally omitted
		.reserved = 0,
		.invoke = 0,
		.descriptor = 0};
	XCTAssertNil([BEMethodSignatureHelper blockSignatureString:(__bridge id)&blockLiteral]);
}

- (void)testBEMethodSignatureHelper_parseBlockSignature
{
	const char *nilString = 0;
	XCTAssertNil([BEMethodSignatureHelper parseBlockSignature:nilString parseFlags:BENoMethodSignatureFlag]);
	XCTAssertNil([BEMethodSignatureHelper parseBlockSignature:"" parseFlags:BENoMethodSignatureFlag]);
	XCTAssertNil([BEMethodSignatureHelper parseBlockSignature:"v" parseFlags:BENoMethodSignatureFlag]);
	XCTAssertNil([BEMethodSignatureHelper parseBlockSignature:"i" parseFlags:BENoMethodSignatureFlag]);
	XCTAssertEqualObjects([BEMethodSignatureHelper parseBlockSignature:"v0" parseFlags:BENoMethodSignatureFlag], @"v0");
	XCTAssertNil([BEMethodSignatureHelper parseBlockSignature:"v8^8" parseFlags:BENoMethodSignatureFlag]);
}

- (void)testBEMethodSignatureHelper_parseTypeAtPointer
{
	const char *badType = "10", *c = "c0", *ptrWOType = "^", *arrayWOType = "[=0", *arrayStart = "[", *structWOType = "{=0";
	const char *unionBlankType = "()", *unionNamedType = "(aUnion)", *unionWOType = "(=0)";
	const char *bitfieldType = "b32";
	XCTAssertNil([BEMethodSignatureHelper parseTypeAtPointer:&badType]);
	
	XCTAssertEqualObjects([BEMethodSignatureHelper parseTypeAtPointer:&c], @"c");
	XCTAssertNil([BEMethodSignatureHelper parseTypeAtPointer:&ptrWOType]);
	XCTAssertEqualObjects([BEMethodSignatureHelper parseTypeAtPointer:&arrayWOType], @"[=");
	XCTAssertNil([BEMethodSignatureHelper parseTypeAtPointer:&arrayStart]);
	XCTAssertEqualObjects([BEMethodSignatureHelper parseTypeAtPointer:&structWOType], @"{=");
	
	XCTAssertEqualObjects([BEMethodSignatureHelper parseTypeAtPointer:&unionBlankType], @"()");
	XCTAssertEqualObjects([BEMethodSignatureHelper parseTypeAtPointer:&unionNamedType], @"(aUnion)");
	XCTAssertEqualObjects([BEMethodSignatureHelper parseTypeAtPointer:&unionWOType], @"(=");
	
	XCTAssertEqualObjects([BEMethodSignatureHelper parseTypeAtPointer:&bitfieldType], @"b32");
}

- (void)testBEMethodSignatureHelper_parseNumberAtPointer
{
	const char *number = "42", *charNumber = "char53", *zeroString = "", *nilString = nil;
	
	XCTAssertEqual([BEMethodSignatureHelper parseNumberAtPointer:&nilString], 0);
	XCTAssertEqual([BEMethodSignatureHelper parseNumberAtPointer:&zeroString], 0);
	XCTAssertEqual([BEMethodSignatureHelper parseNumberAtPointer:&number], 42);
	XCTAssertEqual([BEMethodSignatureHelper parseNumberAtPointer:&charNumber], 53);
}

@end

/*
 
 
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
 
 // performSelector
 
 #pragma clang diagnostic pop
 
 */
