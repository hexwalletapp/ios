// AppViewReducer.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation
import HEXREST
import HEXSmartContract
import IdentifiedCollections
import SwiftUI

enum Tab {
    case charts, accounts
}

struct AppState: Equatable {
    @BindableState var editMode: EditMode = .inactive
    @BindableState var presentEditAddress = false
    @BindableState var selectedTab: Tab = .accounts

    @BindableState var selectedId = ""
    @BindableState var accountsData = IdentifiedArrayOf<AccountData>()
    var currentDay: BigUInt = 0
    var hexPrice = HEXPrice()
    var globalInfo = GlobalInfo()
}

enum AppAction: BindableAction, Equatable {
    case hexManager(HEXSmartContractManager.Action)

    case applicationDidFinishLaunching
    case onBackground
    case onInactive
    case onActive

    case updateAccounts
    case updateHexPrice(Result<HEXPrice, NSError>)
    case binding(BindingAction<AppState>)
}

struct AppEnvironment {
    var hexManager: HEXSmartContractManager
    var mainQueue: AnySchedulerOf<DispatchQueue>
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .applicationDidFinishLaunching:
        switch UserDefaults.standard.data(forKey: k.ACCOUNTS_KEY) {
        case let .some(encodedAccounts):
            do {
                let decodedAccounts = try environment.decoder.decode([Account].self,
                                                                     from: encodedAccounts)
                state.accountsData = IdentifiedArray(uniqueElements: decodedAccounts.map { AccountData(account: $0) })
                state.selectedId = decodedAccounts.first?.id ?? ""
            } catch {
                UserDefaults.standard.removeObject(forKey: k.ACCOUNTS_KEY)
                print(error)
            }
        case .none:
            break
        }
        return environment.hexManager.create(id: HexManagerId()).map(AppAction.hexManager)

    case .onActive:
        return Effect(value: .updateAccounts)

    case .updateAccounts:
        return .merge(
            HEXRESTAPI.fetchHexPrice()
                .receive(on: environment.mainQueue)
                .mapError { $0 as NSError }
                .catchToEffect()
                .map(AppAction.updateHexPrice)
                .throttle(id: GetPriceThrottleId(), for: .seconds(5), scheduler: environment.mainQueue, latest: true),
            environment.hexManager.getGlobalInfo(id: HexManagerId()).fireAndForget()
                .throttle(id: GlobalInfoThrottleId(), for: .seconds(5), scheduler: environment.mainQueue, latest: true),
            environment.hexManager.getCurrentDay(id: HexManagerId()).fireAndForget()
                .throttle(id: GetDayThrottleId(), for: .seconds(5), scheduler: environment.mainQueue, latest: true)
        )

    case let .updateHexPrice(result):
        switch result {
        case let .success(hexPrice): state.hexPrice = hexPrice
        case let .failure(error): print(error)
        }
        return .none

    case .binding(\.$selectedTab):
        switch state.selectedTab {
        case .charts: return .none
        case .accounts: return Effect(value: .updateAccounts)
        }

    case .binding(\.$presentEditAddress):
        switch state.presentEditAddress {
        case false: return Effect(value: .updateAccounts)
        case true: return .none
        }

    case .binding(\.$accountsData):
        do {
            let accounts = state.accountsData.map { $0.account }
            if let lastAccount = accounts.last, state.selectedId.isEmpty {
                state.selectedId = lastAccount.address + lastAccount.chain.description
            }
            let encodedAccounts = try environment.encoder.encode(accounts)
            UserDefaults.standard.setValue(encodedAccounts, forKey: k.ACCOUNTS_KEY)
        } catch {
            UserDefaults.standard.removeObject(forKey: k.ACCOUNTS_KEY)
        }
        return .none

    case .binding, .hexManager, .onBackground, .onInactive:
        return .none
    }
}
.binding()
.combined(with: hexReducer.pullback(state: \.self,
                                    action: /AppAction.hexManager,
                                    environment: { $0 }))
