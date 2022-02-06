// AccountModel.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import EVMChain
import HEXSmartContract
import SwiftUI
import web3

struct Account: Codable, Hashable, Equatable, Identifiable {
    var id: String { address.value + chain.description }
    var name: String = ""
    var address = EthereumAddress("")
    var chain: Chain = .ethereum
    @BindableState var isFavorite: Bool = false

    enum CodingKeys: CodingKey {
        case name, address, chain, isFavorite
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try container.decodeIfPresent(EthereumAddress.self, forKey: .address) ?? EthereumAddress.zero
        chain = try container.decodeIfPresent(Chain.self, forKey: .chain) ?? .ethereum
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(chain, forKey: .chain)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
}
