/*!
 @file			NSObject+MacroableTests.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Unit tests for NSObject+Macroable and BEMacroMeta.
 @discussion	Tests cover:
 				- BEMacroMeta initialisation and property access
 				- Class-level macro enable / disable / isMacrosEnabled
 				- macro:macroBlock: registration, replacement, and nil-block removal
 				- hasMacro: / removeMacro: / flushMacros
 				- Invocation of class macros from instances
 				- Object-level macros (objectMacro:macroBlock: family)
 				- Isolation: object macros do not bleed to other instances or the class
 				- Interaction between class macros and object macros
 				- Subclass does NOT automatically inherit a parent's class macro
 */

#import <XCTest/XCTest.h>
#import <BEFoundation/NSObject+Macroable.h>

// ---------------------------------------------------------------------------
// Minimal test fixture classes
// ---------------------------------------------------------------------------

/// Plain NSObject subclass used as the class-under-test for macros.
@interface MacroableTestObject : NSObject
@end
@implementation MacroableTestObject
@end

/// Direct subclass – used to verify that class macros are NOT automatically
/// inherited by subclasses.
@interface MacroableTestObjectSubclass : MacroableTestObject
@end
@implementation MacroableTestObjectSubclass
@end

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Invoke a zero-argument macro on an instance and return the id result.
static id invokeClassMacroNoArgs(id target, SEL sel)
{
	NSMethodSignature *sig = [target methodSignatureForSelector:sel];
	if (!sig) { return nil; }
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
	inv.target   = target;
	inv.selector = sel;
	[inv invoke];
	__unsafe_unretained id result = nil;
	[inv getReturnValue:&result];
	return result;
}

/// Invoke a single-argument macro on an instance and return the id result.
static id invokeClassMacroOneArg(id target, SEL sel, id arg)
{
	NSMethodSignature *sig = [target methodSignatureForSelector:sel];
	if (!sig) { return nil; }
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
	inv.target   = target;
	inv.selector = sel;
	[inv setArgument:&arg atIndex:2];
	[inv invoke];
	__unsafe_unretained id result = nil;
	[inv getReturnValue:&result];
	return result;
}

// ---------------------------------------------------------------------------
// Test suite
// ---------------------------------------------------------------------------

@interface NSObject_MacroableTests : XCTestCase
@end

@implementation NSObject_MacroableTests

- (void)setUp
{
	// Start each test from a clean, disabled state on both classes.
	[MacroableTestObject flushMacros];
	[MacroableTestObject disableMacros];
	[MacroableTestObjectSubclass flushMacros];
	[MacroableTestObjectSubclass disableMacros];
}

- (void)tearDown
{
	[MacroableTestObject flushMacros];
	[MacroableTestObject disableMacros];
	[MacroableTestObjectSubclass flushMacros];
	[MacroableTestObjectSubclass disableMacros];
}

// ===========================================================================
#pragma mark - BEMacroMeta
// ===========================================================================

- (void)testBEMacroMeta_initWithValidSelectorAndBlock_ReturnsNonNil
{
	SEL sel = @selector(description);
	id  blk = ^NSString*(id _self) { return @"test"; };

	BEMacroMeta *meta = [[BEMacroMeta alloc] initWithSelector:sel block:blk];

	XCTAssertNotNil(meta);
	XCTAssertEqual(meta.selector, sel);
	XCTAssertEqualObjects(meta.block, blk);
}

- (void)testBEMacroMeta_initWithNilBlock_StoresNilBlock
{
	SEL sel = @selector(description);

	BEMacroMeta *meta = [[BEMacroMeta alloc] initWithSelector:sel block:nil];

	XCTAssertNotNil(meta);
	XCTAssertEqual(meta.selector, sel);
	XCTAssertNil(meta.block);
}

