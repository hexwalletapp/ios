//
//  Sequence+Extensions.swift
//  HEX
//
//  Created by Joe Blau on 2/5/22.
//

import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
