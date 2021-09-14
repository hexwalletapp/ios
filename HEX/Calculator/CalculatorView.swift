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
                TextField("HEX Stake Amount", text: $stakeAmount, prompt: Text("HEX Stake Amount"))
                    .submitLabel(.next)
                    .disableAutocorrection(true)
                    .keyboardType(.numberPad)
                
                TextField("# of Days (1-5555)", text: $numberOfDays, prompt: Text("Number of Days (1-5555)"))
                    .submitLabel(.go)
                    .disableAutocorrection(true)
                    .keyboardType(.numberPad)
                
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
