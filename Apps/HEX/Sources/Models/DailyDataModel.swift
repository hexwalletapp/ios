// DailyDataModel.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation

struct DailyData: Codable, Hashable, Equatable {
    let payout: BigUInt
    let shares: BigUInt
    let sats: BigUInt
}
