// HexContractOnChain.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import EVMChain
import Foundation
import HEXSmartContract
import web3

struct HexContractOnChain: Equatable {
//    func data(from chain: Chain) -> OnChainData {
//        switch chain {
//        case .pulse: return plsData
//        case .ethereum: return ethData
//        }
//    }

    var ethData = OnChainData()
    var plsData = OnChainData()
}

struct OnChainData: Equatable {
    var hexUsd: Double = 0
    var v3Liquidity = [EthereumAddress: BigUInt]()
    var price: NSNumber { NSNumber(value: hexUsd) }
    var speculativePrice = NSNumber(1)
    var currentDay: BigUInt = 0
    var dailyData = [DailyData]()
    var globalInfo = GlobalInfo()
}
