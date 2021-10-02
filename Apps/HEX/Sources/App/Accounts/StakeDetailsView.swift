// StakeDetailsView.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import HEXREST
import SwiftUI

struct StakeDetailsView: View {
    let price: Double
    let stake: Stake
    let account: Account

    let threeColumnGrid = [GridItem(.flexible(maximum: 80), alignment: .leading),
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
                    headerView
                    earningsView
                    HStack(alignment: .top) {
                        Spacer()
                        Text("sᴛᴀᴋᴇ ɪᴅ:").font(.caption)
                        Text(stake.stakeId.description).font(.caption.monospaced())
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(stake.endDate.mediumDateString)
    }

    var headerView: some View {
        HStack(alignment: .top) {
            ZStack {
                PercentageRingView(
                    ringWidth: 16,
                    percent: stake.percentComplete * 100,
                    backgroundColor: account.chain.gradient.first?.opacity(0.15) ?? .clear,
                    foregroundColors: [account.chain.gradient.first ?? .clear, account.chain.gradient.last ?? .clear]
                )
                VStack {
                    Text(NSNumber(value: stake.percentComplete).percentageFractionString)
                        .font(.body.monospacedDigit())
                    Text("Complete")
                        .font(.caption.monospaced())
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 128, height: 128)
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                headerDetails(headline: stake.startDate.longDateString, subheadling: "Stake Start")
                headerDetails(headline: stake.endDate.longDateString, subheadling: "Stake End")
                headerDetails(headline: stake.daysRemaining.description, subheadling: "Days Remaining")
                headerDetails(headline: stake.stakeShares.number.shareString, subheadling: "Shares")
                Spacer()
            }
        }
    }

    func headerDetails(headline: String, subheadling: String) -> some View {
        VStack(alignment: .trailing) {
            Text(headline)
            Text(subheadling)
                .font(.caption.monospaced())
                .foregroundColor(.secondary)
        }
    }

    var earningsView: some View {
        VStack {
            earningsHeader
            Divider()
            girdRow(title: "ᴘʀɪɴᴄɪᴘᴀʟ", units: stake.stakedHearts)
            girdRow(title: "ɪɴᴛᴇʀᴇsᴛ", units: stake.interestHearts)
            if let bigPayDayHearts = stake.bigPayDayHearts {
                girdRow(title: "ʙɪɢ ᴘᴀʏ ᴅᴀʏ", units: bigPayDayHearts)
            }
            Divider()
            girdRow(title: "ᴛᴏᴛᴀʟ", units: stake.balanceHearts)
            Divider()
            roiRow(principal: stake.stakedHearts, interest: stake.interestHearts)
        }
        .padding([.bottom], 10)
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
                .hexAt(price: price)
                .currencyWholeString)
                            .font(.caption.monospaced())
        }
    }

    func roiRow(principal: BigUInt, interest: BigUInt) -> some View {
        LazyVGrid(columns: threeColumnGrid) {
            Text("ʀᴏɪ")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(toPercentage(principal: principal.hex,
                              interest: interest.hex))
                .font(.caption.monospaced())
            Text(toPercentage(principal: principal.hexAt(price: price),
                              interest: interest.hexAt(price: price)))
                .font(.caption.monospaced())
        }
    }

    func toPercentage(principal: NSNumber, interest: NSNumber) -> String {
        NSNumber(value: interest.doubleValue / principal.doubleValue).percentageFractionString
    }
}

#if DEBUG
//    struct StakeDetailsView_Previews: PreviewProvider {
//        static var previews: some View {
//            StakeDetailsView(stake: sampleStake)
//        }
//    }
#endif
