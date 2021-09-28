// SampleAppStore.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import HEXSmartContract

#if DEBUG

    // MARK: - Profile

    let sampleAppStore = Store(initialState: AppState(),
                               reducer: appReducer,
                               environment: AppEnvironment(hexManager: .mock(),
                                                           mainQueue: DispatchQueue.main.eraseToAnyScheduler()))
#endif
