// ChartsView.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import SwiftUI

struct ChartsView: View {
    let store: Store<AppState, AppAction>

    let chartHeight = UIScreen.main.bounds.height * 0.6

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Section {
                        LazyVStack {
                            handle
                            DEXLiquidityChartView(store: store).preview.frame(height: 400)
                        }
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .zIndex(1)
                    } header: {
                        chart.frame(height: chartHeight).zIndex(0)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    var handle: some View {
        HStack {
            Spacer()
            Rectangle().foregroundColor(Color(.systemGray3))
                .frame(width: 64, height: 6, alignment: .center)
                .clipShape(Capsule())
            Spacer()
        }.padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
    }

    var chart: some View {
        WithViewStore(store) { viewStore in
            VStack {
                PriceChartView(store: store,
                               chartScale: viewStore.selectedChartScale,
                               timeScale: viewStore.selectedTimeScale,
                               chartType: viewStore.selectedChartType,
                               ohlcv: viewStore.ohlcv)
                    .overlay(alignment: .trailing) {
                        Text(NSNumber(value:
                            viewStore.selectedChartScale == .auto ? viewStore.rightAxisLivePrice.price : pow(10, viewStore.rightAxisLivePrice.price)
                        ).currencyString())
                            .padding(2)
                            .foregroundColor(.white)
                            .background(Color(viewStore.rightAxisLivePrice.background))
                            .font(.system(size: 10, design: .monospaced))
                    }
            }
            .padding([.vertical])
            .background(Color(.systemGroupedBackground))
            .navigationBarTitle(viewStore.hexContractOnChain.ethData.price.currencyString(maxFraction: 4))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    switch viewStore.chartLoading {
                    case true: ProgressView()
                    case false: EmptyView()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(ChartScale.allCases) { timeScale in
                            Button {
                                viewStore.send(.binding(.set(\.$selectedChartScale, timeScale)))
                            } label: {
                                Toggle(timeScale.description,
                                       isOn: .constant(timeScale == viewStore.selectedChartScale))
                            }
                        }
                    } label: {
                        Text(viewStore.selectedChartScale.description)
                    }.disabled(viewStore.chartLoading)

                    Menu(content: {
                        minuteScale
                        hourScale
                        dayScale
                    }, label: {
                        Text(viewStore.selectedTimeScale.code)
                    }).disabled(viewStore.chartLoading)

                    Menu(content: {
                        ForEach(ChartType.allCases) { chart in
                            Button {
                                viewStore.send(.binding(.set(\.$selectedChartType, chart)))
                            } label: {
                                Toggle(chart.description,
                                       isOn: .constant(chart == viewStore.selectedChartType))
                            }
                        }
                    }, label: {
                        viewStore.selectedChartType.icon
                    }).disabled(viewStore.chartLoading)
                }
            }
        }
    }

    var minuteScale: some View {
        Section {
            ForEach(TimeScaleMinute.allCases) { minute in
                timeScaleButton(timeScale: .minute(minute))
            }
        }
    }

    var hourScale: some View {
        Section {
            ForEach(TimeScaleHour.allCases) { hour in
                timeScaleButton(timeScale: .hour(hour))
            }
        }
    }

    var dayScale: some View {
        Section {
            ForEach(TimeScaleDay.allCases) { day in
                timeScaleButton(timeScale: .day(day))
            }
        }
    }

    func timeScaleButton(timeScale: TimeScale) -> some View {
        WithViewStore(store) { viewStore in
            Button {
                viewStore.send(.binding(.set(\.$selectedTimeScale, timeScale)))
            } label: {
                Toggle(timeScale.description,
                       isOn: .constant(timeScale == viewStore.selectedTimeScale))
            }
        }
    }
}

#if DEBUG
    struct ChartsView_Previews: PreviewProvider {
        static var previews: some View {
            ChartsView(store: sampleAppStore)
        }
    }
#endif
