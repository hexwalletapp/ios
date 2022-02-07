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

                                Picker(selection: viewStore.binding(\.$payoutEarnings).animation(),
                                       content: {
                                           ForEach(PayoutEarnings.allCases) { payoutEarning in
                                               payoutEarning.label.tag(payoutEarning)
                                           }
                                       }, label: {
                                           viewStore.payoutEarnings.label
                                       })
                                    .pickerStyle(MenuPickerStyle())
                            }

                            Section {
                                Toggle("Speculate",
                                       isOn: viewStore.binding(\.$shouldSpeculate).animation())
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
                        switch viewStore.accountsData.isEmpty {
                        case false:
                            if viewStore.accountsData[id: viewStore.selectedId]?.account.chain != .pulse {
                                let ethData = viewStore.hexContractOnChain.ethData
                                switch viewStore.shouldSpeculate {
                                case true: toolbarText(heading: ethData.speculativePrice.currencyString + "*",
                                                       subheading: "Price",
                                                       image: Chain.ethereum.image)
                                case false: toolbarText(heading: ethData.price.currencyString,
                                                        subheading: "Price",
                                                        image: Chain.ethereum.image)
                                }
                            }

                            if viewStore.accountsData[id: viewStore.selectedId]?.account.chain != .ethereum {
                                let plsData = viewStore.hexContractOnChain.plsData
                                switch viewStore.shouldSpeculate {
                                case true: toolbarText(heading: plsData.speculativePrice.currencyString + "*",
                                                       subheading: "Price",
                                                       image: Chain.pulse.image)
                                case false: toolbarText(heading: plsData.price.currencyString,
                                                        subheading: "Price",
                                                        image: Chain.pulse.image)
                                }
                            }

                            toolbarText(heading: viewStore.hexContractOnChain.ethData.currentDay.advanced(by: 1).description,
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
                ForEach(viewStore.groupAccountData.totalAccountStakes) { accountStake in
                    StakeDetailsCardView(price: price(on: accountStake.account.chain),
                                         stake: accountStake.stake,
                                         account: accountStake.account)
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
                    FavoritesStakeCreditCardView(store: store,
                                                 groupAccountData: viewStore.groupAccountData)
                        .padding([.horizontal, .top])
                        .padding(.bottom, k.CARD_PADDING_BOTTOM)
                        .tag(viewStore.groupAccountData.id)
                    ForEach(viewStore.accountsData) { accountData in
                        StakeCreditCardView(store: store,
                                            accountData: .constant(accountData))
                            .padding([.horizontal, .top])
                            .padding(.bottom, k.CARD_PADDING_BOTTOM)
                            .tag(accountData.id)
                    }
                }
                .frame(height: ((UIScreen.main.bounds.width) / 1.586) + k.CARD_PADDING_BOTTOM + k.CARD_PADDING_DEFAULT)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .background(LinearGradient(stops: k.ACCOUNT_CARD_BACKGROUND_GRADIENT_STOPS,
                                           startPoint: .top, endPoint: .bottom))
                .overlay(FavoriteDotsIndexView(store: store))
            case (false, true):
                TabView(selection: viewStore.binding(\.$selectedId).animation()) {
                    ForEach(viewStore.accountsData) { accountData in
                        StakeCreditCardView(store: store,
                                            accountData: .constant(accountData))
                            .padding([.horizontal, .top])
                            .padding(.bottom, k.CARD_PADDING_BOTTOM)
                            .tag(accountData.id)
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
        let chainPrice: Double
        switch chain {
        case .ethereum: chainPrice = viewStore.hexContractOnChain.ethData.price.doubleValue
        case .pulse: chainPrice = viewStore.hexContractOnChain.plsData.price.doubleValue
        }
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
