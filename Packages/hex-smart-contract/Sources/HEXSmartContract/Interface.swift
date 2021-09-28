// Interface.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation
import web3

public struct HEXSmartContractManager {
    public enum Action: Equatable {
        case stakeList([StakeLists_Parameter.Response], EthereumAddress, Chain)
        case dailyData([BigUInt], EthereumAddress, Chain)
        case currentDay(BigUInt)
    }

    var create: (AnyHashable) -> Effect<Action, Never> = { _ in _unimplemented("create") }

    var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("destroy") }

    var getStakes: (AnyHashable, String, Chain) -> Effect<Never, Never> = { _, _, _ in _unimplemented("getStakes") }

    var getStakeCount: (AnyHashable, EthereumAddress, Chain) -> Effect<Never, Never> = { _, _, _ in _unimplemented("getStakeCount") }

    var getStakeList: (AnyHashable, EthereumAddress, Chain, BigUInt) -> Void = { _, _, _, _ in _unimplemented("getStakeList") }

    var updateStakeCache: (AnyHashable, EthereumAddress, Chain, StakeLists_Parameter.Response, BigUInt) -> Void = { _, _, _, _, _ in _unimplemented("updateStakeCache") }

    var getDailyDataRange: (AnyHashable, EthereumAddress, Chain, UInt16, UInt16) -> Effect<Never, Never> = { _, _, _, _, _ in _unimplemented("getDailyDataRange") }

    var getCurrentDay: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("getCurrentDay") }

    public func create(id: AnyHashable) -> Effect<Action, Never> {
        create(id)
    }

    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
        destroy(id)
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

    func updateStakeCache(id: AnyHashable, address: EthereumAddress, chain: Chain, stake: StakeLists_Parameter.Response, stakeCount: BigUInt) {
        updateStakeCache(id, address, chain, stake, stakeCount)
    }

    public func getDailyDataRange(id: AnyHashable, address: EthereumAddress, chain: Chain, begin: UInt16, end: UInt16) -> Effect<Never, Never> {
        getDailyDataRange(id, address, chain, begin, end)
    }

    public func getCurrentDay(id: AnyHashable) -> Effect<Never, Never> {
        getCurrentDay(id)
    }
}
