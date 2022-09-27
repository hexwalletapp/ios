//// StakeTotalModel.swift
//// Copyright (c) 2022 Joe Blau
//
//import BigInt
//import Foundation
//
//struct StakeTotal: Codable, Hashable, Equatable {
//    var stakeShares: BigUInt = 0
//    var stakedHearts: BigUInt = 0
//    var interestHearts: BigUInt = 0
//    var interestDailyHearts: BigUInt = 0
//    var interestWeeklyHearts: BigUInt = 0
//    var interestMonthlyHearts: BigUInt = 0
//    var bigPayDayHearts: BigUInt = 0
//
//    var balanceHearts: BigUInt {
//        stakedHearts + interestHearts + bigPayDayHearts
//    }
//
//
//
//    func interest(payout: PayPeriod) -> BigUInt {
//        switch payout {
//        case .daily: return interestDailyHearts
//        case .weekly: return interestWeeklyHearts
//        case .monthly: return interestMonthlyHearts
//        }
//    }
//}
