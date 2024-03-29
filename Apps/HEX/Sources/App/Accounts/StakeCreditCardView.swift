// StakeCreditCardView.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import SwiftUI
import SwiftUIVisualEffects

struct StakeCreditCardView: View {
    let store: Store<AppState, AppAction>
    @Binding var account: Account

    private let MAGNETIC_STRIPE_HEIGHT = CGFloat(32)
    private let MAGNETIC_STRIPE_PADDING = CGFloat(24)
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
        WithViewStore(store) { viewStore in
            ZStack {
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: account.chain.gradient),
                                         startPoint: .bottomLeading,
                                         endPoint: .topTrailing))
                    .blurEffect()
                    .blurEffectStyle(.systemMaterial)
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        front(shortAddress: account.address.shortAddress)
                        Spacer()
                        frontTotal(title: viewStore.payPeriod.description,
                                   hearts: account.summary.interestPayPeriodHearts[viewStore.payPeriod] ?? 0,
                                   price: viewStore.shouldSpeculate ? viewStore.speculativePrice.doubleValue : account.assetPrice.HEX_USD,
                                   alignment: .trailing)
                    }
                    Spacer()
                    HStack(alignment: .bottom) {
                        frontTotal(title: "Total Shares",
                                   shares: account.summary.stakeShares,
                                   alignment: .leading)
                        Spacer()
                        frontTotal(title: "Total",
                                   hearts: account.summary.balanceHearts,
                                   price: viewStore.shouldSpeculate ? viewStore.speculativePrice.doubleValue : account.assetPrice.HEX_USD,
                                   alignment: .trailing)
                    }
                }
                .font(.body.monospacedDigit())
                .padding()
                switch account.isLoading {
                case true: ProgressView()
                    .vibrancyEffect()
                    .vibrancyEffectStyle(.fill)
                case false:
                    switch account.stakes.isEmpty {
                    case true:
                        Text("No stakes for this account")
                            .vibrancyEffect()
                            .vibrancyEffectStyle(.fill)
                    case false:
                        EmptyView()
                    }
                }
            }
            .frame(maxWidth: .infinity, idealHeight: (UIScreen.main.bounds.width) / 1.586)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    var back: some View {
        WithViewStore(store) { viewStore in
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
                    .offset(y: MAGNETIC_STRIPE_PADDING)

                VStack(alignment: .leading) {
                    DataHeaderView()
                    DataRowHexView(title: "ʟɪᴏ̨ᴜɪᴅ",
                                   units: account.summary.liquidHearts,
                                   price: viewStore.shouldSpeculate ? viewStore.speculativePrice.doubleValue : account.assetPrice.HEX_USD)
                    DataRowHexView(title: "sᴛᴀᴋᴇᴅ",
                                   units: account.summary.stakedHearts,
                                   price: viewStore.shouldSpeculate ? viewStore.speculativePrice.doubleValue : account.assetPrice.HEX_USD)
                    DataRowHexView(title: "ɪɴᴛᴇʀᴇsᴛ",
                                   units: account.summary.interestHearts,
                                   price: viewStore.shouldSpeculate ? viewStore.speculativePrice.doubleValue : account.assetPrice.HEX_USD)

                    if !account.summary.bigPayDayHearts.isZero {
                        DataRowHexView(title: "ʙɪɢ ᴘᴀʏ ᴅᴀʏ",
                                       units: account.summary.bigPayDayHearts,
                                       price: viewStore.shouldSpeculate ? viewStore.speculativePrice.doubleValue : account.assetPrice.HEX_USD)
                    }

                    Spacer()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(account.name)
                            description(text: account.chain.description)
                        }
                        Spacer()
                        account.chain.image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 32)
                            .vibrancyEffect()
                            .vibrancyEffectStyle(.fill)
                    }
                }
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .padding(.top, MAGNETIC_STRIPE_HEIGHT + MAGNETIC_STRIPE_PADDING / 2)
                .padding()
            }
            .frame(maxWidth: .infinity, idealHeight: (UIScreen.main.bounds.width) / 1.586)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    func frontTotal(title: String, hearts: BigUInt, price: Double, alignment: HorizontalAlignment) -> some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: alignment) {
                switch viewStore.creditCardUnits {
                case .hex:
                    Label(hearts.hex.hexString, image: "hex-logo.SFSymbol")
                        .labelStyle(HEXNumberTextStyle())
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                case .usd:
                    Text(hearts.hexAt(price: price).currencyString())
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                description(text: title)
            }
        }
    }

    func frontTotal(title: String, shares: BigUInt, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
            Text(shares.number.shareString).foregroundColor(.primary)
            description(text: title)
        }
    }

    func frontTotalHEX(title: String, hearts: BigUInt, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
            Text(hearts.hex.hexString).foregroundColor(.primary)
            description(text: title)
        }
    }

    func front(shortAddress: String) -> some View {
        Text(shortAddress)
            .font(.subheadline.monospaced())
            .padding(8)
            .background(Color(.displayP3, white: 1.0, opacity: 0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    func description(text: String) -> some View {
        Text(text)
            .font(.subheadline)
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
//    struct StakeCardView_Previews: PreviewProvider {
//        static var previews: some View {
//            ForEach(ColorScheme.allCases, id: \.self) {
//                StakeCardView(account: Account(name: "Test", address: "0x1234567890", chain: .ethereum))
//                    .previewLayout(PreviewLayout.sizeThatFits)
//                    .padding()
//                    .preferredColorScheme($0)
//            }
//        }
//    }
#endif
