//
//  CurrentDayABIFunction.swift
//  CurrentDayABIFunction
//
//  Created by Joe Blau on 9/13/21.
//

import Foundation
import web3
import BigInt

struct CurrentDay: ABIFunction {
    static let name = "currentDay"
    let gasPrice: BigUInt? = nil
    let gasLimit: BigUInt? = nil
    var contract = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")
    let from: EthereumAddress? = nil
        
    // MARK: - Params

    func encode(to encoder: ABIFunctionEncoder) throws {}
    
    // MARK: - Response
    struct Response: ABIResponse {
        static var types: [ABIType.Type] = [BigUInt.self]
        let day: BigUInt
        
        init?(values: [ABIDecoder.DecodedValue]) throws {
            self.day = try values[0].decoded()
        }
    }
}
