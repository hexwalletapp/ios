// PlanView.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import simd
import SwiftUI
import UIKit

struct PlanView: View {
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
                        switch viewStore.calculator.planUnit {
                        case .USD:
                            HStack {
                                PlanUnit.USD.image.frame(width: k.FORM_ICON_WIDTH).foregroundColor(.secondary)
                                TextField("\(PlanUnit.USD.description) Stake Amount", value: viewStore.binding(\.$calculator.stakeAmountDollar).animation(),
                                          format: .number)
                                    .focused($focusedField, equals: .stakeAmount)
                                    .keyboardType(.decimalPad)
                                    .submitLabel(.next)
                            }
                        case .HEX:
                            HStack {
                                PlanUnit.HEX.image.frame(width: k.FORM_ICON_WIDTH).foregroundColor(.secondary)
                                TextField("\(PlanUnit.HEX.description) Stake Amount", value: viewStore.binding(\.$calculator.stakeAmountHex).animation(),
                                          format: .number)
                                    .focused($focusedField, equals: .stakeAmount)
                                    .keyboardType(.numberPad)
                                    .submitLabel(.next)
                            }
                        }
                        HStack {
                            Image(systemName: "calendar.badge.clock").frame(width: k.FORM_ICON_WIDTH).foregroundColor(.secondary)
                            TextField("Days", value: viewStore.binding(\.$calculator.stakeDays).animation(),
                                      format: .number)
                                .focused($focusedField, equals: .stakeDays)
                                .keyboardType(.numberPad)
                                .submitLabel(.next)
                                .foregroundColor(viewStore.calculator.stakeDaysValid ? .primary : .red)
                        }
                        HStack {
                            Image(systemName: "dollarsign.square").frame(width: k.FORM_ICON_WIDTH).foregroundColor(.secondary)
                            TextField("Price Prediction", value: viewStore.binding(\.$calculator.price).animation(),
                                      format: .currency(code: "en_US"))
                                .focused($focusedField, equals: .price)
                                .keyboardType(.decimalPad)
                                .submitLabel(.done)
                        }
                    } footer: {
                        switch viewStore.hexContractOnChain.data[.ethereum]?.dailyData.suffix(7).count {
                        case 0:
                            Button {
                                viewStore.send(.getGlobalInfo)
                            } label: {
                                Label("Connect to internet, then tap here to load share data", systemImage: "exclamationmark.triangle.fill")
                            }
                        default: EmptyView()
                        }
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
                .navigationBarTitle("Plan", displayMode: .inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            focusedField = nil
                        } label: { Image(systemName: "keyboard.chevron.compact.down") }
                            .disabled(focusedField == nil)
                    }
                    ToolbarItemGroup(placement: .principal) {
                        Picker("Plan Input", selection: viewStore.binding(\.$calculator.planUnit).animation()) {
                            ForEach(PlanUnit.allCases) {
                                Text($0.description)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
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
                        bonuses(rung: rung.wrappedValue)
                        projected(rung: rung.wrappedValue)
                    }
                } header: {
                    HStack {
                        Text("Stake \(rung.id + 1)")
                        Spacer()
                        Text(rung.wrappedValue.date.longDateString)
                    }
                }
            }
        }
    }

    func bonuses(rung: Rung) -> some View {
        WithViewStore(store) { viewStore in
            switch viewStore.calculator.currentPrice {
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
            switch (viewStore.calculator.price,
                    viewStore.calculator.currentPrice)
            {
            case let (.some(price), .some(currentPrice)):
                VStack {
                    DataSectionHeaderView(title: "Earnings")
                    DataHeaderView()
                    Divider()
                    DataRowHexView(title: "ᴘʀɪɴᴄɪᴘᴀʟ", units: rung.principalHearts, price: price)
                    DataRowHexView(title: "ɪɴᴛᴇʀᴇsᴛ", units: rung.interestHearts, price: price)
                    Divider()
                    DataRowHexView(title: "ᴛᴏᴛᴀʟ", units: rung.totalPayoutHearts, price: price)
                    Divider()
                    DataRowPercentView(title: "ʀᴏɪ", usd: rung.roiPercent(price: price, currentPrice: currentPrice), hex: rung.roiPercent)
                    DataRowPercentView(title: "ᴀᴘʏ", usd: rung.apyPercent(price: price, currentPrice: currentPrice), hex: rung.apyPercent)
                }
            default:
                EmptyView()
            }
        }
    }
}

// struct PlanView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlanView()
//    }
// }
