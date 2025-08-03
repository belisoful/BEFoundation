//
//  NSOrderedSet+BExtension.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import <BEFoundation/NSObject+DynamicMethods.h>
#import "NSObject+DynamicMethodsHelpers.h"


// Test helper classes with DynamicSwizzle prefix
@interface DynamicSwizzleTestClass : NSObject
- (NSString *)originalMethod;
- (NSString *)swizzledMethod;
- (NSString *)methodWithDifferentSignature:(NSInteger)param;
- (void)voidMethod;
- (void)voidSwizzledMethod;
+ (NSString *)classMethod;
+ (NSString *)swizzledClassMethod;
@end

@implementation DynamicSwizzleTestClass
- (NSString *)originalMethod { return @"original"; }
- (NSString *)swizzledMethod { return @"swizzled"; }
- (NSString *)methodWithDifferentSignature:(NSInteger)param { return @"different"; }
- (void)voidMethod { }
- (void)voidSwizzledMethod { }
+ (NSString *)classMethod { return @"class_original"; }
+ (NSString *)swizzledClassMethod { return @"class_swizzled"; }
@end

@interface DynamicSwizzleEmptyTestClass : NSObject
// Empty class for testing method addition
@end

@implementation DynamicSwizzleEmptyTestClass
@end

@interface DynamicSwizzleMethodOnlyClass : NSObject
- (NSString *)onlyOriginalMethod;
@end

@implementation DynamicSwizzleMethodOnlyClass
- (NSString *)onlyOriginalMethod { return @"only_original"; }
@end

@interface DynamicSwizzleSignatureMismatchClass : NSObject
- (NSString *)stringMethod;
- (NSInteger)integerMethod;
@end

@implementation DynamicSwizzleSignatureMismatchClass
- (NSString *)stringMethod { return @"string"; }
- (NSInteger)integerMethod { return 42; }
@end





//	BEMethodSignatureHelper

@interface LargeArgumentNSMethodSignature : NSMethodSignature
- (instancetype)initWithObjCTypes:(const char *)types;

@property (readonly, nonnull) NSMethodSignature *innerMethodSignature;

@property (readonly) NSUInteger numberOfArguments;
- (const char *)getArgumentTypeAtIndex:(NSUInteger)idx NS_RETURNS_INNER_POINTER;

@property (readonly) NSUInteger frameLength;

- (BOOL)isOneway;

@property (readonly) const char *methodReturnType NS_RETURNS_INNER_POINTER;
@property (readonly) NSUInteger methodReturnLength;

- (NSUInteger)getArgumentSizeAtIndex:(NSUInteger)idx;

- (void)largeSignatureMethod:(NSNumber*)number;

- (long)_argInfo:(NSUInteger)idx;
@end



@implementation LargeArgumentNSMethodSignature

- (instancetype)initWithObjCTypes:(const char *)types;
{
	_innerMethodSignature = [NSMethodSignature signatureWithObjCTypes:types];
	return self;
}

- (NSUInteger)numberOfArguments
{
	return _innerMethodSignature.numberOfArguments;
}

- (const char *)getArgumentTypeAtIndex:(NSUInteger)idx
{
	return [_innerMethodSignature getArgumentTypeAtIndex:idx];
}

- (NSUInteger)frameLength
{
	return _innerMethodSignature.frameLength;
}

- (BOOL)isOneway
{
	return [_innerMethodSignature isOneway];
}

- (const char *)methodReturnType
{
	return _innerMethodSignature.methodReturnType;
}

- (NSUInteger)methodReturnLength
{
	return _innerMethodSignature.methodReturnLength;
}

- (NSUInteger)getArgumentSizeAtIndex:(NSUInteger)idx
{
	if (idx == 2)
		return 320;
	return [_innerMethodSignature getArgumentSizeAtIndex:idx];
}

- (long)_argInfo:(NSUInteger)idx
{
	return 0;
}

- (void)largeSignatureMethod:(NSNumber*)number
{
	
}
@end


@protocol NSObjectTestDynamicMethod
	@optional

//Todo: structures, arrays and unions
- (double)newMethodTest_100:(char)charValue uchar:(unsigned char)ucharValue
			   shortValue:(short)shortValue ushortValue:(unsigned short)ushortValue
				 intValue:(int)intValue uintValue:(unsigned int)uintValue
				longValue:(long)longValue ulongValue:(unsigned long)ulongValue
				longlongValue:(long)longlongValue ulonglongValue:(unsigned long long)ulonglongValue
				floatValue:(float)floatValue doubleValue:(double)doubleValue
			  stringValue:(char*)stringValue classValue:(Class)classValue
			 voidPtrValue:(void*)voidPtrValue boolValue:(BOOL)boolValue selector:(SEL)selector;
- (void)newMethodTest_140;
- (void)newMethodTest_141;
- (void)newMethodTest_142:(int)intValue dbl:(double)doubleValue object:(id)objectValue;
- (void)newMethodTest_143:(int)intValue dbl:(double)doubleValue object:(id)objectValue;

- (void)newMethodTest_144;
- (void)newMethodTest_145;
- (void)newMethodTest_146:(int)intValue dbl:(double)doubleValue object:(id)objectValue;
- (void)newMethodTest_147:(int)intValue dbl:(double)doubleValue object:(id)objectValue;

- (void)newMethodTest_200:(int)intValue dbl:(double)doubleValue object:(id)objectValue;

- (NSNumber*)newMethodTest_50:(NSNumber*)intValue;
- (NSNumber*)newMethodTest_51:(SEL)selector intValue:(NSNumber*)intValue;
- (NSNumber*)newMethodTest_52:(SEL)selector intValue:(NSNumber*)intValue floatValue:(float)floatValue;
@end






@interface InvokableTestObject : NSObject <NSObjectTestDynamicMethod>
@property (assign) int intValue;
@property (assign) float floatValue;
@end

@implementation InvokableTestObject

- (NSNumber*)newMethodTest_50:(NSNumber*)value
{
	_intValue = value.intValue;
	return @(_intValue * 10);
}
- (NSNumber*)newMethodTest_51:(SEL)selector intValue:(NSNumber*)value
{
	_intValue = value.intValue;
	return @(_intValue * 100);
}
- (NSNumber*)newMethodTest_52:(SEL)selector intValue:(NSNumber*)value floatValue:(float)floatValue
{
	_intValue = value.intValue;
	_floatValue = floatValue;
	return @(_intValue * 1000);
}
@end




