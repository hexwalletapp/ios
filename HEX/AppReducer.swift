//
//  HEXAppReducer.swift
//  HEXAppReducer
//
//  Created by Joe Blau on 9/4/21.
//

import Foundation
import ComposableArchitecture
import web3
import BigInt
import SwiftUI

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

enum Chain: Codable, Identifiable, CaseIterable, CustomStringConvertible {
    var id: Self { self }

    case ethereum, pulse
    
    var gradient: [Color] {
        switch self {
        case .ethereum: return Constant.HEX_COLORS
        case .pulse: return Constant.PULSE_COLORS
        }
    }
    
    var description: String {
        switch self {
        case .ethereum: return "Ethereum"
        case .pulse: return "Pulse"
        }
    }
}

struct Account: Codable, Hashable, Equatable, Identifiable {
    var id: String { address + chain.description }
    var name: String = ""
    var address: String = ""
    var chain: Chain = .ethereum
    var hexPrice: Double = 0
    var stakes = [Stake]()
    var total = StakeTotal()
}

struct DailyData: Equatable {
    let payout: BigUInt
    let shares: BigUInt
    let sats: BigUInt
    
    init(dayData: BigUInt) {
        var dailyData = dayData
        payout = dailyData & Constant.HEARTS_MASK
        dailyData >>= Constant.HEARTS_UINT_SHIFT
        shares = dailyData & Constant.HEARTS_MASK
        dailyData >>= Constant.HEARTS_UINT_SHIFT
        sats = dailyData & Constant.SATS_MASK
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
        hexEth =  Double(try container.decode(String.self, forKey: .hexEth)) ?? 0
        hexUsd =  Double(try container.decode(String.self, forKey: .hexUsd)) ?? 0
        hexBtc =  Double(try container.decode(String.self, forKey: .hexBtc)) ?? 0
    }
}

struct StakeTotal: Codable, Hashable, Equatable {
    var stakeShares: BigUInt = 0
    var stakeHearts: BigUInt = 0
    var interestHearts: BigUInt = 0
    var interestSevenDayHearts: BigUInt = 0
}

struct AppState: Equatable {
    @BindableState var presentEditAddress = false
    @BindableState var selectedTab: Tab = .accounts
    @BindableState var selectedStakeSegment: StakeFilter = .total
    @BindableState var selectedChain: Chain = .ethereum
    @BindableState var selectedAccount: Account? = nil
    @BindableState var accounts: [Account]? = nil
    var stakeCount = 0
    var currentDay: BigUInt? = nil
    var stakesBeginDay = UInt16.max
    var stakesEndDay = UInt16.min
    var sharesPerDay = [BigUInt]()
    var dailyDataList = [DailyData]()
}

enum AppAction: BindableAction, Equatable {
    case onBackground
    case onInactive
    case onActive
    case getStakes
    case getCurrentDay
    case getDailyDataRange(UInt16, UInt16)
    case scheduleNotification
    
    case updateStakeIDs([BigUInt])
    case updateStake(Stake)
    case updateHexPrice(Result<HEXPrice, NSError>)
    case updateDay(BigUInt)
    case updateDailyData([DailyData])
    case binding(BindingAction<AppState>)
}

struct AppEnvironment {
    let client: EthereumClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .onBackground:
        return .none
        
    case .onInactive:
        return .none
        
    case .onActive:
        switch UserDefaults.standard.data(forKey: Constant.ACCOUNTS_KEY) {
        case let .some(encodedAccounts):
            do {
                let decodedAccounts = try environment.decoder.decode([Account].self, from: encodedAccounts)
                state.accounts = decodedAccounts
            } catch {
                UserDefaults.standard.removeObject(forKey: Constant.ACCOUNTS_KEY)
                print(error)
            }
        case .none:
            break
        }
        
        return .merge(
            Effect(value: .getCurrentDay),
            HEXRESTAPI.fetchHexPrice()
                .receive(on: environment.mainQueue)
                .mapError { $0 as NSError }
                .catchToEffect()
                .map(AppAction.updateHexPrice),
            Effect(value: .getStakes)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
        )
        
    case let .updateStakeIDs(stakeIDs):
//        state.stakeCount = stakeIDs.count
//        state.stakes = [Stake]()
//        guard let firstAccountAddress = state.accounts?.first?.address else { return .none }
//
//        let stakeAddress = EthereumAddress(firstAccountAddress)
//
//        return .merge(
//            stakeIDs.map { stakeID in
//                return .future { completion in
//                    let getStake = StakeLists_Parameter(stakeAddress: stakeAddress,
//                                                        stakeIndex: stakeID)
//                    getStake.call(withClient: environment.client,
//                                  responseType: Stake.self) { (error, response) in
//                        switch error {
//                        case let .some(error):
//                            print(error)
//                        case .none:
//                            switch response {
//                            case let .some(stake):
//                                environment.mainQueue.schedule {
//                                    completion(.success(.updateStake(stake)))
//                                }
//                            case .none:
//                                print("no stake")
//                            }
//                        }
//                    }
//                }
//            }
//        )
        return .none
        
