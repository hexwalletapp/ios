//
//  PlanTypeModel.swift
//  HEX
//
//  Created by Joe Blau on 2/13/22.
//

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
    
    var label: Label<Text,Image> {
        switch self {
        case .USD: return Label(self.description, systemImage: "dollarsign.circle.fill")
        case .HEX: return Label(self.description, image: "hex-logo.SFSymbol")
        }
    }
}
