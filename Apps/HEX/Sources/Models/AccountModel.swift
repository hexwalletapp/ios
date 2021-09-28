// AccountModel.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI
import HEXSmartContract

struct Account: Codable, Hashable, Equatable, Identifiable {
    var id: String { address + chain.description }
    var name: String = ""
    var address: String = ""
    var chain: Chain = .ethereum
}

