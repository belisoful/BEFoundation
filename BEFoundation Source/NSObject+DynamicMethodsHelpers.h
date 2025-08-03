/*!
 * @header NSObject+DynamicMethodsHelpers.h
 * @copyright © 2025 Delicense - @belisoful. All rights released.
 * @date 2025-01-01
 * @abstract Helper classes and utilities for the dynamic method injection system.
 * @discussion This header provides the underlying infrastructure for the dynamic method
 *             injection system, including method swizzling management, signature parsing,
 *             and protocol introspection utilities. These components work together to
 *             enable safe and efficient runtime method injection.
 *
 *             The helper classes handle the complex low-level operations required for
 *             dynamic method management, including:
 *             - Method signature conversion between blocks and Objective-C methods
 *             - Safe method swizzling with state tracking
 *             - Protocol hierarchy traversal
 *             - NSInvocation manipulation for proper argument forwarding
 *
 *             This is an internal header that supports the public NSObject+DynamicMethods
 *             category. Direct use of these classes is not recommended unless you need
 *             low-level control over the dynamic method system.
 */

#ifndef NSObject_DynamicMethodsHelpers_h
#define NSObject_DynamicMethodsHelpers_h

#import <Foundation/Foundation.h>
#import "NSMethodSignature+BlockSignatures.h"

/*!
 * @function recursiveProtocolsFromProtocol
 * @abstract Recursively retrieves all protocols in a protocol's inheritance hierarchy.
 * @param protocol The root protocol to traverse.
 * @return An ordered set containing the protocol and all protocols it adopts, directly or indirectly.
 * @discussion This function performs a breadth-first traversal of the protocol inheritance
 *             hierarchy, collecting all protocols that the given protocol adopts. The
 *             result includes the root protocol itself and maintains the order of discovery.
 *             Returns an empty set if the protocol parameter is nil.
 */
extern NSOrderedSet<Protocol *> *_Nonnull recursiveProtocolsFromProtocol(Protocol *_Nonnull protocol);

/*!
 * @enum BEDynamicMethodsSwizzleState
 * @abstract States for tracking method swizzling on classes.
 * @constant DMSwizzleOff The class has been explicitly marked as not swizzled.
 * @constant DMSwizzleNone The class has no swizzling state information (default).
 * @constant DMSwizzleOn The class has been swizzled and is active.
 * @discussion This enumeration is used to track the swizzling state of classes to prevent
 *             duplicate swizzling operations and to manage inheritance hierarchies properly.
 */
typedef NS_ENUM(NSInteger, BEDynamicMethodsSwizzleState) {
	DMSwizzleOff = -1,
	DMSwizzleNone = 0,
	DMSwizzleOn = 1,
};

/*!
 * @class BEDynamicMethodSwizzleSelectors
 * @abstract Manages method swizzling operations for the dynamic method system.
 * @discussion This class encapsulates the logic for safely swizzling methods between
 *             selectors. It handles both instance methods and class methods (metaclass
 *             swizzling), maintains swizzling state, and provides utilities for checking
 *             swizzling status across class hierarchies.
 *
 *             The class uses associated objects to track swizzling state and prevents
 *             dangerous operations like swizzling NSObject directly.
 */
@interface BEDynamicMethodSwizzleSelectors : NSObject

/*!
 * @property isMetaClass
 * @abstract Indicates whether this swizzle operation targets a metaclass.
 * @discussion When YES, the swizzle operation will target the metaclass of the
 *             specified class, affecting class methods. When NO, it targets
 *             instance methods.
 */
@property (readonly) BOOL isMetaClass;

/*!
 * @property originalSelector
 * @abstract The original selector to be swizzled.
 */
@property (readonly, nonnull) SEL originalSelector;

/*!
 * @property swizzleSelector
 * @abstract The replacement selector to swizzle with the original.
 */
@property (readonly, nonnull) SEL swizzleSelector;

/*!
 * @method swizzleOriginal:withSelector:
 * @abstract Creates a swizzle configuration for instance methods.
 * @param originalSelector The original method selector.
 * @param aSelector The replacement method selector.
 * @return A configured swizzle object for instance method swizzling.
 */
+ (nonnull instancetype)swizzleOriginal:(SEL _Nonnull)originalSelector withSelector:(SEL _Nonnull)aSelector;

/*!
 * @method swizzleMetaOriginal:withSelector:
 * @abstract Creates a swizzle configuration for class methods (metaclass).
 * @param originalSelector The original method selector.
 * @param aSelector The replacement method selector.
 * @return A configured swizzle object for class method swizzling.
 */
+ (nonnull instancetype)swizzleMetaOriginal:(SEL _Nonnull)originalSelector withSelector:(SEL _Nonnull)aSelector;

/*!
 * @method initWithOriginal:swizzleSelector:isMetaClass:
 * @abstract Designated initializer for swizzle configuration.
 * @param originalSelector The original method selector.
 * @param aSelector The replacement method selector.
 * @param isMetaClass Whether to target the metaclass for class method swizzling.
 * @return An initialized swizzle configuration, or nil if initialization fails.
 */
- (nullable instancetype)initWithOriginal:(SEL _Nonnull)originalSelector
						  swizzleSelector:(SEL _Nonnull)aSelector
							  isMetaClass:(BOOL)isMetaClass;

/*!
 * @method swizzleMethodsOnClass:
 * @abstract Performs the method swizzling operation on the specified class.
 * @param targetClass The class on which to perform the swizzle.
 * @return 1 if methods were exchanged, -1 if original method was added, 0 if operation failed.
 * @discussion This method performs the actual swizzling operation, handling signature
 *             validation and choosing the appropriate swizzling strategy based on
 *             whether the original method exists in the target class.
 */
