// StakeModel.swift
// Copyright (c) 2022 Joe Blau

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
    var interestDailyHearts: BigUInt
    var interestWeeklyHearts: BigUInt
    var interestMonthlyHearts: BigUInt
    var bigPayDayHearts: BigUInt?

    init(stake: StakeLists_Parameter.Response, onChainData: OnChainData) {
        let stakeUnlockDay = BigUInt(stake.unlockedDay)
        let stakeLockedDay = BigUInt(stake.lockedDay)
        let currentDay = onChainData.currentDay

        let servedDays: UInt16
        switch stake.lockedDay {
        case let x where x <= currentDay:
            servedDays = min(UInt16(stake.stakedDays), UInt16(currentDay) - UInt16(stake.lockedDay))
        default:
            servedDays = 0
        }
        let stakeEndDay = BigUInt(stake.lockedDay + stake.stakedDays)
        let gracePeriod = stakeEndDay + k.GRACE_PERIOD

        let status: StakeStatus
        // Calculate Status
        if stake.unlockedDay > 0, stake.unlockedDay < stake.lockedDay + stake.stakedDays {
            status = .emergencyEnd
        } else if stake.unlockedDay > 0, stakeEndDay ..< currentDay ~= stakeUnlockDay {
            status = .goodAccounting
        } else if stake.unlockedDay == 0, stakeEndDay ..< gracePeriod ~= stakeUnlockDay {
            status = .gracePeriod
        } else if stake.unlockedDay == 0, currentDay > gracePeriod {
            status = .bleeding
        } else {
            status = .active
        }

        var penaltyDays = (stake.stakedDays + 1) / 2
        if penaltyDays < k.EARLY_PENALTY_MIN_DAYS {
            penaltyDays = UInt16(k.EARLY_PENALTY_MIN_DAYS)
        }

        let percentComplete = max(0, min(1, (Double(currentDay) - Double(stake.lockedDay)) / Double(stake.stakedDays)))

        // MARK: - Assign Variables

        stakeId = stake.stakeId
        stakedHearts = stake.stakedHearts
        stakeShares = stake.stakeShares
        lockedDay = stake.lockedDay
        stakedDays = stake.stakedDays
        self.stakeEndDay = UInt16(stakeEndDay)
        self.penaltyDays = penaltyDays
        unlockedDay = stake.unlockedDay
        isAutoStake = stake.isAutoStake
        self.percentComplete = percentComplete
        self.servedDays = servedDays
        self.status = status
        startDate = k.HEX_START_DATE.addingTimeInterval(TimeInterval(Int(stakeLockedDay) * 86400))
        endDate = k.HEX_START_DATE.addingTimeInterval(TimeInterval(Int(stakeEndDay) * 86400))
        penaltyHearts = 0
        interestHearts = 0
        interestDailyHearts = 0
        interestWeeklyHearts = 0
        interestMonthlyHearts = 0

        bigPayDayHearts = nil

        guard lockedDay <= currentDay else { return }

        let startIndex = Int(lockedDay)
        let endIndex = min(Int(stakeEndDay), Int(currentDay))
        let dayStartIndex = max(endIndex - 2, startIndex)
        let weekStartIndex = max(endIndex - 8, startIndex)
        let monthStartIndex = max(endIndex - 31, startIndex)
        let penaltyEndIndex = Int(stake.lockedDay + penaltyDays)
        let recentInterestDays = BigUInt(endIndex - weekStartIndex)

        switch servedDays {
        case 0:
            interestHearts = 0
        case let x where x > penaltyDays:
            let penaltyInterest = calculatePayout(globalInfo: onChainData.globalInfo,
                                                  beginDay: startIndex,
                                                  endDay: penaltyEndIndex,
                                                  dailyData: onChainData.dailyData)

            let deltaInterest = calculatePayout(globalInfo: onChainData.globalInfo,
                                                beginDay: penaltyEndIndex,
                                                endDay: endIndex,
                                                dailyData: onChainData.dailyData)
            // Penalty
            penaltyHearts = penaltyInterest.payout + deltaInterest.payout

            // Interest
            interestHearts = penaltyInterest.payout + deltaInterest.payout

            // Big Pay Day
            switch (penaltyInterest.bigPayDay, deltaInterest.bigPayDay) {
            case let (.some(penaltyBigPayDay), .some(deltaBigPayDay)):
                bigPayDayHearts = penaltyBigPayDay + deltaBigPayDay
            case let (.some(penaltyBigPayDay), .none):
                bigPayDayHearts = penaltyBigPayDay
            case let (.none, .some(deltaBigPayDay)):
                bigPayDayHearts = deltaBigPayDay
            case (.none, .none):
                break
            }
        default:
            let payoutInterest = calculatePayout(globalInfo: onChainData.globalInfo,
                                                 beginDay: startIndex,
                                                 endDay: endIndex,
                                                 dailyData: onChainData.dailyData)
            let penaltyPayout: BigUInt
            switch penaltyDays {
            case servedDays:
                penaltyPayout = payoutInterest.payout
            default:
                penaltyPayout = payoutInterest.payout * BigUInt(penaltyDays) / BigUInt(servedDays)
            }

            penaltyHearts = penaltyPayout
            interestHearts = payoutInterest.payout
            bigPayDayHearts = payoutInterest.bigPayDay
        }

        // Seven Day Interest
        if !recentInterestDays.isZero {
            interestDailyHearts = calculatePayout(globalInfo: onChainData.globalInfo,
                                                  beginDay: dayStartIndex,
                                                  endDay: endIndex,
                                                  dailyData: onChainData.dailyData).payout
            interestWeeklyHearts = calculatePayout(globalInfo: onChainData.globalInfo,
                                                   beginDay: weekStartIndex,
                                                   endDay: endIndex,
                                                   dailyData: onChainData.dailyData).payout
            interestMonthlyHearts = calculatePayout(globalInfo: onChainData.globalInfo,
                                                    beginDay: monthStartIndex,
                                                    endDay: endIndex,
                                                    dailyData: onChainData.dailyData).payout
        }
    }

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
        let payout = dailyData[beginDay ..< endDay - 1].reduce(0) { $0 + ((stakeShares * $1.payout) / $1.shares) }

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
