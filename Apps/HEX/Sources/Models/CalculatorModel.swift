//
//  CalculatorModel.swift
//  HEX
//
//  Created by Joe Blau on 11/1/21.
//

import Foundation
import ComposableArchitecture
import BigInt

struct Calculator: Equatable {
    var stakeAmount: Int? = nil
    var stakeDays: Int? = nil
    var price: Double? = nil
    var shouldLadder: Bool = false
    
    var ladderSteps: Int = 2 {
        willSet {
            switch newValue < ladderSteps {
            case true:
                ladderRungs = ladderRungs.dropLast()
            case false:
                ladderRungs += [Rung(id: ladderSteps, date: Date())]
            }
        }
    }
    var ladderDistribution: Distribution = .evenly
    var ladderStartDateOffset: Date = Date()
    var ladderRungs: [Rung] = [Rung(id: 0, date: Date()), Rung(id: 1, date: Date())]
}

struct Rung: Equatable, Identifiable {
    var id: Int
    var date: Date
    var stakePercentage: Double = 0.0
    var hearts: BigUInt = 0
}
