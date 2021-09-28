// ChainModel.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI

enum Chain: Codable, Identifiable, CaseIterable, CustomStringConvertible {
    var id: Self { self }

    case ethereum, pulse

    var gradient: [Color] {
        switch self {
        case .ethereum: return k.HEX_COLORS
        case .pulse: return k.PULSE_COLORS
        }
    }

    var description: String {
        switch self {
        case .ethereum: return "Ethereum"
        case .pulse: return "Pulse"
        }
    }
}