@protocol HelperBasicProtocol
@end
@protocol HelperBasicNonProtocol
@end


@interface HelperBasicNonDynamicObject : NSObject <HelperBasicProtocol>
@end
@implementation HelperBasicNonDynamicObject

- (NSInteger)instanceMethod1 {
	return 10;
}
- (NSInteger)instanceMethod2 {
	return 100;
}
- (NSInteger)_instanceMethod3 {
	return 1000;
}


+ (NSInteger)classMethod1 {
	return 11;
}
+ (NSInteger)classMethod2 {
	return 101;
}
+ (NSInteger)_classMethod3 {
	return 1001;
}


+ (NSInteger)classInstanceMethod1 {
	return 12;
}
+ (NSInteger)classInstanceMethod2 {
	return 102;
}
+ (NSInteger)_classInstanceMethod3 {
	return 1002;
}
@end

@interface HelperNonDynamicObject : HelperBasicNonDynamicObject
@end
@implementation HelperNonDynamicObject
@end

@interface SubHelperNonDynamicObject : HelperNonDynamicObject
@end
@implementation SubHelperNonDynamicObject
@end

@interface SubSubHelperNonDynamicObject : SubHelperNonDynamicObject
@end
@implementation SubSubHelperNonDynamicObject
@end

@interface SubSubSubHelperNonDynamicObject : SubSubHelperNonDynamicObject
@end
@implementation SubSubSubHelperNonDynamicObject
@end



#pragma mark Protocols

@protocol ProtocolTestGrandParentProtocol1
@end
@protocol ProtocolTestGrandParentProtocol12
@end
@protocol ProtocolTestGrandParentProtocol2
@end

@protocol ProtocolTestGrandParentProtocol3
@end

@protocol ProtocolTestParentProtocol1 <ProtocolTestGrandParentProtocol1, ProtocolTestGrandParentProtocol12>
@end
@protocol ProtocolTestParentProtocol2 <ProtocolTestGrandParentProtocol2, ProtocolTestGrandParentProtocol12>
@end

@protocol ProtocolTestChildProtocol1 <ProtocolTestParentProtocol1>
@end
@protocol ProtocolTestChildProtocol2 <ProtocolTestParentProtocol2>
@end
@protocol ProtocolTestSumChildProtocol <ProtocolTestParentProtocol1, ProtocolTestParentProtocol2, ProtocolTestGrandParentProtocol1, ProtocolTestGrandParentProtocol12, ProtocolTestGrandParentProtocol2, ProtocolTestGrandParentProtocol3>
@end


@protocol ProtocolTestGrandChildProtocol <ProtocolTestChildProtocol1, ProtocolTestChildProtocol2>
@end
@protocol ProtocolTestSumGrandChildProtocol <ProtocolTestSumChildProtocol>
@end




@interface NSDynamicMethodsHelpersTests : XCTestCase
@property (nonatomic, strong) BEDynamicMethodSwizzleSelectors *swizzler;
@end

#pragma mark - NSObject Dynamic Methods Tests

@implementation NSDynamicMethodsHelpersTests

- (void)setUp {
	[super setUp];
	// Reset any potential swizzling from previous tests
	self.swizzler = nil;
}

- (void)tearDown {
	self.swizzler = nil;
	[super tearDown];
}


- (void)test_recursiveProtocolsFromProtocol
{
	NSOrderedSet *gp1_result = recursiveProtocolsFromProtocol(@protocol(ProtocolTestGrandParentProtocol1));
	NSOrderedSet *reference = [NSOrderedSet orderedSetWithObjects:@protocol(ProtocolTestGrandParentProtocol1), nil];
	XCTAssertEqualObjects(gp1_result.array, reference.array);
	
	NSOrderedSet *gp2_result = recursiveProtocolsFromProtocol(@protocol(ProtocolTestGrandParentProtocol2));
	reference = [NSOrderedSet orderedSetWithObjects:@protocol(ProtocolTestGrandParentProtocol2), nil];
	XCTAssertEqualObjects(gp2_result.array, reference.array);
	
	NSOrderedSet *gp12_result = recursiveProtocolsFromProtocol(@protocol(ProtocolTestGrandParentProtocol12));
	reference = [NSOrderedSet orderedSetWithObjects:@protocol(ProtocolTestGrandParentProtocol12), nil];
	XCTAssertEqualObjects(gp12_result.array, reference.array);
	
	
	
	NSOrderedSet *p1_result = recursiveProtocolsFromProtocol(@protocol(ProtocolTestParentProtocol1));
	reference = [NSOrderedSet orderedSetWithObjects:@protocol(ProtocolTestParentProtocol1), @protocol(ProtocolTestGrandParentProtocol1), @protocol(ProtocolTestGrandParentProtocol12), nil];
	XCTAssertEqualObjects(p1_result, reference);
	
	NSOrderedSet *p2_result = recursiveProtocolsFromProtocol(@protocol(ProtocolTestParentProtocol2));
	reference = [NSOrderedSet orderedSetWithObjects:@protocol(ProtocolTestParentProtocol2), @protocol(ProtocolTestGrandParentProtocol2), @protocol(ProtocolTestGrandParentProtocol12), nil];
	XCTAssertEqualObjects(p2_result, reference);
	
	
	
	NSOrderedSet *c1_result = recursiveProtocolsFromProtocol(@protocol(ProtocolTestChildProtocol1));
	reference = [NSOrderedSet orderedSetWithObjects:@protocol(ProtocolTestChildProtocol1), @protocol(ProtocolTestParentProtocol1), @protocol(ProtocolTestGrandParentProtocol1), @protocol(ProtocolTestGrandParentProtocol12), nil];
	XCTAssertEqualObjects(c1_result, reference);
	
	NSOrderedSet *c2_result = recursiveProtocolsFromProtocol(@protocol(ProtocolTestChildProtocol2));
	reference = [NSOrderedSet orderedSetWithObjects:@protocol(ProtocolTestChildProtocol2), @protocol(ProtocolTestParentProtocol2), @protocol(ProtocolTestGrandParentProtocol2), @protocol(ProtocolTestGrandParentProtocol12), nil];
	XCTAssertEqualObjects(c2_result, reference);
	
	NSOrderedSet *cSum_result = recursiveProtocolsFromProtocol(@protocol(ProtocolTestSumChildProtocol));
	reference = [NSOrderedSet orderedSetWithObjects:@protocol(ProtocolTestSumChildProtocol), @protocol(ProtocolTestParentProtocol1), @protocol(ProtocolTestParentProtocol2), @protocol(ProtocolTestGrandParentProtocol1), @protocol(ProtocolTestGrandParentProtocol12),@protocol(ProtocolTestGrandParentProtocol2),  @protocol(ProtocolTestGrandParentProtocol3), nil];
	XCTAssertEqualObjects(cSum_result, reference);
	
	
	
	NSOrderedSet *gc_result = recursiveProtocolsFromProtocol(@protocol(ProtocolTestGrandChildProtocol));
	reference = [NSOrderedSet orderedSetWithObjects:@protocol(ProtocolTestGrandChildProtocol), @protocol(ProtocolTestChildProtocol1), @protocol(ProtocolTestChildProtocol2), @protocol(ProtocolTestParentProtocol1), @protocol(ProtocolTestParentProtocol2), @protocol(ProtocolTestGrandParentProtocol1), @protocol(ProtocolTestGrandParentProtocol12), @protocol(ProtocolTestGrandParentProtocol2),  nil];
	XCTAssertEqualObjects(gc_result, reference);
	
	NSOrderedSet *gcSum_result = recursiveProtocolsFromProtocol(@protocol(ProtocolTestSumGrandChildProtocol));
	reference = [NSOrderedSet orderedSetWithObjects:@protocol(ProtocolTestSumGrandChildProtocol), @protocol(ProtocolTestSumChildProtocol), @protocol(ProtocolTestParentProtocol1), @protocol(ProtocolTestParentProtocol2), @protocol(ProtocolTestGrandParentProtocol1), @protocol(ProtocolTestGrandParentProtocol12), @protocol(ProtocolTestGrandParentProtocol2), @protocol(ProtocolTestGrandParentProtocol3), nil];
	XCTAssertEqualObjects(gcSum_result, reference);
	
}

