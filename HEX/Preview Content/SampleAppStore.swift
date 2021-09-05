//
//  SampleAppStore.swift
//  SampleAppStore
//
//  Created by Joe Blau on 9/4/21.
//

import ComposableArchitecture
import web3

#if DEBUG

    // MARK: - Profile

    let sampleAppStore = Store(initialState: AppState(),
                               reducer: appReducer,
                               environment: AppEnvironment(client: EthereumClient(url: URL(string: "")!)))
#endif
