// AppViewReducer.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import Foundation
import HEXSmartContract
import SwiftUI
import IdentifiedCollections

import BigInt

enum Tab {
    case charts, accounts, calculator
}

enum StakeFilter: Equatable, CaseIterable, CustomStringConvertible {
    case total, list

    var description: String {
        switch self {
        case .total: return "Total"
        case .list: return "List"
        }
    }
}

struct HEXPrice: Codable, Equatable {
    var lastUpdated: Date
    var hexEth: Double
    var hexUsd: Double
    var hexBtc: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let date = try container.decode(String.self, forKey: .lastUpdated)

        lastUpdated = dateFormatter.date(from: date) ?? Date()
        hexEth = Double(try container.decode(String.self, forKey: .hexEth)) ?? 0
        hexUsd = Double(try container.decode(String.self, forKey: .hexUsd)) ?? 0
        hexBtc = Double(try container.decode(String.self, forKey: .hexBtc)) ?? 0
    }
}

struct StakeTotal: Codable, Hashable, Equatable {
    var stakeShares: BigUInt = 0
    var stakeHearts: BigUInt = 0
    var interestHearts: BigUInt = 0
    var interestSevenDayHearts: BigUInt = 0
}

enum Action {
    case add, remove
}

struct AppState: Equatable {
    @BindableState var presentEditAddress = false
    @BindableState var selectedTab: Tab = .accounts
    
    @BindableState var selectedId = ""
    @BindableState var accounts = IdentifiedArrayOf<Account>()
    var currentDay: BigUInt = 0
}

enum AppAction: BindableAction, Equatable {
    case hexManager(HEXSmartContractManager.Action)

    case applicationDidFinishLaunching
    case onBackground
    case onInactive
    case onActive
    
    case account(Action, Account)
//    case getStakes
//    case getCurrentDay
//    case scheduleNotification

//    case getDailyDataRange(UInt16, UInt16, String)
//    case updateStakeIDs([BigUInt], String)
//    case updateStake(Stake, String)
//    case updateDailyData([DailyData], String)
//    case updateHexPrice(Result<HEXPrice, NSError>)
//    case updateDay(BigUInt)
    case binding(BindingAction<AppState>)

//    case updateAccounts
}

struct AppEnvironment {
    var hexManager: HEXSmartContractManager

    var mainQueue: AnySchedulerOf<DispatchQueue>
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .hexManager:
        return .none

    case .applicationDidFinishLaunching:
        return environment.hexManager.create(id: HexManagerId()).map(AppAction.hexManager)

    case .onBackground:
        return .none

    case .onInactive:
        return .none

    case .onActive:
        switch UserDefaults.standard.data(forKey: k.ACCOUNTS_KEY) {
        case let .some(encodedAccounts):
            do {
                let decodedAccounts = try environment.decoder.decode(IdentifiedArrayOf<Account>.self, from: encodedAccounts)
                state.accounts = decodedAccounts
                state.selectedId = decodedAccounts.first?.address ?? ""
            } catch {
                UserDefaults.standard.removeObject(forKey: k.ACCOUNTS_KEY)
                print(error)
            }
        case .none:
            break
        }
        
        return environment.hexManager.getCurrentDay(id: HexManagerId()).fireAndForget()
        
        

