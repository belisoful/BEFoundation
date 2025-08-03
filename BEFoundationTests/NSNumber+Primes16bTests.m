//
//  NSSet+BExtension.m
//  BFoundationExtensionTests
//
//  Created by ~ ~ on 12/26/24.
//

#import <XCTest/XCTest.h>
#import <BEFoundation/NSNumber+Primes16b.h>

@interface NSNumberPrimes16bTests : XCTestCase

@end

@implementation NSNumberPrimes16bTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


#pragma mark - NSNumber Prime Number 16 bit Extension
#pragma mark Ceil Index Correctness Tests

- (void)testCeilPrimeIndex16
{
	//  testing 7 .. 11
	NSInteger i07 = [NSNumber ceilPrimeIndex16: 7];
	NSInteger i08 = [NSNumber ceilPrimeIndex16: 8];
	NSInteger i09 = [NSNumber ceilPrimeIndex16: 9];
	NSInteger i10 = [NSNumber ceilPrimeIndex16:10];
	NSInteger i11 = [NSNumber ceilPrimeIndex16:11];
	
	NSInteger outOf16bBounds = [NSNumber ceilPrimeIndex16:80000];
	
	XCTAssertEqual(i07, 4);
	XCTAssertEqual(i08, 5);
	XCTAssertEqual(i09, 5);
	XCTAssertEqual(i10, 5);
	XCTAssertEqual(i11, 5);
	XCTAssertEqual(outOf16bBounds, NSNotFound);
}

- (void)testCeilPrimeIndex16_LowerBound
{
	NSInteger in1 = [NSNumber ceilPrimeIndex16: -1];
	NSInteger i00 = [NSNumber ceilPrimeIndex16:  0];
	NSInteger i01 = [NSNumber ceilPrimeIndex16:  1];
	NSInteger i02 = [NSNumber ceilPrimeIndex16:  2];
	NSInteger i03 = [NSNumber ceilPrimeIndex16:  3];
	NSInteger i04 = [NSNumber ceilPrimeIndex16:  4];
	NSInteger i05 = [NSNumber ceilPrimeIndex16:  5];
	
	XCTAssertEqual(in1, NSNotFound);
	XCTAssertEqual(i00, NSNotFound);
	XCTAssertEqual(i01, 0);
	XCTAssertEqual(i02, 1);
	XCTAssertEqual(i03, 2);
	XCTAssertEqual(i04, 3);
	XCTAssertEqual(i05, 3);
}


- (void)testCeilPrimeIndex16_UpperBound
{
	NSInteger pmax_2 = [NSNumber ceilPrimeIndex16: UInt16LargestPrime - 2];
	NSInteger pmax_1 = [NSNumber ceilPrimeIndex16: UInt16LargestPrime - 1];
	NSInteger pmax = [NSNumber ceilPrimeIndex16: UInt16LargestPrime]; // 65521
	NSInteger pmax1 = [NSNumber ceilPrimeIndex16: UInt16LargestPrime + 1];
	NSInteger pmaxMid_1 = [NSNumber ceilPrimeIndex16: 65529 - 1];
	NSInteger pmaxMid = [NSNumber ceilPrimeIndex16: 65529];
	NSInteger pmaxMid1 = [NSNumber ceilPrimeIndex16: 65529 + 1];
	NSInteger u16Max_1 = [NSNumber ceilPrimeIndex16: 65535 - 1];
	NSInteger u16Max = [NSNumber ceilPrimeIndex16: 65535];
	NSInteger u16Max1 = [NSNumber ceilPrimeIndex16: 65535 + 1];
	NSInteger u16Max2p = [NSNumber ceilPrimeIndex16: 65535 + 2]; // first 17b prime
	NSInteger u16Max3 = [NSNumber ceilPrimeIndex16: 65535 + 3];
	
	XCTAssertEqual(pmax_2,		NSPrimeNumbers16BitCount - 1);
	
	XCTAssertEqual(pmax_1,		NSPrimeNumbers16BitCount);
	XCTAssertEqual(pmax,		NSPrimeNumbers16BitCount);
	
	XCTAssertEqual(pmax1,		NSNotFound);
	
	XCTAssertEqual(pmaxMid_1,	NSNotFound);
	XCTAssertEqual(pmaxMid,		NSNotFound);
	XCTAssertEqual(pmaxMid1,	NSNotFound);
	
	XCTAssertEqual(u16Max,		NSNotFound);
	XCTAssertEqual(u16Max_1,	NSNotFound);
	XCTAssertEqual(u16Max,		NSNotFound);
	
	XCTAssertEqual(u16Max1,		NSNotFound);
	XCTAssertEqual(u16Max2p,	NSNotFound);
	XCTAssertEqual(u16Max3,		NSNotFound);
}



#pragma mark Floor Index Correctness Tests

- (void)testFloorPrimeIndex16
{
	//  testing 7 .. 11
	NSInteger i07 = [NSNumber floorPrimeIndex16: 7];
	NSInteger i08 = [NSNumber floorPrimeIndex16: 8];
	NSInteger i09 = [NSNumber floorPrimeIndex16: 9];
	NSInteger i10 = [NSNumber floorPrimeIndex16:10];
	NSInteger i11 = [NSNumber floorPrimeIndex16:11];
	
	XCTAssertEqual(i07, 4);
	XCTAssertEqual(i08, 4);
	XCTAssertEqual(i09, 4);
	XCTAssertEqual(i10, 4);
	XCTAssertEqual(i11, 5);
}

- (void)testFloorPrimeIndex16_LowerBound
{
	NSInteger in1 = [NSNumber floorPrimeIndex16: -1];
	NSInteger i00 = [NSNumber floorPrimeIndex16:  0];
	NSInteger i01 = [NSNumber floorPrimeIndex16:  1];
	NSInteger i02 = [NSNumber floorPrimeIndex16:  2];
	NSInteger i03 = [NSNumber floorPrimeIndex16:  3];
	NSInteger i04 = [NSNumber floorPrimeIndex16:  4];
	NSInteger i05 = [NSNumber floorPrimeIndex16:  5];
	
	XCTAssertEqual(in1, NSNotFound);
	XCTAssertEqual(i00, NSNotFound);
	XCTAssertEqual(i01, 0);
	XCTAssertEqual(i02, 1);
	XCTAssertEqual(i03, 2);
	XCTAssertEqual(i04, 2);
	XCTAssertEqual(i05, 3);
}


