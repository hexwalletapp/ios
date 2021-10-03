// ChartsView.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import SwiftUI

struct ChartsView: View {
    var body: some View {
        LightweightChartsView()
            .navigationTitle("Charts")
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}
