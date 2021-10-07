// OHLCVData.swift
// Copyright (c) 2021 Joe Blau

import Foundation

public struct OHLCVData: Codable, Equatable {
    public var time: Date
    public var high: Double
    public var low: Double
    public var open: Double
    public var volumefrom: Double
    public var volumeto: Double
    public var close: Double
    var conversionType: String
    var conversionSymbol: String
}
