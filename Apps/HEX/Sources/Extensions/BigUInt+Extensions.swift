// BigUInt+Extensions.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation

extension BigUInt {
    var number: NSNumber {
        NSNumber(value: Double(self))
    }

    var hex: NSNumber {
        NSNumber(value: Double(self / BigUInt(100_000_000)))
    }

    func hexAt(price: Double) -> NSNumber {
        return NSNumber(value: hex.doubleValue * price)
    }
}
