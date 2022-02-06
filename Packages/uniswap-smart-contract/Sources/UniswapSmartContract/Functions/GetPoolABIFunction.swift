// GetPoolABIFunction.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import web3

public struct GetPool: ABIFunction {
    public static let name = "getPool"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract = EthereumAddress("0x1f98431c8ad98523631ae4a59f267346ea31f984")
    public let from: EthereumAddress? = nil

    // MARK: - Params

    let tokenA: EthereumAddress
    let tokenB: EthereumAddress
    let fee: BigUInt

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(tokenA)
        try encoder.encode(tokenB)
        try encoder.encode(fee, staticSize: 24)
    }

    // MARK: - Response

    public struct Response: ABIResponse {
        public static var types: [ABIType.Type] = [EthereumAddress.self]
        let address: EthereumAddress

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            address = try values[0].decoded()
        }
    }
}
