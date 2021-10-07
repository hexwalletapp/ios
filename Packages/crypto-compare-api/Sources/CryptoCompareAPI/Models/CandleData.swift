// CandleData.swift
// Copyright (c) 2021 Joe Blau

import Foundation

public struct CandleData: Codable, Equatable {
    var Aggregated: Bool
    var TimeFrom: Date
    var TimeTo: Date
    public var Data: [OHLCVData]
}
