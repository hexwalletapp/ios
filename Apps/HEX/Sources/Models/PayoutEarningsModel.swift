// PayoutEarningsModel.swift
// Copyright (c) 2022 Joe Blau

import Foundation

enum PayoutEarnings: Identifiable, CaseIterable, CustomStringConvertible {
    var id: Self { self }
    case dailyTotal
    case weeklyTotal
    case monthlyTotal

    var description: String {
        switch self {
        case .dailyTotal: return "Daily Payout"
        case .weeklyTotal: return "Weekly Payout"
        case .monthlyTotal: return "Monthly Payout"
        }
    }

    var days: Int {
        switch self {
        case .dailyTotal: return 1
        case .weeklyTotal: return 7
        case .monthlyTotal: return 30
        }
    }
}
