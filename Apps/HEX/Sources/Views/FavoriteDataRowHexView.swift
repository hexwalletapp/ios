//
//  FavoriteDataRowHexView.swift
//  HEX
//
//  Created by Joe Blau on 1/8/22.
//

import SwiftUI

struct FavoriteDataRowHexView: View {
    var title: String
    var usdTotal: String
    var hexTotal: String

    var body: some View {
        LazyVGrid(columns: k.GRID_3, spacing: k.GRID_SPACING) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(usdTotal).font(.caption.monospaced())
            Text(hexTotal).font(.caption.monospaced())
        }
    }
}

#if DEBUG
struct FavoriteDataRowHexView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteDataRowHexView(title: "Title", usdTotal: "$100", hexTotal: "100")
    }
}
#endif