- (void)testBEMacroMeta_selectorProperty_IsReadOnly
{
	// Verify selector is accessible after init (compile-time check covered by
	// the readonly property declaration; this confirms it is set correctly).
	BEMacroMeta *meta = [[BEMacroMeta alloc] initWithSelector:@selector(hash) block:nil];
	XCTAssertEqual(meta.selector, @selector(hash));
}

// ===========================================================================
#pragma mark - enableMacros / disableMacros / isMacrosEnabled
// ===========================================================================

- (void)testIsMacrosEnabled_InitiallyDisabled
{
	// setUp already called disableMacros; confirm the default.
	XCTAssertFalse([MacroableTestObject isMacrosEnabled]);
}

- (void)testEnableMacros_WhenDisabled_ReturnsYES
{
	BOOL result = [MacroableTestObject enableMacros];
	XCTAssertTrue(result);
}

- (void)testEnableMacros_WhenAlreadyEnabled_ReturnsNO
{
	[MacroableTestObject enableMacros];
	BOOL result = [MacroableTestObject enableMacros];
	XCTAssertFalse(result);
}

- (void)testIsMacrosEnabled_AfterEnable_ReturnsYES
{
	[MacroableTestObject enableMacros];
	XCTAssertTrue([MacroableTestObject isMacrosEnabled]);
}

- (void)testDisableMacros_WhenEnabled_ReturnsYES
{
	[MacroableTestObject enableMacros];
	BOOL result = [MacroableTestObject disableMacros];
	XCTAssertTrue(result);
}

- (void)testDisableMacros_WhenAlreadyDisabled_ReturnsNO
{
	// setUp left macros disabled.
	BOOL result = [MacroableTestObject disableMacros];
	XCTAssertFalse(result);
}

- (void)testIsMacrosEnabled_AfterDisable_ReturnsFalse
{
	[MacroableTestObject enableMacros];
	[MacroableTestObject disableMacros];
	XCTAssertFalse([MacroableTestObject isMacrosEnabled]);
}

- (void)testDisableMacros_KeepsMacroRegistered_NotCallable_ReEnableRestores
{
	// Header contract: disabling keeps macros registered but not callable; re-enabling restores them.
	SEL sel = NSSelectorFromString(@"testDisableKeepsRegistered");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @"v"; }];

	MacroableTestObject *obj = MacroableTestObject.new;
	XCTAssertTrue([obj respondsToSelector:sel]);

	[MacroableTestObject disableMacros];
	XCTAssertTrue([MacroableTestObject hasMacro:sel],
				  @"Macro should remain registered after disable");
	XCTAssertFalse([obj respondsToSelector:sel],
				   @"Disabled macro must not be callable");

	[MacroableTestObject enableMacros];
	XCTAssertTrue([obj respondsToSelector:sel],
				  @"Re-enabling should restore the previously registered macro");
	XCTAssertEqualObjects(invokeClassMacroNoArgs(obj, sel), @"v");
}

// ===========================================================================
#pragma mark - macro:macroBlock:
// ===========================================================================

- (void)testMacro_NilSelector_ReturnsNO
{
	SEL nilSel = nil;
	BOOL result = [MacroableTestObject macro:nilSel macroBlock:^(id _self){}];
	XCTAssertFalse(result);
}

- (void)testMacro_ValidSelectorAndBlock_ReturnsYES
{
	SEL sel = NSSelectorFromString(@"testMacroAdd");
	BOOL result = [MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @"hi"; }];
	XCTAssertTrue(result);
}

- (void)testMacro_AutoEnablesMacros
{
	// Macros are disabled in setUp; adding a macro should enable them.
	XCTAssertFalse([MacroableTestObject isMacrosEnabled]);
	SEL sel = NSSelectorFromString(@"testMacroAutoEnable");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @""; }];
	XCTAssertTrue([MacroableTestObject isMacrosEnabled]);
}