- (void)testFloorPrimeIndex16_UpperBound
{
	NSInteger pmax_2 = [NSNumber floorPrimeIndex16: UInt16LargestPrime - 2];
	NSInteger pmax_1 = [NSNumber floorPrimeIndex16: UInt16LargestPrime - 1];
	NSInteger pmax = [NSNumber floorPrimeIndex16: UInt16LargestPrime]; // 65521
	NSInteger pmax1 = [NSNumber floorPrimeIndex16: UInt16LargestPrime + 1];
	NSInteger pmaxMid_1 = [NSNumber floorPrimeIndex16: 65529 - 1];
	NSInteger pmaxMid = [NSNumber floorPrimeIndex16: 65529];
	NSInteger pmaxMid1 = [NSNumber floorPrimeIndex16: 65529 + 1];
	NSInteger u16Max_1 = [NSNumber floorPrimeIndex16: 65535 - 1];
	NSInteger u16Max = [NSNumber floorPrimeIndex16: 65535];
	NSInteger u16Max1 = [NSNumber floorPrimeIndex16: 65535 + 1];
	NSInteger u16Max2p = [NSNumber floorPrimeIndex16: 65535 + 2]; // first 17b prime
	NSInteger u16Max3 = [NSNumber floorPrimeIndex16: 65535 + 3];
	
	XCTAssertEqual(pmax_2,		NSPrimeNumbers16BitCount - 1);
	
	XCTAssertEqual(pmax_1,		NSPrimeNumbers16BitCount - 1);
	XCTAssertEqual(pmax,		NSPrimeNumbers16BitCount);
	
	XCTAssertEqual(pmax1,		NSPrimeNumbers16BitCount);
	XCTAssertEqual(pmaxMid_1,	NSPrimeNumbers16BitCount);
	XCTAssertEqual(pmaxMid,		NSPrimeNumbers16BitCount);
	XCTAssertEqual(pmaxMid1,	NSPrimeNumbers16BitCount);
	XCTAssertEqual(u16Max,		NSPrimeNumbers16BitCount);
	XCTAssertEqual(u16Max_1,	NSPrimeNumbers16BitCount);
	XCTAssertEqual(u16Max,		NSPrimeNumbers16BitCount);
	XCTAssertEqual(u16Max1,		NSPrimeNumbers16BitCount);
	XCTAssertEqual(u16Max2p,	NSNotFound);
	XCTAssertEqual(u16Max3,		NSNotFound);
}



#pragma mark Round Index Correctness Tests

- (void)testRoundPrimeIndex16
{
	//  testing 7 .. 11
	NSInteger i07 = [NSNumber roundPrimeIndex16: 7];
	NSInteger i08 = [NSNumber roundPrimeIndex16: 8];
	NSInteger i09 = [NSNumber roundPrimeIndex16: 9];
	NSInteger i10 = [NSNumber roundPrimeIndex16:10];
	NSInteger i11 = [NSNumber roundPrimeIndex16:11];
	
	XCTAssertEqual(i07, 4);
	XCTAssertEqual(i08, 4);
	XCTAssertEqual(i09, 5);
	XCTAssertEqual(i10, 5);
	XCTAssertEqual(i11, 5);
}

- (void)testRoundPrimeIndex16_LowerBound
{
	NSInteger in1 = [NSNumber roundPrimeIndex16: -1];
	NSInteger i00 = [NSNumber roundPrimeIndex16:  0];
	NSInteger i01 = [NSNumber roundPrimeIndex16:  1];
	NSInteger i02 = [NSNumber roundPrimeIndex16:  2];
	NSInteger i03 = [NSNumber roundPrimeIndex16:  3];
	NSInteger i04 = [NSNumber roundPrimeIndex16:  4];
	NSInteger i05 = [NSNumber roundPrimeIndex16:  5];
	
	XCTAssertEqual(in1, NSNotFound);
	XCTAssertEqual(i00, NSNotFound);
	XCTAssertEqual(i01, 0);
	XCTAssertEqual(i02, 1);
	XCTAssertEqual(i03, 2);
	XCTAssertEqual(i04, 3);
	XCTAssertEqual(i05, 3);
}


- (void)testRoundPrimeIndex16_UpperBound
{
	NSInteger pmax_2 = [NSNumber roundPrimeIndex16: UInt16LargestPrime - 2];
	NSInteger pmax_1 = [NSNumber roundPrimeIndex16: UInt16LargestPrime - 1];
	NSInteger pmax = [NSNumber roundPrimeIndex16: UInt16LargestPrime]; // 65521
	NSInteger pmax1 = [NSNumber roundPrimeIndex16: UInt16LargestPrime + 1];
	NSInteger pmaxMid_1 = [NSNumber roundPrimeIndex16: 65529 - 1];
	NSInteger pmaxMid = [NSNumber roundPrimeIndex16: 65529];
	NSInteger pmaxMid1 = [NSNumber roundPrimeIndex16: 65529 + 1];
	NSInteger u16Max_1 = [NSNumber roundPrimeIndex16: 65535 - 1];
	NSInteger u16Max = [NSNumber roundPrimeIndex16: 65535];
	NSInteger u16Max1 = [NSNumber roundPrimeIndex16: 65535 + 1];
	NSInteger u16Max2p = [NSNumber roundPrimeIndex16: 65535 + 2]; // first 17b prime
	NSInteger u16Max3 = [NSNumber roundPrimeIndex16: 65535 + 3];
	
	XCTAssertEqual(pmax_2,		NSPrimeNumbers16BitCount - 1);
	
	XCTAssertEqual(pmax_1,		NSPrimeNumbers16BitCount);
	XCTAssertEqual(pmax,		NSPrimeNumbers16BitCount);
	
	XCTAssertEqual(pmax1,		NSPrimeNumbers16BitCount);
	XCTAssertEqual(pmaxMid_1,	NSPrimeNumbers16BitCount);
	XCTAssertEqual(pmaxMid,		NSNotFound);
	XCTAssertEqual(pmaxMid1,	NSNotFound);
	XCTAssertEqual(u16Max,		NSNotFound);
	XCTAssertEqual(u16Max_1,	NSNotFound);
	XCTAssertEqual(u16Max,		NSNotFound);
	XCTAssertEqual(u16Max1,		NSNotFound);
	XCTAssertEqual(u16Max2p,	NSNotFound);
	XCTAssertEqual(u16Max3,		NSNotFound);
}




#pragma mark - Round Value Correctness Tests

- (void)testRoundPrimeValue16
{
	//  testing 7 .. 11
	NSInteger i07 = [NSNumber roundPrimeValue16: 7];
	NSInteger i08 = [NSNumber roundPrimeValue16: 8];
	NSInteger i09 = [NSNumber roundPrimeValue16: 9];
	NSInteger i10 = [NSNumber roundPrimeValue16:10];
	NSInteger i11 = [NSNumber roundPrimeValue16:11];
	
	XCTAssertEqual(i07, 7);
	XCTAssertEqual(i08, 7);
	XCTAssertEqual(i09, 11);
	XCTAssertEqual(i10, 11);
	XCTAssertEqual(i11, 11);
}

