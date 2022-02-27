// StakeListsABIFunction.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Foundation
import web3

public struct StakeLists_Parameter: ABIFunction {
    public static let name = "stakeLists"
    public var gasPrice: BigUInt? = nil
    public var gasLimit: BigUInt? = nil
    public var contract = EthereumAddress("0x8bd3d1472a656e312e94fb1bbdd599b8c51d18e3")
    public var from: EthereumAddress? = nil

    // MARK: - Params

    let user: EthereumAddress
    let hsiIndex: BigUInt

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(user)
        try encoder.encode(hsiIndex)
    }

    // MARK: - Response

    public struct Response: ABIResponse, Equatable, Identifiable {
        public static var types: [ABIType.Type] = [BigUInt.self, BigUInt.self, BigUInt.self, UInt16.self, UInt16.self, UInt16.self, Bool.self]

        public var id: BigUInt { stakeId }
        public let stakeId: BigUInt
        public let stakedHearts: BigUInt
        public let stakeShares: BigUInt
        public let lockedDay: UInt16
        public let stakedDays: UInt16
        public let unlockedDay: UInt16
        public let isAutoStake: Bool

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
