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
                                } label: { Label("Accounts", systemImage: "person.fill") }
                            }

                            Section {
                                Picker(selection: viewStore.binding(\.$creditCardUnits).animation(),
                                       content: {
                                    ForEach(CreditCardUnits.allCases) { creditCardUnit in
                                        creditCardUnit.label.tag(creditCardUnit)
                                    }
                                }, label: {
                                    viewStore.creditCardUnits.label
                                })
                                .pickerStyle(MenuPickerStyle())

                                Picker(selection: viewStore.binding(\.$payPeriod).animation(),
                                       content: {
                                    ForEach(PayPeriod.allCases) { payPeriod in
                                        payPeriod.label.tag(payPeriod)
                                    }
                                }, label: {
                                    viewStore.payPeriod.label
                                })
                                .pickerStyle(MenuPickerStyle())
                            }

                            Section {
                                Toggle("Speculate",
                                       isOn: viewStore.binding(\.$shouldSpeculate).animation())
                                Button {
                                    viewStore.send(.binding(.set(\.$modalPresent, .speculate)))
                                } label: { Label("Edit • \(viewStore.speculativePrice.currencyString())",
                                                 systemImage: "square.and.pencil") }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        switch viewStore.accounts.isEmpty {
                        case false:
//                            if let ethData = viewStore.hexContractOnChain.data[.ethereum],
//                               viewStore.accounts[id: viewStore.selectedId]?.account.chain != .pulse {
//
//                                switch viewStore.shouldSpeculate {
//                                case true: toolbarText(heading: ethData.speculativePrice.currencyString() + "*",
//                                                       subheading: "Price",
//                                                       image: Chain.ethereum.image)
//                                case false: toolbarText(heading: ethData.price.currencyString(),
//                                                        subheading: "Price",
//                                                        image: Chain.ethereum.image)
//                                }
//                            }
//
//                            if let plsData = viewStore.hexContractOnChain.data[.pulse],
//                               viewStore.accounts[id: viewStore.selectedId]?.account.chain != .ethereum {
//
//                                switch viewStore.shouldSpeculate {
//                                case true: toolbarText(heading: plsData.speculativePrice.currencyString() + "*",
//                                                       subheading: "Price",
//                                                       image: Chain.pulse.image)
//                                case false: toolbarText(heading: plsData.price.currencyString(),
//                                                        subheading: "Price",
//                                                        image: Chain.pulse.image)
//                                }
//                            }
                            toolbarText(heading: viewStore.hexContractOnChain.data[.ethereum]?.currentDay.advanced(by: 1).description ?? "0",
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
            switch (viewStore.accounts.isEmpty,
                    viewStore.favoriteAccounts.accounts.isEmpty,
                    viewStore.accounts[id: viewStore.selectedId])
            {
            case (false, true, let .some(account)),
                (false, false, let .some(account)):
                ForEach(account.stakes) { stake in
                    StakeDetailsCardView(price: price(on: account.chain),
                                         stake: stake,
                                         account: account)
                }
            case (false, false, .none):
                ForEach(viewStore.favoriteAccounts.totalAccountStakes) { stake in
                    StakeDetailsCardView(price: price(on: stake.account.chain),
                                         stake: stake.stake,
                                         account: stake.account)
                }
            default:
                EmptyView()
            }
        }
    }
    
    private var accountHeader: some View {
        WithViewStore(store) { viewStore in
            switch (viewStore.accounts.isEmpty, viewStore.favoriteAccounts.accounts.isEmpty) {
            case (false, false):
                TabView(selection: viewStore.binding(\.$selectedId).animation()) {
                    FavoritesStakeCreditCardView(store: store,
                                                 favoriteAccounts: viewStore.favoriteAccounts)
                    .padding([.horizontal, .top])
                    .padding(.bottom, k.CARD_PADDING_BOTTOM)
                    .tag(viewStore.favoriteAccounts.id)
                    ForEach(viewStore.accounts) { account in
                        StakeCreditCardView(store: store,
                                            account: .constant(account))
                        .padding([.horizontal, .top])
                        .padding(.bottom, k.CARD_PADDING_BOTTOM)
                        .tag(account.id)
                    }
                }
                .frame(height: ((UIScreen.main.bounds.width) / 1.586) + k.CARD_PADDING_BOTTOM + k.CARD_PADDING_DEFAULT)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .background(LinearGradient(stops: k.ACCOUNT_CARD_BACKGROUND_GRADIENT_STOPS,
                                           startPoint: .top, endPoint: .bottom))
                .overlay(FavoriteDotsIndexView(store: store))
            case (false, true):
                TabView(selection: viewStore.binding(\.$selectedId).animation()) {
                    ForEach(viewStore.accounts) { account in
                        StakeCreditCardView(store: store,
                                            account: .constant(account))
                        .padding([.horizontal, .top])
                        .padding(.bottom, k.CARD_PADDING_BOTTOM)
                        .tag(account.id)
                    }
                }
                .frame(height: ((UIScreen.main.bounds.width) / 1.586) + k.CARD_PADDING_BOTTOM + k.CARD_PADDING_DEFAULT)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .background(LinearGradient(stops: k.ACCOUNT_CARD_BACKGROUND_GRADIENT_STOPS,
                                           startPoint: .top,
                                           endPoint: .bottom))
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
        let chainPrice: Double = viewStore.hexContractOnChain.data[chain]?.price.doubleValue ?? 0.0
        return viewStore.shouldSpeculate ? viewStore.speculativePrice.doubleValue : chainPrice
    }
    
    func toolbarText(heading: String, subheading: String, image: Image? = nil) -> some View {
        VStack(spacing: 0) {
            Text(heading).font(.caption.monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            switch image {
            case let .some(image):
                HStack(spacing: 4) {
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 8)
                    Text(subheading).font(.caption2.monospaced())
                }.padding(0)
                    .foregroundColor(.secondary)
            case .none:
                Text(subheading).font(.caption2.monospaced()).foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: 96)
    }
}

#if DEBUG
struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView(store: sampleAppStore)
    }
}
#endif
