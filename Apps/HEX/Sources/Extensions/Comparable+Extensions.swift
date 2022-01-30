// Comparable+Extensions.swift
// Copyright (c) 2022 Joe Blau

import Foundation

extension Comparable {
    func clamp<T: Comparable>(lower: T, _ upper: T) -> T {
        min(max(self as! T, lower), upper)
    }
}
