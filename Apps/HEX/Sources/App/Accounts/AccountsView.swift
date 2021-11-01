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
                .sheet(item: viewStore.binding(\.$accountPresent), content: { accountPresent in
                    switch accountPresent {
                    case .edit: EditView(store: store)
                    case .speculate: SpeculateView(store: store,
                                                   price: viewStore.speculativePrice.currencyNumberString)
                    }
                })
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Menu {
                            Section {
                                Button {
                                    viewStore.send(.binding(.set(\.$accountPresent, .edit)))
                                } label: { Label("Accounts", systemImage: "person") }
                            }

                            Section {
                                Toggle("Speculate", isOn: viewStore.binding(\.$shouldSpeculate))
                                Button {
                                    viewStore.send(.binding(.set(\.$accountPresent, .speculate)))
                                } label: { Label("Edit • \(viewStore.speculativePrice.currencyString)",
                                                 systemImage: "square.and.pencil") }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        toolbarText(heading: viewStore.currentDay.advanced(by: 1).description, subheading: "Day")
                        toolbarText(heading: viewStore.price.currencyString + (viewStore.shouldSpeculate ? "*" : ""), subheading: "Price")

//                        Button {} label: { Image(systemName: "bell.badge") }
//                            .disabled(true)
//
//                        Button {} label: { Image(systemName: "arrow.up.arrow.down") }
//                            .disabled(true)
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
                .background(LinearGradient(stops: k.ACCOUNT_CARD_BACKGROUND_GRADIENT_STOPS, startPoint: .top, endPoint: .bottom))
            case true:
                VStack {
                    Spacer(minLength: 200)
                    Button {
                        viewStore.send(.binding(.set(\.$accountPresent, .edit)))
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
