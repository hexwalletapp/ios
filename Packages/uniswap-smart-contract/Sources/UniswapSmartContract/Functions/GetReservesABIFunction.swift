// GetReservesABIFunction.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
import web3

public struct GetReserves: ABIFunction {
    public static let name = "getReserves"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract: EthereumAddress
    public let from: EthereumAddress? = nil

    public func encode(to _: ABIFunctionEncoder) throws {}

    // MARK: - Response

    public struct Response: ABIResponse {
        public static var types: [ABIType.Type] = [BigUInt.self, BigUInt.self, UInt32.self]
        let reserve0: BigUInt
        let reserve1: BigUInt
        let blockTimestampLast: UInt32

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            reserve0 = try values[0].decoded()
            reserve1 = try values[1].decoded()
            blockTimestampLast = try values[2].decoded()
        }
    }
}
