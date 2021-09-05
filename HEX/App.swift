//
//  App.swift
//  HEX
//
//  Created by Joe Blau on 9/4/21.
//

import SwiftUI
import ComposableArchitecture

@main
struct HEXApp: App {
    let store = Store(initialState: AppState(),
                      reducer: appReducer,
                      environment: AppEnvironment())
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
