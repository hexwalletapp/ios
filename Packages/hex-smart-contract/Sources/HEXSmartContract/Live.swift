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

public extension HEXSmartContractManager {
    static let live: HEXSmartContractManager = { () -> HEXSmartContractManager in
        var manager = HEXSmartContractManager()

        manager.create = { id in
            Effect.run { subscriber in
                let delegate = HEXSmartContractManagerDelegate(subscriber)

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

        manager.getStakes = { id, address, chain in
            let accountDataKey = address + chain.description

            return manager.getStakeCount(id: id, address: EthereumAddress(address), chain: chain).receive(on: DispatchQueue.main).eraseToEffect()
        }

        manager.getStakeCount = { id, address, chain in
            guard let client = dependencies[id]?.clients[chain] else { return .none }

            return .fireAndForget {
                let stakes = StakeCount_Parameter(stakeAddress: address)
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
                let getStake = StakeLists_Parameter(stakeAddress: address,
                                                    stakeIndex: stakeIndex)
                getStake.call(withClient: client,
                              responseType: StakeLists_Parameter.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .hexSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(stake):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.stakeList(stake, address, chain))
                            }
                        case .none:
                            os_log("No stake list", log: .hexSmartContract, type: .error)
                        }
                    }
                }
            }
        }

        manager.getDailyDataRange = { id, chain, begin, end in
            guard let client = dependencies[id]?.clients[chain] else { return .none }

            return .fireAndForget {
                let dailyDataRange = DailyDataRange_Parameter(beginDay: BigUInt(begin), endDay: BigUInt(end))
                dailyDataRange.call(withClient: client,
                                    responseType: DailyDataRange_Parameter.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .hexSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response?.list {
                        case let .some(list):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.dailyData(list, chain))
                            }
                        case .none:
                            os_log("No stakes", log: .hexSmartContract, type: .error)
                        }
                    }
                }
            }
        }

        manager.getCurrentDay = { id, chain in
            guard let client = dependencies[id]?.clients[chain] else { return .none }

            return .fireAndForget {
                let currentDay = CurrentDay()
                currentDay.call(withClient: client,
                                responseType: CurrentDay.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .hexSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response?.day {
                        case let .some(day):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.currentDay(day, chain))
                            }
                        case .none:
                            os_log("No current day", log: .hexSmartContract, type: .error)
                        }
                    }
                }
            }
        }

        manager.getGlobalInfo = { id, chain in
            guard let client = dependencies[id]?.clients[chain] else { return .none }

            return .fireAndForget {
                let globalInfo = GlobalInfo()
                globalInfo.call(withClient: client,
                                responseType: GlobalInfo.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .hexSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(globalInfo):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.globalInfo(globalInfo, chain))
                            }
                        case .none:
                            os_log("No global info", log: .hexSmartContract, type: .error)
                        }
                    }
                }
            }
        }

        manager.getBalance = { id, address, chain in
            guard let client = dependencies[id]?.clients[chain] else { return .none }
            let ethereumAddress = EthereumAddress(address)
            return .fireAndForget {
                let erc20 = ERC20(client: client)
                erc20.balanceOf(tokenContract: EthereumAddress("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39"),
                                address: ethereumAddress) { error, balance in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .hexSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch balance {
                        case let .some(balance):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.balance(balance, ethereumAddress, chain))
                            }
                        case .none:
                            os_log("No balance", log: .hexSmartContract, type: .error)
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
    let delegate: HEXSmartContractManagerDelegate
    let clients: [Chain: EthereumClient]
    let subscriber: Effect<HEXSmartContractManager.Action, Never>.Subscriber
}

private var dependencies: [AnyHashable: Dependencies] = [:]

// MARK: - Delegate

private class HEXSmartContractManagerDelegate: NSObject {
    let subscriber: Effect<HEXSmartContractManager.Action, Never>.Subscriber

    init(_ subscriber: Effect<HEXSmartContractManager.Action, Never>.Subscriber) {
        self.subscriber = subscriber
    }
}
