//
//  StakeDetailsCardView.swift
//  HEX
//
//  Created by Joe Blau on 9/26/21.
//

import SwiftUI

struct StakeDetailsCardView: View {
    var stake: Stake
    var hexPrice: Double
    
    var body: some View {
        GroupBox {
            HStack {
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
        .groupBoxStyle(StakeGroupBoxStyle(color: .primary, destination: Text("Heart rate")))
    }
}

//struct StakeDetailsCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        StakeDetailsCardView()
//    }
//}
