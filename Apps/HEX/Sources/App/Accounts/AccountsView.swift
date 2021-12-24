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

    init(store: Store<AppState, AppAction>) {
        self.store = store
        UIPageControl.appearance().currentPageIndicatorTintColor = .tintColor
        UIPageControl.appearance().pageIndicatorTintColor = .tertiaryLabel
    }

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
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Menu {
                            Section {
                                Button {
                                    viewStore.send(.binding(.set(\.$modalPresent, .edit)))
                                } label: { Label("Accounts", systemImage: "person") }
                            }

                            Section {
                                Toggle("Speculate", isOn: viewStore.binding(\.$shouldSpeculate).animation())
                                Button {
                                    viewStore.send(.binding(.set(\.$modalPresent, .speculate)))
                                } label: { Label("Edit • \(viewStore.speculativePrice.currencyString)",
                                                 systemImage: "square.and.pencil") }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        switch (viewStore.accountsData.isEmpty, viewStore.accountsData[id: viewStore.selectedId]) {
                        case (false, let .some(accountData)):
                            switch accountData.account.chain {
                            case .ethereum:
                                let ethData = viewStore.hexContractOnChain.ethData
                                toolbarText(heading: ethData.currentDay.advanced(by: 1).description, subheading: "Day")

                                switch viewStore.shouldSpeculate {
                                case true: toolbarText(heading: ethData.speculativePrice.currencyString + "*", subheading: "Price")
                                case false: toolbarText(heading: ethData.price.currencyString, subheading: "Price")
                                }

                            case .pulse:
                                let plsData = viewStore.hexContractOnChain.plsData
                                toolbarText(heading: plsData.currentDay.advanced(by: 1).description, subheading: "Day")

                                switch viewStore.shouldSpeculate {
                                case true: toolbarText(heading: plsData.speculativePrice.currencyString + "*", subheading: "Price")
                                case false: toolbarText(heading: plsData.price.currencyString, subheading: "Price")
                                }
                            }
                            //                        Button {} label: { Image(systemName: "bell.badge") }
                            //                            .disabled(true)
                            //
                            //                        Button {} label: { Image(systemName: "arrow.up.arrow.down") }
                            //                            .disabled(true)

                        default:
                            EmptyView()
                        }
                    }
                }
            }
        }
    }

    func toolbarText(heading: String, subheading: String) -> some View {
        VStack {
            Text(heading).font(.caption.monospacedDigit())
            Text(subheading).font(.caption2.monospaced()).foregroundColor(.secondary)
        }.frame(width: 48)
    }

    var accountList: some View {
        WithViewStore(store) { viewStore in
            switch (viewStore.accountsData.isEmpty, viewStore.accountsData[id: viewStore.selectedId]) {
            case (false, let .some(accountData)):
                ForEach(accountData.stakes) { stake in
                    switch accountData.account.chain {
                    case .ethereum:
                        StakeDetailsCardView(price: viewStore.hexContractOnChain.ethData.price,
                                             stake: stake,
                                             account: accountData.account)
                    case .pulse:
                        StakeDetailsCardView(price: viewStore.hexContractOnChain.plsData.price,
                                             stake: stake,
                                             account: accountData.account)
                    }
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
                TabView(selection: viewStore.binding(\.$selectedId).animation()) {
                    ForEach(viewStore.accountsData) { accountData in
                        switch accountData.account.chain {
                        case .ethereum:
                            StakeCardView(price: viewStore.shouldSpeculate ? viewStore.speculativePrice.doubleValue : viewStore.hexContractOnChain.ethData.price.doubleValue,
                                          accountData: accountData)
                                .padding([.horizontal, .top])
                                .padding(.bottom, k.CARD_PADDING_BOTTOM)
                                .tag(accountData.id)
                        case .pulse:
                            StakeCardView(price: viewStore.shouldSpeculate ? viewStore.speculativePrice.doubleValue : viewStore.hexContractOnChain.plsData.price.doubleValue,
                                          accountData: accountData)
                                .padding([.horizontal, .top])
                                .padding(.bottom, k.CARD_PADDING_BOTTOM)
                                .tag(accountData.id)
                        }
                    }
                }
                .frame(height: ((UIScreen.main.bounds.width) / 1.586) + k.CARD_PADDING_BOTTOM + k.CARD_PADDING_DEFAULT)
                .tabViewStyle(PageTabViewStyle())
                .background(LinearGradient(stops: k.ACCOUNT_CARD_BACKGROUND_GRADIENT_STOPS, startPoint: .top, endPoint: .bottom))
            case true:
                VStack {
                    Spacer(minLength: 200)
                    Button {
                        viewStore.send(.binding(.set(\.$modalPresent, .edit)))
                    } label: {
                        VStack(alignment: .center) {
                            Image(systemName: "person.badge.plus").font(.largeTitle)
                            Text("Add").font(.body.monospaced())
                        }
                        .padding()
                    }
                }
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
