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

enum Tab: Int, Equatable  {
    case charts = 0
    case stakes = 1
    case calculator = 2
}

enum StakeFilter: Int, Equatable, CaseIterable, CustomStringConvertible {
    case total = 0
    case list = 1
    
    var description: String {
        switch self {
        case .total: return "Total"
        case .list: return "List"
        }
    }
}

struct DailyData: Equatable {
    let payout: BigUInt
    let shares: BigUInt
    let sats: BigUInt
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

struct StakeTotal: Equatable {
    var stakeShares: BigUInt = 0
    var stakeHearts: BigUInt = 0
}

struct AppState: Equatable {
    var selectedTab = Tab.charts
    var selectedStakeSegment = StakeFilter.total
    var hexPrice = 0.0
    var stakeCount = 0
    var currentDay: BigUInt? = nil
    var stakesBeginDay = UInt16.max
    var stakesEndDay = UInt16.min
    var stakes = [StakeLists_Parameter.Response]()
    var total = StakeTotal()
    var dailyDataList = [DailyData]()
}

enum AppAction: Equatable {
    case onBackground
    case onInactive
    case onActive
    case getStakes
    case getCurrentDay
    case getDailyDataRange(UInt16, UInt16)
    
    case updateStakeIDs([BigUInt])
    case updateStake(StakeLists_Parameter.Response)
    case updateHexPrice(HEXPrice)
    case updateDay(BigUInt)
    case updateDailyData([DailyData])
    case form(BindingAction<AppState>)
}

struct AppEnvironment {
    let client: EthereumClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .onBackground:
        return .none
        
    case .onInactive:
        return .none
        
    case .onActive:
        return .merge(
            Effect(value: .getCurrentDay),
            .future { completion in
                Task {
                    do {
                        let hexPrice = try await HEXRESTAPI.fetchHexPrice()
                        environment.mainQueue.schedule {
                            completion(.success(.updateHexPrice(hexPrice)))
                        }
                    } catch {
                        fatalError()
                    }
                }
            }
        )
        
    case let .updateStakeIDs(stakeIDs):
        state.stakeCount = stakeIDs.count
        state.stakes = [StakeLists_Parameter.Response]()
        return .merge(
            stakeIDs.map { stakeID in
                return .future { completion in
                    let getStake = StakeLists_Parameter(stakeAddress: EthereumAddress("0xb6542DE25941D3ca4Eb839F6C9096823e09Ab5B4"),
                                                        stakeIndex: stakeID)
                    getStake.call(withClient: environment.client,
                                  responseType: StakeLists_Parameter.Response.self) { (error, response) in
                        switch error {
                        case let .some(error):
                            print(error)
                        case .none:
                            switch response {
                            case let .some(stake):
                                environment.mainQueue.schedule {
                                    completion(.success(.updateStake(stake)))
                                }
                            case .none:
                                print("no stake")
                            }
                        }
                    }
                }
            }
        )
        
    case let .updateStake(stake):
        state.stakes.append(stake)
        state.stakesBeginDay = min(state.stakesBeginDay, stake.lockedDay)
        state.stakesEndDay = max(state.stakesEndDay, stake.lockedDay + stake.stakedDays)
        
        switch state.stakes.count == state.stakeCount {
        case true:
            state.total.stakeHearts = state.stakes.reduce(0, { $0 + $1.stakedHearts })
            state.total.stakeShares = state.stakes.reduce(0, { $0 + $1.stakeShares })
            guard let currentDay = state.currentDay else { return .none }
            return Effect(value: .getDailyDataRange(state.stakesBeginDay, min(state.stakesEndDay, UInt16(currentDay))))
        case false:
            return .none
        }
        
    case .getStakes:
        return .future { completion in
            let stakes = StakeCount_Parameter(stakeAddress: EthereumAddress("0xb6542DE25941D3ca4Eb839F6C9096823e09Ab5B4"))
            stakes.call(withClient: environment.client,
                        responseType: StakeCount_Parameter.Response.self) { (error, response) in
                switch error {
                case let .some(err):
                    print(err)
                case .none:
                    switch response?.stakeCount {
                    case let .some(count):
                        let stakes = (0..<count).map { BigUInt($0) }
                        environment.mainQueue.schedule {
                            completion(.success(.updateStakeIDs(stakes)))
                        }
                    case .none:
                        print("no stakes")
                    }
                }
            }
        }
        
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
                        let dailyDataList = list.map { dayData -> DailyData in
                            var dailyData = dayData
                            let payout = dailyData & Constant.HEARTS_MASK
                            dailyData >>= Constant.HEARTS_UINT_SHIFT
                            let shares = dailyData & Constant.HEARTS_MASK
                            dailyData >>= Constant.HEARTS_UINT_SHIFT
                            let sats = dailyData & Constant.SATS_MASK
                            
                            return DailyData(payout: payout,
                                      shares: shares,
                                      sats: sats)
                        }

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
        
    case let .updateHexPrice(hexPrice):
        state.hexPrice = hexPrice.hexUsd
        return .none
        
    case let .updateDailyData(dailyData):
        state.dailyDataList = dailyData
        return .none
        
    case .form(\.selectedTab):
        switch state.selectedTab {
        case .charts:
            print("show charts")
        case .stakes:
            return Effect(value: .getStakes)
            
        case .calculator:
            print("show calculator")
        }
        return .none
        
    case .form:
        return .none
    }
}
    .binding(action: /AppAction.form)


