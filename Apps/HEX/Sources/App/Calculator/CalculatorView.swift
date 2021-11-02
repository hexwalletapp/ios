//
//  CalculatorView.swift
//  HEX
//
//  Created by Joe Blau on 11/1/21.
//

import SwiftUI
import ComposableArchitecture
import UIKit

struct CalculatorView: View {
    let store: Store<AppState, AppAction>

    let step = 1
    let range = 2...15
        
    var body: some View {
        WithViewStore(store) { viewStore in
            
            NavigationView {
                Form {
                    Section {
                        TextField("Stake Amount", value: viewStore.binding(\.$calculator.stakeAmount), format: .number)
                        .keyboardType(.numberPad)
                        .submitLabel(.next)
                    TextField("Days", value: viewStore.binding(\.$calculator.stakeDays), format: .number)
                        .keyboardType(.numberPad)
                        .submitLabel(.next)
                    TextField("Price Prediction", value: viewStore.binding(\.$calculator.price), format: .number)
                        .keyboardType(.decimalPad)
                        .submitLabel(.done)
                    Toggle("Ladder", isOn: viewStore.binding(\.$calculator.shouldLadder))
                            .disabled(viewStore.calculator.disableForm)
                    }
                    
                    switch viewStore.calculator.shouldLadder {
                    case true:
                        Section {
                            Stepper(value: viewStore.binding(\.$calculator.ladderSteps),
                                    in: range,
                                    step: step) {
                                Text("Stakes: \(viewStore.calculator.ladderSteps)")
                            }
                            Picker(selection: viewStore.binding(\.$calculator.ladderDistribution)) {
                                ForEach(Distribution.allCases) { page in
                                    Text(page.description)
                                }
                            } label: {
                                Text("Distribution")
                            }
                            DatePicker(
                                "Offset Date",
                                selection: viewStore.binding(\.$calculator.ladderStartDateOffset),
                                displayedComponents: [.date]
                            )
                        } header: {
                            Text("Stake Ladder")
                        } footer: {
                            Text("This issa ladder")
                        }
                        
                        
                        Section {
                            ForEach(viewStore.binding(\.$calculator.ladderRungs)) { rung in
                                VStack(spacing: 8) {
                                    DatePicker(
                                        "Stake \(rung.id + 1)",
                                        selection: rung.date,
                                        displayedComponents: [.date]
                                    )
                                    Slider(value: rung.stakePercentage, in: 0...1) {
                                        Text("Stake Percent")
                                    } minimumValueLabel: {
                                        Text("0%")
                                    } maximumValueLabel: {
                                        Text("100%")
                                    }
                                    HStack {
                                        Text(NSNumber(value: rung.stakePercentage.wrappedValue).percentageFractionString)
                                        Spacer()
                                        Text(rung.hearts.wrappedValue.hex.hexString)
                                    }
                                }
                                .padding([.vertical], 12)
                            }
                            
                        } header: {
                            Text("Stakes")
                        } footer: {
                            Text("Your main stake will be divided into these stakes")
                        }
                        
                    case false:
                        EmptyView()
                    }
                    
                    Button {
                        print("here")
                    } label: {
                        HStack {
                            Spacer()
                            Text("Calculate")
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(viewStore.calculator.disableForm ? Color.accentColor.opacity(0.3) : Color.accentColor)
                    .disabled(viewStore.calculator.disableForm)
                }
                .background(Color(.systemGroupedBackground))
                .navigationBarTitle("Calculator", displayMode: .inline)
            }
        }
    }
}

//struct CalculatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalculatorView()
//    }
//}
