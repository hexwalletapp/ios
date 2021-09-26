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
                            ForEach(viewStore.stakes) { stake in
                                StakeDetailsCardView(stake: stake,
                                                     hexPrice: ViewStore(store).hexPrice,
                                                     chain: viewStore.selectedChain)
                            }
                        } header: {
                            TabView(selection: viewStore.binding(\.$selectedChain)) {
                                ForEach(Chain.allCases) { chain in
                                    StakeCardView(store: store, chain: chain)
                                        .padding(.horizontal)
                                        .padding(.top, Constant.CARD_PADDING_TOP)
                                        .padding(.bottom, Constant.CARD_PADDING_BOTTOM)
                                        .tag(chain)
                                }
                            }
                            .frame(height: ((UIScreen.main.bounds.width) / 1.586) + Constant.CARD_PADDING_BOTTOM + Constant.CARD_PADDING_TOP)
                            .tabViewStyle(PageTabViewStyle())
                        }
                    }
                }
                .background(Color(.systemGroupedBackground)).edgesIgnoringSafeArea(.bottom)
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
}

#if DEBUG
struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView(store: sampleAppStore)
    }
}
#endif
