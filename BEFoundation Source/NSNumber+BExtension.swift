/*!
 @header		NSNumber+BExtension.swift
 @copyright		-© 2025 Delicense - @belisoful. All rights released.
 @date			2025-01-01
 @abstract
 @discussion	This is unfinished and unformed EXPERIMENTAL code for swift
*/

import Foundation

infix operator --
infix operator ++

public extension NSNumber {
	
	static func += (lhs: inout NSNumber, rhs: NSNumber) {
		lhs = lhs + rhs
	}
	
	static func -= (lhs: inout NSNumber, rhs: NSNumber) {
		lhs = lhs - rhs
	}
	
	static func *= (lhs: inout NSNumber, rhs: NSNumber) {
		lhs = lhs * rhs
	}
	
	static func /= (lhs: inout NSNumber, rhs: NSNumber) {
		lhs = lhs / rhs
	}
	
	static func %= (lhs: inout NSNumber, rhs: NSNumber) {
		lhs = lhs % rhs
	}
	
	static func ^= (lhs: inout NSNumber, rhs: NSNumber) {
		lhs = lhs ^ rhs
	}
}

@objc enum NSNumberMathOperation: Int {
	case add
	case subtract
	case multiply
	case divide
	case modulus
	case power
	case xor
}


private func numberOperation(operation: NSNumberMathOperation, first: NSNumber, second: NSNumber) -> NSNumber {
	// Define the precedence order of types
	let typeOrder: [UInt8] = [
		UInt8(ascii: "c"), UInt8(ascii: "s"), UInt8(ascii: "i"), UInt8(ascii: "l"), UInt8(ascii: "q"),
		
		UInt8(ascii: "B"),
		UInt8(ascii: "C"), UInt8(ascii: "S"), UInt8(ascii: "I"), UInt8(ascii: "L"), UInt8(ascii: "Q"),
		
		UInt8(ascii: "f"), UInt8(ascii: "d")
	]

	// Access the characters of the objCType strings
	let firstType = UInt8(first.objCType[0])
	let secondType = UInt8(second.objCType[0])

	// Determine the index of the highest precedence type
	let firstIndex = typeOrder.firstIndex(of: firstType) ?? Int.min
	let secondIndex = typeOrder.firstIndex(of: secondType) ?? Int.min
	let highestIndex = max(firstIndex, secondIndex)
	let highestType = typeOrder[highestIndex]

	var resultNumber: NSNumber = 0
	if (highestIndex <= 10) {
		var firstValue:UInt64
		if (firstIndex <= 4) {
			firstValue = UInt64(first.int64Value)
		} else {
			firstValue = first.uint64Value
		}
		
		var secondValue:UInt64
		if (secondIndex <= 4) {
			secondValue = UInt64(second.int64Value)
		} else {
			secondValue = second.uint64Value
		}
		var result: UInt64 = 0
		
		switch operation {
			case .add:
				result = firstValue + secondValue
			case .subtract:
				result = firstValue - secondValue
			case .multiply:
				result = firstValue * secondValue
			case .divide:
				result = (secondValue != 0) ? (firstValue / secondValue) : 0;
			case .modulus:
				result = firstValue % secondValue;
			case .power:
				result = UInt64(pow(Double(firstValue), Double(secondValue)))
			case .xor:
				result = firstValue ^ secondValue
		}
		if (highestType == UInt8(ascii: "c")) {
			resultNumber = NSNumber(value: Int8(result))
		} else if (highestType == UInt8(ascii: "C")) {
			resultNumber = NSNumber(value: UInt8(result))
		} else if (highestType == UInt8(ascii: "s")) {
			resultNumber = NSNumber(value: Int16(result))
		} else if (highestType == UInt8(ascii: "S")) {
			resultNumber = NSNumber(value: UInt16(result))
		} else if (highestType == UInt8(ascii: "i")) {
			resultNumber = NSNumber(value: Int32(result))
		} else if (highestType == UInt8(ascii: "I")) {
			resultNumber = NSNumber(value: UInt32(result))
		} else if (highestType == UInt8(ascii: "l")) {
			resultNumber = NSNumber(value: Int(result))
		} else if (highestType == UInt8(ascii: "L")) {
			resultNumber = NSNumber(value: UInt(result))
		} else if (highestType == UInt8(ascii: "q")) {
			resultNumber = NSNumber(value: Int64(result))
		} else if (highestType == UInt8(ascii: "Q")) {
			resultNumber = NSNumber(value: UInt64(result))
		}
	} else {
		let firstValue: Double = first.doubleValue
		let secondValue: Double = second.doubleValue
		
		var result: Double = 0
		
		switch operation {
		case .add:
			result = firstValue + secondValue
		case .subtract:
			result = firstValue - secondValue
		case .multiply:
			result = firstValue * secondValue
		case .divide:
			if secondValue != 0 {
				result = firstValue / secondValue
			} else {
				result = Double.nan
			}
		case .modulus:
			result = fmod(firstValue, secondValue)
		case .power:
			result = pow(firstValue, secondValue)
		case .xor:
			result = 0
		}
		if (highestType == UInt8(ascii: "f")) {
			resultNumber = NSNumber(value: Float(result))
		} else if (highestType == UInt8(ascii: "d")) {
			resultNumber = NSNumber(value: result)
		}
	}

	return resultNumber
}





