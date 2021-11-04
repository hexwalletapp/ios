// CalculatorView.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import ComposableArchitecture
import simd
import SwiftUI
import UIKit

struct CalculatorView: View {
    let store: Store<AppState, AppAction>
    
    enum Field {
        case stakeAmount
        case stakeDays
        case price
    }
    
    let step = 1
    let range = 1 ... 15
    @FocusState private var focusedField: Field?
    
    
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    Section {
                        TextField("HEX Stake Amount", value: viewStore.binding(\.$calculator.stakeAmountHex).animation(), format: .number)
                            .focused($focusedField, equals: .stakeAmount)
                            .keyboardType(.numbersAndPunctuation)
                            .submitLabel(.next)
                        TextField("Days", value: viewStore.binding(\.$calculator.stakeDays).animation(), format: .number)
                            .focused($focusedField, equals: .stakeDays)
                            .keyboardType(.numbersAndPunctuation)
                            .submitLabel(.next)
                        TextField("Price Prediction", value: viewStore.binding(\.$calculator.price).animation(), format: .number)
                            .focused($focusedField, equals: .price)
                            .keyboardType(.numbersAndPunctuation)
                            .submitLabel(.done)
                    }
                    
                    switch viewStore.calculator.showLadder {
                    case true:
                        Section {
                            Stepper(value: viewStore.binding(\.$calculator.ladderSteps).animation(),
                                    in: range,
                                    step: step) {
                                Text("Stakes: \(viewStore.calculator.ladderSteps)")
                            }
                                    .disabled(viewStore.calculator.disableForm)
                            
//                            Picker(selection: viewStore.binding(\.$calculator.ladderDistribution)) {
//                                ForEach(Distribution.allCases) { page in
//                                    Text(page.description)
//                                }
//                            } label: {
//                                Text("Distribution")
//                            }
//                            .disabled(viewStore.calculator.ladderRungs.count == 1)
//                            DatePicker(
//                                "Offset Date",
//                                selection: viewStore.binding(\.$calculator.ladderStartDateOffset),
//                                displayedComponents: [.date]
//                            )
//                                .disabled(viewStore.calculator.ladderRungs.count == 1)
                        } header: {
                            Text("Ladder")
                        }
                        
                    case false:
                        EmptyView()
                    }
                    
                    switch viewStore.calculator.disableForm {
                    case false:
                        ladderRungsView
                    case true:
                        EmptyView()
                    }
                }
                .onSubmit {
                    switch focusedField {
                    case .stakeAmount: focusedField = .stakeDays
                    case .stakeDays: focusedField = .price
                    default: focusedField = nil
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationBarTitle("Calculator", displayMode: .inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Toggle(isOn: viewStore.binding(\.$calculator.showLadder).animation()) {
                            Label("Ladder", image: "ladder.SFSymbol")
                        }
                        .disabled(viewStore.calculator.disableForm)
                    }
                }
            }
        }
    }
    
    var ladderRungsView: some View {
        WithViewStore(store) { viewStore in
            ForEach(viewStore.binding(\.$calculator.ladderRungs)) { rung in
                Section {
                    VStack {
                        DatePicker(
                            "Stake \(rung.id + 1)",
                            selection: rung.date,
                            displayedComponents: [.date]
                        )
//                        Slider(value: rung.stakePercentage, in: 0 ... 1) {
//                            Text("Stake Percent")
//                        } minimumValueLabel: {
//                            Text(NSNumber(value: rung.stakePercentage.wrappedValue).percentageFractionString)
//                        } maximumValueLabel: {
//                            Text("")
//                        }
//                        .font(.caption.monospaced())
//                        .disabled(viewStore.calculator.ladderRungs.count == 1)
                        

                        bonuses(rung: rung.wrappedValue)
                        projected(rung: rung.wrappedValue)
                    }
                    .padding([.vertical], 12)
                } header: {
                    if rung.id == 0 {
                        switch viewStore.calculator.ladderRungs.count {
                        case 1: Text("Stake")
                        default: Text("Stakes")
                        }
                    }
                }
            }
        }
    }
    
    func bonuses(rung: Rung) -> some View {
        WithViewStore(store) { viewStore in
            switch viewStore.calculator.price {
            case let .some(price):
                VStack {
                    DataSectionHeaderView(title: "Bonus")
                    DataHeaderView()
                    Divider()
                    DataRowHexView(title: "ʟᴏɴɢᴇʀ", units: rung.bonus.longerPaysBetter, price: price)
                    DataRowHexView(title: "ʙɪɢɢᴇʀ", units: rung.bonus.biggerPaysBetter, price: price)
                    DataRowHexView(title: "ᴛᴏᴛᴀʟ", units: rung.bonus.bonusHearts, price: price)
                    Divider()
                    DataRowHexView(title: "ᴇғғᴇᴄᴛɪᴠᴇ", units: rung.effectiveHearts, price: price)
                    Divider()
                    DataRowShareView(title: "sʜᴀʀᴇs", shares: rung.shares)
                }
            case .none:
                EmptyView()
            }
        }
    }
    
    func projected(rung: Rung) -> some View {
        WithViewStore(store) { viewStore in
            switch viewStore.calculator.price {
            case let .some(price):
                VStack {
                    DataSectionHeaderView(title: "Earnings")
                    DataHeaderView()
                    Divider()
                    DataRowHexView(title: "ᴘʀɪɴᴄɪᴘᴀʟ", units: rung.principalHearts, price: price)
                    DataRowHexView(title: "ɪɴᴛᴇʀᴇsᴛ", units: rung.interestHearts, price: price)
                    Divider()
                    DataRowHexView(title: "ᴛᴏᴛᴀʟ", units: rung.totalPayoutHearts, price: price)
                    Divider()
                    DataRowPercentView(title: "ʀᴏɪ", hex: rung.roiPercent, usd: rung.roiPercent(price: price))
                    DataRowPercentView(title: "ᴀᴘʏ", hex: rung.apyPercent, usd: rung.apyPercent(price: price))
                }
            case .none:
                EmptyView()
            }
        }
    }
    
    
    
}

// struct CalculatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalculatorView()
//    }
// }