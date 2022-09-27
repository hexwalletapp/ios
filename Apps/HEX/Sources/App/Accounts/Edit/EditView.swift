// EditView.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import EVMChain
import HEXSmartContract
import SwiftUI
import web3

struct EditView: View {
    let store: Store<AppState, AppAction>

    private enum Field: Hashable {
        case name, address
    }

    @FocusState private var focusedField: Field?
    @State private var account = Account()

    private var adapterValue: Binding<String> {
        Binding<String>(get: {
//            self.willUpdate()
            self.account.address.value
        }, set: {
            self.account.address = EthereumAddress($0)
//            self.didModify()
        })
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    List {
                        Section("Add Account") {
                            Picker(selection: $account.chain) {
                                ForEach(Chain.allCases) { chain in
                                    HStack {
                                        LinearGradient(gradient: Gradient(colors: chain.gradient),
                                                       startPoint: .bottomLeading,
                                                       endPoint: .topTrailing)
                                            .mask(
                                                chain.image.resizable()
                                                    .scaledToFit()
                                            ).frame(width: 16, height: 16)
                                        Text(chain.description)
                                    }
                                }
                            } label: {
                                Text("Chain")
                            }
                            Toggle("Favorite", isOn: $account.isFavorite)
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                            TextField("Wallet Name",
                                      text: $account.name,
                                      prompt: Text("Wallet Name"))
                                .focused($focusedField, equals: .name)
                                .disableAutocorrection(true)
                                .submitLabel(.next)

                            TextField("Public Key",
                                      text: adapterValue,
                                      prompt: Text("Public Key"))
                                .focused($focusedField, equals: .address)
                                .disableAutocorrection(true)
                                .submitLabel(.done)
                        }

                        Section {
                            ForEach(viewStore.accounts) { account in
                                accountFrom(account: account)
                            }
                            .onDelete(perform: delete)
                            .onMove(perform: move)
                        } header: {
                            Text("Accounts")
                        } footer: {
                            switch viewStore.accounts.count {
                            case 0: Text("No accounts")
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

                    account.address = EthereumAddress(account.address.value.trimmingCharacters(in: .whitespaces).lowercased())
                    account.name = account.name.trimmingCharacters(in: .whitespaces)

                    guard !account.address.value.isEmpty, !account.name.isEmpty else { return }

                    var existingAccounts = viewStore.accounts
                    existingAccounts.updateOrAppend(account)

                    
                    viewStore.send(.binding(.set(\.$accounts, existingAccounts)))

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

    func delete(at indices: IndexSet) {
        let viewStore = ViewStore(store)
        var accounts = viewStore.accounts

        accounts.remove(atOffsets: indices)
        viewStore.send(.binding(.set(\.$accounts, accounts)))
    }

    func move(indices: IndexSet, newOffset: Int) {
        let viewStore = ViewStore(store)
        var accounts = viewStore.accounts

        accounts.move(fromOffsets: indices, toOffset: newOffset)
        viewStore.send(.binding(.set(\.$accounts, accounts)))
    }

    func toggleFavorite(account: Account) {
        let viewStore = ViewStore(store)
        var accounts = viewStore.accounts
        
        var account = account
        account.isFavorite.toggle()
        
        accounts.updateOrAppend(account)
        viewStore.send(.binding(.set(\.$accounts, accounts)))
    }

    func accountFrom(account: Account) -> some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 16) {
                LinearGradient(gradient: Gradient(colors: account.chain.gradient),
                               startPoint: .bottomLeading,
                               endPoint: .topTrailing)
                    .mask(
                        account.chain.image
                            .resizable()
                            .scaledToFit()
                    ).frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(account.name)
                    Text(account.address.shortAddress)
                        .foregroundColor(.secondary)
                        .font(.footnote.monospaced())
                }
                Spacer()
                switch viewStore.editMode {
                case .inactive:
                    Button {
                        viewStore.send(.copy(account.address.value))
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.accentColor)
                    }
                    Button {
                        toggleFavorite(account: account)
                        viewStore.send(.updateFavorites)
                    } label: {
                        Image(systemName: account.isFavorite ? "star.fill" : "star")
                            .foregroundColor(.orange)
                    }
                default:
                    EmptyView()
                }
            }
            .buttonStyle(PlainButtonStyle())
//            .swipeActions {
//                Button {} label: {
//                    Label("Copy", systemImage: "doc.on.doc")
//                }
//                Button(role: .destructive) {
//                    viewStore.send(.delete(accountData))
//                } label: {
//                    Label("Delete", systemImage: "trash")
//                }
//            }
        }
    }
}

#if DEBUG
    struct EditView_Previews: PreviewProvider {
        static var previews: some View {
            EditView(store: sampleAppStore)
        }
    }
#endif
