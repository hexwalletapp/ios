//
//  File.swift
//  
//
//  Created by Joe Blau on 2/5/22.
//

import Foundation

public enum TokenPosition: Equatable, Identifiable, Hashable {
    public var id: Self { self }
    
    case zero
    case one
}
