//
//  AccountType.swift
//  HEX
//
//  Created by Joe Blau on 1/2/22.
//

import SwiftUI

enum AccountType: Equatable, Identifiable, CaseIterable, CustomStringConvertible {
    var id: Self { self }

    case individual, group
    
    var description: String {
        switch self {
        case .individual: return "Individual Accounts"
        case .group: return "Group Account"
        }
    }
    
    var emptyState: some View {
        switch self {
        case .individual: return Label("No accounts", systemImage: "person.crop.rectangle.stack")
        case .group: return Label("No group account", systemImage: "person.crop.rectangle")
        }
    }
    
    var label: some View {
        switch self {
        case .individual: return Label(self.description, systemImage: "person.crop.rectangle.stack")
        case .group: return Label(self.description, systemImage: "person.crop.square")
        }
    }
}
