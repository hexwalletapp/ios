// DataRowPercentView.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI

struct DataRowPercentView: View {
    var title: String
    var usd: Double
    var hex: Double
    var body: some View {
        LazyVGrid(columns: k.GRID_3, spacing: k.GRID_SPACING) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(NSNumber(value: usd).percentageFractionString)
                .font(.caption.monospaced())
            Text(NSNumber(value: hex).percentageFractionString)
                .font(.caption.monospaced())
        }
    }
}

#if DEBUG
    struct DataRowPercentView_Previews: PreviewProvider {
        static var previews: some View {
            DataRowPercentView(title: "Title", usd: 5.20, hex: 10000)
        }
    }
#endif
