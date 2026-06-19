/*!
 * @file		BERuntime.m
 * @copyright	-© 2025 Delicense - @belisoful. All rights released.
 * @date		2025-01-01
 * @author		belisoful@icloud.com
 * @abstract	Implementation of runtime utility functions for Objective-C class and method introspection
 * @discussion	This implementation provides utility functions for working with Objective-C runtime,
 *             including metaclass resolution and method existence checking. These functions
 *             extend the standard runtime API with commonly needed functionality.
 */

#import "BERuntime.h"

/*!
 * @function metaclass_getClass
 * @abstract Retrieves the class instance corresponding to a given metaclass
 * @discussion Given a metaclass, this function returns the corresponding class instance.
 *             The function first validates that the input is indeed a metaclass, then
 *             retrieves the class name and looks up the corresponding class instance.
 *             Finally, it verifies that the found class's metaclass matches the input.
 * @param metaClass The metaclass to resolve to its corresponding class
 * @return The class instance corresponding to the metaclass, or nil if the metaclass is invalid
 *         or if no corresponding class is found
 */
Class metaclass_getClass(Class metaClass)
{
	if (!metaClass || !class_isMetaClass(metaClass)) {
		return nil;
	}

	const char *name = class_getName(metaClass);
	if (!name) {
		return nil;
	}

	Class candidate = objc_getClass(name);
	if (!candidate) {
		return nil;
	}

	if (object_getClass(candidate) == metaClass) {
		return candidate;
	}
	return nil;
}

/*!
 * @function class_hasMethod
 * @abstract Checks if a class defines a specific method
 * @discussion This function checks if the given class has a method with the specified selector.
 *             It retrieves the list of methods defined on the class (not inherited methods)
 *             and searches for the specified selector. Memory allocated for the method list
 *             is properly freed after the search.
 * @param cls The class to check for the method
 * @param selector The selector of the method to look for
 * @return YES if the class defines the method, NO otherwise or if parameters are invalid
 */
BOOL class_hasMethod(Class cls, SEL selector)
{
	if (!cls || !selector) {
		return NO;
	}
	unsigned int methodCount = 0;
	Method *methods = class_copyMethodList(cls, &methodCount);
	if (!methods) {
		return NO;
	}
	BOOL found = NO;
	for (unsigned int i = 0; i < methodCount; i++) {
		if (method_getName(methods[i]) == selector) {
			found = YES;
			break;
		}
	}
	free(methods);
	return found;
}
