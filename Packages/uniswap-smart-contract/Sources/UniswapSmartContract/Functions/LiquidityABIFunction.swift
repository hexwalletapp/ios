// LiquidityABIFunction.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import web3

public struct LiquidityABIFunction: ABIFunction {
    public static let name = "liquidity"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract: EthereumAddress
    public let from: EthereumAddress? = nil

    public func encode(to _: ABIFunctionEncoder) throws {}

    // MARK: - Response

    public struct Response: ABIResponse {
        public static var types: [ABIType.Type] = [BigUInt.self]
        let liquidity: BigUInt

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            liquidity = try values[0].decoded()
        }
    }
}
