// OHLCVData.swift
// Copyright (c) 2021 Joe Blau

import Foundation

public struct OHLCVData: Codable, Equatable {
    public var time: Date
    public var open: Double
    public var high: Double
    public var low: Double
    public var close: Double
    public var volume: Double
    
    public init(time: Date,
         open: Double,
         high: Double,
         low: Double,
         close: Double,
         volume: Double) {
        self.time = time
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }
}
