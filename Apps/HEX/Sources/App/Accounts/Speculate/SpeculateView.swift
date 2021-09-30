// SpeculateView.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import HEXREST
import SwiftUI

struct SpeculateView: View {
    let store: Store<AppState, AppAction>
    
    private enum Field: Hashable {
        case price
    }
    
    @State var price: String
    @FocusState private var focusedField: Field?
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    Section("HEX Price") {
                        TextField("HEX Price",
                                  text: $price,
                                  prompt: Text("HEX Price"))
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .price)
                    }
                    
                    Section {
                        Button {
                            guard !price.isEmpty else { return }
                            
                            switch Double(price) {
                            case let .some(priceDouble):
                                let speculativePrice = NSNumber(value: priceDouble)
                                
                                focusedField = nil
                                viewStore.send(.binding(.set(\.$speculativePrice, speculativePrice)))
                                viewStore.send(.binding(.set(\.$shouldSpeculate, true)))
                                viewStore.send(.dismiss)
                            case .none:
                                return
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Speculate")
                                Spacer()
                            }
                        }
                    }
                }
                .navigationTitle("Speculate")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            focusedField = nil
                            viewStore.send(.dismiss)
                        } label: { Image(systemName: "xmark") }
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    focusedField = .price
                }
            }
        }
    }
}

#if DEBUG
struct SpeculateView_Previews: PreviewProvider {
    static var previews: some View {
        SpeculateView(store: sampleAppStore, price: "1.00")
    }
}
#endif
