// AccountModel.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import EVMChain
import HEXSmartContract
import SwiftUI
import web3

struct Account: Codable, Hashable, Equatable, Identifiable {
    var id: String { address.value + chain.id.description }
    var name: String = ""
    var chain: Chain = .ethereum
    var address: EthereumAddress = EthereumAddress("")
    var stakes: IdentifiedArrayOf<Stake> = IdentifiedArrayOf<Stake>()
    var summary: Summary = Summary()
    var assetPrice: AssetPrice = AssetPrice()
    @BindableState var isFavorite: Bool = false
    @BindableState var isLoading: Bool = false
    
    enum CodingKeys: CodingKey {
        case name, chain, address, stakes, summary, assetPrice, isFavorite
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        chain = try container.decodeIfPresent(Chain.self, forKey: .chain) ?? .ethereum
        address = try container.decodeIfPresent(EthereumAddress.self, forKey: .address) ?? EthereumAddress.zero
        stakes = try container.decodeIfPresent(IdentifiedArrayOf<Stake>.self, forKey: .stakes) ?? IdentifiedArrayOf<Stake>()
        summary = try container.decodeIfPresent(Summary.self, forKey: .summary) ?? Summary()
        assetPrice = try container.decodeIfPresent(AssetPrice.self, forKey: .assetPrice) ?? AssetPrice()
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(chain, forKey: .chain)
        try container.encode(address, forKey: .address)
        try container.encode(stakes, forKey: .stakes)
        try container.encode(summary, forKey: .summary)
        try container.encode(assetPrice, forKey: .assetPrice)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
    
    static func genId(address: EthereumAddress, chain: Chain) -> String {
        return address.value + chain.id.description
    }
}
