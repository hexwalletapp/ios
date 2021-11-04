// HEXSmartContractReducer.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import ComposableArchitecture
import Dispatch
import HEXSmartContract

let hexReducer = Reducer<AppState, HEXSmartContractManager.Action, AppEnvironment> { state, action, environment in
    switch action {
    case let .stakeList(stakeList, address, chain):
        let accountDataKey = address.value + chain.description
        var totalStakeShares: BigUInt = 0
        var totalStakedHearts: BigUInt = 0
        let currentDay = state.currentDay

        let stakes = stakeList.sorted(by: {
            let firstStake = [BigUInt($0.lockedDay + $0.stakedDays), $0.stakeId]
            let secondStake = [BigUInt($1.lockedDay + $1.stakedDays), $1.stakeId]
            return firstStake.lexicographicallyPrecedes(secondStake)
        })
            .map { stake -> Stake in
                let stakeUnlockDay = BigUInt(stake.unlockedDay)
                let stakeLockedDay = BigUInt(stake.lockedDay)

                let servedDays: UInt16
                switch stake.lockedDay {
                case let x where x <= state.currentDay:
                    servedDays = min(UInt16(stake.stakedDays), UInt16(state.currentDay) - UInt16(stake.lockedDay))
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
                    totalStakeShares += stake.stakeShares
                    totalStakedHearts += stake.stakedHearts
                }

                var penaltyDays = (stake.stakedDays + 1) / 2
                if penaltyDays < k.EARLY_PENALTY_MIN_DAYS {
                    penaltyDays = UInt16(k.EARLY_PENALTY_MIN_DAYS)
                }

                let percentComplete = max(0, min(1, (Double(currentDay) - Double(stake.lockedDay)) / Double(stake.stakedDays)))
                return Stake(stakeId: stake.stakeId,
                             stakedHearts: stake.stakedHearts,
                             stakeShares: stake.stakeShares,
                             lockedDay: stake.lockedDay,
                             stakedDays: stake.stakedDays,
                             stakeEndDay: UInt16(stakeEndDay),
                             penaltyDays: penaltyDays,
                             unlockedDay: stake.unlockedDay,
                             isAutoStake: stake.isAutoStake,
                             percentComplete: percentComplete,
                             servedDays: servedDays,
                             status: status,
                             startDate: k.HEX_START_DATE.addingTimeInterval(TimeInterval(Int(stakeLockedDay) * 86400)),
                             endDate: k.HEX_START_DATE.addingTimeInterval(TimeInterval(Int(stakeEndDay) * 86400)),
                             penaltyHearts: 0,
                             interestHearts: 0,
                             interestSevenDayHearts: 0,
                             bigPayDayHearts: nil)
            }
        state.accountsData[id: accountDataKey]?.stakes = IdentifiedArray(uniqueElements: stakes)
        state.accountsData[id: accountDataKey]?.total.stakeShares = totalStakeShares
        state.accountsData[id: accountDataKey]?.total.stakedHearts = totalStakedHearts

        return environment.hexManager
            .getDailyDataRange(id: HexManagerId(),
                               address: address,
                               chain: chain,
                               begin: 0,
                               end: UInt16(state.currentDay))
            .fireAndForget()

    case let .dailyData(dailyDataEncoded, address, chain):
        let accountDataKey = address.value + chain.description
        var currentDay = state.currentDay

        let dailyData = dailyDataEncoded.map { dailyData -> DailyData in
            var dailyData = dailyData
            let payout = dailyData & k.HEARTS_MASK
            dailyData >>= k.HEARTS_UINT_SHIFT
            let shares = dailyData & k.HEARTS_MASK
            dailyData >>= k.HEARTS_UINT_SHIFT
            let sats = dailyData & k.SATS_MASK

            return DailyData(payout: payout, shares: shares, sats: sats)
        }
                
        let recentDailyData = dailyData.suffix(7)
        
        state.averageShareRate = recentDailyData.map { Double($0.payout) / Double($0.shares) * Double(k.HEARTS_PER_SATOSHI) }
            .reduce(0.0, +) / Double(recentDailyData.count)

        state.accountsData[id: accountDataKey]?
            .stakes
            .forEach { stake in
                guard stake.lockedDay <= state.currentDay else { return }

                let startIndex = Int(stake.lockedDay)
                let endIndex = min(Int(stake.stakeEndDay), Int(state.currentDay))
                let weekStartIndex = max(endIndex - 7, startIndex)
                let penaltyEndIndex = Int(stake.lockedDay + stake.penaltyDays)
                let recentInterestDays = BigUInt(endIndex - weekStartIndex)

                switch stake.servedDays {
                case 0:
                    state.accountsData[id: accountDataKey]?
                        .stakes[id: stake.id]?
                        .interestHearts = 0
                case let x where x > stake.penaltyDays:
                    let penaltyInterest = stake.calculatePayout(globalInfo: state.globalInfo,
                                                                beginDay: startIndex,
                                                                endDay: penaltyEndIndex,
                                                                dailyData: dailyData)

                    let deltaInterest = stake.calculatePayout(globalInfo: state.globalInfo,
                                                              beginDay: penaltyEndIndex,
                                                              endDay: endIndex,
                                                              dailyData: dailyData)
                    // Peanlty
                    state.accountsData[id: accountDataKey]?
                        .stakes[id: stake.id]?
                        .penaltyHearts = penaltyInterest.payout + deltaInterest.payout

                    // Interest
                    state.accountsData[id: accountDataKey]?
                        .stakes[id: stake.id]?
                        .interestHearts = penaltyInterest.payout + deltaInterest.payout

                    // Big Pay Day
                    switch (penaltyInterest.bigPayDay, deltaInterest.bigPayDay) {
                    case let (.some(penalyBigPayDay), .some(deltaBigPayDay)):
                        state.accountsData[id: accountDataKey]?
                            .stakes[id: stake.id]?
                            .bigPayDayHearts = penalyBigPayDay + deltaBigPayDay
                    case let (.some(penalyBigPayDay), .none):
                        state.accountsData[id: accountDataKey]?
                            .stakes[id: stake.id]?
                            .bigPayDayHearts = penalyBigPayDay
                    case let (.none, .some(deltaBigPayDay)):
                        state.accountsData[id: accountDataKey]?
                            .stakes[id: stake.id]?
                            .bigPayDayHearts = deltaBigPayDay
                    case (.none, .none):
                        break
                    }
                default:
                    let payoutInterest = stake.calculatePayout(globalInfo: state.globalInfo,
                                                               beginDay: startIndex,
                                                               endDay: endIndex,
                                                               dailyData: dailyData)
                    let penaltyPayout: BigUInt
                    switch stake.penaltyDays {
                    case stake.servedDays:
                        penaltyPayout = payoutInterest.payout
                    default:
                        penaltyPayout = payoutInterest.payout * BigUInt(stake.penaltyDays) / BigUInt(stake.servedDays)
                    }

                    state.accountsData[id: accountDataKey]?
                        .stakes[id: stake.id]?
                        .penaltyHearts = penaltyPayout

                    state.accountsData[id: accountDataKey]?
                        .stakes[id: stake.id]?
                        .interestHearts = payoutInterest.payout

                    state.accountsData[id: accountDataKey]?
                        .stakes[id: stake.id]?
                        .bigPayDayHearts = payoutInterest.bigPayDay
                }

                // Seven Day Interest
                if !recentInterestDays.isZero {
                    let sevenDayInterest = stake.calculatePayout(globalInfo: state.globalInfo,
                                                                 beginDay: weekStartIndex,
                                                                 endDay: endIndex,
                                                                 dailyData: dailyData)
                    state.accountsData[id: accountDataKey]?
                        .stakes[id: stake.id]?
                        .interestSevenDayHearts = sevenDayInterest.payout / recentInterestDays
                }
            }

        let stakes = state.accountsData[id: accountDataKey]?.stakes

        let totalInterestHearts = stakes?.reduce(0) { $0 + $1.interestHearts } ?? 0
        var totalInterestSevenDayHearts = stakes?.reduce(0) { $0 + $1.interestSevenDayHearts } ?? 0
        let bigPayDayTotalHearts = stakes?.compactMap { $0.bigPayDayHearts }.reduce(0) { $0 + $1 }

        state.accountsData[id: accountDataKey]?.total.interestHearts = totalInterestHearts
        state.accountsData[id: accountDataKey]?.total.interestSevenDayHearts = totalInterestSevenDayHearts
        bigPayDayTotalHearts.map { state.accountsData[id: accountDataKey]?.total.bigPayDayHearts = $0 }

        return .none

    case let .currentDay(day):
        state.currentDay = day
        return .merge(
            state.accountsData.compactMap { accountData -> Effect<HEXSmartContractManager.Action, Never>? in
                .merge(
                    environment.hexManager.getStakes(id: HexManagerId(),
                                                     address: accountData.account.address,
                                                     chain: accountData.account.chain).fireAndForget(),
                    environment.hexManager.getBalance(id: HexManagerId(),
                                                      address: accountData.account.address,
                                                      chain: accountData.account.chain).fireAndForget()
                )
            }
        )

    case let .globalInfo(globalInfo):
        state.globalInfo = GlobalInfo(globalInfo: globalInfo)
        return .none

    case let .balance(balance, address, chain):
        let accountDataKey = address.value + chain.description
        state.accountsData[id: accountDataKey]?.balanceHearts = balance
        return .none
    }
}
