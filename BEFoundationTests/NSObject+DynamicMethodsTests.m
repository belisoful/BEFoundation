//
//  NSObject+DynamicMethodsTest.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import <BEFoundation/NSObject+DynamicMethods.h>
#import <simd/simd.h>
#import <arm_neon.h>






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
@end


@protocol NewDynamicObjectProtocol
@optional
- (void)optionalMethod;
- (void)argumentsRetainedMethod:(id)argObject;
@end
/*
@interface NewDynamicObject : NSDynamicObject <NewDynamicObjectProtocol, NSCopying>

- (id)copyWithZone:(nullable NSZone *)zone;

@end

@implementation NewDynamicObject
- (id)copyWithZone:(nullable NSZone *)zone{
	return [[self.class allocWithZone:zone] init];
}

@end
*/
@interface NewDynamicObject : NSDynamicObject <NewDynamicObjectProtocol>
- (void)checkInvocation:(id)obj;
@end

@implementation NewDynamicObject
- (void)checkInvocation:(id)obj{
	
}
@end



@interface BasicDynamicObject : NSObject
+(void)load;
@end
@implementation BasicDynamicObject
+(void)load
{
	[self enableDynamicMethods];
}
@end

@interface SubBasicDynamicObject : BasicDynamicObject
@end
@implementation SubBasicDynamicObject
@end


@protocol NonDynamicObjectProcotol
@optional
- (NSInteger)objectProperty;
- (NSInteger)instanceProperty;
+ (NSInteger)classProperty;

- (NSInteger)instanceMethod3;
+ (NSInteger)classMethod3;
+ (NSInteger)classInstanceMethod3;
@end



@interface BasicNonDynamicObject : NSObject <NonDynamicObjectProcotol>
@property (class, nonatomic, assign) NSUInteger calledEnabled;
@property (class, nonatomic, assign) NSUInteger calledDisabled;
+ (void)reset;
+ (BOOL)enableDynamicMethods;
+ (BOOL)disableDynamicMethods;
@end
@implementation BasicNonDynamicObject
+ (NSUInteger)calledEnabled
{
	return ((NSNumber*)objc_getAssociatedObject(self, @selector(calledEnabled))).integerValue;
}
+ (void)setCalledEnabled:(NSUInteger)value
{
	objc_setAssociatedObject(self, @selector(calledEnabled), @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSUInteger)calledDisabled
{
	return ((NSNumber*)objc_getAssociatedObject(self, @selector(calledDisabled))).integerValue;
}
+ (void)setCalledDisabled:(NSUInteger)value
{
	objc_setAssociatedObject(self, @selector(calledDisabled), @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
+ (void)reset
{
	[self resetDynamicMethods];
	self.calledEnabled = 0;
	self.calledDisabled = 0;
}
+ (BOOL)enableDynamicMethods
{
	self.calledEnabled++;
	return [super enableDynamicMethods];
}
+ (BOOL)disableDynamicMethods
{
	self.calledDisabled++;
	return [super disableDynamicMethods];
}


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


@interface SubBasicNonDynamicObject : BasicNonDynamicObject
@end
@implementation SubBasicNonDynamicObject
@end



@interface AltBasicNonDynamicObject : NSObject <NonDynamicObjectProcotol>
@end
@implementation AltBasicNonDynamicObject

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


@interface SubAltBasicNonDynamicObject : BasicNonDynamicObject
@end
@implementation SubAltBasicNonDynamicObject
@end




@protocol DynamicInheritanceProtocol <NSObject>

@optional

- (int)objectMethod;
- (int)instanceMethod;
+ (int)classMethod;

@end

// This is to test the instance method-block chain
@interface SuperDynamicTestObject : NSObject
@end
@implementation SuperDynamicTestObject
@end

@interface SuperSubDynamicTestObject : SuperDynamicTestObject
@end
@implementation SuperSubDynamicTestObject
@end


@interface ParentDynamicTestObject : SuperSubDynamicTestObject
@end
@implementation ParentDynamicTestObject
@end

@interface ParentSubDynamicTestObject : ParentDynamicTestObject
@end
@implementation ParentSubDynamicTestObject
@end


@interface ChildDynamicTestObject : ParentSubDynamicTestObject
@end
@implementation ChildDynamicTestObject
@end

@interface ChildSubDynamicTestObject : ChildDynamicTestObject
@end
@implementation ChildSubDynamicTestObject
@end




#pragma mark - NSObject Dynamic Methods Tests

@interface NSDynamicMethodsTestObject : NSObject
@end
@implementation NSDynamicMethodsTestObject
@end



@interface NSDynamicMethodsTests : XCTestCase

@end


@implementation NSDynamicMethodsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	[BasicNonDynamicObject resetDynamicMethods];
}


- (void)test_MetaClassChecks
{
	
	id objectSelf = SubBasicNonDynamicObject.new;
	Class classSelf = object_getClass(objectSelf);
	Class metaSelf = object_getClass(classSelf);
	Class metaMetaClass = object_getClass(metaSelf);
	
	XCTAssertFalse(object_isClass(objectSelf));
	XCTAssertTrue(object_isClass(classSelf));
	XCTAssertTrue(object_isClass(metaSelf));
	XCTAssertTrue(object_isClass(metaMetaClass));
	
	
	//XCTAssertFalse(class_isMetaClass(objectSelf));	//objectSelf is not a Class
	XCTAssertFalse(class_isMetaClass(classSelf));
	XCTAssertTrue(class_isMetaClass(metaSelf));
	XCTAssertTrue(class_isMetaClass(metaMetaClass));
	
	NSString *objectName = [NSString stringWithFormat:@"%s", object_getClassName(objectSelf)];
	NSString *className = [NSString stringWithFormat:@"%s", object_getClassName(classSelf)];
	NSString *metaName = [NSString stringWithFormat:@"%s", object_getClassName(metaSelf)];
	NSString *metaMetaName = [NSString stringWithFormat:@"%s", object_getClassName(metaMetaClass)];
	
	XCTAssertEqualObjects(objectName, @"SubBasicNonDynamicObject");
	XCTAssertEqualObjects(className, @"SubBasicNonDynamicObject");
	XCTAssertEqualObjects(metaName, @"NSObject");
	XCTAssertEqualObjects(metaMetaName, @"NSObject");
	
	
	//NSString *objectClassName = [NSString stringWithFormat:@"%s", class_getName(objectSelf)];	//Bad Access, objectSelf is not a Class
	NSString *classClassName = [NSString stringWithFormat:@"%s", class_getName(classSelf)];
	NSString *metaClassName = [NSString stringWithFormat:@"%s", class_getName(metaSelf)];
	NSString *metaMetaClassName = [NSString stringWithFormat:@"%s", class_getName(metaMetaClass)];
	
	//XCTAssertEqualObjects(objectClassName, @"SubBasicNonDynamicObject");
	XCTAssertEqualObjects(classClassName, @"SubBasicNonDynamicObject");
	XCTAssertEqualObjects(metaClassName, @"SubBasicNonDynamicObject");
	XCTAssertEqualObjects(metaMetaClassName, @"NSObject");
}



#pragma mark - NSObject Dynamic Methods Properties

- (void)testBasicDynamicObject_dynamicMethods_Baseline
{
	BasicDynamicObject *dObject = BasicDynamicObject.new;
	
	XCTAssertEqual(NSObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(dObject.class.isDynamicMethodsEnabled, DMSelfEnabled);
	
	SEL invalidMethodSelector = NSSelectorFromString(@"aDynamicMethod:");
	XCTAssertFalse([dObject respondsToSelector:invalidMethodSelector]);
	XCTAssertNil([dObject methodSignatureForSelector:invalidMethodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:invalidMethodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:invalidMethodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:invalidMethodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:invalidMethodSelector]);
	
	invalidMethodSelector = nil;
}

- (void)testIsDynamicMethodsEnabled_Default
{
	XCTAssertEqual(NSObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	
	XCTAssertEqual(BasicDynamicObject.isDynamicMethodsEnabled, DMSelfEnabled);
	XCTAssertEqual(SubBasicDynamicObject.isDynamicMethodsEnabled, DMInheritEnabled);
}

- (void)testSetIsDynamicMethodsEnabled_statusRotation
{
	[BasicNonDynamicObject reset];
	
	//Default
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	
	//Enabled
	[BasicNonDynamicObject enableDynamicMethods];
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfEnabled);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritEnabled);
	
	//Disabled
	[BasicNonDynamicObject disableDynamicMethods];
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfDisabled);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritDisabled);
	
	//Reset
	[BasicNonDynamicObject resetDynamicMethods];
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	
	//Disabled
	[BasicNonDynamicObject disableDynamicMethods];
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfDisabled);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritDisabled);
	
	//Enabled
	[BasicNonDynamicObject enableDynamicMethods];
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfEnabled);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritEnabled);
	
	//Reset
	[BasicNonDynamicObject resetDynamicMethods];
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	
	[BasicNonDynamicObject reset];
}

- (void)testEnableDynamicMethods_InvalidCases
{
	XCTAssertFalse([NSObject enableDynamicMethods], @"Cannot enable dynamicMethods on NSObject.");
	XCTAssertFalse([object_getClass(BasicNonDynamicObject.class) enableDynamicMethods], @"Meta Class cannot enable dynamic Methods");
}

- (void)testAllowNSDynamicMethods_Validation
{
	XCTAssertFalse(NSObject.allowNSDynamicMethods, @"Default allow NS Dynamic Methods is false.");
	NSObject.allowNSDynamicMethods = YES;
	XCTAssertFalse(NSObject.allowNSDynamicMethods, @"Cannot enable allowNSDynamicMethods on root NSObject.");
	
	XCTAssertFalse(NSDynamicMethodsTestObject.allowNSDynamicMethods, @"Default allow NS Dynamic Methods is false.");
	XCTAssertEqual(NSDynamicMethodsTestObject.isDynamicMethodsEnabled, DMInheritNone, @"Default allow NS Dynamic Methods is false.");
	XCTAssertTrue([NSDynamicMethodsTestObject.class enableDynamicMethods], @"NS Classes cannot enable dynamic methods");
	XCTAssertEqual(NSDynamicMethodsTestObject.isDynamicMethodsEnabled, DMInheritNone, @"Default allow NS Dynamic Methods is false.");
	
	NSDynamicMethodsTestObject.allowNSDynamicMethods = YES;
	XCTAssertFalse([NSDynamicMethodsTestObject.class enableDynamicMethods], @"NS Classes can enable dynamic methods, when allowed");
	XCTAssertEqual(NSDynamicMethodsTestObject.isDynamicMethodsEnabled, DMSelfEnabled, @"NS allowed classes can enable dynamic methods.");
	
	NSDynamicMethodsTestObject.allowNSDynamicMethods = NO;
	XCTAssertEqual(NSDynamicMethodsTestObject.isDynamicMethodsEnabled, DMInheritNone, @"disallowed but enabled are disabled.");
	
	NSDynamicMethodsTestObject.allowNSDynamicMethods = YES;
	XCTAssertEqual(NSDynamicMethodsTestObject.isDynamicMethodsEnabled, DMSelfEnabled, @"NS allowed classes can enable dynamic methods.");
}

- (void)testEnableDynamicMethods_NSClassBlocked
{
	XCTAssertFalse([NSObject enableDynamicMethods], @"Cannot enable dynamicMethods on NSObject.");
	XCTAssertFalse([object_getClass(BasicNonDynamicObject.class) enableDynamicMethods], @"Meta Class cannot enable dynamic Methods");
}

