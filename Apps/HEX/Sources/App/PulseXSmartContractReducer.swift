// UniswapSmartContractReducer.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation
import PulseXSmartContract
import web3

let pulseXReducer = Reducer<AppState, PulseXSmartContractManager.Action, AppEnvironment> { state, action, environment in

    switch action {
    case let .token(pairAddress, tokenAddress, tokenPosition):
//        var liquidity = state.liquidity
//
//        guard var newLiquidity = liquidity.first(where: {
//            $0.chain == chain &&
//                $0.address == pairAddress
//        }),
//            let tokenInfo = k.TOKEN_INFO_DICT[tokenAddress]
//        else { return .none }
//
//        switch tokenPosition {
//        case .zero:
//            newLiquidity.tokenA.decimals = tokenInfo.decimals
//            newLiquidity.tokenA.symbol = tokenInfo.symbol
//            newLiquidity.tokenA.address = tokenAddress
//        case .one:
//            newLiquidity.tokenB.decimals = tokenInfo.decimals
//            newLiquidity.tokenB.symbol = tokenInfo.symbol
//            newLiquidity.tokenB.address = tokenAddress
//        }
//
//        var set = Set([newLiquidity])
//
//        state.liquidity.forEach { liquidity in
//            set.insert(liquidity)
//        }
//
//        state.liquidity = [DEXLiquidity](set)
        return .none

    case let .pairAddress(pairAddress):
        
        return environment.pulseXManager
            .reserves(id: PulseXManagerId(),
                      pairAddress: pairAddress)
            .fireAndForget()

    case let .reserves(reserve0, reserve1, timestamp, pairAddress):
//        var set = Set<DEXLiquidity>(state.liquidity)
//        set.insert(DEXLiquidity(chain: chain,
//                                address: pairAddress,
//                                version: .v2,
//                                tokenA: ERC20Token(symbol: "0",
//                                                   address: EthereumAddress(""),
//                                                   amount: reserve0),
//                                tokenB: ERC20Token(symbol: "1",
//                                                   address: EthereumAddress(""),
//                                                   amount: reserve1)))
//        state.liquidity = [DEXLiquidity](set)
//
//        let ratio = (reserve0.number.doubleValue / reserve1.number.doubleValue) / 100.0
//        switch (chain, pairAddress) {
//        case (.ethereum, EthereumAddress("0xf6dcdce0ac3001b2f67f750bc64ea5beb37b5824")):
//            state.hexContractOnChain.ethData.hexUsd = 1.0 / ratio
//            state.calculator.currentPrice = 1.0 / ratio
//
//            state.accountsData.filter { $0.account.chain == .ethereum }.forEach { accountData in
//                state.accountsData[id: accountData.id]?.hexPrice = 1.0 / ratio
//            }
//
//        case (.pulse, EthereumAddress("0xf6dcdce0ac3001b2f67f750bc64ea5beb37b5824")):
//            state.hexContractOnChain.plsData.hexUsd = 1.0 / ratio
//            state.accountsData.filter { $0.account.chain == .pulse }.forEach { accountData in
//                state.accountsData[id: accountData.id]?.hexPrice = 1.0 / ratio
//            }
//        default:
//            break
//        }
//        return .merge(
//            environment.pulseXManager.token0(id: PulseXManagerId(),
//                                              chain: chain,
//                                              pairAddress: pairAddress)
//                .fireAndForget(),
//            environment.pulseXManager.token1(id: PulseXManagerId(),
//                                              chain: chain,
//                                              pairAddress: pairAddress)
//                .fireAndForget()
//        )
        return .none
    }
}
