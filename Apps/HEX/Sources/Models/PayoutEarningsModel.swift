// PayoutEarningsModel.swift
// Copyright (c) 2022 Joe Blau

import SwiftUI

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

    var label: Label<Text, Image> {
        switch self {
        case .dailyTotal: return Label(description, systemImage: "1.square.fill")
        case .weeklyTotal: return Label(description, systemImage: "7.square.fill")
        case .monthlyTotal: return Label(description, systemImage: "30.square.fill")
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
