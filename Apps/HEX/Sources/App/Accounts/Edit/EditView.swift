// EditView.swift
// Copyright (c) 2021 Joe Blau

import ComposableArchitecture
import HEXSmartContract
import SwiftUI

struct EditView: View {
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
                            ForEach(viewStore.accountsData) { accountData in
                                HStack {
                                    Image(accountData.account.chain.description).resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                    Text(accountData.account.name)
                                    Spacer()
                                    switch viewStore.editMode {
                                    case .inactive:
                                        Text("\(accountData.account.address.prefix(6).description)...\(accountData.account.address.suffix(4).description)")
                                            .font(.caption.monospaced())
                                            .padding([.horizontal], 12)
                                            .padding([.vertical], 6)
                                            .background(Color(.systemGray6))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    default:
                                        EmptyView()
                                    }
                                }
                            }
                            .onDelete(perform: delete)
                            .onMove(perform: move)
                        } header: {
                            Text("Accounts")
                        } footer: {
                            switch viewStore.accountsData.count {
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

                    var existingAccounts = viewStore.accountsData
                    existingAccounts.updateOrAppend(AccountData(account: account))

                    viewStore.send(.binding(.set(\.$accountsData, existingAccounts)))

                    account = Account()
                }
                .navigationTitle("Manage Accounts")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.dismiss)
                        } label: { Image(systemName: "xmark") }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        switch viewStore.editMode {
                        case .inactive:
                            Button {
                                focusedField = .none
                                viewStore.send(.binding(.set(\.$editMode, .active)))

                            } label: { Text("Edit") }
                        default:
                            Button { viewStore.send(.binding(.set(\.$editMode, .inactive))) } label: { Text("Done") }
                        }
                    }
                }
                .environment(\.editMode, viewStore.binding(\.$editMode))
            }
        }
    }

    func delete(at offsets: IndexSet) {
        let viewStore = ViewStore(store)
        var remainingAccounts = viewStore.accountsData
        remainingAccounts.remove(atOffsets: offsets)
        viewStore.send(.binding(.set(\.$accountsData, remainingAccounts)))
    }

    func move(indices: IndexSet, newOffset: Int) {
        let viewStore = ViewStore(store)
        var accountsData = viewStore.accountsData
        accountsData.move(fromOffsets: indices, toOffset: newOffset)
        viewStore.send(.binding(.set(\.$accountsData, accountsData)))
    }
}

#if DEBUG
    struct EditView_Previews: PreviewProvider {
        static var previews: some View {
            EditView(store: sampleAppStore)
        }
    }
#endif