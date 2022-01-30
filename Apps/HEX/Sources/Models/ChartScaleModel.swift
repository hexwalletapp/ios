// ChartScaleModel.swift
// Copyright (c) 2022 Joe Blau

import Foundation

enum ChartScale: Identifiable, CaseIterable, CustomStringConvertible {
    var id: Self { self }
    case log
    case liner

    var description: String {
        switch self {
        case .log: return "Log"
        case .liner: return "Liner"
        }
    }
}
