//
//  HEXApi.swift
//  HEXApi
//
//  Created by Joe Blau on 9/13/21.
//

import Foundation


enum HEXRestError: Error {
    case invalidURL
}

class HEXRESTAPI {
    static func fetchHexPrice() async throws -> HEXPrice {
        guard let url = URL(string: "https://uniswapdataapi.azurewebsites.net/api/hexPrice") else {
            throw HEXRestError.invalidURL
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            return try JSONDecoder().decode(HEXPrice.self, from: data)
        } catch {
            fatalError("\(error)")
        }
    }

}
