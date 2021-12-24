// HexContractOnChain.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
import HEXREST
import HEXSmartContract

struct HexContractOnChain: Equatable {
    func data(from chain: Chain) -> OnChainData {
        switch chain {
        case .pulse: return plsData
        case .ethereum: return ethData
        }
    }

    var ethData = OnChainData()
    var plsData = OnChainData()
}

struct OnChainData: Equatable {
    var hexPrice = HEXPrice()
    var price: NSNumber { NSNumber(value: hexPrice.hexUsd) }
    var speculativePrice = NSNumber(1)
    var currentDay: BigUInt = 0
    var dailyData = [DailyData]()
    var globalInfo = GlobalInfo()
}
