// NSNumber+Extensions.swift
// Copyright (c) 2021 Joe Blau

import Foundation

extension NSNumber {
    var hexString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: self) ?? ""
    }

    var hexStringSuffix: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positiveSuffix = " ʜᴇx"
        return formatter.string(from: self) ?? ""
    }

    var shareString: String {
        let units = ["", "ᴋ-", "ᴍ-", "ɢ-", "ᴛ-", "ᴘ-", "ᴇ-"]
        let numerator = log10(doubleValue)
        let exp: Int

        switch numerator.sign {
        case .minus: exp = 0
        case .plus: exp = NSNumber(value: numerator / 3.0).intValue
        }

        let roundedNumber = NSNumber(value: round(10 * doubleValue / pow(1000.0, Double(exp))) / 10)

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positiveSuffix = " \(units[exp])sʜᴀʀᴇs"
        return formatter.string(from: roundedNumber) ?? ""
    }

    var currencyStringSuffix: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.positiveSuffix = " ᴜsᴅ"
        return formatter.string(from: self) ?? ""
    }

    var currencyNumberString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self) ?? ""
    }

    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: self) ?? ""
    }
    
    var currencyShortString: String {
        let units = ["", "ᴋ", "ᴍ", "ʙ", "ᴛ", "ᴏ̨", "ᴏ̨"]
        let numerator = log10(doubleValue)
        let exp: Int

        switch numerator.sign {
        case .minus: exp = 0
        case .plus: exp = NSNumber(value: numerator / 3.0).intValue
        }

        let roundedNumber = NSNumber(value: round(10 * doubleValue / pow(1000.0, Double(exp))) / 10)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.positiveSuffix = "\(units[exp])"
        return formatter.string(from: roundedNumber) ?? ""
    }

    var currencyWholeString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: self) ?? ""
    }

    var percentageString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter.string(from: self) ?? ""
    }

    var percentageFractionString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self) ?? ""
    }
}
