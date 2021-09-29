// StakeDetailsView.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import HEXREST
import SwiftUI

struct StakeDetailsView: View {
    let hexPrice: HEXPrice
    let stake: Stake
    let account: Account

    let threeColumnGrid = [GridItem(.flexible(maximum: 72), alignment: .leading),
                           GridItem(.flexible(maximum: 100), alignment: .trailing),
                           GridItem(.flexible(), alignment: .trailing)]

    var body: some View {
        ScrollView {
            GroupBox {
                VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        Label(stake.status.description, systemImage: stake.status.systemName)
                            .padding([.vertical], 8)
                            .padding([.horizontal], 16)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    HStack(alignment: .top) {
                        ZStack {
                            PercentageRingView(
                                ringWidth: 16,
                                percent: stake.percentComplete * 100,
                                backgroundColor: account.chain.gradient.first?.opacity(0.15) ?? .clear,
                                foregroundColors: [account.chain.gradient.first ?? .clear, account.chain.gradient.last ?? .clear]
                            )
                            Text(NSNumber(value: stake.percentComplete).percentageFractionString)
                                .font(.caption.monospacedDigit())
                        }
                        .frame(width: 128, height: 128)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(stake.endDate.longDateString)
                            Text("End Date").font(.subheadline).foregroundColor(.secondary)
                            Spacer()
                            Text(stake.daysRemaining.description)
                            Text("Days Remaining").font(.subheadline).foregroundColor(.secondary)
                            Spacer()
                            Text(stake.stakeShares.number.shareString)
                            Text("Shares").font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                    earningsView
                }
            }
            .padding()
        }
        .navigationTitle(stake.stakeId.description)
    }

    var earningsView: some View {
        VStack {
            earningsHeader
            Divider()
            girdRow(title: "ᴘʀɪɴᴄɪᴘʟᴇ", units: stake.stakedHearts)
            girdRow(title: "ɪɴᴛᴇʀᴇsᴛ", units: stake.interestHearts)
            Divider()
            girdRow(title: "ᴛᴏᴛᴀʟ", units: stake.stakedHearts + stake.interestHearts)
            Divider()
            roiRow(principle: stake.stakedHearts, interest: stake.interestHearts)
        }
        .padding([.vertical], 20)
    }

    var earningsHeader: some View {
        LazyVGrid(columns: threeColumnGrid) {
            Text("")
            Text("ʜᴇx").foregroundColor(.secondary)
            Text("ᴜsᴅ").foregroundColor(.secondary)
        }
    }

    func girdRow(title: String, units: BigUInt) -> some View {
        LazyVGrid(columns: threeColumnGrid) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(units.hex)")
                .font(.caption.monospaced())
            Text(units
                .hexAt(price: hexPrice.hexUsd)
                .currencyString)
                            .font(.caption.monospaced())
        }
    }

    func roiRow(principle: BigUInt, interest: BigUInt) -> some View {
        LazyVGrid(columns: threeColumnGrid) {
            Text("ʀᴏɪ")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(toPercentage(principle: principle.hex,
                              interest: interest.hex))
                .font(.caption.monospaced())
            Text(toPercentage(principle: principle.hexAt(price: hexPrice.hexUsd),
                              interest: interest.hexAt(price: hexPrice.hexUsd)))
                .font(.caption.monospaced())
        }
    }

    func toPercentage(principle: NSNumber, interest: NSNumber) -> String {
        NSNumber(value: interest.doubleValue / principle.doubleValue).percentageFractionString
    }
}

#if DEBUG
//    struct StakeDetailsView_Previews: PreviewProvider {
//        static var previews: some View {
//            StakeDetailsView(stake: sampleStake)
//        }
//    }
#endif