#pragma mark - Functional Checks

- (void)test_swizzleMethods_instance_check
{
	
	SEL		instanceMethod1 = @selector(instanceMethod1);
	SEL		instanceMethod2 = @selector(instanceMethod2);
	
	Class superCls = HelperBasicNonDynamicObject.class;
	Class cls = HelperNonDynamicObject.class;
	Class subCls = SubHelperNonDynamicObject.class;
	
	HelperBasicNonDynamicObject	*superObject = HelperBasicNonDynamicObject.new;
	HelperNonDynamicObject		*object = HelperNonDynamicObject.new;
	SubHelperNonDynamicObject	*subObject = SubHelperNonDynamicObject.new;
	
	XCTAssertEqual([superObject instanceMethod1], 10);
	XCTAssertEqual([object instanceMethod1], 10);
	XCTAssertEqual([subObject instanceMethod1], 10);
	
	XCTAssertEqual([superObject instanceMethod2], 100);
	XCTAssertEqual([object instanceMethod2], 100);
	XCTAssertEqual([subObject instanceMethod2], 100);
	
	
	BEDynamicMethodSwizzleSelectors *instanceSwizzler = [BEDynamicMethodSwizzleSelectors swizzleOriginal:instanceMethod1 withSelector:instanceMethod2];
	
	// Swizzle Superclass
	[instanceSwizzler swizzleMethodsOnClass:superCls];
	
	XCTAssertEqual([superObject instanceMethod1], 100);
	XCTAssertEqual([object instanceMethod1], 100);
	XCTAssertEqual([subObject instanceMethod1], 100);
	
	XCTAssertEqual([superObject instanceMethod2], 10);
	XCTAssertEqual([object instanceMethod2], 10);
	XCTAssertEqual([subObject instanceMethod2], 10);
	
	//Swizzle main class back.
	[instanceSwizzler swizzleMethodsOnClass:cls];
	
	XCTAssertEqual([superObject instanceMethod1], 100);
	XCTAssertEqual([object instanceMethod1], 10);
	XCTAssertEqual([subObject instanceMethod1], 10);
	
	XCTAssertEqual([superObject instanceMethod2], 10);
	XCTAssertEqual([object instanceMethod2], 100);
	XCTAssertEqual([subObject instanceMethod2], 100);
	
	
	[instanceSwizzler swizzleMethodsOnClass:superCls];
	
	XCTAssertEqual([superObject instanceMethod1], 10);
	XCTAssertEqual([object instanceMethod1], 10);
	XCTAssertEqual([subObject instanceMethod1], 10);
	
	XCTAssertEqual([superObject instanceMethod2], 100);
	XCTAssertEqual([object instanceMethod2], 100);
	XCTAssertEqual([subObject instanceMethod2], 100);
}


- (void)test_swizzleMethods_class_chack
{
	SEL		classMethod1 = @selector(classMethod1);
	SEL		classMethod2 = @selector(classMethod2);
	
	Class superCls = HelperBasicNonDynamicObject.class;
	Class cls = HelperNonDynamicObject.class;
	Class subCls = SubHelperNonDynamicObject.class;
	
	HelperBasicNonDynamicObject	*superObject = HelperBasicNonDynamicObject.new;
	HelperNonDynamicObject		*object = HelperNonDynamicObject.new;
	SubHelperNonDynamicObject	*subObject = SubHelperNonDynamicObject.new;
	
	
	XCTAssertEqual([superObject.class classMethod1], 11);
	XCTAssertEqual([object.class classMethod1], 11);
	XCTAssertEqual([subObject.class classMethod1], 11);
	
	XCTAssertEqual([superObject.class classMethod2], 101);
	XCTAssertEqual([object.class classMethod2], 101);
	XCTAssertEqual([subObject.class classMethod2], 101);
	
	
	//	class_getInstanceMethod		method_getImplementation
	BEDynamicMethodSwizzleSelectors *classSwizzler = [BEDynamicMethodSwizzleSelectors swizzleMetaOriginal:classMethod1 withSelector:classMethod2];
	
	
	[classSwizzler swizzleMethodsOnClass:superCls];
	
	XCTAssertEqual([superObject.class classMethod1], 101);
	XCTAssertEqual([object.class classMethod1], 101);
	XCTAssertEqual([subObject.class classMethod1], 101);
	
	XCTAssertEqual([superObject.class classMethod2], 11);
	XCTAssertEqual([object.class classMethod2], 11);
	XCTAssertEqual([subObject.class classMethod2], 11);
}