- (int)swizzleMethodsOnClass:(Class _Nonnull)targetClass;

/*!
 * @method swizzleKey
 * @abstract Returns the key used for storing swizzle state in associated objects.
 * @return A pointer suitable for use as an associated object key.
 */
+ (void * _Nonnull)swizzleKey;

/*!
 * @method statusClassHasSwizzle:
 * @abstract Checks if a class has any swizzling state information.
 * @param cls The class to check.
 * @return YES if the class has swizzling state information, NO otherwise.
 */
+ (BOOL)statusClassHasSwizzle:(Class _Nonnull)cls;

/*!
 * @method statusClassIsSwizzled:
 * @abstract Checks if a class is currently swizzled.
 * @param cls The class to check.
 * @return YES if the class is swizzled, NO otherwise.
 */
+ (BOOL)statusClassIsSwizzled:(Class _Nonnull)cls;

/*!
 * @method statusClassSwizzled:
 * @abstract Returns the detailed swizzling state of a class.
 * @param cls The class to check.
 * @return The swizzling state as a BEDynamicMethodsSwizzleState value.
 */
+ (BEDynamicMethodsSwizzleState)statusClassSwizzled:(Class _Nonnull)cls;

/*!
 * @method setClass:swizzle:
 * @abstract Sets the swizzling state for a class.
 * @param cls The class to modify.
 * @param status The new swizzling state.
 * @discussion This method updates the associated object that tracks swizzling state.
 *             Setting DMSwizzleNone removes the state information entirely.
 *             NSObject cannot be marked as swizzled for safety reasons.
 */
+ (void)setClass:(Class _Nonnull)cls swizzle:(BEDynamicMethodsSwizzleState)status;

/*!
 * @method statusParentsAreSwizzled:
 * @abstract Checks if any parent classes in the inheritance hierarchy are swizzled.
 * @param cls The class whose hierarchy to check.
 * @return YES if any parent class is swizzled, NO otherwise.
 * @discussion This method traverses the class inheritance hierarchy upward,
 *             checking each parent class for swizzling state. It uses synchronization
 *             to ensure thread safety during the traversal.
 */
+ (BOOL)statusParentsAreSwizzled:(Class _Nonnull)cls;

@end

/*!
 * @class BEDynamicMethodsHelper
 * @abstract Base helper class for dynamic method operations.
 * @discussion This class serves as a placeholder for future dynamic method utilities
 *             and provides a consistent namespace for helper functionality.
 */
@interface BEDynamicMethodsHelper : NSObject
@end

#pragma mark - Method Signature Helper

@class BEDynamicMethodMeta;

/*!
 * @category BEMethodSignatureHelper(DynamicMethods)
 * @abstract Utility methods for parsing and manipulating method signatures in the dynamic method system.
 * @discussion This category extends BEMethodSignatureHelper with specialized methods for
 *             converting between block signatures and method signatures, and for manipulating
 *             NSInvocation objects to work with block-based method implementations.
 *
 *             These utilities handle the complex task of signature transformation, ensuring
 *             that arguments are properly marshaled between the original method call and
 *             the block implementation, including proper handling of the optional selector
 *             parameter capture feature.
 */
@interface BEMethodSignatureHelper (DynamicMethods)

/*!
 * @method invocableMethodSignatureFromBlock:
 * @abstract Creates a method signature suitable for NSInvocation from a block.
 * @param block The block to analyze and convert.
 * @return An NSMethodSignature object suitable for creating NSInvocation instances, or nil if conversion fails.
 * @discussion This method analyzes a block's signature and creates a corresponding method
 *             signature that can be used to create NSInvocation objects. It handles the
 *             transformation of block signatures to method signatures, including proper
 *             handling of the implicit self and _cmd parameters.
 *
 *             The method validates that the input is actually a block and extracts the
 *             raw signature information before performing the conversion. It supports
 *             both blocks that capture the selector parameter and those that don't.
 *
 *             @note This method may raise NSInvalidArgumentException if the block parameter
 *                   is nil or not a valid NSBlock instance.
 */
+ (nullable NSMethodSignature *)invocableMethodSignatureFromBlock:(nonnull id)block;

/*!
 * @method mutateInvocation:withMeta:
 * @abstract Transforms an NSInvocation to work with a block-based method implementation.
 * @param invocation The original method invocation to transform.
 * @param meta Metadata describing the dynamic method and its block signature.
 * @return A new NSInvocation configured for the block implementation, or nil if transformation fails.
 * @discussion This method creates a new NSInvocation that matches the block's signature
 *             and properly marshals arguments from the original method call to the block.
 *             It handles the optional selector capture feature by adjusting argument
 *             indices appropriately.
 *
 *             The transformation process includes:
 *             - Validating argument count compatibility between method and block signatures
 *             - Creating a new invocation with the block's signature
 *             - Copying arguments from the original invocation to the new one
 *             - Adjusting for the optional selector parameter
 *             - Preserving argument retention state
 *
 *             This method is used internally during method forwarding to ensure that
 *             dynamic methods receive arguments in the format expected by their block
 *             implementations.
 */
+ (nullable NSInvocation *)mutateInvocation:(nonnull NSInvocation *)invocation
								   withMeta:(nonnull BEDynamicMethodMeta *)meta;

@end

#endif /* NSObject_DynamicMethodsHelpers_h */