- (void)testMacro_NilBlock_WithExistingMacro_RemovesMacro
{
	SEL sel = NSSelectorFromString(@"testMacroNilBlockRemove");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @"v1"; }];
	XCTAssertTrue([MacroableTestObject hasMacro:sel]);

	BOOL result = [MacroableTestObject macro:sel macroBlock:nil];

	XCTAssertTrue(result);
	XCTAssertFalse([MacroableTestObject hasMacro:sel]);
}

- (void)testMacro_NilBlock_WithNoExistingMacro_ReturnsYES
{
	// nil block on a selector that was never registered still returns YES.
	SEL sel = NSSelectorFromString(@"testMacroNilBlockNonExistent");
	BOOL result = [MacroableTestObject macro:sel macroBlock:nil];
	XCTAssertTrue(result);
}

- (void)testMacro_Replacement_UpdatesBlock
{
	SEL sel = NSSelectorFromString(@"testMacroReplace");
	id  block1 = ^NSString*(id _self){ return @"v1"; };
	id  block2 = ^NSString*(id _self){ return @"v2"; };

	[MacroableTestObject macro:sel macroBlock:block1];
	[MacroableTestObject macro:sel macroBlock:block2];

	// After replacement the macro dictionary should still have exactly one entry.
	XCTAssertTrue([MacroableTestObject hasMacro:sel]);

	MacroableTestObject *obj = MacroableTestObject.new;
	NSString *result = invokeClassMacroNoArgs(obj, sel);
	XCTAssertEqualObjects(result, @"v2");
}

- (void)testMacro_MultipleMacros_CoexistIndependently
{
	SEL sel1 = NSSelectorFromString(@"testMacroMultiA");
	SEL sel2 = NSSelectorFromString(@"testMacroMultiB");

	[MacroableTestObject macro:sel1 macroBlock:^NSString*(id _self){ return @"A"; }];
	[MacroableTestObject macro:sel2 macroBlock:^NSString*(id _self){ return @"B"; }];

	XCTAssertTrue([MacroableTestObject hasMacro:sel1]);
	XCTAssertTrue([MacroableTestObject hasMacro:sel2]);
}

// ===========================================================================
#pragma mark - hasMacro:
// ===========================================================================

- (void)testHasMacro_NilSelector_ReturnsNO
{
	SEL nilSel = nil;
	XCTAssertFalse([MacroableTestObject hasMacro:nilSel]);
}

- (void)testHasMacro_BeforeRegistration_ReturnsNO
{
	SEL sel = NSSelectorFromString(@"testHasMacroNotYet");
	XCTAssertFalse([MacroableTestObject hasMacro:sel]);
}

- (void)testHasMacro_AfterRegistration_ReturnsYES
{
	SEL sel = NSSelectorFromString(@"testHasMacroAfterAdd");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @""; }];
	XCTAssertTrue([MacroableTestObject hasMacro:sel]);
}

- (void)testHasMacro_AfterRemoveMacro_ReturnsNO
{
	SEL sel = NSSelectorFromString(@"testHasMacroAfterRemove");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @""; }];
	[MacroableTestObject removeMacro:sel];
	XCTAssertFalse([MacroableTestObject hasMacro:sel]);
}

- (void)testHasMacro_AfterFlushMacros_ReturnsNO
{
	SEL sel = NSSelectorFromString(@"testHasMacroAfterFlush");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @""; }];
	[MacroableTestObject flushMacros];
	XCTAssertFalse([MacroableTestObject hasMacro:sel]);
}

// ===========================================================================
#pragma mark - removeMacro:
// ===========================================================================

- (void)testRemoveMacro_NilSelector_ReturnsNO
{
	SEL nilSel = nil;
	XCTAssertFalse([MacroableTestObject removeMacro:nilSel]);
}

- (void)testRemoveMacro_NonExistentSelector_ReturnsNO
{
	SEL sel = NSSelectorFromString(@"testRemoveMacroNonExistent");
	XCTAssertFalse([MacroableTestObject removeMacro:sel]);
}

