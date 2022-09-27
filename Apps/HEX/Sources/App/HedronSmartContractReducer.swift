// HedronSmartContractReducer.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import Dispatch
import EVMChain
import HedronSmartContract
import HEXSmartContract

let hedronReducer = Reducer<AppState, HedronSmartContractManager.Action, AppEnvironment> { state, action, environment in
    switch action {
    case let .hedronStakes(chain):
        let accounts = state.accounts.filter { $0.chain == chain }
        let stakes = accounts.compactMap { account -> Effect<HedronSmartContractManager.Action, Never> in
            environment.hedronManager.getStakes(id: HedronManagerId(),
                                                address: account.address.value,
                                                chain: chain).fireAndForget()
        }
        return .merge(stakes)

    case let .stake(stake, address, chain, stakeCount):
        let accountKey = Account.genId(address: address, chain: chain)
        
        guard let onChainData = state.hexERC20.data[chain],
              let account = state.accounts[id: accountKey] else { return .none }

        var hedronStake = Stake(stake: stake.response, onChainData: onChainData)
        state.accounts[id: accountKey]?.stakes.append(hedronStake)

        switch state.accounts[id: accountKey]?.stakes.filter({ $0.type == .hedron }).count {
        case Int(stakeCount):
            // Cleanup dirty stakes
            state.accounts[id: account.id]?.stakes.removeAll { $0.isDirty }


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
    }
}
