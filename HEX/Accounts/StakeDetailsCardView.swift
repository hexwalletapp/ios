//
//  StakeDetailsCardView.swift
//  HEX
//
//  Created by Joe Blau on 9/26/21.
//

import SwiftUI

struct StakeDetailsCardView: View {
    let stake: Stake
    let hexPrice: Double
    let chain: Chain
    
    var body: some View {
        GroupBox {
            HStack {
                ZStack {
                    PercentageRingView(
                        ringWidth: 8, percent: stake.percentComplete.doubleValue * 100,
                        backgroundColor: chain.gradient.first!.opacity(0.15),
                        foregroundColors: [chain.gradient.first!, chain.gradient.last!]
                    )
                        .frame(width: 56, height: 56)
                    Text(stake.percentComplete.percentageString)
                        .font(.caption.monospacedDigit())
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(stake.stakedHearts
                            .hexAt(price: hexPrice)
                            .currencyStringSuffix).foregroundColor(.primary)
                    Text(stake.stakedHearts.hex.hexString).foregroundColor(.secondary)
                }
            }
            .font(.body.monospacedDigit())
        } label: {
            Label("Staked \(stake.stakedDays) Days", systemImage: "calendar")
        }
        .padding()
        .groupBoxStyle(StakeGroupBoxStyle(color: .primary, destination: StakeDetailsView(stake: stake)))
    }
}

//struct StakeDetailsCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        StakeDetailsCardView()
//    }
//}

