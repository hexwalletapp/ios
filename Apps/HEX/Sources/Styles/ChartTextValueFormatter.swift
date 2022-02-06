//
//  ChartTextValueFormatter.swift
//  HEX
//
//  Created by Joe Blau on 2/5/22.
//

import Foundation
import Charts

class PieChartTextValueFormatter: ValueFormatter  {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:value))!
    }
    
    
}
