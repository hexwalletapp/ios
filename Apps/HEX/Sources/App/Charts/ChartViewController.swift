//
//  ChartViewController.swift
//  HEX
//
//  Created by Joe Blau on 12/26/21.
//

import UIKit
import LightweightCharts
import BitqueryAPI

class ChartViewController: UIViewController {
    
    private var chart: LightweightCharts!
    private var candlestickSeries: CandlestickSeries? = nil
    private var lineSeries: LineSeries? = nil
    private var volumeSeries: HistogramSeries? = nil
    
    override func viewDidLoad() {
        let chart = LightweightCharts(options: k.chartOptions())
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        chart.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        chart.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        chart.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.chart = chart
    }
    
    func updateData(timeScale: TimeScale, chartType: ChartType, ohlcv: [OHLCVData]) {
        chart.applyOptions(options: k.chartOptions())

        candlestickSeries.map { chart.removeSeries(seriesApi: $0) }
        lineSeries.map { chart.removeSeries(seriesApi: $0) }
        volumeSeries.map { chart.removeSeries(seriesApi: $0) }

        switch chartType {
        case .candlestick:
            candlestickSeries = chart.addCandlestickSeries(options: k.candleStickSeriesOptions())
            candlestickSeries?.setData(data: ohlcv.map { $0.barData })

        case .line:
            lineSeries = chart.addLineSeries(options: k.lineSeriesOptoins())
            lineSeries?.setData(data: ohlcv.map { $0.lineData })
        }

        volumeSeries = chart.addHistogramSeries(options: k.volumeSeriesOptions())
        volumeSeries?.priceScale().applyOptions(
            options: PriceScaleOptions(
                scaleMargins: PriceScaleMargins(
                    top: 0.85,
                    bottom: 0
                )
            )
        )

        volumeSeries?.setData(data: ohlcv.map { $0.volumeData })
    
    }
}
