// HEXNumberTextStyle.swift
// Copyright (c) 2022 Joe Blau

import SwiftUI

struct HEXNumberTextStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 1) {
            configuration.icon
            configuration.title
        }
    }
}
