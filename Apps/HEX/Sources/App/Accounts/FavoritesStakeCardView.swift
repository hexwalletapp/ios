// FavoritesStakeCardView.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import SwiftUI
import SwiftUIVisualEffects

struct FavoritesStakeCardView: View {
    let groupAccountData: GroupAccountData

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
        ZStack {
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: groupAccountData.gradient),
                                     startPoint: .bottomLeading,
                                     endPoint: .topTrailing))
                .blurEffect()
                .blurEffectStyle(.systemMaterial)
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    frontTitle(title: "Daily Payout", data: groupAccountData.dailyPayout, alignment: .leading)
                    Spacer()
                    frontGroup(count: groupAccountData.accountsData.count)
                }
                Spacer()
                HStack(alignment: .bottom) {
                    frontTitle(title: "Total Balance", data: groupAccountData.totalBalance, alignment: .leading)
                    Spacer()
                    frontTitle(title: "Total HEX", data: groupAccountData.totalHEX, alignment: .trailing)
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
                .fill(LinearGradient(gradient: Gradient(colors: groupAccountData.gradient),
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
                                       usdTotal: groupAccountData.totalLiquidUSD,
                                       hexTotal: groupAccountData.totalLiquidHEX)
                FavoriteDataRowHexView(title: "sᴛᴀᴋᴇᴅ",
                                       usdTotal: groupAccountData.totalStakedUSD,
                                       hexTotal: groupAccountData.totalStakedHEX)
                FavoriteDataRowHexView(title: "ɪɴᴛᴇʀᴇsᴛ",
                                       usdTotal: groupAccountData.totalInterestUSD,
                                       hexTotal: groupAccountData.totalInterestHEX)

                if !groupAccountData.totalBigPayday.isZero {
                    FavoriteDataRowHexView(title: "ʙɪɢ ᴘᴀʏ ᴅᴀʏ",
                                           usdTotal: groupAccountData.totalBigPayDayUSD,
                                           hexTotal: groupAccountData.totalBigPayDayHEX)
                }

                Spacer()
                HStack(alignment: .bottom, spacing: 16) {
                    Spacer()
                    ForEach(Array(groupAccountData.totalChains).sorted { $0.description < $1.description }) { chain in
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

    func frontTitle(title: String, data: String, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
            Text(data)
            description(text: title)
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