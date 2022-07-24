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
        let accounts = state.accountsData.filter { $0.account.chain == chain }
        let stakes = accounts.compactMap { accountData -> Effect<HedronSmartContractManager.Action, Never> in
            environment.hedronManager.getStakes(id: HedronManagerId(),
                                                address: accountData.account.address.value,
                                                chain: chain).fireAndForget()
        }
        return .merge(stakes)

    case let .stake(stake, address, chain, stakeCount):
        let accountDataKey = address.value + chain.description

        let onChainData: OnChainData
        switch chain {
        case .ethereum: onChainData = state.hexContractOnChain.ethData
        case .pulse: onChainData = state.hexContractOnChain.plsData
        }

        guard let accountData = state.accountsData[id: accountDataKey] else { return .none }

        var hedronStake = Stake(stake: stake.response, onChainData: onChainData)
        state.accountsData[id: accountDataKey]?.stakes.append(hedronStake)

        switch state.accountsData[id: accountDataKey]?.stakes.filter({ $0.type == .hedron }).count {
        case Int(stakeCount):
            // Cleanup dirty stakes
            state.accountsData[id: accountData.id]?.stakes.filter { $0.isDirty }.forEach { stake in
                state.accountsData[id: accountData.id]?.stakes.remove(stake)
            }

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

    case let .noStakes(address, chain):
        let accountDataKey = address.value + chain.description
        state.accountsData[id: accountDataKey]?.isLoading = false
        return .none
    }
}