- (void)testRemoveMacro_ExistingMacro_ReturnsYES
{
	SEL sel = NSSelectorFromString(@"testRemoveMacroExisting");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @""; }];
	BOOL result = [MacroableTestObject removeMacro:sel];
	XCTAssertTrue(result);
}

- (void)testRemoveMacro_AfterRemoval_MacroGone
{
	SEL sel = NSSelectorFromString(@"testRemoveMacroGone");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @""; }];
	[MacroableTestObject removeMacro:sel];

	MacroableTestObject *obj = MacroableTestObject.new;
	NSMethodSignature *sig = [obj methodSignatureForSelector:sel];
	XCTAssertNil(sig, @"After removal the instance should not find a method signature");
}

// ===========================================================================
#pragma mark - flushMacros
// ===========================================================================

- (void)testFlushMacros_RemovesAllRegisteredMacros
{
	SEL sel1 = NSSelectorFromString(@"testFlushA");
	SEL sel2 = NSSelectorFromString(@"testFlushB");
	[MacroableTestObject macro:sel1 macroBlock:^NSString*(id _self){ return @""; }];
	[MacroableTestObject macro:sel2 macroBlock:^NSString*(id _self){ return @""; }];

	[MacroableTestObject flushMacros];

	XCTAssertFalse([MacroableTestObject hasMacro:sel1]);
	XCTAssertFalse([MacroableTestObject hasMacro:sel2]);
}

- (void)testFlushMacros_OnClassWithNoMacros_DoesNotCrash
{
	XCTAssertNoThrow([MacroableTestObject flushMacros]);
}

- (void)testFlushMacros_CalledTwiceConsecutively_DoesNotCrash
{
	SEL sel = NSSelectorFromString(@"testFlushTwice");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @""; }];
	XCTAssertNoThrow([MacroableTestObject flushMacros]);
	XCTAssertNoThrow([MacroableTestObject flushMacros]);
}

// ===========================================================================
#pragma mark - Macro Invocation
// ===========================================================================

- (void)testMacroInvocation_InstanceCanInvokeClassMacro
{
	SEL sel = NSSelectorFromString(@"testMacroInvokeInstance");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @"invoked"; }];

	MacroableTestObject *obj = MacroableTestObject.new;
	XCTAssertTrue([obj respondsToSelector:sel],
				  @"Instance should respond to a registered class macro");
}

- (void)testMacroInvocation_ReturnsCorrectValue_NoArgs
{
	SEL sel = NSSelectorFromString(@"testMacroReturnValue");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @"hello"; }];

	MacroableTestObject *obj = MacroableTestObject.new;
	NSString *result = invokeClassMacroNoArgs(obj, sel);
	XCTAssertEqualObjects(result, @"hello");
}

- (void)testMacroInvocation_ReturnsCorrectValue_WithOneArgument
{
	SEL sel = NSSelectorFromString(@"testMacroWithArg:");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self, NSString *input){
		return [NSString stringWithFormat:@"got:%@", input];
	}];

	MacroableTestObject *obj = MacroableTestObject.new;
	NSString *result = invokeClassMacroOneArg(obj, sel, @"world");
	XCTAssertEqualObjects(result, @"got:world");
}

- (void)testMacroInvocation_SelfArgumentIsCorrectInstance
{
	// The first argument the block receives should be the instance the macro
	// is invoked on.
	SEL sel = NSSelectorFromString(@"testMacroSelfArg");
	__block id capturedSelf = nil;
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){
		capturedSelf = _self;
		return @"";
	}];

	MacroableTestObject *obj = MacroableTestObject.new;
	invokeClassMacroNoArgs(obj, sel);
	XCTAssertEqual(capturedSelf, obj);
}

