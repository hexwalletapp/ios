//
//  CalculatorView.swift
//  CalculatorView
//
//  Created by Joe Blau on 9/4/21.
//

import SwiftUI
import ComposableArchitecture

struct CalculatorView: View {
    var body: some View {
        NavigationView {
            Text("Calculator")
        }
        .navigationTitle("Calculator")
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
