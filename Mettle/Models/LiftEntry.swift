//
//  LiftEntry.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/27/24.
//

import Foundation

struct LiftEntry: Codable, Identifiable, Hashable {
    let id = UUID()
    let liftType: LiftType
    let date: Date
    let weight: Double
    let note: String?
}
