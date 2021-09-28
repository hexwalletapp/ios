// Live.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Combine
import ComposableArchitecture
import Foundation
import web3

public extension HEXSmartContractManager {
    static let live: HEXSmartContractManager = { () -> HEXSmartContractManager in
        var manager = HEXSmartContractManager()

        manager.create = { id in
            Effect.run { subscriber in
                let delegate = HEXSmartContractManagerDelegate(subscriber)

                let client = EthereumClient(url: URL(string: "https://mainnet.infura.io/v3/84842078b09946638c03157f83405213")!)

                dependencies[id] = Dependencies(delegate: delegate,
                                                client: client,
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

        manager.getStakes = { id, address in
            dependencies[id]?.stakesCache = [StakeLists_Parameter.Response]()
            return manager.getStakeCount(id: id, address: address)
        }

        manager.getStakeCount = { id, address in
            guard let client = dependencies[id]?.client else { return .none }

            return .fireAndForget {
                let stakes = StakeCount_Parameter(stakeAddress: address)
                stakes.call(withClient: client,
                            responseType: StakeCount_Parameter.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        print(err)
                    case .none:
                        switch response?.stakeCount {
                        case let .some(count):
                            manager.getStakeList(id, address, count)
                        case .none:
                            print("no stakes")
                        }
                    }
                }
            }
        }

        manager.getStakeList = { id, address, stakeCount in
            guard let client = dependencies[id]?.client else { return }

            (0 ..< stakeCount).forEach { stakeIndex in
                let getStake = StakeLists_Parameter(stakeAddress: address,
                                                    stakeIndex: stakeIndex)
                getStake.call(withClient: client,
                              responseType: StakeLists_Parameter.Response.self) { error, response in
                    switch error {
                    case let .some(error):
                        print(error)
                    case .none:
                        switch response {
                        case let .some(stake):
                            manager.updateStakeCache(id, stake, stakeCount)
                        case .none:
                            print("no stake")
                        }
                    }
                }
            }
        }

        manager.updateStakeCache = { id, stake, stakeCount in
            dependencies[id]?.stakesCache.append(stake)
            switch dependencies[id]?.stakesCache {
            case let .some(stakes) where stakes.count == Int(stakeCount):
                dependencies[id]?.subscriber.send(.stakeList(stakes))
            default:
                return
            }
        }

        return manager
    }()
}

// MARK: - Dependencies

private struct Dependencies {
    let delegate: HEXSmartContractManagerDelegate
    let client: EthereumClient
    let subscriber: Effect<HEXSmartContractManager.Action, Never>.Subscriber
    var stakesCache = [StakeLists_Parameter.Response]()
}

private var dependencies: [AnyHashable: Dependencies] = [:]

// MARK: - Delegate

private class HEXSmartContractManagerDelegate: NSObject {
    let subscriber: Effect<HEXSmartContractManager.Action, Never>.Subscriber

    init(_ subscriber: Effect<HEXSmartContractManager.Action, Never>.Subscriber) {
        self.subscriber = subscriber
    }
}
