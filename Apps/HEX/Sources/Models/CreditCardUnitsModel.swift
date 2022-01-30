// CreditCardUnitsModel.swift
// Copyright (c) 2022 Joe Blau

import Foundation

enum CreditCardUnits: Identifiable, CaseIterable, CustomStringConvertible {
    var id: Self { self }
    case usd
    case hex

    var description: String {
        switch self {
        case .usd: return "USD"
        case .hex: return "HEX"
        }
    }
}
