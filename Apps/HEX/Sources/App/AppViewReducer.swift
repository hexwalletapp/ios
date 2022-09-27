// AppViewReducer.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import EVMChain
import Foundation
import HedronSmartContract
import HEXSmartContract
import IdentifiedCollections
import os.log
import SwiftUI

enum Tab {
    case accounts, calculator
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

struct LivePrice: Equatable {
    var price: Double = 0
    var text: UIColor = .label
    var background: UIColor = .systemBackground
}

struct AppState: Equatable {
    @BindableState var editMode: EditMode = .inactive
    @BindableState var modalPresent: ModalPresent? = nil
    @BindableState var selectedTab: Tab = .accounts
    @BindableState var payPeriod: PayPeriod = .daily
    @BindableState var creditCardUnits: CreditCardUnits = .usd

    @BindableState var selectedId = ""
    @BindableState var shouldSpeculate = false
    @BindableState var speculativePrice: NSNumber = 1.00
    @BindableState var calculator = Calculator()

    @BindableState var accounts = IdentifiedArrayOf<Account>()
    @BindableState var favoriteAccounts = FavoriteAccounts()
    
    @BindableState var rightAxisLivePrice = LivePrice()

    var poolSpacing = [String: BigInt]()
    var didHaveFavorites = false
    var hexERC20 = HEXERC20()
    var pageViewDots = PageViewDots()
    var activeChains = Set<Chain>()
    var colorScheme: ColorScheme?
}

enum AppAction: BindableAction, Equatable {
    case hexManager(HEXSmartContractManager.Action)
    case hedronManager(HedronSmartContractManager.Action)

    case applicationDidFinishLaunching
    case onBackground
    case onInactive
    case onActive

    case dismiss
    case getAccounts
    case getGlobalInfo
    case binding(BindingAction<AppState>)
    case copy(String)
    case delete(Account)
    case updateFavorites
}

struct AppEnvironment {
    var hexManager: HEXSmartContractManager
    var hedronManager: HedronSmartContractManager
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
                state.accounts = IdentifiedArray(uniqueElements: decodedAccounts)
                state.activeChains = Set<Chain>(state.accounts.map { $0.chain })
                state.activeChains.forEach {
                    state.hexERC20.data[$0] = OnChainData()
                }
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
            environment.hedronManager.create(id: HedronManagerId()).map(AppAction.hedronManager)
        )

    case .onActive:
        switch UserDefaults.standard.string(forKey: "appearanceSetting") {
        case let .some(appearance) where appearance == "1":
            state.colorScheme = .light
        case let .some(appearance) where appearance == "2":
            state.colorScheme = .dark
        default:
            state.colorScheme = nil
        }
        return .merge(
            Effect(value: .getAccounts),
            Effect(value: .updateFavorites)
        )

    case .getAccounts:
        return .merge(
            Effect.cancel(id: CancelGetAccounts()),
            Effect(value: .getGlobalInfo)
                .throttle(id: GetAccountsThorttleId(), for: .seconds(6), scheduler: environment.mainQueue, latest: true)
                .cancellable(id: CancelGetAccounts())
        )

    case .getGlobalInfo:
        return .merge(
            environment.hexManager.getGlobalInfo(id: HexManagerId(), chain: .ethereum).fireAndForget(),
            environment.hexManager.getGlobalInfo(id: HexManagerId(), chain: .pulse).fireAndForget()
        )

    case .dismiss:
        state.modalPresent = nil
        state.activeChains = Set<Chain>(state.accounts.map { $0.chain })
        return .merge(
            Effect(value: .updateFavorites),
            Effect(value: .getAccounts)
        )

    case let .copy(address):
        UIPasteboard.general.string = address
        return .none

    case let .delete(account):
        state.accounts.remove(account)
        do {
            let encodedAccounts = try environment.encoder.encode(state.accounts)
            UserDefaults.standard.setValue(encodedAccounts, forKey: k.ACCOUNTS_KEY)
            return .none
        } catch {
            os_log("%@", log: .hexApp, type: .error, error.localizedDescription)
            return .none
        }

    case .updateFavorites:
        state.accounts.filter { !$0.isFavorite }.forEach { account in
            state.favoriteAccounts.accounts.remove(account)
        }
        state.accounts.filter { $0.isFavorite }.forEach { account in
            state.favoriteAccounts.accounts.updateOrAppend(account)
        }

