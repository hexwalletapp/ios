// StakeTotalModel.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation

struct StakeTotal: Codable, Hashable, Equatable {
    var stakeShares: BigUInt = 0
    var stakedHearts: BigUInt = 0
    var interestHearts: BigUInt = 0
    var interestDailyHearts: BigUInt = 0
    var interestWeeklyHearts: BigUInt = 0
    var interestMonthlyHearts: BigUInt = 0
    var bigPayDayHearts: BigUInt = 0

    var balanceHearts: BigUInt {
        stakedHearts + interestHearts + bigPayDayHearts
    }

    static func + (left: StakeTotal, right: StakeTotal) -> StakeTotal {
        var total = StakeTotal()
        total.stakeShares = left.stakeShares + right.stakeShares
        total.stakedHearts = left.stakedHearts + right.stakedHearts
        total.interestHearts = left.interestHearts + right.interestHearts
        total.interestDailyHearts = left.interestDailyHearts + right.interestDailyHearts
        total.interestWeeklyHearts = left.interestWeeklyHearts + right.interestWeeklyHearts
        total.interestMonthlyHearts = left.interestMonthlyHearts + right.interestMonthlyHearts
        total.bigPayDayHearts = left.bigPayDayHearts + right.bigPayDayHearts
        return total
    }

    func interest(payout: PayoutEarnings) -> BigUInt {
        switch payout {
        case .dailyTotal: return interestDailyHearts
        case .weeklyTotal: return interestWeeklyHearts
        case .monthlyTotal: return interestMonthlyHearts
        }
    }
}
