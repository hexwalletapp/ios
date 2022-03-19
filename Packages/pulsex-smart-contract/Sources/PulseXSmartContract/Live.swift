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

public extension PulseXSmartContractManager {
    static let live: PulseXSmartContractManager = { () -> PulseXSmartContractManager in
        var manager = PulseXSmartContractManager()

        manager.create = { id in
            Effect.run { subscriber in
                let delegate = PulseXSmartContractManagerDelegate(subscriber)
                let client = EthereumClient(url: Chain.pulse.url)

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

        manager.token0 = { id, pairAddress in
            guard let client = dependencies[id]?.client else { return .none }
            return .fireAndForget {
                let token = Token0ABIFunction(contract: pairAddress)
                token.call(withClient: client,
                           responseType: Token0ABIFunction.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .pulseXSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.token(pairAddress,
                                                                         response.address,
                                                                         .zero))
                            }
                        case .none:
                            os_log("No reserves in pair", log: .pulseXSmartContract, type: .error)
                        }
                    }
                }
            }
        }

        manager.token1 = { id, pairAddress in
            guard let client = dependencies[id]?.client else { return .none }
            return .fireAndForget {
                let token = Token1ABIFunction(contract: pairAddress)
                token.call(withClient: client,
                           responseType: Token1ABIFunction.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .pulseXSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.token(pairAddress,
                                                                         response.address,
                                                                         .one))
                            }
                        case .none:
                            os_log("No reserves in pair", log: .pulseXSmartContract, type: .error)
                        }
                    }
                }
            }
        }

        // MARK: - V2

        manager.getPairV2 = { id, first, second in
            guard let client = dependencies[id]?.client else { return .none }

            return .fireAndForget {
                let getPair = GetPair(tokenA: first, tokenB: second)
                getPair.call(withClient: client,
                             responseType: GetPair.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .pulseXSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.pairAddress(response.address))
                            }
                        case .none:
                            os_log("No pair from factory", log: .pulseXSmartContract, type: .info)
                        }
                    }
                }
            }
        }

        manager.reserves = { id, pairAddress in
            guard let client = dependencies[id]?.client else { return .none }
            return .fireAndForget {
                let getReserves = GetReserves(contract: pairAddress)
                getReserves.call(withClient: client,
                                 responseType: GetReserves.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .pulseXSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.reserves(response.reserve0,
                                                                            response.reserve1,
                                                                            response.blockTimestampLast,
                                                                            pairAddress))
                            }
                        case .none:
                            os_log("No reserves in pair", log: .pulseXSmartContract, type: .error)
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
    let delegate: PulseXSmartContractManagerDelegate
    let client: EthereumClient
    let subscriber: Effect<PulseXSmartContractManager.Action, Never>.Subscriber
}

private var dependencies: [AnyHashable: Dependencies] = [:]

// MARK: - Delegate

private class PulseXSmartContractManagerDelegate: NSObject {
    let subscriber: Effect<PulseXSmartContractManager.Action, Never>.Subscriber

    init(_ subscriber: Effect<PulseXSmartContractManager.Action, Never>.Subscriber) {
        self.subscriber = subscriber
    }
}
