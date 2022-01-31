// TimeAxisValueFormatter.swift
// Copyright (c) 2022 Joe Blau

import Charts
import Foundation

class TimeAxisValueFormatter: NSObject, AxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    var timeScale: TimeScale

    init(chart: BarLineChartViewBase, timeScale: TimeScale) {
        self.chart = chart
        self.timeScale = timeScale
    }

    public func stringForValue(_ value: Double, axis _: AxisBase?) -> String {
        guard let maxValues = chart?.data?.xMax else { return "" }

        let timeAgo: Double
        switch timeScale {
        case .day:
            timeAgo = (value - maxValues) * 86400
            let date = Date(timeIntervalSinceNow: timeAgo)
            return Formatter.dayTimeDateFormatter.string(from: date)
        case .hour:
            timeAgo = (value - maxValues) * 3600
            let date = Date(timeIntervalSinceNow: timeAgo)
            return Formatter.hourTimeDateFormatter.string(from: date)
        case .minute:
            timeAgo = (value - maxValues) * 60
            let date = Date(timeIntervalSinceNow: timeAgo)
            return Formatter.minuteTimeDateFormatter.string(from: date)
        }
    }
}
