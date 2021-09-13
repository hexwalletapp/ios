//
//  StakesView.swift
//  StakesView
//
//  Created by Joe Blau on 9/4/21.
//

import SwiftUI
import ComposableArchitecture

struct StakesView: View {
    let store: Store<AppState, AppAction>
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    switch viewStore.selectedStakeSegment {
                    case .total:
                        ScrollView {
                            LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]) {
                                Section {
                                    stakeHeaderView(total: viewStore.total)
                                } header: {
                                    stakeFilterView
                                }
                            }
                        }
                    case .list:
                        ScrollView {
                            LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]) {
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
                    }
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
        LazyVGrid(columns: columns, alignment: .trailing, spacing: 8) {
            Text( stake.stakedHearts.hexAt(price: ViewStore(store).hexPrice).currencyString).foregroundColor(.primary)
            Text( stake.stakeShares.tShares.tshareString).foregroundColor(.primary)
            Text( stake.stakedHearts.hex.hexString).foregroundColor(.secondary)
            Text("")
        }
        .font(.body.monospacedDigit())
        .padding(.horizontal)
    }
    
    func stakeHeaderView(total: StakeTotal) -> some View {
        LazyVGrid(columns: columns, alignment: .trailing, spacing: 8) {
            Text( total.stakeHearts.hexAt(price: ViewStore(store).hexPrice).currencyString).foregroundColor(.primary)
            Text( total.stakeShares.tShares.tshareString).foregroundColor(.primary)
            Text( total.stakeHearts.hex.hexString).foregroundColor(.secondary)
        }
        .font(.body.monospacedDigit())
        .padding(.horizontal)
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
