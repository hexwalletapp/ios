//
//  Formatter+Extensions.swift
//  Formatter+Extensions
//
//  Created by Joe Blau on 9/12/21.
//

import Foundation

extension NSNumber {
    
    var hex: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positiveSuffix = " ʜᴇx"
        return formatter.string(from: self) ?? ""
    }
    
    var tshares: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positiveSuffix = " ᴛsʜᴀʀᴇs"
        return formatter.string(from: self) ?? ""
    }
    var currency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.positiveSuffix = " ᴜsᴅ"
        return formatter.string(from: self) ?? ""
    }
}
