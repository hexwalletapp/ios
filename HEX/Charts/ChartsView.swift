//
//  ChartsView.swift
//  ChartsView
//
//  Created by Joe Blau on 9/4/21.
//

import SwiftUI
import ComposableArchitecture

struct ChartsView: View {
    var body: some View {
        TradingviewChartView()
        .navigationTitle("Charts")
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}
