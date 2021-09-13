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
                ScrollView {
                    stakeHeaderView(totals: viewStore.totals)
                    ForEach(viewStore.stakes) { stake in
                        NavigationLink {
                            Text("hi")
                        } label: {
                            stakeView(stake: stake)
                        }
                    }
                }

                //                .refreshable {
                //                    viewStore.send(.getStakes)
                //                }
                .navigationTitle("Stakes")
                .toolbar {
                    Button {
                        print("add address")
                    } label: {
                        Image(systemName: "person.crop.circle.badge.plus")
                    }
                }
            }
        }
    }
    
    func stakeView(stake: StakeLists_Parameter.Response) -> some View {
        LazyVGrid(columns: columns, alignment: .trailing, spacing: 8) {
            Text( stake.stakedHearts.hexAt(price: ViewStore(store).hexPrice).currency).foregroundColor(.primary)
            Text( stake.stakeShares.tShares.tshares).foregroundColor(.primary)
            Text( stake.stakedHearts.hex.hex).foregroundColor(.secondary)
            Text("")
        }
        .font(.body.monospacedDigit())
        .padding(.horizontal)
    }
    
    func stakeHeaderView(totals: StakeTotals) -> some View {
        LazyVGrid(columns: columns, alignment: .trailing, spacing: 8) {
            Text("$10,000/day")
        }
        .font(.body.monospacedDigit())
        .padding(.horizontal)
    }
}

struct StakesView_Previews: PreviewProvider {
    static var previews: some View {
        StakesView(store: sampleAppStore)
    }
}
