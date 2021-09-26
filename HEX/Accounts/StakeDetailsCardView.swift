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
    
    var body: some View {
        
        GroupBox {
            HStack {
                ActivityRingView(progress: 0.01,
                                 ringRadius: 140.0,
                                 thickness: 8.0,
                                 startColor: Constant.HEX_COLORS.first!,
                                 endColor: Constant.HEX_COLORS.last!)
                    .frame(width: 32, height: 32)
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

