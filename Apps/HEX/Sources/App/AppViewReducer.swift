// AppViewReducer.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import BitqueryAPI
import ComposableArchitecture
import EVMChain
import Foundation
import HEXSmartContract
import IdentifiedCollections
import LightweightCharts
import SwiftUI
import UniswapSmartContract

enum Tab {
    case charts, accounts, calculator
}

enum ModalPresent: Identifiable {
    var id: Self { self }

    case edit, speculate
}

struct AppState: Equatable {
    @BindableState var editMode: EditMode = .inactive
    @BindableState var modalPresent: ModalPresent? = nil
    @BindableState var selectedTab: Tab = .accounts
    @BindableState var selectedTimeScale: TimeScale = .day(.one)
    @BindableState var selectedChartType: ChartType = .candlestick

    @BindableState var selectedId = ""
    @BindableState var accountsData = IdentifiedArrayOf<AccountData>()
    @BindableState var shouldSpeculate = false
    @BindableState var speculativePrice: NSNumber = 1.00
    @BindableState var calculator = Calculator()
    
    var ohlcv = [OHLCVData]()
    var chartLoading = false
    var hexContractOnChain = HexContractOnChain()
}

enum AppAction: BindableAction, Equatable {
    case hexManager(HEXSmartContractManager.Action)
    case uniswapManager(UniswapSmartContractManager.Action)

    case applicationDidFinishLaunching
    case onBackground
    case onInactive
    case onActive

    case dismiss
    case getAccounts
    case getChart
    case getPairs
    case updateChart(Result<[OHLCVData], NSError>)
    case binding(BindingAction<AppState>)
    case copy(String)
    case delete(AccountData)
}

struct AppEnvironment {
    var hexManager: HEXSmartContractManager
    var uniswapManager: UniswapSmartContractManager
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
        return .merge(
            environment.hexManager.create(id: HexManagerId()).map(AppAction.hexManager),
            environment.uniswapManager.create(id: UniswapManagerId()).map(AppAction.uniswapManager)
        )

    case .onActive:
        return .merge(
            Effect(value: .getChart),
            Effect(value: .getAccounts),
            Effect(value: .getPairs)
        )

    case .getAccounts:
        let globalInfos = Chain.allCases.compactMap { chain -> Effect<AppAction, Never> in
            environment.hexManager.getGlobalInfo(id: HexManagerId(), chain: chain).fireAndForget()
        }

        let currentDays = Chain.allCases.compactMap { chain -> Effect<AppAction, Never> in
            environment.hexManager.getCurrentDay(id: HexManagerId(), chain: chain).fireAndForget()
        }

        return .merge(
            .merge(globalInfos),
            .merge(currentDays)
        )

    case .getPairs:
        let pairs = Chain.allCases.compactMap { chain -> Effect<AppAction, Never> in
            environment.uniswapManager.getPair(id: UniswapManagerId(), chain: chain, token0: k.HEX, token1: k.USDC).fireAndForget()
        }
        return .merge(pairs)

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

    case let .copy(address):
        UIPasteboard.general.string = address
        return .none

    case let .delete(account):
        state.accountsData.remove(account)
        let accounts = state.accountsData.map { $0.account }
        do {
            let encodedAccounts = try environment.encoder.encode(accounts)
            UserDefaults.standard.setValue(encodedAccounts, forKey: k.ACCOUNTS_KEY)
            return .none
        } catch {
            print(error)
            return .none
        }

    case .binding(\.$selectedTimeScale),
         .binding(\.$selectedChartType):
        return Effect(value: .getChart)

    case .binding(\.$speculativePrice):
        state.hexContractOnChain.ethData.speculativePrice = state.speculativePrice
        state.hexContractOnChain.plsData.speculativePrice = state.speculativePrice
        return .none

    case .binding(\.$shouldSpeculate):
        return .none

