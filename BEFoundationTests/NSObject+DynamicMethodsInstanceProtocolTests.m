//
//  NSObject+DynamicMethodsTest.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import <BEFoundation/NSObject+DynamicMethods.h>





@protocol MyDMInstanceNoMethodProtocol
@end

@protocol MySubDMInstanceNoMethodProtocol <MyDMInstanceNoMethodProtocol>
@end

@protocol MySubSubDMInstanceNoMethodProtocol <MySubDMInstanceNoMethodProtocol>
@end




@protocol MyDMInstanceRequiredMethodProtocol
- (NSNumber*)protocolObjectMethod;
@end
@protocol MyDMSubInstanceRequiredMethodProtocol <MyDMInstanceRequiredMethodProtocol>
@end
@protocol MyDMSubSubInstanceRequiredMethodProtocol <MyDMSubInstanceRequiredMethodProtocol>
@end


@protocol MyDMInstanceClassRequiredMethodProtocol
+ (NSNumber*)protocolClassMethod;
@end
@protocol MyDMSubInstanceClassRequiredMethodProtocol <MyDMInstanceClassRequiredMethodProtocol>
@end
@protocol MyDMSubSubInstanceClassRequiredMethodProtocol <MyDMSubInstanceClassRequiredMethodProtocol>
@end


@protocol MyDMInstanceOptionalMethodProtocol
@optional
- (NSNumber*)protocolOptionalObjectMethod;
@end
@protocol MyDMSubInstanceOptionalMethodProtocol <MyDMInstanceOptionalMethodProtocol>
@end
@protocol MyDMSubSubInstanceOptionalMethodProtocol <MyDMSubInstanceOptionalMethodProtocol>
@end


@protocol MyDMInstanceClassOptionalMethodProtocol
@optional
+ (NSNumber*)protocolOptionalClassMethod;
@end
@protocol MyDMSubInstanceClassOptionalMethodProtocol <MyDMInstanceClassOptionalMethodProtocol>
@end
@protocol MyDMSubSubInstanceClassOptionalMethodProtocol <MyDMSubInstanceClassOptionalMethodProtocol>
@end




@interface InstanceBaseProtocolTargetObject : NSObject
@end
@implementation InstanceBaseProtocolTargetObject
@end

@interface InstanceGrandParentProtocolTargetObject : InstanceBaseProtocolTargetObject
@end
@implementation InstanceGrandParentProtocolTargetObject
@end

@interface InstanceParentProtocolTargetObject : InstanceGrandParentProtocolTargetObject
@end
@implementation InstanceParentProtocolTargetObject
@end

@interface InstanceProtocolMainTargetObject : InstanceParentProtocolTargetObject
@end
@implementation InstanceProtocolMainTargetObject
@end

@interface InstanceProtocolChildTargetObject : InstanceProtocolMainTargetObject
@end
@implementation InstanceProtocolChildTargetObject
@end

@interface InstanceProtocolGrandChildTargetObject : InstanceProtocolChildTargetObject
@end
@implementation InstanceProtocolGrandChildTargetObject
@end


@protocol InstanceBaseTestProtocol
- (NSNumber*)baseNumber;
+ (NSNumber*)baseClassNumber;
@end
@protocol InstanceGrandParentTestProtocol
- (NSNumber*)gpNumber;
+ (NSNumber*)gpClassNumber;
@end
@protocol InstanceParentTestProtocol
- (NSNumber*)pNumber;
+ (NSNumber*)pClassNumber;
@end
@protocol InstanceMainTestProtocol
- (NSNumber*)mNumber;
+ (NSNumber*)mClassNumber;
@end
@protocol InstanceChildTestProtocol
- (NSNumber*)cNumber;
+ (NSNumber*)cClassNumber;
@end
@protocol InstanceGrandChildTestProtocol
- (NSNumber*)gcNumber;
+ (NSNumber*)gcClassNumber;
@end



@interface IMPInstanceBaseTestObject : NSObject
@end
@implementation IMPInstanceBaseTestObject
- (NSNumber*)baseNumber {return @(10);}
+ (NSNumber*)baseClassNumber {return @(1010);}
@end
@interface IMPInstanceGPTestObject : NSObject
@end
@implementation IMPInstanceGPTestObject
- (NSNumber*)gpNumber {return @(20);}
+ (NSNumber*)gpClassNumber {return @(1020);}
@end
@interface IMPInstancePTestObject : NSObject
@end
@implementation IMPInstancePTestObject
- (NSNumber*)pNumber {return @(30);}
+ (NSNumber*)pClassNumber {return @(1030);}
@end
@interface IMPInstanceMTestObject : NSObject
@end
@implementation IMPInstanceMTestObject
- (NSNumber*)mNumber {return @(40);}
+ (NSNumber*)mClassNumber {return @(1040);}
@end
@interface IMPInstanceCTestObject : NSObject
@end
@implementation IMPInstanceCTestObject
- (NSNumber*)cNumber {return @(50);}
+ (NSNumber*)cClassNumber {return @(1050);}
@end
@interface IMPInstanceGCTestObject : NSObject
@end
@implementation IMPInstanceGCTestObject
- (NSNumber*)gcNumber {return @(60);}
+ (NSNumber*)gcClassNumber {return @(1060);}
@end






@interface ProtocolIMPRequiredInstanceMethod : NSObject <MyDMInstanceRequiredMethodProtocol>
@end
@implementation ProtocolIMPRequiredInstanceMethod
- (NSNumber*)protocolObjectMethod
{
	return @(30);
}

- (NSNumber*)objectMethod
{
	return @(31);
}
@end

@interface ProtocolIMPRequiredInstanceClassMethod : NSObject <MyDMInstanceClassRequiredMethodProtocol>
@end
@implementation ProtocolIMPRequiredInstanceClassMethod
+ (NSNumber*)protocolClassMethod
{
	return @(40);
}
+ (NSNumber*)classMethod
{
	return @(41);
}
@end




@interface ProtocolIMPOptionalInstanceMethod : NSObject <MyDMInstanceOptionalMethodProtocol>
@end
@implementation ProtocolIMPOptionalInstanceMethod

- (NSNumber*)protocolOptionalObjectMethod
{
	return @(130);
}
- (NSNumber*)optionalObjectMethod
{
	return @(131);
}
@end

@interface ProtocolIMPOptionalInstanceClassMethod : NSObject <MyDMInstanceClassOptionalMethodProtocol>
@end
@implementation ProtocolIMPOptionalInstanceClassMethod
+ (NSNumber*)protocolOptionalClassMethod
{
	return @(140);
}
+ (NSNumber*)optionalClassMethod
{
	return @(141);
}
@end






@protocol MyDMGeneralInstanceProtocol
- (NSNumber*)protocolObjectMethod;
+ (NSNumber*)protocolClassMethod;
@optional
- (NSNumber*)protocolOptionalObjectMethod;
+ (NSNumber*)protocolOptionalClassMethod;
@end
@protocol MyDMSubGeneralInstanceProtocol <MyDMGeneralInstanceProtocol>
@end
@protocol MyDMSubSubGeneralInstanceProtocol <MyDMSubGeneralInstanceProtocol>
@end




@interface ProtocolIMPGeneralInstanceMethod : NSObject <MyDMGeneralInstanceProtocol>
@end
@implementation ProtocolIMPGeneralInstanceMethod
- (NSNumber*)protocolObjectMethod
{
	return @(30);
}

