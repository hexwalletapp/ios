// Constants.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
import SwiftUI

struct k {
    static let HEARTS_UINT_SHIFT = BigUInt(72)
    static let HEARTS_MASK = (BigUInt(1) << k.HEARTS_UINT_SHIFT) - BigUInt(1)
    static let SATS_UINT_SHIFT = BigUInt(56)
    static let SATS_MASK = (BigUInt(1) << SATS_UINT_SHIFT) - BigUInt(1)
    static let ONE_WEEK = BigUInt(7)
    static let ACCOUNTS_KEY = "evm_account_key"
    static let HEX_COLORS = [
        Color(red: 1.000, green: 0.859, blue: 0.004, opacity: 1.000),
        Color(red: 1.000, green: 0.522, blue: 0.122, opacity: 1.000),
        Color(red: 1.000, green: 0.239, blue: 0.239, opacity: 1.000),
        Color(red: 1.000, green: 0.059, blue: 0.435, opacity: 1.000),
        Color(red: 0.996, green: 0.004, blue: 0.980, opacity: 1.000),
    ]
    static let PULSE_COLORS = [
        Color(red: 1.000, green: 0.000, blue: 0.000, opacity: 1.000),
        Color(red: 0.902, green: 0.098, blue: 0.902, opacity: 1.000),
        Color(red: 0.502, green: 0.000, blue: 1.000, opacity: 1.000),
        Color(red: 0.000, green: 0.502, blue: 1.000, opacity: 1.000),
        Color(red: 0.000, green: 0.918, blue: 1.000, opacity: 1.000),
    ]
    static let CARD_PADDING_BOTTOM = CGFloat(48)
    static let CARD_PADDING_TOP = CGFloat(12)
}
