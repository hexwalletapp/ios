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
    let gasPrice: BigUInt? = nil
    let gasLimit: BigUInt? = nil
    var contract = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")
    let from: EthereumAddress? = nil
        
    // MARK: - Params
    let stakeAddress: EthereumAddress

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(stakeAddress)
    }
    
    // MARK: - Response
    struct Response: ABIResponse {
        static var types: [ABIType.Type] = [BigInt.self]
        let stakeCount: BigInt
        
        init?(values: [ABIDecoder.DecodedValue]) throws {
            self.stakeCount = try values[0].decoded()
        }
    }
}

struct StakeLists_Parameter: ABIFunction {
    static let name = "stakeLists"
    var gasPrice: BigUInt? = nil
    var gasLimit: BigUInt? = nil
    var contract = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")
    var from: EthereumAddress? = nil
    
    // MARK: - Params
    let stakeAddress: EthereumAddress
    let stakeIndex: BigInt
    
    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(stakeAddress)
        try encoder.encode(stakeIndex)
    }
    
    // MARK: - Response
    struct Respone: ABIResponse {
        static var types: [ABIType.Type] = [BigInt.self]
        
        let bi: BigInt
//        let stakeId: Int
//        let stakedHearts: BigInt
//        let stakeShares: BigInt
//        let lockedDay: UInt
//        let stakedDays: UInt
//        let unlockedDay: UInt
//        let isAutoStake: Bool
        
        init?(values: [ABIDecoder.DecodedValue]) throws {
            self.bi = try values[0].decoded()
            print(self.bi)
//            self.stakeCount = try values[0].decoded()
        }
    }
}
