// EditAddressView.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import SwiftUI

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
                            Picker(selection: $account.chain) {
                                ForEach(Chain.allCases) { page in
                                    Text(page.description)
                                }
                            } label: {
                                Text("Chain")
                            }
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
                                    Image(account.chain.description).resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                    Text(account.name)
                                    Spacer()
                                    Text("\(account.address.prefix(6).description)...\(account.address.suffix(4).description)")
                                        .font(.system(.caption, design: .monospaced))
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
                            case 0: Label("No accounts", systemImage: "person")
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

                    account.address = account.address.trimmingCharacters(in: .whitespaces).lowercased()
                    account.name = account.name.trimmingCharacters(in: .whitespaces)

                    guard !account.address.isEmpty, !account.name.isEmpty else { return }

                    var existingAccounts = viewStore.accounts
                    existingAccounts.updateOrAppend(account)

                    viewStore.send(.binding(.set(\.$accounts, existingAccounts)))

                    account = Account()
                }
                .navigationTitle("Manage Accounts")
                .toolbar {
//                    ToolbarItemGroup(placement: .navigationBarLeading) {
//                        Button {
//                            viewStore.send(.binding(.set(\.$presentEditAddress, false)))
//                        } label: { Image(systemName: "xmark") }
//                    }
                }
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
