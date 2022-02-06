// ObserveABIFunction.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import web3

public struct ObserveABIFunction: ABIFunction {
    public static let name = "observe"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract: EthereumAddress
    public let from: EthereumAddress? = nil

    let secondsAgos: [UInt32]

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(secondsAgos)
    }

    // MARK: - Response

    public struct Response: ABIResponse {
        public static var types: [ABIType.Type] = [ABIArray<BigInt>.self, ABIArray<BigUInt>.self]
        let tickCumulatives: [BigInt]
        let secondsPerLiquidityCumulativeX128s: [BigUInt]

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            tickCumulatives = try values[0].decodedArray()
            secondsPerLiquidityCumulativeX128s = try values[1].decodedArray()
        }
    }
}
