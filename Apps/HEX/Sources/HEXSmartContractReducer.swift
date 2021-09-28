// HEXSmartContractReducer.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import Dispatch
import HEXSmartContract

let hexReducer = Reducer<AppState, HEXSmartContractManager.Action, AppEnvironment> { state, action, environment in
    switch action {
    case let .stakeList(stakeList, address):
        var beginDay = UInt16.max
        var endDay = UInt16(state.currentDay)
        
        let stakes = stakeList.sorted(by: { $0.lockedDay + $0.stakedDays < $1.lockedDay + $1.stakedDays })
            .map { stake -> Stake in

                beginDay = min(beginDay, stake.lockedDay)
                
                return Stake(stakeId: stake.stakeId,
                      stakedHearts: stake.stakedHearts,
                      stakeShares: stake.stakeShares,
                      lockedDay: stake.lockedDay,
                      stakedDays: stake.stakedDays,
                      unlockedDay: stake.unlockedDay,
                      isAutoStake: stake.isAutoStake,
                      percentComplete: (Double(state.currentDay) - Double(stake.lockedDay)) / Double(stake.stakedDays),
                      interestHearts: 0,
                      interestSevenDayHearts: 0)
            }
        state.accounts[id: address.value]?.stakes = stakes
        print(address)
        return environment.hexManager
            .getDailyDataRange(id: HexManagerId(),
                                                        address: address,
                                                        begin: beginDay,
                                                        end: endDay)
            .fireAndForget()

    case let .dailyData(dailyData, address):
        state.accounts[id: address.value]?.dailyData = dailyData.map { dailyData -> DailyData in
            var dailyData = dailyData
            let payout = dailyData & k.HEARTS_MASK
            dailyData >>= k.HEARTS_UINT_SHIFT
            let shares = dailyData & k.HEARTS_MASK
            dailyData >>= k.HEARTS_UINT_SHIFT
            let sats = dailyData & k.SATS_MASK

            return DailyData(payout: payout, shares: shares, sats: sats)
        }

        return .none
        
    case let .currentDay(day):
        state.currentDay = day
        return .concatenate(
            state.accounts.compactMap { account -> Effect<HEXSmartContractManager.Action, Never>?  in
                return environment.hexManager.getStakes(id: HexManagerId(), address: account.address).fireAndForget()
            }
        )
    }
}
