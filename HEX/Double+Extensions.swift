//
//  Double+Extensions.swift
//  HEX
//
//  Created by Joe Blau on 9/26/21.
//

import UIKit

extension Double {
    func toRadians() -> Double {
        return self * Double.pi / 180
    }
    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}
