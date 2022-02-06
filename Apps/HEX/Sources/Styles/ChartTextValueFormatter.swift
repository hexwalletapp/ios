// ChartTextValueFormatter.swift
// Copyright (c) 2022 Joe Blau

import Charts
import Foundation

class PieChartTextValueFormatter: ValueFormatter {
    func stringForValue(_ value: Double, entry _: ChartDataEntry, dataSetIndex _: Int, viewPortHandler _: ViewPortHandler?) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: value))!
    }
}
