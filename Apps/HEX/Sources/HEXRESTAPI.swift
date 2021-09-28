// HEXRESTAPI.swift
// Copyright (c) 2021 Joe Blau

import Combine
import Foundation

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
