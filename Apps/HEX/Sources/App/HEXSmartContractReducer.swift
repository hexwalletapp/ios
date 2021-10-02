// HEXSmartContractReducer.swift
// Copyright (c) 2021 Joe Blau

import BigInt
import ComposableArchitecture
import Dispatch
import HEXSmartContract

let hexReducer = Reducer<AppState, HEXSmartContractManager.Action, AppEnvironment> { state, action, environment in
    switch action {
    case let .stakeList(stakeList, address, chain):
        let accountDataKey = address.value + chain.description
        var totalStakeShares: BigUInt = 0
        var totalStakedHearts: BigUInt = 0
        let currentDay = Int(state.currentDay)

        let stakes = stakeList.sorted(by: {
            let firstStake = [BigUInt($0.lockedDay + $0.stakedDays), $0.stakeId]
            let secondStake = [BigUInt($1.lockedDay + $1.stakedDays), $1.stakeId]
            return firstStake.lexicographicallyPrecedes(secondStake)
        })
            .map { stake -> Stake in
                let stakeUnlockDay = Int(stake.unlockedDay)
                let stakeLockedDay = Int(stake.lockedDay)
                let stakeLength = stakeLockedDay + Int(stake.stakedDays)
                let gracePeriod = stakeLength + k.GRACE_PERIOD
                let daysRemaining = stakeLength - currentDay

                let status: StakeStatus
                // Calculate Status
                if stake.unlockedDay > 0, stake.unlockedDay < stake.lockedDay + stake.stakedDays {
                    status = .emergencyEnd
                } else if stake.unlockedDay > 0, stakeLength ..< currentDay ~= stakeUnlockDay {
                    status = .goodAccounting
                } else if stake.unlockedDay == 0, stakeLength ..< gracePeriod ~= stakeUnlockDay {
                    status = .gracePeriod
                } else if stake.unlockedDay == 0, currentDay > gracePeriod {
                    status = .bleeding
                } else {
                    status = .active
                    totalStakeShares += stake.stakeShares
                    totalStakedHearts += stake.stakedHearts
                }

                return Stake(stakeId: stake.stakeId,
                             stakedHearts: stake.stakedHearts,
                             stakeShares: stake.stakeShares,
                             lockedDay: stake.lockedDay,
                             stakedDays: stake.stakedDays,
                             unlockedDay: stake.unlockedDay,
                             isAutoStake: stake.isAutoStake,
                             percentComplete: min(1, (Double(currentDay) - Double(stake.lockedDay)) / Double(stake.stakedDays)),
                             daysRemaining: daysRemaining,
                             status: status,
                             startDate: k.HEX_START_DATE.addingTimeInterval(TimeInterval(stakeLockedDay * 86400)),
                             endDate: k.HEX_START_DATE.addingTimeInterval(TimeInterval(stakeLength * 86400)),
                             interestHearts: 0,
                             bigPayDayHearts: nil)
            }
        state.accountsData[id: accountDataKey]?.stakes = IdentifiedArray(uniqueElements: stakes)
        state.accountsData[id: accountDataKey]?.total.stakeShares = totalStakeShares
        state.accountsData[id: accountDataKey]?.total.stakedHearts = totalStakedHearts

        return environment.hexManager
            .getDailyDataRange(id: HexManagerId(),
                               address: address,
                               chain: chain,
                               begin: 0,
                               end: UInt16(state.currentDay))
            .fireAndForget()

    case let .dailyData(dailyDataEncoded, address, chain):
        let accountDataKey = address.value + chain.description
        let unclaimedSatoshisTotal = state.globalInfo.unclaimedSatoshisTotal
        let claimedBtcAddrCount = state.globalInfo.claimedBtcAddrCount
        let claimedSatoshisTotal = state.globalInfo.claimedSatoshisTotal

        var totalInterestHearts: BigUInt = 0
        var totalInterestSevenDayHearts: BigUInt = 0
        var bigPayDayTotalHearts: BigUInt = 0
        var currentDay = state.currentDay

        let dailyData = dailyDataEncoded.map { dailyData -> DailyData in
            var dailyData = dailyData
            let payout = dailyData & k.HEARTS_MASK
            dailyData >>= k.HEARTS_UINT_SHIFT
            let shares = dailyData & k.HEARTS_MASK
            dailyData >>= k.HEARTS_UINT_SHIFT
            let sats = dailyData & k.SATS_MASK

            return DailyData(payout: payout, shares: shares, sats: sats)
        }

        state.accountsData[id: accountDataKey]?
            .stakes
            .forEach { stake in
                let startIndex = Int(stake.lockedDay)
                let endIndex = min(startIndex + Int(stake.stakedDays), Int(state.currentDay))
                let weekStartIndex = max(endIndex - 7, startIndex)

                let interestHearts = dailyData[startIndex ..< endIndex].reduce(0) { $0 + ((stake.stakeShares * $1.payout) / $1.shares) }
                let interestSevenDayHearts = dailyData[weekStartIndex ..< endIndex].reduce(0) { $0 + ((stake.stakeShares * $1.payout) / $1.shares) }

                totalInterestHearts += interestHearts
                totalInterestSevenDayHearts += interestSevenDayHearts

                // Big Pay Day
                if startIndex ..< endIndex ~= Int(k.BIG_PAY_DAY) {
                    let stakeSharesTotal = dailyData[Int(k.BIG_PAY_DAY)].shares

                    let bigPaySlice = unclaimedSatoshisTotal * k.HEARTS_PER_SATOSHI * stake.stakeShares / stakeSharesTotal

                    let viralRewards = bigPaySlice * claimedBtcAddrCount / k.CLAIMABLE_BTC_ADDR_COUNT
                    let criticalMass = bigPaySlice * claimedSatoshisTotal / k.CLAIMABLE_SATOSHIS_TOTAL

                    let adoptionBonus = viralRewards + criticalMass

                    let bigPayDayHearts = bigPaySlice + adoptionBonus
                    state.accountsData[id: accountDataKey]?.stakes[id: stake.id]?.bigPayDayHearts = bigPayDayHearts

                    bigPayDayTotalHearts += bigPayDayHearts
                }

                state.accountsData[id: accountDataKey]?.stakes[id: stake.id]?.interestHearts = interestHearts
            }

        state.accountsData[id: accountDataKey]?.total.interestHearts = totalInterestHearts
        state.accountsData[id: accountDataKey]?.total.interestSevenDayHearts = (totalInterestSevenDayHearts / BigUInt(7))
        state.accountsData[id: accountDataKey]?.total.bigPayDayHearts = bigPayDayTotalHearts

        return .none

    case let .currentDay(day):
        state.currentDay = day
        return .merge(
            state.accountsData.compactMap { accountData -> Effect<HEXSmartContractManager.Action, Never>? in
                environment.hexManager.getStakes(id: HexManagerId(),
                                                 address: accountData.account.address,
                                                 chain: accountData.account.chain).fireAndForget()
            }
        )

    case let .globalInfo(globalInfo):
        state.globalInfo = GlobalInfo(globalInfo: globalInfo)
        return .none
    }
}
