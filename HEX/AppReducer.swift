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


struct AppState: Equatable {
    var selectedTab = Tab.charts
    var stakes = [StakeLists_Parameter.Respone]()
}

enum AppAction: Equatable {
    case updateStakeIDs([BigUInt])
    case updateStake(StakeLists_Parameter.Respone)
    case form(BindingAction<AppState>)
}

struct AppEnvironment {
    let client: EthereumClient
    var mainQueue: AnySchedulerOf<DispatchQueue>

}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case let .updateStakeIDs(stakeIDs):
        state.stakes = [StakeLists_Parameter.Respone]()
        return .merge(
            stakeIDs.map { stakeID in
                return .future { completion in
                    let getStake = StakeLists_Parameter(stakeAddress: EthereumAddress("***REMOVED***"),
                                                        stakeIndex: stakeID)
                    getStake.call(withClient: environment.client,
                                  responseType: StakeLists_Parameter.Respone.self) { (error, response) in
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
        
    case .form(\.selectedTab):
        switch state.selectedTab {
        case .charts:
            print("show charts")
        case .stakes:
            
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
                            result(.success(.updateStakeIDs(stakes)))
                        case .none:
                            print("no stakes")
                        }
                    }
                }
            }

        case .calculator:
            print("show calculator")
        }
        return .none
    
    case .form:
        return .none
    }
}
    .binding(action: /AppAction.form)
