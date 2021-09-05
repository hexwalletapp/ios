//
//  StakesView.swift
//  StakesView
//
//  Created by Joe Blau on 9/4/21.
//

import SwiftUI
import ComposableArchitecture

struct StakesView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Stakes")
                    .badge(10)
                Text("Stakes")
                Text("Stakes")
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

struct StakesView_Previews: PreviewProvider {
    static var previews: some View {
        StakesView()
    }
}
