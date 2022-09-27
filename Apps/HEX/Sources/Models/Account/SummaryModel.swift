//
//  SummaryModel.swift
//  HEX
//
//  Created by Joe Blau on 9/26/22.
//

import Foundation
import BigInt

struct Summary: Codable, Hashable, Equatable {
    var stakeShares: BigUInt = 0
    var stakedHearts: BigUInt = 0
    var liquidHearts: BigUInt = 0
    var interestHearts: BigUInt = 0
    var interestPayPeriodHearts: [PayPeriod: BigUInt] = [PayPeriod: BigUInt]()
    var bigPayDayHearts: BigUInt = 0
    var balanceHearts: BigUInt {
        stakedHearts + liquidHearts + interestHearts + bigPayDayHearts
    }
}

extension Summary {
    static func + (left: Summary, right: Summary) -> Summary {
        var summary = Summary()
        summary.stakeShares = left.stakeShares + right.stakeShares
        summary.stakedHearts = left.stakedHearts + right.stakedHearts
        summary.liquidHearts = left.liquidHearts + right.liquidHearts
        summary.interestHearts = left.interestHearts + right.interestHearts
        PayPeriod.allCases.forEach { payPeriod in
            let leftPayPeriod = left.interestPayPeriodHearts[payPeriod] ?? 0
            let rightPayPeriod = right.interestPayPeriodHearts[payPeriod] ?? 0
            summary.interestPayPeriodHearts[payPeriod] = leftPayPeriod + rightPayPeriod
        }
        summary.bigPayDayHearts = left.bigPayDayHearts + right.bigPayDayHearts
        return summary
    }
}
