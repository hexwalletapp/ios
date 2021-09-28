//
//  StakeTotalModel.swift
//  HEX
//
//  Created by Joe Blau on 9/28/21.
//

import Foundation
import BigInt

struct StakeTotal: Codable, Hashable, Equatable {
    var stakeShares: BigUInt = 0
    var stakedHearts: BigUInt = 0
    var interestHearts: BigUInt = 0
    var interestSevenDayHearts: BigUInt = 0
}
