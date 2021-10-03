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
                .sheet(item: viewStore.binding(\.$accountPresent), content: { accountPresent in
                    switch accountPresent {
                    case .edit: EditView(store: store)
                    case .speculate: SpeculateView(store: store,
                                                   price: viewStore.speculativePrice.currencyNumberString)
                    }
                })
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.binding(.set(\.$accountPresent, .edit)))
                        } label: { Image(systemName: "person") }

                        toolbarText(heading: viewStore.currentDay.advanced(by: 1).description, subheading: "Day")
                        toolbarText(heading: viewStore.price.currencyString + (viewStore.shouldSpeculate ? "*" : ""), subheading: "Price")
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Menu(content: {
                            Section {
                                Toggle("Speculate", isOn: viewStore.binding(\.$shouldSpeculate))
                            }
                            Section {
                                Button {
                                    viewStore.send(.binding(.set(\.$accountPresent, .speculate)))
                                } label: { Label("Edit • \(viewStore.speculativePrice.currencyString)",
                                                 systemImage: "square.and.pencil") }
                            }
                        }, label: { Image(systemName: "dollarsign.circle") })

                        Button {} label: { Image(systemName: "bell.badge") }
                            .disabled(true)

                        Button {} label: { Image(systemName: "arrow.up.arrow.down") }
                            .disabled(true)
                    }
                }
            }
        }
    }

    func toolbarText(heading: String, subheading: String) -> some View {
        VStack {
            Text(heading).font(.caption.monospacedDigit())
            Text(subheading).font(.caption2.monospaced()).foregroundColor(.secondary)
        }
    }

    var accountList: some View {
        WithViewStore(store) { viewStore in
            switch (viewStore.accountsData.isEmpty, viewStore.accountsData[id: viewStore.selectedId]) {
            case (false, let .some(accountData)):
                ForEach(accountData.stakes) { stake in
                    StakeDetailsCardView(price: viewStore.price,
                                         stake: stake,
                                         account: accountData.account)
                }
            default:
                EmptyView()
            }
        }
    }

    var accountHeader: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.accountsData.isEmpty {
            case false:
                TabView(selection: viewStore.binding(\.$selectedId)) {
                    ForEach(viewStore.accountsData) { accountData in
                        StakeCardView(price: viewStore.price,
                                      accountData: accountData)
                            .padding([.horizontal, .top])
                            .padding(.bottom, k.CARD_PADDING_BOTTOM)
                            .tag(accountData.id)
                    }
                }
                .frame(height: ((UIScreen.main.bounds.width) / 1.586) + k.CARD_PADDING_BOTTOM + k.CARD_PADDING_DEFAULT)
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