#pragma mark Factory Method Tests

- (void)testSwizzleOriginalWithSelector {
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(originalMethod)
															   withSelector:@selector(swizzledMethod)];
	
	XCTAssertNotNil(swizzle, @"Factory method should return non-null instance");
	XCTAssertFalse(swizzle.isMetaClass, @"Instance method swizzle should not be meta class");
	XCTAssertEqual(swizzle.originalSelector, @selector(originalMethod), @"Original selector should match");
	XCTAssertEqual(swizzle.swizzleSelector, @selector(swizzledMethod), @"Swizzled selector should match");
}

- (void)testSwizzleMetaOriginalWithSelector {
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleMetaOriginal:@selector(classMethod)
																   withSelector:@selector(swizzledClassMethod)];
	
	XCTAssertNotNil(swizzle, @"Factory method should return non-null instance");
	XCTAssertTrue(swizzle.isMetaClass, @"Meta class method swizzle should be meta class");
	XCTAssertEqual(swizzle.originalSelector, @selector(classMethod), @"Original selector should match");
	XCTAssertEqual(swizzle.swizzleSelector, @selector(swizzledClassMethod), @"Swizzled selector should match");
}

- (void)testFactoryMethodsWithNilSelectors {
	SEL nilSelector = nil;
	BEDynamicMethodSwizzleSelectors *swizzle1 = [BEDynamicMethodSwizzleSelectors swizzleOriginal:nilSelector
																withSelector:@selector(swizzledMethod)];
	XCTAssertNotNil(swizzle1, @"Should create instance even with nil original selector");
	XCTAssertEqual(swizzle1.originalSelector, nil, @"Original selector should be nil");
	
	BEDynamicMethodSwizzleSelectors *swizzle2 = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(originalMethod)
																withSelector:nilSelector];
	XCTAssertNotNil(swizzle2, @"Should create instance even with nil swizzled selector");
	XCTAssertEqual(swizzle2.swizzleSelector, nil, @"Swizzled selector should be nil");
}

#pragma mark Initializer Tests

- (void)testInitWithOriginal_InstanceMethod_Success {
	BEDynamicMethodSwizzleSelectors *swizzle = [[BEDynamicMethodSwizzleSelectors alloc] initWithOriginal:@selector(originalMethod)
																	 swizzleSelector:@selector(swizzledMethod)
																		 isMetaClass:NO];
	
	XCTAssertNotNil(swizzle, @"Initializer should return non-null instance");
	XCTAssertFalse(swizzle.isMetaClass, @"isMetaClass should be NO");
	XCTAssertEqual(swizzle.originalSelector, @selector(originalMethod), @"Original selector should match");
	XCTAssertEqual(swizzle.swizzleSelector, @selector(swizzledMethod), @"Swizzled selector should match");
}

- (void)testInitWithOriginal_MetaClassMethod_Success {
	BEDynamicMethodSwizzleSelectors *swizzle = [[BEDynamicMethodSwizzleSelectors alloc] initWithOriginal:@selector(classMethod)
																	 swizzleSelector:@selector(swizzledClassMethod)
																		 isMetaClass:YES];
	
	XCTAssertNotNil(swizzle, @"Initializer should return non-null instance");
	XCTAssertTrue(swizzle.isMetaClass, @"isMetaClass should be YES");
	XCTAssertEqual(swizzle.originalSelector, @selector(classMethod), @"Original selector should match");
	XCTAssertEqual(swizzle.swizzleSelector, @selector(swizzledClassMethod), @"Swizzled selector should match");
}

- (void)testInitWithOriginal_NilSelectors {
	SEL nilSelector = nil;
	BEDynamicMethodSwizzleSelectors *swizzle = [[BEDynamicMethodSwizzleSelectors alloc] initWithOriginal:nilSelector
																	 swizzleSelector:nilSelector
																		 isMetaClass:NO];
	
	XCTAssertNotNil(swizzle, @"Should initialize even with nil selectors");
	XCTAssertFalse(swizzle.isMetaClass, @"isMetaClass should be NO");
	XCTAssertEqual(swizzle.originalSelector, nil, @"Original selector should be nil");
	XCTAssertEqual(swizzle.swizzleSelector, nil, @"Swizzled selector should be nil");
}

#pragma mark SwizzleMethodsOnClass Tests - Success Cases

- (void)testSwizzleMethodsOnClass_InstanceMethod_Success {
	DynamicSwizzleTestClass *testObj = [[DynamicSwizzleTestClass alloc] init];
	NSString *beforeSwizzle = [testObj originalMethod];
	XCTAssertEqualObjects(beforeSwizzle, @"original", @"Original method should return 'original'");
	
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(originalMethod)
															   withSelector:@selector(swizzledMethod)];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 1, @"Should return 1 for successful method exchange");
	
	// Verify swizzle worked
	NSString *afterSwizzle = [testObj originalMethod];
	XCTAssertEqualObjects(afterSwizzle, @"swizzled", @"Original method should now return 'swizzled'");
	
	// Verify reverse swizzle
	NSString *swizzledCall = [testObj swizzledMethod];
	XCTAssertEqualObjects(swizzledCall, @"original", @"Swizzled method should now return 'original'");
	
	// Restore original state
	XCTAssertEqual([swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]], 1);
}

- (void)testSwizzleMethodsOnClass_ClassMethod_Success {
	NSString *beforeSwizzle = [DynamicSwizzleTestClass classMethod];
	XCTAssertEqualObjects(beforeSwizzle, @"class_original", @"Class method should return 'class_original'");
	
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleMetaOriginal:@selector(classMethod)
																   withSelector:@selector(swizzledClassMethod)];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 1, @"Should return 1 for successful method exchange");
	
	// Verify swizzle worked
	NSString *afterSwizzle = [DynamicSwizzleTestClass classMethod];
	XCTAssertEqualObjects(afterSwizzle, @"class_swizzled", @"Class method should now return 'class_swizzled'");
	
	// Restore original state
	XCTAssertEqual([swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]], 1);
}

