// StakeDetailsView.swift
// Copyright (c) 2021 Joe Blau

import HEXREST
import SwiftUI
import BigInt

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
                VStack {
                    HStack {
                        ZStack {
                            PercentageRingView(
                                ringWidth: 8, percent: stake.percentComplete * 100,
                                backgroundColor: account.chain.gradient.first?.opacity(0.15) ?? .clear,
                                foregroundColors: [account.chain.gradient.first ?? .clear, account.chain.gradient.last ?? .clear]
                            )
                            .frame(width: 64, height: 64)
                            Text(NSNumber(value: stake.percentComplete).percentageFractionString)
                                .font(.caption.monospacedDigit())
                        }
                        Spacer()
                        field(value: "\(stake.daysRemaining)", title: "Days Remaining", alingment: .trailing)
                    }

                    Spacer(minLength: 20)
                    earningsHeader
                    Divider()
                    girdRow(title: "Principle", units: stake.stakedHearts)
                    girdRow(title: "Interest", units: stake.interestHearts)
                    Divider()
                    girdRow(title: "Total", units: stake.stakedHearts + stake.interestHearts)
                    Divider()
                    roiRow(principle: stake.stakedHearts, interest: stake.interestHearts)
                }

//                Text(stake.stakeId.description)
//                Text(stake.stakedHearts.hex.hexString)
//                Text(stake.stakeShares.number.shareString)
//
//                Text(stake.lockedDay.description)
//                Text(stake.stakedDays.description)
//                Text(stake.unlockedDay.description)
//
//                Text(stake.isAutoStake.description)
            }
            .padding([.horizontal], 20)
            .padding([.vertical], 10)
        }
        .navigationTitle(stake.stakeId.description)
    }
    
    var earningsHeader: some View {
        LazyVGrid(columns: threeColumnGrid) {
            Text("")
            Text("ʜᴇx")
            Text("ᴜsᴅ")
        }
    }

    func girdRow(title: String, units: BigUInt) -> some View {
        LazyVGrid(columns: threeColumnGrid) {
            Text(title)
                .font(.subheadline)
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
            Text("ROI")
                .font(.subheadline)

            Text(toPercentage(principle: principle.hex,
                              interest: interest.hex))
                .font(.caption.monospaced())
            Text(toPercentage(principle: principle.hexAt(price: hexPrice.hexUsd),
                              interest: interest.hexAt(price: hexPrice.hexUsd)))
                    .font(.caption.monospaced())

        }
    }
    
    func field(value: String, title: String, alingment: HorizontalAlignment) -> some View {
        VStack(alignment: alingment) {
            Text(value).font(.largeTitle)
            Text(title).font(.subheadline).foregroundColor(.secondary)
        }
    }
    
    func toPercentage(principle: NSNumber, interest: NSNumber) -> String {
        NSNumber(value: (interest.doubleValue / principle.doubleValue)).percentageFractionString
    }
}

#if DEBUG
//    struct StakeDetailsView_Previews: PreviewProvider {
//        static var previews: some View {
//            StakeDetailsView(stake: sampleStake)
//        }
//    }
#endif
