// Slot0ABIFunction.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import web3

public struct Slot0ABIFunction: ABIFunction {
    public static let name = "slot0"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract: EthereumAddress
    public let from: EthereumAddress? = nil

    public func encode(to _: ABIFunctionEncoder) throws {}

    // MARK: - Response

    public struct Response: ABIResponse {
        public static var types: [ABIType.Type] = [BigUInt.self, BigInt.self, UInt16.self, UInt16.self, UInt16.self, UInt8.self, Bool.self]
        let sqrtPriceX96: BigUInt
        let tick: BigInt
        let observationIndex: UInt16
        let observationCardinality: UInt16
        let observationCardinalityNext: UInt16
        let feeProtocol: UInt8
        let unlocked: Bool

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            sqrtPriceX96 = try values[0].decoded()
            tick = try values[1].decoded()
            observationIndex = try values[2].decoded()
            observationCardinality = try values[3].decoded()
            observationCardinalityNext = try values[4].decoded()
            feeProtocol = try values[5].decoded()
            unlocked = try values[6].decoded()
        }
    }
}
