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
        HistogramData(color: nil,
                      time: .utc(timestamp: time.timeIntervalSince1970),
                      value: volumeto)
    }
}