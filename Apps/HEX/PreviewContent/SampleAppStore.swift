// SampleAppStore.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import web3

#if DEBUG

    // MARK: - Profile

    let sampleAppStore = Store(initialState: AppState(),
                               reducer: appReducer,
                               environment: AppEnvironment(client: EthereumClient(url: URL(string: "")!),
                                                           mainQueue: DispatchQueue.main.eraseToAnyScheduler()))
#endif
