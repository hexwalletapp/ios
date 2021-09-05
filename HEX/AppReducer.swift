//
//  HEXAppReducer.swift
//  HEXAppReducer
//
//  Created by Joe Blau on 9/4/21.
//

import Foundation
import ComposableArchitecture
import web3

enum Tab: Int, Equatable  {
    case charts = 0
    case stakes = 1
    case calculator = 2
}

struct AppState: Equatable {
    var selectedTab = Tab.charts
}

enum AppAction: Equatable {
    case form(BindingAction<AppState>)
}

struct AppEnvironment {
    let client: EthereumClient
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .form(\.selectedTab):
        switch state.selectedTab {
        case .charts:
            print("show charts")
        case .stakes:
            print("show stakes")
            
            let getStakes = StakeCount_Parameter(stakeAddress: EthereumAddress("***REMOVED***"))
             
            getStakes.call(withClient: environment.client,
                           responseType: StakeCount_Parameter.Response.self) { (error, response) in
                switch error {
                case let .some(err):
                    print(err)
                case .none:
                    print("stakes \(response?.stakeCount)")
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
