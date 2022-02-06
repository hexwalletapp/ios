// LiquidityChartView.swift
// Copyright (c) 2022 Joe Blau

import BitqueryAPI
import Charts
import Foundation
import SwiftUI

struct LiquidityChartView: UIViewRepresentable {
    var liquidity: [DEXLiquidity]
    var interaction: Bool

    init(liquidity: [DEXLiquidity], interaction: Bool = false) {
        self.liquidity = liquidity
        self.interaction = interaction
    }

    func makeUIView(context _: Context) -> PieChartView {
        let view = PieChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.holeColor = .clear
        view.backgroundColor = .clear
        view.transparentCircleRadiusPercent = 0
        view.legend.enabled = false

        view.highlightPerTapEnabled = interaction
        view.rotationEnabled = interaction
        return view
    }

    func updateUIView(_ pieView: PieChartView, context _: Context) {
        let entries = liquidity.compactMap { entry -> PieChartDataEntry in
            PieChartDataEntry(value: entry.tokenA.adjustedAmount.number.doubleValue)
        }

        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.drawIconsEnabled = false
        dataSet.iconsOffset = CGPoint(x: 0, y: 20.0)
        dataSet.valueFont = NSUIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        dataSet.valueFormatter = PieChartTextValueFormatter()
        dataSet.colors = [.systemIndigo, .systemBlue, .systemPink, .systemPurple, .systemRed]

        pieView.data = PieChartData(dataSet: dataSet)
    }
}
