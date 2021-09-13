//
//  HEXABI.swift
//  HEXABI
//
//  Created by Joe Blau on 9/4/21.
//

import Foundation
import web3
import BigInt

struct StakeCount_Parameter: ABIFunction {
    static let name = "stakeCount"
    let gasPrice: BigUInt? = BigUInt(0)
    let gasLimit: BigUInt? = BigUInt(0)
    var contract = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")
    let from: EthereumAddress? = nil
        
    // MARK: - Params
    let stakeAddress: EthereumAddress

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(stakeAddress)
    }
    
    // MARK: - Response
    struct Response: ABIResponse {
        static var types: [ABIType.Type] = [BigUInt.self]
        let stakeCount: BigUInt
        
        init?(values: [ABIDecoder.DecodedValue]) throws {
            self.stakeCount = try values[0].decoded()
        }
    }
}

struct StakeLists_Parameter: ABIFunction {
    static let name = "stakeLists"
    var gasPrice: BigUInt? = BigUInt(0)
    var gasLimit: BigUInt? = BigUInt(0)
    var contract = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")
    var from: EthereumAddress? = nil
    
    // MARK: - Params
    let stakeAddress: EthereumAddress
    let stakeIndex: BigUInt
    
    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(stakeAddress)
        try encoder.encode(stakeIndex)
    }
    
    // MARK: - Response
    struct Response: ABIResponse, Equatable, Identifiable {
        static var types: [ABIType.Type] = [BigUInt.self, BigUInt.self, BigUInt.self, UInt16.self, UInt16.self, UInt16.self, Bool.self]
        
        var id: BigUInt { stakeId }
        let stakeId: BigUInt
        let stakedHearts: BigUInt
        let stakeShares: BigUInt
        let lockedDay: UInt16
        let stakedDays: UInt16
        let unlockedDay: UInt16
        let isAutoStake: Bool
        
        init?(values: [ABIDecoder.DecodedValue]) throws {
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
