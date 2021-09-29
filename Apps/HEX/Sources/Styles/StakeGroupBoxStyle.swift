// StakeGroupBoxStyle.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI

struct StakeGroupBoxStyle<V: View>: GroupBoxStyle {
    var color: Color
    var destination: V
    var stakeStatus: StakeStatus

    @ScaledMetric var size: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        NavigationLink(destination: destination) {
            GroupBox(label: HStack {
                configuration.label.foregroundColor(color)
                Spacer()
                Text(stakeStatus.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right").foregroundColor(.secondary).imageScale(.small)
            }) {
                configuration.content.padding([.top], 4)
            }
        }.buttonStyle(PlainButtonStyle())
    }
}
