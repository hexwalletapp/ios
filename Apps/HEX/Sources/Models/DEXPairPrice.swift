// DEXPairPrice.swift
// Copyright (c) 2022 Joe Blau

import Foundation

struct Token: Codable {
    var id: String
    var name: String
    var symbol: String
}

struct Pair: Codable {
    var token0: Token
    var token0Price: String
    var token1: Token
    var token1Price: String
}

struct DexData: Codable {
    var pair: Pair
}

struct PulseDexPrice: Codable {
    var data: DexData
}

struct CommunityDexPrice: Codable {
    var lastUpdated: String
    var hexEth: String
    var hexUsd: String
    var hexBtc: String
}
