// ERC20TokenModel.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import EVMChain
import Foundation
import web3

struct ERC20Token: Equatable, Hashable, Identifiable {
    var id: String { address.value }
    var symbol: String
    var decimals: Int = 0
    var address: EthereumAddress
    var amount: BigUInt
    var adjustedAmount: BigUInt {
        let power = Int(pow(10.0, Double(decimals)))
        return amount / BigUInt(power)
    }
}
