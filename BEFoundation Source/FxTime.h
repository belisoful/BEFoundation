/*!
 @header 		FxTime.h
 @copyright 	-© 2025 Delicense - @belisoful. All rights released.
 @date 			2025-01-01
 @abstract 		A comprehensive Objective-C wrapper for CoreMedia's CMTime structure providing convenient time manipulation and arithmetic operations.
 @discussion	FxTime encapsulates CoreMedia's CMTime structure in an Objective-C object, providing a more convenient and object-oriented interface for time-based operations in media applications. This class supports all standard CMTime operations including arithmetic, comparison, and conversion while maintaining compatibility with NSSecureCoding and NSCopying protocols.
 
 The class provides factory methods for creating common time values (zero, invalid, infinity) and supports various initialization methods for different time representations. All time arithmetic operations modify the receiver in-place for efficiency.
 */

#ifndef FxTime_h
#define FxTime_h

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>

/*!
 @struct SRational32
 @abstract A structure representing a rational number with 32-bit integer components.
 @discussion
 This structure is used to represent fractional values as a ratio of two integers, providing precise representation of decimal numbers without floating-point precision loss.
 @field multiplier The numerator of the rational number.
 @field divisor The denominator of the rational number.
 */
struct SRational32 {
	int32_t multiplier;
	int32_t divisor;
};
typedef struct SRational32 SRational32;

/*!
 @class FxTime
 @abstract An Objective-C wrapper for CoreMedia's CMTime structure.
 @discussion
 FxTime provides a convenient object-oriented interface for working with time values in media applications. It encapsulates a CMTime structure and provides methods for time arithmetic, comparison, and conversion operations.
 
 The class supports secure coding and copying, making it suitable for use in applications that require serialization or immutable time representations.
 
 All arithmetic operations (add, subtract, multiply) modify the receiver in-place. For immutable operations, create a copy of the FxTime object before performing the operation.
 */
@interface FxTime : NSObject <NSSecureCoding, NSCopying>

/*!
 @property time
 @abstract The underlying CMTime structure.
 @discussion
 Direct access to the wrapped CMTime structure. Modifying this property directly bypasses the convenience methods and may require understanding of CMTime's internal representation.
 */
@property (assign) CMTime time;

#pragma mark - Factory Methods

/*!
 @method time:
 @abstract Creates a new FxTime instance with the specified CMTime value.
 @param time The CMTime value to wrap.
 @return A new autoreleased FxTime instance.
 @discussion
 This is the primary factory method for creating FxTime instances from existing CMTime values.
 */
+ (instancetype)time:(CMTime)time;

/*!
 @method timeWithDictionary:
 @abstract Creates a new FxTime instance from a dictionary representation.
 @param timeDictionary A dictionary containing CMTime components as created by CMTimeCopyAsDictionary.
 @return A new autoreleased FxTime instance.
 @discussion
 This method is useful for deserializing time values from property lists or other dictionary-based storage formats.
 */
+ (instancetype)timeWithDictionary:(NSDictionary*)timeDictionary;

/*!
 @method invalid
 @abstract Creates an invalid time value.
 @return A new FxTime instance representing an invalid time (kCMTimeInvalid).
 @discussion
 Invalid times are used to represent uninitialized or error states in time calculations.
 */
+ (instancetype)invalid;

/*!
 @method indefinite
 @abstract Creates an indefinite time value.
 @return A new FxTime instance representing an indefinite time (kCMTimeIndefinite).
 @discussion
 Indefinite times are used to represent unknown or unbounded durations.
 */
+ (instancetype)indefinite;

/*!
 @method infinity
 @abstract Creates a positive infinity time value.
 @return A new FxTime instance representing positive infinity (kCMTimePositiveInfinity).
 @discussion
 Positive infinity is used to represent unlimited future time or maximum duration values.
 */
+ (instancetype)infinity;

/*!
 @method minusInfinity
 @abstract Creates a negative infinity time value.
 @return A new FxTime instance representing negative infinity (kCMTimeNegativeInfinity).
 @discussion
 Negative infinity is used to represent unlimited past time or minimum duration values.
 */
