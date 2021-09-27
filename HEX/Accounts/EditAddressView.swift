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
                            Picker("Current Page", selection: $account.chain) {
                                ForEach(Chain.allCases) { page in
                                    Text(page.description)
                                }
                            }
                            .pickerStyle(.segmented)
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
                            ForEach(viewStore.accounts) { account in
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
                            .onDelete(perform: delete)
                        } header: {
                            Text("Accounts")
                        } footer: {
                            switch viewStore.accounts.count {
                            case 0:Label("No accounts", systemImage: "person")
                            default: EmptyView()
                            }
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
                    
                    var existingAccounts = Set(viewStore.accounts)
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
    
    func delete(at offsets: IndexSet) {
        let viewStore = ViewStore(store)
        var remainingAccounts = viewStore.accounts
        remainingAccounts.remove(atOffsets: offsets)
        viewStore.send(.binding(.set(\.$accounts, remainingAccounts)))
    }
}

#if DEBUG
struct EditAddressView_Previews: PreviewProvider {
    static var previews: some View {
        EditAddressView(store: sampleAppStore)
    }
}
#endif
