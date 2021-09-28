// HEXSmartContractReducer.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import HEXSmartContract

let hexReducer = Reducer<AppState, HEXSmartContractManager.Action, AppEnvironment> { _, action, _ in
    switch action {
    case let .stakeList(stakeList):
        print(stakeList.count)
        return .none
    }
}
