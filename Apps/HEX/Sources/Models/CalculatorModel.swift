// CalculatorModel.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation

struct Calculator: Equatable {
    var planUnit: PlanUnit = .USD
    var stakeAmountDollar: Double? = nil
    var stakeAmountHex: Int? = nil
    var stakeDays: Int? = nil
    var currentPrice: Double? = nil {
        didSet {
            price = currentPrice
        }
    }

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

    var stakeDaysValid: Bool {
        switch stakeDays {
        case let .some(days): return 1 ... 5555 ~= days
        case .none: return false
        }
    }

    var isAmountValid: Bool {
        stakeAmountDollar != nil || stakeAmountHex != nil
    }

    var disableForm: Bool {
        !isAmountValid ||
            stakeDays?.words.isEmpty == nil ||
            price?.description.isEmpty == nil
    }

    var stakeAmountHearts: BigUInt {
        switch planUnit {
        case .USD:
            switch (stakeAmountDollar, currentPrice) {
            case let (.some(amount), .some(currentPrice)) where price != 0: return BigUInt(amount / currentPrice) * k.HEARTS_PER_HEX
            default: return 0
            }
        case .HEX:
            switch stakeAmountHex {
            case let .some(amount): return BigUInt(amount) * k.HEARTS_PER_HEX
            case .none: return 0
            }
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

    func roiPercent(price: Double, currentPrice: Double) -> Double {
        let current = principalHearts.hexAt(price: currentPrice).doubleValue
        guard current != 0 else { return 0 }
        let projected = interestHearts.hexAt(price: price).doubleValue + principalHearts.hexAt(price: price).doubleValue
        return (projected - current) / current
    }

    var apyPercent: Double {
        roiPercent * (Double(k.ONE_YEAR) / Double(stakeDays))
    }

    func apyPercent(price: Double, currentPrice: Double) -> Double {
        roiPercent(price: price, currentPrice: currentPrice) * (Double(k.ONE_YEAR) / Double(stakeDays))
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
