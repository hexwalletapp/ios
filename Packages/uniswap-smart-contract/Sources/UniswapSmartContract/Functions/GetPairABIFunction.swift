// GetPairABIFunction.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
import web3

public struct GetPair: ABIFunction {
    public static let name = "getPair"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract = EthereumAddress("0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f")
    public let from: EthereumAddress? = nil

    // MARK: - Params

    let first: EthereumAddress
    let second: EthereumAddress

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(first)
        try encoder.encode(second)
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
