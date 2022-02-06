// StakeLeaguesView.swift
// Copyright (c) 2022 Joe Blau

import SwiftUI

struct League: Identifiable {
    var id: String { emoji }
    var emoji: String
    var title: String
    var userCount: Int
}

struct StakeLeaguesView: View {
    let leagues: [League] = [
        League(emoji: "🔱", title: "Prosperous Poseidon", userCount: 0),
        League(emoji: "🐋", title: "Winning Whale", userCount: 13),
        League(emoji: "🦈", title: "Super Shark", userCount: 97),
        League(emoji: "🐬", title: "Dabbing Dolphin", userCount: 906),
        League(emoji: "🦑", title: "Swifty Squid", userCount: 4021),
        League(emoji: "🐢", title: "Tinkering Turtle", userCount: 10920),
        League(emoji: "🦀", title: "Cool Crab", userCount: 20973),
        League(emoji: "🦐", title: "Shy Shrimp", userCount: 25795),
        League(emoji: "🐚", title: "Silent Shell", userCount: 12921),
    ]

    var body: some View {
        VStack {
            ForEach(leagues) { league in
                LazyVGrid(columns: k.LEAGUE_GIRD_3, spacing: k.GRID_SPACING) {
                    Text(league.emoji)
                    Text(league.title)
                    Text("\(league.userCount)").font(.body.monospaced())
                }.foregroundColor(.secondary)
            }
        }
    }
}

// #if DEBUG
// struct StakeLeaguesView_Previews: PreviewProvider {
//    static var previews: some View {
//        StakeLeaguesView()
//    }
// }
// #endif
