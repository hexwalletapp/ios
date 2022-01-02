//
//  IndividualAccountView.swift
//  HEX
//
//  Created by Joe Blau on 1/2/22.
//

import SwiftUI
import EVMChain
import ComposableArchitecture

struct IndividualAccountView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        LazyVStack(pinnedViews: [.sectionHeaders]) {
            Section {
                individualAccountList
            } header: {
                individualAccountHeader
            }
        }
    }
    
    var individualAccountList: some View {
        WithViewStore(store) { viewStore in
            switch (viewStore.accountsData.isEmpty, viewStore.accountsData.filter { !$0.account.isGroup }[id: viewStore.selectedId]) {
            case (false, let .some(accountData)):
                ForEach(accountData.stakes) { stake in
                    StakeDetailsCardView(price: price(on: accountData.account.chain),
                                         stake: stake,
                                         account: accountData.account)
                }
            default:
                EmptyView()
            }
        }
    }

    var individualAccountHeader: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.accountsData.isEmpty {
            case false:
                TabView(selection: viewStore.binding(\.$selectedId).animation()) {
                    ForEach(viewStore.accountsData.filter { !$0.account.isGroup }) { accountData in
                        StakeCardView(price: price(on: accountData.account.chain),
                                      accountData: accountData)
                            .padding([.horizontal, .top])
                            .padding(.bottom, k.CARD_PADDING_BOTTOM)
                            .tag(accountData.id)
                    }
                }
                .frame(height: ((UIScreen.main.bounds.width) / 1.586) + k.CARD_PADDING_BOTTOM + k.CARD_PADDING_DEFAULT)
                .tabViewStyle(PageTabViewStyle())
                .background(LinearGradient(stops: k.ACCOUNT_CARD_BACKGROUND_GRADIENT_STOPS, startPoint: .top, endPoint: .bottom))
            case true:
                VStack {
                    Spacer(minLength: 200)
                    Button {
                        viewStore.send(.binding(.set(\.$modalPresent, .edit)))
                    } label: {
                        VStack(alignment: .center) {
                            Image(systemName: "person.badge.plus").font(.largeTitle)
                            Text("Add").font(.body.monospaced())
                        }
                        .padding()
                    }
                }
            }
        }
    }
    func price(on chain: Chain) -> Double {
        let viewStore = ViewStore(store)
        let chainPrice: Double
        switch chain {
        case .ethereum: chainPrice = viewStore.hexContractOnChain.ethData.price.doubleValue
        case .pulse: chainPrice = viewStore.hexContractOnChain.plsData.price.doubleValue
        }
        return viewStore.shouldSpeculate ? viewStore.speculativePrice.doubleValue : chainPrice
    }
}

//struct IndividualAccountView_Previews: PreviewProvider {
//    static var previews: some View {
//        IndividualAccountView()
//    }
//}