- (void)testMacroInvocation_AllInstancesShareClassMacro
{
	SEL sel = NSSelectorFromString(@"testMacroShared");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @"shared"; }];

	MacroableTestObject *obj1 = MacroableTestObject.new;
	MacroableTestObject *obj2 = MacroableTestObject.new;
	NSString *r1 = invokeClassMacroNoArgs(obj1, sel);
	NSString *r2 = invokeClassMacroNoArgs(obj2, sel);
	XCTAssertEqualObjects(r1, @"shared");
	XCTAssertEqualObjects(r2, @"shared");
}

- (void)testMacroInvocation_AfterRemoveMacro_InstanceDoesNotRespond
{
	SEL sel = NSSelectorFromString(@"testMacroRemovedResponds");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @""; }];
	[MacroableTestObject removeMacro:sel];

	MacroableTestObject *obj = MacroableTestObject.new;
	XCTAssertFalse([obj respondsToSelector:sel]);
}

- (void)testMacroInvocation_ClassDoesNotRespondToClassMacro
{
	// Class macros are instance-facing (via addClassMethod:block:), so the
	// class object itself should NOT respond to the selector.
	SEL sel = NSSelectorFromString(@"testMacroClassLevel");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @""; }];

	XCTAssertFalse([MacroableTestObject respondsToSelector:sel],
				   @"Class object must not respond to an instance-facing class macro");
}

// ===========================================================================
#pragma mark - objectMacro:macroBlock:
// ===========================================================================

- (void)testObjectMacro_NilSelector_ReturnsNO
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL nilSel = nil;
	XCTAssertFalse([obj objectMacro:nilSel macroBlock:^(id _self){}]);
}

- (void)testObjectMacro_ValidSelectorAndBlock_ReturnsYES
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testObjMacroAdd");
	BOOL result = [obj objectMacro:sel macroBlock:^NSString*(id _self){ return @"obj"; }];
	XCTAssertTrue(result);
}

- (void)testObjectMacro_NilBlock_WithExistingMacro_RemovesMacro
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testObjMacroNilBlockRemove");
	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @""; }];
	XCTAssertTrue([obj hasObjectMacro:sel]);

	BOOL result = [obj objectMacro:sel macroBlock:nil];

	XCTAssertTrue(result);
	XCTAssertFalse([obj hasObjectMacro:sel]);
}

- (void)testObjectMacro_NilBlock_NoExistingMacro_ReturnsYES
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testObjMacroNilBlockNone");
	BOOL result = [obj objectMacro:sel macroBlock:nil];
	XCTAssertTrue(result);
}

// ===========================================================================
#pragma mark - hasObjectMacro:
// ===========================================================================

- (void)testHasObjectMacro_NilSelector_ReturnsNO
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL nilSel = nil;
	XCTAssertFalse([obj hasObjectMacro:nilSel]);
}

- (void)testHasObjectMacro_BeforeRegistration_ReturnsNO
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testHasObjMacroNotYet");
	XCTAssertFalse([obj hasObjectMacro:sel]);
}

- (void)testHasObjectMacro_AfterRegistration_ReturnsYES
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testHasObjMacroAfterAdd");
	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @""; }];
	XCTAssertTrue([obj hasObjectMacro:sel]);
}

- (void)testHasObjectMacro_AfterRemoval_ReturnsNO
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testHasObjMacroAfterRemove");
	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @""; }];
	[obj removeObjectMacro:sel];
	XCTAssertFalse([obj hasObjectMacro:sel]);
}

// ===========================================================================
#pragma mark - removeObjectMacro:
// ===========================================================================

- (void)testRemoveObjectMacro_NilSelector_ReturnsNO
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL nilSel = nil;
	XCTAssertFalse([obj removeObjectMacro:nilSel]);
}

- (void)testRemoveObjectMacro_NonExistent_ReturnsNO
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testRemoveObjMacroNonExistent");
	XCTAssertFalse([obj removeObjectMacro:sel]);
}

- (void)testRemoveObjectMacro_Existing_ReturnsYES
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testRemoveObjMacroExisting");
	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @""; }];
	XCTAssertTrue([obj removeObjectMacro:sel]);
}

