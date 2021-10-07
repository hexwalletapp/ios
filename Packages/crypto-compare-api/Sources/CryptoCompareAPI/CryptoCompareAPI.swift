// CryptoCompareAPI.swift
// Copyright (c) 2021 Joe Blau

import Combine
import Foundation

public enum CryptoCompareError: Error {
    case invalidURL
    case httpStatusError
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
            URLQueryItem(name: "tsym", value: "USDC"),
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
