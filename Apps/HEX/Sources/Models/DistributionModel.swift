// DistributionModel.swift
// Copyright (c) 2022 Joe Blau

import Foundation

enum Distribution: Equatable, Identifiable, CaseIterable, CustomStringConvertible {
    public var id: Self { self }

    case evenly
    case firstOfYear
    case firstOfMonth
    case custom

    var description: String {
        switch self {
        case .evenly: return "Evenly"
        case .firstOfYear: return "First Day Of Year"
        case .firstOfMonth: return "First Day Of Month"
        case .custom: return "Custom"
        }
    }
}
