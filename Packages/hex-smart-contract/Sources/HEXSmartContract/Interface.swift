// Interface.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation
import web3

public struct HEXSmartContractManager {
    public enum Action: Equatable {
        case stakeList([StakeLists_Parameter.Response], EthereumAddress, Chain)
        case dailyData([BigUInt], Chain)
        case currentDay(BigUInt, Chain)
        case globalInfo(GlobalInfo.Response, Chain)
        case balance(BigUInt, EthereumAddress, Chain)
    }

    var create: (AnyHashable) -> Effect<Action, Never> = { _ in _unimplemented("create") }

    var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("destroy") }

    var getStakes: (AnyHashable, String, Chain) -> Effect<Never, Never> = { _, _, _ in _unimplemented("getStakes") }

    var getStakeCount: (AnyHashable, EthereumAddress, Chain) -> Effect<Never, Never> = { _, _, _ in _unimplemented("getStakeCount") }

    var getStakeList: (AnyHashable, EthereumAddress, Chain, BigUInt) -> Void = { _, _, _, _ in _unimplemented("getStakeList") }

    var updateStakeCache: (AnyHashable, EthereumAddress, Chain, StakeLists_Parameter.Response, BigUInt) -> Void = { _, _, _, _, _ in _unimplemented("updateStakeCache") }

    var getDailyDataRange: (AnyHashable, Chain, UInt16, UInt16) -> Effect<Never, Never> = { _, _, _, _ in _unimplemented("getDailyDataRange") }

    var getCurrentDay: (AnyHashable, Chain) -> Effect<Never, Never> = { _, _ in _unimplemented("getCurrentDay") }

    var getGlobalInfo: (AnyHashable, Chain) -> Effect<Never, Never> = { _, _ in _unimplemented("getGlobalInfo") }

    var getBalance: (AnyHashable, String, Chain) -> Effect<Never, Never> = { _, _, _ in _unimplemented("getBalance") }

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

    public func getDailyDataRange(id: AnyHashable, chain: Chain, begin: UInt16, end: UInt16) -> Effect<Never, Never> {
        getDailyDataRange(id, chain, begin, end)
    }

    public func getCurrentDay(id: AnyHashable, chain: Chain) -> Effect<Never, Never> {
        getCurrentDay(id, chain)
    }

    public func getGlobalInfo(id: AnyHashable, chain: Chain) -> Effect<Never, Never> {
        getGlobalInfo(id, chain)
    }

    public func getBalance(id: AnyHashable, address: String, chain: Chain) -> Effect<Never, Never> {
        getBalance(id, address, chain)
    }
}
