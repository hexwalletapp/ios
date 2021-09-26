//
//  StakesView.swift
//  StakesView
//
//  Created by Joe Blau on 9/4/21.
//

import SwiftUI
import ComposableArchitecture
import BigInt
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
                //.edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle("Accounts")
                .sheet(isPresented: viewStore.binding(\.$presentEditAddress), content: {
                    EditAddressView(store: store)
                })
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.binding(.set(\.$presentEditAddress, true)))
                        } label: { Image(systemName: "person.crop.circle.badge.plus") }
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
            switch viewStore.selectedAccount {
            case let .some(selectedAccount):
                ForEach(selectedAccount.stakes) { stake in
                    StakeDetailsCardView(stake: stake,
                                         account: selectedAccount)
                }
            case .none:
                EmptyView()
            }
        }
    }
    
    var accountHeader: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.accounts {
            case let .some(accounts):
                TabView(selection: viewStore.binding(\.$selectedAccount)) {
                    ForEach(accounts) { account in
                        StakeCardView(account: account)
                            .padding(.horizontal)
                            .padding(.top, Constant.CARD_PADDING_TOP)
                            .padding(.bottom, Constant.CARD_PADDING_BOTTOM)
                            .tag(account)
                    }
                }
                .frame(height: ((UIScreen.main.bounds.width) / 1.586) + Constant.CARD_PADDING_BOTTOM + Constant.CARD_PADDING_TOP)
                .tabViewStyle(PageTabViewStyle())
            case .none:
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
