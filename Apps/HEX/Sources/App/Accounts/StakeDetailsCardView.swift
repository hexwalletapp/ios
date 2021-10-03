// StakeDetailsCardView.swift
// Copyright (c) 2021 Joe Blau

import HEXREST
import SwiftUI

struct StakeDetailsCardView: View {
    let price: NSNumber
    let stake: Stake
    let account: Account

    var body: some View {
        GroupBox {
            HStack(alignment: .top) {
                ZStack {
                    PercentageRingView(
                        ringWidth: 8, percent: stake.percentComplete * 100,
                        backgroundColor: account.chain.gradient.first?.opacity(0.15) ?? .clear,
                        foregroundColors: [account.chain.gradient.first ?? .clear, account.chain.gradient.last ?? .clear]
                    )
                    .frame(width: 56, height: 56)
                    Text(NSNumber(value: stake.percentComplete).percentageString)
                        .font(.caption.monospacedDigit())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(stake.balanceHearts
                        .hexAt(price: price.doubleValue)
                        .currencyString).foregroundColor(.primary)
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
                                          destination: StakeDetailsView(price: price.doubleValue,
                                                                        stake: stake,
                                                                        account: account),
                                          stakeStatus: stake.status))
    }
}

// struct StakeDetailsCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        StakeDetailsCardView()
//    }
// }