- (void)testRoundPrimeValue16_LowerBound
{
	NSInteger in1 = [NSNumber roundPrimeValue16: -1];
	NSInteger i00 = [NSNumber roundPrimeValue16:  0];
	NSInteger i01 = [NSNumber roundPrimeValue16:  1];
	NSInteger i02 = [NSNumber roundPrimeValue16:  2];
	NSInteger i03 = [NSNumber roundPrimeValue16:  3];
	NSInteger i04 = [NSNumber roundPrimeValue16:  4];
	NSInteger i05 = [NSNumber roundPrimeValue16:  5];
	
	XCTAssertEqual(in1, 0);
	XCTAssertEqual(i00, 0);
	XCTAssertEqual(i01, 1);
	XCTAssertEqual(i02, 2);
	XCTAssertEqual(i03, 3);
	XCTAssertEqual(i04, 5);
	XCTAssertEqual(i05, 5);
}


- (void)testRoundPrimeValue16_UpperBound
{
	NSInteger pmax_2 = [NSNumber roundPrimeValue16: UInt16LargestPrime - 2];
	NSInteger pmax_1 = [NSNumber roundPrimeValue16: UInt16LargestPrime - 1];
	NSInteger pmax = [NSNumber roundPrimeValue16: UInt16LargestPrime]; // 65521
	NSInteger pmax1 = [NSNumber roundPrimeValue16: UInt16LargestPrime + 1];
	NSInteger pmaxMid_1 = [NSNumber roundPrimeValue16: 65529 - 1];
	NSInteger pmaxMid = [NSNumber roundPrimeValue16: 65529];
	NSInteger pmaxMid1 = [NSNumber roundPrimeValue16: 65529 + 1];
	NSInteger u16Max_1 = [NSNumber roundPrimeValue16: 65535 - 1];
	NSInteger u16Max = [NSNumber roundPrimeValue16: 65535];
	NSInteger u16Max1 = [NSNumber roundPrimeValue16: 65535 + 1];
	NSInteger u16Max2p = [NSNumber roundPrimeValue16: 65535 + 2]; // first 17b prime
	NSInteger u16Max3 = [NSNumber roundPrimeValue16: 65535 + 3];
	
	XCTAssertEqual(pmax_2,		UInt16LargestPrime - 2);
	
	XCTAssertEqual(pmax_1,		UInt16LargestPrime);
	XCTAssertEqual(pmax,		UInt16LargestPrime);
	
	XCTAssertEqual(pmax1,		UInt16LargestPrime);
	XCTAssertEqual(pmaxMid_1,	UInt16LargestPrime);
	XCTAssertEqual(pmaxMid,		0);
	XCTAssertEqual(pmaxMid1,	0);
	XCTAssertEqual(u16Max,		0);
	XCTAssertEqual(u16Max_1,	0);
	XCTAssertEqual(u16Max,		0);
	XCTAssertEqual(u16Max1,		0);
	XCTAssertEqual(u16Max2p,	0);
	XCTAssertEqual(u16Max3,		0);
}


#pragma mark Round NSNumber Correctness Tests

- (void)testRoundPrime16
{
	//  testing 7 .. 11
	NSNumber* i07 = [NSNumber roundPrime16: 7];
	NSNumber* i08 = [NSNumber roundPrime16: 8];
	NSNumber* i09 = [NSNumber roundPrime16: 9];
	NSNumber* i10 = [NSNumber roundPrime16:10];
	NSNumber* i11 = [NSNumber roundPrime16:11];
	
	XCTAssertTrue([i07 isKindOfClass:NSNumber.class]);
	XCTAssertEqualObjects(i07,  @(7));
	XCTAssertEqualObjects(i08,  @(7));
	XCTAssertEqualObjects(i09, @(11));
	XCTAssertEqualObjects(i10, @(11));
	XCTAssertEqualObjects(i11, @(11));
}

- (void)testRoundPrime16_LowerBound
{
	NSNumber* in1 = [NSNumber roundPrime16: -1];
	NSNumber* i00 = [NSNumber roundPrime16:  0];
	NSNumber* i01 = [NSNumber roundPrime16:  1];
	NSNumber* i02 = [NSNumber roundPrime16:  2];
	NSNumber* i03 = [NSNumber roundPrime16:  3];
	NSNumber* i04 = [NSNumber roundPrime16:  4];
	NSNumber* i05 = [NSNumber roundPrime16:  5];
	
	XCTAssertNil(in1);
	XCTAssertNil(i00);
	XCTAssertEqualObjects(i01, @(1));
	XCTAssertEqualObjects(i02, @(2));
	XCTAssertEqualObjects(i03, @(3));
	XCTAssertEqualObjects(i04, @(5));
	XCTAssertEqualObjects(i05, @(5));
}


- (void)testRoundPrime16_UpperBound
{
	NSNumber* pmax_2 = [NSNumber roundPrime16: UInt16LargestPrime - 2];
	NSNumber* pmax_1 = [NSNumber roundPrime16: UInt16LargestPrime - 1];
	NSNumber* pmax = [NSNumber roundPrime16: UInt16LargestPrime]; // 65521
	NSNumber* pmax1 = [NSNumber roundPrime16: UInt16LargestPrime + 1];
	NSNumber* pmaxMid_1 = [NSNumber roundPrime16: 65529 - 1];
	NSNumber* pmaxMid = [NSNumber roundPrime16: 65529];
	NSNumber* pmaxMid1 = [NSNumber roundPrime16: 65529 + 1];
	NSNumber* u16Max_1 = [NSNumber roundPrime16: 65535 - 1];
	NSNumber* u16Max = [NSNumber roundPrime16: 65535];
	NSNumber* u16Max1 = [NSNumber roundPrime16: 65535 + 1];
	NSNumber* u16Max2p = [NSNumber roundPrime16: 65535 + 2]; // first 17b prime
	NSNumber* u16Max3 = [NSNumber roundPrime16: 65535 + 3];
	
	XCTAssertEqualObjects(pmax_2,		@(UInt16LargestPrime - 2));
	
	XCTAssertEqualObjects(pmax_1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmax,		@(UInt16LargestPrime));
	
	XCTAssertEqualObjects(pmax1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmaxMid_1,	@(UInt16LargestPrime));
	XCTAssertNil(pmaxMid);
	XCTAssertNil(pmaxMid1);
	XCTAssertNil(u16Max);
	XCTAssertNil(u16Max_1);
	XCTAssertNil(u16Max);
	XCTAssertNil(u16Max1);
	XCTAssertNil(u16Max2p);
	XCTAssertNil(u16Max3);
}


