//
//  SampleAppStore.swift
//  SampleAppStore
//
//  Created by Joe Blau on 9/4/21.
//

import ComposableArchitecture

#if DEBUG

    // MARK: - Profile

    let sampleAppStore = Store(initialState: AppState(),
                               reducer: appReducer,
                               environment: AppEnvironment())
#endif
