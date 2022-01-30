//
//  Comparable+Extensions.swift
//  HEX
//
//  Created by Joe Blau on 1/30/22.
//

import Foundation

extension Comparable {
    func clamp<T: Comparable>(lower: T, _ upper: T) -> T {
        return min(max(self as! T, lower), upper)
    }
}
