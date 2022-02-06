// Constants.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Combine
import Foundation
import LightweightCharts
import SwiftUI
import web3

struct k {
    static let HEARTS_UINT_SHIFT = BigUInt(72)
    static let HEARTS_MASK = (BigUInt(1) << k.HEARTS_UINT_SHIFT) - BigUInt(1)
    static let SATS_UINT_SHIFT = BigUInt(56)
    static let SATS_MASK = (BigUInt(1) << SATS_UINT_SHIFT) - BigUInt(1)
    static let ONE_WEEK = BigUInt(7)
    static let ACCOUNTS_KEY = "evm_account_key"
    static let CARD_PADDING_BOTTOM = CGFloat(24)
    static let CARD_PADDING_DEFAULT = CGFloat(20)
    static let HEX_START_DATE = Date(timeIntervalSince1970: 1_575_273_600)
    static let GRACE_PERIOD = BigUInt(14)
    static let BIG_PAY_DAY = BigUInt(352)
    static let HEARTS_PER_SATOSHI = BigUInt(1e4)
    static let CLAIMABLE_BTC_ADDR_COUNT = BigUInt(27_997_742)
    static let CLAIMABLE_SATOSHIS_TOTAL = BigUInt(910_087_996_911_001)
    static let ONE_YEAR = BigUInt(365)
    static let EARLY_PENALTY_MIN_DAYS = 90
    static let GRID_SPACING = CGFloat.zero
    static let ACCOUNT_CARD_BACKGROUND_GRADIENT_STOPS = [
        Gradient.Stop(color: Color(.systemGroupedBackground), location: 0.95),
        Gradient.Stop(color: Color(.systemGroupedBackground.withAlphaComponent(0)), location: 1.0),
    ]

    static let WETH = EthereumAddress("0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2")
    static let USDC = EthereumAddress("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48")
    static let HEX = EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39")

    static let TOKEN_INFO_DICT = [
        k.WETH: ERC20TokenInfo(decimals: 18, symbol: "WETH"),
        k.USDC: ERC20TokenInfo(decimals: 6, symbol: "USDC"),
        k.HEX: ERC20TokenInfo(decimals: 8, symbol: "HEX"),
    ]

    // Bigger Pays Better
    static let BPB_BONUS_PERCENT = BigUInt(10)
    static let HEARTS_PER_HEX = BigUInt(1e8)
    static let BPB_MAX_HEX = 150 * BigUInt(1e6)
    static let BPB_MAX_HEARTS = BPB_MAX_HEX * HEARTS_PER_HEX
    static let BPB = BPB_MAX_HEARTS * 100 / BPB_BONUS_PERCENT

    // Longer Pays Better
    static let LPB_BONUS_PERCENT = BigUInt(20)
    static let LPB_BONUS_MAX_PERCENT = BigUInt(200)
    static let LPB = 364 * 100 / LPB_BONUS_PERCENT
    static let LPB_MAX_DAYS = LPB * LPB_BONUS_MAX_PERCENT / 100

    static let SHARE_RATE_SCALE = BigUInt(1e5)
    static let FORM_ICON_WIDTH = CGFloat(20)

    static func chartOptions() -> ChartOptions {
        ChartOptions(
            layout: LayoutOptions(backgroundColor: ChartColor(.systemGroupedBackground),
                                  textColor: ChartColor(.secondaryLabel)),
            rightPriceScale: VisiblePriceScaleOptions(borderColor: ChartColor(UIColor.systemGray6)),
            timeScale: TimeScaleOptions(borderColor: ChartColor(UIColor.systemGray5)),
            crosshair: CrosshairOptions(mode: .normal),
            grid: GridOptions(
                verticalLines: GridLineOptions(color: ChartColor(UIColor.systemGray5)),
                horizontalLines: GridLineOptions(color: ChartColor(UIColor.systemGray5))
            ),
            localization: LocalizationOptions(priceFormatter: .closure {
                NSNumber(value: $0).currencyShortString
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

    static let LEAGUE_GIRD_3 = [GridItem(.fixed(30), spacing: k.GRID_SPACING, alignment: .leading),
                                GridItem(.flexible(), spacing: k.GRID_SPACING, alignment: .leading),
                                GridItem(.fixed(100), spacing: k.GRID_SPACING, alignment: .trailing)]

    static let GRID_3 = [GridItem(.fixed(80), spacing: k.GRID_SPACING, alignment: .leading),
                         GridItem(.flexible(), spacing: k.GRID_SPACING, alignment: .trailing),
                         GridItem(.fixed(100), spacing: k.GRID_SPACING, alignment: .trailing)]

    static let GRID_2 = [GridItem(.fixed(80), spacing: k.GRID_SPACING, alignment: .leading),
                         GridItem(.flexible(), spacing: k.GRID_SPACING, alignment: .trailing)]

    static let GRID_1 = [GridItem(.flexible(), spacing: k.GRID_SPACING, alignment: .leading)]
}

struct GetChartId: Hashable {}
struct GetChartThrottleId: Hashable {}
struct HexManagerId: Hashable {}
struct UniswapManagerId: Hashable {}

struct CancelGetAccounts: Hashable {}
struct GetAccountsThorttleId: Hashable {}
