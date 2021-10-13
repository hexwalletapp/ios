// AppView.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(\.$selectedTab)) {
//                ChartsView(store: store)
                TradingviewChartView()
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
            }
        }
    }
}

#if DEBUG

    struct AppView_Previews: PreviewProvider {
        static var previews: some View {
            AppView(store: sampleAppStore)
        }
    }

#endif
