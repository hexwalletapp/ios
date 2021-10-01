//
//  HEXNumberTextStyle.swift.swift
//  HEX
//
//  Created by Joe Blau on 10/1/21.
//

import SwiftUI

struct HEXNumberTextStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 1) {
            configuration.icon
            configuration.title
        }
    }
}
