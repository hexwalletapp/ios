// AppViewReducer.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import BitqueryAPI
import ComposableArchitecture
import Foundation
import HEXREST
import HEXSmartContract
import IdentifiedCollections
import LightweightCharts
import SwiftUI

enum Tab {
    case charts, accounts, plan
}

enum ModalPresent: Identifiable {
    var id: Self { self }

    case edit, speculate, calculator
}

struct AppState: Equatable {
    @BindableState var editMode: EditMode = .inactive
    @BindableState var modalPresent: ModalPresent? = nil
    @BindableState var selectedTab: Tab = .plan
    @BindableState var selectedTimeScale: TimeScale = .day(.one)
    @BindableState var selectedChartType: ChartType = .candlestick

    @BindableState var selectedId = ""
    @BindableState var accountsData = IdentifiedArrayOf<AccountData>()
    @BindableState var shouldSpeculate = false
    @BindableState var speculativePrice: NSNumber = 1.00
    @BindableState var calculator = Calculator()

    var hexPrice = HEXPrice()
    var price: NSNumber = 0.0
    var currentDay: BigUInt = 0
    var globalInfo = GlobalInfo()
    var ohlcv = [OHLCVData]()
    var chartLoading = false
}

enum AppAction: BindableAction, Equatable {
    case hexManager(HEXSmartContractManager.Action)

    case applicationDidFinishLaunching
    case onBackground
    case onInactive
    case onActive

    case dismiss
    case getAccounts
    case getPrice
    case getChart
    case updateHexPrice(Result<HEXPrice, NSError>)
    case updateChart(Result<[OHLCVData], NSError>)
    case binding(BindingAction<AppState>)
}

struct AppEnvironment {
    var hexManager: HEXSmartContractManager
    var mainQueue: AnySchedulerOf<DispatchQueue>
    let bitquery = BitqueryAPI()
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
        return .merge(
            Effect(value: .getChart),
            Effect(value: .getAccounts)
        )

    case .getAccounts:
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

    case .getPrice:
        switch state.shouldSpeculate {
        case true:
            state.price = state.speculativePrice
        case false:
            state.price = NSNumber(value: state.hexPrice.hexUsd)
        }
        return .none

    case let .updateHexPrice(result):
        switch result {
        case let .success(hexPrice):
            state.hexPrice = hexPrice
            state.calculator.price = hexPrice.hexUsd
        case let .failure(error):
            print(error)
        }
        return Effect(value: .getPrice)

    case let .updateChart(result):
        state.chartLoading = false
        switch result {
        case let .success(chartData):
            state.ohlcv = chartData
        case let .failure(error): print(error)
        }
        return .none

    case .getChart:
        state.chartLoading = true
        let histTo = state.selectedTimeScale.toHistTo
        return .merge(
            Effect.cancel(id: GetChartId()),
            environment.bitquery
                .fetchHistory(histTo: histTo)
                .receive(on: environment.mainQueue)
                .mapError { $0 as NSError }
                .catchToEffect()
                .map(AppAction.updateChart)
                .throttle(id: GetChartThrottleId(), for: .seconds(5), scheduler: environment.mainQueue, latest: true)
                .cancellable(id: GetChartId())
        )

    case .dismiss:
        state.modalPresent = nil
        return .none

    case .binding(\.$selectedTimeScale),
         .binding(\.$selectedChartType):
        return Effect(value: .getChart)

    case .binding(\.$shouldSpeculate):
        return Effect(value: .getPrice)

    case .binding(\.$selectedTab):
        switch state.selectedTab {
        case .charts: return Effect(value: .getChart)
        case .accounts: return Effect(value: .getAccounts)
        case .plan: return .none
        }

    case .binding(\.$modalPresent):
        switch state.modalPresent {
        case .some: return .none
        case .none: return Effect(value: .getAccounts)
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

    case .binding(\.$calculator.stakeAmount),
         .binding(\.$calculator.stakeDays),
         .binding(\.$calculator.price),
         .binding(\.$calculator.ladderSteps),
         .binding(\.$calculator.ladderDistribution):

        guard let stakeAmount = state.calculator.stakeAmount else { return .none }

        let percentage = Double(1) / Double(state.calculator.ladderSteps)
        let percentageAmount = Double(stakeAmount) * percentage

        (0 ..< state.calculator.ladderSteps).forEach { index in
            state.calculator.ladderRungs[index].stakePercentage = percentage
            state.calculator.ladderRungs[index].hearts = BigUInt(percentageAmount) * k.HERATS_PER_HEX
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
