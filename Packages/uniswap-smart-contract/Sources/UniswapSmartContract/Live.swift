// Live.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import Combine
import ComposableArchitecture
import EVMChain
import Foundation
import IdentifiedCollections
import UIKit
import web3

public extension UniswapSmartContractManager {
    static let live: UniswapSmartContractManager = { () -> UniswapSmartContractManager in
        var manager = UniswapSmartContractManager()

        manager.create = { id in
            Effect.run { subscriber in
                let delegate = UniswapSmartContractManagerDelegate(subscriber)

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

        manager.getPair = { id, chain, first, second in
            guard let client = dependencies[id]?.clients[chain.id] else { return .none }

            return .fireAndForget {
                let getPair = GetPair(first: first, second: second)
                getPair.call(withClient: client,
                             responseType: GetPair.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        print(err)
                    case .none:
                        switch response?.address {
                        case let .some(address):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.pairAddress(chain, address))
                            }
                        case .none:
                            print("no pair")
                        }
                    }
                }
            }
        }

        manager.getReserves = { id, chain, pairAddress in
            guard let client = dependencies[id]?.clients[chain.id] else { return .none }
            return .fireAndForget {
                let getReserves = GetReserves(contract: pairAddress)
                getReserves.call(withClient: client,
                                 responseType: GetReserves.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        print(err)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.reserves(chain,
                                                                            response.reserve0,
                                                                            response.reserve1,
                                                                            response.blockTimestampLast))
                            }
                        case .none:
                            print("no reserves")
                        }
                    }
                }
            }
        }
        return manager
    }()
}

// MARK: - Dependencies

private struct Dependencies {
    let delegate: UniswapSmartContractManagerDelegate
    let clients: [Chain: EthereumClient]
    let subscriber: Effect<UniswapSmartContractManager.Action, Never>.Subscriber
}

private var dependencies: [AnyHashable: Dependencies] = [:]

// MARK: - Delegate

private class UniswapSmartContractManagerDelegate: NSObject {
    let subscriber: Effect<UniswapSmartContractManager.Action, Never>.Subscriber

    init(_ subscriber: Effect<UniswapSmartContractManager.Action, Never>.Subscriber) {
        self.subscriber = subscriber
    }
}
