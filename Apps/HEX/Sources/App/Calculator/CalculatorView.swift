// CalculatorView.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import SwiftUI
import UIKit

struct CalculatorView: View {
    let store: Store<AppState, AppAction>

    let step = 1
    let range = 1 ... 15

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
                        Stepper(value: viewStore.binding(\.$calculator.ladderSteps),
                                in: range,
                                step: step) {
                            Text("Stakes: \(viewStore.calculator.ladderSteps)")
                        }
                        .disabled(viewStore.calculator.disableForm)

                        Picker(selection: viewStore.binding(\.$calculator.ladderDistribution)) {
                            ForEach(Distribution.allCases) { page in
                                Text(page.description)
                            }
                        } label: {
                            Text("Distribution")
                        }
                        .disabled(viewStore.calculator.ladderRungs.count == 1)
                        DatePicker(
                            "Offset Date",
                            selection: viewStore.binding(\.$calculator.ladderStartDateOffset),
                            displayedComponents: [.date]
                        )
                        .disabled(viewStore.calculator.ladderRungs.count == 1)
                    }

                    switch viewStore.calculator.disableForm {
                    case false:
                        Section {
                            ForEach(viewStore.binding(\.$calculator.ladderRungs)) { rung in
                                VStack(spacing: 8) {
                                    DatePicker(
                                        "Stake \(rung.id + 1)",
                                        selection: rung.date,
                                        displayedComponents: [.date]
                                    )
                                    Slider(value: rung.stakePercentage, in: 0 ... 1) {
                                        Text("Stake Percent")
                                    } minimumValueLabel: {
                                        Text("0%")
                                    } maximumValueLabel: {
                                        Text("100%")
                                    }
                                    .font(.caption.monospaced())
                                    HStack {
                                        Text(NSNumber(value: rung.stakePercentage.wrappedValue).percentageFractionString)
                                        Spacer()
                                        Label(rung.hearts.wrappedValue.hex.hexString, image: "hex-logo.SFSymbol")
                                            .labelStyle(HEXNumberTextStyle())
                                    }
                                    .font(.caption.monospaced())
                                    Divider()
                                }
                                .padding([.vertical], 12)
                            }

                        } header: {
                            switch viewStore.calculator.ladderRungs.count {
                            case 1: Text("Stake")
                            default: Text("Stakes")
                            }
                        }

                    case true:
                        EmptyView()
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationBarTitle("Calculator", displayMode: .inline)
            }
        }
    }
}

// struct CalculatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalculatorView()
//    }
// }
