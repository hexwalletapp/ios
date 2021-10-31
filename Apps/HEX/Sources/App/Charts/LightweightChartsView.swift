// LightweightChartsView.swift
// Copyright (c) 2021 Joe Blau

import Combine
import ComposableArchitecture
import BitqueryAPI
import LightweightCharts
import SwiftUI

struct LightweightChartsView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme

    var timeScale: TimeScale
    var chartType: ChartType
    var ohlcv: [OHLCVData]

    @State var candlestickSeries: CandlestickSeries? = nil
    @State var lineSeries: LineSeries? = nil
    @State var volumeSeries: HistogramSeries? = nil

    func makeUIView(context _: Context) -> LightweightCharts {
        LightweightCharts(options: k.chartOptions())
    }

    func updateUIView(_ chart: LightweightCharts, context _: Context) {
        DispatchQueue.main.async {
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
}
