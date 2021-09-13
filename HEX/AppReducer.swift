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

struct StakeTotals: Equatable {
    var tShares: BigUInt = 0
    var hex: BigUInt = 0
}

struct AppState: Equatable {
    var selectedTab = Tab.charts
    var hexPrice = 0.388328718
    var stakeCount = 0
    var stakes = [StakeLists_Parameter.Response]()
    var totals = StakeTotals()
}

enum AppAction: Equatable {
    case getStakes
    case updateStakeIDs([BigUInt])
    case updateStake(StakeLists_Parameter.Response)
    case form(BindingAction<AppState>)
}

struct AppEnvironment {
    let client: EthereumClient
    var mainQueue: AnySchedulerOf<DispatchQueue>

}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case let .updateStakeIDs(stakeIDs):
        state.stakeCount = stakeIDs.count
        state.stakes = [StakeLists_Parameter.Response]()
        return .merge(
            stakeIDs.map { stakeID in
                return .future { completion in
                    let getStake = StakeLists_Parameter(stakeAddress: EthereumAddress("***REMOVED***"),
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
        return .none
        
    case .getStakes:
        return .future { result in
            let getStakes = StakeCount_Parameter(stakeAddress: EthereumAddress("***REMOVED***"))
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
