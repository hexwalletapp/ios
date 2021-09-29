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

        let stakes = stakeList.sorted(by: { $0.lockedDay + $0.stakedDays < $1.lockedDay + $1.stakedDays })
            .map { stake -> Stake in
                totalStakeShares += stake.stakeShares
                totalStakedHearts += stake.stakedHearts

                return Stake(stakeId: stake.stakeId,
                             stakedHearts: stake.stakedHearts,
                             stakeShares: stake.stakeShares,
                             lockedDay: stake.lockedDay,
                             stakedDays: stake.stakedDays,
                             unlockedDay: stake.unlockedDay,
                             isAutoStake: stake.isAutoStake,
                             percentComplete: min(1,(Double(state.currentDay) - Double(stake.lockedDay)) / Double(stake.stakedDays)),
                             daysRemaining: (Int(stake.lockedDay) + Int(stake.stakedDays)) - Int(state.currentDay),
                             interestHearts: 0)
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

        var totalInterestHearts: BigUInt = 0
        var totalInterestSevenDayHearts: BigUInt = 0
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

        state.accountsData[id: accountDataKey]?.stakes.forEach { stake in
            let startIndex = Int(stake.lockedDay)
            let endIndex = Int(state.currentDay)
            let weekStartIndex = max(endIndex - 7, startIndex)

            let interestHearts = dailyData[startIndex ..< endIndex].reduce(0) { $0 + ((stake.stakeShares * $1.payout) / $1.shares) }
            let interestSevenDayHearts = dailyData[weekStartIndex ..< endIndex].reduce(0) { $0 + ((stake.stakeShares * $1.payout) / $1.shares) }

            totalInterestHearts += interestHearts
            totalInterestSevenDayHearts += interestSevenDayHearts
            
            state.accountsData[id: accountDataKey]?.stakes[id: stake.id]?.interestHearts = interestHearts
        }

        state.accountsData[id: accountDataKey]?.total.interestHearts = totalInterestHearts
        state.accountsData[id: accountDataKey]?.total.interestSevenDayHearts = (totalInterestSevenDayHearts / BigUInt(7))

        return .none

    case let .currentDay(day):
        state.currentDay = day
        return .concatenate(
            state.accountsData.compactMap { accountData -> Effect<HEXSmartContractManager.Action, Never>? in
                environment.hexManager.getStakes(id: HexManagerId(),
                                                 address: accountData.account.address,
                                                 chain: accountData.account.chain).fireAndForget()
            }
        )
    }
}
