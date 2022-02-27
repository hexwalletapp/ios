// Stake+Extensions.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import HedronSmartContract
import HEXSmartContract

struct StakeResponse {
    let stakeId: BigUInt
    let stakedHearts: BigUInt
    let stakeShares: BigUInt
    let lockedDay: UInt16
    let stakedDays: UInt16
    let unlockedDay: UInt16
    let isAutoStake: Bool
    let stakeType: StakeType
}

extension HedronSmartContract.StakeLists_Parameter.Response {
    var response: StakeResponse {
        StakeResponse(stakeId: stakeId,
                      stakedHearts: stakedHearts,
                      stakeShares: stakeShares,
                      lockedDay: lockedDay,
                      stakedDays: stakedDays,
                      unlockedDay: unlockedDay,
                      isAutoStake: isAutoStake,
                      stakeType: .hedron)
    }
}

extension HEXSmartContract.StakeLists_Parameter.Response {
    var response: StakeResponse {
        StakeResponse(stakeId: stakeId,
                      stakedHearts: stakedHearts,
                      stakeShares: stakeShares,
                      lockedDay: lockedDay,
                      stakedDays: stakedDays,
                      unlockedDay: unlockedDay,
                      isAutoStake: isAutoStake,
                      stakeType: .native)
    }
}
