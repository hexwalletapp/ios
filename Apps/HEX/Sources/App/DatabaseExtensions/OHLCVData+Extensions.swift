//
//  OHLCVData+Extensions.swift
//  HEX
//
//  Created by Joe Blau on 3/9/22.
//

import Foundation
import BitqueryAPI
import GRDB

struct OHLCVTimeScaleData: Codable, Identifiable, FetchableRecord, PersistableRecord  {
    var id: String { time.description + code }
    var time: Date
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var volume: Double
    var code: String

    public init(ohlcv: OHLCVData, code: String)
    {
        self.time = ohlcv.time
        self.open = ohlcv.open
        self.high = ohlcv.high
        self.low = ohlcv.low
        self.close = ohlcv.close
        self.volume = ohlcv.volume
        self.code = code
    }
}

extension OHLCVData {
    init(ohlcvTimeScale: OHLCVTimeScaleData ) {
        self.init(time: ohlcvTimeScale.time,
                  open: ohlcvTimeScale.open,
                  high: ohlcvTimeScale.high,
                  low: ohlcvTimeScale.low,
                  close: ohlcvTimeScale.close,
                  volume: ohlcvTimeScale.volume)
    }
}
