// StakeModel.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
import HEXSmartContract

struct Stake: Codable, Hashable, Equatable, Identifiable {
    var id: BigUInt { stakeId }
    let stakeId: BigUInt
    let stakedHearts: BigUInt
    let stakeShares: BigUInt
    let lockedDay: UInt16
    let stakedDays: UInt16
    let stakeEndDay: UInt16
    let penaltyDays: UInt16
    let unlockedDay: UInt16
    let isAutoStake: Bool
    let percentComplete: Double
    let servedDays: UInt16
    let status: StakeStatus
    let startDate: Date
    let endDate: Date
    var penaltyHearts: BigUInt
    var interestHearts: BigUInt
    var interestSevenDayHearts: BigUInt
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
        let stakeDays = max(stakedDays, servedDays)
        return roiPercent * (Double(k.ONE_YEAR) / Double(stakeDays))
    }

    func apyPercent(price: Double) -> Double {
        let stakeDays = max(stakedDays, servedDays)
        return roiPercent(price: price) * (Double(k.ONE_YEAR) / Double(stakeDays))
    }

    func calculatePayout(globalInfo: GlobalInfo,
                         beginDay: Int,
                         endDay: Int,
                         dailyData: [DailyData]) -> (payout: BigUInt,
                                                     bigPayDay: BigUInt?)
    {
        guard !dailyData.isEmpty else { return (0, nil) }
        let payout = dailyData[beginDay ..< endDay].reduce(0) { $0 + ((stakeShares * $1.payout) / $1.shares) }

        var bigPayDay: BigUInt?
        if beginDay ..< endDay ~= Int(k.BIG_PAY_DAY) {
            let stakeSharesTotal = dailyData[Int(k.BIG_PAY_DAY)].shares

            let bigPaySlice = globalInfo.unclaimedSatoshisTotal * k.HEARTS_PER_SATOSHI * stakeShares / stakeSharesTotal

            let viralRewards = bigPaySlice * globalInfo.claimedBtcAddrCount / k.CLAIMABLE_BTC_ADDR_COUNT
            let criticalMass = bigPaySlice * globalInfo.claimedSatoshisTotal / k.CLAIMABLE_SATOSHIS_TOTAL

            let adoptionBonus = viralRewards + criticalMass

            bigPayDay = bigPaySlice + adoptionBonus
//            payout += bigPaySlice + adoptionBonus
        }

        return (payout, bigPayDay)
    }

    func estimatePayoutRewardsDay(globalInfo _: GlobalInfo) -> (payout: BigUInt,
                                                                bigPayDay: BigUInt?)
    {
        return (0, nil)
    }
}
