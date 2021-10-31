// Data.swift
// Copyright (c) 2021 Joe Blau

import Foundation

struct BitqueryResponse: Codable {
    var data: ResponseData
}

struct ResponseData: Codable {
    var ethereum: Ethereum
}

struct Ethereum: Codable {
    var dexTrades: [DexTrade]
}

struct DexTrade: Codable {
    var timeInterval: Interval
    var quotePrice: Double
    var maximum_price: Double
    var minimum_price: Double
    var open_price: String
    var close_price: String
    var tradeAmount: Double
}

struct Interval: Codable {
    var minute: String?
    var hour: String?
    var day: String?
    var month: String?
}