    case let .updateStake(stake):
//        state.stakes.append(stake)
//        state.stakesBeginDay = min(state.stakesBeginDay, stake.lockedDay)
//        state.stakesEndDay = max(state.stakesEndDay, stake.lockedDay + stake.stakedDays)
//
//        switch state.stakes.count == state.stakeCount {
//        case true:
//            state.stakes.sort(by: { $0.lockedDay + $0.stakedDays < $1.lockedDay + $1.stakedDays })
//            state.total.stakeHearts = state.stakes.reduce(0, { $0 + $1.stakedHearts })
//            state.total.stakeShares = state.stakes.reduce(0, { $0 + $1.stakeShares })
//            guard let currentDay = state.currentDay else { return .none }
//            return Effect(value: .getDailyDataRange(state.stakesBeginDay, min(state.stakesEndDay, UInt16(currentDay))))
//        case false:
//            return .none
//        }
        return .none
        
    case .getStakes:
//        guard let firstAccountAddress = state.accounts?.first?.address else { return .none }
//        let stakeAddress = EthereumAddress(firstAccountAddress)
//
//        return .future { completion in
//            let stakes = StakeCount_Parameter(stakeAddress: stakeAddress)
//            stakes.call(withClient: environment.client,
//                        responseType: StakeCount_Parameter.Response.self) { (error, response) in
//                switch error {
//                case let .some(err):
//                    print(err)
//                case .none:
//                    switch response?.stakeCount {
//                    case let .some(count):
//                        let stakes = (0..<count).map { BigUInt($0) }
//                        environment.mainQueue.schedule {
//                            completion(.success(.updateStakeIDs(stakes)))
//                        }
//                    case .none:
//                        print("no stakes")
//                    }
//                }
//            }
//        }
        return .none
        
    case let .getDailyDataRange(begin, end):
        return .future { completion in
            let dailyDataRange = DailyDataRange_Parameter(beginDay: BigUInt(begin), endDay: BigUInt(end))
            dailyDataRange.call(withClient: environment.client,
                                responseType: DailyDataRange_Parameter.Response.self) { (error, response) in
                switch error {
                case let .some(err):
                    print(err)
                case .none:
                    switch response?.list {
                    case let .some(list):
                        let dailyDataList = list.map { DailyData(dayData: $0) }
                        environment.mainQueue.schedule {
                            completion(.success(.updateDailyData(dailyDataList)))
                        }
                    case .none:
                        print("no stakes")
                    }
                }
            }
        }
        
    case .getCurrentDay:
        return .future { completion in
            let currentDay = CurrentDay()
            currentDay.call(withClient: environment.client,
                            responseType: CurrentDay.Response.self) { (error, response) in
                switch error {
                case let .some(err):
                    print(err)
                case .none:
                    switch response?.day {
                    case let .some(day):
                        environment.mainQueue.schedule {
                            completion(.success(.updateDay(day)))
                        }
                    case .none:
                        print("no stakes")
                    }
                }
            }
        }
        
    case let .updateDay(day):
        state.currentDay = day
        return .none
        
    case let .updateHexPrice(result):
//        switch result {
//        case let .success(hexPrice):
//            state.hexPrice = hexPrice.hexUsd
//        case let .failure(error):
//            print(error)
//        }
        return .none
        
    case .scheduleNotification:
        return .none
        
    case let .updateDailyData(dailyData):
//        state.dailyDataList = dailyData
//        
//        guard let currentDay = state.currentDay else { return .none }
//        state.stakes.enumerated().forEach { (index, stake) in
//            let startIndex = Int(stake.lockedDay - state.stakesBeginDay)
//            let endIndex = Int(currentDay - BigUInt(state.stakesBeginDay))
//            let minusWeekIndex = max(endIndex - 7, startIndex)
//            
//            state.stakes[index].interestHearts = state.dailyDataList[startIndex..<endIndex]
//                .reduce(0, { $0 + ((stake.stakeShares * $1.payout) / $1.shares) })
//            state.stakes[index].interestSevenDayHearts = state.dailyDataList[minusWeekIndex..<endIndex]
//                .reduce(0, { $0 + ((stake.stakeShares * $1.payout) / $1.shares) })
//            
//            state.stakes[index].percentComplete = (Double(currentDay) - Double(stake.lockedDay)) / Double(stake.stakedDays)
//        }
//        
//        state.total.interestHearts = state.stakes.reduce(0, { $0 + $1.interestHearts })
//        state.total.interestSevenDayHearts = state.stakes.reduce(0, { $0 + $1.interestSevenDayHearts }) / Constant.ONE_WEEK
        
        return .none
        

    case .binding(\.$selectedTab):
        switch state.selectedTab {
        case .charts, .calculator: return .none
        case .accounts: return Effect(value: .getStakes)
        }
        
    case .binding(\.$accounts):
        do {
            let encodedAccounts = try environment.encoder.encode(state.accounts)
            UserDefaults.standard.setValue(encodedAccounts, forKey: Constant.ACCOUNTS_KEY)
        } catch {
            UserDefaults.standard.removeObject(forKey: Constant.ACCOUNTS_KEY)
        }
        return .none
        
    case .binding:
        return .none
    }
}
    .binding()


