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
            Text("Stakes")
        }
        .navigationTitle("Stakes")
    }
}

struct StakesView_Previews: PreviewProvider {
    static var previews: some View {
        StakesView()
    }
}
