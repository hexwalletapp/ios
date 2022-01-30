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
import os.log
import SwiftUI
import UniswapSmartContract

enum Tab {
    case charts, accounts, calculator
}

enum ModalPresent: Identifiable {
    var id: Self { self }

    case edit, speculate
}

struct PageViewDots: Equatable {
    var hasMinusOne: Bool = false
    var numberOfPages: Int = 0
    var currentIndex: Int = -1
}

struct AppState: Equatable {
    @BindableState var editMode: EditMode = .inactive
    @BindableState var modalPresent: ModalPresent? = nil
    @BindableState var selectedTab: Tab = .charts
    @BindableState var selectedTimeScale: TimeScale = .day(.one)
    @BindableState var selectedChartType: ChartType = .candlestick

    @BindableState var selectedId = ""
    @BindableState var accountsData = IdentifiedArrayOf<AccountData>()
    @BindableState var shouldSpeculate = false
    @BindableState var speculativePrice: NSNumber = 1.00
    @BindableState var calculator = Calculator()

    @BindableState var groupAccountData = GroupAccountData()

    var ohlcv = [OHLCVData]()
    var chartLoading = false
    var didHaveFavorites = false
    var hexContractOnChain = HexContractOnChain()
    var pageViewDots = PageViewDots()
    var activeChains = Set<Chain>()
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
    case getGlobalInfo
    case getChart
    case updateChart(Result<[OHLCVData], NSError>)
    case binding(BindingAction<AppState>)
    case copy(String)
    case delete(AccountData)
    case updateFavorites
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
                state.activeChains = Set<Chain>(state.accountsData.map { $0.account.chain })
                state.pageViewDots.numberOfPages = decodedAccounts.count
                state.selectedId = decodedAccounts.first?.id ?? ""
            } catch {
                UserDefaults.standard.removeObject(forKey: k.ACCOUNTS_KEY)
                os_log("%@", log: .hexApp, type: .error, error.localizedDescription)
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
            Effect(value: .updateFavorites)
        )

    case .getAccounts:
        let pairs = Array(state.activeChains).compactMap { chain -> Effect<AppAction, Never> in
            environment.uniswapManager.getPair(id: UniswapManagerId(), chain: chain, token0: k.HEX, token1: k.USDC).fireAndForget()
        }
        return .merge(
            .merge(pairs),
            Effect.cancel(id: CancelGetAccounts()),
            Effect(value: .getGlobalInfo)
                .throttle(id: GetAccountsThorttleId(), for: .seconds(6), scheduler: environment.mainQueue, latest: true)
                .cancellable(id: CancelGetAccounts())
        )

    case .getGlobalInfo:
        let globalInfos = Array(state.activeChains).compactMap { chain -> Effect<AppAction, Never> in
            environment.hexManager.getGlobalInfo(id: HexManagerId(), chain: chain).fireAndForget()
        }
        return .merge(globalInfos)

    case let .updateChart(result):
        state.chartLoading = false
        switch result {
        case let .success(chartData):
            state.ohlcv = chartData
        case let .failure(error):
            os_log("%@", log: .hexApp, type: .error, error.localizedDescription)
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
        state.activeChains = Set<Chain>(state.accountsData.map { $0.account.chain })
        return .merge(
            Effect(value: .updateFavorites),
            Effect(value: .getAccounts)
        )

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
            os_log("%@", log: .hexApp, type: .error, error.localizedDescription)
            return .none
        }

    case .updateFavorites:
        state.accountsData.filter { !$0.account.isFavorite }.forEach { account in
            state.groupAccountData.accountsData.remove(account)
        }
        state.accountsData.filter { $0.account.isFavorite }.forEach { account in
            state.groupAccountData.accountsData.updateOrAppend(account)
        }
        
        switch (state.groupAccountData.hasFavorites != state.didHaveFavorites) {
        case true:
            let currentIndex = state.pageViewDots.currentIndex
            let numberOfPages: Int
            switch state.groupAccountData.hasFavorites {
            case true:
                numberOfPages = state.accountsData.count + 1
                state.pageViewDots.hasMinusOne = true
                state.pageViewDots.numberOfPages = numberOfPages
                state.pageViewDots.currentIndex = currentIndex.clamp(lower: 1, numberOfPages)
                state.selectedId = state.accountsData[state.pageViewDots.currentIndex - 1].id
            case false:
                numberOfPages = state.accountsData.count
                state.pageViewDots.hasMinusOne = false
                state.pageViewDots.numberOfPages = numberOfPages
                state.pageViewDots.currentIndex = currentIndex.clamp(lower: 0, numberOfPages)
                state.selectedId = state.accountsData[state.pageViewDots.currentIndex].id
            }
            state.didHaveFavorites = state.groupAccountData.hasFavorites
        case false:
            let numberOfPages: Int
            switch state.groupAccountData.hasFavorites {
            case true: numberOfPages = state.accountsData.count + 1
            case false: numberOfPages = state.accountsData.count
            }
            state.pageViewDots.numberOfPages = numberOfPages
        }
        return .none

    case .binding(\.$selectedId):
        switch state.groupAccountData.hasFavorites {
        case true:
            switch (state.groupAccountData.id == state.selectedId,
                    state.accountsData.index(id: state.selectedId))
            {
            case (true, .none): state.pageViewDots.currentIndex = 0
            case (false, let .some(index)): state.pageViewDots.currentIndex = index + 1
            default: state.pageViewDots.currentIndex = 1
            }
        case false:
            state.pageViewDots.currentIndex = state.accountsData.index(id: state.selectedId) ?? 0
        }
        return .none

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
        case .none: return Effect(value: .dismiss)
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
