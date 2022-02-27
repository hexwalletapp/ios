// StakeCountABIFunction.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import web3

public struct StakeCount_Parameter: ABIFunction {
    public static let name = "stakeCount"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract = EthereumAddress("0x8bd3d1472a656e312e94fb1bbdd599b8c51d18e3")
    public let from: EthereumAddress? = nil

    // MARK: - Params

    let user: EthereumAddress

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(user)
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
