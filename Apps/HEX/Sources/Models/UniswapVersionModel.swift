// UniswapVersionModel.swift
// Copyright (c) 2022 Joe Blau

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
        case .v2: return Label(description, systemImage: "arrow.2.squarepath")
        case .v3: return Label(description, systemImage: "arrow.2.squarepath")
        }
    }
}
