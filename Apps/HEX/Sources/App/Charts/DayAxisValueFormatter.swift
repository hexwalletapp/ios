//
//  DayAxisValueFormatter.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Foundation
import Charts

class TimeAxisValueFormatter: NSObject, AxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    var timeScale: TimeScale
    
    init(chart: BarLineChartViewBase, timeScale: TimeScale) {
        self.chart = chart
        self.timeScale = timeScale
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let maxValues = self.chart?.data?.xMax else { return "" }
        
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
