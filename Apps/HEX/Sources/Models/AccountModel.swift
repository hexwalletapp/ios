// AccountModel.swift
// Copyright (c) 2021 Joe Blau

import EVMChain
import HEXSmartContract
import SwiftUI

struct Account: Codable, Hashable, Equatable, Identifiable {
    var id: String { address + chain.description }
    var name: String = ""
    var address: String = ""
    var chain: Chain = .ethereum
    var isGroup: Bool = false
    
    enum CodingKeys: CodingKey {
        case name, address, chain, isGroup
    }
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        chain = try container.decodeIfPresent(Chain.self, forKey: .chain) ?? .ethereum
        isGroup = try container.decodeIfPresent(Bool.self, forKey: .isGroup) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(chain, forKey: .chain)
        try container.encode(isGroup, forKey: .isGroup)
    }
}

