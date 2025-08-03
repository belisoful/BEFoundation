//
//  BFoundationExtensionTests.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import "BEFoundation/BEMutable.h"

@interface BEMutableTests : XCTestCase

@end

@implementation BEMutableTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testNSObject_Correctness {
	NSObject *obj = NSObject.new;
	
	XCTAssertFalse(NSObject.isMutable);
	XCTAssertFalse(obj.class.isMutable);
	XCTAssertFalse(obj.isMutable);
}

#pragma mark - BECollection protocols

- (void)testNSSet_Protocol_Correctness {
	NSSet *set = NSSet.new;
	
	XCTAssertFalse(NSSet.isMutable);
	XCTAssertFalse(set.class.isMutable);
	XCTAssertFalse(set.isMutable);
	
	//XCTAssertTrue([NSSet.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([set conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSSet.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([set conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertTrue([NSSet.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertTrue([set conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSSet.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([set conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSSet.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([set conformsToProtocol:@protocol(BEMutableCollection)]);
}

- (void)testNSOrderedSet_Protocol_Correctness {
	NSOrderedSet *orderedSet = NSOrderedSet.new;
	
	XCTAssertFalse(NSOrderedSet.isMutable);
	XCTAssertFalse(orderedSet.class.isMutable);
	XCTAssertFalse(orderedSet.isMutable);
	
	//XCTAssertTrue([NSOrderedSet.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([orderedSet conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSOrderedSet.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([orderedSet conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertTrue([NSOrderedSet.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertTrue([orderedSet conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSOrderedSet.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([orderedSet conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSOrderedSet.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([orderedSet conformsToProtocol:@protocol(BEMutableCollection)]);
}

- (void)testNSArray_Protocol_Correctness {
	NSArray *array = NSArray.new;
	
	XCTAssertFalse(NSArray.isMutable);
	XCTAssertFalse(array.class.isMutable);
	XCTAssertFalse(array.isMutable);
	
	//XCTAssertTrue([NSArray.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([array conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSArray.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([array conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertTrue([NSArray.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertTrue([array conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSArray.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([array conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSArray.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([array conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSDictionary_Protocol_Correctness {
	NSDictionary *dictionary = NSDictionary.new;
	
	XCTAssertFalse(NSDictionary.isMutable);
	XCTAssertFalse(dictionary.class.isMutable);
	XCTAssertFalse(dictionary.isMutable);
	
	//XCTAssertTrue([NSDictionary.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([dictionary conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSDictionary.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([dictionary conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertTrue([NSDictionary.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertTrue([dictionary conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSDictionary.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([dictionary conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSDictionary.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([dictionary conformsToProtocol:@protocol(BEMutableCollection)]);
}


#pragma mark - BEMutableCollection protocols

- (void)testNSMutableSet_Protocol_Correctness {
	NSMutableSet *set = NSMutableSet.new;
	
	XCTAssertTrue(NSMutableSet.isMutable);
	XCTAssertTrue(set.class.isMutable);
	XCTAssertTrue(set.isMutable);
	
	//XCTAssertTrue([NSMutableSet.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([set conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSMutableSet.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([set conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertTrue([NSMutableSet.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertTrue([set conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertTrue([NSMutableSet.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([set conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertTrue([NSMutableSet.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertTrue([set conformsToProtocol:@protocol(BEMutableCollection)]);
}

- (void)testNSMutableOrderedSet_Protocol_Correctness {
	NSMutableOrderedSet *orderedSet = NSMutableOrderedSet.new;
	
	XCTAssertTrue(NSMutableOrderedSet.isMutable);
	XCTAssertTrue(orderedSet.class.isMutable);
	XCTAssertTrue(orderedSet.isMutable);
	
	//XCTAssertTrue([NSMutableOrderedSet.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([orderedSet conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSMutableOrderedSet.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([orderedSet conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertTrue([NSMutableOrderedSet.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertTrue([orderedSet conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertTrue([NSMutableOrderedSet.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([orderedSet conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertTrue([NSMutableOrderedSet.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertTrue([orderedSet conformsToProtocol:@protocol(BEMutableCollection)]);
}

- (void)testNSMutableArray_Protocol_Correctness {
	NSMutableArray *array = NSMutableArray.new;
	
	XCTAssertTrue(NSMutableArray.isMutable);
	XCTAssertTrue(array.class.isMutable);
	XCTAssertTrue(array.isMutable);
	
	//XCTAssertTrue([NSMutableArray.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([array conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSMutableArray.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([array conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertTrue([NSMutableArray.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertTrue([array conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertTrue([NSMutableArray.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([array conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertTrue([NSMutableArray.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertTrue([array conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSMutableDictionary_Protocol_Correctness {
	NSMutableDictionary *dictionary = NSMutableDictionary.new;
	
	XCTAssertTrue(NSMutableDictionary.isMutable);
	XCTAssertTrue(dictionary.class.isMutable);
	XCTAssertTrue(dictionary.isMutable);
	
	//XCTAssertTrue([NSMutableDictionary.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([dictionary conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSMutableDictionary.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([dictionary conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertTrue([NSMutableDictionary.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertTrue([dictionary conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertTrue([NSMutableDictionary.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([dictionary conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertTrue([NSMutableDictionary.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertTrue([dictionary conformsToProtocol:@protocol(BEMutableCollection)]);
}


#pragma mark - BEHasMutable

