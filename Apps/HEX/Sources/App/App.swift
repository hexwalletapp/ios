// App.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import SwiftUI
import GRDB

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
            let dbQueue: DatabaseQueue
            do {
                let fileManager = FileManager()
                let folderURL = try fileManager
                    .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    .appendingPathComponent("database", isDirectory: true)
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
                
                let dbURL = folderURL.appendingPathComponent("db.sqlite")
                dbQueue = try DatabaseQueue(path: dbURL.path)
                
            } catch {
                fatalError(error.localizedDescription)
            }
            
            store = Store(initialState: AppState(),
                          reducer: appReducer,
                          environment: AppEnvironment(
                            hexManager: .live,
                            hedronManager: .live,
                            uniswapManager: .live,
                            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                            dbQueue: dbQueue
                          ))
            
            super.init()
            ViewStore(store).send(.applicationDidFinishLaunching)
            UITextField.appearance().clearButtonMode = .whileEditing
        }
    }
}
