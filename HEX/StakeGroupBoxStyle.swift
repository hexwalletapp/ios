//
//  StakeGroupBoxStyle.swift
//  HEX
//
//  Created by Joe Blau on 9/25/21.
//

import SwiftUI


struct StakeGroupBoxStyle<V: View>: GroupBoxStyle {
    var color: Color
    var destination: V
    var date: Date?

    @ScaledMetric var size: CGFloat = 1
    
    func makeBody(configuration: Configuration) -> some View {
        NavigationLink(destination: destination) {
            GroupBox(label: HStack {
                configuration.label.foregroundColor(color)
                Spacer()
                if date != nil {
                    Text("\(date!)").font(.footnote).foregroundColor(.secondary).padding(.trailing, 4)
                }
                Image(systemName: "chevron.right").foregroundColor(Color(.systemGray4)).imageScale(.small)
            }) {
                configuration.content.padding([.top], 4)
            }
        }.buttonStyle(PlainButtonStyle())
    }
}
