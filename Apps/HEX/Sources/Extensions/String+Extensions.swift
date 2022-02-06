// String+Extensions.swift
// Copyright (c) 2022 Joe Blau

import Foundation
import web3

extension EthereumAddress {
    var shortAddress: String {
        "\(value.prefix(6).description)...\(value.suffix(4).description)"
    }
}
