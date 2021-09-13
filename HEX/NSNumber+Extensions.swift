//
//  Formatter+Extensions.swift
//  Formatter+Extensions
//
//  Created by Joe Blau on 9/12/21.
//

import Foundation

extension NSNumber {
    
    var hexString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positiveSuffix = " ʜᴇx"
        return formatter.string(from: self) ?? ""
    }
    
    var tshareString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positiveSuffix = " ᴛsʜᴀʀᴇs"
        return formatter.string(from: self) ?? ""
    }
    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.positiveSuffix = " ᴜsᴅ"
        return formatter.string(from: self) ?? ""
    }
}
