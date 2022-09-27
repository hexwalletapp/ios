// CreditCardUnitsModel.swift
// Copyright (c) 2022 Joe Blau

import Foundation
import SwiftUI

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

    var label: Label<Text, Image> {
        switch self {
        case .usd: return Label(description, systemImage: "dollarsign.square.fill")
        case .hex: return Label(description, image: "hex-logo.SFSymbol")
        }
    }
}
