// CalculatorModel.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation

struct Calculator: Equatable {
    var stakeAmount: Int? = nil
    var stakeDays: Int? = nil
    var price: Double? = nil
    var showLadder: Bool = false

    var ladderSteps: Int = 1 {
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
    var ladderStartDateOffset = Date()
    var ladderRungs: [Rung] = [Rung(id: 0, date: Date())]

    var disableForm: Bool {
        stakeAmount?.words.isEmpty == nil ||
            stakeDays?.words.isEmpty == nil ||
            price?.description.isEmpty == nil
    }
}

struct Rung: Equatable, Identifiable {
    var id: Int
    var date: Date
    var stakePercentage: Double = 0.0
    var hearts: BigUInt = 0
    var bonus: Bonus = Bonus()
    var effectiveHearts: BigUInt = 0
}

struct Bonus: Equatable {
    var longerPaysBetter: BigUInt = 0
    var biggerPaysBetter: BigUInt = 0
    var bonusHearts: BigUInt = 0
}
