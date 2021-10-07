// ChartType.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI

protocol ChartTypeable: CaseIterable, CustomStringConvertible {
    var description: String { get }
}

enum ChartType: Identifiable, ChartTypeable {
    var id: Self { self }
    case candlestick
    case line

    var description: String {
        switch self {
        case .candlestick: return "Candlestick"
        case .line: return "Line"
        }
    }

    var icon: Image {
        switch self {
        case .candlestick: return Image("candlestick-chart.SFSymbol")
        case .line: return Image("line-chart.SFSymbol")
        }
    }
}
