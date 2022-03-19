// Interface.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation
import web3

public struct PulseXSmartContractManager {
    public enum Action: Equatable {
        case token(EthereumAddress, EthereumAddress, TokenPosition)
        case pairAddress(EthereumAddress)
        case reserves(BigUInt, BigUInt, UInt32, EthereumAddress)
    }

    var create: (AnyHashable) -> Effect<Action, Never> = { _ in _unimplemented("create") }

    var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("destroy") }

    var token0: (AnyHashable, EthereumAddress) -> Effect<Never, Never> = { _, _ in _unimplemented("token0") }

    var token1: (AnyHashable, EthereumAddress) -> Effect<Never, Never> = { _, _ in _unimplemented("token1") }

    var getPairV2: (AnyHashable, EthereumAddress, EthereumAddress) -> Effect<Never, Never> = { _, _, _ in _unimplemented("getPairV2") }

    var reserves: (AnyHashable, EthereumAddress) -> Effect<Never, Never> = { _, _ in _unimplemented("reserves") }

    // MARK: - Shared

    public func create(id: AnyHashable) -> Effect<Action, Never> {
        create(id)
    }

    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
        destroy(id)
    }

    public func token0(id: AnyHashable, pairAddress: EthereumAddress) -> Effect<Never, Never> {
        token0(id, pairAddress)
    }

    public func token1(id: AnyHashable, pairAddress: EthereumAddress) -> Effect<Never, Never> {
        token1(id, pairAddress)
    }

    // MARK: - Uniswap V2

    public func getPairV2(id: AnyHashable, token0: EthereumAddress, token1: EthereumAddress) -> Effect<Never, Never> {
        getPairV2(id, token0, token1)
    }

    public func reserves(id: AnyHashable, pairAddress: EthereumAddress) -> Effect<Never, Never> {
        reserves(id, pairAddress)
    }
}
