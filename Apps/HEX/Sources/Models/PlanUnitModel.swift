// PlanUnitModel.swift
// Copyright (c) 2022 Joe Blau

import SwiftUI

enum PlanUnit: CaseIterable, Equatable, Hashable, Identifiable, CustomStringConvertible {
    var id: Self { self }
    case USD
    case HEX

    var description: String {
        switch self {
        case .USD: return "Dollar"
        case .HEX: return "HEX"
        }
    }

    var image: Image {
        switch self {
        case .USD: return Image(systemName: "dollarsign.circle.fill")
        case .HEX: return Image("hex-logo.SFSymbol")
        }
    }

    var label: Label<Text, Image> {
        switch self {
        case .USD: return Label(description, systemImage: "dollarsign.circle.fill")
        case .HEX: return Label(description, image: "hex-logo.SFSymbol")
        }
    }
}
