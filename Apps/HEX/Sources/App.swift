// App.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import SwiftUI
import web3

@main
struct HEXApp: App {
    @Environment(\.scenePhase) private var scenePhase

    let store = Store(initialState: AppState(),
                      reducer: appReducer,
                      environment: AppEnvironment(
                          client: EthereumClient(url: URL(string: "https://mainnet.infura.io/v3/84842078b09946638c03157f83405213")!),
                          mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                      ))

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                ViewStore(store).send(.onBackground)
            case .inactive:
                ViewStore(store).send(.onInactive)
            case .active:
                ViewStore(store).send(.onActive)
            @unknown default:
                fatalError("invalid scene phase")
            }
        }
    }
}
