//
//  HEXAppReducer.swift
//  HEXAppReducer
//
//  Created by Joe Blau on 9/4/21.
//

import Foundation
import ComposableArchitecture

struct AppState: Equatable {}

enum AppAction: Equatable {}

struct AppEnvironment {}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { _, _, _ in
    return .none
}
