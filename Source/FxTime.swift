//
//  PrincipalDelegate.m
//  PlugIn
//
//  Created by Apple on 2/12/20.
//  Copyright © 2024 Belisoful All rights reserved.
//
import Foundation
//import CoreMedia


//Todo,  allow math operators on NSFxTime object for time

/*

// MARK: - Arithmetic Operators
extension NSFxTime {
	static func + (lhs: NSFxTime, rhs: NSFxTime) -> NSFxTime {
		return NSFxTime(cmTime: CMTimeAdd(lhs.time, rhs.time))
	}
	
	static func - (lhs: NSFxTime, rhs: NSFxTime) -> NSFxTime {
		return NSFxTime(cmTime: CMTimeSubtract(lhs.time, rhs.time))
	}
	
	static func * (lhs: NSFxTime, rhs: NSFxTime) -> NSFxTime {
		let product = CMTimeGetSeconds(lhs.time) * CMTimeGetSeconds(rhs.time)
		return NSFxTime(cmTime: CMTimeMakeWithSeconds(product, preferredTimescale: lhs.time.timescale))
	}
	
	static func / (lhs: NSFxTime, rhs: NSFxTime) -> NSFxTime {
		let quotient = CMTimeGetSeconds(lhs.time) / CMTimeGetSeconds(rhs.time)
		return NSFxTime(cmTime: CMTimeMakeWithSeconds(quotient, preferredTimescale: lhs.time.timescale))
	}
	
	static func % (lhs: NSFxTime, rhs: NSFxTime) -> NSFxTime {
		let remainder = CMTimeGetSeconds(lhs.time).truncatingRemainder(dividingBy: CMTimeGetSeconds(rhs.time))
		return NSFxTime(cmTime: CMTimeMakeWithSeconds(remainder, preferredTimescale: lhs.time.timescale))
	}
}

// MARK: - Compound Assignment Operators
extension NSFxTime {
	static func += (lhs: inout NSFxTime, rhs: NSFxTime) {
		lhs = lhs + rhs
	}
	
	static func -= (lhs: inout NSFxTime, rhs: NSFxTime) {
		lhs = lhs - rhs
	}
	
	static func *= (lhs: inout NSFxTime, rhs: NSFxTime) {
		lhs = lhs * rhs
	}
	
	static func /= (lhs: inout NSFxTime, rhs: NSFxTime) {
		lhs = lhs / rhs
	}
	
	static func %= (lhs: inout NSFxTime, rhs: NSFxTime) {
		lhs = lhs % rhs
	}
}

// MARK: - Increment/Decrement Operators
extension NSFxTime {
	// Prefix increment
	static prefix func ++ (value: inout NSFxTime) -> NSFxTime {
		let oneSecond = NSFxTime(cmTime: CMTimeMake(value: 1, timescale: 1))
		value = value + oneSecond
		return value
	}
	
	// Postfix increment
	static postfix func ++ (value: inout NSFxTime) -> NSFxTime {
		let original = value
		let oneSecond = NSFxTime(cmTime: CMTimeMake(value: 1, timescale: 1))
		value = value + oneSecond
		return original
	}
	
	// Prefix decrement
	static prefix func -- (value: inout NSFxTime) -> NSFxTime {
		let oneSecond = NSFxTime(cmTime: CMTimeMake(value: 1, timescale: 1))
		value = value - oneSecond
		return value
	}
	
	// Postfix decrement
	static postfix func -- (value: inout NSFxTime) -> NSFxTime {
		let original = value
		let oneSecond = NSFxTime(cmTime: CMTimeMake(value: 1, timescale: 1))
		value = value - oneSecond
		return original
	}
}

*/
