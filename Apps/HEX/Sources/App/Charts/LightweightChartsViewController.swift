//
//  LightweightChartsViewController.swift
//  HEX
//
//  Created by Joe Blau on 12/26/21.
//

import SwiftUI
import UIKit
import BitqueryAPI

struct LightweightChartsViewController: UIViewControllerRepresentable {

    typealias UIViewControllerType = ChartViewController
    
    @Environment(\.colorScheme) var colorScheme

    var timeScale: TimeScale
    var chartType: ChartType
    var ohlcv: [OHLCVData]
    
    func makeUIViewController(context: Context) -> ChartViewController {
        return ChartViewController()
    }
    
    func updateUIViewController(_ chatViewController: ChartViewController, context: Context) {
        chatViewController.updateData(timeScale: timeScale,
                                      chartType: chartType,
                                      ohlcv: ohlcv)
    }
}
