//
//  HEXApi.swift
//  HEXApi
//
//  Created by Joe Blau on 9/13/21.
//

import Foundation
import Combine

enum HEXRestError: Error {
    case invalidURL
    case httpStatusError
}

final class HEXRESTAPI {
    static func fetchHexPrice() -> AnyPublisher<HEXPrice, Error> {
        guard let url = URL(string: "https://uniswapdataapi.azurewebsites.net/api/hexPrice") else {
            return Fail(error: HEXRestError.invalidURL).eraseToAnyPublisher()
        }
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { (data, response) -> HEXPrice in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
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