- (void)testNSIndexSet_Protocol_Correctness {
	NSIndexSet *indexSet = NSIndexSet.new;
	
	XCTAssertFalse(NSIndexSet.isMutable);
	XCTAssertFalse(indexSet.class.isMutable);
	XCTAssertFalse(indexSet.isMutable);
	
	//XCTAssertTrue([NSIndexSet.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([indexSet conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSIndexSet.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([indexSet conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertFalse([NSIndexSet.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([indexSet conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSIndexSet.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([indexSet conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSIndexSet.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([indexSet conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSNumber_Protocol_Correctness {
	NSNumber *number = [NSNumber numberWithInt:0];
	
	XCTAssertFalse(NSNumber.isMutable);
	XCTAssertFalse(number.class.isMutable);
	XCTAssertFalse(number.isMutable);
	
	
	XCTAssertTrue([NSNumber.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([number conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertFalse([NSNumber.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([number conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSNumber.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([number conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSNumber.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([number conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSString_Protocol_Correctness {
	NSString *string = [NSString stringWithFormat:@""];
	
	XCTAssertFalse(NSString.isMutable);
	XCTAssertFalse(string.class.isMutable);
	XCTAssertFalse(string.isMutable);
	
	//XCTAssertTrue([NSString.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([string conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSString.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([string conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertFalse([NSString.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([string conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSString.class conformsToProtocol:@protocol(BEMutable)]);
	
	//NOTE: NSMutableString and NSString are concrete classes of @""
	//XCTAssertFalse([string conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSString.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([string.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([string conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSData_Protocol_Correctness {
	NSData *data = NSData.new;
	
	XCTAssertFalse(NSData.isMutable);
	XCTAssertFalse(data.class.isMutable);
	XCTAssertFalse(data.isMutable);
	
	//XCTAssertTrue([NSData.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([data conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSData.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([data conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertFalse([NSData.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([data conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSData.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([data conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSData.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([data conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSAttributedString_Protocol_Correctness {
	NSAttributedString *string = NSAttributedString.new;
	
	XCTAssertFalse(NSAttributedString.isMutable);
	XCTAssertFalse(string.class.isMutable);
	XCTAssertFalse(string.isMutable);
	
	//XCTAssertTrue([NSAttributedString.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([string conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSAttributedString.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([string conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertFalse([NSAttributedString.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([string conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSAttributedString.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([string conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSAttributedString.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([string conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSURLRequest_Protocol_Correctness {
	NSURLRequest *urlRequest = NSURLRequest.new;
	
	XCTAssertFalse(NSURLRequest.isMutable);
	XCTAssertFalse(urlRequest.class.isMutable);
	XCTAssertFalse(urlRequest.isMutable);
	
	//XCTAssertTrue([NSURLRequest.class conformsToProtocol:@protocol(NSHasMutable)]);
	//XCTAssertTrue([urlRequest conformsToProtocol:@protocol(NSHasMutable)]);
	
	XCTAssertTrue([NSURLRequest.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([urlRequest conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertFalse([NSURLRequest.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([urlRequest conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSURLRequest.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([urlRequest conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSURLRequest.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([urlRequest conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSCharacterSet_Protocol_Correctness {
	NSCharacterSet *charSet = NSCharacterSet.new;
	
	XCTAssertFalse(NSCharacterSet.isMutable);
	XCTAssertFalse(charSet.class.isMutable);
	XCTAssertFalse(charSet.isMutable);
	
#if kCharSetDifferentiable
	XCTAssertTrue([NSCharacterSet.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([charSet conformsToProtocol:@protocol(BEHasMutable)]);
#else
	XCTAssertFalse([NSCharacterSet.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BEHasMutable)]);
#endif
	
	XCTAssertFalse([NSCharacterSet.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSCharacterSet.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSCharacterSet.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testBECharacterSet_Protocol_Correctness {
	BECharacterSet *charSet = BECharacterSet.new;
	
	XCTAssertFalse(BECharacterSet.isMutable);
	XCTAssertFalse(charSet.class.isMutable);
	XCTAssertFalse(charSet.isMutable);
	
	XCTAssertTrue([BECharacterSet.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([charSet conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertFalse([BECharacterSet.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertTrue([BECharacterSet.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertTrue([charSet conformsToProtocol:@protocol(BEHasMutable)]);
	
	XCTAssertFalse([BECharacterSet.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([BECharacterSet.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BEMutableCollection)]);
	
}



#pragma mark - BEMutable

- (void)testNSMutableIndexSet_Protocol_Correctness {
	NSMutableIndexSet *indexSet = NSMutableIndexSet.new;
	
	XCTAssertTrue(NSMutableIndexSet.isMutable);
	XCTAssertTrue(indexSet.class.isMutable);
	XCTAssertTrue(indexSet.isMutable);
	
	XCTAssertFalse([NSMutableIndexSet.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([indexSet conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertTrue([NSMutableIndexSet.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([indexSet conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSMutableIndexSet.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([indexSet conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSMutableNumber_Protocol_Correctness {
	NSMutableNumber *number = [NSMutableNumber numberWithInt:0];
	
	XCTAssertTrue(NSMutableNumber.isMutable);
	XCTAssertTrue(number.class.isMutable);
	XCTAssertTrue(number.isMutable);
	
	XCTAssertFalse([NSMutableNumber.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([number conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertTrue([NSMutableNumber.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([number conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSMutableNumber.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([number conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSMutableString_Protocol_Correctness {
	NSMutableString *string = NSMutableString.new;
	
	XCTAssertTrue(NSMutableString.isMutable);
	XCTAssertTrue(string.class.isMutable);
	XCTAssertTrue(string.isMutable);
	
	
	[string performSelector:@selector(setString:) withObject:@"obj"];
	
	XCTAssertFalse([NSMutableString.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([string conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertTrue([NSMutableString.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([string conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSMutableString.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([string conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSMutableData_Protocol_Correctness {
	NSMutableData *data = NSMutableData.new;
	
	XCTAssertTrue(NSMutableData.isMutable);
	XCTAssertTrue(data.class.isMutable);
	XCTAssertTrue(data.isMutable);
	
	XCTAssertFalse([NSMutableData.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([data conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertTrue([NSMutableData.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([data conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSMutableData.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([data conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSMutableAttributedString_Protocol_Correctness {
	NSMutableAttributedString *string = NSMutableAttributedString.new;
	
	XCTAssertTrue(NSMutableAttributedString.isMutable);
	XCTAssertTrue(string.class.isMutable);
	XCTAssertTrue(string.isMutable);
	
	XCTAssertFalse([NSMutableAttributedString.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([string conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertTrue([NSMutableAttributedString.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([string conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSMutableAttributedString.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([string conformsToProtocol:@protocol(BEMutableCollection)]);
}


- (void)testNSMutableURLRequest_Protocol_Correctness {
	NSMutableURLRequest *urlRequest = NSMutableURLRequest.new;
	
	XCTAssertTrue(NSMutableURLRequest.isMutable);
	XCTAssertTrue(urlRequest.class.isMutable);
	XCTAssertTrue(urlRequest.isMutable);
	
	XCTAssertFalse([NSMutableURLRequest.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([urlRequest conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertTrue([NSMutableURLRequest.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([urlRequest conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSMutableURLRequest.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([urlRequest conformsToProtocol:@protocol(BEMutableCollection)]);
}



- (void)testNSMutableCharacterSet_Protocol_Correctness {
	NSMutableCharacterSet *charSet = NSMutableCharacterSet.new;
	
	
#if kCharSetDifferentiable
	XCTAssertTrue(NSMutableCharacterSet.isMutable);
	XCTAssertTrue(charSet.class.isMutable);
	XCTAssertTrue(charSet.isMutable);
	
	XCTAssertTrue([NSMutableCharacterSet.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([charSet conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSMutableCharacterSet.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(NSHasMutable)]);
#else
	XCTAssertFalse(NSMutableCharacterSet.isMutable);
	XCTAssertFalse(charSet.class.isMutable);
	XCTAssertFalse(charSet.isMutable);
	
	XCTAssertFalse([NSMutableCharacterSet.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([NSMutableCharacterSet.class conformsToProtocol:@protocol(BEHasMutable)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BEHasMutable)]);
#endif
	
	XCTAssertFalse([NSMutableCharacterSet.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([NSMutableCharacterSet.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BEMutableCollection)]);
}

- (void)testBEMutableCharacterSet_Protocol_Correctness {
	BEMutableCharacterSet *charSet = BEMutableCharacterSet.new;
	
	XCTAssertTrue(BEMutableCharacterSet.isMutable);
	XCTAssertTrue(charSet.class.isMutable);
	XCTAssertTrue(charSet.isMutable);
	
	XCTAssertTrue([BEMutableCharacterSet.class conformsToProtocol:@protocol(BEMutable)]);
	XCTAssertTrue([charSet conformsToProtocol:@protocol(BEMutable)]);
	
	XCTAssertFalse([BEMutableCharacterSet.class conformsToProtocol:@protocol(BECollection)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BECollection)]);
	
	XCTAssertFalse([BEMutableCharacterSet.class conformsToProtocol:@protocol(BEMutableCollection)]);
	XCTAssertFalse([charSet conformsToProtocol:@protocol(BEMutableCollection)]);
}



#pragma mark - BECollection Helper Methods

- (NSArray *)arrayInstanceHelper
{
	NSString *strBytes = @"data0";
	NSString *mstrBytes = @"mutabledata0";
	
	NSString *attrString = @"NSAttributedString";
	NSDictionary *attributes = @{
		NSFontAttributeName: [NSFont boldSystemFontOfSize:18],
		NSForegroundColorAttributeName: [NSColor redColor]
	};
	
	NSString *mattrString = @"NSMutableAttributedString";
	NSDictionary *mattributes = @{
		NSFontAttributeName: [NSFont boldSystemFontOfSize:50],
		NSForegroundColorAttributeName: [NSColor blueColor]
	};
	
	NSArray *keys = @[
		@"set_string",
		@"set_array",
		@"orderedset",
		@"array",
		@"dictionary",
		
		@"indexset",
		@"number", // 6 can be deleted
		@"string",
		@"data",
		@"attributedstring",
		@"urlrequest",
		@"NScharset",
		@"mutable_NScharset",
		
		@"mutable_set",
		@"mutable_orderedset", // 14 can be deleted
		@"mutable_array",
		@"mutable_dictionary",
		
		@"mutable_indexset",
		@"mutable_number",
		@"mutable_string",
		@"mutable_data",
		@"mutable_attributedstring",
		@"mutable_urlrequest",
		@"BEcharset",
		@"mutable_BEcharset"
	];
	
	NSArray *values = @[
		//  0 .. 4
		[NSSet setWithObject:@"NSSet"],
		[NSSet setWithObject:@[@"InnerString"]],
		[NSOrderedSet orderedSetWithObjects:@"NSOrderedSet0", @"NSOrderedSet1", @"NSOrderedSet1", nil],
		[NSArray arrayWithObjects:@"NSArray0", @"NSArray1", nil],
		[NSDictionary dictionaryWithObjects:@[@"element0", @"element1"] forKeys:@[@"key0", @"key1"]],
		
		//	5 .. 12
		[NSIndexSet indexSetWithIndex:1111],
		[NSNumber numberWithLong:5353],
		[NSString stringWithFormat:@"string0"],
		[NSData dataWithBytes:[strBytes cStringUsingEncoding:NSASCIIStringEncoding] length:[strBytes lengthOfBytesUsingEncoding:NSASCIIStringEncoding]],
		[NSAttributedString.alloc initWithString:attrString attributes:attributes],
		[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://ecosia.com/"]],
		[NSCharacterSet characterSetWithCharactersInString:@"0123"],
		[NSMutableCharacterSet characterSetWithCharactersInString:@"4567"],
		
		//	13 .. 16
		[NSMutableSet setWithObject:@"NSMutableSet"],
		[NSMutableOrderedSet orderedSetWithObjects:@"NSMOrderedSet0", @"NSMOrderedSet1", @"NSMOrderedSet1", nil],
		[NSMutableArray arrayWithObjects:@"NSMArray0", @"NSMArray1", nil],
		[NSMutableDictionary dictionaryWithObjects:@[@"melement0", @"melement1"] forKeys:@[@"mkey0", @"mkey1"]],
		
		//	17 .. 24
		[NSMutableIndexSet indexSetWithIndex:11111],
		[NSMutableNumber numberWithLong:535353],
		[NSMutableString stringWithString:@"mutablestring0"],
		[NSMutableData dataWithBytes:[mstrBytes cStringUsingEncoding:NSASCIIStringEncoding] length:[mstrBytes lengthOfBytesUsingEncoding:NSASCIIStringEncoding]],
		[NSMutableAttributedString.alloc initWithString:mattrString attributes:mattributes],
		[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://duckduckgo.com/"]],
		[BECharacterSet characterSetWithCharactersInString:@"BECharacterSet"],
		[BEMutableCharacterSet characterSetWithCharactersInString:@"BEMutableCharacterSet"]
	];
	
	XCTAssertEqual(keys.count, values.count);
	return @[keys, values];
}

#pragma mark - BECollection copyRecursive

// Immutable Sets

- (void)testNSSet_copyRecursive_Correctness
{
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSSet *reference = [NSSet setWithArray:elements];
	
	NSSet *result = [reference copyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSSet.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableSet.class]);
	XCTAssertEqual(result.count, reference.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
		BOOL contains = [reference containsObject:obj];
		
		XCTAssertTrue(contains);
		if (contains) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				// All Collections must be immutable
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual([result member:elements[0]], elements[0]);
	XCTAssertEqualObjects([result member:elements[0]], elements[0]);
	XCTAssertNotEqual([result member:elements[1]], elements[1]);
	XCTAssertEqualObjects([result member:elements[1]], elements[1]);
	XCTAssertNotEqual([result member:elements[2]], elements[2]);
	XCTAssertEqualObjects([result member:elements[2]], elements[2]);
	XCTAssertNotEqual([result member:elements[3]], elements[3]);
	XCTAssertEqualObjects([result member:elements[3]], elements[3]);
	XCTAssertNotEqual([result member:elements[4]], elements[4]);
	XCTAssertEqualObjects([result member:elements[4]], elements[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual([result member:elements[5]], elements[5]);
		XCTAssertEqual([result member:elements[6]], elements[6]);
		XCTAssertEqual([result member:elements[7]], elements[7]);
		XCTAssertEqual([result member:elements[8]], elements[8]);
		XCTAssertEqual([result member:elements[9]], elements[9]);
		XCTAssertEqual([result member:elements[10]], elements[10]);
		
		XCTAssertEqual([result member:elements[11]], elements[11]);
		XCTAssertNotEqual([result member:elements[12]], elements[12]);
		XCTAssertEqualObjects([result member:elements[12]], elements[12]);	//NSMutableCharacterSet
	}
	
	XCTAssertNotEqual([result member:elements[13]], elements[13]);
	XCTAssertEqualObjects([result member:elements[13]], elements[13]);
	XCTAssertNotEqual([result member:elements[14]], elements[14]);
	XCTAssertEqualObjects([result member:elements[14]], elements[14]);
	XCTAssertNotEqual([result member:elements[15]], elements[15]);
	XCTAssertEqualObjects([result member:elements[15]], elements[15]);
	XCTAssertNotEqual([result member:elements[16]], elements[16]);
	XCTAssertEqualObjects([result member:elements[16]], elements[16]);
	
	XCTAssertNotEqual([result member:elements[17]], elements[17]);
	XCTAssertEqualObjects([result member:elements[17]], elements[17]);
	XCTAssertNotEqual([result member:elements[18]], elements[18]);
	XCTAssertEqualObjects([result member:elements[18]], elements[18]);
	XCTAssertNotEqual([result member:elements[19]], elements[19]);
	XCTAssertEqualObjects([result member:elements[19]], elements[19]);
	XCTAssertNotEqual([result member:elements[20]], elements[20]);
	XCTAssertEqualObjects([result member:elements[20]], elements[20]);
	XCTAssertNotEqual([result member:elements[21]], elements[21]);
	XCTAssertEqualObjects([result member:elements[21]], elements[21]);
	XCTAssertNotEqual([result member:elements[22]], elements[22]);
	XCTAssertEqualObjects([result member:elements[22]], elements[22]);
	
	XCTAssertEqual([result member:elements[23]], elements[23]);
	
	XCTAssertNotNil(elements[24], @"Element 24 is missing.");
	XCTAssertNotNil([result member:elements[24]], @"Element 24 is not found in the result");
	XCTAssertNotEqual([result member:elements[24]], elements[24]);
	XCTAssertEqualObjects([result member:elements[24]], elements[24]);
}

- (void)testNSOrderedSet_copyRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSOrderedSet *reference = [NSOrderedSet orderedSetWithArray:elements];
	
	NSOrderedSet *result = [reference copyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSOrderedSet.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableOrderedSet.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertNotEqual(result[12], reference[12]);	//NSMutableCharacterSet
		XCTAssertEqualObjects(result[12], reference[12]);
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertNotEqual(result[17], reference[17]);
	XCTAssertEqualObjects(result[17], reference[17]);
	XCTAssertNotEqual(result[18], reference[18]);
	XCTAssertEqualObjects(result[18], reference[18]);
	XCTAssertNotEqual(result[19], reference[19]);
	XCTAssertEqualObjects(result[19], reference[19]);
	XCTAssertNotEqual(result[20], reference[20]);
	XCTAssertEqualObjects(result[20], reference[20]);
	XCTAssertNotEqual(result[21], reference[21]);
	XCTAssertEqualObjects(result[21], reference[21]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertNotEqual(result[24], reference[24]);
	XCTAssertEqualObjects(result[24], reference[24]);
}

- (void)testNSArray_copyRecursive_Correctness {
	
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSArray *reference = [NSArray arrayWithArray:elements];
	
	NSArray *result = [reference copyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSArray.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableArray.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertNotEqual(result[12], reference[12]); //NSMutableCharacterSet is not converted
		XCTAssertEqualObjects(result[12], reference[12]);
		
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertNotEqual(result[17], reference[17]);
	XCTAssertEqualObjects(result[17], reference[17]);
	XCTAssertNotEqual(result[18], reference[18]);
	XCTAssertEqualObjects(result[18], reference[18]);
	XCTAssertNotEqual(result[19], reference[19]);
	XCTAssertEqualObjects(result[19], reference[19]);
	XCTAssertNotEqual(result[20], reference[20]);
	XCTAssertEqualObjects(result[20], reference[20]);
	XCTAssertNotEqual(result[21], reference[21]);
	XCTAssertEqualObjects(result[21], reference[21]);
	XCTAssertNotEqual(result[22], reference[22]);
	XCTAssertEqualObjects(result[22], reference[22]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertNotEqual(result[24], reference[24]);
	XCTAssertEqualObjects(result[24], reference[24]);
}

- (void)testNSDictionary_copyRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSDictionary *reference = [NSDictionary dictionaryWithObjects:keyValues[1] forKeys:keyValues[0]];
	
	NSDictionary *result = [reference copyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSDictionary.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(result.count, keyValues[1].count);
	
	[result enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		id ref = [reference objectForKey:key];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[@"set_string"], reference[@"set_string"]);
	XCTAssertEqualObjects(result[@"set_string"], reference[@"set_string"]);
	XCTAssertNotEqual(result[@"set_array"], reference[@"set_array"]);
	XCTAssertEqualObjects(result[@"set_array"], reference[@"set_array"]);
	XCTAssertNotEqual(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertEqualObjects(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertNotEqual(result[@"array"], reference[@"array"]);
	XCTAssertEqualObjects(result[@"array"], reference[@"array"]);
	XCTAssertNotEqual(result[@"dictionary"], reference[@"dictionary"]);
	XCTAssertEqualObjects(result[@"dictionary"], reference[@"dictionary"]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[@"indexset"], reference[@"indexset"]);
		XCTAssertEqual(result[@"number"], reference[@"number"]);
		XCTAssertEqual(result[@"string"], reference[@"string"]);
		XCTAssertEqual(result[@"data"], reference[@"data"]);
		XCTAssertEqual(result[@"attributedstring"], reference[@"attributedstring"]);
		XCTAssertEqual(result[@"urlrequest"], reference[@"urlrequest"]);
		
		XCTAssertEqual(result[@"NScharset"], reference[@"NScharset"]);
		XCTAssertNotEqual(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
		XCTAssertEqualObjects(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
	}
	
	XCTAssertNotEqual(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertEqualObjects(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertNotEqual(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertEqualObjects(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertNotEqual(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertEqualObjects(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertNotEqual(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	XCTAssertEqualObjects(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	
	XCTAssertNotEqual(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertEqualObjects(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertNotEqual(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertEqualObjects(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertNotEqual(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertEqualObjects(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertNotEqual(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertEqualObjects(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertNotEqual(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertEqualObjects(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertNotEqual(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	XCTAssertEqualObjects(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	
	XCTAssertEqual(result[@"BEcharset"], reference[@"BEcharset"]);
	XCTAssertNotEqual(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
	XCTAssertEqualObjects(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
}

//Mutable Collections

- (void)testNSMutableSet_copyRecursive_Correctness
{
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableSet *reference = [NSMutableSet setWithArray:elements];
	
	NSSet *result = [reference copyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSSet.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableSet.class]);
	XCTAssertEqual(result.count, reference.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
		BOOL contains = [reference containsObject:obj];
		
		XCTAssertTrue(contains);
		if (contains) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				// All Collections must be immutable
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual([result member:elements[0]], elements[0]);
	XCTAssertEqualObjects([result member:elements[0]], elements[0]);
	XCTAssertNotEqual([result member:elements[1]], elements[1]);
	XCTAssertEqualObjects([result member:elements[1]], elements[1]);
	XCTAssertNotEqual([result member:elements[2]], elements[2]);
	XCTAssertEqualObjects([result member:elements[2]], elements[2]);
	XCTAssertNotEqual([result member:elements[3]], elements[3]);
	XCTAssertEqualObjects([result member:elements[3]], elements[3]);
	XCTAssertNotEqual([result member:elements[4]], elements[4]);
	XCTAssertEqualObjects([result member:elements[4]], elements[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual([result member:elements[5]], elements[5]);
		XCTAssertEqual([result member:elements[6]], elements[6]);
		XCTAssertEqual([result member:elements[7]], elements[7]);
		XCTAssertEqual([result member:elements[8]], elements[8]);
		XCTAssertEqual([result member:elements[9]], elements[9]);
		XCTAssertEqual([result member:elements[10]], elements[10]);
		
		XCTAssertEqual([result member:elements[11]], elements[11]);
		XCTAssertNotEqual([result member:elements[12]], elements[12]);	//NSMutableCharacterSet
		XCTAssertEqualObjects([result member:elements[12]], elements[12]);
	}
	
	XCTAssertNotEqual([result member:elements[13]], elements[13]);
	XCTAssertEqualObjects([result member:elements[13]], elements[13]);
	XCTAssertNotEqual([result member:elements[14]], elements[14]);
	XCTAssertEqualObjects([result member:elements[14]], elements[14]);
	XCTAssertNotEqual([result member:elements[15]], elements[15]);
	XCTAssertEqualObjects([result member:elements[15]], elements[15]);
	XCTAssertNotEqual([result member:elements[16]], elements[16]);
	XCTAssertEqualObjects([result member:elements[16]], elements[16]);
	
	XCTAssertNotEqual([result member:elements[17]], elements[17]);
	XCTAssertEqualObjects([result member:elements[17]], elements[17]);
	XCTAssertNotEqual([result member:elements[18]], elements[18]);
	XCTAssertEqualObjects([result member:elements[18]], elements[18]);
	XCTAssertNotEqual([result member:elements[19]], elements[19]);
	XCTAssertEqualObjects([result member:elements[19]], elements[19]);
	XCTAssertNotEqual([result member:elements[20]], elements[20]);
	XCTAssertEqualObjects([result member:elements[20]], elements[20]);
	XCTAssertNotEqual([result member:elements[21]], elements[21]);
	XCTAssertEqualObjects([result member:elements[21]], elements[21]);
	XCTAssertNotEqual([result member:elements[22]], elements[22]);
	XCTAssertEqualObjects([result member:elements[22]], elements[22]);
	
	XCTAssertEqual([result member:elements[23]], elements[23]);
	
	XCTAssertNotNil(elements[24], @"Element 24 is missing.");
	XCTAssertNotNil([result member:elements[24]], @"Element 24 is not found in the result");
	XCTAssertNotEqual([result member:elements[24]], elements[24]);
	XCTAssertEqualObjects([result member:elements[24]], elements[24]);
}

- (void)testNSMutableOrderedSet_copyRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableOrderedSet *reference = [NSMutableOrderedSet orderedSetWithArray:elements];
	
	NSOrderedSet *result = [reference copyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSOrderedSet.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableOrderedSet.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertNotEqual(result[12], reference[12]);	//NSMutableCharacterSet
		XCTAssertEqualObjects(result[12], reference[12]);
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertNotEqual(result[17], reference[17]);
	XCTAssertEqualObjects(result[17], reference[17]);
	XCTAssertNotEqual(result[18], reference[18]);
	XCTAssertTrue([result[18] isEqual:reference[18]]);
	XCTAssertEqualObjects(result[18], reference[18]);
	XCTAssertNotEqual(result[19], reference[19]);
	XCTAssertEqualObjects(result[19], reference[19]);
	XCTAssertNotEqual(result[20], reference[20]);
	XCTAssertEqualObjects(result[20], reference[20]);
	XCTAssertNotEqual(result[21], reference[21]);
	XCTAssertEqualObjects(result[21], reference[21]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertNotEqual(result[24], reference[24]);
	XCTAssertEqualObjects(result[24], reference[24]);
}

- (void)testNSMutableArray_copyRecursive_Correctness {
	
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableArray *reference = [NSMutableArray arrayWithArray:elements];
	
	NSArray *result = [reference copyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSArray.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableArray.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertNotEqual(result[12], reference[12]); //NSMutableCharacterSet is NOT converted
		XCTAssertEqualObjects(result[12], reference[12]);
		
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertNotEqual(result[17], reference[17]);
	XCTAssertEqualObjects(result[17], reference[17]);
	XCTAssertNotEqual(result[18], reference[18]);
	XCTAssertTrue([result[18] isEqual:reference[18]]);
	XCTAssertEqual(((NSNumber*)result[18]).longLongValue, ((NSMutableNumber*)reference[18]).longLongValue);
	XCTAssertEqualObjects(result[18], reference[18]);
	XCTAssertNotEqual(result[19], reference[19]);
	XCTAssertEqualObjects(result[19], reference[19]);
	XCTAssertNotEqual(result[20], reference[20]);
	XCTAssertEqualObjects(result[20], reference[20]);
	XCTAssertNotEqual(result[21], reference[21]);
	XCTAssertEqualObjects(result[21], reference[21]);
	XCTAssertNotEqual(result[22], reference[22]);
	XCTAssertEqualObjects(result[22], reference[22]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertNotEqual(result[24], reference[24]);
	XCTAssertEqualObjects(result[24], reference[24]);
}

- (void)testNSMutableDictionary_copyRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSMutableDictionary *reference = [NSMutableDictionary dictionaryWithObjects:keyValues[1] forKeys:keyValues[0]];
	
	NSDictionary *result = [reference copyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSDictionary.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(result.count, keyValues[1].count);
	
	[result enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		id ref = [reference objectForKey:key];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[@"set_string"], reference[@"set_string"]);
	XCTAssertEqualObjects(result[@"set_string"], reference[@"set_string"]);
	XCTAssertNotEqual(result[@"set_array"], reference[@"set_array"]);
	XCTAssertEqualObjects(result[@"set_array"], reference[@"set_array"]);
	XCTAssertNotEqual(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertEqualObjects(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertNotEqual(result[@"array"], reference[@"array"]);
	XCTAssertEqualObjects(result[@"array"], reference[@"array"]);
	XCTAssertNotEqual(result[@"dictionary"], reference[@"dictionary"]);
	XCTAssertEqualObjects(result[@"dictionary"], reference[@"dictionary"]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[@"indexset"], reference[@"indexset"]);
		XCTAssertEqual(result[@"number"], reference[@"number"]);
		XCTAssertEqual(result[@"string"], reference[@"string"]);
		XCTAssertEqual(result[@"data"], reference[@"data"]);
		XCTAssertEqual(result[@"attributedstring"], reference[@"attributedstring"]);
		XCTAssertEqual(result[@"urlrequest"], reference[@"urlrequest"]);
		
		XCTAssertEqual(result[@"NScharset"], reference[@"NScharset"]);
		XCTAssertNotEqual(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
		XCTAssertEqualObjects(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
	}
	
	XCTAssertNotEqual(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertEqualObjects(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertNotEqual(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertEqualObjects(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertNotEqual(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertEqualObjects(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertNotEqual(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	XCTAssertEqualObjects(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	
	XCTAssertNotEqual(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertEqualObjects(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertNotEqual(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertEqualObjects(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertNotEqual(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertEqualObjects(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertNotEqual(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertEqualObjects(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertNotEqual(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertEqualObjects(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertNotEqual(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	XCTAssertEqualObjects(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	
	XCTAssertEqual(result[@"BEcharset"], reference[@"BEcharset"]);
	XCTAssertNotEqual(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
	XCTAssertEqualObjects(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
}


#pragma mark - BECollection copyCollectionRecursive

// Immutable Sets

- (void)testNSSet_copyCollectionRecursive_Correctness
{
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSSet *reference = [NSSet setWithArray:elements];
	
	NSSet *result = [reference copyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSSet.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableSet.class]);
	XCTAssertEqual(result.count, reference.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
		BOOL contains = [reference containsObject:obj];
		
		XCTAssertTrue(contains);
		if (contains) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				// All Collections must be immutable
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual([result member:elements[0]], elements[0]);
	XCTAssertEqualObjects([result member:elements[0]], elements[0]);
	XCTAssertNotEqual([result member:elements[1]], elements[1]);
	XCTAssertEqualObjects([result member:elements[1]], elements[1]);
	XCTAssertNotEqual([result member:elements[2]], elements[2]);
	XCTAssertEqualObjects([result member:elements[2]], elements[2]);
	XCTAssertNotEqual([result member:elements[3]], elements[3]);
	XCTAssertEqualObjects([result member:elements[3]], elements[3]);
	XCTAssertNotEqual([result member:elements[4]], elements[4]);
	XCTAssertEqualObjects([result member:elements[4]], elements[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual([result member:elements[5]], elements[5]);
		XCTAssertEqual([result member:elements[6]], elements[6]);
		XCTAssertEqual([result member:elements[7]], elements[7]);
		XCTAssertEqual([result member:elements[8]], elements[8]);
		XCTAssertEqual([result member:elements[9]], elements[9]);
		XCTAssertEqual([result member:elements[10]], elements[10]);
		
		XCTAssertEqual([result member:elements[11]], elements[11]);
		XCTAssertEqual([result member:elements[12]], elements[12]);	//NSMutableCharacterSet
	}
	
	XCTAssertNotEqual([result member:elements[13]], elements[13]);
	XCTAssertEqualObjects([result member:elements[13]], elements[13]);
	XCTAssertNotEqual([result member:elements[14]], elements[14]);
	XCTAssertEqualObjects([result member:elements[14]], elements[14]);
	XCTAssertNotEqual([result member:elements[15]], elements[15]);
	XCTAssertEqualObjects([result member:elements[15]], elements[15]);
	XCTAssertNotEqual([result member:elements[16]], elements[16]);
	XCTAssertEqualObjects([result member:elements[16]], elements[16]);
	
	XCTAssertEqual([result member:elements[17]], elements[17]);
	XCTAssertEqual([result member:elements[18]], elements[18]);
	XCTAssertEqual([result member:elements[19]], elements[19]);
	XCTAssertEqual([result member:elements[20]], elements[20]);
	XCTAssertEqual([result member:elements[21]], elements[21]);
	XCTAssertEqual([result member:elements[22]], elements[22]);
	
	XCTAssertEqual([result member:elements[23]], elements[23]);
	XCTAssertEqual([result member:elements[24]], elements[24]);
}

- (void)testNSOrderedSet_copyCollectionRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSOrderedSet *reference = [NSOrderedSet orderedSetWithArray:elements];
	
	NSOrderedSet *result = [reference copyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSOrderedSet.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableOrderedSet.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertEqual(result[12], reference[12]);	//NSMutableCharacterSet
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertEqual(result[17], reference[17]);
	XCTAssertEqual(result[18], reference[18]);
	XCTAssertEqual(result[19], reference[19]);
	XCTAssertEqual(result[20], reference[20]);
	XCTAssertEqual(result[21], reference[21]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertEqual(result[24], reference[24]);
}

- (void)testNSArray_copyCollectionRecursive_Correctness {
	
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSArray *reference = [NSArray arrayWithArray:elements];
	
	NSArray *result = [reference copyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSArray.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableArray.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertEqual(result[12], reference[12]); //NSMutableCharacterSet is not converted
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertEqual(result[17], reference[17]);
	XCTAssertEqual(result[18], reference[18]);
	XCTAssertEqual(result[19], reference[19]);
	XCTAssertEqual(result[20], reference[20]);
	XCTAssertEqual(result[21], reference[21]);
	XCTAssertEqual(result[22], reference[22]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertEqual(result[24], reference[24]);
}

- (void)testNSDictionary_copyCollectionRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSDictionary *reference = [NSDictionary dictionaryWithObjects:keyValues[1] forKeys:keyValues[0]];
	
	NSDictionary *result = [reference copyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSDictionary.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(result.count, keyValues[1].count);
	
	[result enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		id ref = [reference objectForKey:key];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[@"set_string"], reference[@"set_string"]);
	XCTAssertEqualObjects(result[@"set_string"], reference[@"set_string"]);
	XCTAssertNotEqual(result[@"set_array"], reference[@"set_array"]);
	XCTAssertEqualObjects(result[@"set_array"], reference[@"set_array"]);
	XCTAssertNotEqual(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertEqualObjects(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertNotEqual(result[@"array"], reference[@"array"]);
	XCTAssertEqualObjects(result[@"array"], reference[@"array"]);
	XCTAssertNotEqual(result[@"dictionary"], reference[@"dictionary"]);
	XCTAssertEqualObjects(result[@"dictionary"], reference[@"dictionary"]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[@"indexset"], reference[@"indexset"]);
		XCTAssertEqual(result[@"number"], reference[@"number"]);
		XCTAssertEqual(result[@"string"], reference[@"string"]);
		XCTAssertEqual(result[@"data"], reference[@"data"]);
		XCTAssertEqual(result[@"attributedstring"], reference[@"attributedstring"]);
		XCTAssertEqual(result[@"urlrequest"], reference[@"urlrequest"]);
		
		XCTAssertEqual(result[@"NScharset"], reference[@"NScharset"]);
		XCTAssertEqual(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
	}
	
	XCTAssertNotEqual(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertEqualObjects(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertNotEqual(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertEqualObjects(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertNotEqual(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertEqualObjects(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertNotEqual(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	XCTAssertEqualObjects(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	
	XCTAssertEqual(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertEqual(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertEqual(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertEqual(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertEqual(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertEqual(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	
	XCTAssertEqual(result[@"BEcharset"], reference[@"BEcharset"]);
	XCTAssertEqual(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
}

//Mutable Collections

- (void)testNSMutableSet_copyCollectionRecursive_Correctness
{
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableSet *reference = [NSMutableSet setWithArray:elements];
	
	NSSet *result = [reference copyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSSet.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableSet.class]);
	XCTAssertEqual(result.count, reference.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
		BOOL contains = [reference containsObject:obj];
		
		XCTAssertTrue(contains);
		if (contains) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				// All Collections must be immutable
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual([result member:elements[0]], elements[0]);
	XCTAssertEqualObjects([result member:elements[0]], elements[0]);
	XCTAssertNotEqual([result member:elements[1]], elements[1]);
	XCTAssertEqualObjects([result member:elements[1]], elements[1]);
	XCTAssertNotEqual([result member:elements[2]], elements[2]);
	XCTAssertEqualObjects([result member:elements[2]], elements[2]);
	XCTAssertNotEqual([result member:elements[3]], elements[3]);
	XCTAssertEqualObjects([result member:elements[3]], elements[3]);
	XCTAssertNotEqual([result member:elements[4]], elements[4]);
	XCTAssertEqualObjects([result member:elements[4]], elements[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual([result member:elements[5]], elements[5]);
		XCTAssertEqual([result member:elements[6]], elements[6]);
		XCTAssertEqual([result member:elements[7]], elements[7]);
		XCTAssertEqual([result member:elements[8]], elements[8]);
		XCTAssertEqual([result member:elements[9]], elements[9]);
		XCTAssertEqual([result member:elements[10]], elements[10]);
		
		XCTAssertEqual([result member:elements[11]], elements[11]);
		XCTAssertEqual([result member:elements[12]], elements[12]);	//NSMutableCharacterSet
	}
	
	XCTAssertNotEqual([result member:elements[13]], elements[13]);
	XCTAssertEqualObjects([result member:elements[13]], elements[13]);
	XCTAssertNotEqual([result member:elements[14]], elements[14]);
	XCTAssertEqualObjects([result member:elements[14]], elements[14]);
	XCTAssertNotEqual([result member:elements[15]], elements[15]);
	XCTAssertEqualObjects([result member:elements[15]], elements[15]);
	XCTAssertNotEqual([result member:elements[16]], elements[16]);
	XCTAssertEqualObjects([result member:elements[16]], elements[16]);
	
	XCTAssertEqual([result member:elements[17]], elements[17]);
	XCTAssertEqual([result member:elements[18]], elements[18]);
	XCTAssertEqual([result member:elements[19]], elements[19]);
	XCTAssertEqual([result member:elements[20]], elements[20]);
	XCTAssertEqual([result member:elements[21]], elements[21]);
	XCTAssertEqual([result member:elements[22]], elements[22]);
	
	XCTAssertEqual([result member:elements[23]], elements[23]);
	XCTAssertEqual([result member:elements[24]], elements[24]);
}

- (void)testNSMutableOrderedSet_copyCollectionRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableOrderedSet *reference = [NSMutableOrderedSet orderedSetWithArray:elements];
	
	NSOrderedSet *result = [reference copyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSOrderedSet.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableOrderedSet.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertEqual(result[12], reference[12]);	//NSMutableCharacterSet
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertEqual(result[17], reference[17]);
	XCTAssertEqual(result[18], reference[18]);
	XCTAssertEqual(result[19], reference[19]);
	XCTAssertEqual(result[20], reference[20]);
	XCTAssertEqual(result[21], reference[21]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertEqual(result[24], reference[24]);
}

- (void)testNSMutableArray_copyCollectionRecursive_Correctness {
	
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableArray *reference = [NSMutableArray arrayWithArray:elements];
	
	NSArray *result = [reference copyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSArray.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableArray.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertEqual(result[12], reference[12]); //NSMutableCharacterSet is NOT converted
		
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertEqual(result[17], reference[17]);
	XCTAssertEqual(result[18], reference[18]);
	XCTAssertEqual(result[19], reference[19]);
	XCTAssertEqual(result[20], reference[20]);
	XCTAssertEqual(result[21], reference[21]);
	XCTAssertEqual(result[22], reference[22]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertEqual(result[24], reference[24]);
}

- (void)testNSMutableDictionary_copyCollectionRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSMutableDictionary *reference = [NSMutableDictionary dictionaryWithObjects:keyValues[1] forKeys:keyValues[0]];
	
	NSDictionary *result = [reference copyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSDictionary.class]);
	XCTAssertFalse([result isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(result.count, keyValues[1].count);
	
	[result enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		id ref = [reference objectForKey:key];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[@"set_string"], reference[@"set_string"]);
	XCTAssertEqualObjects(result[@"set_string"], reference[@"set_string"]);
	XCTAssertNotEqual(result[@"set_array"], reference[@"set_array"]);
	XCTAssertEqualObjects(result[@"set_array"], reference[@"set_array"]);
	XCTAssertNotEqual(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertEqualObjects(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertNotEqual(result[@"array"], reference[@"array"]);
	XCTAssertEqualObjects(result[@"array"], reference[@"array"]);
	XCTAssertNotEqual(result[@"dictionary"], reference[@"dictionary"]);
	XCTAssertEqualObjects(result[@"dictionary"], reference[@"dictionary"]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[@"indexset"], reference[@"indexset"]);
		XCTAssertEqual(result[@"number"], reference[@"number"]);
		XCTAssertEqual(result[@"string"], reference[@"string"]);
		XCTAssertEqual(result[@"data"], reference[@"data"]);
		XCTAssertEqual(result[@"attributedstring"], reference[@"attributedstring"]);
		XCTAssertEqual(result[@"urlrequest"], reference[@"urlrequest"]);
		
		XCTAssertEqual(result[@"NScharset"], reference[@"NScharset"]);
		XCTAssertEqual(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
	}
	
	XCTAssertNotEqual(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertEqualObjects(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertNotEqual(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertEqualObjects(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertNotEqual(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertEqualObjects(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertNotEqual(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	XCTAssertEqualObjects(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	
	XCTAssertEqual(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertEqual(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertEqual(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertEqual(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertEqual(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertEqual(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	
	XCTAssertEqual(result[@"BEcharset"], reference[@"BEcharset"]);
	XCTAssertEqual(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
}

#pragma mark - BECollection mutableCopyRecursive

// Immutable Sets

- (void)testNSSet_mutableCopyRecursive_Correctness
{
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSSet *reference = [NSSet setWithArray:elements];
	
	NSSet *result = [reference mutableCopyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableSet.class]);
	XCTAssertEqual(result.count, reference.count);
	
	[reference enumerateObjectsUsingBlock:^(id  _Nonnull ref, BOOL * _Nonnull stop) {
		BOOL contains = [result containsObject:ref];
		
		XCTAssertTrue(contains);
		if (contains) {
			id obj = [result member:ref];
			XCTAssertNotNil(obj);
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				// All Collections must be immutable
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual([result member:elements[0]], elements[0]);
	XCTAssertEqualObjects([result member:elements[0]], elements[0]);
	XCTAssertNotEqual([result member:elements[1]], elements[1]);
	XCTAssertEqualObjects([result member:elements[1]], elements[1]);
	XCTAssertNotEqual([result member:elements[2]], elements[2]);
	XCTAssertEqualObjects([result member:elements[2]], elements[2]);
	XCTAssertNotEqual([result member:elements[3]], elements[3]);
	XCTAssertEqualObjects([result member:elements[3]], elements[3]);
	XCTAssertNotEqual([result member:elements[4]], elements[4]);
	XCTAssertEqualObjects([result member:elements[4]], elements[4]);
	
	//Immutable objects become mutable, not the same
	{
		XCTAssertNotEqual([result member:elements[5]], elements[5]);
		XCTAssertEqualObjects([result member:elements[5]], elements[5]);
		XCTAssertNotEqual([result member:elements[6]], elements[6]);
		XCTAssertEqualObjects([result member:elements[6]], elements[6]);
		XCTAssertNotEqual([result member:elements[7]], elements[7]);
		XCTAssertEqualObjects([result member:elements[7]], elements[7]);
		XCTAssertNotEqual([result member:elements[8]], elements[8]);
		XCTAssertEqualObjects([result member:elements[8]], elements[8]);
		XCTAssertNotEqual([result member:elements[9]], elements[9]);
		XCTAssertEqualObjects([result member:elements[9]], elements[9]);
		XCTAssertNotEqual([result member:elements[10]], elements[10]);
		XCTAssertEqualObjects([result member:elements[10]], elements[10]);
		
		XCTAssertNotEqual([result member:elements[11]], elements[11]);
		XCTAssertEqualObjects([result member:elements[11]], elements[11]);
		XCTAssertNotEqual([result member:elements[12]], elements[12]);
		XCTAssertEqualObjects([result member:elements[12]], elements[12]);	//NSMutableCharacterSet
	}
	
	XCTAssertNotEqual([result member:elements[13]], elements[13]);
	XCTAssertEqualObjects([result member:elements[13]], elements[13]);
	XCTAssertNotEqual([result member:elements[14]], elements[14]);
	XCTAssertEqualObjects([result member:elements[14]], elements[14]);
	XCTAssertNotEqual([result member:elements[15]], elements[15]);
	XCTAssertEqualObjects([result member:elements[15]], elements[15]);
	XCTAssertNotEqual([result member:elements[16]], elements[16]);
	XCTAssertEqualObjects([result member:elements[16]], elements[16]);
	
	XCTAssertNotEqual([result member:elements[17]], elements[17]);
	XCTAssertEqualObjects([result member:elements[17]], elements[17]);
	XCTAssertNotEqual([result member:elements[18]], elements[18]);
	XCTAssertEqualObjects([result member:elements[18]], elements[18]);
	XCTAssertNotEqual([result member:elements[19]], elements[19]);
	XCTAssertEqualObjects([result member:elements[19]], elements[19]);
	XCTAssertNotEqual([result member:elements[20]], elements[20]);
	XCTAssertEqualObjects([result member:elements[20]], elements[20]);
	XCTAssertNotEqual([result member:elements[21]], elements[21]);
	XCTAssertEqualObjects([result member:elements[21]], elements[21]);
	XCTAssertNotEqual([result member:elements[22]], elements[22]);
	XCTAssertEqualObjects([result member:elements[22]], elements[22]);
	
	NSArray *resultElements = [result allObjects];
	
	XCTAssertNotNil(elements[23], @"Element 23 is missing.");
	XCTAssertEqualObjects([elements[23] className], @"BECharacterSet");
	XCTAssertNotNil([result member:elements[23]], @"Element 23 is not found in the result");
	XCTAssertNotEqual([result member:elements[23]], elements[23]);
	BOOL same = [[result member:elements[23]] isEqual:elements[23]];
	XCTAssertTrue([[result member:elements[23]] isEqual:elements[23]]);
	XCTAssertEqualObjects([result member:elements[23]], elements[23]);
	
	XCTAssertNotEqual([result member:elements[24]], elements[24]);
	XCTAssertEqualObjects([result member:elements[24]], elements[24]);
}

- (void)testNSOrderedSet_mutableCopyRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSOrderedSet *reference = [NSOrderedSet orderedSetWithArray:elements];
	
	NSOrderedSet *result = [reference mutableCopyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableOrderedSet.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects become mutable, not the same
	{
		XCTAssertNotEqual(result[5], reference[5]);
		XCTAssertEqualObjects(result[5], reference[5]);
		XCTAssertNotEqual(result[6], reference[6]);
		XCTAssertEqualObjects(result[6], reference[6]);
		XCTAssertNotEqual(result[7], reference[7]);
		XCTAssertEqualObjects(result[7], reference[7]);
		XCTAssertNotEqual(result[8], reference[8]);
		XCTAssertEqualObjects(result[8], reference[8]);
		XCTAssertNotEqual(result[9], reference[9]);
		XCTAssertEqualObjects(result[9], reference[9]);
		XCTAssertNotEqual(result[10], reference[10]);
		XCTAssertEqualObjects(result[10], reference[10]);
		
		XCTAssertNotEqual(result[11], reference[11]);
		XCTAssertEqualObjects(result[11], reference[11]);
		XCTAssertNotEqual(result[12], reference[12]);	//NSMutableCharacterSet
		XCTAssertEqualObjects(result[12], reference[12]);
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertNotEqual(result[17], reference[17]);
	XCTAssertEqualObjects(result[17], reference[17]);
	XCTAssertNotEqual(result[18], reference[18]);
	XCTAssertEqualObjects(result[18], reference[18]);
	XCTAssertNotEqual(result[19], reference[19]);
	XCTAssertEqualObjects(result[19], reference[19]);
	XCTAssertNotEqual(result[20], reference[20]);
	XCTAssertEqualObjects(result[20], reference[20]);
	XCTAssertNotEqual(result[21], reference[21]);
	XCTAssertEqualObjects(result[21], reference[21]);
	
	XCTAssertNotEqual(result[23], reference[23]);
	XCTAssertEqualObjects(result[23], reference[23]);
	XCTAssertNotEqual(result[24], reference[24]);
	XCTAssertEqualObjects(result[24], reference[24]);
}

- (void)testNSArray_mutableCopyRecursive_Correctness {
	
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSArray *reference = [NSArray arrayWithArray:elements];
	
	NSArray *result = [reference mutableCopyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableArray.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertNotEqual(result[5], reference[5]);
		XCTAssertEqualObjects(result[5], reference[5]);
		XCTAssertNotEqual(result[6], reference[6]);
		XCTAssertEqualObjects(result[6], reference[6]);
		XCTAssertNotEqual(result[7], reference[7]);
		XCTAssertEqualObjects(result[7], reference[7]);
		XCTAssertNotEqual(result[8], reference[8]);
		XCTAssertEqualObjects(result[8], reference[8]);
		XCTAssertNotEqual(result[9], reference[9]);
		XCTAssertEqualObjects(result[9], reference[9]);
		XCTAssertNotEqual(result[10], reference[10]);
		XCTAssertEqualObjects(result[10], reference[10]);
		
		XCTAssertNotEqual(result[11], reference[11]);
		XCTAssertEqualObjects(result[11], reference[11]);
		XCTAssertNotEqual(result[12], reference[12]); //NSMutableCharacterSet is not converted
		XCTAssertEqualObjects(result[12], reference[12]);
		
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertNotEqual(result[17], reference[17]);
	XCTAssertEqualObjects(result[17], reference[17]);
	XCTAssertNotEqual(result[18], reference[18]);
	XCTAssertEqualObjects(result[18], reference[18]);
	XCTAssertNotEqual(result[19], reference[19]);
	XCTAssertEqualObjects(result[19], reference[19]);
	XCTAssertNotEqual(result[20], reference[20]);
	XCTAssertEqualObjects(result[20], reference[20]);
	XCTAssertNotEqual(result[21], reference[21]);
	XCTAssertEqualObjects(result[21], reference[21]);
	XCTAssertNotEqual(result[22], reference[22]);
	XCTAssertEqualObjects(result[22], reference[22]);
	
	XCTAssertNotEqual(result[23], reference[23]);
	XCTAssertEqualObjects(result[23], reference[23]);
	XCTAssertNotEqual(result[24], reference[24]);
	XCTAssertEqualObjects(result[24], reference[24]);
}

- (void)testNSDictionary_mutableCopyRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSDictionary *reference = [NSDictionary dictionaryWithObjects:keyValues[1] forKeys:keyValues[0]];
	
	NSDictionary *result = [reference mutableCopyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(result.count, keyValues[1].count);
	
	[result enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		id ref = [reference objectForKey:key];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[@"set_string"], reference[@"set_string"]);
	XCTAssertEqualObjects(result[@"set_string"], reference[@"set_string"]);
	XCTAssertNotEqual(result[@"set_array"], reference[@"set_array"]);
	XCTAssertEqualObjects(result[@"set_array"], reference[@"set_array"]);
	XCTAssertNotEqual(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertEqualObjects(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertNotEqual(result[@"array"], reference[@"array"]);
	XCTAssertEqualObjects(result[@"array"], reference[@"array"]);
	XCTAssertNotEqual(result[@"dictionary"], reference[@"dictionary"]);
	XCTAssertEqualObjects(result[@"dictionary"], reference[@"dictionary"]);
	
	//Immutable objects are the same
	{
		XCTAssertNotEqual(result[@"indexset"], reference[@"indexset"]);
		XCTAssertEqualObjects(result[@"indexset"], reference[@"indexset"]);
		XCTAssertNotEqual(result[@"number"], reference[@"number"]);
		XCTAssertEqualObjects(result[@"number"], reference[@"number"]);
		XCTAssertNotEqual(result[@"string"], reference[@"string"]);
		XCTAssertEqualObjects(result[@"string"], reference[@"string"]);
		XCTAssertNotEqual(result[@"data"], reference[@"data"]);
		XCTAssertEqualObjects(result[@"data"], reference[@"data"]);
		XCTAssertNotEqual(result[@"attributedstring"], reference[@"attributedstring"]);
		XCTAssertEqualObjects(result[@"attributedstring"], reference[@"attributedstring"]);
		XCTAssertNotEqual(result[@"urlrequest"], reference[@"urlrequest"]);
		XCTAssertEqualObjects(result[@"urlrequest"], reference[@"urlrequest"]);
		
		XCTAssertNotEqual(result[@"NScharset"], reference[@"NScharset"]);
		XCTAssertEqualObjects(result[@"NScharset"], reference[@"NScharset"]);
		XCTAssertNotEqual(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
		XCTAssertEqualObjects(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
	}
	
	XCTAssertNotEqual(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertEqualObjects(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertNotEqual(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertEqualObjects(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertNotEqual(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertEqualObjects(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertNotEqual(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	XCTAssertEqualObjects(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	
	XCTAssertNotEqual(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertEqualObjects(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertNotEqual(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertEqualObjects(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertNotEqual(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertEqualObjects(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertNotEqual(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertEqualObjects(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertNotEqual(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertEqualObjects(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertNotEqual(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	XCTAssertEqualObjects(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	
	XCTAssertNotEqual(result[@"BEcharset"], reference[@"BEcharset"]);
	XCTAssertEqualObjects(result[@"BEcharset"], reference[@"BEcharset"]);
	XCTAssertNotEqual(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
	XCTAssertEqualObjects(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
}

//Mutable Collections

- (void)testNSMutableSet_mutableCopyRecursive_Correctness
{
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableSet *reference = [NSMutableSet setWithArray:elements];
	
	NSSet *result = [reference mutableCopyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableSet.class]);
	XCTAssertEqual(result.count, reference.count);
	
	[reference enumerateObjectsUsingBlock:^(id  _Nonnull ref, BOOL * _Nonnull stop) {
		BOOL contains = [result containsObject:ref];
		
		XCTAssertTrue(contains);
		if (contains) {
			id obj = [result member:ref];
			XCTAssertNotNil(obj);
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				// All Collections must be immutable
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual([result member:elements[0]], elements[0]);
	XCTAssertEqualObjects([result member:elements[0]], elements[0]);
	XCTAssertNotEqual([result member:elements[1]], elements[1]);
	XCTAssertEqualObjects([result member:elements[1]], elements[1]);
	XCTAssertNotEqual([result member:elements[2]], elements[2]);
	XCTAssertEqualObjects([result member:elements[2]], elements[2]);
	XCTAssertNotEqual([result member:elements[3]], elements[3]);
	XCTAssertEqualObjects([result member:elements[3]], elements[3]);
	XCTAssertNotEqual([result member:elements[4]], elements[4]);
	XCTAssertEqualObjects([result member:elements[4]], elements[4]);
	
	//Immutable objects are the same
	{
		XCTAssertNotEqual([result member:elements[5]], elements[5]);
		XCTAssertEqualObjects([result member:elements[5]], elements[5]);
		XCTAssertNotEqual([result member:elements[6]], elements[6]);
		XCTAssertEqualObjects([result member:elements[6]], elements[6]);
		XCTAssertNotEqual([result member:elements[7]], elements[7]);
		XCTAssertEqualObjects([result member:elements[7]], elements[7]);
		XCTAssertNotEqual([result member:elements[8]], elements[8]);
		XCTAssertEqualObjects([result member:elements[8]], elements[8]);
		XCTAssertNotEqual([result member:elements[9]], elements[9]);
		XCTAssertEqualObjects([result member:elements[9]], elements[9]);
		XCTAssertNotEqual([result member:elements[10]], elements[10]);
		XCTAssertEqualObjects([result member:elements[10]], elements[10]);
		
		XCTAssertNotEqual([result member:elements[11]], elements[11]);
		XCTAssertEqualObjects([result member:elements[11]], elements[11]);
		XCTAssertNotEqual([result member:elements[12]], elements[12]);	//NSMutableCharacterSet
		XCTAssertEqualObjects([result member:elements[12]], elements[12]);
	}
	
	XCTAssertNotEqual([result member:elements[13]], elements[13]);
	XCTAssertEqualObjects([result member:elements[13]], elements[13]);
	XCTAssertNotEqual([result member:elements[14]], elements[14]);
	XCTAssertEqualObjects([result member:elements[14]], elements[14]);
	XCTAssertNotEqual([result member:elements[15]], elements[15]);
	XCTAssertEqualObjects([result member:elements[15]], elements[15]);
	XCTAssertNotEqual([result member:elements[16]], elements[16]);
	XCTAssertEqualObjects([result member:elements[16]], elements[16]);
	
	XCTAssertNotEqual([result member:elements[17]], elements[17]);
	XCTAssertEqualObjects([result member:elements[17]], elements[17]);
	XCTAssertNotEqual([result member:elements[18]], elements[18]);
	XCTAssertEqualObjects([result member:elements[18]], elements[18]);
	XCTAssertNotEqual([result member:elements[19]], elements[19]);
	XCTAssertEqualObjects([result member:elements[19]], elements[19]);
	XCTAssertNotEqual([result member:elements[20]], elements[20]);
	XCTAssertEqualObjects([result member:elements[20]], elements[20]);
	XCTAssertNotEqual([result member:elements[21]], elements[21]);
	XCTAssertEqualObjects([result member:elements[21]], elements[21]);
	XCTAssertNotEqual([result member:elements[22]], elements[22]);
	XCTAssertEqualObjects([result member:elements[22]], elements[22]);
	
	
	XCTAssertNotNil(elements[23], @"Element 23 is missing.");
	XCTAssertNotNil([result member:elements[23]], @"Element 23 is not found in the result");
	XCTAssertNotEqual([result member:elements[23]], elements[23]);
	XCTAssertEqualObjects([result member:elements[23]], elements[23]);
	
	XCTAssertNotEqual([result member:elements[24]], elements[24]);
	XCTAssertEqualObjects([result member:elements[24]], elements[24]);
}

- (void)testNSMutableOrderedSet_mutableCopyRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableOrderedSet *reference = [NSMutableOrderedSet orderedSetWithArray:elements];
	
	NSOrderedSet *result = [reference mutableCopyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableOrderedSet.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertNotEqual(result[5], reference[5]);
		XCTAssertEqualObjects(result[5], reference[5]);
		XCTAssertNotEqual(result[6], reference[6]);
		XCTAssertEqualObjects(result[6], reference[6]);
		XCTAssertNotEqual(result[7], reference[7]);
		XCTAssertEqualObjects(result[7], reference[7]);
		XCTAssertNotEqual(result[8], reference[8]);
		XCTAssertEqualObjects(result[8], reference[8]);
		XCTAssertNotEqual(result[9], reference[9]);
		XCTAssertEqualObjects(result[9], reference[9]);
		XCTAssertNotEqual(result[10], reference[10]);
		XCTAssertEqualObjects(result[10], reference[10]);
		
		XCTAssertNotEqual(result[11], reference[11]);
		XCTAssertEqualObjects(result[11], reference[11]);
		XCTAssertNotEqual(result[12], reference[12]);	//NSMutableCharacterSet
		XCTAssertEqualObjects(result[12], reference[12]);
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertNotEqual(result[17], reference[17]);
	XCTAssertEqualObjects(result[17], reference[17]);
	XCTAssertNotEqual(result[18], reference[18]);
	XCTAssertEqualObjects(result[18], reference[18]);
	XCTAssertNotEqual(result[19], reference[19]);
	XCTAssertEqualObjects(result[19], reference[19]);
	XCTAssertNotEqual(result[20], reference[20]);
	XCTAssertEqualObjects(result[20], reference[20]);
	XCTAssertNotEqual(result[21], reference[21]);
	XCTAssertEqualObjects(result[21], reference[21]);
	
	XCTAssertNotEqual(result[23], reference[23]);
	XCTAssertEqualObjects(result[23], reference[23]);
	XCTAssertNotEqual(result[24], reference[24]);
	XCTAssertEqualObjects(result[24], reference[24]);
}

- (void)testNSMutableArray_mutableCopyRecursive_Correctness {
	
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableArray *reference = [NSMutableArray arrayWithArray:elements];
	
	NSArray *result = [reference mutableCopyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableArray.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertNotEqual(result[5], reference[5]);
		XCTAssertEqualObjects(result[5], reference[5]);
		XCTAssertNotEqual(result[6], reference[6]);
		XCTAssertEqualObjects(result[6], reference[6]);
		XCTAssertNotEqual(result[7], reference[7]);
		XCTAssertEqualObjects(result[7], reference[7]);
		XCTAssertNotEqual(result[8], reference[8]);
		XCTAssertEqualObjects(result[8], reference[8]);
		XCTAssertNotEqual(result[9], reference[9]);
		XCTAssertEqualObjects(result[9], reference[9]);
		XCTAssertNotEqual(result[10], reference[10]);
		XCTAssertEqualObjects(result[10], reference[10]);
		
		XCTAssertNotEqual(result[11], reference[11]);
		XCTAssertEqualObjects(result[11], reference[11]);
		XCTAssertNotEqual(result[12], reference[12]);	//NSMutableCharacterSet
		XCTAssertEqualObjects(result[12], reference[12]);
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertNotEqual(result[17], reference[17]);
	XCTAssertEqualObjects(result[17], reference[17]);
	XCTAssertNotEqual(result[18], reference[18]);
	XCTAssertEqualObjects(result[18], reference[18]);
	XCTAssertNotEqual(result[19], reference[19]);
	XCTAssertEqualObjects(result[19], reference[19]);
	XCTAssertNotEqual(result[20], reference[20]);
	XCTAssertEqualObjects(result[20], reference[20]);
	XCTAssertNotEqual(result[21], reference[21]);
	XCTAssertEqualObjects(result[21], reference[21]);
	XCTAssertNotEqual(result[22], reference[22]);
	XCTAssertEqualObjects(result[22], reference[22]);
	
	XCTAssertNotEqual(result[23], reference[23]);
	XCTAssertEqualObjects(result[23], reference[23]);
	XCTAssertNotEqual(result[24], reference[24]);
	XCTAssertEqualObjects(result[24], reference[24]);
}

- (void)testNSMutableDictionary_mutableCopyRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSMutableDictionary *reference = [NSMutableDictionary dictionaryWithObjects:keyValues[1] forKeys:keyValues[0]];
	
	NSDictionary *result = [reference mutableCopyRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(result.count, keyValues[1].count);
	
	[result enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		id ref = [reference objectForKey:key];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[@"set_string"], reference[@"set_string"]);
	XCTAssertEqualObjects(result[@"set_string"], reference[@"set_string"]);
	XCTAssertNotEqual(result[@"set_array"], reference[@"set_array"]);
	XCTAssertEqualObjects(result[@"set_array"], reference[@"set_array"]);
	XCTAssertNotEqual(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertEqualObjects(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertNotEqual(result[@"array"], reference[@"array"]);
	XCTAssertEqualObjects(result[@"array"], reference[@"array"]);
	XCTAssertNotEqual(result[@"dictionary"], reference[@"dictionary"]);
	XCTAssertEqualObjects(result[@"dictionary"], reference[@"dictionary"]);
	
	//Immutable objects are the same
	{
		XCTAssertNotEqual(result[@"indexset"], reference[@"indexset"]);
		XCTAssertEqualObjects(result[@"indexset"], reference[@"indexset"]);
		XCTAssertNotEqual(result[@"number"], reference[@"number"]);
		XCTAssertEqualObjects(result[@"number"], reference[@"number"]);
		XCTAssertNotEqual(result[@"string"], reference[@"string"]);
		XCTAssertEqualObjects(result[@"string"], reference[@"string"]);
		XCTAssertNotEqual(result[@"data"], reference[@"data"]);
		XCTAssertEqualObjects(result[@"data"], reference[@"data"]);
		XCTAssertNotEqual(result[@"attributedstring"], reference[@"attributedstring"]);
		XCTAssertEqualObjects(result[@"attributedstring"], reference[@"attributedstring"]);
		XCTAssertNotEqual(result[@"urlrequest"], reference[@"urlrequest"]);
		XCTAssertEqualObjects(result[@"urlrequest"], reference[@"urlrequest"]);
		
		XCTAssertNotEqual(result[@"NScharset"], reference[@"NScharset"]);
		XCTAssertEqualObjects(result[@"NScharset"], reference[@"NScharset"]);
		XCTAssertNotEqual(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
		XCTAssertEqualObjects(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
	}
	
	XCTAssertNotEqual(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertEqualObjects(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertNotEqual(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertEqualObjects(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertNotEqual(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertEqualObjects(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertNotEqual(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	XCTAssertEqualObjects(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	
	XCTAssertNotEqual(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertEqualObjects(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertNotEqual(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertEqualObjects(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertNotEqual(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertEqualObjects(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertNotEqual(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertEqualObjects(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertNotEqual(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertEqualObjects(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertNotEqual(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	XCTAssertEqualObjects(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	
	XCTAssertNotEqual(result[@"BEcharset"], reference[@"BEcharset"]);
	XCTAssertEqualObjects(result[@"BEcharset"], reference[@"BEcharset"]);
	XCTAssertNotEqual(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
	XCTAssertEqualObjects(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
}


#pragma mark - BECollection mutableCopyRecursive

// Immutable Sets

- (void)testNSSet_mutableCopyCollectionRecursive_Correctness
{
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSSet *reference = [NSSet setWithArray:elements];
	
	NSSet *result = [reference mutableCopyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableSet.class]);
	XCTAssertEqual(result.count, reference.count);
	
	[reference enumerateObjectsUsingBlock:^(id  _Nonnull ref, BOOL * _Nonnull stop) {
		BOOL contains = [result containsObject:ref];
		
		XCTAssertTrue(contains);
		if (contains) {
			id obj = [result member:ref];
			XCTAssertNotNil(obj);
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				// All Collections must be immutable
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual([result member:elements[0]], elements[0]);
	XCTAssertEqualObjects([result member:elements[0]], elements[0]);
	XCTAssertNotEqual([result member:elements[1]], elements[1]);
	XCTAssertEqualObjects([result member:elements[1]], elements[1]);
	XCTAssertNotEqual([result member:elements[2]], elements[2]);
	XCTAssertEqualObjects([result member:elements[2]], elements[2]);
	XCTAssertNotEqual([result member:elements[3]], elements[3]);
	XCTAssertEqualObjects([result member:elements[3]], elements[3]);
	XCTAssertNotEqual([result member:elements[4]], elements[4]);
	XCTAssertEqualObjects([result member:elements[4]], elements[4]);
	
	//Immutable objects become mutable, not the same
	{
		XCTAssertEqual([result member:elements[5]], elements[5]);
		XCTAssertEqual([result member:elements[6]], elements[6]);
		XCTAssertEqual([result member:elements[7]], elements[7]);
		XCTAssertEqual([result member:elements[8]], elements[8]);
		XCTAssertEqual([result member:elements[9]], elements[9]);
		XCTAssertEqual([result member:elements[10]], elements[10]);
		
		XCTAssertEqual([result member:elements[11]], elements[11]);
		XCTAssertEqual([result member:elements[12]], elements[12]);
	}
	
	XCTAssertNotEqual([result member:elements[13]], elements[13]);
	XCTAssertEqualObjects([result member:elements[13]], elements[13]);
	XCTAssertNotEqual([result member:elements[14]], elements[14]);
	XCTAssertEqualObjects([result member:elements[14]], elements[14]);
	XCTAssertNotEqual([result member:elements[15]], elements[15]);
	XCTAssertEqualObjects([result member:elements[15]], elements[15]);
	XCTAssertNotEqual([result member:elements[16]], elements[16]);
	XCTAssertEqualObjects([result member:elements[16]], elements[16]);
	
	XCTAssertEqual([result member:elements[17]], elements[17]);
	XCTAssertEqual([result member:elements[18]], elements[18]);
	XCTAssertEqual([result member:elements[19]], elements[19]);
	XCTAssertEqual([result member:elements[20]], elements[20]);
	XCTAssertEqual([result member:elements[21]], elements[21]);
	XCTAssertEqual([result member:elements[22]], elements[22]);
	
	XCTAssertEqual([result member:elements[23]], elements[23]);
	XCTAssertEqual([result member:elements[24]], elements[24]);
}

- (void)testNSOrderedSet_mutableCopyCollectionRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSOrderedSet *reference = [NSOrderedSet orderedSetWithArray:elements];
	
	NSOrderedSet *result = [reference mutableCopyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableOrderedSet.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BECollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects become mutable, not the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertEqual(result[12], reference[12]);	//NSMutableCharacterSet
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertEqual(result[17], reference[17]);
	XCTAssertEqual(result[18], reference[18]);
	XCTAssertEqual(result[19], reference[19]);
	XCTAssertEqual(result[20], reference[20]);
	XCTAssertEqual(result[21], reference[21]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertEqual(result[24], reference[24]);
}

- (void)testNSArray_mutableCopyCollectionRecursive_Correctness {
	
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSArray *reference = [NSArray arrayWithArray:elements];
	
	NSArray *result = [reference mutableCopyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableArray.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertEqual(result[12], reference[12]); //NSMutableCharacterSet is not converted
		
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertEqual(result[17], reference[17]);
	XCTAssertEqual(result[18], reference[18]);
	XCTAssertEqual(result[19], reference[19]);
	XCTAssertEqual(result[20], reference[20]);
	XCTAssertEqual(result[21], reference[21]);
	XCTAssertEqual(result[22], reference[22]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertEqual(result[24], reference[24]);
}

- (void)testNSDictionary_mutableCopyCollectionRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSDictionary *reference = [NSDictionary dictionaryWithObjects:keyValues[1] forKeys:keyValues[0]];
	
	NSDictionary *result = [reference mutableCopyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(result.count, keyValues[1].count);
	
	[result enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		id ref = [reference objectForKey:key];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[@"set_string"], reference[@"set_string"]);
	XCTAssertEqualObjects(result[@"set_string"], reference[@"set_string"]);
	XCTAssertNotEqual(result[@"set_array"], reference[@"set_array"]);
	XCTAssertEqualObjects(result[@"set_array"], reference[@"set_array"]);
	XCTAssertNotEqual(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertEqualObjects(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertNotEqual(result[@"array"], reference[@"array"]);
	XCTAssertEqualObjects(result[@"array"], reference[@"array"]);
	XCTAssertNotEqual(result[@"dictionary"], reference[@"dictionary"]);
	XCTAssertEqualObjects(result[@"dictionary"], reference[@"dictionary"]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[@"indexset"], reference[@"indexset"]);
		XCTAssertEqual(result[@"number"], reference[@"number"]);
		XCTAssertEqual(result[@"string"], reference[@"string"]);
		XCTAssertEqual(result[@"data"], reference[@"data"]);
		XCTAssertEqual(result[@"attributedstring"], reference[@"attributedstring"]);
		XCTAssertEqual(result[@"urlrequest"], reference[@"urlrequest"]);
		
		XCTAssertEqual(result[@"NScharset"], reference[@"NScharset"]);
		XCTAssertEqual(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
	}
	
	XCTAssertNotEqual(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertEqualObjects(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertNotEqual(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertEqualObjects(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertNotEqual(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertEqualObjects(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertNotEqual(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	XCTAssertEqualObjects(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	
	XCTAssertEqual(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertEqual(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertEqual(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertEqual(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertEqual(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertEqual(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	
	XCTAssertEqual(result[@"BEcharset"], reference[@"BEcharset"]);
	XCTAssertEqual(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
}

//Mutable Collections

- (void)testNSMutableSet_mutableCopyCollectionRecursive_Correctness
{
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableSet *reference = [NSMutableSet setWithArray:elements];
	
	NSSet *result = [reference mutableCopyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableSet.class]);
	XCTAssertEqual(result.count, reference.count);
	
	[reference enumerateObjectsUsingBlock:^(id  _Nonnull ref, BOOL * _Nonnull stop) {
		BOOL contains = [result containsObject:ref];
		
		XCTAssertTrue(contains);
		if (contains) {
			id obj = [result member:ref];
			XCTAssertNotNil(obj);
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				// All Collections must be immutable
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual([result member:elements[0]], elements[0]);
	XCTAssertEqualObjects([result member:elements[0]], elements[0]);
	XCTAssertNotEqual([result member:elements[1]], elements[1]);
	XCTAssertEqualObjects([result member:elements[1]], elements[1]);
	XCTAssertNotEqual([result member:elements[2]], elements[2]);
	XCTAssertEqualObjects([result member:elements[2]], elements[2]);
	XCTAssertNotEqual([result member:elements[3]], elements[3]);
	XCTAssertEqualObjects([result member:elements[3]], elements[3]);
	XCTAssertNotEqual([result member:elements[4]], elements[4]);
	XCTAssertEqualObjects([result member:elements[4]], elements[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual([result member:elements[5]], elements[5]);
		XCTAssertEqual([result member:elements[6]], elements[6]);
		XCTAssertEqual([result member:elements[7]], elements[7]);
		XCTAssertEqual([result member:elements[8]], elements[8]);
		XCTAssertEqual([result member:elements[9]], elements[9]);
		XCTAssertEqual([result member:elements[10]], elements[10]);
		
		XCTAssertEqual([result member:elements[11]], elements[11]);
		XCTAssertEqual([result member:elements[12]], elements[12]);	//NSMutableCharacterSet
	}
	
	XCTAssertNotEqual([result member:elements[13]], elements[13]);
	XCTAssertEqualObjects([result member:elements[13]], elements[13]);
	XCTAssertNotEqual([result member:elements[14]], elements[14]);
	XCTAssertEqualObjects([result member:elements[14]], elements[14]);
	XCTAssertNotEqual([result member:elements[15]], elements[15]);
	XCTAssertEqualObjects([result member:elements[15]], elements[15]);
	XCTAssertNotEqual([result member:elements[16]], elements[16]);
	XCTAssertEqualObjects([result member:elements[16]], elements[16]);
	
	XCTAssertEqual([result member:elements[17]], elements[17]);
	XCTAssertEqual([result member:elements[18]], elements[18]);
	XCTAssertEqual([result member:elements[19]], elements[19]);
	XCTAssertEqual([result member:elements[20]], elements[20]);
	XCTAssertEqual([result member:elements[21]], elements[21]);
	XCTAssertEqual([result member:elements[22]], elements[22]);
	
	XCTAssertEqual([result member:elements[23]], elements[23]);
	XCTAssertEqual([result member:elements[24]], elements[24]);
}

- (void)testNSMutableOrderedSet_mutableCopyCollectionRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableOrderedSet *reference = [NSMutableOrderedSet orderedSetWithArray:elements];
	
	NSOrderedSet *result = [reference mutableCopyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableOrderedSet.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertEqual(result[12], reference[12]);	//NSMutableCharacterSet
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertEqual(result[17], reference[17]);
	XCTAssertEqual(result[18], reference[18]);
	XCTAssertEqual(result[19], reference[19]);
	XCTAssertEqual(result[20], reference[20]);
	XCTAssertEqual(result[21], reference[21]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertEqual(result[24], reference[24]);
}

- (void)testNSMutableArray_mutableCopyCollectionRecursive_Correctness {
	
	NSArray *keyValues = [self arrayInstanceHelper];
	NSArray *elements = keyValues[1];
	NSMutableArray *reference = [NSMutableArray arrayWithArray:elements];
	
	NSArray *result = [reference mutableCopyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableArray.class]);
	XCTAssertEqual(result.count, elements.count);
	
	[result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
		id ref = [reference objectAtIndex:index];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[0], reference[0]);
	XCTAssertEqualObjects(result[0], reference[0]);
	XCTAssertNotEqual(result[1], reference[1]);
	XCTAssertEqualObjects(result[1], reference[1]);
	XCTAssertNotEqual(result[2], reference[2]);
	XCTAssertEqualObjects(result[2], reference[2]);
	XCTAssertNotEqual(result[3], reference[3]);
	XCTAssertEqualObjects(result[3], reference[3]);
	XCTAssertNotEqual(result[4], reference[4]);
	XCTAssertEqualObjects(result[4], reference[4]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[5], reference[5]);
		XCTAssertEqual(result[6], reference[6]);
		XCTAssertEqual(result[7], reference[7]);
		XCTAssertEqual(result[8], reference[8]);
		XCTAssertEqual(result[9], reference[9]);
		XCTAssertEqual(result[10], reference[10]);
		
		XCTAssertEqual(result[11], reference[11]);
		XCTAssertEqual(result[12], reference[12]);	//NSMutableCharacterSet
	}
	
	XCTAssertNotEqual(result[13], reference[13]);
	XCTAssertEqualObjects(result[13], reference[13]);
	XCTAssertNotEqual(result[14], reference[14]);
	XCTAssertEqualObjects(result[14], reference[14]);
	XCTAssertNotEqual(result[15], reference[15]);
	XCTAssertEqualObjects(result[15], reference[15]);
	XCTAssertNotEqual(result[16], reference[16]);
	XCTAssertEqualObjects(result[16], reference[16]);
	
	XCTAssertEqual(result[17], reference[17]);
	XCTAssertEqual(result[18], reference[18]);
	XCTAssertEqual(result[19], reference[19]);
	XCTAssertEqual(result[20], reference[20]);
	XCTAssertEqual(result[21], reference[21]);
	XCTAssertEqual(result[22], reference[22]);
	
	XCTAssertEqual(result[23], reference[23]);
	XCTAssertEqual(result[24], reference[24]);
}

- (void)testNSMutableDictionary_mutableCopyCollectionRecursive_Correctness {
	
	NSArray<NSArray*> *keyValues = [self arrayInstanceHelper];
	NSMutableDictionary *reference = [NSMutableDictionary dictionaryWithObjects:keyValues[1] forKeys:keyValues[0]];
	
	NSDictionary *result = [reference mutableCopyCollectionRecursive];
	
	XCTAssertNotEqual(result, reference);
	XCTAssertTrue([result isKindOfClass:NSMutableDictionary.class]);
	XCTAssertEqual(result.count, keyValues[1].count);
	
	[result enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		id ref = [reference objectForKey:key];
		BOOL equals = [obj isEqual:ref];
		
		XCTAssertTrue(equals);
		if (equals) {
			if([obj conformsToProtocol:@protocol(BECollectionAbstract)]) {
				XCTAssertTrue([obj conformsToProtocol:@protocol(BEMutableCollection)]);
			}
		}
	}];
	
	XCTAssertNotEqual(result[@"set_string"], reference[@"set_string"]);
	XCTAssertEqualObjects(result[@"set_string"], reference[@"set_string"]);
	XCTAssertNotEqual(result[@"set_array"], reference[@"set_array"]);
	XCTAssertEqualObjects(result[@"set_array"], reference[@"set_array"]);
	XCTAssertNotEqual(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertEqualObjects(result[@"orderedset"], reference[@"orderedset"]);
	XCTAssertNotEqual(result[@"array"], reference[@"array"]);
	XCTAssertEqualObjects(result[@"array"], reference[@"array"]);
	XCTAssertNotEqual(result[@"dictionary"], reference[@"dictionary"]);
	XCTAssertEqualObjects(result[@"dictionary"], reference[@"dictionary"]);
	
	//Immutable objects are the same
	{
		XCTAssertEqual(result[@"indexset"], reference[@"indexset"]);
		XCTAssertEqual(result[@"number"], reference[@"number"]);
		XCTAssertEqual(result[@"string"], reference[@"string"]);
		XCTAssertEqual(result[@"data"], reference[@"data"]);
		XCTAssertEqual(result[@"attributedstring"], reference[@"attributedstring"]);
		XCTAssertEqual(result[@"urlrequest"], reference[@"urlrequest"]);
		
		XCTAssertEqual(result[@"NScharset"], reference[@"NScharset"]);
		XCTAssertEqual(result[@"mutable_NScharset"], reference[@"mutable_NScharset"]);
	}
	
	XCTAssertNotEqual(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertEqualObjects(result[@"mutable_set"], reference[@"mutable_set"]);
	XCTAssertNotEqual(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertEqualObjects(result[@"mutable_orderedset"], reference[@"mutable_orderedset"]);
	XCTAssertNotEqual(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertEqualObjects(result[@"mutable_array"], reference[@"mutable_array"]);
	XCTAssertNotEqual(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	XCTAssertEqualObjects(result[@"mutable_dictionary"], reference[@"mutable_dictionary"]);
	
	XCTAssertEqual(result[@"mutable_indexset"], reference[@"mutable_indexset"]);
	XCTAssertEqual(result[@"mutable_number"], reference[@"mutable_number"]);
	XCTAssertEqual(result[@"mutable_string"], reference[@"mutable_string"]);
	XCTAssertEqual(result[@"mutable_data"], reference[@"mutable_data"]);
	XCTAssertEqual(result[@"mutable_attributedstring"], reference[@"mutable_attributedstring"]);
	XCTAssertEqual(result[@"mutable_urlrequest"], reference[@"mutable_urlrequest"]);
	
	XCTAssertEqual(result[@"BEcharset"], reference[@"BEcharset"]);
	XCTAssertEqual(result[@"mutable_BEcharset"], reference[@"mutable_BEcharset"]);
}

#pragma mark - Performance
/*
- (void)test PerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/

@end
