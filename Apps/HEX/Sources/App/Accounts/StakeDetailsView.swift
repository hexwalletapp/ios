// StakeDetailsView.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import HEXREST
import SwiftUI

struct StakeDetailsView: View {
    let price: Double
    let stake: Stake
    let account: Account

    let threeColumnGrid = [GridItem(.fixed(80), spacing: k.GRID_SPACING, alignment: .leading),
                           GridItem(.flexible(), spacing: k.GRID_SPACING, alignment: .trailing),
                           GridItem(.fixed(100), spacing: k.GRID_SPACING, alignment: .trailing)]

    var body: some View {
        ScrollView {
            GroupBox {
                VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        Label(stake.status.description, systemImage: stake.status.systemName)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
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
                headerDetails(headline: stake.startDate.longDateString, subheading: "Stake Start Date")
                headerDetails(headline: stake.endDate.longDateString, subheading: "Stake End Date")
                switch stake.stakeEndDay < stake.stakedDays {
                case true: headerDetails(headline: stake.endDate.relativeTime, subheading: "Stake Ended")
                case false: headerDetails(headline: stake.endDate.relativeTime, subheading: "Stake Ends")
                }
                headerDetails(headline: stake.stakeShares.number.shareString, subheading: "Shares")
                Spacer()
            }
        }
    }

    func headerDetails(headline: String, subheading: String) -> some View {
        VStack(alignment: .trailing) {
            Text(headline)
            Text(subheading)
                .font(.caption.monospaced())
                .foregroundColor(.secondary)
        }
    }

    var earningsView: some View {
        VStack {
            earningsHeader
            VStack {
                Divider()
                girdRow(title: "ᴘʀɪɴᴄɪᴘᴀʟ", units: stake.stakedHearts)
                girdRow(title: "ɪɴᴛᴇʀᴇsᴛ", units: stake.interestHearts)
                if let bigPayDayHearts = stake.bigPayDayHearts {
                    girdRow(title: "ʙɪɢ ᴘᴀʏ ᴅᴀʏ", units: bigPayDayHearts)
                }
            }
            VStack {
                Divider()
                girdRow(title: "ᴛᴏᴛᴀʟ", units: stake.balanceHearts)
            }
//            VStack {
//                Divider()
//                girdRow(title: "ᴘᴇɴᴀʟᴛʏ", units: stake.penaltyHearts).foregroundColor(.red)
//            }
            VStack {
                Divider()
                gridRow(title: "ʀᴏɪ", hex: stake.roiPercent, usd: stake.roiPercent(price: price))
                gridRow(title: "ᴀᴘʏ", hex: stake.apyPercent, usd: stake.apyPercent(price: price))
            }
        }
    }

    var earningsHeader: some View {
        LazyVGrid(columns: threeColumnGrid, spacing: k.GRID_SPACING) {
            Text("")
            Text("ᴜsᴅ").foregroundColor(.secondary)
            Text("ʜᴇx").foregroundColor(.secondary)
        }
    }

    func girdRow(title: String, units: BigUInt) -> some View {
        LazyVGrid(columns: threeColumnGrid, spacing: k.GRID_SPACING) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(units
                    .hexAt(price: price)
                    .currencyWholeString)
                .font(.caption.monospaced())
            Text("\(units.hex)")
                .font(.caption.monospaced())
        }
    }

    func gridRow(title: String, hex: Double, usd: Double) -> some View {
        LazyVGrid(columns: threeColumnGrid, spacing: k.GRID_SPACING) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(NSNumber(value: hex).percentageFractionString)
                .font(.caption.monospaced())
            Text(NSNumber(value: usd).percentageFractionString)
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
