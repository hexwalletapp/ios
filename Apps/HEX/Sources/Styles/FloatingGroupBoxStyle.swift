// FloatingGroupBoxStyle.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI

struct FloatingGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemBackground)))
            .overlay(configuration.label.padding(.leading, 4), alignment: .topLeading)
    }
}
