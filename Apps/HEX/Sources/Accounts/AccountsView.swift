// AccountsView.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import ComposableArchitecture
import SwiftUI
import SwiftUIVisualEffects

struct AccountsView: View {
    let store: Store<AppState, AppAction>
    let columns = [
        GridItem(.flexible()),
        GridItem(.fixed(92)),
    ]

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ScrollView {
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        Section {
                            accountList
                        } header: {
                            accountHeader
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationBarTitle("Accounts")
                .sheet(isPresented: viewStore.binding(\.$presentEditAddress), content: {
                    EditAddressView(store: store)
                })
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.binding(.set(\.$presentEditAddress, true)))
                        } label: { Image(systemName: "person") }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {} label: { Image(systemName: "arrow.up.arrow.down") }
                    }
                }
            }
        }
    }

    var accountList: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.accounts.isEmpty {
            case false:
                ForEach(viewStore.accounts[viewStore.selectedIndex].stakes) { stake in
                    StakeDetailsCardView(stake: stake,
                                         account: viewStore.accounts[viewStore.selectedIndex])
                }
            case true:
                EmptyView()
            }
        }
    }

    var accountHeader: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.accounts.isEmpty {
            case false:
                TabView(selection: viewStore.binding(\.$selectedIndex)) {
                    ForEach(Array(viewStore.accounts.enumerated()), id: \.element) { index, account in
                        StakeCardView(account: account)
                            .padding(.horizontal)
                            .padding(.top, k.CARD_PADDING_TOP)
                            .padding(.bottom, k.CARD_PADDING_BOTTOM)
                            .tag(index)
                    }
                }
                .frame(height: ((UIScreen.main.bounds.width) / 1.586) + k.CARD_PADDING_BOTTOM + k.CARD_PADDING_TOP)
                .tabViewStyle(PageTabViewStyle())
            case true:
                EmptyView()
            }
        }
    }
}

#if DEBUG
    struct AccountsView_Previews: PreviewProvider {
        static var previews: some View {
            AccountsView(store: sampleAppStore)
        }
    }
#endif
