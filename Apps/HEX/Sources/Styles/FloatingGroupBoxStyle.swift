//
//  CustomGroupBoxStyle.swift
//  HEX
//
//  Created by Joe Blau on 11/12/21.
//

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
