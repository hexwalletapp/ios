// HEXNumberTextStyle.swift.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI

struct HEXNumberTextStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 1) {
            configuration.icon
            configuration.title
        }
    }
}
