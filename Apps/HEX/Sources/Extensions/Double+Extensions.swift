// Double+Extensions.swift
// Copyright (c) 2021 Joe Blau

import UIKit

extension Double {
    func toRadians() -> Double {
        self * Double.pi / 180
    }

    func toCGFloat() -> CGFloat {
        CGFloat(self)
    }
}