- (NSNumber*)objectMethod
{
	return @(31);
}

+ (NSNumber*)protocolClassMethod
{
	return @(40);
}
+ (NSNumber*)classMethod
{
	return @(41);
}

- (NSNumber*)protocolOptionalObjectMethod
{
	return @(130);
}
- (NSNumber*)optionalObjectMethod
{
	return @(131);
}

+ (NSNumber*)protocolOptionalClassMethod
{
	return @(140);
}
+ (NSNumber*)optionalClassMethod
{
	return @(141);
}
@end

@interface IMPWithOriginalObjectMethod : NSObject <NSProtocolImpClass>
@property (nonatomic) id originalObject;
- (void)setOriginalObject:(id _Nonnull)object;
@end
@implementation IMPWithOriginalObjectMethod
@synthesize originalObject = _originalObject;

- (id)originalObject
{
	return _originalObject;
}

- (void)setOriginalObject:(id _Nonnull)object
{
	_originalObject = object;
}
@end





#pragma mark - NSObject Dynamic Methods Tests


@interface NSDynamicMethodsInstanceProtocolTests : XCTestCase

@end


@implementation NSDynamicMethodsInstanceProtocolTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


- (void)test_addRemoveInstanceProtocol_noProtocol
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *childObject = InstanceParentProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	XCTAssertEqual([InstanceParentProtocolTargetObject isDynamicMethodsEnabled], DMInheritEnabled);
	
	XCTAssertNil([object.class methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertFalse([object.class respondsToSelector:@selector(classMethod)]);
	XCTAssertNil([object.class instanceMethodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object.class instancesRespondToSelector:@selector(objectMethod)]);
	XCTAssertNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(objectMethod)]);
	XCTAssertNil([childObject methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([childObject respondsToSelector:@selector(objectMethod)]);
	
	XCTAssertNil([InstanceParentProtocolTargetObject methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertFalse([InstanceParentProtocolTargetObject respondsToSelector:@selector(classMethod)]);
	XCTAssertNil([InstanceParentProtocolTargetObject instanceMethodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([InstanceParentProtocolTargetObject instancesRespondToSelector:@selector(objectMethod)]);
	
	
	XCTAssertTrue([object.class addInstanceForwardClass:ProtocolIMPGeneralInstanceMethod.class]);
	XCTAssertNotNil([object.class methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertTrue([object.class respondsToSelector:@selector(classMethod)]);
	XCTAssertNotNil([object.class instanceMethodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertTrue([object.class instancesRespondToSelector:@selector(objectMethod)]);
	XCTAssertNotNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(objectMethod)]);
	XCTAssertNotNil([childObject methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertTrue([childObject respondsToSelector:@selector(objectMethod)]);
	
	XCTAssertNotNil([InstanceParentProtocolTargetObject methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertTrue([InstanceParentProtocolTargetObject respondsToSelector:@selector(classMethod)]);
	XCTAssertNotNil([InstanceParentProtocolTargetObject instanceMethodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertTrue([InstanceParentProtocolTargetObject instancesRespondToSelector:@selector(objectMethod)]);
	
	
	NSNumber *objectResult = nil;
	XCTAssertNoThrow(objectResult = [object performSelector:@selector(objectMethod)]);
	XCTAssertEqualObjects(objectResult, @(31));
	
	NSNumber *classResult = nil;
	XCTAssertNoThrow(classResult = [object.class performSelector:@selector(classMethod)]);
	XCTAssertEqualObjects(classResult, @(41));
	
	
	XCTAssertTrue([object.class removeInstanceForwardClass:ProtocolIMPGeneralInstanceMethod.class]);
	XCTAssertNil([object.class methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertFalse([object.class respondsToSelector:@selector(classMethod)]);
	XCTAssertNil([object.class instanceMethodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object.class instancesRespondToSelector:@selector(objectMethod)]);
	XCTAssertNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(objectMethod)]);
	XCTAssertNil([childObject methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([childObject respondsToSelector:@selector(objectMethod)]);
	
	XCTAssertNil([InstanceParentProtocolTargetObject methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertFalse([InstanceParentProtocolTargetObject respondsToSelector:@selector(classMethod)]);
	XCTAssertNil([InstanceParentProtocolTargetObject instanceMethodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([InstanceParentProtocolTargetObject instancesRespondToSelector:@selector(objectMethod)]);
	
	XCTAssertTrue([object.class resetDynamicMethods]);
	XCTAssertEqual([InstanceParentProtocolTargetObject isDynamicMethodsEnabled], DMInheritNone);
}

- (void)test_addRemoveInstanceProtocol_noMethod
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)test_addRemoveInstanceSubProtocol_noMethod
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)test_addRemoveInstanceSubSubProtocol_noMethod
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}


- (void)test_addRemoveInstanceProtocol_object_required
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	//	ProtocolIMPRequiredInstanceMethod *target = ProtocolIMPRequiredInstanceMethod.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol) withClass:ProtocolIMPRequiredInstanceMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolObjectMethod)]);
	XCTAssertNotNil([mainObject methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertTrue([mainObject respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(objectMethod)]);
	XCTAssertNil([mainObject methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([mainObject respondsToSelector:@selector(objectMethod)]);
	
	NSNumber *result = nil;
	
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(result, @(30));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(result, @(30));
	XCTAssertThrowsSpecificNamed([mainObject performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	
	
	
	XCTAssertFalse([object.class removeInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol) withClass:ProtocolIMPRequiredInstanceClassMethod.class]);
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol) withClass:ProtocolIMPRequiredInstanceMethod.class]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)test_addRemoveInstanceSubProtocol_object_required
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol) withClass:ProtocolIMPRequiredInstanceMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolObjectMethod)]);
	XCTAssertNotNil([mainObject methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertTrue([mainObject respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(objectMethod)]);
	XCTAssertNil([mainObject methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([mainObject respondsToSelector:@selector(objectMethod)]);
	
	
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(result, @(30));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(result, @(30));
	XCTAssertThrowsSpecificNamed([mainObject performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)test_addRemoveInstanceSubSubProtocol_object_required
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol) withClass:ProtocolIMPRequiredInstanceMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolObjectMethod)]);
	XCTAssertNotNil([mainObject methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertTrue([mainObject respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(objectMethod)]);
	XCTAssertNil([mainObject methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([mainObject respondsToSelector:@selector(objectMethod)]);
	
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(result, @(30));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(result, @(30));
	XCTAssertThrowsSpecificNamed([mainObject performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMSubSubInstanceRequiredMethodProtocol)]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}




- (void)test_addRemoveInstanceProtocol_object_optional
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	//ProtocolIMPOptionalInstanceMethod *target = ProtocolIMPRequiredInstanceMethod.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMInstanceOptionalMethodProtocol) withClass:ProtocolIMPOptionalInstanceMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertNotNil([mainObject methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertTrue([mainObject respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(objectMethod)]);
	XCTAssertNil([mainObject methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([mainObject respondsToSelector:@selector(objectMethod)]);
	
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertEqualObjects(result, @(130));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject performSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertEqualObjects(result, @(130));
	XCTAssertThrowsSpecificNamed([mainObject performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	
	XCTAssertFalse([object.class removeInstanceProtocol:@protocol(MyDMInstanceOptionalMethodProtocol) withClass:ProtocolIMPOptionalInstanceClassMethod.class]);
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMInstanceOptionalMethodProtocol) withClass:ProtocolIMPOptionalInstanceMethod.class]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}


- (void)test_addRemoveInstanceSubProtocol_object_optional
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol) withClass:ProtocolIMPOptionalInstanceMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertNotNil([mainObject methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertTrue([mainObject respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(objectMethod)]);
	XCTAssertNil([mainObject methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([mainObject respondsToSelector:@selector(objectMethod)]);
	
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertEqualObjects(result, @(130));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject performSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertEqualObjects(result, @(130));
	XCTAssertThrowsSpecificNamed([mainObject performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)test_addRemoveInstanceSubSubProtocol_object_optional
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol) withClass:ProtocolIMPOptionalInstanceMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubInstanceOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertNotNil([mainObject methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertTrue([mainObject respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(objectMethod)]);
	XCTAssertNil([mainObject methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([mainObject respondsToSelector:@selector(objectMethod)]);
	
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertEqualObjects(result, @(130));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject performSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertEqualObjects(result, @(130));
	XCTAssertThrowsSpecificNamed([mainObject performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMSubSubInstanceOptionalMethodProtocol)]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}





- (void)test_addRemoveInstanceProtocol_class_required
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	//ProtocolIMPRequiredInstanceMethod *target = ProtocolIMPRequiredInstanceMethod.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol) withClass:ProtocolIMPRequiredInstanceClassMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	
	XCTAssertNotNil([object.class methodSignatureForSelector:@selector(protocolClassMethod)]);
	XCTAssertTrue([object.class respondsToSelector:@selector(protocolClassMethod)]);
	XCTAssertNotNil([mainObject.class methodSignatureForSelector:@selector(protocolClassMethod)]);
	XCTAssertTrue([mainObject.class respondsToSelector:@selector(protocolClassMethod)]);
	
	XCTAssertNil([object.class methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertFalse([object.class respondsToSelector:@selector(classMethod)]);
	XCTAssertNil([mainObject.class methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertFalse([mainObject.class respondsToSelector:@selector(classMethod)]);
	
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object.class performSelector:@selector(protocolClassMethod)]);
	XCTAssertEqualObjects(result, @(40));
	XCTAssertThrowsSpecificNamed([object.class performSelector:@selector(classMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject.class performSelector:@selector(protocolClassMethod)]);
	XCTAssertEqualObjects(result, @(40));
	XCTAssertThrowsSpecificNamed([mainObject.class performSelector:@selector(classMethod)], NSException, NSInvalidArgumentException);
	
	
	XCTAssertFalse([object.class removeInstanceProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol) withClass: ProtocolIMPRequiredInstanceMethod.class]);
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol) withClass:ProtocolIMPRequiredInstanceClassMethod.class]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)test_addRemoveInstanceSubProtocol_class_required
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol) withClass:ProtocolIMPRequiredInstanceClassMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	
	XCTAssertNotNil([object.class methodSignatureForSelector:@selector(protocolClassMethod)]);
	XCTAssertTrue([object.class respondsToSelector:@selector(protocolClassMethod)]);
	XCTAssertNotNil([mainObject.class methodSignatureForSelector:@selector(protocolClassMethod)]);
	XCTAssertTrue([mainObject.class respondsToSelector:@selector(protocolClassMethod)]);
	
	XCTAssertNil([object.class methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertFalse([object.class respondsToSelector:@selector(classMethod)]);
	XCTAssertNil([mainObject.class methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertFalse([mainObject.class respondsToSelector:@selector(classMethod)]);
	
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object.class performSelector:@selector(protocolClassMethod)]);
	XCTAssertEqualObjects(result, @(40));
	XCTAssertThrowsSpecificNamed([object.class performSelector:@selector(classMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject.class performSelector:@selector(protocolClassMethod)]);
	XCTAssertEqualObjects(result, @(40));
	XCTAssertThrowsSpecificNamed([mainObject.class performSelector:@selector(classMethod)], NSException, NSInvalidArgumentException);
	
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)test_addRemoveInstanceSubSubProtocol_class_required
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol) withClass:ProtocolIMPRequiredInstanceClassMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubInstanceClassRequiredMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	
	XCTAssertNotNil([object.class methodSignatureForSelector:@selector(protocolClassMethod)]);
	XCTAssertTrue([object.class respondsToSelector:@selector(protocolClassMethod)]);
	XCTAssertNotNil([mainObject.class methodSignatureForSelector:@selector(protocolClassMethod)]);
	XCTAssertTrue([mainObject.class respondsToSelector:@selector(protocolClassMethod)]);
	
	XCTAssertNil([object.class methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(classMethod)]);
	XCTAssertNil([mainObject.class methodSignatureForSelector:@selector(classMethod)]);
	XCTAssertFalse([mainObject respondsToSelector:@selector(classMethod)]);
	
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object.class performSelector:@selector(protocolClassMethod)]);
	XCTAssertEqualObjects(result, @(40));
	XCTAssertThrowsSpecificNamed([object.class performSelector:@selector(classMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject.class performSelector:@selector(protocolClassMethod)]);
	XCTAssertEqualObjects(result, @(40));
	XCTAssertThrowsSpecificNamed([mainObject.class performSelector:@selector(classMethod)], NSException, NSInvalidArgumentException);
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMSubSubInstanceClassRequiredMethodProtocol)]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}




- (void)test_addRemoveInstanceProtocol_class_optional
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	//ProtocolIMPOptionalInstanceMethod *target = ProtocolIMPRequiredInstanceMethod.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol) withClass:ProtocolIMPOptionalInstanceClassMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	
	XCTAssertNotNil([object.class methodSignatureForSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertTrue([object.class respondsToSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertNotNil([mainObject.class methodSignatureForSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertTrue([mainObject.class respondsToSelector:@selector(protocolOptionalClassMethod)]);
	
	XCTAssertNil([object.class methodSignatureForSelector:@selector(optionalClassMethod)]);
	XCTAssertFalse([object.class respondsToSelector:@selector(optionalClassMethod)]);
	XCTAssertNil([mainObject.class methodSignatureForSelector:@selector(optionalClassMethod)]);
	XCTAssertFalse([mainObject.class respondsToSelector:@selector(optionalClassMethod)]);
	
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object.class performSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertEqualObjects(result, @(140));
	XCTAssertThrowsSpecificNamed([object.class performSelector:@selector(optionalClassMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject.class performSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertEqualObjects(result, @(140));
	XCTAssertThrowsSpecificNamed([mainObject.class performSelector:@selector(optionalClassMethod)], NSException, NSInvalidArgumentException);
	
	
	
	XCTAssertFalse([object.class removeInstanceProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol) withClass:ProtocolIMPOptionalInstanceMethod.class]);
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol) withClass:ProtocolIMPOptionalInstanceClassMethod.class]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)test_addRemoveInstanceSubProtocol_class_optional
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol) withClass:ProtocolIMPOptionalInstanceClassMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	
	XCTAssertNotNil([object.class methodSignatureForSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertTrue([object.class respondsToSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertNotNil([mainObject.class methodSignatureForSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertTrue([mainObject.class respondsToSelector:@selector(protocolOptionalClassMethod)]);
	
	XCTAssertNil([object.class methodSignatureForSelector:@selector(optionalClassMethod)]);
	XCTAssertFalse([object.class respondsToSelector:@selector(optionalClassMethod)]);
	XCTAssertNil([mainObject.class methodSignatureForSelector:@selector(optionalClassMethod)]);
	XCTAssertFalse([mainObject.class respondsToSelector:@selector(optionalClassMethod)]);
	
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object.class performSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertEqualObjects(result, @(140));
	XCTAssertThrowsSpecificNamed([object.class performSelector:@selector(optionalClassMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject.class performSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertEqualObjects(result, @(140));
	XCTAssertThrowsSpecificNamed([mainObject.class performSelector:@selector(optionalClassMethod)], NSException, NSInvalidArgumentException);
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)test_addRemoveInstanceSubSubProtocol_class_optional
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mainObject = InstanceProtocolMainTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol) withClass:ProtocolIMPOptionalInstanceClassMethod.class]);
	
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([object.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject.class conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubInstanceClassOptionalMethodProtocol)]);
	XCTAssertTrue([mainObject conformsToProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	
	XCTAssertNotNil([object.class methodSignatureForSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertTrue([object.class respondsToSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertNotNil([mainObject.class methodSignatureForSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertTrue([mainObject.class respondsToSelector:@selector(protocolOptionalClassMethod)]);
	
	XCTAssertNil([object.class methodSignatureForSelector:@selector(optionalClassMethod)]);
	XCTAssertFalse([object.class respondsToSelector:@selector(optionalClassMethod)]);
	XCTAssertNil([mainObject.class methodSignatureForSelector:@selector(optionalClassMethod)]);
	XCTAssertFalse([mainObject.class respondsToSelector:@selector(optionalClassMethod)]);
	
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object.class performSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertEqualObjects(result, @(140));
	XCTAssertThrowsSpecificNamed([object.class performSelector:@selector(optionalClassMethod)], NSException, NSInvalidArgumentException);
	
	result = nil;
	XCTAssertNoThrow(result = [mainObject.class performSelector:@selector(protocolOptionalClassMethod)]);
	XCTAssertEqualObjects(result, @(140));
	XCTAssertThrowsSpecificNamed([mainObject.class performSelector:@selector(optionalClassMethod)], NSException, NSInvalidArgumentException);
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMSubSubInstanceClassOptionalMethodProtocol)]);
	
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject.class conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MyDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubDMInstanceNoMethodProtocol)]);
	XCTAssertFalse([mainObject conformsToProtocol:@protocol(MySubSubDMInstanceNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}



- (void)test_synchronizing_methodSignatureForSelector_protocolClass
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *childObject = InstanceParentProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol) withClass:ProtocolIMPGeneralInstanceMethod.class]);
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertNotNil([childObject methodSignatureForSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertNil([childObject methodSignatureForSelector:@selector(protocolObjectMethod)]);
	
	
	XCTAssertTrue([object.class resetDynamicMethods]);
}

- (void)test_synchronizing_respondsToSelector_protocolClass
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *childObject = InstanceParentProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol) withClass:ProtocolIMPGeneralInstanceMethod.class]);
	
	XCTAssertTrue([object respondsToSelector:@selector(protocolObjectMethod)]);
	XCTAssertTrue([childObject respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	
	XCTAssertFalse([object respondsToSelector:@selector(protocolObjectMethod)]);
	XCTAssertFalse([childObject respondsToSelector:@selector(protocolObjectMethod)]);
	
	
	XCTAssertTrue([object.class resetDynamicMethods]);
}

- (void)test_synchronizing_conformsToProtocol_protocolClass
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *childObject = InstanceParentProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol) withClass:ProtocolIMPGeneralInstanceMethod.class]);
	
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertTrue([childObject conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([childObject conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	
	
	XCTAssertTrue([object.class resetDynamicMethods]);
	
}

- (void)test_synchronizing_forwardInvocation_protocolClass
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *childObject = InstanceParentProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol) withClass:ProtocolIMPGeneralInstanceMethod.class]);
	
	
	
	NSNumber *objectResult = nil;
	XCTAssertNoThrow(objectResult = [object performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(objectResult, @(30));
	
	objectResult = nil;
	
	XCTAssertNoThrow(objectResult = [childObject performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(objectResult, @(30));
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(protocolObjectMethod)], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([childObject performSelector:@selector(protocolObjectMethod)], NSException, NSInvalidArgumentException);
	
	
	XCTAssertTrue([object.class resetDynamicMethods]);
	
}

- (void)test_synchronizing_methodSignatureForSelector_noProtocol
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *childObject = InstanceParentProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertTrue([object.class addInstanceProtocol:nil withClass:ProtocolIMPGeneralInstanceMethod.class]);
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertNotNil([childObject methodSignatureForSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertTrue([object.class removeInstanceProtocol:nil withClass:ProtocolIMPGeneralInstanceMethod.class]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertNil([childObject methodSignatureForSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertTrue([object.class resetDynamicMethods]);
}

- (void)test_synchronizing_respondsToSelector_noProtocol
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *childObject = InstanceParentProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertTrue([object.class addInstanceProtocol:nil withClass:ProtocolIMPGeneralInstanceMethod.class]);
	
	XCTAssertTrue([object respondsToSelector:@selector(protocolObjectMethod)]);
	XCTAssertTrue([childObject respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertTrue([object.class removeInstanceProtocol:nil withClass:ProtocolIMPGeneralInstanceMethod.class]);
	
	XCTAssertFalse([object respondsToSelector:@selector(protocolObjectMethod)]);
	XCTAssertFalse([childObject respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertTrue([object.class resetDynamicMethods]);
}

- (void)test_synchronizing_conformsToProtocol_noProtocol
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *childObject = InstanceParentProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertTrue([object.class addInstanceProtocol:nil withClass:ProtocolIMPGeneralInstanceMethod.class]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([childObject conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([object.class removeInstanceProtocol:nil withClass:ProtocolIMPGeneralInstanceMethod.class]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	XCTAssertFalse([childObject conformsToProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	
	XCTAssertTrue([object.class resetDynamicMethods]);
	
}

- (void)test_synchronizing_forwardInvocation_noProtocol
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *childObject = InstanceParentProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertTrue([object.class addInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol) withClass:ProtocolIMPGeneralInstanceMethod.class]);
	
	
	
	NSNumber *objectResult = nil;
	XCTAssertNoThrow(objectResult = [object performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(objectResult, @(30));
	
	objectResult = nil;
	
	XCTAssertNoThrow(objectResult = [childObject performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(objectResult, @(30));
	
	
	XCTAssertTrue([object.class removeInstanceProtocol:@protocol(MyDMInstanceRequiredMethodProtocol)]);
	
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(protocolObjectMethod)], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([childObject performSelector:@selector(protocolObjectMethod)], NSException, NSInvalidArgumentException);
	
	
	XCTAssertTrue([object.class resetDynamicMethods]);
}


- (void)test_ProtocolClass_chain_BottomEnabled
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceGrandParentProtocolTargetObject *gpObject = InstanceGrandParentProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *pObject = InstanceParentProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mObject = InstanceProtocolMainTargetObject.new;
	InstanceProtocolChildTargetObject *cObject = InstanceProtocolChildTargetObject.new;
	InstanceProtocolGrandChildTargetObject *gcObject = InstanceProtocolGrandChildTargetObject.new;
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceParentProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceProtocolChildTargetObject enableDynamicMethods]);
	
	{
		XCTAssertFalse([object conformsToProtocol:@protocol(InstanceBaseTestProtocol)]);
		XCTAssertFalse([gpObject conformsToProtocol:@protocol(InstanceGrandParentTestProtocol)]);
		XCTAssertFalse([pObject conformsToProtocol:@protocol(InstanceParentTestProtocol)]);
		XCTAssertFalse([mObject conformsToProtocol:@protocol(InstanceMainTestProtocol)]);
		XCTAssertFalse([cObject conformsToProtocol:@protocol(InstanceChildTestProtocol)]);
		XCTAssertFalse([gcObject conformsToProtocol:@protocol(InstanceGrandChildTestProtocol)]);
	}
	
	{	//	Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	
	{	//	Protocols
		Protocol *protocol = @protocol(InstanceBaseTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceMainTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject addInstanceProtocol:@protocol(InstanceBaseTestProtocol) withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject addInstanceProtocol:@protocol(InstanceGrandParentTestProtocol) withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject addInstanceProtocol:@protocol(InstanceParentTestProtocol) withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject addInstanceProtocol:@protocol(InstanceMainTestProtocol) withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject addInstanceProtocol:@protocol(InstanceChildTestProtocol) withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject addInstanceProtocol:@protocol(InstanceGrandChildTestProtocol) withClass:IMPInstanceGCTestObject.class]);
	
	XCTAssertFalse([InstanceBaseProtocolTargetObject addInstanceProtocol:@protocol(InstanceBaseTestProtocol) withClass:IMPInstanceBaseTestObject.class]);
	
	{	//	Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	
	{	// Protocols
		Protocol *protocol = @protocol(InstanceBaseTestProtocol);
		XCTAssertTrue([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertTrue([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceMainTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject disableDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	
	{	// Protocols
		Protocol *protocol = @protocol(InstanceBaseTestProtocol);
		XCTAssertTrue([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertTrue([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceMainTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject resetDynamicMethods]);
	
	{	//	Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	
	{	// Protocols
		Protocol *protocol = @protocol(InstanceBaseTestProtocol);
		XCTAssertTrue([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertTrue([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceMainTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject removeInstanceProtocol:@protocol(InstanceBaseTestProtocol)]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject removeInstanceProtocol:@protocol(InstanceGrandParentTestProtocol)]);
	XCTAssertTrue([InstanceParentProtocolTargetObject removeInstanceProtocol:@protocol(InstanceParentTestProtocol)]);
	XCTAssertTrue([InstanceProtocolMainTargetObject removeInstanceProtocol:@protocol(InstanceMainTestProtocol)]);
	XCTAssertTrue([InstanceProtocolChildTargetObject removeInstanceProtocol:@protocol(InstanceChildTestProtocol)]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject removeInstanceProtocol:nil withClass:IMPInstanceGCTestObject.class]);
	
	XCTAssertTrue([InstanceProtocolChildTargetObject resetDynamicMethods]);
	XCTAssertTrue([InstanceBaseProtocolTargetObject resetDynamicMethods]);
}

- (void)test_ProtocolClass_functional_BottomEnabled
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceGrandParentProtocolTargetObject *gpObject = InstanceGrandParentProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *pObject = InstanceParentProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mObject = InstanceProtocolMainTargetObject.new;
	InstanceProtocolChildTargetObject *cObject = InstanceProtocolChildTargetObject.new;
	InstanceProtocolGrandChildTargetObject *gcObject = InstanceProtocolGrandChildTargetObject.new;
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceParentProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceProtocolChildTargetObject enableDynamicMethods]);
	
	{
		XCTAssertFalse([object conformsToProtocol:@protocol(InstanceBaseTestProtocol)]);
		XCTAssertFalse([gpObject conformsToProtocol:@protocol(InstanceGrandParentTestProtocol)]);
		XCTAssertFalse([pObject conformsToProtocol:@protocol(InstanceParentTestProtocol)]);
		XCTAssertFalse([mObject conformsToProtocol:@protocol(InstanceMainTestProtocol)]);
		XCTAssertFalse([cObject conformsToProtocol:@protocol(InstanceChildTestProtocol)]);
		XCTAssertFalse([gcObject conformsToProtocol:@protocol(InstanceGrandChildTestProtocol)]);
	}
	
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject addInstanceProtocol:@protocol(InstanceBaseTestProtocol) withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject addInstanceProtocol:@protocol(InstanceGrandParentTestProtocol) withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject addInstanceProtocol:@protocol(InstanceParentTestProtocol) withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject addInstanceProtocol:@protocol(InstanceMainTestProtocol) withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject addInstanceProtocol:@protocol(InstanceChildTestProtocol) withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject addInstanceProtocol:@protocol(InstanceGrandChildTestProtocol) withClass:IMPInstanceGCTestObject.class]);
	
   #pragma clang diagnostic push
   #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	
	NSNumber *result = nil;
	
	{	//	Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(60));
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1060));
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject disableDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(60));
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject.class performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject.class performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1060));
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject resetDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(60));
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1060));
	}
	
	
   #pragma clang diagnostic pop
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject removeInstanceProtocol:@protocol(InstanceBaseTestProtocol)]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject removeInstanceProtocol:@protocol(InstanceGrandParentTestProtocol)]);
	XCTAssertTrue([InstanceParentProtocolTargetObject removeInstanceProtocol:@protocol(InstanceParentTestProtocol)]);
	XCTAssertTrue([InstanceProtocolMainTargetObject removeInstanceProtocol:@protocol(InstanceMainTestProtocol)]);
	XCTAssertTrue([InstanceProtocolChildTargetObject removeInstanceProtocol:@protocol(InstanceChildTestProtocol)]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject removeInstanceProtocol:@protocol(InstanceGrandChildTestProtocol)]);
	
	XCTAssertTrue([InstanceProtocolChildTargetObject resetDynamicMethods]);
	XCTAssertTrue([InstanceBaseProtocolTargetObject resetDynamicMethods]);
}



- (void)test_ProtocolClass_chain_BottomDisabled
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceGrandParentProtocolTargetObject *gpObject = InstanceGrandParentProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *pObject = InstanceParentProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mObject = InstanceProtocolMainTargetObject.new;
	InstanceProtocolChildTargetObject *cObject = InstanceProtocolChildTargetObject.new;
	InstanceProtocolGrandChildTargetObject *gcObject = InstanceProtocolGrandChildTargetObject.new;
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceParentProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceProtocolChildTargetObject disableDynamicMethods]);
	
	
	{
		XCTAssertFalse([object conformsToProtocol:@protocol(InstanceBaseTestProtocol)]);
		XCTAssertFalse([gpObject conformsToProtocol:@protocol(InstanceGrandParentTestProtocol)]);
		XCTAssertFalse([pObject conformsToProtocol:@protocol(InstanceParentTestProtocol)]);
		XCTAssertFalse([mObject conformsToProtocol:@protocol(InstanceMainTestProtocol)]);
		XCTAssertFalse([cObject conformsToProtocol:@protocol(InstanceChildTestProtocol)]);
		XCTAssertFalse([gcObject conformsToProtocol:@protocol(InstanceGrandChildTestProtocol)]);
	}
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	
	{	//	Protocols
		Protocol *protocol = @protocol(InstanceBaseTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceMainTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject.class conformsToProtocol:protocol]);
	}
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject addInstanceProtocol:@protocol(InstanceBaseTestProtocol) withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject addInstanceProtocol:@protocol(InstanceGrandParentTestProtocol) withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject addInstanceProtocol:@protocol(InstanceParentTestProtocol) withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject addInstanceProtocol:@protocol(InstanceMainTestProtocol) withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject addInstanceProtocol:@protocol(InstanceChildTestProtocol) withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject addInstanceProtocol:@protocol(InstanceGrandChildTestProtocol) withClass:IMPInstanceGCTestObject.class]);
	
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	
	{	// Protocols
		Protocol *protocol = @protocol(InstanceBaseTestProtocol);
		XCTAssertTrue([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertTrue([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceMainTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject disableDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	
	{	// Protocols
		Protocol *protocol = @protocol(InstanceBaseTestProtocol);
		XCTAssertTrue([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertTrue([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceMainTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject resetDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	
	{	// Protocols
		Protocol *protocol = @protocol(InstanceBaseTestProtocol);
		XCTAssertTrue([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertTrue([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertTrue([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceParentTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertTrue([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceMainTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertTrue([mObject conformsToProtocol:protocol]);
		XCTAssertTrue([cObject conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	{
		Protocol *protocol = @protocol(InstanceGrandChildTestProtocol);
		XCTAssertFalse([object conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject conformsToProtocol:protocol]);
		XCTAssertFalse([pObject conformsToProtocol:protocol]);
		XCTAssertFalse([mObject conformsToProtocol:protocol]);
		XCTAssertFalse([cObject conformsToProtocol:protocol]);
		XCTAssertFalse([gcObject conformsToProtocol:protocol]);
		
		XCTAssertFalse([object.class conformsToProtocol:protocol]);
		XCTAssertFalse([gpObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([pObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([mObject.class conformsToProtocol:protocol]);
		XCTAssertFalse([cObject.class conformsToProtocol:protocol]);
		XCTAssertTrue([gcObject.class conformsToProtocol:protocol]);
	}
	
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject removeInstanceProtocol:@protocol(InstanceBaseTestProtocol)]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject removeInstanceProtocol:@protocol(InstanceGrandParentTestProtocol)]);
	XCTAssertTrue([InstanceParentProtocolTargetObject removeInstanceProtocol:@protocol(InstanceParentTestProtocol)]);
	XCTAssertTrue([InstanceProtocolMainTargetObject removeInstanceProtocol:@protocol(InstanceMainTestProtocol)]);
	XCTAssertTrue([InstanceProtocolChildTargetObject removeInstanceProtocol:@protocol(InstanceChildTestProtocol)]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject removeInstanceProtocol:@protocol(InstanceGrandChildTestProtocol)]);
	
	XCTAssertTrue([InstanceProtocolChildTargetObject resetDynamicMethods]);
	XCTAssertTrue([InstanceBaseProtocolTargetObject resetDynamicMethods]);
}


- (void)test_ProtocolClass_functional_BottomDisabled
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceGrandParentProtocolTargetObject *gpObject = InstanceGrandParentProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *pObject = InstanceParentProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mObject = InstanceProtocolMainTargetObject.new;
	InstanceProtocolChildTargetObject *cObject = InstanceProtocolChildTargetObject.new;
	InstanceProtocolGrandChildTargetObject *gcObject = InstanceProtocolGrandChildTargetObject.new;
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceParentProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceProtocolChildTargetObject disableDynamicMethods]);
	
	{
		XCTAssertFalse([object conformsToProtocol:@protocol(InstanceBaseTestProtocol)]);
		XCTAssertFalse([gpObject conformsToProtocol:@protocol(InstanceGrandParentTestProtocol)]);
		XCTAssertFalse([pObject conformsToProtocol:@protocol(InstanceParentTestProtocol)]);
		XCTAssertFalse([mObject conformsToProtocol:@protocol(InstanceMainTestProtocol)]);
		XCTAssertFalse([cObject conformsToProtocol:@protocol(InstanceChildTestProtocol)]);
		XCTAssertFalse([gcObject conformsToProtocol:@protocol(InstanceGrandChildTestProtocol)]);
	}
	
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject addInstanceProtocol:@protocol(InstanceBaseTestProtocol) withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject addInstanceProtocol:@protocol(InstanceGrandParentTestProtocol) withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject addInstanceProtocol:@protocol(InstanceParentTestProtocol) withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject addInstanceProtocol:@protocol(InstanceMainTestProtocol) withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject addInstanceProtocol:@protocol(InstanceChildTestProtocol) withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject addInstanceProtocol:@protocol(InstanceGrandChildTestProtocol) withClass:IMPInstanceGCTestObject.class]);
	
   #pragma clang diagnostic push
   #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	
	NSNumber *result = nil;
	
	{	//	Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject disableDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject.class performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject.class performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject resetDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
   #pragma clang diagnostic pop
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject removeInstanceProtocol:@protocol(InstanceBaseTestProtocol)]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject removeInstanceProtocol:@protocol(InstanceGrandParentTestProtocol)]);
	XCTAssertTrue([InstanceParentProtocolTargetObject removeInstanceProtocol:@protocol(InstanceParentTestProtocol)]);
	XCTAssertTrue([InstanceProtocolMainTargetObject removeInstanceProtocol:@protocol(InstanceMainTestProtocol)]);
	XCTAssertTrue([InstanceProtocolChildTargetObject removeInstanceProtocol:@protocol(InstanceChildTestProtocol)]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject removeInstanceProtocol:@protocol(InstanceGrandChildTestProtocol)]);
	
	XCTAssertTrue([InstanceProtocolChildTargetObject resetDynamicMethods]);
	XCTAssertTrue([InstanceBaseProtocolTargetObject resetDynamicMethods]);
}




- (void)test_ClassOnly_chain_BottomEnabled
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceGrandParentProtocolTargetObject *gpObject = InstanceGrandParentProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *pObject = InstanceParentProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mObject = InstanceProtocolMainTargetObject.new;
	InstanceProtocolChildTargetObject *cObject = InstanceProtocolChildTargetObject.new;
	InstanceProtocolGrandChildTargetObject *gcObject = InstanceProtocolGrandChildTargetObject.new;
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceParentProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceProtocolChildTargetObject enableDynamicMethods]);
	
	{
		XCTAssertFalse([object conformsToProtocol:@protocol(InstanceBaseTestProtocol)]);
		XCTAssertFalse([gpObject conformsToProtocol:@protocol(InstanceGrandParentTestProtocol)]);
		XCTAssertFalse([pObject conformsToProtocol:@protocol(InstanceParentTestProtocol)]);
		XCTAssertFalse([mObject conformsToProtocol:@protocol(InstanceMainTestProtocol)]);
		XCTAssertFalse([cObject conformsToProtocol:@protocol(InstanceChildTestProtocol)]);
		XCTAssertFalse([gcObject conformsToProtocol:@protocol(InstanceGrandChildTestProtocol)]);
	}
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	

	
	XCTAssertTrue([InstanceBaseProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject addInstanceProtocol:nil withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject addInstanceProtocol:nil withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject addInstanceProtocol:nil withClass:IMPInstanceGCTestObject.class]);
	
	
	{
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject disableDynamicMethods]);
	
	{
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	
	
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject resetDynamicMethods]);
	
	{
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	
	
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject removeInstanceProtocol:nil withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject removeInstanceProtocol:nil withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject removeInstanceProtocol:nil withClass:IMPInstanceGCTestObject.class]);
	
	XCTAssertTrue([InstanceProtocolChildTargetObject resetDynamicMethods]);
	XCTAssertTrue([InstanceBaseProtocolTargetObject resetDynamicMethods]);
}

- (void)test_ClassOnly_functional_BottomEnabled
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceGrandParentProtocolTargetObject *gpObject = InstanceGrandParentProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *pObject = InstanceParentProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mObject = InstanceProtocolMainTargetObject.new;
	InstanceProtocolChildTargetObject *cObject = InstanceProtocolChildTargetObject.new;
	InstanceProtocolGrandChildTargetObject *gcObject = InstanceProtocolGrandChildTargetObject.new;
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceParentProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceProtocolChildTargetObject enableDynamicMethods]);
	
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject addInstanceProtocol:nil withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject addInstanceProtocol:nil withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject addInstanceProtocol:nil withClass:IMPInstanceGCTestObject.class]);
	
   #pragma clang diagnostic push
   #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	
	NSNumber *result = nil;
	
	{	//	Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(60));
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1060));
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject disableDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(60));
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject.class performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject.class performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1060));
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject resetDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(50));
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(60));
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1050));
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1060));
	}
	
	
   #pragma clang diagnostic pop
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject removeInstanceProtocol:nil withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject removeInstanceProtocol:nil withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject removeInstanceProtocol:nil withClass:IMPInstanceGCTestObject.class]);
	
	XCTAssertTrue([InstanceProtocolChildTargetObject resetDynamicMethods]);
	XCTAssertTrue([InstanceBaseProtocolTargetObject resetDynamicMethods]);
}



- (void)test_ClassOnly_chain_BottomDisabled
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceGrandParentProtocolTargetObject *gpObject = InstanceGrandParentProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *pObject = InstanceParentProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mObject = InstanceProtocolMainTargetObject.new;
	InstanceProtocolChildTargetObject *cObject = InstanceProtocolChildTargetObject.new;
	InstanceProtocolGrandChildTargetObject *gcObject = InstanceProtocolGrandChildTargetObject.new;
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceParentProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceProtocolChildTargetObject disableDynamicMethods]);
	
	{	//	Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject addInstanceProtocol:nil withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject addInstanceProtocol:nil withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject addInstanceProtocol:nil withClass:IMPInstanceGCTestObject.class]);
	
	XCTAssertFalse([InstanceBaseProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstanceBaseTestObject.class]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject disableDynamicMethods]);
	
	{	//	Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject resetDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		XCTAssertNotNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNotNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gpNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertTrue([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(pNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertTrue([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(mNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertTrue([mObject respondsToSelector:selector]);
		XCTAssertTrue([cObject respondsToSelector:selector]);
		XCTAssertTrue([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([mObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([cObject.class instancesRespondToSelector:selector]);
		XCTAssertTrue([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(cNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	{
		SEL selector = @selector(gcNumber);
		XCTAssertNil([object methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject methodSignatureForSelector:selector]);
		XCTAssertNil([pObject methodSignatureForSelector:selector]);
		XCTAssertNil([mObject methodSignatureForSelector:selector]);
		XCTAssertNil([cObject methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object respondsToSelector:selector]);
		XCTAssertFalse([gpObject respondsToSelector:selector]);
		XCTAssertFalse([pObject respondsToSelector:selector]);
		XCTAssertFalse([mObject respondsToSelector:selector]);
		XCTAssertFalse([cObject respondsToSelector:selector]);
		XCTAssertFalse([gcObject respondsToSelector:selector]);
		
		XCTAssertNil([object.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class instanceMethodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class instanceMethodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gpObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([pObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([mObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([cObject.class instancesRespondToSelector:selector]);
		XCTAssertFalse([gcObject.class instancesRespondToSelector:selector]);
	}
	
	
	
	{	//	class methods
		SEL selector = @selector(baseClassNumber);
		XCTAssertNotNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertTrue([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gpClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertTrue([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(pClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertTrue([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(mClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNotNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertTrue([mObject.class respondsToSelector:selector]);
		XCTAssertTrue([cObject.class respondsToSelector:selector]);
		XCTAssertTrue([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(cClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	{
		SEL selector = @selector(gcClassNumber);
		XCTAssertNil([object.class methodSignatureForSelector:selector]);
		XCTAssertNil([gpObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([pObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([mObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([cObject.class methodSignatureForSelector:selector]);
		XCTAssertNil([gcObject.class methodSignatureForSelector:selector]);
		
		XCTAssertFalse([object.class respondsToSelector:selector]);
		XCTAssertFalse([gpObject.class respondsToSelector:selector]);
		XCTAssertFalse([pObject.class respondsToSelector:selector]);
		XCTAssertFalse([mObject.class respondsToSelector:selector]);
		XCTAssertFalse([cObject.class respondsToSelector:selector]);
		XCTAssertFalse([gcObject.class respondsToSelector:selector]);
	}
	
	
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject removeInstanceProtocol:nil withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject removeInstanceProtocol:nil withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject removeInstanceProtocol:nil withClass:IMPInstanceGCTestObject.class]);
	
	XCTAssertTrue([InstanceProtocolChildTargetObject resetDynamicMethods]);
	XCTAssertTrue([InstanceBaseProtocolTargetObject resetDynamicMethods]);
}


- (void)test_ClassOnly_functional_BottomDisabled
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	InstanceGrandParentProtocolTargetObject *gpObject = InstanceGrandParentProtocolTargetObject.new;
	InstanceParentProtocolTargetObject *pObject = InstanceParentProtocolTargetObject.new;
	InstanceProtocolMainTargetObject *mObject = InstanceProtocolMainTargetObject.new;
	InstanceProtocolChildTargetObject *cObject = InstanceProtocolChildTargetObject.new;
	InstanceProtocolGrandChildTargetObject *gcObject = InstanceProtocolGrandChildTargetObject.new;
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceParentProtocolTargetObject enableDynamicMethods]);
	XCTAssertTrue([InstanceProtocolChildTargetObject disableDynamicMethods]);
	
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject addInstanceProtocol:nil withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject addInstanceProtocol:nil withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject addInstanceProtocol:nil withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject addInstanceProtocol:nil withClass:IMPInstanceGCTestObject.class]);
	
   #pragma clang diagnostic push
   #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	
	NSNumber *result = nil;
	
	{	//	Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject disableDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject.class performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject.class performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
	
	
	XCTAssertTrue([InstanceParentProtocolTargetObject resetDynamicMethods]);
	
	{	// Object Methods
		SEL selector = @selector(baseNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(10));
	}
	{
		SEL selector = @selector(gpNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(20));
	}
	{
		SEL selector = @selector(pNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(30));
	}
	{
		SEL selector = @selector(mNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject performSelector:selector]);
		XCTAssertEqualObjects(result, @(40));
	}
	{
		SEL selector = @selector(cNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcNumber);
		
		XCTAssertThrowsSpecificNamed([object performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
	{	//	Class Methods
		SEL selector = @selector(baseClassNumber);
		
		result = nil;
		XCTAssertNoThrow(result = [object.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1010));
	}
	{
		SEL selector = @selector(gpClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [gpObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1020));
	}
	{
		SEL selector = @selector(pClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [pObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1030));
	}
	{
		SEL selector = @selector(mClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		
		result = nil;
		XCTAssertNoThrow(result = [mObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [cObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
		
		result = nil;
		XCTAssertNoThrow(result = [gcObject.class performSelector:selector]);
		XCTAssertEqualObjects(result, @(1040));
	}
	{
		SEL selector = @selector(cClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	{
		SEL selector = @selector(gcClassNumber);
		
		XCTAssertThrowsSpecificNamed([object.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gpObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([pObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([mObject.class performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([cObject performSelector:selector], NSException, NSInvalidArgumentException);
		XCTAssertThrowsSpecificNamed([gcObject performSelector:selector], NSException, NSInvalidArgumentException);
	}
	
	
   #pragma clang diagnostic pop
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstanceBaseTestObject.class]);
	XCTAssertTrue([InstanceGrandParentProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstanceGPTestObject.class]);
	XCTAssertTrue([InstanceParentProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstancePTestObject.class]);
	XCTAssertTrue([InstanceProtocolMainTargetObject removeInstanceProtocol:nil withClass:IMPInstanceMTestObject.class]);
	XCTAssertTrue([InstanceProtocolChildTargetObject removeInstanceProtocol:nil withClass:IMPInstanceCTestObject.class]);
	XCTAssertTrue([InstanceProtocolGrandChildTargetObject removeInstanceProtocol:nil withClass:IMPInstanceGCTestObject.class]);
	
	XCTAssertTrue([InstanceProtocolChildTargetObject resetDynamicMethods]);
	XCTAssertTrue([InstanceBaseProtocolTargetObject resetDynamicMethods]);
}



- (void)test_instanceOptionalMethod
{
	[InstanceBaseProtocolTargetObject enableDynamicMethods];
	
	[InstanceBaseProtocolTargetObject addInstanceProtocol:@protocol(MyDMInstanceOptionalMethodProtocol) withClass:ProtocolIMPOptionalInstanceMethod.class];
	
	XCTAssertTrue([InstanceBaseProtocolTargetObject instancesRespondToSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertFalse([InstanceBaseProtocolTargetObject removeInstanceForwardClass:IMPInstanceMTestObject.class]);
	
	[InstanceBaseProtocolTargetObject removeInstanceProtocol:@protocol(MyDMInstanceOptionalMethodProtocol)];
	
	[InstanceBaseProtocolTargetObject resetDynamicMethods];
}


- (void)test_instance_badInput
{
	XCTAssertFalse([InstanceBaseProtocolTargetObject addInstanceProtocol:nil withClass:nil]);
	XCTAssertFalse([InstanceBaseProtocolTargetObject removeInstanceProtocol:nil withClass:nil]);
	XCTAssertFalse([InstanceBaseProtocolTargetObject removeInstanceProtocol:@protocol(InstanceBaseTestProtocol) withClass:nil]);
	
	XCTAssertFalse([InstanceBaseProtocolTargetObject removeInstanceProtocol:nil withClass:IMPInstanceGCTestObject.class]);
	
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	Protocol *nilProtocol = nil;
	XCTAssertFalse([object isDynamicObjectProtocol:nilProtocol]);
	XCTAssertFalse([InstanceBaseProtocolTargetObject isDynamicInstanceProtocol:nilProtocol]);
}

- (void)test_targetForProtocol
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	
	[InstanceBaseProtocolTargetObject addInstanceProtocol:@protocol(MyDMInstanceNoMethodProtocol) withClass:IMPWithOriginalObjectMethod.class];
	[InstanceBaseProtocolTargetObject addInstanceForwardClass:IMPInstanceBaseTestObject.class];
	[InstanceBaseProtocolTargetObject enableDynamicMethods];
	
	IMPWithOriginalObjectMethod *target = [object targetForProtocol:@protocol(MyDMInstanceNoMethodProtocol)];
	XCTAssertNotNil(target, @"Target for MyDMInstanceNoMethodProtocol should be found.");
	
	NSArray *noProtocolTargets = [object targetForProtocol:nil];
	XCTAssertNotNil(noProtocolTargets, @"Targets with no protocol should be found.");
	XCTAssertTrue([noProtocolTargets isKindOfClass:NSArray.class]);
	XCTAssertFalse([noProtocolTargets isKindOfClass:NSMutableArray.class]);
	
	noProtocolTargets = [object targetForProtocol:@protocol(NSNoProtocol)];
	XCTAssertNotNil(noProtocolTargets, @"Targets with no protocol should be found.");
	XCTAssertTrue([noProtocolTargets isKindOfClass:NSArray.class]);
	XCTAssertFalse([noProtocolTargets isKindOfClass:NSMutableArray.class]);
	
	[InstanceBaseProtocolTargetObject removeInstanceProtocol:@protocol(MyDMInstanceNoMethodProtocol)];
	[InstanceBaseProtocolTargetObject removeInstanceForwardClass:IMPInstanceBaseTestObject.class];
	
	target = [object targetForProtocol:@protocol(MyDMInstanceNoMethodProtocol)];
	XCTAssertNil(target);
	
	noProtocolTargets = [object targetForProtocol:nil];
	XCTAssertNil(noProtocolTargets);
	
	noProtocolTargets = [object targetForProtocol:@protocol(NSNoProtocol)];
	XCTAssertNil(noProtocolTargets);
	
	[InstanceBaseProtocolTargetObject resetDynamicMethods];
}


- (void)test_InstanceClass_originalObject
{
	InstanceBaseProtocolTargetObject *object = InstanceBaseProtocolTargetObject.new;
	
	[InstanceBaseProtocolTargetObject addInstanceProtocol:@protocol(MyDMInstanceNoMethodProtocol) withClass:IMPWithOriginalObjectMethod.class];
	[InstanceBaseProtocolTargetObject enableDynamicMethods];
	
	IMPWithOriginalObjectMethod *target = [object targetForProtocol:@protocol(MyDMInstanceNoMethodProtocol)];
	
	XCTAssertNotNil(target, @"Target for MyDMInstanceNoMethodProtocol should be found.");
	XCTAssertEqual(target.originalObject, object, @"originalObject should have been set.");
	
	[InstanceBaseProtocolTargetObject removeInstanceProtocol:@protocol(MyDMInstanceNoMethodProtocol)];
	[InstanceBaseProtocolTargetObject resetDynamicMethods];
}

@end

/*
 
 
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
 
 // performSelector
 
 #pragma clang diagnostic pop
 
 */
