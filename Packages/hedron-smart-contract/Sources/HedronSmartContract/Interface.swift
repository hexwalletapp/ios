// Interface.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import EVMChain
import Foundation
import web3

public struct HedronSmartContractManager {
    public enum Action: Equatable {
        case hedronStakes(Chain)
        case stake(StakeLists_Parameter.Response, EthereumAddress, Chain, BigUInt)
    }

    var create: (AnyHashable) -> Effect<Action, Never> = { _ in _unimplemented("create") }

    var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("destroy") }

    var getHedronStakes: (AnyHashable, Chain) -> Void = { _, _ in _unimplemented("getHedronStakes") }

    var getStakes: (AnyHashable, String, Chain) -> Effect<Never, Never> = { _, _, _ in _unimplemented("getStakes") }

    var getStakeCount: (AnyHashable, EthereumAddress, Chain) -> Effect<Never, Never> = { _, _, _ in _unimplemented("getStakeCount") }

    var getStakeList: (AnyHashable, EthereumAddress, Chain, BigUInt) -> Void = { _, _, _, _ in _unimplemented("getStakeList") }

    public func create(id: AnyHashable) -> Effect<Action, Never> {
        create(id)
    }

    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
        destroy(id)
    }

    public func getHedronStakes(id: AnyHashable, chain: Chain) {
        getHedronStakes(id, chain)
    }

    public func getStakes(id: AnyHashable, address: String, chain: Chain) -> Effect<Never, Never> {
        getStakes(id, address, chain)
    }

    internal func getStakeCount(id: AnyHashable, address: EthereumAddress, chain: Chain) -> Effect<Never, Never> {
        getStakeCount(id, address, chain)
    }

    internal func getStakeList(id: AnyHashable, address: EthereumAddress, chain: Chain, stakeCount: BigUInt) {
        getStakeList(id, address, chain, stakeCount)
    }
}
