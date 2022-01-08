// GroupAccountDataModel.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import SwiftUI

struct GroupAccountData: Hashable, Equatable, Identifiable {
    var id: UUID { UUID() }

    var gradient: [Color] = [
        Color(white: 0.70),
        Color(white: 0.60),
        Color(white: 0.50),
        Color(white: 0.40),
        Color(white: 0.30),
    ]

    var ethPrice: Double = 0
    var plsPrice: Double = 0

    var dailyPayout: String {
        accountData.reduce(into: NSNumber(0)) { partialResult, accountData in
            let price: Double
            switch accountData.account.chain {
            case .ethereum: price = ethPrice
            case .pulse: price = plsPrice
            }
            partialResult = NSNumber(value: partialResult.doubleValue + accountData.total.interestHearts.hexAt(price: price).doubleValue)
        }.currencyString
    }

    var totalBalance: String {
        accountData.reduce(into: NSNumber(0)) { partialResult, accountData in
            let price: Double
            switch accountData.account.chain {
            case .ethereum: price = ethPrice
            case .pulse: price = plsPrice
            }
            let totalBalance = accountData.total.balanceHearts + accountData.liquidBalanceHearts

            partialResult = NSNumber(value: partialResult.doubleValue + totalBalance.hexAt(price: price).doubleValue)
        }.currencyString
    }

    var totalHEX: String {
        accountData.reduce(into: BigUInt(0)) { partialResult, accountData in
            partialResult += accountData.total.balanceHearts + accountData.liquidBalanceHearts

        }.hex.hexString
    }

    var accountData = [AccountData]()
}
