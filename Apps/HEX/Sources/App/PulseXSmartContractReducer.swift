// PulseXSmartContractReducer.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation
import PulseXSmartContract
import web3

let pulseXReducer = Reducer<AppState, PulseXSmartContractManager.Action, AppEnvironment> { _, action, environment in

    switch action {
    case let .token(pairAddress, tokenAddress, tokenPosition):
        return .none

    case let .pairAddress(pairAddress):
        return environment.pulseXManager
            .reserves(id: PulseXManagerId(),
                      pairAddress: pairAddress)
            .fireAndForget()

    case let .reserves(reserve0, reserve1, timestamp, pairAddress):
        return .none
    }
}
