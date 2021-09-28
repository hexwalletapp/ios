// HEXRESTAPI.swift
// Copyright (c) 2021 Joe Blau

import Combine
import Foundation

struct HEXPrice: Codable, Equatable {
    var lastUpdated: Date
    var hexEth: Double
    var hexUsd: Double
    var hexBtc: Double

    init() {
        lastUpdated = Date()
        hexEth = Double.zero
        hexUsd = Double.zero
        hexBtc = Double.zero
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let date = try container.decode(String.self, forKey: .lastUpdated)

        lastUpdated = dateFormatter.date(from: date) ?? Date()
        hexEth = Double(try container.decode(String.self, forKey: .hexEth)) ?? 0
        hexUsd = Double(try container.decode(String.self, forKey: .hexUsd)) ?? 0
        hexBtc = Double(try container.decode(String.self, forKey: .hexBtc)) ?? 0
    }
}

enum HEXRestError: Error {
    case invalidURL
    case httpStatusError
}

enum HEXRESTAPI {
    static func fetchHexPrice() -> AnyPublisher<HEXPrice, Error> {
        guard let url = URL(string: "https://uniswapdataapi.azurewebsites.net/api/hexPrice") else {
            return Fail(error: HEXRestError.invalidURL).eraseToAnyPublisher()
        }
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { data, response -> HEXPrice in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw HEXRestError.httpStatusError
                }
                do {
                    return try JSONDecoder().decode(HEXPrice.self, from: data)
                } catch {
                    throw error
                }
            }
            .eraseToAnyPublisher()
    }
}
