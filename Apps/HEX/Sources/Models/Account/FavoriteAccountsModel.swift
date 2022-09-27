// GroupAccountDataModel.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import EVMChain
import Foundation
import SwiftUI

struct FavoriteAccounts: Hashable, Equatable, Identifiable {
    var id: String { "FavoriteAccountDataId" }

    var gradient: [Color] = [
        Color(red: 0.059, green: 0.910, blue: 1.000, opacity: 1.000),
        Color(red: 0.384, green: 0.600, blue: 1.000, opacity: 1.000),
        Color(red: 0.725, green: 0.282, blue: 1.000, opacity: 1.000),
        Color(red: 1.000, green: 0.024, blue: 1.000, opacity: 1.000),
        Color(red: 1.000, green: 1.000, blue: 0.031, opacity: 1.000),
    ]

    var hasFavorites: Bool {
        !accounts.isEmpty
    }

    var accounts = IdentifiedArrayOf<Account>()

    func payout(payPeriod: PayPeriod) -> String {
        accounts.reduce(into: NSNumber(0)) { partialResult, account in
            let payPeriodInterest = account.summary.interestPayPeriodHearts[payPeriod] ?? 0
            partialResult = NSNumber(value: partialResult.doubleValue + payPeriodInterest.hexAt(price: account.assetPrice.HEX_USD).doubleValue)
        }.currencyString()
    }

    func payoutHEX(payPeriod: PayPeriod) -> String {
        accounts.reduce(into: BigUInt(0)) { partialResult, account in
            partialResult += account.summary.interestPayPeriodHearts[payPeriod] ?? 0
        }.hex.hexString
    }

    var totalBalance: String {
        accounts.reduce(into: NSNumber(0)) { partialResult, account in
            let totalBalance = account.summary.balanceHearts + account.summary.liquidHearts
            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: account.assetPrice.HEX_USD).doubleValue)
        }.currencyString()
    }

    var totalHEX: String {
        accounts.reduce(into: BigUInt(0)) { partialResult, account in
            partialResult += account.summary.balanceHearts + account.summary.liquidHearts
        }.hex.hexString
    }

    var totalShares: String {
        accounts.reduce(into: BigUInt(0)) { partialResult, account in
            partialResult += account.summary.stakeShares
        }.number.shareString
    }

    // MARK: - Total Liquid

    var totalLiquidUSD: String {
        accounts.reduce(into: NSNumber(0)) { partialResult, account in
            let totalBalance = account.summary.liquidHearts
            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: account.assetPrice.HEX_USD).doubleValue)
        }.currencyString()
    }

    var totalLiquidHEX: String {
        accounts.reduce(into: BigUInt(0)) { partialResult, account in
            partialResult += account.summary.liquidHearts
        }.hex.hexString
    }

    // MARK: - Total Staked

    var totalStakedUSD: String {
        accounts.reduce(into: NSNumber(0)) { partialResult, account in
            let totalBalance = account.summary.stakedHearts

            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: account.assetPrice.HEX_USD).doubleValue)
        }.currencyString()
    }

    var totalStakedHEX: String {
        accounts.reduce(into: BigUInt(0)) { partialResult, account in
            partialResult += account.summary.stakedHearts
        }.hex.hexString
    }

    // MARK: - Total Interest

    var totalInterestUSD: String {
        accounts.reduce(into: NSNumber(0)) { partialResult, account in
            let totalBalance = account.summary.interestHearts

            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: account.assetPrice.HEX_USD).doubleValue)
        }.currencyString()
    }

    var totalInterestHEX: String {
        accounts.reduce(into: BigUInt(0)) { partialResult, account in
            partialResult += account.summary.interestHearts
        }.hex.hexString
    }

    // MARK: - Total Big Pay Day

    var totalBigPayDayUSD: String {
        accounts.reduce(into: NSNumber(0)) { partialResult, account in
            let totalBalance = account.summary.bigPayDayHearts

            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: account.assetPrice.HEX_USD).doubleValue)
        }.currencyString()
    }

    var totalBigPayDayHEX: String {
        totalBigPayday.hex.hexString
    }

    var totalBigPayday: BigUInt {
        accounts.reduce(into: BigUInt(0)) { partialResult, account in
            partialResult += account.summary.bigPayDayHearts
        }
    }

    // MARK: - Total Chains

    var totalChains: Set<Chain> {
        accounts.reduce(into: Set<Chain>()) { partialResult, account in
            partialResult.insert(account.chain)
        }
    }

    // MARK: - Stakes

    var totalAccountStakes: [AccountStake] {
        accounts.reduce(into: [AccountStake]()) { partialResult, account in
            let accounts = Array(repeating: account, count: account.stakes.count)
            let accountStakes = zip(accounts, account.stakes).map { AccountStake(account: $0, stake: $1) }
            partialResult.append(contentsOf: accountStakes)
        }.sorted { $0.stake.stakeEndDay < $1.stake.stakeEndDay }
    }
}

struct AccountStake: Identifiable {
    var id: String { "c:\(account.chain)s:\(stake.id)" }
    var account: Account
    var stake: Stake
}