+ (instancetype)minusInfinity;

/*!
 @method zero
 @abstract Creates a zero time value.
 @return A new FxTime instance representing zero time (kCMTimeZero).
 @discussion
 Zero time represents the origin point for time calculations and is commonly used as a starting reference.
 */
+ (instancetype)zero;

#pragma mark - Initialization Methods

/*!
 @method initWithTime:
 @abstract Initializes a new FxTime instance by copying another FxTime instance.
 @param time The FxTime instance to copy.
 @return An initialized FxTime instance.
 @discussion
 This initializer creates a new FxTime instance with the same time value as the source instance.
 */
- (instancetype)initWithTime:(FxTime*)time;

/*!
 @method initWithCMTime:
 @abstract Initializes a new FxTime instance with a CMTime value.
 @param time The CMTime value to wrap.
 @return An initialized FxTime instance.
 @discussion
 This is the designated initializer for creating FxTime instances from CMTime values.
 */
- (instancetype)initWithCMTime:(CMTime)time;

/*!
 @method initWithDictionary:
 @abstract Initializes a new FxTime instance from a dictionary representation.
 @param timeDictionary A dictionary containing CMTime components.
 @return An initialized FxTime instance.
 @discussion
 The dictionary should contain the same keys and values as those created by CMTimeCopyAsDictionary.
 */
- (instancetype)initWithDictionary:(NSDictionary*)timeDictionary;

/*!
 @method initWithTime:timescale:
 @abstract Initializes a new FxTime instance with a time value and timescale.
 @param value The time value in timescale units.
 @param timescale The number of time units per second.
 @return An initialized FxTime instance.
 @discussion
 This initializer creates a time value where the actual time in seconds is value/timescale.
 */
- (instancetype)initWithTime:(int64_t)value timescale:(int32_t)timescale;

/*!
 @method initWithTime:timescale:epoch:
 @abstract Initializes a new FxTime instance with a time value, timescale, and epoch.
 @param value The time value in timescale units.
 @param timescale The number of time units per second.
 @param epoch The epoch value for the time.
 @return An initialized FxTime instance.
 @discussion
 The epoch parameter is used for time values that need to reference a specific starting point other than zero.
 */
- (instancetype)initWithTime:(int64_t)value timescale:(int32_t)timescale epoch:(int64_t)epoch;

/*!
 @method initWithSeconds:preferredTimescale:
 @abstract Initializes a new FxTime instance with a time value in seconds.
 @param seconds The time value in seconds.
 @param preferredTimescale The preferred timescale for internal representation.
 @return An initialized FxTime instance.
 @discussion
 This initializer converts a floating-point seconds value to the most appropriate CMTime representation using the specified preferred timescale.
 */
- (instancetype)initWithSeconds:(Float64)seconds preferredTimescale:(int32_t)preferredTimescale;

#pragma mark - Time Component Properties

/*!
 @property value
 @abstract The time value component of the wrapped CMTime.
 @discussion
 This represents the numerator of the time fraction. The actual time in seconds is value/timescale.
 */
@property (nonatomic) CMTimeValue value;

/*!
 @property timescale
 @abstract The timescale component of the wrapped CMTime.
 @discussion
 This represents the denominator of the time fraction and indicates the number of time units per second.
 */
@property (nonatomic) CMTimeScale timescale;

/*!
 @property flags
 @abstract The flags component of the wrapped CMTime.
 @discussion
 These flags indicate special states of the time value such as invalid, indefinite, or infinity.
 */
@property (nonatomic) CMTimeFlags flags;

/*!
 @property epoch
 @abstract The epoch component of the wrapped CMTime.
 @discussion
 The epoch is used for time values that need to reference a specific starting point other than zero.
 */
@property (nonatomic) CMTimeEpoch epoch;

#pragma mark - Computed Properties

/*!
 @property seconds
 @abstract The time value converted to seconds as a floating-point number.
 @discussion
 This property provides a convenient way to access the time value in seconds without manual conversion.
 */
@property (assign, readonly) Float64 seconds;

