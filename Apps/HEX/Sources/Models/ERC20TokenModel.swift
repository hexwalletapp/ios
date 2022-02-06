//
//  ERC20TokenModel.swift
//  HEX
//
//  Created by Joe Blau on 2/5/22.
//

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
