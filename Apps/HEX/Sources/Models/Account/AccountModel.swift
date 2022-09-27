// AccountModel.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import EVMChain
import HEXSmartContract
import SwiftUI
import web3

//struct Account: Codable, Hashable, Equatable, Identifiable {
//    var id: String { address.value + chain.description }
//    var name: String = ""
//    var address = EthereumAddress("")
//    var chain: Chain = .ethereum
//    @BindableState var isFavorite: Bool = false
//
//    enum CodingKeys: CodingKey {
//        case name, address, chain, isFavorite
//    }
//
//    init() {}
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
//        address = try container.decodeIfPresent(EthereumAddress.self, forKey: .address) ?? EthereumAddress.zero
//        chain = try container.decodeIfPresent(Chain.self, forKey: .chain) ?? .ethereum
//        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//        try container.encode(address, forKey: .address)
//        try container.encode(chain, forKey: .chain)
//        try container.encode(isFavorite, forKey: .isFavorite)
//    }
//}


struct Account: Codable, Hashable, Equatable, Identifiable {
    var id: String { address.value + chain.id.description }
    var name: String = ""
    var chain: Chain = .ethereum
    var address: EthereumAddress = EthereumAddress("")
    var stakes: [Stake] = [Stake]()
    var summary: Summary = Summary()
    var assetPrice: AssetPrice = AssetPrice()
    @BindableState var isFavorite: Bool = false
    @BindableState var isLoading: Bool = false
    
    enum CodingKeys: CodingKey {
        case name, address, chain, isFavorite
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
    }
    
    func encode(to encoder: Encoder) throws {
    }
    
    static func genId(address: EthereumAddress, chain: Chain) -> String {
        return address.value + chain.id.description
    }

}




//struct AccountData: Codable, Hashable, Equatable, Identifiable {
//    var id: String { account.id }
//    var account: Account
//    var stakes = IdentifiedArrayOf<Stake>()
//    var total = StakeTotal()
//    var liquidBalanceHearts: BigUInt = 0
//    var hexPrice: Double = 0.0
//    var isLoading = false
//}
