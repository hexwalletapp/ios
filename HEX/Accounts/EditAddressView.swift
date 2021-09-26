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
    
    private enum Field: Hashable {
        case name, address
    }
    
    @FocusState private var focusedField: Field?
    @State private var account = Account()
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {

                    List {
                        Section("Add Account") {
                                TextField("Wallet Name",
                                          text: $account.name,
                                          prompt: Text("Wallet Name"))
                                    .focused($focusedField, equals: .name)
                                    .submitLabel(.next)
                                
                                TextField("Public Key",
                                          text: $account.address,
                                          prompt: Text("Public Key"))
                                    .focused($focusedField, equals: .address)
                                    .submitLabel(.done)
                        }
                        Section {
                            switch viewStore.accounts {
                            case let .some(acocunts):
                                ForEach(acocunts) { account in
                                    HStack {
                                        Text(account.name)
                                        Spacer()
                                        Text("\(account.address.prefix(6).description)...\(account.address.suffix(4).description)")
                                            .font(.system(.subheadline, design: .monospaced))
                                            .padding([.horizontal], 12)
                                            .padding([.vertical], 6)
                                            .background(Color(.systemGray6))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            case .none:
                                EmptyView()
                            }
                        } header: {
                            Text("Accounts")
                        } footer: {
                            EmptyView()
//                            switch !viewStore.accounts?.isEmpty {
//                            case .some:
//                                Label("No accounts", systemImage: "person")
//                            case .none:
//                                EmptyView()
//                            }
                        }
                    }
                }
                .onSubmit {
                    switch focusedField {
                    case .none: focusedField = .name
                    case .name: focusedField = .address
                    case .address: break
                    }
                    guard !account.address.isEmpty && !account.name.isEmpty else { return }
                    
                    var existingAccounts: Set<Account>
                    switch viewStore.accounts {
                    case let .some(accounts): existingAccounts = Set(accounts)
                    case .none: existingAccounts = Set<Account>()
                    }
                    existingAccounts.insert(account)
                    
                
                    viewStore.send(.binding(.set(\.$accounts, Array(existingAccounts) )))
                
                    account = Account()
                }
                .navigationTitle("Manage Accounts")
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    focusedField = .name
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
