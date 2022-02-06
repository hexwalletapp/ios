// TokenPosition.swift
// Copyright (c) 2022 Joe Blau

import Foundation

public enum TokenPosition: Equatable, Identifiable, Hashable {
    public var id: Self { self }

    case zero
    case one
}
