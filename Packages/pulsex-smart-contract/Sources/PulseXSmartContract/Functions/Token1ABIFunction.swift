// Token1ABIFunction.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import web3

public struct Token1ABIFunction: ABIFunction {
    public static let name = "token1"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract: EthereumAddress
    public let from: EthereumAddress? = nil

    public func encode(to _: ABIFunctionEncoder) throws {}

    // MARK: - Response

    public struct Response: ABIResponse {
        public static var types: [ABIType.Type] = [EthereumAddress.self]
        let address: EthereumAddress

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            address = try values[0].decoded()
        }
    }
}
