//
//  EditAddressView.swift
//  EditAddressView
//
//  Created by Joe Blau on 9/14/21.
//

import SwiftUI
import ComposableArchitecture

struct EditAddressView: View {
    let store: Store<AppState, AppAction>
    @State var username: String = ""

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    TextField("Public Key or ENS Address", text:
                                viewStore.$ethereumAddress)
                }
            }
        }

    }
}

#if DEBUG
struct EditAddressView_Previews: PreviewProvider {
    static var previews: some View {
        EditAddressView(store: sampleAppStore)
    }
}
#endif
