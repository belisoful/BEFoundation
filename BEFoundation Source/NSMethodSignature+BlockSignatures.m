/*!
 @file			NSObject+DynamicMethods.m
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract
 @discussion
*/

#import "NSMethodSignature+BlockSignatures.h"
#import "BE_ARC.h"

#define NSStringTypeEncode(type) ([NSString stringWithCString:@encode(type) encoding:NSASCIIStringEncoding])

@implementation NSMethodSignature (BlockSignatures)

+ (nullable NSMethodSignature *)signatureFromBlock:(nonnull id)block
{
	NSString *blockSignature = [BEMethodSignatureHelper blockSignatureString:block];
	
	if (!blockSignature) {
		return nil;
	}
	
	return [NSMethodSignature signatureWithObjCTypes:[blockSignature cStringUsingEncoding:NSASCIIStringEncoding]];
}


+ (nullable NSMethodSignature *)methodSignatureFromBlock:(nonnull id)block
{
	if(!block) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: nil argument", NSMethodSignature.className, NSStringFromSelector(_cmd)];
	} else if (![block isKindOfClass:NSClassFromString(@"NSBlock")]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: Argument is not a NSBlock", NSMethodSignature.className, NSStringFromSelector(_cmd)];
	}
	
	const char *rawBlockSignature = [BEMethodSignatureHelper rawBlockSignatureChar:block];
	
	if (!rawBlockSignature) {
		return nil;
	}
	
	NSString* blockSignature = [BEMethodSignatureHelper parseBlockSignature:rawBlockSignature parseFlags:BERequireSelectorFlag];
	
	if (!blockSignature) {
		return nil;
	}
	
	return [NSMethodSignature signatureWithObjCTypes:[blockSignature cStringUsingEncoding:NSASCIIStringEncoding]];
}



- (NSString *)methodReturnTypeString
{
	return [NSString stringWithCString:self.methodReturnType encoding:NSASCIIStringEncoding];
}


- (nonnull NSString *)getArgumentTypeStringAtIndex:(NSUInteger)idx
{
	const char *argType = [self getArgumentTypeAtIndex:idx];
	return [NSString stringWithCString:argType encoding:NSASCIIStringEncoding];
}


- (NSUInteger)getArgumentSizeAtIndex:(NSUInteger)idx
{
	const char *type = [self getArgumentTypeAtIndex:idx];
	if (!type) {
		return 0;
	}
	NSUInteger size = 0;
	if (strcmp(type, @encode(char)) == 0 || strcmp(type, @encode(unsigned char)) == 0) {
		size = sizeof(int);
	} else if (strcmp(type, @encode(short)) == 0 || strcmp(type, @encode(unsigned short)) == 0) {
		size = sizeof(int);
	} else if (strcmp(type, @encode(int)) == 0 || strcmp(type, @encode(unsigned int)) == 0) {
		size = sizeof(int);
	} else if (strcmp(type, @encode(long)) == 0 || strcmp(type, @encode(unsigned long)) == 0) {
		size = sizeof(long);
	} else if (strcmp(type, @encode(long long)) == 0 || strcmp(type, @encode(unsigned long long)) == 0) {
		size = sizeof(long long);
	} else if (strcmp(type, @encode(BOOL)) == 0) {
		size = sizeof(int);
	} else if (strcmp(type, @encode(float)) == 0) {
		size = sizeof(float);
	} else if (strcmp(type, @encode(double)) == 0) {
		size = sizeof(double);
	} else if (strcmp(type, @encode(long double)) == 0) {
		size = sizeof(long double);
	} else if (strcmp(type, @encode(char*)) == 0) { //C String
		size = sizeof(char*);
	} else if (type[0] == @encode(id)[0]) {
		size = sizeof(id);
	} else if (strcmp(type, @encode(Class)) == 0) {
		size = sizeof(Class);
	} else if (strcmp(type, @encode(SEL)) == 0) {
		size = sizeof(SEL);
	} else if (strcmp(type, "?") == 0 || type[0] == '^' || type[0] == '[' || type[0] == '{' || type[0] == '(') { //Pointers
		size = sizeof(void*);
	}
	return size;
}

@end




@implementation BEMethodSignatureHelper

