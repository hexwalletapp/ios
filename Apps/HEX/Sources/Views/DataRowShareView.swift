// DataRowShareView.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import SwiftUI

struct DataRowShareView: View {
    var title: String
    var shares: BigUInt

    var body: some View {
        LazyVGrid(columns: k.GRID_2, spacing: k.GRID_SPACING) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(shares.number.shareString)
                .font(.caption)
        }
    }
}

#if DEBUG
    struct DataRowShareView_Previews: PreviewProvider {
        static var previews: some View {
            DataRowShareView(title: "Title", shares: BigUInt(100))
        }
    }
#endif
