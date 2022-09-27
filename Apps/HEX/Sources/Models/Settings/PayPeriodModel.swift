// PayPeriodModel.swift
// Copyright (c) 2022 Joe Blau

import SwiftUI

enum PayPeriod: Codable, Identifiable, CaseIterable, CustomStringConvertible {
    var id: Self { self }
    case daily
    case weekly
    case monthly

    var description: String {
        switch self {
        case .daily: return "Daily Payout"
        case .weekly: return "Weekly Payout"
        case .monthly: return "Monthly Payout"
        }
    }

    var label: Label<Text, Image> {
        switch self {
        case .daily: return Label(description, systemImage: "1.square.fill")
        case .weekly: return Label(description, systemImage: "7.square.fill")
        case .monthly: return Label(description, systemImage: "30.square.fill")
        }
    }

    var days: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .monthly: return 30
        }
    }
}
