// UniswapSmartContractReducer.swift
// Copyright (c) 2021 Joe Blau

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
            state.groupAccountData.ethPrice = 1.0 / ratio
        case .pulse:
            state.hexContractOnChain.plsData.hexUsd = 1.0 / ratio
            state.groupAccountData.plsPrice = 1.0 / ratio
        }
        return .none
    }
}
