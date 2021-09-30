// GlobalInfoModel.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
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
        lockedHeartsTotal = globalInfo.lockedHeartsTotal
        nextStakeSharesTotal = globalInfo.nextStakeSharesTotal
        shareRate = globalInfo.shareRate
        stakePenaltyTotal = globalInfo.stakePenaltyTotal
        dailyDataCount = globalInfo.dailyDataCount
        stakeSharesTotal = globalInfo.stakeSharesTotal
        latestStakeId = globalInfo.latestStakeId
        unclaimedSatoshisTotal = globalInfo.unclaimedSatoshisTotal
        claimedSatoshisTotal = globalInfo.claimedSatoshisTotal
        claimedBtcAddrCount = globalInfo.claimedBtcAddrCount
    }
}
