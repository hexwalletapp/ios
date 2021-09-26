//
//  StakeCardView.swift
//  HEX
//
//  Created by Joe Blau on 9/25/21.
//

import SwiftUI
import SwiftUIVisualEffects

struct StakeCardView: View {
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: Constant.HEX_COLORS),
                                     startPoint: .bottomLeading,
                                     endPoint: .topTrailing))
                .blurEffect()
                .blurEffectStyle(.systemMaterialLight)
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("$23,000")
                        description(text: "Daily Payout")
                    }
                    Spacer()
                    Text("0x1245...5678")
                        .font(.body.monospacedDigit())
                        .padding(6)
                        .background(Color(.displayP3, white: 1.0, opacity: 0.4))
                        .clipShape(Capsule())
                }
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("$50,000,000.00")
                        description(text: "Total Balance")
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("10 P-Shares")
                        description(text: "Total Shares")
                    }
                }
            }
            .font(.body.monospacedDigit())
            .padding()

        }
        .frame(width: 300, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    func description(text: String) -> some View {
        Text(text)
                .font(.caption.monospaced())
                .vibrancyEffect()
                .vibrancyEffectStyle(.fill)
    }
}

#if DEBUG
struct StakeCardView_Previews: PreviewProvider {
    static var previews: some View {
        StakeCardView()
    }
}
#endif
