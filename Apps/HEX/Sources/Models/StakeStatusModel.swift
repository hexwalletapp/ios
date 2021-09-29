// StakeStatusModel.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI

enum StakeStatus: Codable, Equatable, CustomStringConvertible {
    case active, gracePeriod, goodAccounting, emergencyEnd, end, bleeding

    var description: String {
        switch self {
        case .active: return "Active"
        case .gracePeriod: return "Grace Period"
        case .goodAccounting: return "Good Accounting"
        case .emergencyEnd: return "Emergency End"
        case .end: return "End"
        case .bleeding: return "Bleeding"
        }
    }

    var systemName: String {
        switch self {
        case .active: return "checkmark.seal.fill"
        case .gracePeriod: return "xmark.octagon.fill"
        case .goodAccounting: return "lock.shield.fill"
        case .emergencyEnd: return "flame.fill"
        case .end: return "dollarsign.square.fill"
        case .bleeding: return "exclamationmark.octagon.fill"
        }
    }
}
