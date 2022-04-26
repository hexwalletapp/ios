// GetPairABIFunction.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import web3

public struct GetPair: ABIFunction {
    public static let name = "getPair"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract = EthereumAddress("0xb242aA8A863CfcE9fcBa2b9a6B00b4cd62343f27")
    public let from: EthereumAddress? = nil

    // MARK: - Params

    let tokenA: EthereumAddress
    let tokenB: EthereumAddress

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(tokenA)
        try encoder.encode(tokenB)
    }

    // MARK: - Response

    public struct Response: ABIResponse {
        public static var types: [ABIType.Type] = [BigInt.self]
        let address: EthereumAddress

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            address = try values[0].decoded()
        }
    }
}
