// ExtraChartCardView.swift.swift
// Copyright (c) 2022 Joe Blau

import SwiftUI

struct ExtraChartCardView: View {
    var title: String
    var view: AnyView

    var body: some View {
        GroupBox {
            view
        } label: {
            Label(title, systemImage: "")
            EmptyView()
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .groupBoxStyle(ChartGroupBoxStyle(color: .primary,
                                          destination: view))
    }
}

// struct ExtraChartCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExtraChartCardView()
//    }
// }
