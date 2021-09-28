// AccountModel.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI

struct Account: Codable, Hashable, Equatable, Identifiable {
    var id: String { address }
    var name: String = ""
    var address: String = ""
    var chain: Chain = .ethereum
    var stakes = [Stake]()
    var total = StakeTotal()
    
    
    //    var dailyData = [DailyData]()
//    var stakesBeginDay = UInt16.max
//    var stakesEndDay = UInt16.min
    
//    var hexPrice: Double = 0
//    var stakeCount = 0
//    var stakes = [Stake]()
//    var sharesPerDay = [BigUInt]()
//    var dailyDataList = [DailyData]()

}
