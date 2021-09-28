//
//  AccountDataModel.swift
//  HEX
//
//  Created by Joe Blau on 9/28/21.
//

import Foundation

struct AccountData: Codable, Hashable, Equatable, Identifiable {
    var id: String { account.id }
    var account: Account
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
