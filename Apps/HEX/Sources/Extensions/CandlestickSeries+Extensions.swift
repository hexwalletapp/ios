// CandlestickSeries+Extensions.swift
// Copyright (c) 2021 Joe Blau

import Foundation
import LightweightCharts

extension CandlestickSeries: Equatable {
    public static func == (lhs: CandlestickSeries, rhs: CandlestickSeries) -> Bool {
        lhs.jsName == rhs.jsName
    }
}