    case .binding(\.$selectedTab):
        switch state.selectedTab {
        case .charts: return Effect(value: .getChart)
        case .accounts: return Effect(value: .getAccounts)
        case .calculator: return .none
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

    case .binding(\.$calculator.stakeAmountHex),
         .binding(\.$calculator.stakeDays),
         .binding(\.$calculator.price),
         .binding(\.$calculator.ladderSteps),
         .binding(\.$calculator.ladderDistribution):

        guard let totalStakeDays = state.calculator.stakeDays,
              let stakeAmount = state.calculator.stakeAmountHex,
              state.calculator.stakeDaysValid else { return .none }

        let recentDailyData = state.hexContractOnChain.ethData.dailyData.suffix(7)

        let averageShareRateHex = recentDailyData.map { ($0.payout * k.HEARTS_PER_HEX) / $0.shares }.reduce(BigUInt(0), +) / BigUInt(recentDailyData.count)
        let stakeDays = BigUInt(totalStakeDays) / BigUInt(state.calculator.ladderSteps)
        let principalHearts = state.calculator.stakeAmountHearts / BigUInt(state.calculator.ladderSteps)

        (0 ..< state.calculator.ladderSteps).forEach { index in
            let stakeDaysForRung = stakeDays * BigUInt(index + 1)
            var cappedExtraDays: BigUInt = 0

            if stakeDaysForRung > 1 {
                switch stakeDaysForRung <= k.LPB_MAX_DAYS {
                case true: cappedExtraDays = stakeDaysForRung - BigUInt(1)
                case false: cappedExtraDays = k.LPB_MAX_DAYS
                }
            }

            let cappedStakedHearts: BigUInt
            switch principalHearts <= k.BPB_MAX_HEARTS {
            case true: cappedStakedHearts = principalHearts
            case false: cappedStakedHearts = k.BPB_MAX_HEARTS
            }

            let longerPaysBetter = cappedExtraDays * k.BPB
            let biggerPaysBetter = cappedStakedHearts * k.LPB

            var bonusHearts = longerPaysBetter + biggerPaysBetter
            bonusHearts = principalHearts * bonusHearts / (k.LPB * k.BPB)

            let bonus = Bonus(longerPaysBetter: principalHearts * longerPaysBetter / (k.LPB * k.BPB),
                              biggerPaysBetter: principalHearts * biggerPaysBetter / (k.LPB * k.BPB),
                              bonusHearts: bonusHearts)

            let effectiveHearts = principalHearts + bonusHearts
            let shares = (effectiveHearts * k.SHARE_RATE_SCALE / state.hexContractOnChain.ethData.globalInfo.shareRate)

            let final = Double(averageShareRateHex) * pow(3.69 / 100.0 + 1.0, Double(stakeDaysForRung) / 365.25)
            let averageSharePayout = (averageShareRateHex + BigUInt(final)) / 2

            let interestHearts = shares * stakeDaysForRung * averageSharePayout / k.HEARTS_PER_HEX

            let interval = Double(stakeDaysForRung) * 86400
            state.calculator.ladderRungs[index].date = Date().advanced(by: interval)
            state.calculator.ladderRungs[index].stakePercentage = 1.0 / Double(state.calculator.ladderSteps)
            state.calculator.ladderRungs[index].principalHearts = principalHearts
            state.calculator.ladderRungs[index].interestHearts = interestHearts
            state.calculator.ladderRungs[index].bonus = bonus
            state.calculator.ladderRungs[index].effectiveHearts = effectiveHearts
            state.calculator.ladderRungs[index].shares = shares
        }
        return .none

    case .binding, .hexManager, .uniswapManager, .onBackground, .onInactive:
        return .none
    }
}
.binding()
.combined(with: hexReducer.pullback(state: \.self,
                                    action: /AppAction.hexManager,
                                    environment: { $0 }))
.combined(with: uniswapReducer.pullback(state: \.self,
                                        action: /AppAction.uniswapManager,
                                        environment: { $0 }))
