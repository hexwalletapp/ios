// OSLog+Extensions.swift
// Copyright (c) 2022 Joe Blau

import Foundation
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let uniswapSmartContract = OSLog(subsystem: subsystem, category: "uniswap_smart_contract")
}
