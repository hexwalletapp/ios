// BitqueryAPI.swift
// Copyright (c) 2021 Joe Blau

import Combine
import Foundation

public enum BitqueryError: Error {
    case invalidURL
    case httpStatusError
    case invalidEncoding
}

public struct BitqueryAPI {
    let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()

    let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    public init() {}

    public func fetchHistory(histTo: HistTo) -> AnyPublisher<[OHLCVData], Error> {
        let sortString: String
        let intervalString: String
        switch histTo {
        case let .histominute(minute):
            sortString = minute.sortString
            intervalString = minute.intervalString
        case let .histohour(hour):
            sortString = hour.sortString
            intervalString = hour.intervalString
        case let .histoday(day):
            sortString = day.sortString
            intervalString = day.intervalString
        }

        guard let URL = URL(string: "https://graphql.bitquery.io/") else {
            return Fail(error: BitqueryError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("BQYwXeKCf95a3kzsptCQ81LFFEArJRoM", forHTTPHeaderField: "X-API-KEY")

        let bodyObject: [String: Any] = [
            "query": "query{ethereum(network:ethereum){dexTrades(options:{limit:10000,desc:\"\(sortString)\"}date:{since:\"2019-12-02\"}exchangeName:{is:\"Uniswap\"}baseCurrency:{is:\"0x2b591e99afe9f32eaa6214f7b7629768c40eeb39\"}quoteCurrency:{is:\"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48\"}){timeInterval{\(intervalString)}quotePrice maximum_price:quotePrice(calculate:maximum)minimum_price:quotePrice(calculate:minimum)open_price:minimum(of:block,get:quote_price)close_price:maximum(of:block,get:quote_price)tradeAmount(in:USD)}}}",
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: bodyObject, options: []) else {
            return Fail(error: BitqueryError.invalidEncoding).eraseToAnyPublisher()
        }
        request.httpBody = body
        request.httpShouldHandleCookies = false

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw BitqueryError.httpStatusError
                }
                return data
            }
            .mapError { $0 as Error }
            .decode(type: BitqueryResponse.self, decoder: JSONDecoder())
            .map { response in
                response.data.ethereum.dexTrades.map { dexTrade -> OHLCVData in
                    var date: Date?
                    if let minute = dexTrade.timeInterval.minute {
                        date = dateFormatter.date(from: minute)
                    } else if let hour = dexTrade.timeInterval.hour {
                        date = dateFormatter.date(from: hour)
                    } else if let day = dexTrade.timeInterval.day {
                        date = dayFormatter.date(from: day)
                    } else if let month = dexTrade.timeInterval.month {
                        date = dayFormatter.date(from: month)
                    }

                    return OHLCVData(time: date ?? Date(),
                                     open: Double(dexTrade.open_price) ?? 0.0,
                                     high: dexTrade.maximum_price,
                                     low: dexTrade.minimum_price,
                                     close: Double(dexTrade.close_price) ?? 0.0,
                                     volume: dexTrade.tradeAmount)
                }.reversed()
            }
            .eraseToAnyPublisher()
    }
}
