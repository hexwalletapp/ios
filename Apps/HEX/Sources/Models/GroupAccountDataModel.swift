// GroupAccountDataModel.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import EVMChain
import Foundation
import SwiftUI

struct GroupAccountData: Hashable, Equatable, Identifiable {
    var id: String { "FavoriteAccountDataId" }

    var gradient: [Color] = [
        Color(white: 0.50),
        Color(white: 0.40),
        Color(white: 0.30),
        Color(white: 0.20),
        Color(white: 0.10),
    ]

    var hasFavorites: Bool {
        !accountsData.isEmpty
    }

    var accountsData = IdentifiedArrayOf<AccountData>()

    var dailyPayout: String {
        accountsData.reduce(into: NSNumber(0)) { partialResult, accountData in
            partialResult = NSNumber(value: partialResult.doubleValue + accountData.total.interestSevenDayHearts.hexAt(price: accountData.hexPrice).doubleValue)
        }.currencyString
    }

    var totalBalance: String {
        accountsData.reduce(into: NSNumber(0)) { partialResult, accountData in
            let totalBalance = accountData.total.balanceHearts + accountData.liquidBalanceHearts

            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: accountData.hexPrice).doubleValue)
        }.currencyString
    }

    var totalHEX: String {
        accountsData.reduce(into: BigUInt(0)) { partialResult, accountData in
            partialResult += accountData.total.balanceHearts + accountData.liquidBalanceHearts
        }.hex.hexString
    }

    // MARK: - Total Liquid

    var totalLiquidUSD: String {
        accountsData.reduce(into: NSNumber(0)) { partialResult, accountData in
            let totalBalance = accountData.liquidBalanceHearts

            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: accountData.hexPrice).doubleValue)
        }.currencyString
    }

    var totalLiquidHEX: String {
        accountsData.reduce(into: BigUInt(0)) { partialResult, accountData in
            partialResult += accountData.liquidBalanceHearts
        }.hex.hexString
    }

    // MARK: - Total Staked

    var totalStakedUSD: String {
        accountsData.reduce(into: NSNumber(0)) { partialResult, accountData in
            let totalBalance = accountData.total.stakedHearts

            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: accountData.hexPrice).doubleValue)
        }.currencyString
    }

    var totalStakedHEX: String {
        accountsData.reduce(into: BigUInt(0)) { partialResult, accountData in
            partialResult += accountData.total.stakedHearts
        }.hex.hexString
    }

    // MARK: - Total Interest

    var totalInterestUSD: String {
        accountsData.reduce(into: NSNumber(0)) { partialResult, accountData in
            let totalBalance = accountData.total.interestHearts

            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: accountData.hexPrice).doubleValue)
        }.currencyString
    }

    var totalInterestHEX: String {
        accountsData.reduce(into: BigUInt(0)) { partialResult, accountData in
            partialResult += accountData.total.interestHearts
        }.hex.hexString
    }

    // MARK: - Total Big Pay Day

    var totalBigPayDayUSD: String {
        accountsData.reduce(into: NSNumber(0)) { partialResult, accountData in
            let totalBalance = accountData.total.bigPayDayHearts

            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: accountData.hexPrice).doubleValue)
        }.currencyString
    }

    var totalBigPayDayHEX: String {
        totalBigPayday.hex.hexString
    }

    var totalBigPayday: BigUInt {
        accountsData.reduce(into: BigUInt(0)) { partialResult, accountData in
            partialResult += accountData.total.bigPayDayHearts
        }
    }

    // MARK: - Total Chains

    var totalChains: Set<Chain> {
        accountsData.reduce(into: Set<Chain>()) { partialResult, accountData in
            partialResult.insert(accountData.account.chain)
        }
    }

    // MARK: - Stakes

    var totalAccountStakes: [(Account, Stake)] {
        accountsData.reduce(into: [(Account, Stake)]()) { partialResult, accountData in
            let accounts = Array(repeating: accountData.account, count: accountData.stakes.count)
            let accountStakes = zip(accounts, accountData.stakes).map { ($0, $1) }
            partialResult.append(contentsOf: accountStakes)
        }.sorted { $0.1.stakeEndDay < $1.1.stakeEndDay }
    }
}
