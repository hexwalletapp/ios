// ChartsView.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import SwiftUI

struct ChartsView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    LightweightChartsView(timeScale: viewStore.selectedTimeScale,
                                          chartType: viewStore.selectedChartType,
                                          ohlcv: viewStore.ohlcv)
                }
                .background(Color(.systemGroupedBackground))
                .navigationBarTitle("HEX/USDC", displayMode: .inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        switch viewStore.chartLoading {
                        case true: ProgressView()
                        case false: EmptyView()
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
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
