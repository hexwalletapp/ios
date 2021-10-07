// HistTo.swift
// Copyright (c) 2021 Joe Blau

import Foundation

public enum HistTo: CustomStringConvertible {
    case histominute(HistToMinute)
    case histohour(HistToHour)
    case histoday(HistToDay)

    public var description: String {
        switch self {
        case .histominute: return "histominute"
        case .histohour: return "histohour"
        case .histoday: return "histoday"
        }
    }
}

public enum HistToMinute: String {
    case five = "5"
    case fifteen = "15"
    case thirty = "30"
}

public enum HistToHour: String {
    case one = "1"
    case two = "2"
    case four = "4"
}

public enum HistToDay: String {
    case one = "1"
    case seven = "7"
    case thirty = "30"
}