/*!
 @property isValid
 @abstract Whether the time value is valid.
 @discussion
 Returns YES if the time represents a valid time value, NO if it represents an invalid or uninitialized state.
 */
@property (nonatomic, readonly) BOOL isValid;

/*!
 @property isInfinity
 @abstract Whether the time value represents positive infinity.
 @discussion
 Returns YES if the time represents positive infinity, indicating unlimited future time or maximum duration.
 */
@property (nonatomic, readonly) BOOL isInfinity;

/*!
 @property isNegativeInfinity
 @abstract Whether the time value represents negative infinity.
 @discussion
 Returns YES if the time represents negative infinity, indicating unlimited past time or minimum duration.
 */
@property (nonatomic, readonly) BOOL isNegativeInfinity;

/*!
 @property isIndefinite
 @abstract Whether the time value is indefinite.
 @discussion
 Returns YES if the time represents an indefinite duration, indicating unknown or unbounded time.
 */
@property (nonatomic, readonly) BOOL isIndefinite;

/*!
 @property isNumeric
 @abstract Whether the time value is numeric (finite and valid).
 @discussion
 Returns YES only if the time is valid, non-indefinite, and non-infinite. Such times can be used in arithmetic operations.
 */
@property (nonatomic, readonly) BOOL isNumeric;

/*!
 @property isRounded
 @abstract Whether the time value has been rounded during conversion.
 @discussion
 Returns YES if the time value has been rounded during a previous conversion operation, indicating potential precision loss.
 */
@property (nonatomic, readonly) BOOL isRounded;

#pragma mark - Utility Methods

/*!
 @method asDictionary
 @abstract Converts the time value to a dictionary representation.
 @return A dictionary containing the time components.
 @discussion
 This method creates a dictionary representation of the time value that can be used for serialization or storage.
 */
- (NSDictionary *)asDictionary;

/*!
 @method show
 @abstract Displays the time value in the debugger console.
 @discussion
 This method uses CMTimeShow to display a human-readable representation of the time value for debugging purposes.
 */
- (void)show;

#pragma mark - Time Conversion

/*!
 @method convertTimeScale:roundingMethod:
 @abstract Converts the time value to a new timescale.
 @param newTimescale The target timescale for conversion.
 @param method The rounding method to use during conversion.
 @discussion
 This method modifies the receiver's time value to use the specified timescale, applying the specified rounding method to handle precision loss.
 */
- (void)convertTimeScale:(int32_t)newTimescale roundingMethod:(CMTimeRoundingMethod)method;

#pragma mark - Arithmetic Operations

/*!
 @method add:
 @abstract Adds another FxTime instance to this time value.
 @param time The FxTime instance to add.
 @discussion
 This method modifies the receiver by adding the specified time value. Both time values must be numeric for the operation to succeed.
 */
- (void)add:(FxTime*)time;

/*!
 @method addTime:
 @abstract Adds a CMTime value to this time value.
 @param time The CMTime value to add.
 @discussion
 This method modifies the receiver by adding the specified CMTime value. Both time values must be numeric for the operation to succeed.
 */
- (void)addTime:(CMTime)time;

/*!
 @method subtract:
 @abstract Subtracts another FxTime instance from this time value.
 @param time The FxTime instance to subtract.
 @discussion
 This method modifies the receiver by subtracting the specified time value. Both time values must be numeric for the operation to succeed.
 */
- (void)subtract:(FxTime*)time;

/*!
 @method subtractTime:
 @abstract Subtracts a CMTime value from this time value.
 @param time The CMTime value to subtract.
 @discussion
 This method modifies the receiver by subtracting the specified CMTime value. Both time values must be numeric for the operation to succeed.
 */
- (void)subtractTime:(CMTime)time;

/*!
 @method multiply:
 @abstract Multiplies this time value by an integer multiplier.
 @param multiplier The integer multiplier.
 @discussion
 This method modifies the receiver by multiplying it by the specified integer value. The time value must be numeric for the operation to succeed.
 */
- (void)multiply:(int32_t)multiplier;