// ===========================================================================
#pragma mark - flushObjectMacros
// ===========================================================================

- (void)testFlushObjectMacros_RemovesAllObjectMacros
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel1 = NSSelectorFromString(@"testFlushObjA");
	SEL sel2 = NSSelectorFromString(@"testFlushObjB");
	[obj objectMacro:sel1 macroBlock:^NSString*(id _self){ return @""; }];
	[obj objectMacro:sel2 macroBlock:^NSString*(id _self){ return @""; }];

	[obj flushObjectMacros];

	XCTAssertFalse([obj hasObjectMacro:sel1]);
	XCTAssertFalse([obj hasObjectMacro:sel2]);
}

- (void)testFlushObjectMacros_OnFreshObject_DoesNotCrash
{
	MacroableTestObject *obj = MacroableTestObject.new;
	XCTAssertNoThrow([obj flushObjectMacros]);
}

- (void)testFlushObjectMacros_CalledTwice_DoesNotCrash
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testFlushObjTwice");
	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @""; }];
	XCTAssertNoThrow([obj flushObjectMacros]);
	XCTAssertNoThrow([obj flushObjectMacros]);
}

// ===========================================================================
#pragma mark - Object Macro Invocation
// ===========================================================================

- (void)testObjectMacroInvocation_ReturnsCorrectValue
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testObjMacroReturnValue");
	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @"obj-result"; }];

	NSString *result = invokeClassMacroNoArgs(obj, sel);
	XCTAssertEqualObjects(result, @"obj-result");
}

- (void)testObjectMacroInvocation_WithOneArgument
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testObjMacroWithArg:");
	[obj objectMacro:sel macroBlock:^NSString*(id _self, NSString *input){
		return [NSString stringWithFormat:@"obj:%@", input];
	}];

	NSString *result = invokeClassMacroOneArg(obj, sel, @"arg");
	XCTAssertEqualObjects(result, @"obj:arg");
}

// ===========================================================================
#pragma mark - Isolation
// ===========================================================================

- (void)testObjectMacro_DoesNotAffectOtherInstances
{
	MacroableTestObject *obj1 = MacroableTestObject.new;
	MacroableTestObject *obj2 = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testObjMacroIsolation");

	[obj1 objectMacro:sel macroBlock:^NSString*(id _self){ return @"only obj1"; }];

	XCTAssertTrue([obj1 hasObjectMacro:sel]);
	XCTAssertFalse([obj2 hasObjectMacro:sel],
				   @"Object macro on obj1 must not be visible on obj2");
}

- (void)testObjectMacro_DoesNotAppearAtClassLevel
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testObjMacroClassLevel");
	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @""; }];

	// The class object itself should not respond to an object-level macro.
	XCTAssertFalse([MacroableTestObject respondsToSelector:sel],
				   @"Object macro must not surface as a class-level method");
}

- (void)testClassMacro_DoesNotSetHasObjectMacro
{
	SEL sel = NSSelectorFromString(@"testClassMacroNoObjMacro");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @""; }];

	MacroableTestObject *obj = MacroableTestObject.new;
	// A class macro is instance-facing but is NOT the same as an object macro.
	XCTAssertFalse([obj hasObjectMacro:sel],
				   @"A class macro must not report as an object macro on an instance");
}

- (void)testObjectMacro_OverridesClassMacroOnSpecificInstance
{
	// Register a class macro returning "class-v" for all instances.
	SEL sel = NSSelectorFromString(@"testMacroOverride");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @"class-v"; }];

	MacroableTestObject *obj = MacroableTestObject.new;
	// Override just this instance with a different block.
	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @"obj-v"; }];

	// This instance should see the object-level override.
	NSString *result = invokeClassMacroNoArgs(obj, sel);
	XCTAssertEqualObjects(result, @"obj-v");
}

