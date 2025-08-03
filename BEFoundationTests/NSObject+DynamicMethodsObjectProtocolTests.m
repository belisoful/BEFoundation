//
//  NSObject+DynamicMethodsTest.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import <BEFoundation/NSObject+DynamicMethods.h>





@protocol MyDMNoMethodProtocol
@end

@protocol MySubDMNoMethodProtocol <MyDMNoMethodProtocol>
@end

@protocol MySubSubDMNoMethodProtocol <MySubDMNoMethodProtocol>
@end




@protocol MyDMObjectRequiredMethodProtocol
- (NSNumber*)protocolObjectMethod;
@end
@protocol MyDMSubObjectRequiredMethodProtocol <MyDMObjectRequiredMethodProtocol>
@end
@protocol MyDMSubSubObjectRequiredMethodProtocol <MyDMSubObjectRequiredMethodProtocol>
@end


@protocol MyDMClassRequiredMethodProtocol
+ (NSNumber*)protocolClassMethod;
@end
@protocol MyDMSubClassRequiredMethodProtocol <MyDMClassRequiredMethodProtocol>
@end
@protocol MyDMSubSubClassRequiredMethodProtocol <MyDMSubClassRequiredMethodProtocol>
@end


@protocol MyDMObjectOptionalMethodProtocol
@optional
- (NSNumber*)protocolOptionalObjectMethod;
@end
@protocol MyDMSubObjectOptionalMethodProtocol <MyDMObjectOptionalMethodProtocol>
@end
@protocol MyDMSubSubObjectOptionalMethodProtocol <MyDMSubObjectOptionalMethodProtocol>
@end


@protocol MyDMClassOptionalMethodProtocol
@optional
+ (NSNumber*)protocolOptionalClassMethod;
@end
@protocol MyDMSubClassOptionalMethodProtocol <MyDMClassOptionalMethodProtocol>
@end
@protocol MyDMSubSubClassOptionalMethodProtocol <MyDMSubClassOptionalMethodProtocol>
@end




@interface ProtocolTargetObject : NSObject
@end
@implementation ProtocolTargetObject
@end





@interface ProtocolIMPRequiredObjectMethod : NSObject <MyDMObjectRequiredMethodProtocol>
@end
@implementation ProtocolIMPRequiredObjectMethod
- (NSNumber*)protocolObjectMethod
{
	return @(30);
}

- (NSNumber*)objectMethod
{
	return @(31);
}
@end

@interface ProtocolIMPRequiredClassMethod : NSObject <MyDMClassRequiredMethodProtocol>
@end
@implementation ProtocolIMPRequiredClassMethod
+ (NSNumber*)protocolClassMethod
{
	return @(40);
}
+ (NSNumber*)classMethod
{
	return @(41);
}
@end




@interface ProtocolIMPOptionalObjectMethod : NSObject <MyDMObjectOptionalMethodProtocol>
@end
@implementation ProtocolIMPOptionalObjectMethod

- (NSNumber*)protocolOptionalObjectMethod
{
	return @(130);
}
- (NSNumber*)optionalObjectMethod
{
	return @(131);
}
@end

@interface ProtocolIMPOptionalClassMethod : NSObject <MyDMClassOptionalMethodProtocol>
@end
@implementation ProtocolIMPOptionalClassMethod
+ (NSNumber*)protocolOptionalClassMethod
{
	return @(140);
}
+ (NSNumber*)optionalClassMethod
{
	return @(141);
}
@end






@protocol MyDMGeneralProtocol
- (NSNumber*)protocolObjectMethod;
+ (NSNumber*)protocolClassMethod;
@optional
- (NSNumber*)protocolOptionalObjectMethod;
+ (NSNumber*)protocolOptionalClassMethod;
@end
@protocol MyDMSubGeneralProtocol <MyDMGeneralProtocol>
@end
@protocol MyDMSubSubGeneralProtocol <MyDMSubGeneralProtocol>
@end




@interface ProtocolIMPGeneralMethod : NSObject <MyDMGeneralProtocol>
@end
@implementation ProtocolIMPGeneralMethod
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



