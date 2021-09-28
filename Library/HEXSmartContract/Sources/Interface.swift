// Interface.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation
import web3

public struct HEXSmartContractManager {
    public enum Action: Equatable {
        case stakeList([StakeLists_Parameter.Response])
    }

    var create: (AnyHashable) -> Effect<Action, Never> = { _ in _unimplemented("create") }

    var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("destroy") }

    var getStakes: (AnyHashable, EthereumAddress) -> Effect<Never, Never> = { _, _ in _unimplemented("getStakes") }

    var getStakeCount: (AnyHashable, EthereumAddress) -> Effect<Never, Never> = { _, _ in _unimplemented("getStakeCount") }

    var getStakeList: (AnyHashable, EthereumAddress, BigUInt) -> Void = { _, _, _ in _unimplemented("getStakeList") }

    var updateStakeCache: (AnyHashable, StakeLists_Parameter.Response, BigUInt) -> Void = { _, _, _ in _unimplemented("updateStakeCache") }

    public func create(id: AnyHashable) -> Effect<Action, Never> {
        create(id)
    }

    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
        destroy(id)
    }

    public func getStakes(id: AnyHashable, address: EthereumAddress) -> Effect<Never, Never> {
        getStakes(id, address)
    }

    internal func getStakeCount(id: AnyHashable, address: EthereumAddress) -> Effect<Never, Never> {
        getStakeCount(id, address)
    }

    internal func getStakeList(id: AnyHashable, address: EthereumAddress, stakeCount: BigUInt) {
        getStakeList(id, address, stakeCount)
    }

    func updateStakeCache(id: AnyHashable, stake: StakeLists_Parameter.Response, stakeCount: BigUInt) {
        updateStakeCache(id, stake, stakeCount)
    }
}
