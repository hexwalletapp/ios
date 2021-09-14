//
//  ContentView.swift
//  HEX
//
//  Created by Joe Blau on 9/4/21.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(keyPath: \.selectedTab, send: AppAction.form)) {
                ChartsView()
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("Charts")
                    }
                    .tag(Tab.charts)
                
                StakesView(store: store)
                    .tabItem {
                        Image(systemName: "banknote.fill")
                        Text("Stakes")
                    }
                    .tag(Tab.stakes)

//                CalculatorView()
//                    .tabItem {
//                        Image(systemName: "plus.app.fill")
//                        Text("Calculator")
//                    }
//                    .tag(Tab.calculator)
            }
        }
    }
}

#if DEBUG

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: sampleAppStore)
    }
}

#endif
