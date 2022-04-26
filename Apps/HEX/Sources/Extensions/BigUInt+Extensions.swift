// BigUInt+Extensions.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation

extension BigUInt {
    var number: NSNumber {
        NSNumber(value: Double(self))
    }

    var hex: NSNumber {
        quotientAndRemainder(dividingBy: BigUInt(100_000_000)).quotient.number
    }

    func hexAt(price: Double) -> NSNumber {
        NSNumber(value: hex.doubleValue * price)
    }
}
