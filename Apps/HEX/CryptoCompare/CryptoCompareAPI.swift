// CryptoCompareAPI.swift
// Copyright (c) 2021 Joe Blau

import Combine
import Foundation

public enum CryptoCompareError: Error {
    case invalidURL
    case httpStatusError
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

public enum CryptoCompareAPI {
    static var APIKEY = "d8c4ddee5947285ca8e90aeb0823e82d227e44c320a0b0b4ec8c376d19e1bacb"

    public static func fetchHistory(histTo: HistTo) -> AnyPublisher<CryptoCompareResponse, Error> {
        
        let aggregate: String
        switch histTo {
        case let .histominute(minute): aggregate = minute.rawValue
        case let .histohour(hour): aggregate = hour.rawValue
        case let .histoday(day): aggregate = day.rawValue
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "min-api.cryptocompare.com"
        components.path = "/data/v2/" + histTo.description
        components.queryItems = [
            URLQueryItem(name: "fsym", value: "HEX"),
            URLQueryItem(name: "tsym", value: "USD"),
            URLQueryItem(name: "aggregate", value: aggregate),
            URLQueryItem(name: "limit", value: "1000"),
            URLQueryItem(name: "api_key", value: APIKEY),
        ]

        guard let url = components.url else {
            return Fail(error: CryptoCompareError.invalidURL).eraseToAnyPublisher()
        }
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { data, response -> CryptoCompareResponse in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw CryptoCompareError.httpStatusError
                }
                do {
                    return try JSONDecoder().decode(CryptoCompareResponse.self, from: data)
                } catch {
                    throw error
                }
            }
            .eraseToAnyPublisher()
    }
}

public struct CryptoCompareResponse: Codable, Equatable {
    var Response: String
    var Message: String
    var HasWarning: Bool
    var `Type`: Int
    var Data: CandleData
}

public struct CandleData: Codable, Equatable {
    var Aggregated: Bool
    var TimeFrom: Date
    var TimeTo: Date
    var Data: [OHLCVData]
}

public struct OHLCVData: Codable, Equatable {
    var time: Date
    var high: Double
    var low: Double
    var open: Double
    var volumefrom: Double
    var volumeto: Double
    var close: Double
    var conversionType: String
    var conversionSymbol: String
}