+ (nullable const char *)rawBlockSignatureChar:(nonnull id)block
{
	if(!block) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: nil argument", NSMethodSignature.className, NSStringFromSelector(_cmd)];
	} else if (![block isKindOfClass:NSClassFromString(@"NSBlock")]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: Argument is not a NSBlock", NSMethodSignature.className, NSStringFromSelector(_cmd)];
	}
	return NSSignatureForBlock(block);
}


+ (nullable NSString *)rawBlockSignatureString:(nonnull id)block
{
	if(!block) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: nil argument", NSMethodSignature.className, NSStringFromSelector(_cmd)];
	} else if (![block isKindOfClass:NSClassFromString(@"NSBlock")]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: Argument is not a NSBlock", NSMethodSignature.className, NSStringFromSelector(_cmd)];
	}
	
	const char *rawBlockSignature = NSSignatureForBlock(block);
	if (!rawBlockSignature) {
		return nil;
	}
	return [NSString stringWithCString:rawBlockSignature encoding:NSASCIIStringEncoding];
}


+ (nullable NSString *)blockSignatureString:(nonnull id)block
{
	if(!block) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: nil argument", NSMethodSignature.className, NSStringFromSelector(_cmd)];
	} else if (![block isKindOfClass:NSClassFromString(@"NSBlock")]) {
		[NSException raise:NSInvalidArgumentException
					format:@"*** -[%@ %@]: Argument is not a NSBlock", NSMethodSignature.className, NSStringFromSelector(_cmd)];
	}
	const char *rawBlockSignature = NSSignatureForBlock(block);
	
	if (!rawBlockSignature) {
		return nil;
	}
	
	return [BEMethodSignatureHelper parseBlockSignature:rawBlockSignature parseFlags:BENoMethodSignatureFlag];
}



+ (nullable NSString *)parseBlockSignature:(const char *)signature parseFlags:(BEMethodSignatureParseFlags)flags
{
	if (!signature) {
		return nil;
	}
	
	NSMutableString *methodSignature = [NSMutableString string];
	const char *p = signature;
	
	// Parse return type
	NSString *returnType = [self parseTypeAtPointer:&p];
	if (!returnType) {
		return nil;
	}
	
	[methodSignature appendString:returnType];
	
	if(!*p){
		return nil;
	}
	// Parse frame size
	NSInteger frameSize = [self parseNumberAtPointer:&p];
	
	// Parse arguments
	NSMutableArray<NSString*> *argTypes = [NSMutableArray array];
	NSMutableArray<NSNumber*> *argOffsets = [NSMutableArray array];
	
	while (*p) {
		NSString *argType = [self parseTypeAtPointer:&p];
		if (!argType) {
			return nil;
		}
		
		NSInteger offset = [self parseNumberAtPointer:&p];
		
		[argTypes addObject:argType];
		[argOffsets addObject:@(offset)];
	}
	
	/*
	NSMutableArray<NSNumber*> *argSizes = [NSMutableArray array];
	__block NSInteger lastOffset = -1;
	[argOffsets enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if (lastOffset >= 0) {
			[argSizes addObject:@(obj.intValue - lastOffset)];
		}
		lastOffset = obj.intValue;
	}];
	[argSizes addObject:@(frameSize - lastOffset)];
	 */
	
	// Skip the first argument (block itself) if it's @?
	NSInteger offsetAdjustment = 0;
	if (!(flags & BEKeepBlockArgumentFlag) && argTypes.count > 0 && [argTypes[0] isEqualToString:@"@?"]) {
		[argTypes removeObjectAtIndex:0];
		[argOffsets removeObjectAtIndex:0];
		frameSize -= sizeof(id);
		offsetAdjustment -= sizeof(id);
	}
	
	// Check if we need to add selector as second argument
	BOOL needsSelector = NO, hasSelector, replicateSelector = flags & BEReplicateSelectorFlag;
	
	hasSelector = argTypes.count > 1 && [argTypes[1] isEqualToString:NSStringTypeEncode(SEL)];
	if ((flags & BERequireSelectorFlag) && !hasSelector) {
		// Add space for the selector argument
		needsSelector = YES;
		frameSize += sizeof(SEL);
	}
	if (hasSelector && replicateSelector) {
		frameSize += sizeof(SEL);
	}
	
	// Append frame size
	[methodSignature appendFormat:@"%ld", (long)frameSize];
	
	// Append arguments
	for (NSInteger i = 0; i < argTypes.count; i++) {
		// Insert selector as second argument if needed
		if (i == 1 && needsSelector) {
			[methodSignature appendFormat:@"%s%ld", @encode(SEL), (long)sizeof(SEL)];
			offsetAdjustment += sizeof(SEL);
		}
		
		[methodSignature appendFormat:@"%@%ld", argTypes[i], (long)[argOffsets[i] integerValue] + offsetAdjustment];
		
		if (i == 1 && hasSelector && replicateSelector) {
			[methodSignature appendFormat:@"%s%ld", @encode(SEL), (long)(sizeof(id) + sizeof(SEL))];
			offsetAdjustment += sizeof(SEL);
		}
	}
	if (needsSelector && argTypes.count == 1) {
		[methodSignature appendFormat:@"%s%ld", @encode(SEL), (long)sizeof(SEL)];
	}
	
	return [methodSignature copy];
}


