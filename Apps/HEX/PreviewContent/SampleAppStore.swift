// SampleAppStore.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import HEXSmartContract
import GRDB

#if DEBUG

    // MARK: - Profile

    let sampleQueue = DatabaseQueue()

    let sampleAppStore = Store(initialState: AppState(),
                               reducer: appReducer,
                               environment: AppEnvironment(hexManager: .mock(),
                                                           hedronManager: .mock(),
                                                           uniswapManager: .mock(),
                                                           mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                                           dbQueue: sampleQueue
                                                          ))
#endif
