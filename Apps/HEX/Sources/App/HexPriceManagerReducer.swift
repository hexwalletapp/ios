// HexPriceManagerReducer.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import EVMChain
import Foundation

let hexPriceReducer = Reducer<AppState, HexPriceManager.Action, AppEnvironment> { state, action, environment in
    switch action {
    case let .hexPrice(price, chain):
        guard let price = price else { return .none }
        switch chain {
        case .ethereum:
            let dexPrice = try? environment.decoder.decode(CommunityDexPrice.self,
                                                           from: price)
            guard let hexUsd = dexPrice?.hexUsd,
                  let doubleHexUsd = Double(hexUsd) else { return .none }
            state.hexContractOnChain.ethData.hexUsd = doubleHexUsd

            state.accountsData.filter { $0.account.chain == .ethereum }.forEach { accountData in
                state.accountsData[id: accountData.id]?.hexPrice = doubleHexUsd
            }

        case .pulse:
            let dexPrice = try? environment.decoder.decode(PulseDexPrice.self,
                                                           from: price)
            guard let hexUsd = dexPrice?.data.pair.token1Price,
                  let doubleHexUsd = Double(hexUsd) else { return .none }
            state.hexContractOnChain.plsData.hexUsd = doubleHexUsd

            state.accountsData.filter { $0.account.chain == .pulse }.forEach { accountData in
                state.accountsData[id: accountData.id]?.hexPrice = doubleHexUsd
            }
        }
        return .none
    }
}
