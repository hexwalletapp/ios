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
        let accountKey = Account.genId(address: address, chain: chain)

        guard let onChainData: OnChainData = state.hexContractOnChain.data[chain],
              let account: Account = state.accounts[id: accountKey] else { return .none }

        let nativeStake = Stake(stake: stake.response, onChainData: onChainData)
        state.accounts[id: accountKey]?.stakes.append(nativeStake)

        switch state.accounts[id: accountKey]?.stakes.filter({ $0.type == .native }).count {
        case Int(stakeCount):
            // Cleanup dirty stakes
            // TODO: Fix cleanup dirty stakes
//            state.accounts[id: account.id]?.stakes.filter { $0.isDirty }.forEach { stake in
//                state.accounts[id: account.id]?.stakes.remove(at: stake)
//            }

            let summary = account.stakes
                .reduce(into: Summary()) { partialResult, stake in
                    partialResult.stakeShares += stake.stakeShares
                    partialResult.stakedHearts += stake.stakedHearts
                    partialResult.interestHearts += stake.interestHearts
                    PayPeriod.allCases.forEach { payPeriod in
                        partialResult.interestPayPeriodHearts[payPeriod]? += stake.interestPayPeriodHearts[payPeriod] ?? 0
                    }
                    partialResult.bigPayDayHearts += stake.bigPayDayHearts ?? 0
                }
            state.accounts[id: accountKey]?.summary = summary
            state.accounts[id: accountKey]?.stakes.sort(by: {
                let firstStake = [BigUInt($0.lockedDay + $0.stakedDays), $0.stakeId]
                let secondStake = [BigUInt($1.lockedDay + $1.stakedDays), $1.stakeId]
                return firstStake.lexicographicallyPrecedes(secondStake)
            })
            state.accounts[id: accountKey]?.isLoading = false

            if account.isFavorite {
                state.favoriteAccounts.accounts.updateOrAppend(account)
            }
            return .none
        default:
            return .none
        }

    case let .noStakes(address, chain):
        let accountKey = Account.genId(address: address, chain: chain)
        state.accounts[id: accountKey]?.isLoading = false
        return .none

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

        state.hexContractOnChain.data[chain]?.dailyData = dailyData

        let accounts = state.accounts.filter { $0.chain == chain }
        let stakes = accounts.compactMap { account -> Effect<HEXSmartContractManager.Action, Never> in
            environment.hexManager.getStakes(id: HexManagerId(),
                                             address: account.address.value,
                                             chain: chain).fireAndForget()
        }

        let balances = accounts.compactMap { account -> Effect<HEXSmartContractManager.Action, Never> in
            environment.hexManager.getBalance(id: HexManagerId(),
                                              address: account.address.value,
                                              chain: chain).fireAndForget()
        }

        state.accounts.filter { $0.chain == chain }.forEach { account in
            state.accounts[id: account.id]?.stakes.forEach { stake in
                state.accounts[id: account.id]?.stakes[Int(stake.id)].isDirty = true
            }
        }

        state.accounts.forEach { account in
            state.accounts[id: account.id]?.isLoading = true
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
        state.hexContractOnChain.data[chain]?.currentDay = day
        return environment.hexManager.getDailyDataRange(id: HexManagerId(),
                                                        chain: chain,
                                                        begin: 0,
                                                        end: UInt16(day))
            .fireAndForget()

    case let .globalInfo(globalInfo, chain):
        state.hexContractOnChain.data[chain]?.globalInfo = GlobalInfo(globalInfo: globalInfo)
        return environment.hexManager.getCurrentDay(id: HexManagerId(), chain: chain).fireAndForget()

    case let .balance(balance, address, chain):
        let accountKey = Account.genId(address: address, chain: chain)
        state.accounts[id: accountKey]?.summary.liquidHearts = balance

        switch state.accounts[id: accountKey] {
        case let .some(account) where account.isFavorite == true:
            state.favoriteAccounts.accounts.updateOrAppend(account)
            return .none
        default:
            return .none
        }
    }
}
