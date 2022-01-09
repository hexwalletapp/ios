// AccountsView.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import EVMChain
import SwiftUI
import SwiftUIVisualEffects

struct AccountsView: View {
    let store: Store<AppState, AppAction>
    let columns = [
        GridItem(.flexible()),
        GridItem(.fixed(92)),
    ]

    @State private var favoriteColor = 0

    init(store: Store<AppState, AppAction>) {
        self.store = store
        UIPageControl.appearance().currentPageIndicatorTintColor = .tintColor
        UIPageControl.appearance().pageIndicatorTintColor = .tertiaryLabel
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ScrollView {
                    Section {
                        accountList
                    } header: {
                        accountHeader
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

                                switch viewStore.shouldSpeculate {
                                case true: toolbarText(heading: ethData.speculativePrice.currencyString + "*", subheading: "Price")
                                case false: toolbarText(heading: ethData.price.currencyString, subheading: "Price")
                                }

                                toolbarText(heading: ethData.currentDay.advanced(by: 1).description, subheading: "Day")
                            case .pulse:
                                let plsData = viewStore.hexContractOnChain.plsData

                                switch viewStore.shouldSpeculate {
                                case true: toolbarText(heading: plsData.speculativePrice.currencyString + "*", subheading: "Price")
                                case false: toolbarText(heading: plsData.price.currencyString, subheading: "Price")
                                }

                                toolbarText(heading: plsData.currentDay.advanced(by: 1).description, subheading: "Day")
                            }
                        case (false, .none):
                            let ethData = viewStore.hexContractOnChain.ethData
                            toolbarText(heading: ethData.currentDay.advanced(by: 1).description,
                                        subheading: "Day")
                        default:
                            EmptyView()
                        }
                    }
                }
            }
        }
    }

    private var accountList: some View {
        WithViewStore(store) { viewStore in
            switch (viewStore.accountsData.isEmpty,
                    viewStore.groupAccountData.accountsData.isEmpty,
                    viewStore.accountsData[id: viewStore.selectedId])
            {
            case (false, true, let .some(accountData)),
                 (false, false, let .some(accountData)):
                ForEach(accountData.stakes) { stake in
                    StakeDetailsCardView(price: price(on: accountData.account.chain),
                                         stake: stake,
                                         account: accountData.account)
                }
            case (false, false, .none):
                ForEach(viewStore.groupAccountData.totalAccountStakes, id: \.self.1.stakeId) { accountStake in
                    StakeDetailsCardView(price: price(on: accountStake.0.chain),
                                         stake: accountStake.1,
                                         account: accountStake.0)
                }
            default:
                EmptyView()
            }
        }
    }

    private var accountHeader: some View {
        WithViewStore(store) { viewStore in
            switch (viewStore.accountsData.isEmpty, viewStore.groupAccountData.accountsData.isEmpty) {
            case (false, false):
                TabView(selection: viewStore.binding(\.$selectedId).animation()) {
                    FavoritesStakeCardView(groupAccountData: viewStore.groupAccountData)
                        .padding([.horizontal, .top])
                        .padding(.bottom, k.CARD_PADDING_BOTTOM)
                        .tag(viewStore.groupAccountData.id)
                    ForEach(viewStore.accountsData) { accountData in
                        StakeCardView(price: price(on: accountData.account.chain),
                                      accountData: accountData)
                            .padding([.horizontal, .top])
                            .padding(.bottom, k.CARD_PADDING_BOTTOM)
                            .tag(accountData.id)
                    }
                }
                .frame(height: ((UIScreen.main.bounds.width) / 1.586) + k.CARD_PADDING_BOTTOM + k.CARD_PADDING_DEFAULT)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .background(LinearGradient(stops: k.ACCOUNT_CARD_BACKGROUND_GRADIENT_STOPS, startPoint: .top, endPoint: .bottom))
                .overlay(FavoriteDotsIndexView(store: store))
            case (false, true):
                TabView(selection: viewStore.binding(\.$selectedId).animation()) {
                    ForEach(viewStore.accountsData) { accountData in
                        StakeCardView(price: price(on: accountData.account.chain),
                                      accountData: accountData)
                            .padding([.horizontal, .top])
                            .padding(.bottom, k.CARD_PADDING_BOTTOM)
                            .tag(accountData.id)
                    }
                }
                .frame(height: ((UIScreen.main.bounds.width) / 1.586) + k.CARD_PADDING_BOTTOM + k.CARD_PADDING_DEFAULT)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .background(LinearGradient(stops: k.ACCOUNT_CARD_BACKGROUND_GRADIENT_STOPS, startPoint: .top, endPoint: .bottom))
                .overlay(FavoriteDotsIndexView(store: store))
            default:
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

    func price(on chain: Chain) -> Double {
        let viewStore = ViewStore(store)
        let chainPrice: Double
        switch chain {
        case .ethereum: chainPrice = viewStore.hexContractOnChain.ethData.price.doubleValue
        case .pulse: chainPrice = viewStore.hexContractOnChain.plsData.price.doubleValue
        }
        return viewStore.shouldSpeculate ? viewStore.speculativePrice.doubleValue : chainPrice
    }

    func toolbarText(heading: String, subheading: String) -> some View {
        VStack {
            Text(heading).font(.caption.monospacedDigit())
            Text(subheading).font(.caption2.monospaced()).foregroundColor(.secondary)
        }
        .frame(width: 48)
    }
}

#if DEBUG
    struct AccountsView_Previews: PreviewProvider {
        static var previews: some View {
            AccountsView(store: sampleAppStore)
        }
    }
#endif
