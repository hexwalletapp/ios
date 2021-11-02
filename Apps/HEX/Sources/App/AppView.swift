// AppView.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(\.$selectedTab)) {
                ChartsView(store: store)
//                TradingviewChartView()
                    .tabItem {
                        Image("chart.fill")
                        Text("Chart")
                    }
                    .tag(Tab.charts)

                AccountsView(store: store)
                    .tabItem {
                        Image("accounts.fill")
                        Text("Accounts")
                    }
                    .tag(Tab.accounts)

                CalculatorView(store: store)
                    .tabItem {
                        Image("plan.fill")
                        Text("Plan")
                    }
                    .tag(Tab.plan)
            }
            .sheet(item: viewStore.binding(\.$modalPresent), content: { modalPresent in
                switch modalPresent {
                case .edit: EditView(store: store)
                case .speculate: SpeculateView(store: store,
                                               price: viewStore.speculativePrice.currencyNumberString)
                case .calculator: CalculatorView(store: store)
                }
            })
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
