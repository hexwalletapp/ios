// CryptoCompareResponse.swift
// Copyright (c) 2021 Joe Blau

import Foundation

public struct CryptoCompareResponse: Codable, Equatable {
    var Response: String
    var Message: String
    var HasWarning: Bool
    var `Type`: Int
    public var Data: CandleData
}
