// GroupAccountView.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import SwiftUI

struct GroupAccountView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        LazyVStack(pinnedViews: [.sectionHeaders]) {
            Section {
                accountList
            } header: {
                accountHeader
            }
        }
    }

    var accountList: some View {
        EmptyView()
    }

    var accountHeader: some View {
        WithViewStore(store) { viewStore in
            switch (viewStore.accountsData.isEmpty, viewStore.accountsData.filter { $0.account.isFavorite }) {
            case (false, let accountData):
                GroupStakeCardView(groupAccountData: groupAccount(accountData: accountData))
                    .padding([.horizontal, .top])
                    .padding(.bottom, k.CARD_PADDING_BOTTOM)
            default: EmptyView()
            }
        }
    }

    func groupAccount(accountData: IdentifiedArrayOf<AccountData>) -> GroupAccountData {
        GroupAccountData(ethPrice: 0.20, plsPrice: 0.80, accountData: accountData.filter { $0.account.isFavorite })
    }
}

// struct GroupView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupView()
//    }
// }
