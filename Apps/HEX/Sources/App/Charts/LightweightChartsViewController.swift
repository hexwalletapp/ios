// LightweightChartsViewController.swift
// Copyright (c) 2021 Joe Blau

import BitqueryAPI
import SwiftUI
import UIKit

struct LightweightChartsViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ChartViewController

    @Environment(\.colorScheme) var colorScheme

    var timeScale: TimeScale
    var chartType: ChartType
    var ohlcv: [OHLCVData]

    func makeUIViewController(context _: Context) -> ChartViewController {
        ChartViewController()
    }

    func updateUIViewController(_ chatViewController: ChartViewController, context _: Context) {
        chatViewController.updateData(timeScale: timeScale,
                                      chartType: chartType,
                                      ohlcv: ohlcv)
    }
}
