// DataRowHexView.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import SwiftUI

struct DataRowHexView: View {
    var title: String
    var units: BigUInt
    var price: Double

    var body: some View {
        LazyVGrid(columns: k.GRID_3, spacing: k.GRID_SPACING) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(units
                .hexAt(price: price)
                .currencyWholeString)
                            .font(.caption.monospaced())
            Text(units.hex.hexString)
                .font(.caption.monospaced())
        }
    }
}

#if DEBUG
    struct DataRowHexView_Previews: PreviewProvider {
        static var previews: some View {
            DataRowHexView(title: "Title", units: BigUInt(100), price: 1)
        }
    }
#endif
