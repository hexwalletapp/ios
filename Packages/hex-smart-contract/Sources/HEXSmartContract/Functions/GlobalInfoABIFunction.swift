// GlobalInfoABIFunction.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Foundation
import web3

public struct GlobalInfo: ABIFunction {
    public static let name = "globalInfo"
    public var gasPrice: BigUInt? = nil
    public var gasLimit: BigUInt? = nil
    public var contract = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")
    public var from: EthereumAddress? = nil

    public func encode(to _: ABIFunctionEncoder) throws {}

    // MARK: - Response

    public struct Response: ABIResponse, Equatable {
        public static var types = [ABIType.Type](repeating: BigUInt.self, count: 13)
        public let lockedHeartsTotal: BigUInt
        public let nextStakeSharesTotal: BigUInt
        public let shareRate: BigUInt
        public let stakePenaltyTotal: BigUInt
        public let dailyDataCount: BigUInt
        public let stakeSharesTotal: BigUInt
        public let latestStakeId: BigUInt
        public let unclaimedSatoshisTotal: BigUInt
        public let claimedSatoshisTotal: BigUInt
        public let claimedBtcAddrCount: BigUInt

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            lockedHeartsTotal = try values[0].decoded()
            nextStakeSharesTotal = try values[1].decoded()
            shareRate = try values[2].decoded()
            stakePenaltyTotal = try values[3].decoded()
            dailyDataCount = try values[4].decoded()
            stakeSharesTotal = try values[5].decoded()
            latestStakeId = try values[6].decoded()
            unclaimedSatoshisTotal = try values[7].decoded()
            claimedSatoshisTotal = try values[8].decoded()
            claimedBtcAddrCount = try values[9].decoded()
        }
    }
}
