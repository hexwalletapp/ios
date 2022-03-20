// HEXSmartContractReducer.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import Dispatch
import EVMChain
import HedronSmartContract
import HEXSmartContract

let hexReducer = Reducer<AppState, HEXSmartContractManager.Action, AppEnvironment> { state, action, environment in
    switch action {
    case let .stake(stake, address, chain, stakeCount):
        let accountDataKey = address.value + chain.description

        let onChainData: OnChainData
        switch chain {
        case .ethereum: onChainData = state.hexContractOnChain.ethData
        case .pulse: onChainData = state.hexContractOnChain.plsData
        }

        guard let accountData = state.accountsData[id: accountDataKey] else { return .none }

        let stake = Stake(stake: stake.response, onChainData: onChainData)
        state.accountsData[id: accountDataKey]?.stakes.append(stake)

        switch accountData.stakes.count {
        case Int(stakeCount):
            let total = accountData.stakes
                .reduce(into: StakeTotal()) { partialResult, stake in
                    partialResult.stakeShares += stake.stakeShares
                    partialResult.stakedHearts += stake.stakedHearts
                    partialResult.interestHearts += stake.interestHearts
                    partialResult.interestDailyHearts += stake.interestDailyHearts
                    partialResult.interestWeeklyHearts += stake.interestWeeklyHearts
                    partialResult.interestMonthlyHearts += stake.interestMonthlyHearts
                    partialResult.bigPayDayHearts += stake.bigPayDayHearts ?? 0
                }
            state.accountsData[id: accountDataKey]?.total = total
            state.accountsData[id: accountDataKey]?.stakes.sort(by: {
                let firstStake = [BigUInt($0.lockedDay + $0.stakedDays), $0.stakeId]
                let secondStake = [BigUInt($1.lockedDay + $1.stakedDays), $1.stakeId]
                return firstStake.lexicographicallyPrecedes(secondStake)
            })
            state.accountsData[id: accountDataKey]?.isLoading = false

            if accountData.account.isFavorite {
                state.groupAccountData.accountsData.updateOrAppend(accountData)
            }
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

        let accounts = state.accountsData.filter { $0.account.chain == chain }
        let stakes = accounts.compactMap { accountData -> Effect<HEXSmartContractManager.Action, Never> in
            environment.hexManager.getStakes(id: HexManagerId(),
                                             address: accountData.account.address.value,
                                             chain: chain).fireAndForget()
        }

        let balances = accounts.compactMap { accountData -> Effect<HEXSmartContractManager.Action, Never> in
            environment.hexManager.getBalance(id: HexManagerId(),
                                              address: accountData.account.address.value,
                                              chain: chain).fireAndForget()
        }

        state.accountsData.forEach { accountData in
            state.accountsData[id: accountData.id]?.isLoading = true
        }

        return .merge(
            .merge(stakes),
            .merge(balances),
            .fireAndForget {
                Chain.allCases.forEach { chain in
                    environment.hedronManager.getHedronStakes(id: HedronManagerId(), chain: chain)
                }
            }
        )

    case let .currentDay(day, chain):
        switch chain {
        case .ethereum:
            state.hexContractOnChain.ethData.currentDay = day
        case .pulse:
            state.hexContractOnChain.plsData.currentDay = day
        }
        return environment.hexManager.getDailyDataRange(id: HexManagerId(),
                                                        chain: chain,
                                                        begin: 0,
                                                        end: UInt16(day))
            .fireAndForget()

    case let .globalInfo(globalInfo, chain):
        switch chain {
        case .ethereum:
            state.hexContractOnChain.ethData.globalInfo = GlobalInfo(globalInfo: globalInfo)
        case .pulse:
            state.hexContractOnChain.plsData.globalInfo = GlobalInfo(globalInfo: globalInfo)
        }

        return environment.hexManager.getCurrentDay(id: HexManagerId(), chain: chain).fireAndForget()

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
