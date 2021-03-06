// AppView.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(\.$selectedTab)) {
                AccountsView(store: store)
                    .tabItem {
                        Image(systemName: "creditcard.fill")
                        Text("Accounts")
                    }
                    .tag(Tab.accounts)

                PlanView(store: store)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Plan")
                    }
                    .tag(Tab.calculator)
            }
            .preferredColorScheme(viewStore.colorScheme)
            .sheet(item: viewStore.binding(\.$modalPresent), content: { modalPresent in
                switch modalPresent {
                case .edit: EditView(store: store)
                case .speculate: SpeculateView(store: store,
                                               price: viewStore.speculativePrice.doubleValue)
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
