// Interface.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import EVMChain
import Foundation
import web3

public struct UniswapSmartContractManager {
    public enum Action: Equatable {
        case token(Chain, EthereumAddress, EthereumAddress, TokenPosition)
        case pairAddress(Chain, EthereumAddress)
        case poolAddrses(Chain, EthereumAddress, Double)
        case reserves(Chain, BigUInt, BigUInt, UInt32, EthereumAddress)
        case liquidity(Chain, BigUInt, EthereumAddress)
        case observe(Chain, [BigInt], [BigUInt], EthereumAddress)
        case slot0(Chain, EthereumAddress, BigUInt, BigInt, UInt16, UInt16, UInt16, UInt8, Bool)
    }

    var create: (AnyHashable) -> Effect<Action, Never> = { _ in _unimplemented("create") }

    var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("destroy") }

    var token0: (AnyHashable, Chain, EthereumAddress) -> Effect<Never, Never> = { _, _, _ in _unimplemented("token0") }

    var token1: (AnyHashable, Chain, EthereumAddress) -> Effect<Never, Never> = { _, _, _ in _unimplemented("token1") }

    var getPairV2: (AnyHashable, Chain, EthereumAddress, EthereumAddress) -> Effect<Never, Never> = { _, _, _, _ in _unimplemented("getPairV2") }

    var reserves: (AnyHashable, Chain, EthereumAddress) -> Effect<Never, Never> = { _, _, _ in _unimplemented("reserves") }

    var getPoolV3: (AnyHashable, Chain, EthereumAddress, EthereumAddress, BigUInt) -> Effect<Never, Never> = { _, _, _, _, _ in _unimplemented("getPoolV3") }

    var liquidity: (AnyHashable, Chain, EthereumAddress) -> Effect<Never, Never> = { _, _, _ in _unimplemented("liquidity") }

    var observe: (AnyHashable, Chain, EthereumAddress, [UInt32]) -> Effect<Never, Never> = { _, _, _, _ in _unimplemented("observe") }

    var slot0: (AnyHashable, Chain, EthereumAddress) -> Effect<Never, Never> = { _, _, _ in _unimplemented("slot0") }

    // MARK: - Shared

    public func create(id: AnyHashable) -> Effect<Action, Never> {
        create(id)
    }

    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
        destroy(id)
    }

    public func token0(id: AnyHashable, chain: Chain, pairAddress: EthereumAddress) -> Effect<Never, Never> {
        token0(id, chain, pairAddress)
    }

    public func token1(id: AnyHashable, chain: Chain, pairAddress: EthereumAddress) -> Effect<Never, Never> {
        token1(id, chain, pairAddress)
    }

    // MARK: - Uniswap V2

    public func getPairV2(id: AnyHashable, chain: Chain, token0: EthereumAddress, token1: EthereumAddress) -> Effect<Never, Never> {
        getPairV2(id, chain, token0, token1)
    }

    public func reserves(id: AnyHashable, chain: Chain, pairAddress: EthereumAddress) -> Effect<Never, Never> {
        reserves(id, chain, pairAddress)
    }

    // MARK: - Uniswap V3

    public func getPoolV3(id: AnyHashable, chain: Chain, tokenA: EthereumAddress, tokenB: EthereumAddress, fee: BigUInt) -> Effect<Never, Never> {
        getPoolV3(id, chain, tokenA, tokenB, fee)
    }

    public func liquidity(id: AnyHashable, chain: Chain, pairAddress: EthereumAddress) -> Effect<Never, Never> {
        liquidity(id, chain, pairAddress)
    }

    public func observe(id: AnyHashable, chain: Chain, pairAddress: EthereumAddress, secondsAgos: [UInt32]) -> Effect<Never, Never> {
        observe(id, chain, pairAddress, secondsAgos)
    }

    public func slot0(id: AnyHashable, chain: Chain, pairAddress: EthereumAddress) -> Effect<Never, Never> {
        slot0(id, chain, pairAddress)
    }
}