- (void)testSwizzleMethodsOnClass_VoidMethods_Success {
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(voidMethod)
															   withSelector:@selector(voidSwizzledMethod)];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 1, @"Should return 1 for successful void method exchange");
	
	// Restore original state
	XCTAssertEqual([swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]], 1);
}
- (void)testSwizzleMethodsOnClass_MethodAddition_Success {
   // Add a method from DynamicSwizzleTestClass to DynamicSwizzleEmptyTestClass
   BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(nonExistentMethod)
															withSelector:@selector(swizzledMethod)];
   
   // First add the swizzled method to the empty class
   Method sourceMethod = class_getInstanceMethod([DynamicSwizzleTestClass class], @selector(swizzledMethod));
   XCTAssertNotEqual(sourceMethod, NULL, @"Source method should exist");
   
   BOOL added = class_addMethod([DynamicSwizzleEmptyTestClass class],
							   @selector(swizzledMethod),
							   method_getImplementation(sourceMethod),
							   method_getTypeEncoding(sourceMethod));
   XCTAssertTrue(added, @"Should be able to add method to empty class");
   
   // Also add the nonExistentMethod to the empty class so it can be found for swizzling
   BOOL addedNonExistent = class_addMethod([DynamicSwizzleEmptyTestClass class],
										  @selector(nonExistentMethod),
										  method_getImplementation(sourceMethod),
										  method_getTypeEncoding(sourceMethod));
   XCTAssertTrue(addedNonExistent, @"Should be able to add nonExistentMethod to empty class");
   
   int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleEmptyTestClass class]];
   XCTAssertEqual(result, 1, @"Should return -1 for method addition");
   
   // Verify the method was added
   DynamicSwizzleEmptyTestClass *emptyObj = [[DynamicSwizzleEmptyTestClass alloc] init];
   XCTAssertTrue([emptyObj respondsToSelector:@selector(nonExistentMethod)], @"Should respond to added method");
   
   XCTAssertEqual([swizzle swizzleMethodsOnClass:[DynamicSwizzleEmptyTestClass class]], 1);
}

#pragma mark SwizzleMethodsOnClass Tests - Failure Cases

- (void)testSwizzleMethodsOnClass_NilClass_ReturnsZero {
	Class nilClass = nil;
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(originalMethod)
															   withSelector:@selector(swizzledMethod)];
	
	int result = [swizzle swizzleMethodsOnClass:nilClass];
	XCTAssertEqual(result, 0, @"Should return 0 for nil class");
}

- (void)testSwizzleMethodsOnClass_OriginalMethodNotFound_ReturnsZero {
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:NSSelectorFromString(@"nonExistentOriginalMethod")
															   withSelector:@selector(swizzledMethod)];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 0, @"Should return 0 when original method not found");
}

- (void)testSwizzleMethodsOnClass_SwizzledMethodNotFound_ReturnsZero {
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(originalMethod)
															   withSelector:NSSelectorFromString(@"nonExistentSwizzledMethod")];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 0, @"Should return 0 when swizzled method not found");
}

- (void)testSwizzleMethodsOnClass_BothMethodsNotFound_ReturnsZero {
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:NSSelectorFromString(@"nonExistentOriginalMethod")
															   withSelector:NSSelectorFromString(@"nonExistentSwizzledMethod")];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 0, @"Should return 0 when both methods not found");
}

- (void)testSwizzleMethodsOnClass_SignatureMismatch_ReturnsZero {
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(stringMethod)
															   withSelector:@selector(integerMethod)];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleSignatureMismatchClass class]];
	XCTAssertEqual(result, 0, @"Should return 0 for signature mismatch");
}

- (void)testSwizzleMethodsOnClass_DifferentParameterCount_ReturnsZero {
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(originalMethod)
															   withSelector:@selector(methodWithDifferentSignature:)];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 0, @"Should return 0 for different parameter count");
}

#pragma mark Edge Cases and Complex Scenarios

- (void)testSwizzleMethodsOnClass_NilSelectors {
	SEL nilSelector = nil;
	BEDynamicMethodSwizzleSelectors *swizzle = [[BEDynamicMethodSwizzleSelectors alloc] initWithOriginal:nilSelector
																	 swizzleSelector:@selector(swizzledMethod)
																		 isMetaClass:NO];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 0, @"Should return 0 when original selector is nil");
	
	swizzle = [[BEDynamicMethodSwizzleSelectors alloc] initWithOriginal:@selector(originalMethod)
											  swizzleSelector:nilSelector
												  isMetaClass:NO];
	
	result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 0, @"Should return 0 when swizzled selector is nil");
}

- (void)testSwizzleMethodsOnClass_MetaClassTargeting {
	// Test that isMetaClass:YES correctly targets the meta class
	BEDynamicMethodSwizzleSelectors *swizzle = [[BEDynamicMethodSwizzleSelectors alloc] initWithOriginal:@selector(classMethod)
																	 swizzleSelector:@selector(swizzledClassMethod)
																		 isMetaClass:YES];
	
	// This should work because we're targeting the meta class
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 1, @"Should successfully swizzle meta class methods");
	
	// Restore
	XCTAssertEqual([swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]], 1);
}

- (void)testSwizzleMethodsOnClass_MetaClassWithInstanceMethod_ReturnsZero {
	// Test trying to swizzle instance methods on meta class (should fail)
	BEDynamicMethodSwizzleSelectors *swizzle = [[BEDynamicMethodSwizzleSelectors alloc] initWithOriginal:@selector(originalMethod)
																	 swizzleSelector:@selector(swizzledMethod)
																		 isMetaClass:YES];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 0, @"Should return 0 when trying to swizzle instance methods on meta class");
}

- (void)testSwizzleMethodsOnClass_InstanceMethodAsClassMethod_ReturnsZero {
	// Test trying to swizzle class methods as instance methods (should fail)
	BEDynamicMethodSwizzleSelectors *swizzle = [[BEDynamicMethodSwizzleSelectors alloc] initWithOriginal:@selector(classMethod)
																	 swizzleSelector:@selector(swizzledClassMethod)
																		 isMetaClass:NO];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 0, @"Should return 0 when trying to swizzle class methods as instance methods");
}

