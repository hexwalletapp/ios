// AccountDataModel.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
import IdentifiedCollections

struct AccountData: Codable, Hashable, Equatable, Identifiable {
    var id: String { account.id }
    var account: Account
    var stakes = IdentifiedArrayOf<Stake>()
    var total = StakeTotal()
    var balanceHearts: BigUInt = 0
}
