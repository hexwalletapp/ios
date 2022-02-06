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
        
        
        manager.token0 = { id, chain, pairAddress in
            guard let client = dependencies[id]?.clients[chain.id] else { return .none }
            return .fireAndForget {
                let token = Token0ABIFunction(contract: pairAddress)
                token.call(withClient: client,
                           responseType: Token0ABIFunction.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .uniswapSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.token(chain,
                                                                         pairAddress,
                                                                         response.address,
                                                                         .zero))
                            }
                        case .none:
                            os_log("No reserves in pair", log: .uniswapSmartContract, type: .error)
                        }
                    }
                }
            }
        }
        
        manager.token1 = { id, chain, pairAddress in
            guard let client = dependencies[id]?.clients[chain.id] else { return .none }
            return .fireAndForget {
                let token = Token1ABIFunction(contract: pairAddress)
                token.call(withClient: client,
                           responseType: Token1ABIFunction.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .uniswapSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.token(chain,
                                                                         pairAddress,
                                                                         response.address,
                                                                         .one))
                            }
                        case .none:
                            os_log("No reserves in pair", log: .uniswapSmartContract, type: .error)
                        }
                    }
                }
            }
        }
        
        // MARK: - V2
        
        manager.getPairV2 = { id, chain, first, second in
            guard let client = dependencies[id]?.clients[chain.id] else { return .none }
            
            return .fireAndForget {
                let getPair = GetPair(first: first, second: second)
                getPair.call(withClient: client,
                             responseType: GetPair.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .uniswapSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.pairAddress(chain,
                                                                               response.address))
                            }
                        case .none:
                            os_log("No pair from factory", log: .uniswapSmartContract, type: .info)
                        }
                    }
                }
            }
        }
        
        manager.reserves = { id, chain, pairAddress in
            guard let client = dependencies[id]?.clients[chain.id] else { return .none }
            return .fireAndForget {
                let getReserves = GetReserves(contract: pairAddress)
                getReserves.call(withClient: client,
                                 responseType: GetReserves.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .uniswapSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.reserves(chain,
                                                                            response.reserve0,
                                                                            response.reserve1,
                                                                            response.blockTimestampLast,
                                                                            pairAddress))
                            }
                        case .none:
                            os_log("No reserves in pair", log: .uniswapSmartContract, type: .error)
                        }
                    }
                }
            }
        }
        
        manager.getPoolV3 = { id, chain, tokenA, tokenB, fee in
            guard let client = dependencies[id]?.clients[chain.id] else { return .none }
            
            return .fireAndForget {
                let getPool = GetPool(tokenA: tokenA, tokenB: tokenB, fee: fee)
                getPool.call(withClient: client,
                             responseType: GetPool.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .uniswapSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                let tickerSpacing: Double
                                switch fee {
                                case 500: tickerSpacing = 10.0
                                case 3000: tickerSpacing = 60.0
                                case 10000: tickerSpacing = 200.0
                                default: tickerSpacing = 60.0
                                }
                                
                                dependencies[id]?.subscriber.send(.poolAddrses(chain,
                                                                               response.address,
                                                                               tickerSpacing))
                            }
                        case .none:
                            os_log("No pool from factory", log: .uniswapSmartContract, type: .info)
                        }
                    }
                }
            }
        }
        
        manager.liquidity = { id, chain, poolAddress in
            guard let client = dependencies[id]?.clients[chain.id] else { return .none }
            
            return .fireAndForget {
                let getLiquidity = LiquidityABIFunction(contract: poolAddress)
                getLiquidity.call(withClient: client,
                                  responseType: LiquidityABIFunction.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .uniswapSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.liquidity(chain,
                                                                             response.liquidity,
                                                                             poolAddress))
                            }
                        case .none:
                            os_log("No liquidity in pool", log: .uniswapSmartContract, type: .info)
                        }
                    }
                }
            }
        }
        
        manager.observe = { id, chain, poolAddress, secondsAgos in
            guard let client = dependencies[id]?.clients[chain.id] else { return .none }
            
            return .fireAndForget {
                let getObserve = ObserveABIFunction(contract: poolAddress, secondsAgos: secondsAgos)
                getObserve.call(withClient: client,
                                responseType: ObserveABIFunction.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .uniswapSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.observe(chain,
                                                                           response.tickCumulatives,
                                                                           response.secondsPerLiquidityCumulativeX128s,
                                                                           poolAddress))
                            }
                        default:
                            os_log("No liquidity in pool", log: .uniswapSmartContract, type: .info)
                        }
                    }
                }
            }
        }
        
        manager.slot0 = { id, chain, poolAddress in
            guard let client = dependencies[id]?.clients[chain.id] else { return .none }
            
            return .fireAndForget {
                let slot0 = Slot0ABIFunction(contract: poolAddress)
                slot0.call(withClient: client,
                           responseType: Slot0ABIFunction.Response.self) { error, response in
                    switch error {
                    case let .some(err):
                        os_log("%@", log: .uniswapSmartContract, type: .error, err.localizedDescription)
                    case .none:
                        switch response {
                        case let .some(response):
                            DispatchQueue.main.async {
                                dependencies[id]?.subscriber.send(.slot0(chain,
                                                                         poolAddress,
                                                                         response.sqrtPriceX96,
                                                                         response.tick,
                                                                         response.observationIndex,
                                                                         response.observationCardinality,
                                                                         response.observationCardinalityNext,
                                                                         response.feeProtocol,
                                                                         response.unlocked))
                            }
                        case .none:
                            os_log("No slot in pool", log: .uniswapSmartContract, type: .info)
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
