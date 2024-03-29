// StakeDetailsView.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import SwiftUI

struct StakeDetailsView: View {
    let price: Double
    let stake: Stake
    let account: Account

    var body: some View {
        ScrollView {
            GroupBox {
                VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        Label(stake.statusType, systemImage: stake.status.systemName)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    headerView
                    earningsView
                    HStack(alignment: .top) {
                        Text(stake.type.description).font(.caption.monospaced())
                        Spacer()
                        Text("sᴛᴀᴋᴇ ɪᴅ:").font(.caption)
                        Text(stake.stakeId.description).font(.caption.monospaced())
                    }
                    .foregroundColor(.secondary)
                }
            }
            .groupBoxStyle(FloatingGroupBoxStyle())
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(stake.endDate.mediumDateString)
    }

    var headerView: some View {
        HStack(alignment: .top) {
            Gauge(value: stake.percentComplete, in: 0...1) {
                } currentValueLabel: {
                    Text(NSNumber(value: stake.percentComplete).percentageString)
                        .font(.caption.monospacedDigit())
                }
                .scaleEffect(2.3)
                .tint(Gradient(colors: account.chain.gradient))
                .gaugeStyle(.accessoryCircular)
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
            DataHeaderView()
            VStack {
                Divider()
                DataRowHexView(title: "ᴘʀɪɴᴄɪᴘᴀʟ", units: stake.stakedHearts, price: price)
                DataRowHexView(title: "ɪɴᴛᴇʀᴇsᴛ", units: stake.interestHearts, price: price)
                if let bigPayDayHearts = stake.bigPayDayHearts {
                    DataRowHexView(title: "ʙɪɢ ᴘᴀʏ ᴅᴀʏ", units: bigPayDayHearts, price: price)
                }
            }
            VStack {
                Divider()
                DataRowHexView(title: "ᴛᴏᴛᴀʟ", units: stake.balanceHearts, price: price)
            }
//            VStack {
//                Divider()
//              DataRowHexView(title: "ᴘᴇɴᴀʟᴛʏ", units: stake.penaltyHearts, price: price).foregroundColor(.red)
//            }
            VStack {
                Divider()
                DataRowPercentView(title: "ʀᴏɪ", usd: stake.roiPercent(price: price), hex: stake.roiPercent)
                DataRowPercentView(title: "ᴀᴘʏ", usd: stake.apyPercent(price: price), hex: stake.apyPercent)
            }
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
