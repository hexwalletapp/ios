// Formatter+Extensions.swift
// Copyright (c) 2022 Joe Blau

import Foundation

extension Formatter {
    static func currencyFormatter(maxFraction: Int = 2) -> NumberFormatter {
        let f = NumberFormatter()
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = maxFraction
        f.negativePrefix = " $"
        f.positivePrefix = " $"
        return f
    }

    static var dayTimeDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        return f
    }

    static var hourTimeDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }

    static var minuteTimeDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }
}
