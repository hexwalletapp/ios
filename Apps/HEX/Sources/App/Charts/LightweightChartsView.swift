// LightweightChartsView.swift
// Copyright (c) 2021 Joe Blau

import Combine
import ComposableArchitecture
import CryptoCompareAPI
import LightweightCharts
import SwiftUI

struct LightweightChartsView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme

    var store: Store<AppState, AppAction>
    var timeScale: TimeScale
    var chartType: ChartType
    var ohlcv: [OHLCVData]

    func makeUIView(context _: Context) -> LightweightCharts {
        LightweightCharts(options: k.chartOptions())
    }

    func updateUIView(_ chart: LightweightCharts, context _: Context) {
        let viewStore = ViewStore(store)

        chart.applyOptions(options: k.chartOptions())

        viewStore.candlesstickSeries.map { chart.removeSeries(seriesApi: $0) }
        viewStore.lineSeries.map { chart.removeSeries(seriesApi: $0) }
        viewStore.volumeSeries.map { chart.removeSeries(seriesApi: $0) }

        switch chartType {
        case .candlestick:
            let candlestickSeries = chart.addCandlestickSeries(options: k.candleStickSeriesOptions())
            candlestickSeries.setData(data: ohlcv.map { $0.barData })

            viewStore.send(.binding(.set(\.$candlesstickSeries, candlestickSeries)))
        case .line:
            let lineSeries = chart.addLineSeries(options: k.lineSeriesOptoins())
            lineSeries.setData(data: ohlcv.map { $0.lineData })

            viewStore.send(.binding(.set(\.$lineSeries, lineSeries)))
        }

        let volumeSeries = chart.addHistogramSeries(options: k.volumeSeriesOptions())
        volumeSeries.priceScale().applyOptions(
            options: PriceScaleOptions(
                scaleMargins: PriceScaleMargins(
                    top: 0.85,
                    bottom: 0
                )
            )
        )

        volumeSeries.setData(data: ohlcv.map { $0.volumeData })
        viewStore.send(.binding(.set(\.$volumeSeries, volumeSeries)))
    }
}
