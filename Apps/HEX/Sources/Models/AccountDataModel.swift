// AccountDataModel.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
import IdentifiedCollections

struct AccountData: Codable, Hashable, Equatable, Identifiable {
    var id: String { account.id }
    var account: Account
    var stakes = IdentifiedArrayOf<Stake>()
    var total = StakeTotal()
    var balanceHearts: BigUInt = 0

    mutating func globalAccountData(onChainData: OnChainData) {
        stakes.forEach { stake in
            guard stake.lockedDay <= onChainData.currentDay else { return }

            let startIndex = Int(stake.lockedDay)
            let endIndex = min(Int(stake.stakeEndDay), Int(onChainData.currentDay))
            let weekStartIndex = max(endIndex - 7, startIndex)
            let penaltyEndIndex = Int(stake.lockedDay + stake.penaltyDays)
            let recentInterestDays = BigUInt(endIndex - weekStartIndex)

            switch stake.servedDays {
            case 0:
                stakes[id: stake.id]?
                    .interestHearts = 0
            case let x where x > stake.penaltyDays:
                let penaltyInterest = stake.calculatePayout(globalInfo: onChainData.globalInfo,
                                                            beginDay: startIndex,
                                                            endDay: penaltyEndIndex,
                                                            dailyData: onChainData.dailyData)

                let deltaInterest = stake.calculatePayout(globalInfo: onChainData.globalInfo,
                                                          beginDay: penaltyEndIndex,
                                                          endDay: endIndex,
                                                          dailyData: onChainData.dailyData)
                // Peanlty
                stakes[id: stake.id]?.penaltyHearts = penaltyInterest.payout + deltaInterest.payout

                // Interest
                stakes[id: stake.id]?.interestHearts = penaltyInterest.payout + deltaInterest.payout

                // Big Pay Day
                switch (penaltyInterest.bigPayDay, deltaInterest.bigPayDay) {
                case let (.some(penalyBigPayDay), .some(deltaBigPayDay)):
                    stakes[id: stake.id]?.bigPayDayHearts = penalyBigPayDay + deltaBigPayDay
                case let (.some(penalyBigPayDay), .none):
                    stakes[id: stake.id]?.bigPayDayHearts = penalyBigPayDay
                case let (.none, .some(deltaBigPayDay)):
                    stakes[id: stake.id]?.bigPayDayHearts = deltaBigPayDay
                case (.none, .none):
                    break
                }
            default:
                let payoutInterest = stake.calculatePayout(globalInfo: onChainData.globalInfo,
                                                           beginDay: startIndex,
                                                           endDay: endIndex,
                                                           dailyData: onChainData.dailyData)
                let penaltyPayout: BigUInt
                switch stake.penaltyDays {
                case stake.servedDays:
                    penaltyPayout = payoutInterest.payout
                default:
                    penaltyPayout = payoutInterest.payout * BigUInt(stake.penaltyDays) / BigUInt(stake.servedDays)
                }

                stakes[id: stake.id]?.penaltyHearts = penaltyPayout

                stakes[id: stake.id]?.interestHearts = payoutInterest.payout

                stakes[id: stake.id]?.bigPayDayHearts = payoutInterest.bigPayDay
            }

            // Seven Day Interest
            if !recentInterestDays.isZero {
                let sevenDayInterest = stake.calculatePayout(globalInfo: onChainData.globalInfo,
                                                             beginDay: weekStartIndex,
                                                             endDay: endIndex,
                                                             dailyData: onChainData.dailyData)
                stakes[id: stake.id]?.interestSevenDayHearts = sevenDayInterest.payout / recentInterestDays
            }
        }

        total.interestHearts = stakes.reduce(0) { $0 + $1.interestHearts }
        total.interestSevenDayHearts = stakes.reduce(0) { $0 + $1.interestSevenDayHearts }
        total.bigPayDayHearts = stakes.compactMap { $0.bigPayDayHearts }.reduce(0) { $0 + $1 }
    }
}
