// ChartScaleModel.swift
// Copyright (c) 2022 Joe Blau

import Foundation

enum ChartScale: Identifiable, CaseIterable, CustomStringConvertible {
    var id: Self { self }
    case log
    case auto

    var description: String {
        switch self {
        case .log: return "ʟᴏɢ"
        case .auto: return "ᴀᴜᴛᴏ"
        }
    }
}
