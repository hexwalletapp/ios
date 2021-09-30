//
//  GlobalInfoModel.swift
//  HEX
//
//  Created by Joe Blau on 9/29/21.
//

import Foundation
import BigInt
import HEXSmartContract

struct GlobalInfo: Equatable {
    var lockedHeartsTotal: BigUInt = 0
    var nextStakeSharesTotal: BigUInt = 0
    var shareRate: BigUInt = 0
    var stakePenaltyTotal: BigUInt = 0
    var dailyDataCount: BigUInt = 0
    var stakeSharesTotal: BigUInt = 0
    var latestStakeId: BigUInt = 0
    var unclaimedSatoshisTotal: BigUInt = 0
    var claimedSatoshisTotal: BigUInt = 0
    var claimedBtcAddrCount: BigUInt = 0
    
    init() {}
    
    init(globalInfo: HEXSmartContract.GlobalInfo.Response) {
        self.lockedHeartsTotal = globalInfo.lockedHeartsTotal
        self.nextStakeSharesTotal = globalInfo.nextStakeSharesTotal
        self.shareRate = globalInfo.shareRate
        self.stakePenaltyTotal = globalInfo.stakePenaltyTotal
        self.dailyDataCount = globalInfo.dailyDataCount
        self.stakeSharesTotal = globalInfo.stakeSharesTotal
        self.latestStakeId = globalInfo.latestStakeId
        self.unclaimedSatoshisTotal = globalInfo.unclaimedSatoshisTotal
        self.claimedSatoshisTotal = globalInfo.claimedSatoshisTotal
        self.claimedBtcAddrCount = globalInfo.claimedBtcAddrCount
    }
}
