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

    case let .stakeList(stakeList, address, chain):
        let accountDataKey = address.value + chain.description

        let onChainData: OnChainData
        switch chain {
        case .ethereum: onChainData = state.hexContractOnChain.ethData
        case .pulse: onChainData = state.hexContractOnChain.plsData
        }

        let stakes = stakeList.map { Stake(stake: $0.response, onChainData: onChainData) }

        let combinedStakes: Set<Stake>
        switch state.accountsData[id: accountDataKey]?.stakes {
        case let .some(existingStakes): combinedStakes = Set(existingStakes).union(stakes)
        case .none: combinedStakes = Set(stakes)
        }
        let totalStakes = combinedStakes.sorted(by: {
            let firstStake = [BigUInt($0.lockedDay + $0.stakedDays), $0.stakeId]
            let secondStake = [BigUInt($1.lockedDay + $1.stakedDays), $1.stakeId]
            return firstStake.lexicographicallyPrecedes(secondStake)
        })
        state.accountsData[id: accountDataKey]?.stakes = IdentifiedArray(uniqueElements: totalStakes)

        let total = totalStakes.reduce(into: StakeTotal()) { partialResult, stake in
            partialResult.stakeShares += stake.stakeShares
            partialResult.stakedHearts += stake.stakedHearts
            partialResult.interestHearts += stake.interestHearts
            partialResult.interestDailyHearts += stake.interestDailyHearts
            partialResult.interestWeeklyHearts += stake.interestWeeklyHearts
            partialResult.interestMonthlyHearts += stake.interestMonthlyHearts
            partialResult.bigPayDayHearts += stake.bigPayDayHearts ?? 0
        }

        state.accountsData[id: accountDataKey]?.total = total

        state.accountsData[id: accountDataKey]?.isLoading = false

        switch state.accountsData[id: accountDataKey] {
        case let .some(accountData) where accountData.account.isFavorite == true:
            state.groupAccountData.accountsData.updateOrAppend(accountData)
            return .none
        default:
            return .none
        }
    }
}
