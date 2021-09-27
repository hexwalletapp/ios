// StakeDetailsView.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI

struct StakeDetailsView: View {
    var stake: Stake

    var body: some View {
        List {
            Text(stake.stakeId.description)
            Text(stake.stakedHearts.hex.hexString)
            Text(stake.stakeShares.number.shareString)

            Text(stake.lockedDay.description)
            Text(stake.stakedDays.description)
            Text(stake.unlockedDay.description)

            Text(stake.isAutoStake.description)
        }
        .navigationTitle(stake.stakeId.description)
    }
}

#if DEBUG
    struct StakeDetailsView_Previews: PreviewProvider {
        static var previews: some View {
            StakeDetailsView(stake: sampleStake)
        }
    }
#endif
