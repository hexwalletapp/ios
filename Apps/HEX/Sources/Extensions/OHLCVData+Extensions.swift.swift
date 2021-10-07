// OHLCVData+Extensions.swift.swift
// Copyright (c) 2021 Joe Blau

import CryptoCompareAPI
import Foundation
import LightweightCharts

extension OHLCVData {
    var lineData: LineData {
        LineData(time: .utc(timestamp: time.timeIntervalSince1970),
                 value: close)
    }

    var barData: BarData {
        BarData(time: .utc(timestamp: time.timeIntervalSince1970),
                open: open,
                high: high,
                low: low,
                close: close)
    }

    var volumeData: HistogramData {
        let color: ChartColor
        switch open < close {
        case true: color = ChartColor(.systemGreen.withAlphaComponent(0.6))
        case false: color = ChartColor(.systemRed.withAlphaComponent(0.6))
        }
        return HistogramData(color: color,
                             time: .utc(timestamp: time.timeIntervalSince1970),
                             value: volumefrom)
    }
}