/*!
 @method multiplyByFloat64:
 @abstract Multiplies this time value by a floating-point multiplier.
 @param multiplier The floating-point multiplier.
 @discussion
 This method modifies the receiver by multiplying it by the specified floating-point value. The time value must be numeric for the operation to succeed.
 */
- (void)multiplyByFloat64:(Float64)multiplier;

/*!
 @method multiplyByRatio:divisor:
 @abstract Multiplies this time value by a rational number (multiplier/divisor).
 @param multiplier The numerator of the rational multiplier.
 @param divisor The denominator of the rational multiplier.
 @discussion
 This method modifies the receiver by multiplying it by the rational number multiplier/divisor. The time value must be numeric for the operation to succeed.
 */
- (void)multiplyByRatio:(int32_t)multiplier divisor:(int32_t)divisor;

#pragma mark - Utility Functions

/*!
 @method rationalize:
 @abstract Converts a floating-point number to a rational representation.
 @param number The floating-point number to rationalize.
 @return A SRational32 structure containing the rational representation.
 @discussion
 This method finds the best rational approximation of the given floating-point number using a default tolerance of 1.0e-6.
 */
+ (SRational32)rationalize:(Float64)number;

/*!
 @method rationalize:tolerance:
 @abstract Converts a floating-point number to a rational representation with specified tolerance.
 @param number The floating-point number to rationalize.
 @param tolerance The maximum acceptable error in the approximation.
 @return A SRational32 structure containing the rational representation.
 @discussion
 This method finds the best rational approximation of the given floating-point number within the specified tolerance using continued fractions.
 */
+ (SRational32)rationalize:(Float64)number tolerance:(double)tolerance;

#pragma mark - Comparison Operations

/*!
 @method compare:
 @abstract Compares this time value with another FxTime instance.
 @param time1 The FxTime instance to compare against.
 @return -1 if time1 is less than this time, 0 if equal, 1 if time1 is greater than this time.
 @discussion
 This method compares the input time1 with the receiver's internal time value. Both time values must be numeric for meaningful comparison.
 */
- (int32_t)compare:(FxTime*)time1;

/*!
 @method compareTime:
 @abstract Compares this time value with a CMTime value.
 @param time1 The CMTime value to compare against.
 @return -1 if time1 is less than this time, 0 if equal, 1 if time1 is greater than this time.
 @discussion
 This method compares the input time1 with the receiver's internal time value. Both time values must be numeric for meaningful comparison.
 */
- (int32_t)compareTime:(CMTime)time1;

#pragma mark - Min/Max Operations

/*!
 @method minimum:
 @abstract Sets this time value to the minimum of this time and another FxTime instance.
 @param time The FxTime instance to compare against.
 @discussion
 This method modifies the receiver to contain the smaller of the two time values.
 */
- (void)minimum:(FxTime*)time;

/*!
 @method minimumTime:
 @abstract Sets this time value to the minimum of this time and a CMTime value.
 @param time The CMTime value to compare against.
 @discussion
 This method modifies the receiver to contain the smaller of the two time values.
 */
- (void)minimumTime:(CMTime)time;

/*!
 @method maximum:
 @abstract Sets this time value to the maximum of this time and another FxTime instance.
 @param time The FxTime instance to compare against.
 @discussion
 This method modifies the receiver to contain the larger of the two time values.
 */
- (void)maximum:(FxTime*)time;

/*!
 @method maximumTime:
 @abstract Sets this time value to the maximum of this time and a CMTime value.
 @param time The CMTime value to compare against.
 @discussion
 This method modifies the receiver to contain the larger of the two time values.
 */
- (void)maximumTime:(CMTime)time;

#pragma mark - Absolute Value

/*!
 @property absoluteValue
 @abstract The absolute value of this time as a new FxTime instance.
 @discussion
 Returns a new FxTime instance containing the absolute value of this time. The original time value is not modified.
 */
@property (readonly) FxTime* absoluteValue;

/*!
 @property absoluteValueTime
 @abstract The absolute value of this time as a CMTime value.
 @discussion
 Returns a CMTime structure containing the absolute value of this time. The original time value is not modified.
 */
@property (assign, readonly) CMTime absoluteValueTime;

@end

#endif