- (void)testSwizzleMethodsOnClass_SameSelector_Success {
	// Test swizzling a method with itself (should work but be no-op)
	BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(originalMethod)
															   withSelector:@selector(originalMethod)];
	
	int result = [swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result, 1, @"Should return 1 even when swizzling method with itself");
	
	// Verify functionality is unchanged
	DynamicSwizzleTestClass *testObj = [[DynamicSwizzleTestClass alloc] init];
	NSString *resultString = [testObj originalMethod];
	XCTAssertEqualObjects(resultString, @"original", @"Method should still return original value");
}

- (void)testSwizzleMethodsOnClass_MultipleSwizzles {
	// Test multiple swizzles on the same class
	DynamicSwizzleTestClass *testObj = [[DynamicSwizzleTestClass alloc] init];
	
	// First swizzle
	BEDynamicMethodSwizzleSelectors *swizzle1 = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(originalMethod)
																withSelector:@selector(swizzledMethod)];
	int result1 = [swizzle1 swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result1, 1, @"First swizzle should succeed");
	
	NSString *afterFirst = [testObj originalMethod];
	XCTAssertEqualObjects(afterFirst, @"swizzled", @"First swizzle should be effective");
	
	// Second swizzle (restore)
	int result2 = [swizzle1 swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	XCTAssertEqual(result2, 1, @"Second swizzle should succeed");
	
	NSString *afterSecond = [testObj originalMethod];
	XCTAssertEqualObjects(afterSecond, @"original", @"Second swizzle should restore original");
}

#pragma mark Property Tests

- (void)testSynthesizedProperties {
	BEDynamicMethodSwizzleSelectors *swizzle = [[BEDynamicMethodSwizzleSelectors alloc] initWithOriginal:@selector(testMethod)
																	 swizzleSelector:@selector(swizzledTestMethod)
																		 isMetaClass:YES];
	
	// Test that properties are correctly synthesized and accessible
	XCTAssertTrue(swizzle.isMetaClass, @"isMetaClass property should be accessible");
	XCTAssertEqual(swizzle.originalSelector, @selector(testMethod), @"originalSelector property should be accessible");
	XCTAssertEqual(swizzle.swizzleSelector, @selector(swizzledTestMethod), @"swizzleSelector property should be accessible");
	
	// Test property mutability (if setters exist)
	XCTAssertFalse([swizzle respondsToSelector:@selector(setIsMetaClass:)], @"Should nothave isMetaClass setter");
	XCTAssertFalse([swizzle respondsToSelector:@selector(setOriginalSelector:)], @"Should have originalSelector setter");
	XCTAssertFalse([swizzle respondsToSelector:@selector(setswizzleSelector:)], @"Should have swizzleSelector setter");
}

#pragma mark Memory Management Tests

- (void)testMemoryManagement {
	// Test that objects are properly allocated and can be deallocated
	@autoreleasepool {
		BEDynamicMethodSwizzleSelectors *swizzle = [BEDynamicMethodSwizzleSelectors swizzleOriginal:@selector(originalMethod)
																   withSelector:@selector(swizzledMethod)];
		XCTAssertNotNil(swizzle, @"Should create valid instance");
		
		// Use the object
		[swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
		
		// Object should be deallocated when leaving this scope
		[swizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	}
	
	// Test factory method memory management
	@autoreleasepool {
		BEDynamicMethodSwizzleSelectors *metaSwizzle = [BEDynamicMethodSwizzleSelectors swizzleMetaOriginal:@selector(classMethod)
																		  withSelector:@selector(swizzledClassMethod)];
		XCTAssertNotNil(metaSwizzle, @"Should create valid meta instance");
		
		// Use the object
		[metaSwizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
		
		// Object should be deallocated when leaving this scope
		[metaSwizzle swizzleMethodsOnClass:[DynamicSwizzleTestClass class]];
	}
}


#pragma mark - Class swizzle method status


- (void)testSwizzleKey {
	XCTAssertEqual([BEDynamicMethodSwizzleSelectors swizzleKey], [BEDynamicMethodSwizzleSelectors swizzleKey], @"Swizzle Key should be invariant.");
	XCTAssertTrue([BEDynamicMethodSwizzleSelectors swizzleKey] != nil,  @"Swizzle Key should be nonzero.");
}


- (void)testStatusClassHasSwizzle {
	Class cls = self.class;
	
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:cls], @"By Default, has no swizzle.");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleNone];
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:cls], @"No swizzle is left unset");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleOn];
	XCTAssertTrue([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:cls], @"ON swizzle is set");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleNone];
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:cls], @"reset swizzle is unset");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleOff];
	XCTAssertTrue([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:cls], @"OFF swizzle is set");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleNone];
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:cls], @"reset swizzle is unset");
}


- (void)testStatusClassIsSwizzle {
	Class cls = self.class;
	
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:cls], @"By Default, should be no swizzle.");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleNone];
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:cls], @"No swizzle should be no swizzle");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleOn];
	XCTAssertTrue([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:cls], @"ON swizzle should be Swizzled");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleNone];
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:cls], @"reset swizzle should be no swizzle");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleOff];
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:cls], @"OFF swizzle should be no swizzle");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleNone];
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:cls], @"reset swizzle should be no swizzle");
}


- (void)testStatusClassSwizzled {
	Class cls = self.class;
	
	XCTAssertEqual([BEDynamicMethodSwizzleSelectors statusClassSwizzled:cls], DMSwizzleNone, @"By Default, should be DMSwizzleNone.");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleNone];
	XCTAssertEqual([BEDynamicMethodSwizzleSelectors statusClassSwizzled:cls], DMSwizzleNone, @"No swizzle should be DMSwizzleNone");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleOn];
	XCTAssertEqual([BEDynamicMethodSwizzleSelectors statusClassSwizzled:cls], DMSwizzleOn, @"ON swizzle should DMSwizzleOn");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleNone];
	XCTAssertEqual([BEDynamicMethodSwizzleSelectors statusClassSwizzled:cls], DMSwizzleNone, @"reset swizzle should be DMSwizzleNone");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleOff];
	XCTAssertEqual([BEDynamicMethodSwizzleSelectors statusClassSwizzled:cls], DMSwizzleOff, @"OFF swizzle should be DMSwizzleOff");
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleNone];
	XCTAssertEqual([BEDynamicMethodSwizzleSelectors statusClassSwizzled:cls], DMSwizzleNone, @"reset swizzle should be DMSwizzleNone");
}




