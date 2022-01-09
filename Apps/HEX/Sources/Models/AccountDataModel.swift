// AccountDataModel.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import IdentifiedCollections

struct AccountData: Codable, Hashable, Equatable, Identifiable {
    var id: String { account.id }
    var account: Account
    var stakes = IdentifiedArrayOf<Stake>()
    var total = StakeTotal()
    var liquidBalanceHearts: BigUInt = 0
    var hexPrice: Double = 0
    var isLoading = false
}
