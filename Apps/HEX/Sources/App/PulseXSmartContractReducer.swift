// PulseXSmartContractReducer.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation
import PulseXSmartContract
import web3

let pulseXReducer = Reducer<AppState, PulseXSmartContractManager.Action, AppEnvironment> { state, action, environment in

    switch action {
    case let .token(pairAddress, tokenAddress, tokenPosition):
        return .none

    case let .pairAddress(pairAddress):
        return environment.pulseXManager
            .reserves(id: PulseXManagerId(),
                      pairAddress: pairAddress)
            .fireAndForget()

    case let .reserves(reserve0, reserve1, timestamp, pairAddress):
        let ratio = (reserve0.number.doubleValue / reserve1.number.doubleValue) / 100.0
        state.hexContractOnChain.plsData.hexUsd = 1.0 / ratio
        state.accountsData.filter { $0.account.chain == .pulse }.forEach { accountData in
            state.accountsData[id: accountData.id]?.hexPrice = 1.0 / ratio
        }
        return .none
    }
}
