//
//  PhysicsCategory.swift
//  Plinkonnect4
//
//  Created by Sarju Thakkar on 4/21/25.
//


import Foundation

struct PhysicsCategory {
    static let none: UInt32  = 0
    static let ball: UInt32  = 0x1 << 0
    static let peg: UInt32   = 0x1 << 1
    static let slot: UInt32  = 0x1 << 2
}
