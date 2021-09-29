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
    static let CARD_PADDING_BOTTOM = CGFloat(48)
    static let CARD_PADDING_TOP = CGFloat(12)
    static let HEX_START_DATE = Date(timeIntervalSince1970: 1_575_273_600)
    static let GRACE_PERIOD = 14
}

struct HexManagerId: Hashable {}
struct GetPriceDebounceId: Hashable {}
struct GetDayDebounceId: Hashable {}
