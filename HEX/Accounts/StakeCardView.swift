//
//  StakeCardView.swift
//  HEX
//
//  Created by Joe Blau on 9/25/21.
//

import SwiftUI
import SwiftUIVisualEffects
import BigInt
import ComposableArchitecture

struct StakeCardView: View {
    let account: Account
    
    private let MAGNETIC_STRIPE_HEIGHT = CGFloat(32)
    @State private var cardRotation = 0.0
    @State private var showBack = false
    
    var body: some View {
        ZStack {
            switch showBack {
            case true: back
            case false: front
            }
        }
        .onTapGesture {
            flipCard()
        }
        .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
    }
    
    var front: some View {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: account.chain.gradient),
                                         startPoint: .bottomLeading,
                                         endPoint: .topTrailing))
                    .blurEffect()
                    .blurEffectStyle(.systemMaterial)
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        frontTotal(title: "Daily Payout",
                                   hearts: account.total.interestSevenDayHearts,
                                   alignment: .leading)
                        Spacer()
                        front(address: account.address)
                    }
                    Spacer()
                    HStack(alignment: .bottom) {
                        frontTotal(title: "Total Balance",
                                   hearts: account.total.stakeHearts + account.total.interestHearts,
                                   alignment: .leading)
                        Spacer()
                        frontTotal(title: "Total Shares",
                                   shares: account.total.stakeShares,
                                   alignment: .trailing)
                    }
                }
                .font(.body.monospacedDigit())
                .padding()
            }
            .frame(maxWidth: .infinity, idealHeight: (UIScreen.main.bounds.width) / 1.586)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    var back: some View {
            ZStack(alignment: .topLeading) {
            Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: account.chain.gradient),
                                     startPoint: .bottomLeading,
                                     endPoint: .topTrailing))
                .blurEffect()
                .blurEffectStyle(.systemMaterial)
            Rectangle()
                .foregroundColor(.black)
                .frame(height: MAGNETIC_STRIPE_HEIGHT)
                .offset(y: MAGNETIC_STRIPE_HEIGHT)
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Image(account.chain.description).resizable()
                        .scaledToFit()
                        .frame(height: 32)
                        .vibrancyEffect()
                        .vibrancyEffectStyle(.fill)
                    Spacer()
                    Text(account.name)
                    description(text: account.chain.description)
                }

                Spacer()
                VStack(alignment: .trailing) {
                    backTotal(title: "Staked", hearts: account.total.stakeHearts)
                    Spacer()
                    backTotal(title: "Earned", hearts: account.total.interestHearts)
                }
            }
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .padding([.top], MAGNETIC_STRIPE_HEIGHT * 2)
            .padding()
        }
        .frame(maxWidth: .infinity, idealHeight: (UIScreen.main.bounds.width) / 1.586)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    func frontTotal(title: String, hearts: BigUInt, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
            Text(hearts.hexAt(price: account.hexPrice).currencyString)
            description(text: title)
        }
    }
    
    func frontTotal(title: String, shares: BigUInt, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
            Text(shares.number.shareString).foregroundColor(.primary)
            description(text: title)
        }
    }
    
    func front(address: String) -> some View {
        Text("\(address.prefix(6).description)...\(address.suffix(4).description)" )
            .font(.system(.subheadline, design: .monospaced))
            .padding(8)
            .background(Color(.displayP3, white: 1.0, opacity: 0.2))
            .clipShape(Capsule())
    }
    
    func backTotal(title: String, hearts: BigUInt) -> some View {
        VStack(alignment: .trailing) {
            Text(hearts.hexAt(price: account.hexPrice).currencyStringSuffix).foregroundColor(.primary)
            Text(hearts.hex.hexString).foregroundColor(.secondary)
            description(text: title)
        }
        .font(.body.monospacedDigit())
    }
    
    func description(text: String) -> some View {
        Text(text)
            .font(.system(.caption, design: .monospaced))
            .vibrancyEffect()
            .vibrancyEffectStyle(.fill)
    }
    
    func flipCard() {
        let duration = 0.3
        withAnimation(.easeInOut(duration: duration)) {
            cardRotation += 180
        }
        
        withAnimation(.easeInOut(duration: 0.001).delay(duration / 2)) {
            showBack.toggle()
        }
    }
}

#if DEBUG
struct StakeCardView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            StakeCardView(account: Account(name: "Test", address: "0x1234567890", chain: .ethereum))
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .preferredColorScheme($0)
        }
        
    }
}
#endif
