// CalculatorModel.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation

struct Calculator: Equatable {
    var stakeAmountHex: Int? = nil
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
        stakeAmountHex?.words.isEmpty == nil ||
            stakeDays?.words.isEmpty == nil ||
            price?.description.isEmpty == nil
    }
    
    var stakeAmountHearts: BigUInt {
        switch stakeAmountHex {
        case let .some(amount): return BigUInt(amount) * k.HEARTS_PER_HEX
        case .none: return 0
        }
    }
}

struct Rung: Equatable, Identifiable {
    var id: Int
    var date: Date
    var stakePercentage: Double = 0.0
    var principalHearts: BigUInt = 0
    var interestHearts: BigUInt = 0
    var bonus = Bonus()
    var effectiveHearts: BigUInt = 0
    var shares: BigUInt = 0
    var totalPayoutHearts: BigUInt {
        principalHearts + interestHearts
    }
    var roiPercent: Double {
        interestHearts.hex.doubleValue / principalHearts.hex.doubleValue
    }
    
    func roiPercent(price: Double) -> Double {
        interestHearts.hexAt(price: price).doubleValue / principalHearts.hexAt(price: price).doubleValue
    }
    
    var apyPercent: Double {
        return roiPercent * (Double(k.ONE_YEAR) / Double(stakeDays))
    }

    func apyPercent(price: Double) -> Double {
        return roiPercent(price: price) * (Double(k.ONE_YEAR) / Double(stakeDays))
    }
    
    var stakeDays: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 1
    }
}

struct Bonus: Equatable {
    var longerPaysBetter: BigUInt = 0
    var biggerPaysBetter: BigUInt = 0
    var bonusHearts: BigUInt = 0
}






