// ChartGroupBoxStyle.swift
// Copyright (c) 2022 Joe Blau

import SwiftUI

struct ChartGroupBoxStyle<V: View>: GroupBoxStyle {
    var color: Color
    var destination: V

    @ScaledMetric var size: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        NavigationLink(destination: destination) {
            GroupBox(label: HStack {
                configuration.label.foregroundColor(color)
                Spacer()
                Text("View")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right").foregroundColor(.secondary).imageScale(.small)
            }) {
                configuration.content.padding(.top, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
