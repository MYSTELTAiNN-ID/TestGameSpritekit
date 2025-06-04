//
//  PhysicsCategory.swift
//  TestGame
//
//  Created by Syamsuddin Putra Riefli on 08/06/25.
//


struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1 << 0 // 1
    static let ground: UInt32 = 0x1 << 1 // 2
    static let npc: UInt32 = 0x1 << 2 
}
