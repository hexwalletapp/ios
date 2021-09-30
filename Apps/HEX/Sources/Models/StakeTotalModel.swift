// StakeTotalModel.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation

struct StakeTotal: Codable, Hashable, Equatable {
    var stakeShares: BigUInt = 0
    var stakedHearts: BigUInt = 0
    var interestHearts: BigUInt = 0
    var interestSevenDayHearts: BigUInt = 0
    var bigPayDayHearts: BigUInt = 0
    
    var balanceHearts: BigUInt {
        stakedHearts + interestHearts + bigPayDayHearts
    }
}
