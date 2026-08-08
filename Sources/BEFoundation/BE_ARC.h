/*!
 @header		`BE_ARC.h`
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @author		belisoful@icloud.com
 @abstract		Memory-management macros that compile correctly under both ARC and MRC.
 @discussion	Under ARC, retain/autorelease collapse to the bare expression, releases become nil
				assignments, and BLOCK_COPY uses -copy. Under MRC the macros expand to the classic
				retain/release/autorelease and Block_copy/Block_release calls. This lets shared
				source build in either mode (e.g. when BEFoundation files are compiled directly
				into a host project rather than linked as the framework).

				@code
				_ivar = NARC_RETAIN(value);                 // bare value under ARC, -retain under MRC
				id temp = NARC_RETAIN_AUTORELEASE(value);   // safe return of an owned object
				NARC_RELEASE(_ivar);                        // nil-assigns under ARC, -release + nil under MRC

				void (^handler)(void) = BLOCK_COPY(block);  // moves the block to the heap
				BLOCK_RELEASE(handler);

				- (void)dealloc {
				    NARC_RELEASE(_ivar);
				    SUPER_DEALLOC();                        // [super dealloc] under MRC, empty under ARC
				}
				@endcode
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


#endif	//	BE_ARC_h