#pragma mark - NSObject Dynamic Methods Tests


@interface NSDynamicMethodsObjectProtocolTests : XCTestCase

@end


@implementation NSDynamicMethodsObjectProtocolTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testProtocol_NoProtocol_target
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolIMPGeneralMethod *target = ProtocolIMPGeneralMethod.new;
	NSObject *nonTarget = NSObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertTrue([object addObjectProtocol:nil withTarget:target]);
	
	XCTAssertFalse([object addObjectProtocol:nil withTarget:target]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertEqualObjects([object performSelector:@selector(protocolObjectMethod)], @(30));
	XCTAssertEqualObjects([object performSelector:@selector(objectMethod)], @(31));
	XCTAssertEqualObjects([object performSelector:@selector(protocolOptionalObjectMethod)], @(130));
	XCTAssertEqualObjects([object performSelector:@selector(optionalObjectMethod)], @(131));
	
	// remove target
	XCTAssertFalse([object removeObjectProtocol:nil withTarget:nonTarget]);
	XCTAssertTrue([object removeObjectProtocol:nil withTarget:target]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocol_WOMethod_noTarget
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// Add Protocol
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// Remove Protocol
	XCTAssertTrue([object removeObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocol_WOMethod_nilTarget
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// Add nil target
	id nilTarget = nil;
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:nilTarget]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove nil target
	XCTAssertTrue([object removeObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:nilTarget]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocol_WOMethod_target
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// Add with target
	NSObject *target = NSObject.new, *nonTarget = NSObject.new;
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:target]);
	XCTAssertFalse([object addObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove with target
	XCTAssertFalse([object removeObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:nonTarget]);
	XCTAssertFalse([object removeObjectProtocol:@protocol(MySubDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object removeObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:target]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove prototol
	XCTAssertFalse([object removeObjectProtocol:@protocol(MySubDMNoMethodProtocol) withTarget:nil]);
	XCTAssertTrue([object removeObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:nil]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove target
	XCTAssertFalse([object removeObjectProtocol:nil withTarget:nonTarget]);
	XCTAssertTrue([object removeObjectProtocol:nil withTarget:target]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}


- (void)testForwardTarget_target
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolTargetObject *objectTarget = ProtocolTargetObject.new, *nonTarget = ProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertTrue([object addObjectForwardTarget:objectTarget]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove target
	XCTAssertFalse([object removeObjectForwardTarget:nonTarget]);
	XCTAssertTrue([object removeObjectForwardTarget:objectTarget]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}


- (void)testForwardTarget_target_second
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolTargetObject *objectTarget = ProtocolTargetObject.new, *nonTarget = ProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:objectTarget]);
	
	XCTAssertFalse([object removeObjectForwardTarget:nonTarget]);
	
	XCTAssertTrue([object addObjectForwardTarget:objectTarget]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove target
	XCTAssertFalse([object removeObjectForwardTarget:nonTarget]);
	XCTAssertTrue([object removeObjectForwardTarget:objectTarget]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}


- (void)testProtocolSub_WOMethod_noTarget
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	
	// Add Protocol
	XCTAssertTrue([object addObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	
	// Remove Protocol
	XCTAssertTrue([object removeObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocolSub_WOMethod_nilTarget
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// Add nil target
	id nilTarget = nil;
	XCTAssertTrue([object addObjectProtocol:@protocol(MySubDMNoMethodProtocol) withTarget:nilTarget]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove nil target
	XCTAssertTrue([object removeObjectProtocol:@protocol(MySubDMNoMethodProtocol) withTarget:nilTarget]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocolSub_WOMethod_target
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// Add with target
	NSObject *target = NSObject.new, *nonTarget = NSObject.new;
	XCTAssertTrue([object addObjectProtocol:@protocol(MySubDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove with target
	XCTAssertFalse([object removeObjectProtocol:@protocol(MySubDMNoMethodProtocol) withTarget:nonTarget]);
	XCTAssertFalse([object removeObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object removeObjectProtocol:@protocol(MySubDMNoMethodProtocol) withTarget:target]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MySubDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove nil target
	XCTAssertFalse([object removeObjectProtocol:@protocol(MyDMNoMethodProtocol) withTarget:nil]);
	XCTAssertTrue([object removeObjectProtocol:@protocol(MySubDMNoMethodProtocol) withTarget:nil]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MySubDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove target
	XCTAssertFalse([object removeObjectProtocol:nil withTarget:nonTarget]);
	XCTAssertTrue([object removeObjectProtocol:nil withTarget:target]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}


- (void)testProtocolSubSub_WOMethod_noTarget
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// Add Protocol
	XCTAssertTrue([object addObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// Remove Protocol
	XCTAssertTrue([object removeObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocolSubSub_WOMethod_nilTarget
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// Add nil target
	id nilTarget = nil;
	XCTAssertTrue([object addObjectProtocol:@protocol(MySubSubDMNoMethodProtocol) withTarget:nilTarget]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove nil target
	XCTAssertTrue([object removeObjectProtocol:@protocol(MySubSubDMNoMethodProtocol) withTarget:nilTarget]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocolSubSub_WOMethod_target
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// Add with target
	NSObject *target = NSObject.new, *nonTarget = NSObject.new;
	XCTAssertTrue([object addObjectProtocol:@protocol(MySubSubDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove with target
	XCTAssertFalse([object removeObjectProtocol:@protocol(MySubSubDMNoMethodProtocol) withTarget:nonTarget]);
	XCTAssertFalse([object removeObjectProtocol:@protocol(MySubDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object removeObjectProtocol:@protocol(MySubSubDMNoMethodProtocol) withTarget:target]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MySubSubDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove nil target
	XCTAssertTrue([object removeObjectProtocol:@protocol(MySubSubDMNoMethodProtocol) withTarget:nil]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MySubSubDMNoMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertTrue([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	// remove target
	XCTAssertFalse([object removeObjectProtocol:nil withTarget:nonTarget]);
	XCTAssertTrue([object removeObjectProtocol:nil withTarget:target]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MyDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubDMNoMethodProtocol)]);
	XCTAssertFalse([object isDynamicObjectProtocol:@protocol(MySubSubDMNoMethodProtocol)]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}






- (void)testProtocol_Method_required
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolIMPRequiredObjectMethod *target = ProtocolIMPRequiredObjectMethod.new; // method:	objectMethod
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMObjectRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectRequiredMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMObjectRequiredMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMObjectRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectRequiredMethodProtocol)]);
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(objectMethod)]);
	
	// perform protocol selector in target
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(result, @(30));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocolSub_Method_required
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolIMPRequiredObjectMethod *target = ProtocolIMPRequiredObjectMethod.new; // method:	objectMethod
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMObjectRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectRequiredMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMSubObjectRequiredMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMObjectRequiredMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubObjectRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectRequiredMethodProtocol)]);
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(objectMethod)]);
	
	// perform protocol selector in target
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(result, @(30));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocolSubSub_Method_required
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolIMPRequiredObjectMethod *target = ProtocolIMPRequiredObjectMethod.new; // method:	objectMethod
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMObjectRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectRequiredMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectRequiredMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMSubSubObjectRequiredMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMObjectRequiredMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubObjectRequiredMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubSubObjectRequiredMethodProtocol)]);
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(objectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(objectMethod)]);
	
	// perform protocol selector in target
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolObjectMethod)]);
	XCTAssertEqualObjects(result, @(30));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(objectMethod)], NSException, NSInvalidArgumentException);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}



- (void)testProtocol_Method_optional
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolIMPOptionalObjectMethod *target = ProtocolIMPOptionalObjectMethod.new; // method:	objectMethod
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMObjectOptionalMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(optionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(optionalObjectMethod)]);
	
	// perform protocol selector in target
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertEqualObjects(result, @(130));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(optionalObjectMethod)], NSException, NSInvalidArgumentException);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocolSub_Method_optional
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolIMPOptionalObjectMethod *target = ProtocolIMPOptionalObjectMethod.new; // method:	objectMethod
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(optionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(optionalObjectMethod)]);
	
	// perform protocol selector in target
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertEqualObjects(result, @(130));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(optionalObjectMethod)], NSException, NSInvalidArgumentException);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocolSubSub_Method_optional
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolIMPOptionalObjectMethod *target = ProtocolIMPOptionalObjectMethod.new; // method:	objectMethod
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNotNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertTrue([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(optionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(optionalObjectMethod)]);
	
	// perform protocol selector in target
	NSNumber *result = nil;
	XCTAssertNoThrow(result = [object performSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertEqualObjects(result, @(130));
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(optionalObjectMethod)], NSException, NSInvalidArgumentException);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}




- (void)testProtocol_Method_optional_missing
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolIMPRequiredObjectMethod *target = ProtocolIMPRequiredObjectMethod.new; // method:	objectMethod
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMObjectOptionalMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(optionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(optionalObjectMethod)]);
	
	// perform protocol selector in target
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(protocolOptionalObjectMethod)], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(optionalObjectMethod)], NSException, NSInvalidArgumentException);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocolSub_Method_optional_missing
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolIMPRequiredObjectMethod *target = ProtocolIMPRequiredObjectMethod.new; // method:	objectMethod
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(optionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(optionalObjectMethod)]);
	
	// perform protocol selector in target
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(protocolOptionalObjectMethod)], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(optionalObjectMethod)], NSException, NSInvalidArgumentException);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}

