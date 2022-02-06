// TopRoundedCardShape.swift
// Copyright (c) 2022 Joe Blau

import SwiftUI

struct TopRoundedCardShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        let bl = CGPoint(x: rect.minX, y: rect.maxY)

        let tls = CGPoint(x: rect.minX, y: rect.minY + radius)
        let tlc = CGPoint(x: rect.minX + radius, y: rect.minY + radius)

        let trs = CGPoint(x: rect.maxX - radius, y: rect.minY)
        let trc = CGPoint(x: rect.maxX - radius, y: rect.minY + radius)

        path.move(to: br)
        path.addLine(to: bl)

        path.addLine(to: tls)
        path.addRelativeArc(center: tlc, radius: radius,
                            startAngle: Angle.degrees(0), delta: Angle.degrees(270))

        path.addLine(to: trs)
        path.addRelativeArc(center: trc, radius: radius,
                            startAngle: Angle.degrees(270), delta: Angle.degrees(90))

        return path
    }
}