    case let .account(action, account):
//        switch action {
//        case .add: state.accounts.append(account)
//        case .remove: state.accounts.remove(id: account.id)
//        }
        return .none
        
//        return Effect(value: .updateAccounts)

//    case let .updateStakeIDs(stakeIDs, id):
//        guard let accountIndex = state.accounts.firstIndex(where: { $0.id == id }) else { return .none }
//        state.accounts[accountIndex].stakes = [Stake]()
//        state.accounts[accountIndex].stakeCount = stakeIDs.count
//        let address = EthereumAddress(state.accounts[accountIndex].address)
//        return .merge(
//            stakeIDs.map { stakeID in
//                .future { completion in
//                    let getStake = StakeLists_Parameter(stakeAddress: address,
//                                                        stakeIndex: stakeID)
//                    getStake.call(withClient: environment.client,
//                                  responseType: Stake.self) { error, response in
//                        switch error {
//                        case let .some(error):
//                            print(error)
//                        case .none:
//                            switch response {
//                            case let .some(stake):
//                                environment.mainQueue.schedule {
//                                    completion(.success(.updateStake(stake, id)))
//                                }
//                            case .none:
//                                print("no stake")
//                            }
//                        }
//                    }
//                }
//            }
//        )

//    case let .updateStake(stake, id):
//        guard let accountIndex = state.accounts.firstIndex(where: { $0.id == id }) else { return .none }
//        var stake = stake
//        state.accounts[accountIndex].stakesBeginDay = min(state.accounts[accountIndex].stakesBeginDay, stake.lockedDay)
//        state.accounts[accountIndex].stakesEndDay = max(state.accounts[accountIndex].stakesEndDay, stake.lockedDay + stake.stakedDays)
//
//        state.accounts[accountIndex].stakes.append(stake)
//
//        switch state.accounts[accountIndex].stakes.count == state.accounts[accountIndex].stakeCount {
//        case true:
//            state.accounts[accountIndex].stakes.sort(by: { $0.lockedDay + $0.stakedDays < $1.lockedDay + $1.stakedDays })
//            state.accounts[accountIndex].total.stakeHearts = state.accounts[accountIndex].stakes.reduce(0) { $0 + $1.stakedHearts }
//            state.accounts[accountIndex].total.stakeShares = state.accounts[accountIndex].stakes.reduce(0) { $0 + $1.stakeShares }
//            guard let currentDay = state.currentDay else { return .none }
//            return Effect(value: .getDailyDataRange(state.accounts[accountIndex].stakesBeginDay, min(state.accounts[accountIndex].stakesEndDay, UInt16(currentDay)), id))
//        case false:
//            return .none
//        }

//    case .getStakes:
//        return .merge(
//            state.accounts.compactMap { account -> Effect<AppAction, Never>? in
//                let address = EthereumAddress(account.address)
//                return .future { completion in
//                    let stakes = StakeCount_Parameter(stakeAddress: address)
//                    stakes.call(withClient: environment.client,
//                                responseType: StakeCount_Parameter.Response.self) { error, response in
//                        switch error {
//                        case let .some(err):
//                            print(err)
//                        case .none:
//                            switch response?.stakeCount {
//                            case let .some(count):
//                                let stakes = (0 ..< count).map { BigUInt($0) }
//                                environment.mainQueue.schedule {
//                                    completion(.success(.updateStakeIDs(stakes, account.id)))
//                                }
//                            case .none:
//                                print("no stakes")
//                            }
//                        }
//                    }
//                }
//            }
//        )

//    case let .getDailyDataRange(begin, end, address):
//        return .future { completion in
//            let dailyDataRange = DailyDataRange_Parameter(beginDay: BigUInt(begin), endDay: BigUInt(end))
//            dailyDataRange.call(withClient: environment.client,
//                                responseType: DailyDataRange_Parameter.Response.self) { error, response in
//                switch error {
//                case let .some(err):
//                    print(err)
//                case .none:
//                    switch response?.list {
//                    case let .some(list):
//                        let dailyDataList = list.map { DailyData(dayData: $0) }
//                        environment.mainQueue.schedule {
//                            completion(.success(.updateDailyData(dailyDataList, address)))
//                        }
//                    case .none:
//                        print("no stakes")
//                    }
//                }
//            }
//        }
//
//    case .getCurrentDay:
//        return .future { completion in
//            let currentDay = CurrentDay()
//            currentDay.call(withClient: environment.client,
//                            responseType: CurrentDay.Response.self) { error, response in
//                switch error {
//                case let .some(err):
//                    print(err)
//                case .none:
//                    switch response?.day {
//                    case let .some(day):
//                        environment.mainQueue.schedule {
//                            completion(.success(.updateDay(day)))
//                        }
//                    case .none:
//                        print("no stakes")
//                    }
//                }
//            }
//        }
//
//    case let .updateDay(day):
//        state.currentDay = day
//        return .none
//
//    case let .updateHexPrice(result):
//        switch result {
//        case let .success(hexPrice):
//            (0 ..< state.accounts.count).forEach { index in
//                state.accounts[index].hexPrice = hexPrice.hexUsd
//            }
//        case let .failure(error):
//            print(error)
//        }
//        return .none

//    case .scheduleNotification:
//        return .none

//    case let .updateDailyData(dailyData, id):
//
//        guard let currentDay = state.currentDay,
//              let accountIndex = state.accounts.firstIndex(where: { $0.id == id }) else { return .none }
//
//        state.accounts[accountIndex].dailyDataList = dailyData
//        state.accounts[accountIndex].stakes.enumerated().forEach { index, stake in
//            let startIndex = Int(stake.lockedDay - state.accounts[accountIndex].stakesBeginDay)
//            let endIndex = Int(currentDay - BigUInt(state.accounts[accountIndex].stakesBeginDay))
//            let minusWeekIndex = max(endIndex - 7, startIndex)
//
//            state.accounts[accountIndex].stakes[index].interestHearts = state.accounts[accountIndex].dailyDataList[startIndex ..< endIndex]
//                .reduce(0) { $0 + ((stake.stakeShares * $1.payout) / $1.shares) }
//            state.accounts[accountIndex].stakes[index].interestSevenDayHearts = state.accounts[accountIndex].dailyDataList[minusWeekIndex ..< endIndex]
//                .reduce(0) { $0 + ((stake.stakeShares * $1.payout) / $1.shares) }
//
//            state.accounts[accountIndex].stakes[index].percentComplete = (Double(currentDay) - Double(stake.lockedDay)) / Double(stake.stakedDays)
//        }
//
//        state.accounts[accountIndex].total.interestHearts = state.accounts[accountIndex].stakes.reduce(0) { $0 + $1.interestHearts }
//        state.accounts[accountIndex].total.interestSevenDayHearts = state.accounts[accountIndex].stakes.reduce(0) { $0 + $1.interestSevenDayHearts } / k.ONE_WEEK
//        return .none
//
//    case .updateAccounts:
//        return .merge(
//            Effect(value: .getCurrentDay),
//            HEXRESTAPI.fetchHexPrice()
//                .receive(on: environment.mainQueue)
//                .mapError { $0 as NSError }
//                .catchToEffect()
//                .map(AppAction.updateHexPrice),
//            Effect(value: .getStakes)
//                .receive(on: environment.mainQueue)
//                .eraseToEffect()
//        )

        
    case .binding(\.$selectedTab):
//        switch state.selectedTab {
//        case .charts, .calculator: return .none
//        case .accounts:
//            return Effect(value: .updateAccounts)
//        }
        return .none

    case .binding(\.$presentEditAddress):
//        switch state.presentEditAddress {
//        case false: return Effect(value: .updateAccounts)
//        case true: return .none
//        }
        return .none

    case .binding(\.$accounts):
        do {
            let encodedAccounts = try environment.encoder.encode(state.accounts)
            UserDefaults.standard.setValue(encodedAccounts, forKey: k.ACCOUNTS_KEY)
        } catch {
            UserDefaults.standard.removeObject(forKey: k.ACCOUNTS_KEY)
        }
        return .none

    case .binding:
        return .none
    }
}
.binding()
.combined(with: hexReducer.pullback(state: \.self,
                                    action: /AppAction.hexManager,
                                    environment: { $0 }))