+ (NSString *)parseTypeAtPointer:(const char **)pointer
{
	const char *p = *pointer;
	const char *start = p;
	
	if (!*p) {
		return nil;
	}
	
	if (isdigit(*p)) {
		return nil;
	}
	
	switch (*p) {
		case 'c': case 'i': case 's': case 'l': case 'q': // signed integers
		case 'C': case 'I': case 'S': case 'L': case 'Q': // unsigned integers
		case 'f': case 'd': case 'D': // floats
		case 'B': case 'v': case '*': case '#': case ':': // other basic types
			p++;
			break;
			
		case '@': // object
			p++; // skip '@'
			// Check for optional specifiers after @
			if (*p == '?') {
				// Block type: @?
				p++;
			} else if (*p == '"') {
				// Class name in quotes: @"ClassName"
				p++; // skip opening quote
				while (*p && *p != '"') p++; // skip to closing quote
				if (*p == '"') p++; // skip closing quote
			}
			// If neither ? nor ", it's just a generic object (@)
			break;
			
		case '^': // pointer
			p++;
			// Parse the pointed-to type recursively
			{
				NSString *pointedType = [self parseTypeAtPointer:&p];
				if (!pointedType) return nil;
			}
			break;
			
		case '[': // array
			p++; // skip '['
			// Parse array size
			while (*p && isdigit(*p)) p++;
			// Parse array element type
			{
				NSString *elementType = [self parseTypeAtPointer:&p];
				if (!elementType) return nil;
			}
			if (*p == ']') p++; // skip ']'
			break;
			
		case '{': // structure
			p++; // skip '{'
			// Parse struct name (optional)
			while (*p && *p != '=' && *p != '}') p++;
			if (*p == '=') {
				p++; // skip '='
				// Parse struct members
				while (*p && *p != '}') {
					NSString *memberType = [self parseTypeAtPointer:&p];
					if (!memberType) break;
				}
			}
			if (*p == '}') p++; // skip '}'
			break;
			
		case '(': // union
			p++; // skip '('
			// Parse union name (optional)
			while (*p && *p != '=' && *p != ')') p++;
			if (*p == '=') {
				p++; // skip '='
				// Parse union members
				while (*p && *p != ')') {
					NSString *memberType = [self parseTypeAtPointer:&p];
					if (!memberType) break;
				}
			}
			if (*p == ')') p++; // skip ')'
			break;
			
		case 'b': // bitfield
			p++; // skip 'b'
			// Parse bitfield size
			while (*p && isdigit(*p)) p++;
			break;
			
		default:
			// Unknown type, try to advance at least one character
			p++;
			if (isdigit(*p)) {
				break;
			}
	}
	
	NSString *result = [[NSString alloc] initWithBytes:start
												length:(p - start)
											  encoding:NSASCIIStringEncoding];
	*pointer = p;
	return result;
}

+ (NSInteger)parseNumberAtPointer:(const char **)pointer
{
	if(!pointer || !*pointer) {
		return 0;
	}
	const char *p = *pointer;
	NSInteger result = 0;
	
	// Skip non-digits
	while (*p && !isdigit(*p)) p++;
	
	// Parse digits
	while (*p && isdigit(*p)) {
		result = result * 10 + (*p - '0');
		p++;
	}
	
	*pointer = p;
	return result;
}

@end
