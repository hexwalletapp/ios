// HEXSmartContractReducer.swift
// Copyright (c) 2022 Joe Blau

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
        let onChainData = state.hexContractOnChain.data(from: chain)
        let currentDay = onChainData.currentDay

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
        state.accountsData[id: accountDataKey]?.globalAccountData(onChainData: onChainData)

        switch state.accountsData[id: accountDataKey] {
        case let .some(accountData) where accountData.account.isFavorite == true:
            state.groupAccountData.accountsData.updateOrAppend(accountData)
            return .none
        default:
            return .none
        }

    case let .dailyData(dailyDataEncoded, chain):
        let dailyData = dailyDataEncoded.map { dailyData -> DailyData in
            var dailyData = dailyData
            let payout = dailyData & k.HEARTS_MASK
            dailyData >>= k.HEARTS_UINT_SHIFT
            let shares = dailyData & k.HEARTS_MASK
            dailyData >>= k.HEARTS_UINT_SHIFT
            let sats = dailyData & k.SATS_MASK

            return DailyData(payout: payout, shares: shares, sats: sats)
        }

        switch chain {
        case .ethereum: state.hexContractOnChain.ethData.dailyData = dailyData
        case .pulse: state.hexContractOnChain.plsData.dailyData = dailyData
        }
        return .none

    case let .currentDay(day, chain):
        let accounts = state.accountsData.filter { $0.account.chain == chain }
        let stakes = accounts.compactMap { accountData -> Effect<HEXSmartContractManager.Action, Never> in
            environment.hexManager.getStakes(id: HexManagerId(),
                                             address: accountData.account.address,
                                             chain: chain).fireAndForget()
        }
        let balances = accounts.compactMap { accountData -> Effect<HEXSmartContractManager.Action, Never> in
            environment.hexManager.getBalance(id: HexManagerId(),
                                              address: accountData.account.address,
                                              chain: chain).fireAndForget()
        }
        switch chain {
        case .ethereum: state.hexContractOnChain.ethData.currentDay = day
        case .pulse: state.hexContractOnChain.plsData.currentDay = day
        }
        return .merge(
            environment.hexManager.getDailyDataRange(id: HexManagerId(),
                                                     chain: chain,
                                                     begin: 0,
                                                     end: UInt16(state.hexContractOnChain.data(from: chain).globalInfo.dailyDataCount))
                .fireAndForget(),
            .merge(stakes),
            .merge(balances)
        )

    case let .globalInfo(globalInfo, chain):
        switch chain {
        case .ethereum:
            state.hexContractOnChain.ethData.globalInfo = GlobalInfo(globalInfo: globalInfo)
        case .pulse:
            state.hexContractOnChain.plsData.globalInfo = GlobalInfo(globalInfo: globalInfo)
        }
        return .none

    case let .balance(balance, address, chain):
        let accountDataKey = address.value + chain.description
        state.accountsData[id: accountDataKey]?.liquidBalanceHearts = balance

        switch state.accountsData[id: accountDataKey] {
        case let .some(accountData) where accountData.account.isFavorite == true:
            state.groupAccountData.accountsData.updateOrAppend(accountData)
            return .none
        default:
            return .none
        }
    }
}