- (void)testSetClassSwizzle_NSObject {
	Class cls = NSObject.class;
	
	[BEDynamicMethodSwizzleSelectors setClass:cls swizzle:DMSwizzleOn];
	
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:cls]);
}




- (void)testStatusParentIsSwizzled {
	
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:HelperBasicNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:HelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:SubHelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:SubSubHelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:SubSubSubHelperNonDynamicObject.class]);
	
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:HelperBasicNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:HelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:SubHelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:SubSubHelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:SubSubSubHelperNonDynamicObject.class]);
	
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusParentsAreSwizzled:HelperBasicNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusParentsAreSwizzled:HelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusParentsAreSwizzled:SubHelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusParentsAreSwizzled:SubSubHelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusParentsAreSwizzled:SubSubSubHelperNonDynamicObject.class]);
	
	
	[BEDynamicMethodSwizzleSelectors setClass:SubHelperNonDynamicObject.class swizzle:YES];
	
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:HelperBasicNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:HelperNonDynamicObject.class]);
	XCTAssertTrue([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:SubHelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:SubSubHelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassHasSwizzle:SubSubSubHelperNonDynamicObject.class]);
	
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:HelperBasicNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:HelperNonDynamicObject.class]);
	XCTAssertTrue([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:SubHelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:SubSubHelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusClassIsSwizzled:SubSubSubHelperNonDynamicObject.class]);
	
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusParentsAreSwizzled:HelperBasicNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusParentsAreSwizzled:HelperNonDynamicObject.class]);
	XCTAssertFalse([BEDynamicMethodSwizzleSelectors statusParentsAreSwizzled:SubHelperNonDynamicObject.class]);
	XCTAssertTrue([BEDynamicMethodSwizzleSelectors statusParentsAreSwizzled:SubSubHelperNonDynamicObject.class]);
	XCTAssertTrue([BEDynamicMethodSwizzleSelectors statusParentsAreSwizzled:SubSubSubHelperNonDynamicObject.class]);
	
}





#pragma mark - BEMethodSignatureHelper (DynamicMethods)

- (void)testBEMethodSignatureHelper_invocableMethodSignatureFromBlock_NoCmdArgument_Minimal
{
	id aBlock = ^int(id self) {
		return YES;
	};
	
	NSMethodSignature *signature = [BEMethodSignatureHelper invocableMethodSignatureFromBlock:aBlock];
	XCTAssertNotNil(signature);
	
	XCTAssertEqualObjects(signature.methodReturnTypeString, @"i");
	XCTAssertEqual([signature methodReturnLength], 4);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 2);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @":");
}

- (void)testBEMethodSignatureHelper_invocableMethodSignatureFromBlock_CmdArgument_Minimal
{
	id aBlock = ^int(id self, SEL _cmd) {
		return YES;
	};
	
	NSMethodSignature *signature = [BEMethodSignatureHelper invocableMethodSignatureFromBlock:aBlock];
	XCTAssertNotNil(signature);
	
	XCTAssertEqualObjects(signature.methodReturnTypeString, @"i");
	XCTAssertEqual([signature methodReturnLength], 4);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 3);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @":");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:2], @":");
}

- (void)testBEMethodSignatureHelper_invocableMethodSignatureFromBlock_NoCmdArgument
{
	id aBlock = ^int(id self, NSNumber* aNumber, int intValue, double dblValue) {
		return YES;
	};
	
	NSMethodSignature *signature = [BEMethodSignatureHelper invocableMethodSignatureFromBlock:aBlock];
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

- (void)testBEMethodSignatureHelper_invocableMethodSignatureFromBlock_CmdArgument
{
	id aBlock = ^int(id self, SEL _cmd, NSNumber* aNumber, int intValue, double dblValue) {
		return YES;
	};
	
	NSMethodSignature *signature = [BEMethodSignatureHelper invocableMethodSignatureFromBlock:aBlock];
	XCTAssertNotNil(signature);
	
	XCTAssertEqualObjects(signature.methodReturnTypeString, @"i");
	XCTAssertEqual([signature methodReturnLength], 4);
	XCTAssertEqual([signature frameLength], 224);
	
	XCTAssertEqual(signature.numberOfArguments, 6);
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:1], @":");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:2], @":");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:3], @"@\"NSNumber\"");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:4], @"i");
	XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:5], @"d");
}

