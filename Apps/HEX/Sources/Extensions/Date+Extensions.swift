// Date+Extensions.swift
// Copyright (c) 2021 Joe Blau

import Foundation

extension Date {
    var longDateString: String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: self)
    }
}
