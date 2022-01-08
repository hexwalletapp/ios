// GroupStakeCardView.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import SwiftUI
import SwiftUIVisualEffects

struct GroupStakeCardView: View {
//    let price: Double
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
//                    frontTotal(title: "Daily Payout",
//                               hearts: groupAccountData.total.interestSevenDayHearts,
//                               alignment: .leading)
                    Spacer()
                    frontGroup(count: groupAccountData.accountData.count)
                }
                Spacer()
                HStack(alignment: .bottom) {
                    frontTitle(title: "Total Balance", data: groupAccountData.totalBalance, alignment: .leading)
//                    frontTotal(title: "Total Balance",
//                               hearts: groupAccountData.total.balanceHearts + accountData.liquidBalanceHearts,
//                               alignment: .leading)
                    Spacer()
                    frontTitle(title: "Total HEX", data: groupAccountData.totalHEX, alignment: .trailing)
//                    frontTotalHEX(title: ,
//                                  hearts: accountData.total.balanceHearts + accountData.liquidBalanceHearts,
//                                  alignment: .trailing)
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
//                DataRowHexView(title: "ʟɪᴏ̨ᴜɪᴅ", units: accountData.liquidBalanceHearts, price: price)
//                DataRowHexView(title: "sᴛᴀᴋᴇᴅ", units: accountData.total.stakedHearts, price: price)
//                DataRowHexView(title: "ɪɴᴛᴇʀᴇsᴛ", units: accountData.total.interestHearts, price: price)
//
//                if !accountData.total.bigPayDayHearts.isZero {
//                    DataRowHexView(title: "ʙɪɢ ᴘᴀʏ ᴅᴀʏ", units: accountData.total.bigPayDayHearts, price: price)
//                }

                Spacer()
                HStack(alignment: .bottom) {
//                    VStack(alignment: .leading) {
//                        Spacer()
//                        Text(accountData.account.name)
//                        description(text: accountData.account.chain.description)
//                    }
//                    Spacer()
//                    accountData.account.chain.image
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 32)
//                        .vibrancyEffect()
//                        .vibrancyEffectStyle(.fill)
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

//    func frontTotal(title: String, hearts: BigUInt, alignment: HorizontalAlignment) -> some View {
//        VStack(alignment: alignment) {
    ////            Text(hearts.hexAt(price: price).currencyString)
//            description(text: title)
//        }
//    }
//
//    func frontTotal(title: String, shares: BigUInt, alignment: HorizontalAlignment) -> some View {
//        VStack(alignment: alignment) {
//            Text(shares.number.shareString).foregroundColor(.primary)
//            description(text: title)
//        }
//    }
//
//    func frontTotalHEX(title: String, hearts: BigUInt, alignment: HorizontalAlignment) -> some View {
//        VStack(alignment: alignment) {
//            Text(hearts.hex.hexString).foregroundColor(.primary)
//            description(text: title)
//        }
//    }

    func frontGroup(count: Int) -> some View {
        Text("Accounts: \(count)")
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
