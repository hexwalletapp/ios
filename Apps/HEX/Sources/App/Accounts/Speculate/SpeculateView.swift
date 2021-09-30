//
//  SpeculateView.swift
//  HEX
//
//  Created by Joe Blau on 9/29/21.
//

import SwiftUI
import ComposableArchitecture
import HEXREST

struct SpeculateView: View {
    let store: Store<AppState, AppAction>
    
    private enum Field: Hashable {
        case price
    }
    
    @State var price: String = "0.0"
    @FocusState private var focusedField: Field?
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    List {
                        Section("HEX Price") {
                            
                            TextField("HEX Price",
                                      text: $price,
                                      prompt: Text("HEX Price"))
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .price)
                                .submitLabel(.done)
                        }
                        .onSubmit {
                            guard !price.isEmpty else { return }
                            
                            switch  Double(price)  {
                            case let .some(priceDouble):
                                let speculativePrice = NSNumber(value: priceDouble)
                                
                                viewStore.send(.binding(.set(\.$speculativePrice, speculativePrice)))
                                viewStore.send(.binding(.set(\.$shouldSpeculate, true)))
                                viewStore.send(.binding(.set(\.$accountPresent, nil)))
                            case .none:
                                return
                            }
                        }
                    }
                    .navigationTitle("Speculate")
                }
            }
            .onAppear {
                price = viewStore.price.description
                
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
        SpeculateView(store: sampleAppStore)
    }
}
#endif
