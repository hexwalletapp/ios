//
//  DataHeaderView.swift
//  HEX
//
//  Created by Joe Blau on 11/3/21.
//

import SwiftUI

struct DataHeaderView: View {
    var body: some View {
        LazyVGrid(columns: k.GRID_3, spacing: k.GRID_SPACING) {
            Text("")
            Text("ᴜsᴅ").foregroundColor(.secondary)
            Text("ʜᴇx").foregroundColor(.secondary)
        }
    }
}

#if DEBUG
struct DataHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        DataHeaderView()
    }
}
#endif
