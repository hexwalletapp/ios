//
//  BigUInt+Extensions.swift
//  BigUInt+Extensions
//
//  Created by Joe Blau on 9/12/21.
//

import BigInt
import Foundation

extension BigUInt {
    
    var number: NSNumber {
        NSNumber(value: Double(self))
    }
    
    var hex: NSNumber {
        NSNumber(value: Double(self / BigUInt(100_000_000) ))
    }
    
    func hexAt(price: Double) -> NSNumber {
        NSNumber(value: hex.doubleValue * price)
    }
}
