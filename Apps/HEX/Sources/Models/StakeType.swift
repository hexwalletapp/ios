// StakeType.swift
// Copyright (c) 2022 Joe Blau

import Foundation

enum StakeType: Codable, Hashable, Equatable, Identifiable, CustomStringConvertible {
    var id: Self { self }
    case native
    case hedron

    var shortName: String {
        switch self {
        case .native: return "Stake"
        case .hedron: return "HSI"
        }
    }

    var description: String {
        switch self {
        case .native: return "Native HEX stake"
        case .hedron: return "HEX Stake Instance"
        }
    }
}
