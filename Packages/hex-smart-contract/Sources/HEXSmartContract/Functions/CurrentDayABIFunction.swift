// CurrentDayABIFunction.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import web3

public struct CurrentDay: ABIFunction {
    public static let name = "currentDay"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public var contract = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")
    public let from: EthereumAddress? = nil

    // MARK: - Params

    public func encode(to _: ABIFunctionEncoder) throws {}

    // MARK: - Response

    public struct Response: ABIResponse {
        public static var types: [ABIType.Type] = [BigUInt.self]
        let day: BigUInt

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            day = try values[0].decoded()
        }
    }
}
