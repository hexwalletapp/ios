// AccountsView.swift
// Copyright (c) 2021 Joe Blau

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
                    switch viewStore.accountTypeView {
                    case .individual:
                        IndividualAccountView(store: store)
                    case .group:
                        EmptyView()
                    }

                }
                .background(Color(.systemGroupedBackground))
                .navigationBarTitle(viewStore.accountTypeView.description)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Menu {
                            Section {
                                Button {
                                    viewStore.send(.binding(.set(\.$modalPresent, .edit)))
                                } label: { Label("Accounts", systemImage: "person") }
                                
                                Picker("Account Mode", selection: viewStore.binding(\.$accountTypeView)) {
                                    ForEach(AccountType.allCases) { accountType in
                                        accountType.label.tag(accountType)
                                    }
                                }
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




}

#if DEBUG
    struct AccountsView_Previews: PreviewProvider {
        static var previews: some View {
            AccountsView(store: sampleAppStore)
        }
    }
#endif
