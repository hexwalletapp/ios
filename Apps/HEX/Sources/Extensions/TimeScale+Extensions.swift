//
//  TimeScale+Extensions.swift
//  HEX
//
//  Created by Joe Blau on 10/6/21.
//

import Foundation

extension TimeScale {
    var toHistTo: HistTo {
        switch self {
        case let .minute(minute):
            switch minute {
            case .five: return .histominute(.five)
            case .fifteen: return .histominute(.fifteen)
            case .thirty: return .histominute(.thirty)
            }
        case let .hour(hour):
            switch hour {
            case .one: return .histohour(.one)
            case .two: return .histohour(.two)
            case .four: return .histohour(.four)
            }
        case let .day(day):
            switch day {
            case .one: return .histoday(.one)
            case .seven: return .histoday(.seven)
            case .thirty: return .histoday(.thirty)
            }
        }
    }
}