#pragma mark - Floor Value Correctness Tests

- (void)testFloorPrimeValue16
{
	//  testing 7 .. 11
	NSInteger i07 = [NSNumber floorPrimeValue16: 7];
	NSInteger i08 = [NSNumber floorPrimeValue16: 8];
	NSInteger i09 = [NSNumber floorPrimeValue16: 9];
	NSInteger i10 = [NSNumber floorPrimeValue16:10];
	NSInteger i11 = [NSNumber floorPrimeValue16:11];
	
	XCTAssertEqual(i07,  7);
	XCTAssertEqual(i08,  7);
	XCTAssertEqual(i09,  7);
	XCTAssertEqual(i10,  7);
	XCTAssertEqual(i11, 11);
}

- (void)testFloorPrimeValue16_LowerBound
{
	NSInteger in1 = [NSNumber floorPrimeValue16: -1];
	NSInteger i00 = [NSNumber floorPrimeValue16:  0];
	NSInteger i01 = [NSNumber floorPrimeValue16:  1];
	NSInteger i02 = [NSNumber floorPrimeValue16:  2];
	NSInteger i03 = [NSNumber floorPrimeValue16:  3];
	NSInteger i04 = [NSNumber floorPrimeValue16:  4];
	NSInteger i05 = [NSNumber floorPrimeValue16:  5];
	
	XCTAssertEqual(in1, 0);
	XCTAssertEqual(i00, 0);
	XCTAssertEqual(i01, 1);
	XCTAssertEqual(i02, 2);
	XCTAssertEqual(i03, 3);
	XCTAssertEqual(i04, 3);
	XCTAssertEqual(i05, 5);
}


- (void)testFloorPrimeValue16_UpperBound
{
	NSInteger pmax_2 = [NSNumber floorPrimeValue16: UInt16LargestPrime - 2];
	NSInteger pmax_1 = [NSNumber floorPrimeValue16: UInt16LargestPrime - 1];
	NSInteger pmax = [NSNumber floorPrimeValue16: UInt16LargestPrime]; // 65521
	NSInteger pmax1 = [NSNumber floorPrimeValue16: UInt16LargestPrime + 1];
	NSInteger pmaxMid_1 = [NSNumber floorPrimeValue16: 65529 - 1];
	NSInteger pmaxMid = [NSNumber floorPrimeValue16: 65529];
	NSInteger pmaxMid1 = [NSNumber floorPrimeValue16: 65529 + 1];
	NSInteger u16Max_1 = [NSNumber floorPrimeValue16: 65535 - 1];
	NSInteger u16Max = [NSNumber floorPrimeValue16: 65535];
	NSInteger u16Max1 = [NSNumber floorPrimeValue16: 65535 + 1];
	NSInteger u16Max2p = [NSNumber floorPrimeValue16: 65535 + 2]; // first 17b prime
	NSInteger u16Max3 = [NSNumber floorPrimeValue16: 65535 + 3];
	
	XCTAssertEqual(pmax_2,		UInt16LargestPrime - 2);
	
	XCTAssertEqual(pmax_1,		UInt16LargestPrime - 2);
	XCTAssertEqual(pmax,		UInt16LargestPrime);
	
	XCTAssertEqual(pmax1,		UInt16LargestPrime);
	XCTAssertEqual(pmaxMid_1,	UInt16LargestPrime);
	XCTAssertEqual(pmaxMid,		UInt16LargestPrime);
	XCTAssertEqual(pmaxMid1,	UInt16LargestPrime);
	XCTAssertEqual(u16Max,		UInt16LargestPrime);
	XCTAssertEqual(u16Max_1,	UInt16LargestPrime);
	XCTAssertEqual(u16Max,		UInt16LargestPrime);
	XCTAssertEqual(u16Max1,		UInt16LargestPrime);
	XCTAssertEqual(u16Max2p,	0);
	XCTAssertEqual(u16Max3,		0);
}

#pragma mark Floor Value Offset Correctness Tests

- (void)testFloorPrimeValue16Offset
{
	//  testing 7 .. 11
	NSInteger i07 = [NSNumber floorPrimeValue16: 7 offset:-2];
	NSInteger i08 = [NSNumber floorPrimeValue16: 8 offset:-1];
	NSInteger i09 = [NSNumber floorPrimeValue16: 9 offset:0];
	NSInteger i10 = [NSNumber floorPrimeValue16:10 offset:1];
	NSInteger i11 = [NSNumber floorPrimeValue16:11 offset:2];
	
	XCTAssertEqual(i07,  3);
	XCTAssertEqual(i08,  5);
	XCTAssertEqual(i09,  7);
	XCTAssertEqual(i10, 11);
	XCTAssertEqual(i11, 17);
}

- (void)testFloorPrimeValue16Offset_LowerBound
{
	NSInteger in1 = [NSNumber floorPrimeValue16: -1 offset:-1];
	NSInteger i00 = [NSNumber floorPrimeValue16:  0 offset:-1];
	NSInteger i01 = [NSNumber floorPrimeValue16:  1 offset:-1];
	NSInteger i02 = [NSNumber floorPrimeValue16:  2 offset:-1];
	NSInteger i03 = [NSNumber floorPrimeValue16:  3 offset:-1];
	NSInteger i04 = [NSNumber floorPrimeValue16:  4 offset:-1];
	NSInteger i05 = [NSNumber floorPrimeValue16:  5 offset:-1];
	
	XCTAssertEqual(in1, 0);
	XCTAssertEqual(i00, 0);
	XCTAssertEqual(i01, 0);
	XCTAssertEqual(i02, 1);
	XCTAssertEqual(i03, 2);
	XCTAssertEqual(i04, 2);
	XCTAssertEqual(i05, 3);
}


