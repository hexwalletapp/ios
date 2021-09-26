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

struct StakesView: View {
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
                                stakeView(stake: stake)
                            }
                        } header: {
                            
                            TabView() {
                                StakeCardView(store: store)
                                    .padding()
                            }
                            .frame(height: ((UIScreen.main.bounds.width) / 1.586) )
                            .tabViewStyle(PageTabViewStyle())
                        }
                    }
                }
                .background(Color(.systemGroupedBackground)).edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle("Accounts")
                .sheet(isPresented: viewStore.$presentEditAddress, content: {
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
    
    func stakeView(stake: Stake) -> some View {
        GroupBox {
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(stake.stakedHearts.hexAt(price: ViewStore(store).hexPrice).currencyStringSuffix).foregroundColor(.primary)
                    Text(stake.stakedHearts.hex.hexString).foregroundColor(.secondary)
                }
            }
            .font(.body.monospacedDigit())
        } label: {
            Label("Staked \(stake.stakedDays) Days", systemImage: "calendar")
        }
        .padding()
        .groupBoxStyle(StakeGroupBoxStyle(color: .primary, destination: Text("Heart rate")))
    }
}

#if DEBUG
struct StakesView_Previews: PreviewProvider {
    static var previews: some View {
        StakesView(store: sampleAppStore)
    }
}
#endif
