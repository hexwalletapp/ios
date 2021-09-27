// StakeListsABIFunction.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
import web3

public struct StakeLists_Parameter: ABIFunction {
    public static let name = "stakeLists"
    public var gasPrice: BigUInt? = nil
    public var gasLimit: BigUInt? = nil
    public var contract = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")
    public var from: EthereumAddress? = nil

    // MARK: - Params

    let stakeAddress: EthereumAddress
    let stakeIndex: BigUInt

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(stakeAddress)
        try encoder.encode(stakeIndex)
    }

    // MARK: - Response

    public struct Response: ABIResponse, Codable, Hashable, Equatable, Identifiable {
        public static var types: [ABIType.Type] = [BigUInt.self, BigUInt.self, BigUInt.self, UInt16.self, UInt16.self, UInt16.self, Bool.self]

        public var id: BigUInt { stakeId }
        let stakeId: BigUInt
        let stakedHearts: BigUInt
        let stakeShares: BigUInt
        let lockedDay: UInt16
        let stakedDays: UInt16
        let unlockedDay: UInt16
        let isAutoStake: Bool
        var percentComplete: Double = 0.0
        var interestHearts: BigUInt = 0
        var interestSevenDayHearts: BigUInt = 0

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            stakeId = try values[0].decoded()
            stakedHearts = try values[1].decoded()
            stakeShares = try values[2].decoded()
            lockedDay = try values[3].decoded()
            stakedDays = try values[4].decoded()
            unlockedDay = try values[5].decoded()
            isAutoStake = try values[6].decoded()
        }
    }
}

public typealias Stake = StakeLists_Parameter.Response