- (void)testFloorPrimeValue16Offset_UpperBound
{
	NSInteger pmax_2 = [NSNumber floorPrimeValue16: UInt16LargestPrime - 2 offset:1];
	NSInteger pmax_1 = [NSNumber floorPrimeValue16: UInt16LargestPrime - 1 offset:1];
	NSInteger pmax = [NSNumber floorPrimeValue16: UInt16LargestPrime offset:1]; // 65521
	NSInteger pmax1 = [NSNumber floorPrimeValue16: UInt16LargestPrime + 1 offset:1];
	NSInteger pmaxMid_1 = [NSNumber floorPrimeValue16: 65529 - 1 offset:1];
	NSInteger pmaxMid = [NSNumber floorPrimeValue16: 65529 offset:1];
	NSInteger pmaxMid1 = [NSNumber floorPrimeValue16: 65529 + 1 offset:1];
	NSInteger u16Max_1 = [NSNumber floorPrimeValue16: 65535 - 1 offset:1];
	NSInteger u16Max = [NSNumber floorPrimeValue16: 65535 offset:1];
	NSInteger u16Max1 = [NSNumber floorPrimeValue16: 65535 + 1 offset:1];
	NSInteger u16Max2p = [NSNumber floorPrimeValue16: 65535 + 2 offset:1]; // first 17b prime
	NSInteger u16Max3 = [NSNumber floorPrimeValue16: 65535 + 3 offset:1];
	
	XCTAssertEqual(pmax_2,		UInt16LargestPrime);
	
	XCTAssertEqual(pmax_1,		UInt16LargestPrime);
	XCTAssertEqual(pmax,		0);
	
	XCTAssertEqual(pmax1,		0);
	XCTAssertEqual(pmaxMid_1,	0);
	XCTAssertEqual(pmaxMid,		0);
	XCTAssertEqual(pmaxMid1,	0);
	XCTAssertEqual(u16Max,		0);
	XCTAssertEqual(u16Max_1,	0);
	XCTAssertEqual(u16Max,		0);
	XCTAssertEqual(u16Max1,		0);
	XCTAssertEqual(u16Max2p,	0);
	XCTAssertEqual(u16Max3,		0);
}



#pragma mark Floor NSNumber Correctness Tests

- (void)testFloorPrime16
{
	//  testing 7 .. 11
	NSNumber* i07 = [NSNumber floorPrime16: 7];
	NSNumber* i08 = [NSNumber floorPrime16: 8];
	NSNumber* i09 = [NSNumber floorPrime16: 9];
	NSNumber* i10 = [NSNumber floorPrime16:10];
	NSNumber* i11 = [NSNumber floorPrime16:11];
	
	XCTAssertTrue([i07 isKindOfClass:NSNumber.class]);
	XCTAssertEqualObjects(i07,  @(7));
	XCTAssertEqualObjects(i08,  @(7));
	XCTAssertEqualObjects(i09,  @(7));
	XCTAssertEqualObjects(i10,  @(7));
	XCTAssertEqualObjects(i11, @(11));
}

- (void)testFloorPrime16_LowerBound
{
	NSNumber* in1 = [NSNumber floorPrime16: -1];
	NSNumber* i00 = [NSNumber floorPrime16:  0];
	NSNumber* i01 = [NSNumber floorPrime16:  1];
	NSNumber* i02 = [NSNumber floorPrime16:  2];
	NSNumber* i03 = [NSNumber floorPrime16:  3];
	NSNumber* i04 = [NSNumber floorPrime16:  4];
	NSNumber* i05 = [NSNumber floorPrime16:  5];
	
	XCTAssertNil(in1);
	XCTAssertNil(i00);
	XCTAssertEqualObjects(i01, @(1));
	XCTAssertEqualObjects(i02, @(2));
	XCTAssertEqualObjects(i03, @(3));
	XCTAssertEqualObjects(i04, @(3));
	XCTAssertEqualObjects(i05, @(5));
}


