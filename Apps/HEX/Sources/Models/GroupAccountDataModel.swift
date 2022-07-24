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
        Color(red: 0.059, green: 0.910, blue: 1.000, opacity: 1.000),
        Color(red: 0.384, green: 0.600, blue: 1.000, opacity: 1.000),
        Color(red: 0.725, green: 0.282, blue: 1.000, opacity: 1.000),
        Color(red: 1.000, green: 0.024, blue: 1.000, opacity: 1.000),
        Color(red: 1.000, green: 1.000, blue: 0.031, opacity: 1.000),
    ]

    var hasFavorites: Bool {
        !accountsData.isEmpty
    }

    var accountsData = IdentifiedArrayOf<AccountData>()

    func payout(earnings: PayoutEarnings) -> String {
        accountsData.reduce(into: NSNumber(0)) { partialResult, accountData in
            switch earnings {
            case .dailyTotal:
                partialResult = NSNumber(value: partialResult.doubleValue + accountData.total.interestDailyHearts.hexAt(price: accountData.hexPrice).doubleValue)
            case .weeklyTotal:
                partialResult = NSNumber(value: partialResult.doubleValue + accountData.total.interestWeeklyHearts.hexAt(price: accountData.hexPrice).doubleValue)
            case .monthlyTotal:
                partialResult = NSNumber(value: partialResult.doubleValue + accountData.total.interestMonthlyHearts.hexAt(price: accountData.hexPrice).doubleValue)
            }
        }.currencyString()
    }

    func payoutHEX(earnings: PayoutEarnings) -> String {
        accountsData.reduce(into: BigUInt(0)) { partialResult, accountData in
            switch earnings {
            case .dailyTotal: partialResult += accountData.total.interestDailyHearts
            case .weeklyTotal: partialResult += accountData.total.interestWeeklyHearts
            case .monthlyTotal: partialResult += accountData.total.interestMonthlyHearts
            }
        }.hex.hexString
    }

    var totalBalance: String {
        accountsData.reduce(into: NSNumber(0)) { partialResult, accountData in
            let totalBalance = accountData.total.balanceHearts + accountData.liquidBalanceHearts
            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: accountData.hexPrice).doubleValue)
        }.currencyString()
    }

    var totalHEX: String {
        accountsData.reduce(into: BigUInt(0)) { partialResult, accountData in
            partialResult += accountData.total.balanceHearts + accountData.liquidBalanceHearts
        }.hex.hexString
    }

    var totalShares: String {
        accountsData.reduce(into: BigUInt(0)) { partialResult, accountData in
            partialResult += accountData.total.stakeShares
        }.number.shareString
    }

    // MARK: - Total Liquid

    var totalLiquidUSD: String {
        accountsData.reduce(into: NSNumber(0)) { partialResult, accountData in
            let totalBalance = accountData.liquidBalanceHearts

            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: accountData.hexPrice).doubleValue)
        }.currencyString()
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
        }.currencyString()
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
        }.currencyString()
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
        }.currencyString()
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

    var totalAccountStakes: [AccountStake] {
        accountsData.reduce(into: [AccountStake]()) { partialResult, accountData in
            let accounts = Array(repeating: accountData.account, count: accountData.stakes.count)
            let accountStakes = zip(accounts, accountData.stakes).map { AccountStake(account: $0, stake: $1) }
            partialResult.append(contentsOf: accountStakes)
        }.sorted { $0.stake.stakeEndDay < $1.stake.stakeEndDay }
    }
}

struct AccountStake: Identifiable {
    var id: String { "c:\(account.chain)s:\(stake.id)" }
    var account: Account
    var stake: Stake
}
