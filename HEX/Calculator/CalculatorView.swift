//
//  CalculatorView.swift
//  CalculatorView
//
//  Created by Joe Blau on 9/4/21.
//

import SwiftUI
import ComposableArchitecture

struct CalculatorView: View {
    @State var stakeAmount: String = ""
    @State var numberOfDays: String = ""
    var body: some View {
        NavigationView {
            Form {                
                Button {
                    UIApplication.shared.keyWindow?.endEditing(true)
                } label: {
                    Text("Calculate")
                }
            }
            .navigationTitle("Calculator")
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