- (void)testFloorPrime16_UpperBound
{
	NSNumber* pmax_2 = [NSNumber floorPrime16: UInt16LargestPrime - 2];
	NSNumber* pmax_1 = [NSNumber floorPrime16: UInt16LargestPrime - 1];
	NSNumber* pmax = [NSNumber floorPrime16: UInt16LargestPrime]; // 65521
	NSNumber* pmax1 = [NSNumber floorPrime16: UInt16LargestPrime + 1];
	NSNumber* pmaxMid_1 = [NSNumber floorPrime16: 65529 - 1];
	NSNumber* pmaxMid = [NSNumber floorPrime16: 65529];
	NSNumber* pmaxMid1 = [NSNumber floorPrime16: 65529 + 1];
	NSNumber* u16Max_1 = [NSNumber floorPrime16: 65535 - 1];
	NSNumber* u16Max = [NSNumber floorPrime16: 65535];
	NSNumber* u16Max1 = [NSNumber floorPrime16: 65535 + 1];
	NSNumber* u16Max2p = [NSNumber floorPrime16: 65535 + 2]; // first 17b prime
	NSNumber* u16Max3 = [NSNumber floorPrime16: 65535 + 3];
	
	XCTAssertEqualObjects(pmax_2,		@(UInt16LargestPrime - 2));
	
	XCTAssertEqualObjects(pmax_1,		@(UInt16LargestPrime - 2));
	XCTAssertEqualObjects(pmax,			@(UInt16LargestPrime));
	
	XCTAssertEqualObjects(pmax1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmaxMid_1,	@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmaxMid,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmaxMid1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(u16Max,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(u16Max_1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(u16Max,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(u16Max1,		@(UInt16LargestPrime));
	XCTAssertNil(u16Max2p);
	XCTAssertNil(u16Max3);
}



#pragma mark - Ceil Value Correctness Tests

- (void)testCeilPrimeValue16
{
	//  testing 7 .. 11
	NSInteger i07 = [NSNumber ceilPrimeValue16: 7];
	NSInteger i08 = [NSNumber ceilPrimeValue16: 8];
	NSInteger i09 = [NSNumber ceilPrimeValue16: 9];
	NSInteger i10 = [NSNumber ceilPrimeValue16:10];
	NSInteger i11 = [NSNumber ceilPrimeValue16:11];
	
	XCTAssertEqual(i07,  7);
	XCTAssertEqual(i08, 11);
	XCTAssertEqual(i09, 11);
	XCTAssertEqual(i10, 11);
	XCTAssertEqual(i11, 11);
}

- (void)testCeilPrimeValue16_LowerBound
{
	NSInteger in1 = [NSNumber ceilPrimeValue16: -1];
	NSInteger i00 = [NSNumber ceilPrimeValue16:  0];
	NSInteger i01 = [NSNumber ceilPrimeValue16:  1];
	NSInteger i02 = [NSNumber ceilPrimeValue16:  2];
	NSInteger i03 = [NSNumber ceilPrimeValue16:  3];
	NSInteger i04 = [NSNumber ceilPrimeValue16:  4];
	NSInteger i05 = [NSNumber ceilPrimeValue16:  5];
	
	XCTAssertEqual(in1, 0);
	XCTAssertEqual(i00, 0);
	XCTAssertEqual(i01, 1);
	XCTAssertEqual(i02, 2);
	XCTAssertEqual(i03, 3);
	XCTAssertEqual(i04, 5);
	XCTAssertEqual(i05, 5);
}


- (void)testCeilPrimeValue16_UpperBound
{
	NSInteger pmax_2 = [NSNumber ceilPrimeValue16: UInt16LargestPrime - 2];
	NSInteger pmax_1 = [NSNumber ceilPrimeValue16: UInt16LargestPrime - 1];
	NSInteger pmax = [NSNumber ceilPrimeValue16: UInt16LargestPrime]; // 65521
	NSInteger pmax1 = [NSNumber ceilPrimeValue16: UInt16LargestPrime + 1];
	NSInteger pmaxMid_1 = [NSNumber ceilPrimeValue16: 65529 - 1];
	NSInteger pmaxMid = [NSNumber ceilPrimeValue16: 65529];
	NSInteger pmaxMid1 = [NSNumber ceilPrimeValue16: 65529 + 1];
	NSInteger u16Max_1 = [NSNumber ceilPrimeValue16: 65535 - 1];
	NSInteger u16Max = [NSNumber ceilPrimeValue16: 65535];
	NSInteger u16Max1 = [NSNumber ceilPrimeValue16: 65535 + 1];
	NSInteger u16Max2p = [NSNumber ceilPrimeValue16: 65535 + 2]; // first 17b prime
	NSInteger u16Max3 = [NSNumber ceilPrimeValue16: 65535 + 3];
	
	XCTAssertEqual(pmax_2,		UInt16LargestPrime - 2);
	
	XCTAssertEqual(pmax_1,		UInt16LargestPrime);
	XCTAssertEqual(pmax,		UInt16LargestPrime);
	
	XCTAssertEqual(pmax1,		0);
	XCTAssertEqual(pmaxMid_1,	0);
	XCTAssertEqual(pmaxMid,		0);
	XCTAssertEqual(pmaxMid1,	0);
	XCTAssertEqual(u16Max,		0);
	XCTAssertEqual(u16Max_1,	0);
	XCTAssertEqual(u16Max,		0);
	XCTAssertEqual(u16Max1,		0);
	XCTAssertEqual(u16Max2p,	0);
	XCTAssertEqual(u16Max3,		0);
}

#pragma mark Ceil Value Offset Correctness Tests

- (void)testCeilPrimeValue16Offset
{
	//  testing 7 .. 11
	NSInteger i07 = [NSNumber ceilPrimeValue16: 7 offset:-2];
	NSInteger i08 = [NSNumber ceilPrimeValue16: 8 offset:-1];
	NSInteger i09 = [NSNumber ceilPrimeValue16: 9 offset:0];
	NSInteger i10 = [NSNumber ceilPrimeValue16:10 offset:1];
	NSInteger i11 = [NSNumber ceilPrimeValue16:11 offset:2];
	
	XCTAssertEqual(i07,  3);
	XCTAssertEqual(i08,  7);
	XCTAssertEqual(i09, 11);
	XCTAssertEqual(i10, 13);
	XCTAssertEqual(i11, 17);
}

- (void)testCeilPrimeValue16Offset_LowerBound
{
	NSInteger in1 = [NSNumber ceilPrimeValue16: -1 offset:-1];
	NSInteger i00 = [NSNumber ceilPrimeValue16:  0 offset:-1];
	NSInteger i01 = [NSNumber ceilPrimeValue16:  1 offset:-1];
	NSInteger i02 = [NSNumber ceilPrimeValue16:  2 offset:-1];
	NSInteger i03 = [NSNumber ceilPrimeValue16:  3 offset:-1];
	NSInteger i04 = [NSNumber ceilPrimeValue16:  4 offset:-1];
	NSInteger i05 = [NSNumber ceilPrimeValue16:  5 offset:-1];
	
	XCTAssertEqual(in1, 0);
	XCTAssertEqual(i00, 0);
	XCTAssertEqual(i01, 0);
	XCTAssertEqual(i02, 1);
	XCTAssertEqual(i03, 2);
	XCTAssertEqual(i04, 3);
	XCTAssertEqual(i05, 3);
}


- (void)testCeilPrimeValue16Offset_UpperBound
{
	NSInteger pmax_2 = [NSNumber ceilPrimeValue16: UInt16LargestPrime - 2 offset:1];
	NSInteger pmax_1 = [NSNumber ceilPrimeValue16: UInt16LargestPrime - 1 offset:1];
	NSInteger pmax = [NSNumber ceilPrimeValue16: UInt16LargestPrime offset:1]; // 65521
	NSInteger pmax1 = [NSNumber ceilPrimeValue16: UInt16LargestPrime + 1 offset:1];
	NSInteger pmaxMid_1 = [NSNumber ceilPrimeValue16: 65529 - 1 offset:1];
	NSInteger pmaxMid = [NSNumber ceilPrimeValue16: 65529 offset:1];
	NSInteger pmaxMid1 = [NSNumber ceilPrimeValue16: 65529 + 1 offset:1];
	NSInteger u16Max_1 = [NSNumber ceilPrimeValue16: 65535 - 1 offset:1];
	NSInteger u16Max = [NSNumber ceilPrimeValue16: 65535 offset:1];
	NSInteger u16Max1 = [NSNumber ceilPrimeValue16: 65535 + 1 offset:1];
	NSInteger u16Max2p = [NSNumber ceilPrimeValue16: 65535 + 2 offset:1]; // first 17b prime
	NSInteger u16Max3 = [NSNumber ceilPrimeValue16: 65535 + 3 offset:1];
	
	XCTAssertEqual(pmax_2,		UInt16LargestPrime);
	
	XCTAssertEqual(pmax_1,		0);
	XCTAssertEqual(pmax,		0);
	
	XCTAssertEqual(pmax1,		0);
	XCTAssertEqual(pmaxMid_1,	0);
	XCTAssertEqual(pmaxMid,		0);
	XCTAssertEqual(pmaxMid1,	0);
	XCTAssertEqual(u16Max,		0);
	XCTAssertEqual(u16Max_1,	0);
	XCTAssertEqual(u16Max,		0);
	XCTAssertEqual(u16Max1,		0);
	XCTAssertEqual(u16Max2p,	0);
	XCTAssertEqual(u16Max3,		0);
}



#pragma mark Ceil NSNumber Correctness Tests

- (void)testCeilPrime16
{
	//  testing 7 .. 11
	NSNumber* i07 = [NSNumber ceilPrime16: 7];
	NSNumber* i08 = [NSNumber ceilPrime16: 8];
	NSNumber* i09 = [NSNumber ceilPrime16: 9];
	NSNumber* i10 = [NSNumber ceilPrime16:10];
	NSNumber* i11 = [NSNumber ceilPrime16:11];
	
	XCTAssertTrue([i07 isKindOfClass:NSNumber.class]);
	XCTAssertEqualObjects(i07,  @(7));
	XCTAssertEqualObjects(i08, @(11));
	XCTAssertEqualObjects(i09, @(11));
	XCTAssertEqualObjects(i10, @(11));
	XCTAssertEqualObjects(i11, @(11));
}

- (void)testCeilPrime16_LowerBound
{
	NSNumber* in1 = [NSNumber ceilPrime16: -1];
	NSNumber* i00 = [NSNumber ceilPrime16:  0];
	NSNumber* i01 = [NSNumber ceilPrime16:  1];
	NSNumber* i02 = [NSNumber ceilPrime16:  2];
	NSNumber* i03 = [NSNumber ceilPrime16:  3];
	NSNumber* i04 = [NSNumber ceilPrime16:  4];
	NSNumber* i05 = [NSNumber ceilPrime16:  5];
	
	XCTAssertNil(in1);
	XCTAssertNil(i00);
	XCTAssertEqualObjects(i01, @(1));
	XCTAssertEqualObjects(i02, @(2));
	XCTAssertEqualObjects(i03, @(3));
	XCTAssertEqualObjects(i04, @(5));
	XCTAssertEqualObjects(i05, @(5));
}


- (void)testCeilPrime16_UpperBound
{
	NSNumber* pmax_2 = [NSNumber ceilPrime16: UInt16LargestPrime - 2];
	NSNumber* pmax_1 = [NSNumber ceilPrime16: UInt16LargestPrime - 1];
	NSNumber* pmax = [NSNumber ceilPrime16: UInt16LargestPrime]; // 65521
	NSNumber* pmax1 = [NSNumber ceilPrime16: UInt16LargestPrime + 1];
	NSNumber* pmaxMid_1 = [NSNumber ceilPrime16: 65529 - 1];
	NSNumber* pmaxMid = [NSNumber ceilPrime16: 65529];
	NSNumber* pmaxMid1 = [NSNumber ceilPrime16: 65529 + 1];
	NSNumber* u16Max_1 = [NSNumber ceilPrime16: 65535 - 1];
	NSNumber* u16Max = [NSNumber ceilPrime16: 65535];
	NSNumber* u16Max1 = [NSNumber ceilPrime16: 65535 + 1];
	NSNumber* u16Max2p = [NSNumber ceilPrime16: 65535 + 2]; // first 17b prime
	NSNumber* u16Max3 = [NSNumber ceilPrime16: 65535 + 3];
	
	XCTAssertEqualObjects(pmax_2,		@(UInt16LargestPrime - 2));
	
	XCTAssertEqualObjects(pmax_1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmax,			@(UInt16LargestPrime));
	
	XCTAssertNil(pmax1);
	XCTAssertNil(pmaxMid_1);
	XCTAssertNil(pmaxMid);
	XCTAssertNil(pmaxMid1);
	XCTAssertNil(u16Max);
	XCTAssertNil(u16Max_1);
	XCTAssertNil(u16Max);
	XCTAssertNil(u16Max1);
	XCTAssertNil(u16Max2p);
	XCTAssertNil(u16Max3);
}


#pragma mark - NSNumber roundPrime16

- (void)testNSNumber_RoundPrime16
{
	//  testing 7 .. 11
	NSNumber* i07 = [@7 roundPrime16];
	NSNumber* i08 = [@8 roundPrime16];
	NSNumber* i09 = [@9 roundPrime16];
	NSNumber* i10 = [@10 roundPrime16];
	NSNumber* i11 = [@11 roundPrime16];
	
	XCTAssertTrue([i07 isKindOfClass:NSNumber.class]);
	XCTAssertEqualObjects(i07,  @(7));
	XCTAssertEqualObjects(i08,  @(7));
	XCTAssertEqualObjects(i09, @(11));
	XCTAssertEqualObjects(i10, @(11));
	XCTAssertEqualObjects(i11, @(11));
}

- (void)testNSNumber_RoundPrime16_LowerBound
{
	NSNumber* in1 = [@-1 roundPrime16];
	NSNumber* i00 = [@0 roundPrime16];
	NSNumber* i01 = [@1 roundPrime16];
	NSNumber* i02 = [@2 roundPrime16];
	NSNumber* i03 = [@3 roundPrime16];
	NSNumber* i04 = [@4 roundPrime16];
	NSNumber* i05 = [@5 roundPrime16];
	
	XCTAssertNil(in1);
	XCTAssertNil(i00);
	XCTAssertEqualObjects(i01, @(1));
	XCTAssertEqualObjects(i02, @(2));
	XCTAssertEqualObjects(i03, @(3));
	XCTAssertEqualObjects(i04, @(5));
	XCTAssertEqualObjects(i05, @(5));
}


- (void)testNSNumber_RoundPrime16_UpperBound
{
	NSNumber* pmax_2 = [@(UInt16LargestPrime - 2) roundPrime16];
	NSNumber* pmax_1 = [@(UInt16LargestPrime - 1) roundPrime16];
	NSNumber* pmax = [@UInt16LargestPrime roundPrime16]; // 65521
	NSNumber* pmax1 = [@(UInt16LargestPrime + 1) roundPrime16];
	NSNumber* pmaxMid_1 = [@(65529 - 1) roundPrime16];
	NSNumber* pmaxMid = [@(65529) roundPrime16];
	NSNumber* pmaxMid1 = [@(65529 + 1) roundPrime16];
	NSNumber* u16Max_1 = [@(65535 - 1) roundPrime16];
	NSNumber* u16Max = [@65535 roundPrime16];
	NSNumber* u16Max1 = [@(65535 + 1) roundPrime16];
	NSNumber* u16Max2p = [@(65535 + 2) roundPrime16]; // first 17b prime
	NSNumber* u16Max3 = [@(65535 + 3) roundPrime16];
	
	XCTAssertEqualObjects(pmax_2,		@(UInt16LargestPrime - 2));
	
	XCTAssertEqualObjects(pmax_1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmax,		@(UInt16LargestPrime));
	
	XCTAssertEqualObjects(pmax1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmaxMid_1,	@(UInt16LargestPrime));
	XCTAssertNil(pmaxMid);
	XCTAssertNil(pmaxMid1);
	XCTAssertNil(u16Max);
	XCTAssertNil(u16Max_1);
	XCTAssertNil(u16Max);
	XCTAssertNil(u16Max1);
	XCTAssertNil(u16Max2p);
	XCTAssertNil(u16Max3);
}



#pragma mark - NSNumber floorPrime16

- (void)testNSNumber_FloorPrime16
{
	//  testing 7 .. 11
	NSNumber* i07 = [@7 floorPrime16];
	NSNumber* i08 = [@8 floorPrime16];
	NSNumber* i09 = [@9 floorPrime16];
	NSNumber* i10 = [@10 floorPrime16];
	NSNumber* i11 = [@11 floorPrime16];
	
	XCTAssertTrue([i07 isKindOfClass:NSNumber.class]);
	XCTAssertEqualObjects(i07,  @(7));
	XCTAssertEqualObjects(i08,  @(7));
	XCTAssertEqualObjects(i09,  @(7));
	XCTAssertEqualObjects(i10,  @(7));
	XCTAssertEqualObjects(i11, @(11));
}

- (void)testNSNumber_FloorPrime16_LowerBound
{
	NSNumber* in1 = [@-1 floorPrime16];
	NSNumber* i00 = [@0 floorPrime16];
	NSNumber* i01 = [@1 floorPrime16];
	NSNumber* i02 = [@2 floorPrime16];
	NSNumber* i03 = [@3 floorPrime16];
	NSNumber* i04 = [@4 floorPrime16];
	NSNumber* i05 = [@5 floorPrime16];
	
	XCTAssertNil(in1);
	XCTAssertNil(i00);
	XCTAssertEqualObjects(i01, @(1));
	XCTAssertEqualObjects(i02, @(2));
	XCTAssertEqualObjects(i03, @(3));
	XCTAssertEqualObjects(i04, @(3));
	XCTAssertEqualObjects(i05, @(5));
}


- (void)testNSNumber_FloorPrime16_UpperBound
{
	NSNumber* pmax_2 = [@(UInt16LargestPrime - 2) floorPrime16];
	NSNumber* pmax_1 = [@(UInt16LargestPrime - 1) floorPrime16];
	NSNumber* pmax = [@UInt16LargestPrime floorPrime16]; // 65521
	NSNumber* pmax1 = [@(UInt16LargestPrime + 1) floorPrime16];
	NSNumber* pmaxMid_1 = [@(65529 - 1) floorPrime16];
	NSNumber* pmaxMid = [@(65529) floorPrime16];
	NSNumber* pmaxMid1 = [@(65529 + 1) floorPrime16];
	NSNumber* u16Max_1 = [@(65535 - 1) floorPrime16];
	NSNumber* u16Max = [@65535 floorPrime16];
	NSNumber* u16Max1 = [@(65535 + 1) floorPrime16];
	NSNumber* u16Max2p = [@(65535 + 2) floorPrime16]; // first 17b prime
	NSNumber* u16Max3 = [@(65535 + 3) floorPrime16];
	
	XCTAssertEqualObjects(pmax_2,		@(UInt16LargestPrime - 2));
	
	XCTAssertEqualObjects(pmax_1,		@(UInt16LargestPrime - 2));
	XCTAssertEqualObjects(pmax,			@(UInt16LargestPrime));
	
	XCTAssertEqualObjects(pmax1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmaxMid_1,	@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmaxMid,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmaxMid1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(u16Max,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(u16Max_1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(u16Max,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(u16Max1,		@(UInt16LargestPrime));
	XCTAssertNil(u16Max2p);
	XCTAssertNil(u16Max3);
}



#pragma mark - NSNumber ceilPrime16

- (void)testNSNumber_CeilPrime16
{
	//  testing 7 .. 11
	NSNumber* i07 = [@7 ceilPrime16];
	NSNumber* i08 = [@8 ceilPrime16];
	NSNumber* i09 = [@9 ceilPrime16];
	NSNumber* i10 = [@10 ceilPrime16];
	NSNumber* i11 = [@11 ceilPrime16];
	
	XCTAssertTrue([i07 isKindOfClass:NSNumber.class]);
	XCTAssertEqualObjects(i07,  @(7));
	XCTAssertEqualObjects(i08, @(11));
	XCTAssertEqualObjects(i09, @(11));
	XCTAssertEqualObjects(i10, @(11));
	XCTAssertEqualObjects(i11, @(11));
}

- (void)testNSNumber_CeilPrime16_LowerBound
{
	NSNumber* in1 = [@-1 ceilPrime16];
	NSNumber* i00 = [@0 ceilPrime16];
	NSNumber* i01 = [@1 ceilPrime16];
	NSNumber* i02 = [@2 ceilPrime16];
	NSNumber* i03 = [@3 ceilPrime16];
	NSNumber* i04 = [@4 ceilPrime16];
	NSNumber* i05 = [@5 ceilPrime16];
	
	XCTAssertNil(in1);
	XCTAssertNil(i00);
	XCTAssertEqualObjects(i01, @(1));
	XCTAssertEqualObjects(i02, @(2));
	XCTAssertEqualObjects(i03, @(3));
	XCTAssertEqualObjects(i04, @(5));
	XCTAssertEqualObjects(i05, @(5));
}


- (void)testNSNumber_CeilPrime16_UpperBound
{
	NSNumber* pmax_2 = [@(UInt16LargestPrime - 2) ceilPrime16];
	NSNumber* pmax_1 = [@(UInt16LargestPrime - 1) ceilPrime16];
	NSNumber* pmax = [@UInt16LargestPrime ceilPrime16]; // 65521
	NSNumber* pmax1 = [@(UInt16LargestPrime + 1) ceilPrime16];
	NSNumber* pmaxMid_1 = [@(65529 - 1) ceilPrime16];
	NSNumber* pmaxMid = [@(65529) ceilPrime16];
	NSNumber* pmaxMid1 = [@(65529 + 1) ceilPrime16];
	NSNumber* u16Max_1 = [@(65535 - 1) ceilPrime16];
	NSNumber* u16Max = [@65535 ceilPrime16];
	NSNumber* u16Max1 = [@(65535 + 1) ceilPrime16];
	NSNumber* u16Max2p = [@(65535 + 2) ceilPrime16]; // first 17b prime
	NSNumber* u16Max3 = [@(65535 + 3) ceilPrime16];
	
	XCTAssertEqualObjects(pmax_2,		@(UInt16LargestPrime - 2));
	
	XCTAssertEqualObjects(pmax_1,		@(UInt16LargestPrime));
	XCTAssertEqualObjects(pmax,		@(UInt16LargestPrime));
	
	XCTAssertNil(pmax1);
	XCTAssertNil(pmaxMid_1);
	XCTAssertNil(pmaxMid);
	XCTAssertNil(pmaxMid1);
	XCTAssertNil(u16Max);
	XCTAssertNil(u16Max_1);
	XCTAssertNil(u16Max);
	XCTAssertNil(u16Max1);
	XCTAssertNil(u16Max2p);
	XCTAssertNil(u16Max3);
}


@end
