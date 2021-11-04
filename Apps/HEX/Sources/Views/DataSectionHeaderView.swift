// DataSectionHeaderView.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI

struct DataSectionHeaderView: View {
    var title: String
    var body: some View {
        LazyVGrid(columns: k.GRID_1, spacing: k.GRID_SPACING) {
            Text(title).font(.subheadline.monospaced().bold())
        }.padding([.top], 12)
    }
}

struct DataSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        DataSectionHeaderView(title: "title")
    }
}