///Add two numbers
public func + (first: NSNumber, second:NSNumber) -> NSNumber {
	return numberOperation(operation: .add, first: first, second: second)
}

///Subtract two numbers
public func - (first: NSNumber, second:NSNumber) -> NSNumber {
	return numberOperation(operation: .subtract, first: first, second: second)
}

///Multiply two numbers
public func * (first: NSNumber, second:NSNumber) -> NSNumber {
	return numberOperation(operation: .multiply, first: first, second: second)
}

///Divide two numbers
public func / (first: NSNumber, second:NSNumber) -> NSNumber {
	return numberOperation(operation: .divide, first: first, second: second)
}

///Divide two numbers
public func % (first: NSNumber, second:NSNumber) -> NSNumber {
	return numberOperation(operation: .modulus, first: first, second: second)
}

///Divide two numbers
public func pow (first: NSNumber, second:NSNumber) -> NSNumber {
	return numberOperation(operation: .power, first: first, second: second)
}
public func | (first: NSNumber, second:NSNumber) -> NSNumber {
	return true;
}
public func & (first: NSNumber, second:NSNumber) -> NSNumber {
	return true;
}
public func ^ (first: NSNumber, second:NSNumber) -> NSNumber {
	return true;
}

///Postfix increment two numbers
public prefix func ~(first: NSNumber) -> NSNumber {
	let type = UInt8(first.objCType[0])
	
	var number:UInt64
	switch type {
		case UInt8(ascii: "c"):
			number = UInt64(first.int8Value)
		case UInt8(ascii: "s"):
			number = UInt64(first.int16Value)
		case UInt8(ascii: "i"):
			number = UInt64(first.intValue)
		case UInt8(ascii: "l"):
			number = UInt64(first.int32Value)
		case UInt8(ascii: "q"):
			number = UInt64(first.int64Value)
		
		case UInt8(ascii: "B"):
			number = UInt64(first.uint8Value)
		case UInt8(ascii: "C"):
			number = UInt64(first.uint8Value)
		case UInt8(ascii: "S"):
			number = UInt64(first.uint8Value)
		case UInt8(ascii: "I"):
			number = UInt64(first.uint8Value)
		case UInt8(ascii: "L"):
			number = UInt64(first.uint8Value)
		case UInt8(ascii: "Q"):
			number = UInt64(first.uint8Value)
		
	default:
		number = 0
	}
	number = ~number;
	
	var resultNumber:NSNumber
	switch type {
		case UInt8(ascii: "c"):
			resultNumber = NSNumber(value: Int8(number))
		case UInt8(ascii: "s"):
			resultNumber = NSNumber(value: Int16(number))
		case UInt8(ascii: "i"):
			resultNumber = NSNumber(value: Int(number))
		case UInt8(ascii: "l"):
			resultNumber = NSNumber(value: Int32(number))
		case UInt8(ascii: "q"):
			resultNumber = NSNumber(value: Int64(number))
		
		case UInt8(ascii: "B"):
			resultNumber = NSNumber(value: UInt8(number))
		case UInt8(ascii: "C"):
			resultNumber = NSNumber(value: UInt8(number))
		case UInt8(ascii: "S"):
			resultNumber = NSNumber(value: UInt16(number))
		case UInt8(ascii: "I"):
			resultNumber = NSNumber(value: UInt(number))
		case UInt8(ascii: "L"):
			resultNumber = NSNumber(value: UInt32(number))
		case UInt8(ascii: "Q"):
			resultNumber = NSNumber(value: UInt64(number))
		
	default:
		resultNumber = 0
	}
	return resultNumber
}

public func < (first: NSNumber, second:NSNumber) -> ObjCBool {
	return ;
}
public func <= (first: NSNumber, second:NSNumber) -> ObjCBool {
	return true;
}
public func > (first: NSNumber, second:NSNumber) -> ObjCBool {
	return true;
}
public func >= (first: NSNumber, second:NSNumber) -> ObjCBool {
	return true;
}
public func == (first: NSNumber, second:NSNumber) -> ObjCBool {
	return true;
}
public func != (first: NSNumber, second:NSNumber) -> ObjCBool {
	return true;
}

///Postfix decrement two numbers
public prefix func -- (first: NSNumber) -> NSNumber {
	return numberOperation(operation: .subtract, first: first, second: 1)
}

///Postfix decrement two numbers
public postfix func -- (first: NSNumber) -> NSNumber {
	return numberOperation(operation: .subtract, first: first, second: 1)
}


public prefix func ++(first: NSNumber) -> NSNumber {
	return numberOperation(operation: .add, first: first, second: 1)
}

///Postfix increment two numbers
public postfix func ++(first: NSNumber) -> NSNumber {
	return numberOperation(operation: .add, first: first, second: 1)
}
