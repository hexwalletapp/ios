// ChartsView.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import SwiftUI

struct ChartsView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack(spacing: 0) {
                    Picker(selection: viewStore.binding(\.$selectedTimeScale)) {
                        ForEach(TimeScale.allCases) { timeScale in
                            Text(timeScale.description)
                        }
                    } label: {
                        Text("Chain")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top, k.CARD_PADDING_DEFAULT)
                    LightweightChartsView()
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .padding()
                    
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("HEX/USDC")
            }

        }
        
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView(store: sampleAppStore)
    }
}
