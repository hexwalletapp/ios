//
//  DataRowPercentView.swift
//  HEX
//
//  Created by Joe Blau on 11/3/21.
//

import SwiftUI

struct DataRowPercentView: View {
    var title: String
    var hex: Double
    var usd: Double
    var body: some View {
        LazyVGrid(columns: k.GRID_3, spacing: k.GRID_SPACING) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(NSNumber(value: hex).percentageFractionString)
                .font(.caption.monospaced())
            Text(NSNumber(value: usd).percentageFractionString)
                .font(.caption.monospaced())
        }
    }
}

#if DEBUG
struct DataRowPercentView_Previews: PreviewProvider {
    static var previews: some View {
        DataRowPercentView(title: "Title", hex: 10000, usd: 5.20)
    }
}
#endif
