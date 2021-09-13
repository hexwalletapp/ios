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
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
    ]
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    Spacer(minLength: 1)
                    switch viewStore.selectedStakeSegment {
                    case .total:
                        ScrollView {
                            LazyVStack(spacing: 1, pinnedViews: [.sectionHeaders]) {
                                Section {
                                    stakeHeaderView(total: viewStore.total)
                                } header: {
                                    stakeFilterView
                                }
                            }
                        }
                        .background(Color(.systemGroupedBackground))
                    case .list:
                        ScrollView {
                            LazyVStack(spacing: 1, pinnedViews: [.sectionHeaders]) {
                                Section {
                                    ForEach(viewStore.stakes) { stake in
                                        NavigationLink {
                                            Text("hi")
                                        } label: {
                                            stakeView(stake: stake)
                                        }
                                    }
                                } header: {
                                    stakeFilterView
                                }
                            }
                        }
                        .background(Color(.systemGroupedBackground))
                    }
                    Spacer(minLength: 1)
                }
                
                //                .refreshable {
                //                    viewStore.send(.getStakes)
                //                }
                .navigationTitle("Stakes")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {} label: { Image(systemName: "person.crop.circle.badge.plus") }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {} label: { Image(systemName: "arrow.up.arrow.down") }
                        .disabled(viewStore.selectedStakeSegment == .total)
                    }
                }
            }
        }
    }
    
    func stakeView(stake: StakeLists_Parameter.Response) -> some View {
        LazyVGrid(columns: columns, alignment: .trailing, spacing: 1) {
            VStack(alignment: .trailing) {
                Text(stake.stakedHearts.hexAt(price: ViewStore(store).hexPrice).currencyString).foregroundColor(.primary)
                Text(stake.stakedHearts.hex.hexString).foregroundColor(.secondary)
            }
            VStack(alignment: .trailing) {
                Text( stake.stakeShares.tShares.tshareString).foregroundColor(.primary)
                Text("-").foregroundColor(.secondary)
            }
        }
        .padding(4)
        .background(.background)
        .font(.body.monospacedDigit())
    }
    
    func stakeHeaderView(total: StakeTotal) -> some View {
        LazyVGrid(columns: columns, alignment: .trailing, spacing: 1) {
            dataCardHearts(title: "7-Day Average Earnings", hearts: total.interestSevenDayHearts)
            dataCardHearts(title: "HEX Staked", hearts: total.stakeHearts)
            dataCardHearts(title: "HEX Locked", hearts: total.stakeHearts + total.interestHearts)
            dataCardHearts(title: "HEX Earned", hearts: total.interestHearts)
            dataCardShares(title: "T-Shares", shares: total.stakeShares)
        }
        .font(.body.monospacedDigit())
        .padding(.horizontal, 1)
    }
    
    func dataCardHearts(title: String, hearts: BigUInt) -> some View {
        VStack(alignment: .trailing,  spacing: 4) {
            HStack {
                Text(title).font(.caption).foregroundColor(.secondary)
                Spacer()
            }
            Text(hearts.hexAt(price: ViewStore(store).hexPrice).currencyString).foregroundColor(.primary)
            Text(hearts.hex.hexString).foregroundColor(.secondary)
        }
        .padding(4)
        .background(.background)
        
    }
    
    func dataCardShares(title: String, shares: BigUInt) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack {
                Text(title).font(.caption).foregroundColor(.secondary)
                Spacer()
            }
            Text(shares.tShares.tshareString).foregroundColor(.primary)
            Text("-").foregroundColor(.secondary)
        }
        .padding(4)
        .background(.background)
        .font(.body.monospacedDigit())
    }
    
    
    
    var stakeFilterView: some View {
        Picker("Select stake filter",
               selection: ViewStore(store).binding(keyPath: \.selectedStakeSegment, send: AppAction.form)) {
            ForEach(StakeFilter.allCases, id: \.self) { stakeFilter in
                Text(stakeFilter.description).tag(stakeFilter)
            }
        }
               .pickerStyle(.segmented)
               .padding()
               .background(Color(.systemBackground))
    }
}

struct StakesView_Previews: PreviewProvider {
    static var previews: some View {
        StakesView(store: sampleAppStore)
    }
}