- (void)testBEMethodSignatureHelper_invocableMethodSignatureFromBlock_struct
{
	struct myPoint {
		float x, y, z, w;
	};
	
	
	//array, structures, and without SEL __cmd
	id aBlock = ^int(id self, NSNumber __strong *pt[4], struct myPoint structValue, struct myPoint *structPtrValue, long double ld) {
		return YES;
	};
	NSMethodSignature *signature = [BEMethodSignatureHelper invocableMethodSignatureFromBlock:aBlock];
	
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

- (void)testBEMethodSignatureHelper_invocableMethodSignatureFromBlock_BadArgument
{
	id nilBlock = nil;
	
	XCTAssertThrowsSpecificNamed([BEMethodSignatureHelper invocableMethodSignatureFromBlock:nilBlock], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([BEMethodSignatureHelper invocableMethodSignatureFromBlock:(id)NSObject.new], NSException, NSInvalidArgumentException);
	
	Block_literal blockLiteralNoSignature = {
		.isa = &_NSConcreteGlobalBlock,
		.flags = BLOCK_IS_GLOBAL,  // BLOCK_HAS_SIGNATURE is intentionally omitted
		.reserved = 0,
		.invoke = 0,
		.descriptor = 0};
	XCTAssertNil([BEMethodSignatureHelper invocableMethodSignatureFromBlock:(__bridge id)&blockLiteralNoSignature]);
	
	
	Block_descriptor descr = {
		.signature = "v"
	};
	
	Block_literal blockLiteral = {
		.isa = &_NSConcreteGlobalBlock,
		.flags = BLOCK_IS_GLOBAL | BLOCK_HAS_SIGNATURE,  // BLOCK_HAS_SIGNATURE is intentionally omitted
		.reserved = 0,
		.invoke = 0,
		.descriptor = &descr};
	XCTAssertNil([BEMethodSignatureHelper invocableMethodSignatureFromBlock:(__bridge id)&blockLiteral]);
}

- (void)testBEMethodSignatureHelper_mutateInvocation
{
	BEDynamicMethodMeta *metaWithSelf = [BEDynamicMethodMeta.alloc initWithSelector:@selector(init) block:^void(id _self) {} ];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:metaWithSelf.methodSignature];
	XCTAssertNotNil([BEMethodSignatureHelper mutateInvocation:invocation withMeta:metaWithSelf]);
	
	BEDynamicMethodMeta *metaWithSelfCmd = [BEDynamicMethodMeta.alloc initWithSelector:@selector(init) block:^void(id _self, SEL __cmd) {} ];
	invocation = [NSInvocation invocationWithMethodSignature:metaWithSelfCmd.methodSignature];
	XCTAssertNotNil([BEMethodSignatureHelper mutateInvocation:invocation withMeta:metaWithSelfCmd]);
}


- (void)testBEMethodSignatureHelper_mutateInvocation_bigArgumentSize
{
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[LargeArgumentNSMethodSignature.alloc initWithObjCTypes:"v24@0:8@16"]];
	BEDynamicMethodMeta *meta = [BEDynamicMethodMeta.alloc initWithSelector:@selector(init) block:^void(id self, id number) {}];
	XCTAssertNotNil([BEMethodSignatureHelper mutateInvocation:invocation withMeta:meta]);
}

- (void)testBEMethodSignatureHelper_mutateInvocation_BadArguments
{
	NSInvocation *nilInvocation = nil;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(init)]];
	BEDynamicMethodMeta *nilMeta = nil;
	BEDynamicMethodMeta *nonMeta = (BEDynamicMethodMeta*)NSObject.new;
	BEDynamicMethodMeta *blankMeta = BEDynamicMethodMeta.new;
	BEDynamicMethodMeta *meta = [BEDynamicMethodMeta.alloc initWithSelector:@selector(init) block:^void(id _self) {} ];
	
	XCTAssertNil([BEMethodSignatureHelper mutateInvocation:nilInvocation withMeta:meta]);
	XCTAssertNil([BEMethodSignatureHelper mutateInvocation:(NSInvocation*)NSObject.new withMeta:meta]);
	XCTAssertNil([BEMethodSignatureHelper mutateInvocation:invocation withMeta:nilMeta]);
	XCTAssertNil([BEMethodSignatureHelper mutateInvocation:invocation withMeta:nonMeta]);
	XCTAssertNil([BEMethodSignatureHelper mutateInvocation:invocation withMeta:blankMeta]);
	
	NSMethodSignature *signature = [InvokableTestObject instanceMethodSignatureForSelector:@selector(newMethodTest_52:intValue:floatValue:)];
	XCTAssertNotNil(signature);
	invocation = [NSInvocation invocationWithMethodSignature:signature];
	meta = [BEDynamicMethodMeta.alloc initWithSelector:@selector(newMethodTest_52:intValue:floatValue:) block:^void(id self, id number) {}];
	XCTAssertNil([BEMethodSignatureHelper mutateInvocation:invocation withMeta:meta]);
}

#pragma mark - Functionality Test

- (void)testInvocableChecks_W_WO_SelectorArgument
{
	InvokableTestObject *object = InvokableTestObject.new;
	NSNumber *numberArgument = @101010101;
	
	SEL methodSelector = @selector(newMethodTest_50:);
	
	NSMethodSignature *methodSignature = [object methodSignatureForSelector:methodSelector];
	XCTAssertNotNil(methodSignature);
	
	NSInvocation *invokable = [NSInvocation invocationWithMethodSignature:methodSignature];
	[invokable setTarget:object];
	[invokable setSelector:methodSelector];
	[invokable setArgument:&numberArgument atIndex:2];
	
	XCTAssertEqual(object.intValue, 0);
	
	// INVOKE
	[invokable invoke];
	
	NSNumber *returnValue = nil;
	[invokable getReturnValue:&returnValue];
	
	XCTAssertEqualObjects(returnValue, @(numberArgument.intValue * 10));
	XCTAssertEqual(object.intValue, 101010101);
	
	
	
	numberArgument = @11;
	[invokable setArgument:&numberArgument atIndex:2];
	
	id block = ^NSNumber*(id __self, NSNumber* number) {
		return @(number.intValue * -2);
	};
	
	IMP blockImplementation = imp_implementationWithBlock(block);
	
	//	INVOKE Block Implementation
	[invokable invokeUsingIMP:blockImplementation];
	imp_removeBlock(blockImplementation);
	
	[invokable getReturnValue:&returnValue];
	XCTAssertEqualObjects(returnValue, @(numberArgument.intValue * -2));
	
	
	//NSInvokable block with command
	NSMethodSignature *cmdBlockSignature = [NSMethodSignature signatureWithObjCTypes:"@32@0:8:16@24"];
	numberArgument = @6;
	NSInvocation *invokableCmd = [NSInvocation invocationWithMethodSignature:cmdBlockSignature];
	[invokableCmd setTarget:object];
	[invokableCmd setSelector:methodSelector];
	[invokableCmd setArgument:&methodSelector atIndex:2];
	[invokableCmd setArgument:&numberArgument atIndex:3];
	
	
	
	block = ^NSNumber*(id __self, SEL __cmd, NSNumber* number) {
		return @(number.intValue * -3);
	};
	
	blockImplementation = imp_implementationWithBlock(block);
	[invokableCmd invokeUsingIMP:blockImplementation];
	imp_removeBlock(blockImplementation);
	
	[invokableCmd getReturnValue:&returnValue];
	XCTAssertEqualObjects(returnValue, @(numberArgument.intValue * -3));
}

@end

/*
 
 
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
 
 // performSelector
 
 #pragma clang diagnostic pop
 
 */
