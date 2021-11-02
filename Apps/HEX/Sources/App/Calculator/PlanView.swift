//
//  PlanView.swift
//  HEX
//
//  Created by Joe Blau on 11/1/21.
//

import SwiftUI
import ComposableArchitecture

struct PlanView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    Text("Plan!")
                    
                }
                    .navigationBarTitle("Plan", displayMode: .inline)
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Section {
                                Button {
                                    viewStore.send(.binding(.set(\.$modalPresent, .calculator)))
                                } label: { Label("Calculate", image: "calculator.SFSymbol") }
                            }
                        }
                    }
            }
        }
    }
}

//struct PlanView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlanView()
//    }
//}