        switch state.favoriteAccounts.hasFavorites != state.didHaveFavorites {
        case true:
            let currentIndex = state.pageViewDots.currentIndex
            let numberOfPages: Int
            switch state.favoriteAccounts.hasFavorites {
            case true:
                numberOfPages = state.accounts.count + 1
                state.pageViewDots.hasMinusOne = true
                state.pageViewDots.numberOfPages = numberOfPages
                state.pageViewDots.currentIndex = currentIndex.clamp(lower: 1, numberOfPages)
                state.selectedId = state.accounts[state.pageViewDots.currentIndex - 1].id
            case false:
                numberOfPages = state.accounts.count
                state.pageViewDots.hasMinusOne = false
                state.pageViewDots.numberOfPages = numberOfPages
                state.pageViewDots.currentIndex = currentIndex.clamp(lower: 0, numberOfPages)
                state.selectedId = state.accounts[state.pageViewDots.currentIndex].id
            }
            state.didHaveFavorites = state.favoriteAccounts.hasFavorites
        case false:
            let numberOfPages: Int
            switch state.favoriteAccounts.hasFavorites {
            case true: numberOfPages = state.accounts.count + 1
            case false: numberOfPages = state.accounts.count
            }
            state.pageViewDots.numberOfPages = numberOfPages
        }
        return .none

    case .binding(\.$selectedId):
        switch state.favoriteAccounts.hasFavorites {
        case true:
            switch (state.favoriteAccounts.id == state.selectedId,
                    state.accounts.index(id: state.selectedId))
            {
            case (true, .none): state.pageViewDots.currentIndex = 0
            case (false, let .some(index)): state.pageViewDots.currentIndex = index + 1
            default: state.pageViewDots.currentIndex = 1
            }
        case false:
            state.pageViewDots.currentIndex = state.accounts.index(id: state.selectedId) ?? 0
        }
        return .none

    case .binding(\.$speculativePrice):
        state.hexERC20.data.keys.forEach { chain in
            // TODO: Fix this to make it optional
            state.hexERC20.data[chain]!.speculativePrice = state.speculativePrice
        }
        return .none

    case .binding(\.$shouldSpeculate):
        return .none

    case .binding(\.$selectedTab):
        switch state.selectedTab {
        case .accounts: return Effect(value: .getAccounts)
        case .calculator: return .none
        }

    case .binding(\.$modalPresent):
        switch state.modalPresent {
        case .some: return .none
        case .none: return Effect(value: .dismiss)
        }

    case .binding(\.$accounts):
        do {
            if let lastAccount = state.accounts.last, state.selectedId.isEmpty {
                state.selectedId = lastAccount.address.value + lastAccount.chain.description
            }
            let encodedAccounts = try environment.encoder.encode(state.accounts)
            UserDefaults.standard.setValue(encodedAccounts, forKey: k.ACCOUNTS_KEY)
        } catch {
            UserDefaults.standard.removeObject(forKey: k.ACCOUNTS_KEY)
        }
        return .none

    case .binding(\.$calculator.stakeAmountDollar),
         .binding(\.$calculator.stakeAmountHex),
         .binding(\.$calculator.stakeDays),
         .binding(\.$calculator.price),
         .binding(\.$calculator.ladderSteps),
         .binding(\.$calculator.ladderDistribution):

        guard let recentDailyData = state.hexERC20.data[.ethereum]?.dailyData.suffix(7) else {
            return .none
        }

        switch state.calculator.planUnit {
        case .USD:
            state.calculator.stakeAmountHex = Int(state.calculator.stakeAmountHearts / k.HEARTS_PER_HEX)
        case .HEX:
            if let price = state.calculator.price {
                state.calculator.stakeAmountDollar = Double(state.calculator.stakeAmountHearts / k.HEARTS_PER_HEX) * price
            }
        }

        guard let totalStakeDays = state.calculator.stakeDays,
              let globalShareRate = state.hexERC20.data[.ethereum]?.globalInfo.shareRate,
              state.calculator.stakeDaysValid,
              state.calculator.isAmountValid,
              !recentDailyData.isEmpty else { return .none }

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
            let shares = (effectiveHearts * k.SHARE_RATE_SCALE / globalShareRate)

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

    case .binding, .hexManager, .hedronManager, .onBackground, .onInactive:
        return .none
    }
}
.binding()
.combined(with: hexReducer.pullback(state: \.self,
                                    action: /AppAction.hexManager,
                                    environment: { $0 }))
.combined(with: hedronReducer.pullback(state: \.self,
                                       action: /AppAction.hedronManager,
                                       environment: { $0 }))
