// UniswapSmartContractReducer.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import Foundation
import UniswapSmartContract

let uniswapReducer = Reducer<AppState, UniswapSmartContractManager.Action, AppEnvironment> { state, action, environment in

    switch action {
    case let .pairAddress(chain, address):
        return environment.uniswapManager.getReserves(id: UniswapManagerId(), chain: chain, pairAddress: address).fireAndForget()

    case let .reserves(chain, reserve0, reserve1, timestamp):
        let ratio = Double(reserve0 / reserve1) / Double(100)
        switch chain {
        case .ethereum:
            state.hexContractOnChain.ethData.hexUsd = 1.0 / ratio
            state.calculator.price = 1.0 / ratio
            
            state.accountsData.filter { $0.account.chain == .ethereum }.forEach { accountData in
                state.accountsData[id: accountData.id]?.hexPrice = 1.0 / ratio
            }
        case .pulse:
            state.hexContractOnChain.plsData.hexUsd = 1.0 / ratio
            
            state.accountsData.filter { $0.account.chain == .pulse }.forEach { accountData in
                state.accountsData[id: accountData.id]?.hexPrice = 1.0 / ratio
            }
        }
        return .none
    }
}
