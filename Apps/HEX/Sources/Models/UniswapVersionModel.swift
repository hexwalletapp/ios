//
//  UniswapVersionModel.swift
//  HEX
//
//  Created by Joe Blau on 2/5/22.
//

import SwiftUI

enum UniswapVersion: String, Equatable, Identifiable, CustomStringConvertible {
    var id: Self { self }
    case v2
    case v3
    
    var description: String {
        switch self {
        case .v2: return "Uniswap V2"
        case .v3: return "Uniswap V3"
        }
    }
    
    var label: Label<Text, Image> {
        switch self {
        case .v2: return Label(self.description, systemImage: "arrow.2.squarepath")
        case .v3: return Label(self.description, systemImage: "arrow.2.squarepath")
        }
    }
}
