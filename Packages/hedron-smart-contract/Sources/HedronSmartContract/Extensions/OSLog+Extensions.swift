// OSLog+Extensions.swift
// Copyright (c) 2022 Joe Blau

import Foundation
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let hedronSmartContract = OSLog(subsystem: subsystem, category: "hedron_smart_contract")
}
