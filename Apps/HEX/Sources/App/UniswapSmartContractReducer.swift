// UniswapSmartContractReducer.swift
// Copyright (c) 2022 Joe Blau

import BigInt
import ComposableArchitecture
import Foundation
import UniswapSmartContract
import web3

let uniswapReducer = Reducer<AppState, UniswapSmartContractManager.Action, AppEnvironment> { state, action, environment in

    switch action {
    case let .token(chain, pairAddress, tokenAddress, tokenPosition):
        var liquidity = state.liquidity

        guard var newLiquidity = liquidity.first(where: {
            $0.chain == chain &&
                $0.address == pairAddress
        }),
            let tokenInfo = k.TOKEN_INFO_DICT[tokenAddress]
        else { return .none }

        switch tokenPosition {
        case .zero:
            newLiquidity.tokenA.decimals = tokenInfo.decimals
            newLiquidity.tokenA.symbol = tokenInfo.symbol
            newLiquidity.tokenA.address = tokenAddress
        case .one:
            newLiquidity.tokenB.decimals = tokenInfo.decimals
            newLiquidity.tokenB.symbol = tokenInfo.symbol
            newLiquidity.tokenB.address = tokenAddress
        }

        var set = Set([newLiquidity])

        state.liquidity.forEach { liquidity in
            set.insert(liquidity)
        }

        state.liquidity = [DEXLiquidity](set)
        return .none

    case let .pairAddress(chain, pairAddress):
        return environment.uniswapManager
            .reserves(id: UniswapManagerId(),
                      chain: chain,
                      pairAddress: pairAddress)
            .fireAndForget()

    case let .reserves(chain, reserve0, reserve1, timestamp, pairAddress):
        var set = Set<DEXLiquidity>(state.liquidity)
        set.insert(DEXLiquidity(chain: chain,
                                address: pairAddress,
                                version: .v2,
                                tokenA: ERC20Token(symbol: "0",
                                                   address: EthereumAddress(""),
                                                   amount: reserve0),
                                tokenB: ERC20Token(symbol: "1",
                                                   address: EthereumAddress(""),
                                                   amount: reserve1)))
        state.liquidity = [DEXLiquidity](set)

        let ratio = (reserve0.number.doubleValue / reserve1.number.doubleValue) / 100.0
        switch chain {
        case .ethereum:

            switch pairAddress {
            case EthereumAddress("0xf6dcdce0ac3001b2f67f750bc64ea5beb37b5824"):
                state.hexContractOnChain.ethData.hexUsd = 1.0 / ratio
                state.calculator.price = 1.0 / ratio

                state.accountsData.filter { $0.account.chain == .ethereum }.forEach { accountData in
                    state.accountsData[id: accountData.id]?.hexPrice = 1.0 / ratio
                }
            default:
                break
            }

        case .pulse:
            state.hexContractOnChain.plsData.hexUsd = 1.0 / ratio

            state.accountsData.filter { $0.account.chain == .pulse }.forEach { accountData in
                state.accountsData[id: accountData.id]?.hexPrice = 1.0 / ratio
            }
        }
        return .merge(
            environment.uniswapManager.token0(id: UniswapManagerId(),
                                              chain: chain,
                                              pairAddress: pairAddress)
                .fireAndForget(),
            environment.uniswapManager.token1(id: UniswapManagerId(),
                                              chain: chain,
                                              pairAddress: pairAddress)
                .fireAndForget()
        )

    case let .poolAddrses(chain, poolAddress, tickerSpacing):
        state.poolSpacing[poolAddress.value] = BigInt(tickerSpacing)
        return .merge(
            environment.uniswapManager.liquidity(id: UniswapManagerId(),
                                                 chain: chain,
                                                 pairAddress: poolAddress)
                .fireAndForget(),
            environment.uniswapManager.token0(id: UniswapManagerId(),
                                              chain: chain,
                                              pairAddress: poolAddress)
                .fireAndForget(),
            environment.uniswapManager.token1(id: UniswapManagerId(),
                                              chain: chain,
                                              pairAddress: poolAddress)
                .fireAndForget()
        )

    case let .liquidity(chain, liquidity, poolAddress):
        state.hexContractOnChain.ethData.v3Liquidity[poolAddress] = liquidity
        return environment.uniswapManager
            .slot0(id: UniswapManagerId(),
                   chain: chain,
                   pairAddress: poolAddress)
            .fireAndForget()

    case .observe:
        return .none

    case let .slot0(chain, poolAddress, sqrtPriceX96, tick, _, _, _, _, _):
        guard let liquidity = state.hexContractOnChain.ethData.v3Liquidity[poolAddress],
              let tickSpacing = state.poolSpacing[poolAddress.value] else { return .none }

        let tickLow = (tick / tickSpacing) * tickSpacing
        let tickHigh = tickLow + tickSpacing

//        print(tickLow)
//        print(tickHigh)
//        print(liquidity)
//        let tick = Double(tick)
//
//        let price = pow(1.0001, tick)
//
//        let sa = pow(1.0001, Double(Int(bottom) / 2))
//        let sb = pow(1.0001, Double(Int(top) / 2))
//        let sp = pow(price, 0.5)
//
//        let amount0 = liquidity.number.doubleValue * (sb - sp) / (sp * sb)
//        let amount1 = liquidity.number.doubleValue * (sp - sa)
//        print(poolAddress.value)

        // Add to liquidity

        var set = Set<DEXLiquidity>(state.liquidity)
        set.insert(DEXLiquidity(chain: chain,
                                address: poolAddress,
                                version: .v3,
                                tokenA: ERC20Token(symbol: "A",
                                                   address: EthereumAddress(""),
                                                   amount: BigUInt(0)),
                                tokenB: ERC20Token(symbol: "B",
                                                   address: EthereumAddress(""),
                                                   amount: BigUInt(0))))
        state.liquidity = [DEXLiquidity](set)

        return .merge(
            environment.uniswapManager.token0(id: UniswapManagerId(),
                                              chain: chain,
                                              pairAddress: poolAddress)
                .fireAndForget(),
            environment.uniswapManager.token1(id: UniswapManagerId(),
                                              chain: chain,
                                              pairAddress: poolAddress)
                .fireAndForget()
        )
    }
}