- (void)testDisableDynamicMethods_InvalidCases
{
	XCTAssertFalse([NSObject disableDynamicMethods], @"Cannot disable dynamicMethods on NSObject.");
	XCTAssertFalse([object_getClass(BasicNonDynamicObject.class) disableDynamicMethods], @"Meta Class cannot enable dynamic Methods");
}

- (void)testResetDynamicMethods_InvalidCases
{
	XCTAssertFalse([NSObject resetDynamicMethods], @"Cannot disable dynamicMethods on NSObject.");
	XCTAssertFalse([object_getClass(BasicNonDynamicObject.class) resetDynamicMethods], @"Meta Class cannot enable dynamic Methods");
}


- (void)testSetIsDynamicMethodsEnabled_SubclassInherit_Validation
{
	SEL objectSelector = NSSelectorFromString(@"objectProperty");
	SEL instanceSelector = NSSelectorFromString(@"instanceProperty");
	SEL classSelector = NSSelectorFromString(@"classProperty");
	
	//ND = non-dynamic
	BasicNonDynamicObject *ndObject = BasicNonDynamicObject.new;
	SubBasicNonDynamicObject *ndSubObject = SubBasicNonDynamicObject.new;
	
	
	
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	
	XCTAssertTrue([BasicNonDynamicObject enableDynamicMethods]);
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfEnabled);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritEnabled);
	
	SEL nilSelector = nil;
	XCTAssertNil([BasicNonDynamicObject instanceMethodSignatureForSelector:nilSelector]);
	XCTAssertNotNil([BasicNonDynamicObject instanceMethodSignatureForSelector:objectSelector]);
	
	XCTAssertFalse([ndObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndObject respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:classSelector]);
	
	XCTAssertNotNil([ndObject methodSignatureForSelector:objectSelector]);
	XCTAssertNotNil([ndObject methodSignatureForSelector:instanceSelector]);
	XCTAssertNotNil([ndObject.class methodSignatureForSelector:classSelector]);
	XCTAssertNotNil([ndSubObject methodSignatureForSelector:objectSelector]);
	XCTAssertNotNil([ndSubObject methodSignatureForSelector:instanceSelector]);
	XCTAssertNotNil([ndSubObject.class methodSignatureForSelector:classSelector]);
	XCTAssertNotNil([BasicNonDynamicObject instanceMethodSignatureForSelector:objectSelector]);
	XCTAssertNotNil([BasicNonDynamicObject instanceMethodSignatureForSelector:instanceSelector]);
	XCTAssertNil([BasicNonDynamicObject.class instanceMethodSignatureForSelector:classSelector]);
	XCTAssertNotNil([SubBasicNonDynamicObject instanceMethodSignatureForSelector:objectSelector]);
	XCTAssertNotNil([SubBasicNonDynamicObject instanceMethodSignatureForSelector:instanceSelector]);
	XCTAssertNil([SubBasicNonDynamicObject.class instanceMethodSignatureForSelector:classSelector]);
	
	
	//Set the Object, Instance, and class methods.
	__block NSInteger objectReturnValue = 10;
	__block NSInteger instanceReturnValue = 100;
	__block NSInteger classReturnValue = 1000;
	
	[ndObject addObjectMethod:objectSelector block:^NSInteger(id _self) {return objectReturnValue;}];
	[ndObject.class addInstanceMethod:instanceSelector block:^NSInteger(id _self) {return instanceReturnValue;}];
	[ndObject.class addObjectMethod:classSelector block:^NSInteger(id _self) {return classReturnValue;}];
	
	
	//Check the methods
	XCTAssertTrue([ndObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	NSInteger objectResult = 0;
	NSInteger instanceResult = 0;
	NSInteger classResult = 0;
	
	@try {
		objectResult = [ndObject objectProperty];
		instanceResult = [ndObject instanceProperty];
		classResult = [ndObject.class classProperty];
	} @catch (NSException *e) {
		
	}
	
	XCTAssertEqual(objectResult, objectReturnValue);
	XCTAssertEqual(instanceResult, instanceReturnValue);
	XCTAssertEqual(classResult, classReturnValue);
	
	
	//Test Sub Object for Superclass dynamic methods
	objectReturnValue = 11;
	instanceReturnValue = 101;
	classReturnValue = 1001;
	
	NSInteger objectSubResult = 0;
	NSInteger instanceSubResult = 0;
	NSInteger classSubResult = 0;
	
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	
	@try {
		instanceSubResult = [ndSubObject instanceProperty];
		classSubResult = [ndSubObject.class classProperty];
	} @catch (NSException *e) {
		
	}
	
	XCTAssertEqual(objectSubResult, 0);
	XCTAssertEqual(instanceSubResult, instanceReturnValue);
	XCTAssertEqual(classSubResult, classSubResult);
	
	
	//Turn off Dynamic Methods for our regular object
	//	test regular object and subclass object
	[BasicNonDynamicObject disableDynamicMethods];
	
	XCTAssertThrowsSpecificNamed([ndObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject.class classProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject.class classProperty], NSException, NSInvalidArgumentException);
	
	XCTAssertFalse([ndObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndObject respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:classSelector]);
	
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:classSelector]);
	
	XCTAssertNotNil([BasicNonDynamicObject instanceMethodSignatureForSelector:objectSelector]);
	
	
	//Turn on dynamic methods for our regular object
	//	test regular object and subclass object
	[BasicNonDynamicObject enableDynamicMethods];
	
	objectReturnValue = 12;
	instanceReturnValue = 102;
	classReturnValue = 1002;
	XCTAssertEqual([ndObject objectProperty], objectReturnValue);
	XCTAssertEqual([ndObject instanceProperty], instanceReturnValue);
	XCTAssertEqual([ndObject.class classProperty], classReturnValue);
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertEqual([ndSubObject instanceProperty], instanceReturnValue);
	XCTAssertEqual([ndSubObject.class classProperty], classReturnValue);
	
	XCTAssertTrue([ndObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	
	[ndObject.class removeInstanceMethod:instanceSelector];
	XCTAssertTrue([ndObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	[ndObject.class removeObjectMethod:classSelector];
	XCTAssertTrue([ndObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	//reset
	[BasicNonDynamicObject resetDynamicMethods];
}

- (void)testSubclassDynamicMethods_ClassEnabled_Validation
{
	SEL objectSelector = NSSelectorFromString(@"objectProperty");
	SEL instanceSelector = NSSelectorFromString(@"instanceProperty");
	SEL classSelector = NSSelectorFromString(@"classProperty");
	
	//ND = non-dynamic
	BasicNonDynamicObject *ndObject = BasicNonDynamicObject.new;
	SubBasicNonDynamicObject *ndSubObject = SubBasicNonDynamicObject.new;
	
	
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	
	XCTAssertThrowsSpecificNamed([ndObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject.class classProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject.class classProperty], NSException, NSInvalidArgumentException);
	
	XCTAssertFalse([ndObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	XCTAssertTrue([BasicNonDynamicObject enableDynamicMethods]);
	XCTAssertFalse([BasicNonDynamicObject enableDynamicMethods]);
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfEnabled);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritEnabled);
	
	
	//Set the Object, Instance, and class methods.
	__block NSInteger objectReturnValue = 1;
	__block NSInteger instanceReturnValue = 100;
	__block NSInteger classReturnValue = 1000;
	
	XCTAssertTrue([ndObject addObjectMethod:objectSelector block:^NSInteger(id _self) {return objectReturnValue;}]);
	XCTAssertTrue([ndObject.class addInstanceMethod:instanceSelector block:^NSInteger(id _self) {return instanceReturnValue;}]);
	XCTAssertTrue([ndObject.class addObjectMethod:classSelector block:^NSInteger(id _self) {return classReturnValue;}]);
	
	// Add the same methods to subclass to override
	XCTAssertTrue([ndSubObject.class addInstanceMethod:instanceSelector block:^NSInteger(id _self) {return instanceReturnValue * 2;}]);
	XCTAssertTrue([ndSubObject.class addObjectMethod:classSelector block:^NSInteger(id _self) {return classReturnValue * 2;}]);
	
	
	objectReturnValue = 1;
	instanceReturnValue = 101;
	classReturnValue = 1001;
	XCTAssertEqual([ndObject objectProperty], objectReturnValue);
	XCTAssertEqual([ndObject instanceProperty], instanceReturnValue);
	XCTAssertEqual([ndObject.class classProperty], classReturnValue);
	
	XCTAssertEqual([ndSubObject instanceProperty], instanceReturnValue * 2);
	XCTAssertEqual([ndSubObject.class classProperty], classReturnValue * 2);
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException, @"Sub-object shouldn't have objectProperty.");
	
	XCTAssertTrue([ndObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	// objectSelector to subclass
	[ndSubObject addObjectMethod:objectSelector block:^NSInteger(id _self) {return objectReturnValue * 2;}];
	
	XCTAssertEqual([ndSubObject objectProperty], objectReturnValue * 2);
	
	XCTAssertTrue([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertNotNil([ndSubObject methodSignatureForSelector:objectSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertNotNil([SubBasicNonDynamicObject instanceMethodSignatureForSelector:objectSelector], @"Protocols return their methods.");
	
	// Turn on subclass dynamic methods with super class dynamic methods
	[SubBasicNonDynamicObject enableDynamicMethods];
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfEnabled);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfEnabled);
	
	objectReturnValue = 2;
	instanceReturnValue = 102;
	classReturnValue = 1002;
	
	XCTAssertEqual([ndObject objectProperty], objectReturnValue);
	XCTAssertEqual([ndObject instanceProperty], instanceReturnValue);
	XCTAssertEqual([ndObject.class classProperty], classReturnValue);
	XCTAssertEqual([ndSubObject objectProperty], objectReturnValue * 2);
	XCTAssertEqual([ndSubObject instanceProperty], instanceReturnValue * 2);
	XCTAssertEqual([ndSubObject.class classProperty], classReturnValue * 2);
	
	
	XCTAssertTrue([ndObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndObject.class respondsToSelector:classSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	// turn off subclass dynamic methods with super class dynamic methods
	[SubBasicNonDynamicObject disableDynamicMethods];
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfDisabled);
	objectReturnValue = 3;
	instanceReturnValue = 103;
	classReturnValue = 1003;
	
	XCTAssertEqual([ndObject objectProperty], objectReturnValue);
	XCTAssertEqual([ndObject instanceProperty], instanceReturnValue);
	XCTAssertEqual([ndObject.class classProperty], classReturnValue);
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertEqual([ndSubObject instanceProperty], instanceReturnValue, @"the super instance method should be called");
	XCTAssertEqual([ndSubObject.class classProperty], classReturnValue, @"the super class method should be called");
	
	XCTAssertTrue([ndObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	// Turn on subclass dynamic methods with super class dynamic methods
	[SubBasicNonDynamicObject enableDynamicMethods];
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfEnabled);
	objectReturnValue = 4;
	instanceReturnValue = 104;
	classReturnValue = 1004;
	XCTAssertEqual([ndObject objectProperty], objectReturnValue);
	XCTAssertEqual([ndObject instanceProperty], instanceReturnValue);
	XCTAssertEqual([ndObject.class classProperty], classReturnValue);
	XCTAssertEqual([ndSubObject objectProperty], objectReturnValue * 2);
	XCTAssertEqual([ndSubObject instanceProperty], instanceReturnValue * 2);
	XCTAssertEqual([ndSubObject.class classProperty], classReturnValue * 2);
	
	
	XCTAssertTrue([ndObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndObject.class respondsToSelector:classSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	// subclass DMSelfEnabled to DMInheritEnabled
	[SubBasicNonDynamicObject resetDynamicMethods];
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritEnabled);
	objectReturnValue = 5;
	instanceReturnValue = 105;
	classReturnValue = 1005;
	
	XCTAssertEqual([ndObject objectProperty], objectReturnValue);
	XCTAssertEqual([ndObject instanceProperty], instanceReturnValue);
	XCTAssertEqual([ndObject.class classProperty], classReturnValue);
	XCTAssertEqual([ndSubObject objectProperty], objectReturnValue * 2);
	XCTAssertEqual([ndSubObject instanceProperty], instanceReturnValue * 2);
	XCTAssertEqual([ndSubObject.class classProperty], classReturnValue * 2);
	
	
	XCTAssertTrue([ndObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndObject.class respondsToSelector:classSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	// Turn off subclass dynamic methods with super class dynamic methods
	[SubBasicNonDynamicObject disableDynamicMethods];
	objectReturnValue = 6;
	instanceReturnValue = 106;
	classReturnValue = 1006;
	
	XCTAssertEqual([ndObject objectProperty], objectReturnValue);
	XCTAssertEqual([ndObject instanceProperty], instanceReturnValue);
	XCTAssertEqual([ndObject.class classProperty], classReturnValue);
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertEqual([ndSubObject instanceProperty], instanceReturnValue, @"the super instance method should be called");
	XCTAssertEqual([ndSubObject.class classProperty], classReturnValue, @"the super class method should be called");
	
	
	XCTAssertTrue([ndObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	// subclass DMSelfDisabled to DMInheritEnabled
	[SubBasicNonDynamicObject resetDynamicMethods];
	objectReturnValue = 7;
	instanceReturnValue = 107;
	classReturnValue = 1007;
	XCTAssertEqual([ndObject objectProperty], objectReturnValue);
	XCTAssertEqual([ndObject instanceProperty], instanceReturnValue);
	XCTAssertEqual([ndObject.class classProperty], classReturnValue);
	XCTAssertEqual([ndSubObject objectProperty], objectReturnValue * 2);
	XCTAssertEqual([ndSubObject instanceProperty], instanceReturnValue * 2);
	XCTAssertEqual([ndSubObject.class classProperty], classReturnValue * 2);
	
	
	XCTAssertTrue([ndObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndObject.class respondsToSelector:classSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	[ndObject.class removeInstanceMethod:instanceSelector];
	[ndObject.class removeObjectMethod:classSelector];
	[ndSubObject.class removeInstanceMethod:instanceSelector];
	[ndSubObject.class removeObjectMethod:classSelector];
}

- (void)testSubclassDynamicMethods_ClassDisabled_Validation
{
	SEL objectSelector = NSSelectorFromString(@"objectProperty");
	SEL instanceSelector = NSSelectorFromString(@"instanceProperty");
	SEL classSelector = NSSelectorFromString(@"classProperty");
	
	//ND = non-dynamic
	BasicNonDynamicObject *ndObject = BasicNonDynamicObject.new;
	SubBasicNonDynamicObject *ndSubObject = SubBasicNonDynamicObject.new;
	
	
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritNone);

	
	XCTAssertTrue([BasicNonDynamicObject disableDynamicMethods]);
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfDisabled);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritDisabled);
	
	
	//Set the Object, Instance, and class methods.
	__block NSInteger objectReturnValue = 1;
	__block NSInteger instanceReturnValue = 100;
	__block NSInteger classReturnValue = 1000;
	
	[ndObject addObjectMethod:objectSelector block:^NSInteger(id _self) {return objectReturnValue;}];
	[ndObject.class addInstanceMethod:instanceSelector block:^NSInteger(id _self) {return instanceReturnValue;}];
	[ndObject.class addObjectMethod:classSelector block:^NSInteger(id _self) {return classReturnValue;}];
	
	// Add the same methods to subclass to override
	[ndSubObject addObjectMethod:objectSelector block:^NSInteger(id _self) {return objectReturnValue * 2;}];
	[ndSubObject.class addInstanceMethod:instanceSelector block:^NSInteger(id _self) {return instanceReturnValue * 2;}];
	[ndSubObject.class addObjectMethod:classSelector block:^NSInteger(id _self) {return classReturnValue * 2;}];
	
	
	objectReturnValue = 1;
	instanceReturnValue = 101;
	classReturnValue = 1001;
	XCTAssertThrowsSpecificNamed([ndObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject.class classProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject.class classProperty], NSException, NSInvalidArgumentException);
	
	
	// Turn on subclass dynamic methods with super class dynamic methods
	[SubBasicNonDynamicObject enableDynamicMethods];
	XCTAssertEqual(BasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfDisabled);
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfEnabled);
	
	XCTAssertFalse([ndObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndObject.class respondsToSelector:classSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	objectReturnValue = 2;
	instanceReturnValue = 102;
	classReturnValue = 1002;
	
	NSInteger result = 0;
	XCTAssertThrowsSpecificNamed([ndObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject.class classProperty], NSException, NSInvalidArgumentException);
	XCTAssertNoThrowSpecificNamed( result = [ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertEqual([ndSubObject instanceProperty], instanceReturnValue * 2);
	XCTAssertEqual([ndSubObject.class classProperty], classReturnValue * 2);
	
	
	// turn off subclass dynamic methods with super class dynamic methods
	[SubBasicNonDynamicObject disableDynamicMethods];
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfDisabled);
	objectReturnValue = 3;
	instanceReturnValue = 103;
	classReturnValue = 1003;
	
	XCTAssertThrowsSpecificNamed([ndObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject.class classProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject.class classProperty], NSException, NSInvalidArgumentException);
	
	XCTAssertFalse([ndObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	// Turn on subclass dynamic methods with super class dynamic methods
	[SubBasicNonDynamicObject enableDynamicMethods];
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMSelfEnabled);
	objectReturnValue = 4;
	instanceReturnValue = 104;
	classReturnValue = 1004;
	XCTAssertThrowsSpecificNamed([ndObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject.class classProperty], NSException, NSInvalidArgumentException);
	XCTAssertEqual([ndSubObject objectProperty], objectReturnValue * 2);
	XCTAssertEqual([ndSubObject instanceProperty], instanceReturnValue * 2);
	XCTAssertEqual([ndSubObject.class classProperty], classReturnValue * 2);
	
	XCTAssertFalse([ndObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndObject.class respondsToSelector:classSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertTrue([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertTrue([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertTrue([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	
	// subclass DMSelfEnabled to DMInheritEnabled
	[SubBasicNonDynamicObject resetDynamicMethods];
	XCTAssertEqual(SubBasicNonDynamicObject.isDynamicMethodsEnabled, DMInheritDisabled);
	objectReturnValue = 5;
	instanceReturnValue = 105;
	classReturnValue = 1005;
	
	XCTAssertThrowsSpecificNamed([ndObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject.class classProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject.class classProperty], NSException, NSInvalidArgumentException);
	
	XCTAssertFalse([ndObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	// Turn off subclass dynamic methods with super class dynamic methods
	[SubBasicNonDynamicObject disableDynamicMethods];
	objectReturnValue = 6;
	instanceReturnValue = 106;
	classReturnValue = 1006;
	
	XCTAssertThrowsSpecificNamed([ndObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject.class classProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject.class classProperty], NSException, NSInvalidArgumentException);
	
	XCTAssertFalse([ndObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	// subclass DMSelfDisabled to DMInheritEnabled
	[SubBasicNonDynamicObject resetDynamicMethods];
	objectReturnValue = 7;
	instanceReturnValue = 107;
	classReturnValue = 1007;
	XCTAssertThrowsSpecificNamed([ndObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndObject.class classProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject objectProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject instanceProperty], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([ndSubObject.class classProperty], NSException, NSInvalidArgumentException);
	
	XCTAssertFalse([ndObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:objectSelector]);
	XCTAssertFalse([ndSubObject respondsToSelector:instanceSelector]);
	XCTAssertFalse([ndSubObject.class respondsToSelector:classSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([BasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([BasicNonDynamicObject respondsToSelector:classSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:objectSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject instancesRespondToSelector:instanceSelector]);
	XCTAssertFalse([SubBasicNonDynamicObject respondsToSelector:classSelector]);
	
	
	[ndObject.class removeInstanceMethod:instanceSelector];
	[ndObject.class removeObjectMethod:classSelector];
	[ndSubObject.class removeInstanceMethod:instanceSelector];
	[ndSubObject.class removeObjectMethod:classSelector];
	
	[BasicNonDynamicObject resetDynamicMethods];
	[SubBasicNonDynamicObject resetDynamicMethods];
}

- (void)testInheritanceChain
{
	SEL objectSelector = @selector(objectMethod);
	SEL instanceSelector = @selector(instanceMethod);
	SEL classSelector = @selector(classMethod);
	
	SuperDynamicTestObject		*superObject = SuperDynamicTestObject.new;
	SuperSubDynamicTestObject	*superSubObject = SuperSubDynamicTestObject.new;
	ParentDynamicTestObject		*parentObject = ParentDynamicTestObject.new;
	ParentSubDynamicTestObject	*parentSubObject = ParentSubDynamicTestObject.new;
	ChildDynamicTestObject		*childObject = ChildDynamicTestObject.new;
	ChildSubDynamicTestObject	*childSubObject = ChildSubDynamicTestObject.new;
	
	int objectReturnValue = 1;
	int instanceReturnValue = 11;
	int classReturnValue = 101;
	
	
	XCTAssertEqual(SuperDynamicTestObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(SuperSubDynamicTestObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(ParentDynamicTestObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(ParentSubDynamicTestObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(ChildDynamicTestObject.isDynamicMethodsEnabled, DMInheritNone);
	XCTAssertEqual(ChildSubDynamicTestObject.isDynamicMethodsEnabled, DMInheritNone);
	
	
	[superObject addObjectMethod:objectSelector block:^NSNumber*(id _self) {return @(objectReturnValue);}];
	[SuperDynamicTestObject addInstanceMethod:instanceSelector block:^NSNumber*(id _self) {return @(instanceReturnValue);}];
	[SuperDynamicTestObject addObjectMethod:classSelector block:^NSNumber*(id _self) {return @(classReturnValue);}];
	
	[superSubObject addObjectMethod:objectSelector block:^NSNumber*(id _self) {return @(objectReturnValue * 2);}];
	[SuperSubDynamicTestObject addInstanceMethod:instanceSelector block:^NSNumber*(id _self) {return @(instanceReturnValue * 2);}];
	[SuperSubDynamicTestObject addObjectMethod:classSelector block:^NSNumber*(id _self) {return @(classReturnValue * 2);}];
	
	
	[parentObject addObjectMethod:objectSelector block:^NSNumber*(id _self) {return @(objectReturnValue * 3);}];
	[ParentDynamicTestObject addInstanceMethod:instanceSelector block:^NSNumber*(id _self) {return @(instanceReturnValue * 3);}];
	[ParentDynamicTestObject addObjectMethod:classSelector block:^NSNumber*(id _self) {return @(classReturnValue * 3);}];
	
	[parentSubObject addObjectMethod:objectSelector block:^NSNumber*(id _self) {return @(objectReturnValue * 4);}];
	[ParentSubDynamicTestObject addInstanceMethod:instanceSelector block:^NSNumber*(id _self) {return @(instanceReturnValue * 4);}];
	[ParentSubDynamicTestObject addObjectMethod:classSelector block:^NSNumber*(id _self) {return @(classReturnValue * 4);}];
	
	
	[childObject addObjectMethod:objectSelector block:^NSNumber*(id _self) {return @(objectReturnValue * 5);}];
	[ChildDynamicTestObject addInstanceMethod:instanceSelector block:^NSNumber*(id _self) {return @(instanceReturnValue * 5);}];
	[ChildDynamicTestObject addObjectMethod:classSelector block:^NSNumber*(id _self) {return @(classReturnValue * 5);}];
	
	[childSubObject addObjectMethod:objectSelector block:^NSNumber*(id _self) {return @(objectReturnValue * 6);}];
	[ChildSubDynamicTestObject addInstanceMethod:instanceSelector block:^NSNumber*(id _self) {return @(instanceReturnValue * 6);}];
	[ChildSubDynamicTestObject addObjectMethod:classSelector block:^NSNumber*(id _self) {return @(classReturnValue * 6);}];
	
	{ //	methodSignatureForSelector
		XCTAssertNil([superObject methodSignatureForSelector:objectSelector]);
		XCTAssertNil([superSubObject methodSignatureForSelector:objectSelector]);
		XCTAssertNil([parentObject methodSignatureForSelector:objectSelector]);
		XCTAssertNil([parentSubObject methodSignatureForSelector:objectSelector]);
		XCTAssertNil([childObject methodSignatureForSelector:objectSelector]);
		XCTAssertNil([childSubObject methodSignatureForSelector:objectSelector]);
		
		XCTAssertNil([superObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNil([superSubObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNil([parentObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNil([parentSubObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNil([childObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNil([childSubObject methodSignatureForSelector:instanceSelector]);
		
		XCTAssertNil([superObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNil([superSubObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNil([parentObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNil([parentSubObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNil([childObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNil([childSubObject.class methodSignatureForSelector:classSelector]);
	}
	
	{ //	respondsToSelector
		XCTAssertFalse([superObject respondsToSelector:objectSelector]);
		XCTAssertFalse([superSubObject respondsToSelector:objectSelector]);
		XCTAssertFalse([parentObject respondsToSelector:objectSelector]);
		XCTAssertFalse([parentSubObject respondsToSelector:objectSelector]);
		XCTAssertFalse([childObject respondsToSelector:objectSelector]);
		XCTAssertFalse([childSubObject respondsToSelector:objectSelector]);
		
		XCTAssertFalse([superObject respondsToSelector:instanceSelector]);
		XCTAssertFalse([superSubObject respondsToSelector:instanceSelector]);
		XCTAssertFalse([parentObject respondsToSelector:instanceSelector]);
		XCTAssertFalse([parentSubObject respondsToSelector:instanceSelector]);
		XCTAssertFalse([childObject respondsToSelector:instanceSelector]);
		XCTAssertFalse([childSubObject respondsToSelector:instanceSelector]);
		
		XCTAssertFalse([superObject.class respondsToSelector:classSelector]);
		XCTAssertFalse([superSubObject.class respondsToSelector:classSelector]);
		XCTAssertFalse([parentObject.class respondsToSelector:classSelector]);
		XCTAssertFalse([parentSubObject.class respondsToSelector:classSelector]);
		XCTAssertFalse([childObject.class respondsToSelector:classSelector]);
		XCTAssertFalse([childSubObject.class respondsToSelector:classSelector]);
	}
	
	{ //	instanceMethodSignatureForSelector
		XCTAssertNil([superObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([superSubObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([parentObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([parentSubObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([childObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([childSubObject.class instanceMethodSignatureForSelector:objectSelector]);
		
		XCTAssertNil([superObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNil([superSubObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNil([parentObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNil([parentSubObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNil([childObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNil([childSubObject.class instanceMethodSignatureForSelector:instanceSelector]);
		
		XCTAssertNil([superObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([superSubObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([parentObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([parentSubObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([childObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([childSubObject.class instanceMethodSignatureForSelector:classSelector]);
	}
	
	{ //	instancesRespondToSelector
		XCTAssertFalse([superObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([superSubObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([parentObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([parentSubObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([childObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([childSubObject.class instancesRespondToSelector:objectSelector]);
		
		XCTAssertFalse([superObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertFalse([superSubObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertFalse([parentObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertFalse([parentSubObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertFalse([childObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertFalse([childSubObject.class instancesRespondToSelector:instanceSelector]);
		
		XCTAssertFalse([superObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([superSubObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([parentObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([parentSubObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([childObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([childSubObject.class instancesRespondToSelector:classSelector]);
	}
	
	
   #pragma clang diagnostic push
   #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	
	XCTAssertThrowsSpecificNamed([superObject performSelector:objectSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([superObject performSelector:instanceSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([superObject.class performSelector:classSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([superSubObject performSelector:objectSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([superSubObject performSelector:instanceSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([superSubObject.class performSelector:classSelector], NSException, NSInvalidArgumentException);
	
	XCTAssertThrowsSpecificNamed([parentObject performSelector:objectSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([parentObject performSelector:instanceSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([parentObject.class performSelector:classSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([parentSubObject performSelector:objectSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([parentSubObject performSelector:instanceSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([parentSubObject.class performSelector:classSelector], NSException, NSInvalidArgumentException);
	
	XCTAssertThrowsSpecificNamed([childObject performSelector:objectSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([childObject performSelector:instanceSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([childObject.class performSelector:classSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([childSubObject performSelector:objectSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([childSubObject performSelector:instanceSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([childSubObject.class performSelector:classSelector], NSException, NSInvalidArgumentException);
	
	XCTAssertTrue([superObject.class enableDynamicMethods]);
	XCTAssertTrue([superObject.class resetDynamicMethods]);
	
	XCTAssertTrue([parentObject.class enableDynamicMethods]);
	
	XCTAssertThrowsSpecificNamed([superSubObject performSelector:objectSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([superSubObject performSelector:instanceSelector], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([superSubObject.class performSelector:classSelector], NSException, NSInvalidArgumentException);
	XCTAssertEqualObjects([childSubObject performSelector:objectSelector], @(objectReturnValue * 6));
	XCTAssertEqualObjects([childSubObject performSelector:instanceSelector], @(instanceReturnValue * 6));
	XCTAssertEqualObjects([childSubObject.class performSelector:classSelector], @(classReturnValue * 6));
	
	{ //	methodSignatureForSelector
		XCTAssertNil([superObject methodSignatureForSelector:objectSelector]);
		XCTAssertNil([superSubObject methodSignatureForSelector:objectSelector]);
		XCTAssertNotNil([parentObject methodSignatureForSelector:objectSelector]);
		XCTAssertNotNil([parentSubObject methodSignatureForSelector:objectSelector]);
		XCTAssertNotNil([childObject methodSignatureForSelector:objectSelector]);
		XCTAssertNotNil([childSubObject methodSignatureForSelector:objectSelector]);
		
		XCTAssertNil([superObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNil([superSubObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([parentObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([parentSubObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([childObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([childSubObject methodSignatureForSelector:instanceSelector]);
		
		XCTAssertNil([superObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNil([superSubObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNotNil([parentObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNotNil([parentSubObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNotNil([childObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNotNil([childSubObject.class methodSignatureForSelector:classSelector]);
	}
	
	{ //	respondsToSelector
		XCTAssertFalse([superObject respondsToSelector:objectSelector]);
		XCTAssertFalse([superSubObject respondsToSelector:objectSelector]);
		XCTAssertTrue([parentObject respondsToSelector:objectSelector]);
		XCTAssertTrue([parentSubObject respondsToSelector:objectSelector]);
		XCTAssertTrue([childObject respondsToSelector:objectSelector]);
		XCTAssertTrue([childSubObject respondsToSelector:objectSelector]);
		
		XCTAssertFalse([superObject respondsToSelector:instanceSelector]);
		XCTAssertFalse([superSubObject respondsToSelector:instanceSelector]);
		XCTAssertTrue([parentObject respondsToSelector:instanceSelector]);
		XCTAssertTrue([parentSubObject respondsToSelector:instanceSelector]);
		XCTAssertTrue([childObject respondsToSelector:instanceSelector]);
		XCTAssertTrue([childSubObject respondsToSelector:instanceSelector]);
		
		XCTAssertFalse([superObject.class respondsToSelector:classSelector]);
		XCTAssertFalse([superSubObject.class respondsToSelector:classSelector]);
		XCTAssertTrue([parentObject.class respondsToSelector:classSelector]);
		XCTAssertTrue([parentSubObject.class respondsToSelector:classSelector]);
		XCTAssertTrue([childObject.class respondsToSelector:classSelector]);
		XCTAssertTrue([childSubObject.class respondsToSelector:classSelector]);
	}
	
	{ //	instanceMethodSignatureForSelector
		XCTAssertNil([superObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([superSubObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([parentObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([parentSubObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([childObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([childSubObject.class instanceMethodSignatureForSelector:objectSelector]);
		
		XCTAssertNil([superObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNil([superSubObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([parentObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([parentSubObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([childObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([childSubObject.class instanceMethodSignatureForSelector:instanceSelector]);
		
		XCTAssertNil([superObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([superSubObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([parentObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([parentSubObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([childObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([childSubObject.class instanceMethodSignatureForSelector:classSelector]);
	}
	
	{ //	instancesRespondToSelector
		XCTAssertFalse([superObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([superSubObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([parentObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([parentSubObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([childObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([childSubObject.class instancesRespondToSelector:objectSelector]);
		
		XCTAssertFalse([superObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertFalse([superSubObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertTrue([parentObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertTrue([parentSubObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertTrue([childObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertTrue([childSubObject.class instancesRespondToSelector:instanceSelector]);
		
		XCTAssertFalse([superObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([superSubObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([parentObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([parentSubObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([childObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([childSubObject.class instancesRespondToSelector:classSelector]);
	}
	
	
	
	XCTAssertTrue([childObject.class disableDynamicMethods]);
	
	XCTAssertThrowsSpecificNamed([childSubObject performSelector:objectSelector], NSException, NSInvalidArgumentException);
	XCTAssertEqualObjects([childSubObject performSelector:instanceSelector], @(instanceReturnValue * 4));
	XCTAssertEqualObjects([childSubObject.class performSelector:classSelector], @(classReturnValue * 4));
	
	{ //	methodSignatureForSelector
		XCTAssertNil([superObject methodSignatureForSelector:objectSelector]);
		XCTAssertNil([superSubObject methodSignatureForSelector:objectSelector]);
		XCTAssertNotNil([parentObject methodSignatureForSelector:objectSelector]);
		XCTAssertNotNil([parentSubObject methodSignatureForSelector:objectSelector]);
		XCTAssertNil([childObject methodSignatureForSelector:objectSelector]);
		XCTAssertNil([childSubObject methodSignatureForSelector:objectSelector]);
		
		XCTAssertNil([superObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNil([superSubObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([parentObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([parentSubObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([childObject methodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([childSubObject methodSignatureForSelector:instanceSelector]);
		
		XCTAssertNil([superObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNil([superSubObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNotNil([parentObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNotNil([parentSubObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNotNil([childObject.class methodSignatureForSelector:classSelector]);
		XCTAssertNotNil([childSubObject.class methodSignatureForSelector:classSelector]);
	}
	
	{ //	respondsToSelector
		XCTAssertFalse([superObject respondsToSelector:objectSelector]);
		XCTAssertFalse([superSubObject respondsToSelector:objectSelector]);
		XCTAssertTrue([parentObject respondsToSelector:objectSelector]);
		XCTAssertTrue([parentSubObject respondsToSelector:objectSelector]);
		XCTAssertFalse([childObject respondsToSelector:objectSelector]);
		XCTAssertFalse([childSubObject respondsToSelector:objectSelector]);
		
		XCTAssertFalse([superObject respondsToSelector:instanceSelector]);
		XCTAssertFalse([superSubObject respondsToSelector:instanceSelector]);
		XCTAssertTrue([parentObject respondsToSelector:instanceSelector]);
		XCTAssertTrue([parentSubObject respondsToSelector:instanceSelector]);
		XCTAssertTrue([childObject respondsToSelector:instanceSelector]);
		XCTAssertTrue([childSubObject respondsToSelector:instanceSelector]);
		
		XCTAssertFalse([superObject.class respondsToSelector:classSelector]);
		XCTAssertFalse([superSubObject.class respondsToSelector:classSelector]);
		XCTAssertTrue([parentObject.class respondsToSelector:classSelector]);
		XCTAssertTrue([parentSubObject.class respondsToSelector:classSelector]);
		XCTAssertTrue([childObject.class respondsToSelector:classSelector]);
		XCTAssertTrue([childSubObject.class respondsToSelector:classSelector]);
	}
	
	{ //	instanceMethodSignatureForSelector
		XCTAssertNil([superObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([superSubObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([parentObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([parentSubObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([childObject.class instanceMethodSignatureForSelector:objectSelector]);
		XCTAssertNil([childSubObject.class instanceMethodSignatureForSelector:objectSelector]);
		
		XCTAssertNil([superObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNil([superSubObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([parentObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([parentSubObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([childObject.class instanceMethodSignatureForSelector:instanceSelector]);
		XCTAssertNotNil([childSubObject.class instanceMethodSignatureForSelector:instanceSelector]);
		
		XCTAssertNil([superObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([superSubObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([parentObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([parentSubObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([childObject.class instanceMethodSignatureForSelector:classSelector]);
		XCTAssertNil([childSubObject.class instanceMethodSignatureForSelector:classSelector]);
	}
	
	{ //	instancesRespondToSelector
		XCTAssertFalse([superObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([superSubObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([parentObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([parentSubObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([childObject.class instancesRespondToSelector:objectSelector]);
		XCTAssertFalse([childSubObject.class instancesRespondToSelector:objectSelector]);
		
		XCTAssertFalse([superObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertFalse([superSubObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertTrue([parentObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertTrue([parentSubObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertTrue([childObject.class instancesRespondToSelector:instanceSelector]);
		XCTAssertTrue([childSubObject.class instancesRespondToSelector:instanceSelector]);
		
		XCTAssertFalse([superObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([superSubObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([parentObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([parentSubObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([childObject.class instancesRespondToSelector:classSelector]);
		XCTAssertFalse([childSubObject.class instancesRespondToSelector:classSelector]);
	}
	
	
   #pragma clang diagnostic pop
}

#pragma mark - Object Dynamic Methods

- (void)testBasicDynamicObject_isDynamicObjectMethod
{
	BasicDynamicObject *dObject = BasicDynamicObject.new;
	
	SEL dynamicMethodSelector = NSSelectorFromString(@"my_isDynamicInstanceMethod:");
	SEL nilSelector = nil;
	
	XCTAssertFalse([dObject isDynamicMethod:nilSelector]);
	XCTAssertFalse([dObject isDynamicMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:nilSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:dynamicMethodSelector]);
	
	XCTAssertFalse([dObject.class isDynamicMethod:nilSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:nilSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:nilSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:dynamicMethodSelector]);
	
	XCTAssertTrue([dObject addObjectMethod:dynamicMethodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 2);
	}
	]);
	
	XCTAssertFalse([dObject isDynamicMethod:@selector(init)]);
	
	XCTAssertTrue([dObject isDynamicMethod:dynamicMethodSelector]);
	XCTAssertTrue([dObject isDynamicObjectMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:dynamicMethodSelector]);
	
	XCTAssertTrue([dObject removeObjectMethod:dynamicMethodSelector]);
	
	XCTAssertFalse([dObject isDynamicMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:dynamicMethodSelector]);
}


- (void)testBasicDynamicObject_AddObjectMethod_NoCmdSelector_Minimal
{
	BasicDynamicObject<NSObjectTestDynamicMethod> *dObject = (BasicDynamicObject<NSObjectTestDynamicMethod> *)BasicDynamicObject.new;
	
	//SEL longMethodSelector = @selector(newMethodTest_100:uchar:shortValue:ushortValue:intValue:uintValue:longValue:ulongValue:longlongValue:ulonglongValue:floatValue:doubleValue:stringValue:classValue:voidPtrValue:boolValue:selector:);
	
	SEL methodSelector = @selector(newMethodTest_140);
	
	XCTAssertFalse([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertFalse([dObject respondsToSelector:methodSelector]);
	XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	NSObject *objParam = NSObject.new;
	
	int counter = 2;
	__block id __self = nil;
	
	__block int blockExecutionCount = 0;
	__block SEL blockCommand = nil;
	__block int blockParam2 = 0;
	__block double blockParam3 = 0;
	__block id blockObject = nil;
	
	XCTAssertTrue([dObject addObjectMethod:methodSelector block:^(id _self) {
		__self = _self;
		//blockCommand = __cmd;
		//blockParam2 = param2;
		//blockParam3 = param3;
		//blockObject = object;
		
		blockExecutionCount += counter;
	}]);
	
	XCTAssertTrue([dObject isDynamicMethod:methodSelector]);
	XCTAssertTrue([dObject isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
	// Object only methods don't affect the class.
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	[dObject newMethodTest_140];
	
	XCTAssertEqual(__self, dObject);
	//XCTAssertEqual(blockCommand, nil);
	XCTAssertEqual(blockExecutionCount, counter);
}
	
- (void)testBasicDynamicObject_AddObjectMethod_WithCmdSelector_Minimal
{
	BasicDynamicObject<NSObjectTestDynamicMethod> *dObject = (BasicDynamicObject<NSObjectTestDynamicMethod> *)BasicDynamicObject.new;
	
	SEL methodSelector = @selector(newMethodTest_141);
	
	XCTAssertFalse([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertFalse([dObject respondsToSelector:methodSelector]);
	XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	NSObject *objParam = NSObject.new;
	
	int counter = 2;
	__block id __self = nil;
	
	__block int blockExecutionCount = 0;
	__block SEL blockCommand = nil;
	__block int blockParam2 = 0;
	__block double blockParam3 = 0;
	__block id blockObject = nil;
	
	XCTAssertTrue([dObject addObjectMethod:methodSelector block:^(id _self, SEL __cmd) {
		__self = _self;
		blockCommand = __cmd;
		//blockParam2 = param2;
		//blockParam3 = param3;
		//blockObject = object;
		
		blockExecutionCount += counter;
	}]);
	
	XCTAssertTrue([dObject isDynamicMethod:methodSelector]);
	XCTAssertTrue([dObject isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	[dObject newMethodTest_141];
	
	XCTAssertEqual(__self, dObject);
	XCTAssertEqualObjects(NSStringFromSelector(blockCommand), NSStringFromSelector(methodSelector));
	XCTAssertEqual(blockExecutionCount, counter);
}


- (void)testBasicDynamicObject_AddObjectMethod_NoCmdSelector
{
	BasicDynamicObject<NSObjectTestDynamicMethod> *dObject = (BasicDynamicObject<NSObjectTestDynamicMethod> *)BasicDynamicObject.new;
	
	//SEL longMethodSelector = @selector(newMethodTest_100:uchar:shortValue:ushortValue:intValue:uintValue:longValue:ulongValue:longlongValue:ulonglongValue:floatValue:doubleValue:stringValue:classValue:voidPtrValue:boolValue:selector:);
	
	SEL methodSelector = @selector(newMethodTest_142:dbl:object:);
	
	XCTAssertFalse([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertFalse([dObject respondsToSelector:methodSelector]);
	XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	NSObject *objParam = NSObject.new;
	
	int counter = 2;
	__block id __self = nil;
	
	__block int blockExecutionCount = 0;
	__block SEL blockCommand = nil;
	__block int blockParam2 = 0;
	__block double blockParam3 = 0;
	__block id blockObject = nil;
	
	XCTAssertTrue([dObject addObjectMethod:methodSelector block:^(id _self, int param2, double param3, id object) {
		__self = _self;
		//blockCommand = __cmd;
		blockParam2 = param2;
		blockParam3 = param3;
		blockObject = object;
		
		blockExecutionCount += counter;
	}]);
	
	XCTAssertTrue([dObject isDynamicMethod:methodSelector]);
	XCTAssertTrue([dObject isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
	// Object only methods don't affect the class.
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	[dObject newMethodTest_142:33 dbl:1.5 object:objParam];
	
	XCTAssertEqual(__self, dObject);
	XCTAssertEqual(blockCommand, nil);
	XCTAssertEqual(blockParam2, 33);
	XCTAssertEqual(blockParam3, 1.5);
	XCTAssertEqual(blockObject, objParam);
	XCTAssertEqual(blockExecutionCount, counter);
	
	
	XCTAssertTrue([dObject addObjectMethod:methodSelector block:^(id _self, int param2, double param3, id object) {
		__self = _self;
		//blockCommand = __cmd;
		blockParam2 = param2 * 2;
		blockParam3 = param3 * 3;
		blockObject = nil;
		
		blockExecutionCount += counter * 10;
	}]);
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	
	
	[dObject newMethodTest_142:50 dbl:10 object:objParam];
	
	XCTAssertEqual(__self, dObject);
	XCTAssertEqual(blockCommand, nil);
	XCTAssertEqual(blockParam2, 100);
	XCTAssertEqual(blockParam3, 30.0);
	XCTAssertNil(blockObject);
	XCTAssertEqual(blockExecutionCount, 22);
}
	
- (void)testBasicDynamicObject_AddObjectMethod_WithCmdSelector
{
	BasicDynamicObject<NSObjectTestDynamicMethod> *dObject = (BasicDynamicObject<NSObjectTestDynamicMethod> *)BasicDynamicObject.new;
	
	SEL methodSelector = @selector(newMethodTest_143:dbl:object:);
	
	XCTAssertFalse([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertFalse([dObject respondsToSelector:methodSelector]);
	XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	NSObject *objParam = NSObject.new;
	
	int counter = 2;
	__block id __self = nil;
	
	__block int blockExecutionCount = 0;
	__block SEL blockCommand = nil;
	__block int blockParam2 = 0;
	__block double blockParam3 = 0;
	__block id blockObject = nil;
	
	XCTAssertTrue([dObject addObjectMethod:methodSelector block:^(id _self, SEL __cmd, int param2, double param3, id object) {
		__self = _self;
		blockCommand = __cmd;
		blockParam2 = param2;
		blockParam3 = param3;
		blockObject = object;
		
		blockExecutionCount += counter;
	}]);
	
	XCTAssertTrue([dObject isDynamicMethod:methodSelector]);
	XCTAssertTrue([dObject isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	[dObject newMethodTest_143:33 dbl:1.5 object:objParam];
	
	XCTAssertEqual(__self, dObject);
	XCTAssertEqualObjects(NSStringFromSelector(blockCommand), NSStringFromSelector(methodSelector));
	XCTAssertEqual(blockParam2, 33);
	XCTAssertEqual(blockParam3, 1.5);
	XCTAssertEqual(blockObject, objParam);
	XCTAssertEqual(blockExecutionCount, counter);
}

typedef union myUnion {
	char c;
	short s;
	int i;
} myUnion;

- (void)testBasicDynamicObject_AddObjectMethod_BadParameters
{
	BasicDynamicObject *object = BasicDynamicObject.new;
	
	__block int blockExecutionCount = 0;
	
	SEL newMethodSelector = NSSelectorFromString(@"newMethodTest_1000");
	SEL nullSelector = nil;
	
	XCTAssertFalse([object addObjectMethod:nullSelector block:NULL]);
	
	XCTAssertFalse([object addObjectMethod:nullSelector block:^(id _self, SEL __cmd, int param2, double param3, id object) {
		blockExecutionCount++;
	}]);
	
	XCTAssertFalse([object addObjectMethod:newMethodSelector block:NULL]);
	
	XCTAssertFalse([object addObjectMethod:newMethodSelector block:NSString.new]);
	
	XCTAssertThrowsSpecificNamed([object addObjectMethod:newMethodSelector block:^(id _self, union myUnion *aUnion) {}], NSException,
								 NSInvalidArgumentException);
	
	SEL longerSelector = NSSelectorFromString(@"myDiffMethod:param:");
	
	XCTAssertTrue([object addObjectMethod:longerSelector block:^(id _self, id p1, id p2, id p3) {
		blockExecutionCount++;
	}]);
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[object performSelector:longerSelector withObject:@100 withObject:@100];
#pragma clang diagnostic pop
	
	// Check for lack of signature, shouldn't happen buuuuuut....  (for coverage)
	Block_literal blockLiteral = {
		.isa = &_NSConcreteGlobalBlock,
		.flags = BLOCK_IS_GLOBAL,  // BLOCK_HAS_SIGNATURE is intentionally omitted
		.reserved = 0,
		.invoke = 0,
		.descriptor = 0};
	XCTAssertFalse([object addObjectMethod:NSSelectorFromString(@"customMethod:") block:(__bridge id)&blockLiteral]);
}

- (void)testBasicDynamicObject_RemoveObjectMethod
{
	BasicDynamicObject *dObject = BasicDynamicObject.new;
	
	SEL methodSelector = NSSelectorFromString(@"myDynamicRemoveMethod:");
	
	XCTAssertTrue([dObject addObjectMethod:methodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 2);
	}
				  ]);
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	XCTAssertFalse([dObject removeObjectMethod:@selector(init)]);
	XCTAssertTrue([dObject removeObjectMethod:methodSelector]);
	
	
	XCTAssertFalse([dObject respondsToSelector:methodSelector]);
	XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
}

- (void)testBasicDynamicObject_RemoveObjectMethod_BadArgument
{
	BasicDynamicObject *dObject = BasicDynamicObject.new;
	
	SEL nilSelector = nil;
	XCTAssertFalse([dObject removeObjectMethod:nilSelector]);
}



#pragma mark - Instance Dynamic Methods

- (void)testBasicDynamicObject_isDynamicInstanceMethod
{
	BasicDynamicObject *dObject = BasicDynamicObject.new;
	
	SEL dynamicMethodSelector = NSSelectorFromString(@"myDynamicClassMethod:");
	
	XCTAssertFalse([dObject isDynamicMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:dynamicMethodSelector]);
	
	XCTAssertTrue([dObject.class addInstanceMethod:dynamicMethodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 2);
	}
	]);
	
	XCTAssertFalse([dObject isDynamicMethod:@selector(init)]);
	
	XCTAssertTrue([dObject isDynamicMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:dynamicMethodSelector]);
	XCTAssertTrue([dObject.class isDynamicInstanceMethod:dynamicMethodSelector]);
	
	XCTAssertTrue([dObject.class removeInstanceMethod:dynamicMethodSelector]);
	
	XCTAssertFalse([dObject isDynamicMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:dynamicMethodSelector]);
}






- (void)testBasicDynamicObject_AddInstanceMethod_NoCmdSelector_Minimal
{
	BasicDynamicObject<NSObjectTestDynamicMethod> *dObject = (BasicDynamicObject<NSObjectTestDynamicMethod> *)BasicDynamicObject.new;
	
	//SEL longMethodSelector = @selector(newMethodTest_100:uchar:shortValue:ushortValue:intValue:uintValue:longValue:ulongValue:longlongValue:ulonglongValue:floatValue:doubleValue:stringValue:classValue:voidPtrValue:boolValue:selector:);
	
	SEL methodSelector = @selector(newMethodTest_144);
	
	XCTAssertFalse([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertFalse([dObject respondsToSelector:methodSelector]);
	XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	int counter = 2;
	__block id __self = nil;
	
	__block int blockExecutionCount = 0;
	
	XCTAssertTrue([dObject.class addInstanceMethod:methodSelector block:^(id _self) {
		__self = _self;
		//blockCommand = __cmd;
		//blockParam2 = param2;
		//blockParam3 = param3;
		//blockObject = object;
		
		blockExecutionCount += counter;
	}]);
	
	XCTAssertTrue([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertTrue([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertTrue([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNotNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	[dObject newMethodTest_144];
	
	XCTAssertEqual(__self, dObject);
	//XCTAssertEqual(blockCommand, nil);
	XCTAssertEqual(blockExecutionCount, counter);
	
	
	XCTAssertTrue([dObject.class removeInstanceMethod:methodSelector]);
}
	
- (void)testBasicDynamicObject_AddInstanceMethod_WithCmdSelector_Minimal
{
	BasicDynamicObject<NSObjectTestDynamicMethod> *dObject = (BasicDynamicObject<NSObjectTestDynamicMethod> *)BasicDynamicObject.new;
	
	SEL methodSelector = @selector(newMethodTest_145);
	
	XCTAssertFalse([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertFalse([dObject respondsToSelector:methodSelector]);
	XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	int counter = 2;
	__block id __self = nil;
	
	__block int blockExecutionCount = 0;
	__block SEL blockCommand = nil;
	
	XCTAssertTrue([dObject.class addInstanceMethod:methodSelector block:^(id _self, SEL __cmd) {
		__self = _self;
		blockCommand = __cmd;
		
		blockExecutionCount += counter;
	}]);
	
	XCTAssertTrue([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertTrue([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertTrue([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNotNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	[dObject newMethodTest_145];
	
	XCTAssertEqual(__self, dObject);
	XCTAssertEqualObjects(NSStringFromSelector(blockCommand), NSStringFromSelector(methodSelector));
	XCTAssertEqual(blockExecutionCount, counter);
	
	XCTAssertTrue([dObject.class removeInstanceMethod:methodSelector]);
}

- (void)testBasicDynamicObject_AddInstanceMethod_NoCmdSelector
{
	BasicDynamicObject<NSObjectTestDynamicMethod> *dObject = (BasicDynamicObject<NSObjectTestDynamicMethod> *)BasicDynamicObject.new;
	
	//SEL longMethodSelector = @selector(newMethodTest_100:uchar:shortValue:ushortValue:intValue:uintValue:longValue:ulongValue:longlongValue:ulonglongValue:floatValue:doubleValue:stringValue:classValue:voidPtrValue:boolValue:selector:);
	
	SEL methodSelector = @selector(newMethodTest_146:dbl:object:);
	
	XCTAssertFalse([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	XCTAssertFalse([dObject respondsToSelector:methodSelector]);
	XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	NSObject *objParam = NSObject.new;
	
	int counter = 2;
	__block id __self = nil;
	
	__block int blockExecutionCount = 0;
	__block SEL blockCommand = nil;
	__block int blockParam2 = 0;
	__block double blockParam3 = 0;
	__block id blockObject = nil;
	XCTAssertTrue([dObject.class addInstanceMethod:methodSelector block:^(id _self, int param2, double param3, id object) {
		__self = _self;
		//blockCommand = __cmd;
		blockParam2 = param2;
		blockParam3 = param3;
		blockObject = object;
		
		blockExecutionCount += counter;
	}]);
	
	XCTAssertTrue([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertTrue([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertTrue([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNotNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	[dObject newMethodTest_146:33 dbl:1.5 object:objParam];
	
	XCTAssertEqual(__self, dObject);
	XCTAssertEqual(blockCommand, nil);
	XCTAssertEqual(blockParam2, 33);
	XCTAssertEqual(blockParam3, 1.5);
	XCTAssertEqual(blockObject, objParam);
	XCTAssertEqual(blockExecutionCount, counter);
	
	XCTAssertTrue([dObject.class addInstanceMethod:methodSelector block:^(id _self, int param2, double param3, id object) {
		__self = _self;
		//blockCommand = __cmd;
		blockParam2 = param2 * 2;
		blockParam3 = param3 * 3;
		blockObject = nil;
		
		blockExecutionCount += counter * 10;
	}]);
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertTrue([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNotNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	[dObject newMethodTest_146:50 dbl:10 object:objParam];
	
	XCTAssertEqual(__self, dObject);
	XCTAssertEqual(blockCommand, nil);
	XCTAssertEqual(blockParam2, 100);
	XCTAssertEqual(blockParam3, 30.0);
	XCTAssertNil(blockObject);
	XCTAssertEqual(blockExecutionCount, 22);
	
	XCTAssertTrue([dObject.class removeInstanceMethod:methodSelector]);
}
	
- (void)testBasicDynamicObject_AddInstanceMethod_WithCmdSelector
{
	BasicDynamicObject<NSObjectTestDynamicMethod> *dObject = (BasicDynamicObject<NSObjectTestDynamicMethod> *)BasicDynamicObject.new;
	
	SEL methodSelector = @selector(newMethodTest_147:dbl:object:);
	
	XCTAssertFalse([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertFalse([dObject respondsToSelector:methodSelector]);
	XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	NSObject *objParam = NSObject.new;
	
	int counter = 2;
	__block id __self = nil;
	
	__block int blockExecutionCount = 0;
	__block SEL blockCommand = nil;
	__block int blockParam2 = 0;
	__block double blockParam3 = 0;
	__block id blockObject = nil;
	
	XCTAssertTrue([dObject.class addInstanceMethod:methodSelector block:^(id _self, SEL __cmd, int param2, double param3, id object) {
		__self = _self;
		blockCommand = __cmd;
		blockParam2 = param2;
		blockParam3 = param3;
		blockObject = object;
		
		blockExecutionCount += counter;
	}]);
	
	XCTAssertTrue([dObject isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject isDynamicObjectMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicMethod:methodSelector]);
	XCTAssertFalse([dObject.class isDynamicObjectMethod:methodSelector]);
	XCTAssertTrue([dObject.class isDynamicInstanceMethod:methodSelector]);
	
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertTrue([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNotNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	[dObject newMethodTest_147:33 dbl:1.5 object:objParam];
	
	XCTAssertEqual(__self, dObject);
	XCTAssertEqualObjects(NSStringFromSelector(blockCommand), NSStringFromSelector(methodSelector));
	XCTAssertEqual(blockParam2, 33);
	XCTAssertEqual(blockParam3, 1.5);
	XCTAssertEqual(blockObject, objParam);
	XCTAssertEqual(blockExecutionCount, counter);
	
	XCTAssertTrue([dObject.class removeInstanceMethod:methodSelector]);
}


- (void)testBasicDynamicObject_AddInstanceMethod_BadParameters
{
	__block int blockExecutionCount = 0;
	
	SEL newMethodSelector = NSSelectorFromString(@"newMethodTest_1001:");
	SEL nullSelector = nil;
	
	XCTAssertFalse([BasicDynamicObject addInstanceMethod:nullSelector block:NULL]);
	
	XCTAssertFalse([BasicDynamicObject addInstanceMethod:nullSelector block:^(id _self, SEL __cmd, int param2, double param3, id object) {
		blockExecutionCount++;
	}]);
	
	XCTAssertFalse([BasicDynamicObject addInstanceMethod:newMethodSelector block:NULL]);
	
	XCTAssertFalse([BasicDynamicObject addInstanceMethod:newMethodSelector block:NSString.new]);
	
	Block_literal blockLiteral = {
		.isa = &_NSConcreteGlobalBlock,
		.flags = BLOCK_IS_GLOBAL,  // BLOCK_HAS_SIGNATURE is intentionally omitted
		.reserved = 0,
		.invoke = 0,
		.descriptor = 0};
	XCTAssertFalse([BasicDynamicObject addInstanceMethod:NSSelectorFromString(@"customMethod:") block:(__bridge id)&blockLiteral]);
}


- (void)testBasicDynamicObject_RemoveInstanceMethod
{
	BasicDynamicObject *dObject = BasicDynamicObject.new;
	
	SEL methodSelector = NSSelectorFromString(@"myDynamicClassMethod:");
	
	
	XCTAssertTrue([dObject.class addInstanceMethod:methodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 2);
	}
	]);
	
	XCTAssertTrue([dObject respondsToSelector:methodSelector]);
	XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertTrue([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNotNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	
	
	
	XCTAssertFalse([dObject.class removeInstanceMethod:@selector(init)]);
	XCTAssertTrue([dObject.class removeInstanceMethod:methodSelector]);
	
	
	XCTAssertFalse([dObject respondsToSelector:methodSelector]);
	XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
	
	XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
	XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
	XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
}

- (void)testBasicDynamicObject_RemoveInstanceMethod_BadArgument
{
	SEL nilSelector = nil;
	XCTAssertFalse([NSDynamicObject removeInstanceMethod:nilSelector]);
}


- (void)testBasicDynamicObject_MetaClass_check
{
	BasicDynamicObject *dObject = BasicDynamicObject.new;
	
	SEL objectSelector = NSSelectorFromString(@"objectPropertyMeta");
	SEL objectCmdSelector = NSSelectorFromString(@"objectCmdPropertyMeta");
	SEL instanceSelector = NSSelectorFromString(@"instancePropertyMeta");
	SEL classSelector = NSSelectorFromString(@"classPropertyMeta");
	SEL classCmdSelector = NSSelectorFromString(@"classCmdPropertyMeta");
	
	SEL methodSelector;
	
	{	// Object Selector
		methodSelector = objectSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector]);
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Object Cmd Selector
		methodSelector = objectCmdSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector]);
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Instance Selector
		methodSelector = instanceSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector]);
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Class Selector
		methodSelector = classSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector]);
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Class Cmd Selector
		methodSelector = classCmdSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector]);
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	
	XCTAssertTrue([dObject addObjectMethod:objectSelector block:^NSNumber*(id _self) {
		return @(-10);
	}]);
	
	XCTAssertTrue([dObject addObjectMethod:objectCmdSelector block:^NSNumber*(id _self, SEL __cmd) {
		return @(-20);
	}]);
	
	XCTAssertTrue([dObject.class addInstanceMethod:instanceSelector block:^NSNumber*(id _self) {
		return @(-100);
	}]);
	
	XCTAssertTrue([dObject.class addObjectMethod:classSelector block:^NSNumber*(id _self) {
		return @(-1000);
	}]);
	
	XCTAssertTrue([dObject.class addObjectMethod:classCmdSelector block:^NSNumber*(id _self, SEL __cmd) {
		return @(-1010);
	}]);
	
	
	
	{	// Object Selector
		methodSelector = objectSelector;
		
		XCTAssertTrue([dObject respondsToSelector:methodSelector]);
		XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Object Cmd Selector
		methodSelector = objectCmdSelector;
		
		XCTAssertTrue([dObject respondsToSelector:methodSelector]);
		XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Instance Selector
		methodSelector = instanceSelector;
		
		XCTAssertTrue([dObject respondsToSelector:methodSelector]);
		XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertTrue([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNotNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Class Selector
		methodSelector = classSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector], @"Object should not respond to class object method");
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector], @"Object should not have class object method signature");
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertTrue([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNotNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Class Cmd Selector
		methodSelector = classCmdSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector], @"Object should not respond to class object method");
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector], @"Object should not have class object method signature");
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertTrue([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNotNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
   #pragma clang diagnostic push
   #pragma clang diagnostic ignored "-Warc-performSelector-leaks"

	NSNumber *objectResult = [dObject performSelector:objectSelector];
	NSNumber *objectCmdResult = [dObject performSelector:objectCmdSelector];
	NSNumber *instanceResult = [dObject performSelector:instanceSelector];
	NSNumber *classResult = nil;
	
	XCTAssertThrowsSpecificNamed(classResult = [dObject performSelector:classSelector], NSException,
								 NSInvalidArgumentException);
	
	XCTAssertEqualObjects(objectResult, @-10);
	XCTAssertEqualObjects(objectCmdResult, @-20);
	XCTAssertEqualObjects(instanceResult, @-100);
	XCTAssertNil(classResult);
	
	
	objectResult = nil;
	instanceResult = nil;
	classResult = nil;
	XCTAssertThrowsSpecificNamed(objectResult = [dObject.class performSelector:objectSelector], NSException,
								 NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed(instanceResult = [dObject.class performSelector:instanceSelector], NSException,
								 NSInvalidArgumentException);
	
	XCTAssertNoThrow(classResult = [dObject.class performSelector:classSelector]);
	
	XCTAssertNil(objectResult);
	XCTAssertNil(instanceResult);
	XCTAssertEqualObjects(classResult, @-1000);
	
	
	
	classResult = nil;
	XCTAssertNoThrow(classResult = [dObject.class performSelector:classCmdSelector]);
	XCTAssertEqualObjects(classResult, @-1010);
	
	
   #pragma clang diagnostic pop
	
	// Doesn't remove selector of incorrect style
	XCTAssertFalse([dObject.class removeObjectMethod:@selector(init)]);
	XCTAssertFalse([dObject.class removeObjectMethod:objectSelector]);
	XCTAssertFalse([dObject.class removeObjectMethod:instanceSelector]);
	XCTAssertFalse([dObject.class removeInstanceMethod:objectSelector]);
	XCTAssertFalse([dObject.class removeInstanceMethod:classSelector]);
	XCTAssertFalse([dObject removeObjectMethod:instanceSelector]);
	XCTAssertFalse([dObject removeObjectMethod:classSelector]);
	
	// remove class object method
	XCTAssertTrue([dObject.class removeObjectMethod:classSelector]);
	
	{	// Object Selector
		methodSelector = objectSelector;
		
		XCTAssertTrue([dObject respondsToSelector:methodSelector]);
		XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Instance Selector
		methodSelector = instanceSelector;
		
		XCTAssertTrue([dObject respondsToSelector:methodSelector]);
		XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertTrue([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNotNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Instance Selector
		methodSelector = classSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector]);
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	
	// remove instance method
	XCTAssertTrue([dObject.class removeInstanceMethod:instanceSelector]);
	
	{	// Object Selector
		methodSelector = objectSelector;
		
		XCTAssertTrue([dObject respondsToSelector:methodSelector]);
		XCTAssertNotNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Instance Selector
		methodSelector = instanceSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector]);
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Instance Selector
		methodSelector = classSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector]);
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	
	
	
	// remove instance method
	XCTAssertTrue([dObject removeObjectMethod:objectSelector]);
	
	{	// Object Selector
		methodSelector = objectSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector]);
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Instance Selector
		methodSelector = instanceSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector]);
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
	
	{	// Instance Selector
		methodSelector = classSelector;
		
		XCTAssertFalse([dObject respondsToSelector:methodSelector]);
		XCTAssertNil([dObject methodSignatureForSelector:methodSelector]);
		
		XCTAssertFalse([dObject.class instancesRespondToSelector:methodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:methodSelector]);
		XCTAssertFalse([dObject.class respondsToSelector:methodSelector]);
		XCTAssertNil([dObject.class methodSignatureForSelector:methodSelector]);
	}
}




#pragma mark - NSDynamicObject

- (void)testNSDynamicObject_methodSignatureForSelector_preexistingMethod
{
	NSDynamicObject *dObject = NSDynamicObject.new;
	
	NSMethodSignature *signature = [dObject methodSignatureForSelector:@selector(init)];
	
	XCTAssertNotNil(signature);
	XCTAssertEqual(signature.numberOfArguments, 2);
	XCTAssertTrue([signature methodReturnType] != 0);
	XCTAssertEqual([signature methodReturnLength], sizeof(id));
	if ([signature methodReturnType]) {
		XCTAssertEqual([signature methodReturnType][0], @encode(id)[0]);
	}
}


- (void)testNSDynamicObject_methodSignatureForSelector_nonexistentMethod
{
	NSDynamicObject *dObject = NSDynamicObject.new;
	
	SEL dynamicMethodSelector = NSSelectorFromString(@"nonDynamicMethodSignatureForSelector:");
	
	NSMethodSignature *signature = [dObject methodSignatureForSelector:dynamicMethodSelector];
	
	XCTAssertNil(signature);
}


- (void)testNSDynamicObject_methodSignatureForSelector_object
{
	NSDynamicObject *dObject = NSDynamicObject.new;
	
	SEL dynamicMethodSelector = NSSelectorFromString(@"myDynamicMethodSignatureForSelector:");
	
	XCTAssertTrue([dObject addObjectMethod:dynamicMethodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 2);
	}
	]);
	
	NSMethodSignature *signature = [dObject methodSignatureForSelector:dynamicMethodSelector];
	XCTAssertNotNil(signature);
	XCTAssertTrue([signature methodReturnType] != 0);
	if ([signature methodReturnType] != 0)
		XCTAssertEqual([signature methodReturnType][0], @encode(id)[0]);
	XCTAssertEqual([signature methodReturnLength], sizeof(long));
	
	XCTAssertEqual(signature.numberOfArguments, 3);
	if (signature.numberOfArguments == 3) {
		XCTAssertEqual([signature getArgumentTypeAtIndex:0][0], @encode(id)[0]);
		XCTAssertEqual([signature getArgumentTypeAtIndex:1][0], @encode(SEL)[0]);
		XCTAssertEqual([signature getArgumentTypeAtIndex:2][0]
					   , @encode(id)[0]);
		
	}
	XCTAssertNil([dObject.class methodSignatureForSelector:dynamicMethodSelector]);
}


- (void)testNSDynamicObject_methodSignatureForSelector_instance
{
	NSDynamicObject *dObject = NSDynamicObject.new;
	
	SEL dynamicMethodSelector = NSSelectorFromString(@"myDynamicClassMethodSignatureForSelector:");
	
	XCTAssertTrue([dObject.class addInstanceMethod:dynamicMethodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 2);
	}
	]);
	
	NSMethodSignature *signature = [dObject methodSignatureForSelector:dynamicMethodSelector];
	XCTAssertNotNil(signature);
	XCTAssertTrue([signature methodReturnType] != 0);
	if ([signature methodReturnType] != 0)
		XCTAssertEqual([signature methodReturnType][0], @encode(id)[0]);
	XCTAssertEqual([signature methodReturnLength], sizeof(long));
	
	XCTAssertEqual(signature.numberOfArguments, 3);
	if (signature.numberOfArguments == 3) {
		XCTAssertEqual([signature getArgumentTypeAtIndex:0][0], @encode(id)[0]);
		XCTAssertEqual([signature getArgumentTypeAtIndex:1][0], @encode(SEL)[0]);
		XCTAssertEqual([signature getArgumentTypeAtIndex:2][0], @encode(id)[0]);
	}
	
	signature = [dObject.class methodSignatureForSelector:dynamicMethodSelector];
	
	XCTAssertNil(signature);
	
	XCTAssertTrue([dObject.class removeInstanceMethod:dynamicMethodSelector]);
}

- (void)testNSDynamicObject_methodSignatureForSelector_class_override
{
	NSDynamicObject *dObject = NSDynamicObject.new;
	
	SEL dynamicMethodSelector = NSSelectorFromString(@"myClassMethod:");
	
	XCTAssertTrue([dObject.class addInstanceMethod:dynamicMethodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 2);
	}
	]);
	
	NSMethodSignature *signature = [dObject methodSignatureForSelector:dynamicMethodSelector];
	XCTAssertNotNil(signature);
	XCTAssertTrue([signature methodReturnType] != 0);
	if ([signature methodReturnType] != 0)
		XCTAssertEqual([signature methodReturnType][0], @encode(id)[0]);
	XCTAssertEqual([signature methodReturnLength], sizeof(long));
	
	XCTAssertEqual(signature.numberOfArguments, 3);
	if (signature.numberOfArguments == 3) {
		XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
		XCTAssertEqual([signature getArgumentTypeAtIndex:1][0], @encode(SEL)[0]);
		XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:2], @"@\"NSNumber\"");
	}
	
	id instanceBlock = ^NSString*(id _self, NSString* input) {
		return [NSString stringWithFormat:@"%d", input.intValue * 2];
	};
	
	
	//Object overrides instance selector-block
	XCTAssertTrue([dObject addObjectMethod:dynamicMethodSelector block:instanceBlock]);
	
	signature = [dObject methodSignatureForSelector:dynamicMethodSelector];
	XCTAssertNotNil(signature);
	XCTAssertTrue([signature methodReturnType] != 0);
	if ([signature methodReturnType] != 0)
		XCTAssertEqual([signature methodReturnType][0], @encode(id)[0]);
	XCTAssertEqual([signature methodReturnLength], sizeof(long));
	
	XCTAssertEqual(signature.numberOfArguments, 3);
	if (signature.numberOfArguments == 3) {
		XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
		XCTAssertEqual([signature getArgumentTypeAtIndex:1][0], @encode(SEL)[0]);
		XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:2], @"@\"NSString\"");
	}
	
	
	signature = [dObject.class methodSignatureForSelector:dynamicMethodSelector];
	XCTAssertNil(signature);
	
	XCTAssertTrue([dObject.class removeInstanceMethod:dynamicMethodSelector]);
	
	signature = [dObject methodSignatureForSelector:dynamicMethodSelector];
	XCTAssertNotNil(signature);
	XCTAssertTrue([signature methodReturnType] != 0);
	if ([signature methodReturnType] != 0)
		XCTAssertEqual([signature methodReturnType][0], @encode(id)[0]);
	XCTAssertEqual([signature methodReturnLength], sizeof(long));
	
	XCTAssertEqual(signature.numberOfArguments, 3);
	if (signature.numberOfArguments == 3) {
		XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:0], @"@");
		XCTAssertEqual([signature getArgumentTypeAtIndex:1][0], @encode(SEL)[0]);
		XCTAssertEqualObjects([signature getArgumentTypeStringAtIndex:2], @"@\"NSString\"");
	}
}


- (void)testNSDynamicObject_forwardInvocation_instance
{
	NSDynamicObject *dObject = NSDynamicObject.new;
	
	SEL dynamicMethodSelector = NSSelectorFromString(@"myDynamicForwardInvocation:");
	
	XCTAssertTrue([dObject addObjectMethod:dynamicMethodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 2);
	}
	]);
	
	//This calls ForwardInvocation
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	
	NSNumber *result = [dObject performSelector:dynamicMethodSelector withObject:@5];
	
#pragma clang diagnostic pop
	
	XCTAssertEqualObjects(result, @10);
}


- (void)testNSDynamicObject_forwardInvocation_class
{
	NSDynamicObject *dObject = NSDynamicObject.new;
	
	SEL dynamicMethodSelector = NSSelectorFromString(@"myDynamicClassForwardInvocation:");
	
	XCTAssertTrue([dObject.class addInstanceMethod:dynamicMethodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 3);
	}
	]);
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	
	//This calls ForwardInvocation
	NSNumber *result = [dObject performSelector:dynamicMethodSelector withObject:@5];
	XCTAssertEqualObjects(result, @15);
	
	
	// Instance Dynamic Method overrides Class
	XCTAssertTrue([dObject addObjectMethod:dynamicMethodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 2);
	}
	]);
	
	result = [dObject performSelector:dynamicMethodSelector withObject:@5];
	XCTAssertEqualObjects(result, @10);
	
	XCTAssertTrue([dObject removeObjectMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject removeObjectMethod:dynamicMethodSelector]);
	
	result = [dObject performSelector:dynamicMethodSelector withObject:@5];
	XCTAssertEqualObjects(result, @15);
	
	XCTAssertTrue([dObject addObjectMethod:dynamicMethodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 2);
	}
	]);
	
	result = [dObject performSelector:dynamicMethodSelector withObject:@5];
	XCTAssertEqualObjects(result, @10);
	
	XCTAssertTrue([dObject.class removeInstanceMethod:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class removeInstanceMethod:dynamicMethodSelector]);
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	
	result = [dObject performSelector:dynamicMethodSelector withObject:@5];
	XCTAssertEqualObjects(result, @10);
	
#pragma clang diagnostic pop
	
	XCTAssertTrue([dObject removeObjectMethod:dynamicMethodSelector]);
}

- (void)testNSDynamicObject_forwardInvocation_nonMethod
{
	NSDynamicObject *dObject = NSDynamicObject.new;
	
	SEL nonSelector = NSSelectorFromString(@"nonexistingMethod:");
	
	XCTAssertThrowsSpecificNamed([dObject performSelector:nonSelector withObject:@100], NSException,
								 NSInvalidArgumentException);
	
#pragma clang diagnostic pop
}


- (void)testNSDynamicObject_respondsToSelector_instance
{
	NSDynamicObject *dObject = NSDynamicObject.new;
	
	XCTAssertTrue([dObject respondsToSelector:@selector(init)]);
	
	SEL dynamicMethodSelector = NSSelectorFromString(@"myDynamicRespondsToSelector:");
	XCTAssertFalse([dObject respondsToSelector:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:dynamicMethodSelector]);
	
	{	// Check class instances* methods
		XCTAssertFalse([dObject.class instancesRespondToSelector:dynamicMethodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:dynamicMethodSelector]);
		XCTAssertNotEqual([dObject.class instanceMethodForSelector:dynamicMethodSelector], (void*)0);
	}	// end check
	
	XCTAssertTrue([dObject addObjectMethod:dynamicMethodSelector block:^NSNumber*(id _self, NSNumber* input) {
		return @(input.intValue * 2);
	}
	]);
	
	{	// Check class instances* methods
		XCTAssertFalse([dObject.class instancesRespondToSelector:dynamicMethodSelector]);
		XCTAssertNil([dObject.class instanceMethodSignatureForSelector:dynamicMethodSelector]);
		XCTAssertNotEqual([dObject.class instanceMethodForSelector:dynamicMethodSelector], (void*)0);
	}	// end check
	
	XCTAssertTrue([dObject respondsToSelector:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:dynamicMethodSelector]);
	XCTAssertTrue([dObject respondsToSelector:@selector(init)]);
	
	XCTAssertTrue([dObject removeObjectMethod:dynamicMethodSelector]);
	
	XCTAssertFalse([dObject respondsToSelector:dynamicMethodSelector]);
	XCTAssertFalse([dObject.class respondsToSelector:dynamicMethodSelector]);
}



#pragma mark - NewDynamicObject Normal forwardInvocation



- (void)testNewDynamicObject_forwardInvocation_argumentsRetained
{
	NewDynamicObject *ndObject = NewDynamicObject.new;
	NSObject *argObject = NSObject.new;
	
	__block id parameterObject = nil;
	
	XCTAssertTrue([ndObject addObjectMethod:@selector(argumentsRetainedMethod:) block:^(id _self, SEL __cmd, id argObject) {
		parameterObject = argObject;
	}]);
	
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[ndObject methodSignatureForSelector:@selector(argumentsRetainedMethod:)]];
	invocation.target = ndObject;
	invocation.selector = @selector(argumentsRetainedMethod:);
	
	[invocation setArgument:&argObject atIndex:2];
	[invocation retainArguments];
	
	[ndObject forwardInvocation:invocation];
}


#pragma mark - NewDynamicObject Normal forwardInvocation

- (void)testNewDynamicObject_normalNonDynamicForwardInvocation
{
	NewDynamicObject *ndObject = NewDynamicObject.new;
	
	XCTAssertThrowsSpecificNamed([ndObject performSelector:@selector(optionalMethod)], NSException,
								 NSInvalidArgumentException);
}

/*
#pragma mark - NSDynamicObject class method (not an instance method)


- (void)testNewDynamicObject_classMethod
{
	__block int returnValue = 311113;
	SEL selector = NSSelectorFromString(@"dynamicProperty");
	XCTAssertTrue([NewDynamicObject addObjectMethod:selector block:^NSNumber*(id __self) {
		return @(returnValue);
	}]);
	NSNumber *result = [NewDynamicObject performSelector:selector];
	
	XCTAssertNotNil(result);
	XCTAssertEqual(result.intValue, returnValue);
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	
	// Check an instance
	NewDynamicObject *dObject = NewDynamicObject.new;
	[dObject performSelector:selector]; // should error
	
#pragma clang diagnostic pop
}
 */


@end

/*
 
 
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
 
 // performSelector
 
 #pragma clang diagnostic pop
 
 */
