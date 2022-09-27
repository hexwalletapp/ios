// FavoritesStakeCreditCardView.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import SwiftUI
import SwiftUIVisualEffects

struct FavoritesStakeCreditCardView: View {
    let store: Store<AppState, AppAction>
    let favoriteAccounts: FavoriteAccounts

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
                    .fill(LinearGradient(gradient: Gradient(colors: favoriteAccounts.gradient),
                                         startPoint: .bottomLeading,
                                         endPoint: .topTrailing))
                    .blurEffect()
                    .blurEffectStyle(.systemThinMaterial)
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        frontGroup(count: favoriteAccounts.accounts.count)
                        Spacer()
                        frontTotal(title: viewStore.payPeriod.description,
                                   value: favoriteAccounts.payout(payPeriod: viewStore.payPeriod),
                                   hex: favoriteAccounts.payoutHEX(payPeriod: viewStore.payPeriod),
                                   alignment: .trailing)
                    }
                    Spacer()
                    HStack(alignment: .bottom) {
                        frontTitle(title: "Shares",
                                   value: favoriteAccounts.totalShares,
                                   alignment: .leading)
                        Spacer()
                        frontTotal(title: "Total",
                                   value: favoriteAccounts.totalBalance,
                                   hex: favoriteAccounts.totalHEX,
                                   alignment: .trailing)
                    }
                }
                .font(.body.monospacedDigit())
                .padding()
            }
            .frame(maxWidth: .infinity, idealHeight: (UIScreen.main.bounds.width) / 1.586)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    var back: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: favoriteAccounts.gradient),
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
                FavoriteDataRowHexView(title: "ʟɪᴏ̨ᴜɪᴅ",
                                       usdTotal: favoriteAccounts.totalLiquidUSD,
                                       hexTotal: favoriteAccounts.totalLiquidHEX)
                FavoriteDataRowHexView(title: "sᴛᴀᴋᴇᴅ",
                                       usdTotal: favoriteAccounts.totalStakedUSD,
                                       hexTotal: favoriteAccounts.totalStakedHEX)
                FavoriteDataRowHexView(title: "ɪɴᴛᴇʀᴇsᴛ",
                                       usdTotal: favoriteAccounts.totalInterestUSD,
                                       hexTotal: favoriteAccounts.totalInterestHEX)

                if !favoriteAccounts.totalBigPayday.isZero {
                    FavoriteDataRowHexView(title: "ʙɪɢ ᴘᴀʏ ᴅᴀʏ",
                                           usdTotal: favoriteAccounts.totalBigPayDayUSD,
                                           hexTotal: favoriteAccounts.totalBigPayDayHEX)
                }

                Spacer()
                HStack(alignment: .bottom, spacing: 16) {
                    Spacer()
                    ForEach(Array(favoriteAccounts.totalChains).sorted { $0.description < $1.description }) { chain in
                        chain.image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 32)
                            .vibrancyEffect()
                            .vibrancyEffectStyle(.fill)
                    }
                }
            }
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .padding(.top, MAGNETIC_STRIPE_HEIGHT + MAGNETIC_STRIPE_PADDING / 2)
            .padding()
        }
        .frame(maxWidth: .infinity, idealHeight: (UIScreen.main.bounds.width) / 1.586)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    func frontTitle(title: String, value: String, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
            Text(value)
            description(text: title)
        }
    }

    func frontTotal(title: String,
                    value: String,
                    hex: String,
                    alignment: HorizontalAlignment) -> some View
    {
        WithViewStore(store) { viewStore in
            VStack(alignment: alignment) {
                switch viewStore.creditCardUnits {
                case .hex:
                    Label(hex, image: "hex-logo.SFSymbol")
                        .labelStyle(HEXNumberTextStyle())
                case .usd:
                    Text(value)
                }
                description(text: title)
            }
        }
    }

    func frontGroup(count: Int) -> some View {
        Text("Favorites: \(count)")
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

// struct GroupStakeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupStakeCardView()
//    }
// }
