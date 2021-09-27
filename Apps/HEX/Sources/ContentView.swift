// ContentView.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(\.$selectedTab)) {
                ChartsView()
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("Charts")
                    }
                    .tag(Tab.charts)

                AccountsView(store: store)
                    .tabItem {
                        Image(systemName: "creditcard.fill")
                        Text("Accounts")
                    }
                    .tag(Tab.accounts)

//                CalculatorView()
//                    .tabItem {
//                        Image(systemName: "plus.app.fill")
//                        Text("Calculator")
//                    }
//                    .tag(Tab.calculator)
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
