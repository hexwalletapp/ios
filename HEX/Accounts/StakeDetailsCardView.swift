//
//  StakeDetailsCardView.swift
//  HEX
//
//  Created by Joe Blau on 9/26/21.
//

import SwiftUI

struct StakeDetailsCardView: View {
    let stake: Stake
    let account: Account
    
    var body: some View {
        GroupBox {
            HStack {
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
                VStack(alignment: .trailing) {
                    Text(stake.stakedHearts
                            .hexAt(price: account.hexPrice)
                            .currencyStringSuffix).foregroundColor(.primary)
                    Text(stake.stakedHearts.hex.hexString).foregroundColor(.secondary)
                }
            }
            .font(.body.monospacedDigit())
        } label: {
            Label("Staked \(stake.stakedDays) Days", systemImage: "calendar")
        }
        .padding([.horizontal], 20)
        .padding([.vertical], 10)
        .groupBoxStyle(StakeGroupBoxStyle(color: .primary, destination: StakeDetailsView(stake: stake)))
    }
}

//struct StakeDetailsCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        StakeDetailsCardView()
//    }
//}

