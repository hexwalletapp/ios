// StakeModel.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation

struct Stake: Codable, Hashable, Equatable, Identifiable {
    var id: BigUInt { stakeId }
    let stakeId: BigUInt
    let stakedHearts: BigUInt
    let stakeShares: BigUInt
    let lockedDay: UInt16
    let stakedDays: UInt16
    let unlockedDay: UInt16
    let isAutoStake: Bool
    let percentComplete: Double
}
