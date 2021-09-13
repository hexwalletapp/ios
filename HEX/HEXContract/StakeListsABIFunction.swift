//
//  StakeListsABIFunction.swift
//  StakeListsABIFunction
//
//  Created by Joe Blau on 9/13/21.
//

import Foundation
import web3
import BigInt

struct StakeLists_Parameter: ABIFunction {
    static let name = "stakeLists"
    var gasPrice: BigUInt? = nil
    var gasLimit: BigUInt? = nil
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
        var interestHearts: BigUInt = 0
        
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

