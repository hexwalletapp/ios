// App.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import SwiftUI

@main
struct HEXApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: appDelegate.store)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                ViewStore(appDelegate.store).send(.onBackground)
            case .inactive:
                ViewStore(appDelegate.store).send(.onInactive)
            case .active:
                ViewStore(appDelegate.store).send(.onActive)
            @unknown default:
                fatalError("invalid scene phase")
            }
        }
    }

    class AppDelegate: NSObject, UIApplicationDelegate {
        let store: Store<AppState, AppAction>

        override init() {
            store = Store(initialState: AppState(),
                          reducer: appReducer,
                          environment: AppEnvironment(
                              hexPriceManager: .live,
                              hexManager: .live,
                              hedronManager: .live,
                              mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                          ))

            super.init()
            ViewStore(store).send(.applicationDidFinishLaunching)
            UITextField.appearance().clearButtonMode = .whileEditing
        }
    }
}
