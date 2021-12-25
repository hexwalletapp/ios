// Interface.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import ComposableArchitecture
import EVMChain
import Foundation
import web3

public struct UniswapSmartContractManager {
    public enum Action: Equatable {
        case pairAddress(Chain, EthereumAddress)
        case reserves(Chain, BigUInt, BigUInt, UInt32)
    }

    var create: (AnyHashable) -> Effect<Action, Never> = { _ in _unimplemented("create") }

    var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("destroy") }

    var getPair: (AnyHashable, Chain, EthereumAddress, EthereumAddress) -> Effect<Never, Never> = { _, _, _, _ in _unimplemented("getPair") }

    var getReserves: (AnyHashable, Chain, EthereumAddress) -> Effect<Never, Never> = { _, _, _ in _unimplemented("getReserves") }

    public func create(id: AnyHashable) -> Effect<Action, Never> {
        create(id)
    }

    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
        destroy(id)
    }

    public func getPair(id: AnyHashable, chain: Chain, token0: EthereumAddress, token1: EthereumAddress) -> Effect<Never, Never> {
        getPair(id, chain, token0, token1)
    }

    public func getReserves(id: AnyHashable, chain: Chain, pairAddress: EthereumAddress) -> Effect<Never, Never> {
        getReserves(id, chain, pairAddress)
    }
}
