// PriceAxisValueFormatter.swift
// Copyright (c) 2022 Joe Blau

import Charts
import Foundation

class PriceAxisValueFormatter: NSObject, AxisValueFormatter {
    var chartScale: ChartScale

    init(chartScale: ChartScale) {
        self.chartScale = chartScale
    }

    public func stringForValue(_ value: Double, axis _: AxisBase?) -> String {
        let number: NSNumber
        switch chartScale {
        case .log: number = NSNumber(value: pow(10, value))
        case .auto: number = NSNumber(value: value)
        }
        return Formatter.currencyFormatter.string(from: number) ?? ""
    }
}
