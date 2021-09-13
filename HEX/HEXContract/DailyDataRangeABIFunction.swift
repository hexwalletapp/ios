//
//  HEXABI.swift
//  HEXABI
//
//  Created by Joe Blau on 9/4/21.
//

import Foundation
import web3
import BigInt

struct DailyDataRange_Parameter: ABIFunction {
    static let name = "dailyDataRange"
    var gasPrice: BigUInt? = nil
    var gasLimit: BigUInt? = nil
    var contract = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")
    var from: EthereumAddress? = nil
    
    // MARK: - Params
    let beginDay: BigUInt
    let endDay: BigUInt
    
    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(beginDay)
        try encoder.encode(endDay)
    }
    
    // MARK: - Response
    struct Response: ABIResponse {
        static var types: [ABIType.Type] = [ABIArray<BigUInt>.self]
        let list: [BigUInt]
        
        init?(values: [ABIDecoder.DecodedValue]) throws {
            self.list = try values[0].decodedArray()
        }
    }
}
