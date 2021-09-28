// DailyDataRangeABIFunction.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
import web3

public struct DailyDataRange_Parameter: ABIFunction {
    public static let name = "dailyDataRange"
    public var gasPrice: BigUInt? = nil
    public var gasLimit: BigUInt? = nil
    public var contract = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")
    public var from: EthereumAddress? = nil

    // MARK: - Params

    let beginDay: BigUInt
    let endDay: BigUInt

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(beginDay)
        try encoder.encode(endDay)
    }

    // MARK: - Response

    public struct Response: ABIResponse {
        public static var types: [ABIType.Type] = [ABIArray<BigUInt>.self]
        let list: [BigUInt]

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            list = try values[0].decodedArray()
        }
    }
}
