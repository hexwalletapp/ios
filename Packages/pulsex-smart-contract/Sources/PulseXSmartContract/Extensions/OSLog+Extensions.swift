// OSLog+Extensions.swift
// Copyright (c) 2022 Joe Blau

import Foundation
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let pulseXSmartContract = OSLog(subsystem: subsystem, category: "pulsex_smart_contract")
}
