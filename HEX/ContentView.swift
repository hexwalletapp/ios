//
//  ContentView.swift
//  HEX
//
//  Created by Joe Blau on 9/4/21.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(keyPath: \.selectedTab, send: AppAction.form)) {
                Text("The First Tab")
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("Charts")
                    }
                Text("Another Tab")
                    .tabItem {
                        Image(systemName: "banknote.fill")
                        Text("Stakes")
                    }
                Text("The Last Tab")
                    .tabItem {
                        Image(systemName: "plus.app.fill")
                        Text("Calculator")
                    }
            }
        }
    }
}

#if DEBUG

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: sampleAppStore)
    }
}

#endif
