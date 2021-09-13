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
    var hexPrice = 0.388328718
    var stakeCount = 0
    var stakes = [StakeLists_Parameter.Response]()
    var total = StakeTotal()
}

enum AppAction: Equatable {
    case onBackground
    case onInactive
    case onActive
    case getStakes
    case updateStakeIDs([BigUInt])
    case updateStake(StakeLists_Parameter.Response)
    case updateHexPrice(HEXPrice)
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
        return .future { completion in
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
        if state.stakes.count == state.stakeCount {
            state.total.stakeHearts = state.stakes.reduce(0, { $0 + $1.stakedHearts })
            state.total.stakeShares = state.stakes.reduce(0, { $0 + $1.stakeShares })
        }
        
        return .none
        
    case .getStakes:
        return .future { result in
            let getStakes = StakeCount_Parameter(stakeAddress: EthereumAddress("0xb6542DE25941D3ca4Eb839F6C9096823e09Ab5B4"))
            getStakes.call(withClient: environment.client,
                           responseType: StakeCount_Parameter.Response.self) { (error, response) in
                switch error {
                case let .some(err):
                    print(err)
                case .none:
                    switch response?.stakeCount {
                    case let .some(count):
                        let stakes = (0..<count).map { BigUInt($0) }
                        environment.mainQueue.schedule {
                            result(.success(.updateStakeIDs(stakes)))
                        }
                    case .none:
                        print("no stakes")
                    }
                }
            }
        }
        
    case let .updateHexPrice(hexPrice):
        state.hexPrice = hexPrice.hexUsd
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


