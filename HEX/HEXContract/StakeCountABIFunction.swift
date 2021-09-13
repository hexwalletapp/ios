//
//  StakeCountABIFunction.swift
//  StakeCountABIFunction
//
//  Created by Joe Blau on 9/13/21.
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
        static var types: [ABIType.Type] = [BigUInt.self]
        let stakeCount: BigUInt
        
        init?(values: [ABIDecoder.DecodedValue]) throws {
            self.stakeCount = try values[0].decoded()
        }
    }
}
