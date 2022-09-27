// HexContractOnChain.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import EVMChain
import Foundation
import HEXSmartContract
import web3

struct HEXERC20: Equatable {
    var data = [Chain: OnChainData]()
}

struct OnChainData: Equatable {
    var hexUsd: Double = 0
    var price: NSNumber { NSNumber(value: hexUsd) }
    var speculativePrice = NSNumber(1)
    var currentDay: BigUInt = 0
    var dailyData = [DailyData]()
    var globalInfo = GlobalInfo()
}
