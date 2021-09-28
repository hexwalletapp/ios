// StakeCountABIFunction.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
import web3

public struct StakeCount_Parameter: ABIFunction {
    public static let name = "stakeCount"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")
    public let from: EthereumAddress? = nil

    // MARK: - Params

    let stakeAddress: EthereumAddress

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(stakeAddress)
    }

    // MARK: - Response

    public struct Response: ABIResponse {
        public static var types: [ABIType.Type] = [BigUInt.self]
        let stakeCount: BigUInt

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            stakeCount = try values[0].decoded()
        }
    }
}
