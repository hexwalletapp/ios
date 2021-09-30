// Chain.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI

public enum Chain: Codable, Identifiable, CaseIterable, CustomStringConvertible {
    public var id: Self { self }

    case ethereum, pulse

    public var gradient: [Color] {
        switch self {
        case .ethereum: return [
                Color(red: 1.000, green: 0.859, blue: 0.004, opacity: 1.000),
                Color(red: 1.000, green: 0.522, blue: 0.122, opacity: 1.000),
                Color(red: 1.000, green: 0.239, blue: 0.239, opacity: 1.000),
                Color(red: 1.000, green: 0.059, blue: 0.435, opacity: 1.000),
                Color(red: 0.996, green: 0.004, blue: 0.980, opacity: 1.000),
            ]
        case .pulse: return [
                Color(red: 1.000, green: 0.000, blue: 0.000, opacity: 1.000),
                Color(red: 0.902, green: 0.098, blue: 0.902, opacity: 1.000),
                Color(red: 0.502, green: 0.000, blue: 1.000, opacity: 1.000),
                Color(red: 0.000, green: 0.502, blue: 1.000, opacity: 1.000),
                Color(red: 0.000, green: 0.918, blue: 1.000, opacity: 1.000),
            ]
        }
    }

    public var description: String {
        switch self {
        case .ethereum: return "Ethereum"
        case .pulse: return "Pulse"
        }
    }
}