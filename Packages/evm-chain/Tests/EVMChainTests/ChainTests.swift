// ChainTests.swift
// Copyright (c) 2022 Joe Blau

import XCTest
@testable import EVMChain

final class ChainTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(evm_chain().text, "Hello, World!")
    }
}
