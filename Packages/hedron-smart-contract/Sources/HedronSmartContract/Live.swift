// Live.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import Combine
import ComposableArchitecture
import EVMChain
import Foundation
import IdentifiedCollections
import os.log
import UIKit
import web3

public extension HedronSmartContractManager {
    static let live: HedronSmartContractManager = { () -> HedronSmartContractManager in
        var manager = HedronSmartContractManager()

        manager.create = { id in
            Effect.run { subscriber in
                let delegate = HedronSmartContractManagerDelegate(subscriber)

                let clients = Chain.allCases.reduce(into: [Chain: EthereumClient]()) { dict, chain in
                    dict[chain.id] = EthereumClient(url: chain.url)
                }

                dependencies[id] = Dependencies(delegate: delegate,
                                                clients: clients,
                                                subscriber: subscriber)
                return AnyCancellable {
                    dependencies[id] = nil
                }
            }
        }

        manager.destroy = { id in
            .fireAndForget {
                dependencies[id]?.subscriber.send(completion: .finished)
                dependencies[id] = nil
            }
        }

        manager.getHedronStakes = { id, chain in
            dependencies[id]?.subscriber.send(Action.hedronStakes(chain))
        }

        manager.getStakes = { id, address, chain in
            let accountDataKey = address + chain.description

            switch dependencies[id]?.stakesCache[accountDataKey] == nil {
            case true: dependencies[id]?.stakesCache[accountDataKey] = IdentifiedArrayOf<StakeLists_Parameter.Response>()
            case false: dependencies[id]?.stakesCache[accountDataKey]?.removeAll()
            }

            return manager.getStakeCount(id: id, address: EthereumAddress(address), chain: chain).receive(on: DispatchQueue.main).eraseToEffect()
        }

        manager.getStakeCount = { id, address, chain in
            guard let client = dependencies[id]?.clients[chain] else { return .none }

            return .fireAndForget {
                let stakes = StakeCount_Parameter(user: address)
                stakes.call(withClient: client,
                            responseType: StakeCount_Parameter.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .hexSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response?.stakeCount {
                        case let .some(count):
                            DispatchQueue.main.async {
                                manager.getStakeList(id, address, chain, count)
                            }
                        case .none:
                            os_log("No stake count", log: .hexSmartContract, type: .error)
                        }
                    }
                }
            }
        }

        manager.getStakeList = { id, address, chain, stakeCount in
            guard let client = dependencies[id]?.clients[chain] else { return }

            (0 ..< stakeCount).forEach { stakeIndex in
                let getStake = StakeLists_Parameter(user: address,
                                                    hsiIndex: stakeIndex)
                getStake.call(withClient: client,
                              responseType: StakeLists_Parameter.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .hexSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(stake):
                            DispatchQueue.main.async {
                                manager.updateStakeCache(id, address, chain, stake, stakeCount)
                            }
                        case .none:
                            os_log("No stake list", log: .hexSmartContract, type: .error)
                        }
                    }
                }
            }
        }

        manager.updateStakeCache = { id, address, chain, stake, stakeCount in
            let accountDataKey = address.value + chain.description

            dependencies[id]?.stakesCache[accountDataKey]?.updateOrAppend(stake)
            switch dependencies[id]?.stakesCache[accountDataKey] {
            case let .some(stakes) where stakes.count == Int(stakeCount):
                DispatchQueue.main.async {
                    dependencies[id]?.subscriber.send(Action.stakeList(Array(stakes), address, chain))
                }
            default:
                return
            }
        }
        return manager
    }()
}

// MARK: - Dependencies

private struct Dependencies {
    let delegate: HedronSmartContractManagerDelegate
    let clients: [Chain: EthereumClient]
    let subscriber: Effect<HedronSmartContractManager.Action, Never>.Subscriber
    var stakesCache = [String: IdentifiedArrayOf<StakeLists_Parameter.Response>]()
}

private var dependencies: [AnyHashable: Dependencies] = [:]

// MARK: - Delegate

private class HedronSmartContractManagerDelegate: NSObject {
    let subscriber: Effect<HedronSmartContractManager.Action, Never>.Subscriber

    init(_ subscriber: Effect<HedronSmartContractManager.Action, Never>.Subscriber) {
        self.subscriber = subscriber
    }
}
