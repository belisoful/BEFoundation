/*!
 @header		`BE_ARC.h`
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract		This is to enable direct usage of BEFoundation outside of the framework context.
 @discussion	When objective c ARC is turned on, 
*/

#ifndef BE_ARC_h
#define BE_ARC_h

//

#if __has_feature(objc_arc)

	#define NARC_RETAIN(obj)				(obj)
	#define NARC_AUTORELEASE(obj)			(obj)
	#define NARC_RETAIN_AUTORELEASE(obj)	(obj)
	#define NARC_RELEASE(obj)				(obj = nil)
	#define NARC_RELEASE_RAW(obj)
	#define SUPER_DEALLOC()
	#define BLOCK_COPY(block)   			[(block) copy]
	#define BLOCK_RELEASE(block)   			((block) = nil)

#else

	#define NARC_RETAIN(obj)				[(obj) retain]
	#define NARC_AUTORELEASE(obj)			[(obj) autorelease]
	#define NARC_RETAIN_AUTORELEASE(obj)	[[(obj) retain] autorelease]
	#define NARC_RELEASE(obj)				([(obj) release], obj = nil)
	#define NARC_RELEASE_RAW(obj)			[(obj) release]
	#define SUPER_DEALLOC() 				[super dealloc]
	#define BLOCK_COPY(block)   			Block_copy(block)
	#define BLOCK_RELEASE(block)   { if (block) { Block_release(block); (block) = nil; } }

#endif


#endif	//	NSArray_Extension_h
