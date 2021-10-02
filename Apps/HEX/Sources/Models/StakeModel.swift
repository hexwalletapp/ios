// StakeModel.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation

struct Stake: Codable, Hashable, Equatable, Identifiable {
    var id: BigUInt { stakeId }
    let stakeId: BigUInt
    let stakedHearts: BigUInt
    let stakeShares: BigUInt
    let lockedDay: UInt16
    let stakedDays: UInt16
    let unlockedDay: UInt16
    let isAutoStake: Bool
    let percentComplete: Double
    let daysRemaining: Int
    let status: StakeStatus
    let startDate: Date
    let endDate: Date
    var interestHearts: BigUInt
    var bigPayDayHearts: BigUInt?

    var balanceHearts: BigUInt {
        switch bigPayDayHearts {
        case let .some(bigPayDayHearts):
            return stakedHearts + interestHearts + bigPayDayHearts
        case .none:
            return stakedHearts + interestHearts
        }
    }

    var roiPercent: Double {
        interestHearts.hex.doubleValue / stakedHearts.hex.doubleValue
    }

    func roiPercent(price: Double) -> Double {
        interestHearts.hexAt(price: price).doubleValue / stakedHearts.hexAt(price: price).doubleValue
    }

    var apyPercent: Double {
        let stakeDays = Int(stakedDays) + max(daysRemaining, 0)
        return roiPercent * (Double(k.ONE_YEAR) / Double(stakeDays))
    }

    func apyPercent(price: Double) -> Double {
        let stakeDays = Int(stakedDays) + max(daysRemaining, 0)
        return roiPercent(price: price) * (Double(k.ONE_YEAR) / Double(stakeDays))
    }
}
