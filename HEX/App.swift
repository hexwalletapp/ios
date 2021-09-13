//
//  App.swift
//  HEX
//
//  Created by Joe Blau on 9/4/21.
//

import SwiftUI
import ComposableArchitecture
import web3

@main
struct HEXApp: App {
    let store = Store(initialState: AppState(),
                      reducer: appReducer,
                      environment: AppEnvironment(
                        client: EthereumClient(url: URL(string: "https://mainnet.infura.io/v3/84842078b09946638c03157f83405213")!),
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                      )
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
