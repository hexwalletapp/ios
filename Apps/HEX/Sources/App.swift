// App.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import SwiftUI

@main
struct HEXApp: App {
    @Environment(\.scenePhase) private var scenePhase

    let store = Store(initialState: AppState(),
                      reducer: appReducer,
                      environment: AppEnvironment(
                          hexManager: .live,
                          mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                      ))

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
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
