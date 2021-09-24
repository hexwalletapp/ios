//
//  StakesView.swift
//  StakesView
//
//  Created by Joe Blau on 9/4/21.
//

import SwiftUI
import ComposableArchitecture
import BigInt

struct StakesView: View {
    let store: Store<AppState, AppAction>
    let columns = [
        GridItem(.flexible()),
        GridItem(.fixed(92)),
    ]
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    switch viewStore.selectedStakeSegment {
                    case .total:
                        HStack {
                            Text("Price:")
                            Spacer()
                            Text(NSNumber(value: viewStore.hexPrice).currencyString)
                        }
                        .navigationBarTitle(StakeFilter.total.description)
                        dataCardHearts(title: "7-Day Average Earnings", hearts: viewStore.total.interestSevenDayHearts)
                        dataCardHearts(title: "HEX Staked", hearts: viewStore.total.stakeHearts)
                        dataCardHearts(title: "HEX Locked", hearts: viewStore.total.stakeHearts + viewStore.total.interestHearts)
                        dataCardHearts(title: "HEX Earned", hearts: viewStore.total.interestHearts)
                        dataCardShares(title: "Shares", shares: viewStore.total.stakeShares)
                        
                    case .list:
                        ForEach(viewStore.stakes) { stake in
                            NavigationLink {
                                StakeDetailsView(stake: stake)
                            } label: {
                                stakeView(stake: stake)
                            }
                        }
                        .navigationBarTitle(StakeFilter.list.description)
                    }
                }
                .sheet(isPresented: viewStore.$presentEditAddress, content: {
                    EditAddressView(store: store)
                })
                .refreshable { viewStore.send(.getStakes) }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.binding(.set(\.$presentEditAddress, true)))
                        } label: { Image(systemName: "person.crop.circle.badge.plus") }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {} label: { Image(systemName: "arrow.up.arrow.down") }
                        .disabled(viewStore.selectedStakeSegment == .total)
                    }
                    
                    ToolbarItemGroup(placement: .principal) {
                        stakeFilterView
                    }
                }
            }
        }
    }
    
    func stakeView(stake: Stake) -> some View {
        LazyVGrid(columns: columns, alignment: .trailing) {
            VStack(alignment: .trailing) {
                Text(stake.stakedHearts.hexAt(price: ViewStore(store).hexPrice).currencyString).foregroundColor(.primary)
                Text(stake.stakedHearts.hex.hexString).foregroundColor(.secondary)
            }
            Text(stake.stakeShares.number.shareString).font(.caption).foregroundColor(.secondary)
        }
        .font(.body.monospacedDigit())
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    func dataCardHearts(title: String, hearts: BigUInt) -> some View {
        Section {
            VStack(alignment: .trailing) {
                Text(hearts.hexAt(price: ViewStore(store).hexPrice).currencyString).foregroundColor(.primary)
                Text(hearts.hex.hexString).foregroundColor(.secondary)
            }
            .font(.body.monospacedDigit())
            .frame(maxWidth: .infinity, alignment: .trailing)
        } header: {
            Text(title)
        }
    }
    
    func dataCardShares(title: String, shares: BigUInt) -> some View {
        Section {
            VStack(alignment: .trailing) {
                Text(shares.number.shareString).foregroundColor(.primary)
            }
            .font(.body.monospacedDigit())
            .frame(maxWidth: .infinity, alignment: .trailing)
        } header: {
            Text(title)
        }
    }
    
    var stakeFilterView: some View {
        Picker("Select stake filter",
               selection: ViewStore(store).$selectedStakeSegment) {
            ForEach(StakeFilter.allCases, id: \.self) { stakeFilter in
                Text(stakeFilter.description).tag(stakeFilter)
            }
        }
               .pickerStyle(.segmented)
    }
}

#if DEBUG
struct StakesView_Previews: PreviewProvider {
    static var previews: some View {
        StakesView(store: sampleAppStore)
    }
}
#endif
