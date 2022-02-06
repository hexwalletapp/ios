// DEXLiquidityChartView.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import SwiftUI

struct DEXLiquidityChartView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVStack {
                    LiquidityChartView(liquidity: viewStore.liquidity.filter { $0.chain == .ethereum },
                                       interaction: true).frame(height: 300)
                    ForEach(viewStore.liquidity.filter { $0.chain == .ethereum }) { liquidity in
                        GroupBox(label:
                                    Label(liquidity.pairPool ,
                                          systemImage: "wallet.pass.fill").font(.body.monospaced())
                        ) {
                            VStack(alignment: .trailing, spacing: 8) {
                                row(token: liquidity.tokenA)
                                row(token: liquidity.tokenB)
                                HStack(alignment: .top) {
                                    liquidity.version.label
                                    Spacer()
                                    Text(liquidity.address.shortAddress)
                                }
                                .padding(.top, 8)
                                .font(.caption.monospaced())
                                .foregroundColor(.secondary)
                            }
                            .padding(.top, 8)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding([.horizontal])
                        .padding([.vertical], 10)
                    }
                }
            }
            .navigationTitle("Liquidty")
        }
    }
    
    func row(token: ERC20Token) -> some View {
        HStack {
            Text(token.symbol)
            Spacer()
            Text("\(token.adjustedAmount.number)")
                .font(.body.monospaced())
        }
    }
    
    var preview: some View {
        WithViewStore(store) { viewStore in
            GroupBox {
                LiquidityChartView(liquidity: viewStore.liquidity.filter { $0.chain == .ethereum }).frame(height: 300)
            } label: {
                Text("Liquidty")
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .groupBoxStyle(ChartGroupBoxStyle(color: .primary,
                                              destination: self))
        }
    }
}

// struct DEXLiquidityChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        DEXLiquidityChartView()
//    }
// }
