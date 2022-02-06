// DEXLiquidityModel.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import EVMChain
import Foundation
import web3

struct DEXLiquidity: Equatable, Hashable, Identifiable {
    var id: EthereumAddress { address }
    var chain: Chain
    var address: EthereumAddress
    var version: UniswapVersion
    var tokenA: ERC20Token
    var tokenB: ERC20Token

    var pairPool: String {
        "\(tokenA.symbol)/\(tokenB.symbol)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(chain)
        hasher.combine(address)
        hasher.combine(version)
    }

    static func == (lhs: DEXLiquidity, rhs: DEXLiquidity) -> Bool {
        lhs.chain == rhs.chain &&
            lhs.address == rhs.address &&
            lhs.version == rhs.version
    }
}
