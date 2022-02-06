// TimeScaleModel.swift
// Copyright (c) 2022 Joe Blau

import Foundation

protocol TimeScaleable: Equatable, CustomStringConvertible {
    var description: String { get }
    var code: String { get }
}

enum TimeScale: CustomStringConvertible, TimeScaleable {
    case minute(TimeScaleMinute)
    case hour(TimeScaleHour)
    case day(TimeScaleDay)

    var description: String {
        switch self {
        case let .minute(minute): return minute.description
        case let .hour(hour): return hour.description
        case let .day(day): return day.description
        }
    }

    var code: String {
        switch self {
        case let .minute(minute): return minute.code
        case let .hour(hour): return hour.code
        case let .day(day): return day.code
        }
    }
}

enum TimeScaleMinute: Identifiable, CaseIterable, TimeScaleable {
    var id: Self { self }
    case five
    case fifteen
    case thirty

    var description: String {
        switch self {
        case .five: return "5 minutes"
        case .fifteen: return "15 minutes"
        case .thirty: return "30 minutes"
        }
    }

    var code: String {
        switch self {
        case .five: return "5m"
        case .fifteen: return "15m"
        case .thirty: return "30m"
        }
    }
}

enum TimeScaleHour: Identifiable, CaseIterable, TimeScaleable {
    var id: Self { self }
    case one
    case two
    case four

    var description: String {
        switch self {
        case .one: return "1 hour"
        case .two: return "2 hours"
        case .four: return "4 hours"
        }
    }

    var code: String {
        switch self {
        case .one: return "1h"
        case .two: return "2h"
        case .four: return "4h"
        }
    }
}

enum TimeScaleDay: Identifiable, CaseIterable, TimeScaleable {
    var id: Self { self }
    case one
    case seven
    case thirty

    var description: String {
        switch self {
        case .one: return "1 day"
        case .seven: return "1 week"
        case .thirty: return "1 month"
        }
    }

    var code: String {
        switch self {
        case .one: return "D"
        case .seven: return "W"
        case .thirty: return "M"
        }
    }
}
