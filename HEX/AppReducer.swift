//
//  HEXAppReducer.swift
//  HEXAppReducer
//
//  Created by Joe Blau on 9/4/21.
//

import Foundation
import ComposableArchitecture

enum Tab {
    case charts
    case stakes
    case calculator
}

struct AppState: Equatable {
    var selectedTab: Tab = .charts
}

enum AppAction: Equatable {
    
    case form(BindingAction<AppState>)
}

struct AppEnvironment {}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { _, _, _ in
    return .none
}
