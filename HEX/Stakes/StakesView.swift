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
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    ForEach(viewStore.stakes) { stake in
                        Text("Result:")
                    }
                }
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
}

struct StakesView_Previews: PreviewProvider {
    static var previews: some View {
        StakesView(store: sampleAppStore)
    }
}
