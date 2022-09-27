// StakeDetailsCardView.swift
// Copyright (c) 2022 Joe Blau

import SwiftUI

struct StakeDetailsCardView: View {
    let price: Double
    let stake: Stake
    let account: Account

    @State private var current = 3000.0

    
    let gradient = Gradient(colors: [.blue, .green, .pink])

    
    var body: some View {
        
        GroupBox {
            HStack(alignment: .top) {
                Gauge(value: stake.percentComplete, in: 0...1) {
                    } currentValueLabel: {
                        Text(NSNumber(value: stake.percentComplete).percentageString)
                            .font(.caption.monospacedDigit())
                    }
                    .scaleEffect(1.2)
                    .tint(Gradient(colors: account.chain.gradient))
                    .gaugeStyle(.accessoryCircular)
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Spacer()
                    Text(stake.balanceHearts
                        .hexAt(price: price)
                        .currencyString()).foregroundColor(.primary)
                    Label(stake.balanceHearts.hex.hexString, image: "hex-logo.SFSymbol")
                        .labelStyle(HEXNumberTextStyle())
                        .foregroundColor(.secondary)
                }
            }
            .font(.body.monospacedDigit())
        } label: {
            Label(stake.endDate.mediumDateString, systemImage: stake.status.systemName)
            EmptyView()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .groupBoxStyle(StakeGroupBoxStyle(color: .primary,
                                          destination: StakeDetailsView(price: price,
                                                                        stake: stake,
                                                                        account: account),
                                          status: stake.statusType))
    }
}

// struct StakeDetailsCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        StakeDetailsCardView()
//    }
// }
