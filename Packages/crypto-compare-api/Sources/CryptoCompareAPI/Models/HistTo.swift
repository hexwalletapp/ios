// HistTo.swift
// Copyright (c) 2021 Joe Blau

import Foundation

protocol TimeSortable {
    var intervalString: String { get }
    var sortString: String { get }
}

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

public enum HistToMinute: String, TimeSortable {
    case five = "5"
    case fifteen = "15"
    case thirty = "30"
    
    var intervalString: String {
        switch self {
        case .five: return "minute(count: 5)"
        case .fifteen: return "minute(count: 15)"
        case .thirty: return "minute(count: 30)"
        }
    }
    
    public var sortString: String {
        return "timeInterval.minute"
    }
}

public enum HistToHour: String, TimeSortable {
    case one = "1"
    case two = "2"
    case four = "4"
    
    var intervalString: String {
        switch self {
        case .one: return "hour(count: 1)"
        case .two: return "hour(count: 2)"
        case .four: return "hour(count: 4)"
        }
    }
    
    public var sortString: String {
        return "timeInterval.hour"
    }
}

public enum HistToDay: String, TimeSortable {
    case one = "1"
    case seven = "7"
    case thirty = "30"
    
    var intervalString: String {
        switch self {
        case .one: return "day(count: 1)"
        case .seven: return "day(count: 7)"
        case .thirty: return "month(count: 1)"
        }
    }
    
    public var sortString: String {
        switch self {
        case .one, .seven: return "timeInterval.day"
        case .thirty: return "timeInterval.month"
        }
    }
}
