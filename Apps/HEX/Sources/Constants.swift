// Constants.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Combine
import Foundation
import LightweightCharts
import SwiftUI

struct k {
    static let HEARTS_UINT_SHIFT = BigUInt(72)
    static let HEARTS_MASK = (BigUInt(1) << k.HEARTS_UINT_SHIFT) - BigUInt(1)
    static let SATS_UINT_SHIFT = BigUInt(56)
    static let SATS_MASK = (BigUInt(1) << SATS_UINT_SHIFT) - BigUInt(1)
    static let ONE_WEEK = BigUInt(7)
    static let ACCOUNTS_KEY = "evm_account_key"
    static let CARD_PADDING_BOTTOM = CGFloat(48)
    static let CARD_PADDING_DEFAULT = CGFloat(20)
    static let HEX_START_DATE = Date(timeIntervalSince1970: 1_575_273_600)
    static let GRACE_PERIOD = BigUInt(14)
    static let BIG_PAY_DAY = BigUInt(352)
    static let HEARTS_PER_SATOSHI = BigUInt(1e4)
    static let CLAIMABLE_BTC_ADDR_COUNT = BigUInt(27_997_742)
    static let CLAIMABLE_SATOSHIS_TOTAL = BigUInt(910_087_996_911_001)
    static let ONE_YEAR = BigUInt(365)
    static let EARLY_PENALTY_MIN_DAYS = 90

    static func chartOptions() -> ChartOptions {
        ChartOptions(
            layout: LayoutOptions(backgroundColor: ChartColor(.systemBackground),
                                  textColor: ChartColor(.secondaryLabel)),
            rightPriceScale: VisiblePriceScaleOptions(borderColor: ChartColor(UIColor.systemGray6)),
            timeScale: TimeScaleOptions(borderColor: ChartColor(UIColor.systemGray6)),
            crosshair: CrosshairOptions(mode: .normal),
            grid: GridOptions(
                verticalLines: GridLineOptions(color: ChartColor(UIColor.systemGray6)),
                horizontalLines: GridLineOptions(color: ChartColor(UIColor.systemGray6))
            ),
            localization: LocalizationOptions(priceFormatter: .closure {
                NSNumber(value: $0).currencyString
            }
            )
        )
    }

    static func volumeSeriesOptions() -> HistogramSeriesOptions {
        HistogramSeriesOptions(
            priceScaleId: "123",
            priceLineVisible: false,
            priceFormat: .builtIn(BuiltInPriceFormat(type: .volume, precision: nil, minMove: nil)),
            color: ChartColor(UIColor.systemGray4)
        )
    }

    static func candleStickSeriesOptions() -> CandlestickSeriesOptions {
        CandlestickSeriesOptions(
            upColor: ChartColor(UIColor.systemGreen),
            downColor: ChartColor(UIColor.systemRed),
            borderUpColor: ChartColor(UIColor.systemGreen),
            borderDownColor: ChartColor(UIColor.systemRed),
            wickUpColor: ChartColor(UIColor.systemGreen),
            wickDownColor: ChartColor(UIColor.systemRed)
        )
    }

    static func lineSeriesOptoins() -> LineSeriesOptions {
        LineSeriesOptions(
            color: ChartColor(.accentColor),
            lineWidth: .two
        )
    }
}

struct HexManagerId: Hashable {}
struct GetPriceThrottleId: Hashable {}
struct GlobalInfoThrottleId: Hashable {}
struct GetDayThrottleId: Hashable {}

var cancellables = Set<AnyCancellable>()