- (void)testClassMacro_OtherInstanceUnaffectedByObjectMacroOverride
{
	SEL sel = NSSelectorFromString(@"testMacroOverrideOther");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @"class-v"; }];

	MacroableTestObject *obj1 = MacroableTestObject.new;
	MacroableTestObject *obj2 = MacroableTestObject.new;
	[obj1 objectMacro:sel macroBlock:^NSString*(id _self){ return @"obj-v"; }];

	// obj2 was NOT given an object-level override; it should still see the class macro.
	NSString *result = invokeClassMacroNoArgs(obj2, sel);
	XCTAssertEqualObjects(result, @"class-v",
						  @"Unmodified instance should still use the class macro");
}

- (void)testRemoveClassMacro_ObjectMacroOnInstanceStillWorks
{
	SEL sel = NSSelectorFromString(@"testRemoveClassKeepObj");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @"class-v"; }];

	MacroableTestObject *obj = MacroableTestObject.new;
	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @"obj-v"; }];

	// Removing the class macro should not disturb the object-level macro.
	[MacroableTestObject removeMacro:sel];

	NSString *result = invokeClassMacroNoArgs(obj, sel);
	XCTAssertEqualObjects(result, @"obj-v",
						  @"Object macro should survive removal of the class macro");

	[obj flushObjectMacros];
}

- (void)testObjectMacro_Replacement_UpdatesBlock
{
	MacroableTestObject *obj = MacroableTestObject.new;
	SEL sel = NSSelectorFromString(@"testObjMacroReplace");

	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @"o1"; }];
	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @"o2"; }];

	XCTAssertTrue([obj hasObjectMacro:sel]);
	XCTAssertEqualObjects(invokeClassMacroNoArgs(obj, sel), @"o2");

	[obj flushObjectMacros];
}

- (void)testRemoveObjectMacro_ClassMacroResurfaces
{
	// With both a class macro and an instance override, removing the object macro
	// should fall back to the class macro for that instance.
	SEL sel = NSSelectorFromString(@"testObjRemoveResurface");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @"class-v"; }];

	MacroableTestObject *obj = MacroableTestObject.new;
	[obj objectMacro:sel macroBlock:^NSString*(id _self){ return @"obj-v"; }];
	XCTAssertEqualObjects(invokeClassMacroNoArgs(obj, sel), @"obj-v");

	[obj removeObjectMacro:sel];

	XCTAssertEqualObjects(invokeClassMacroNoArgs(obj, sel), @"class-v",
						  @"Removing the instance override should restore the class macro");
}

// ===========================================================================
#pragma mark - Subclass Inheritance
// ===========================================================================

- (void)testSubclass_DoesNotInheritParentClassMacro
{
	// Class macros are stored on the specific class's associated objects and are
	// NOT automatically inherited by subclasses.
	SEL sel = NSSelectorFromString(@"testSubclassNoInherit");
	[MacroableTestObject macro:sel macroBlock:^NSString*(id _self){ return @"parent"; }];

	__unused MacroableTestObjectSubclass *sub = MacroableTestObjectSubclass.new;

	// The subclass instance should not find the macro registered on the parent.
	XCTAssertFalse([MacroableTestObjectSubclass hasMacro:sel],
				   @"Subclass hasMacro: should not see the parent's class macro");
}

- (void)testSubclass_OwnClassMacro_WorksIndependently
{
	SEL sel = NSSelectorFromString(@"testSubclassOwnMacro");
	[MacroableTestObjectSubclass macro:sel macroBlock:^NSString*(id _self){ return @"sub"; }];

	MacroableTestObjectSubclass *sub = MacroableTestObjectSubclass.new;
	NSString *result = invokeClassMacroNoArgs(sub, sel);
	XCTAssertEqualObjects(result, @"sub");
	XCTAssertFalse([MacroableTestObject hasMacro:sel],
				   @"Macro registered on the subclass must not appear on the parent");
}

@end
