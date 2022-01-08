// StakeTotalModel.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation

struct StakeTotal: Codable, Hashable, Equatable {
    var stakeShares: BigUInt = 0
    var stakedHearts: BigUInt = 0
    var interestHearts: BigUInt = 0
    var interestSevenDayHearts: BigUInt = 0
    var bigPayDayHearts: BigUInt = 0

    var balanceHearts: BigUInt {
        stakedHearts + interestHearts + bigPayDayHearts
    }

    static func + (left: StakeTotal, right: StakeTotal) -> StakeTotal {
        var total = StakeTotal()
        total.stakeShares = left.stakeShares + right.stakeShares
        total.stakedHearts = left.stakedHearts + right.stakedHearts
        total.interestHearts = left.interestHearts + right.interestHearts
        total.interestSevenDayHearts = left.interestSevenDayHearts + right.interestSevenDayHearts
        total.bigPayDayHearts = left.bigPayDayHearts + right.bigPayDayHearts
        return total
    }
}