- (void)testProtocolSubSub_Method_optional_missing
{
	ProtocolTargetObject *object = ProtocolTargetObject.new;
	ProtocolIMPRequiredObjectMethod *target = ProtocolIMPRequiredObjectMethod.new; // method:	objectMethod
	
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertFalse([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertTrue([object addObjectProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol) withTarget:target]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMObjectOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubObjectOptionalMethodProtocol)]);
	XCTAssertTrue([object conformsToProtocol:@protocol(MyDMSubSubObjectOptionalMethodProtocol)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(protocolOptionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(protocolOptionalObjectMethod)]);
	
	XCTAssertNil([object methodSignatureForSelector:@selector(optionalObjectMethod)]);
	XCTAssertFalse([object respondsToSelector:@selector(optionalObjectMethod)]);
	
	// perform protocol selector in target
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(protocolOptionalObjectMethod)], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([object performSelector:@selector(optionalObjectMethod)], NSException, NSInvalidArgumentException);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}



- (void)testDynamicMethod_BadArguments
{
	ProtocolTargetObject *objectTarget = ProtocolTargetObject.new, *object = ProtocolTargetObject.new;
	
	Protocol *nilProtocol = nil;
	XCTAssertTrue([object.class enableDynamicMethods]);
	
	XCTAssertFalse([object conformsToProtocol:nilProtocol]);
	
	XCTAssertFalse([object addObjectProtocol:nilProtocol]);
	XCTAssertFalse([object conformsToProtocol:nilProtocol]);
	
	XCTAssertFalse([object addObjectProtocol:nilProtocol withTarget:nil]);
	
	XCTAssertFalse([object addObjectProtocol:@protocol(NSNoProtocol)]);
	XCTAssertFalse([object addObjectProtocol:@protocol(NSNoProtocol) withTarget:nil]);
	XCTAssertFalse([object conformsToProtocol:@protocol(NSNoProtocol)]);
	
	XCTAssertFalse([object removeObjectProtocol:@protocol(NSNoProtocol) withTarget:objectTarget]);
	XCTAssertFalse([object removeObjectProtocol:nil withTarget:nil]);
	
	XCTAssertTrue([object.class disableDynamicMethods]);
}


@end

/*
 
 
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
 
 // performSelector
 
 #pragma clang diagnostic pop
 
 */
