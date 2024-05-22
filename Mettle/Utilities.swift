//
//  Utilities.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/27/24.
//

import Foundation
import SwiftUI

extension Date {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Adjust the style as needed
        formatter.timeStyle = .none
        return formatter
    }()

    var formatted: String {
        return Date.dateFormatter.string(from: self)
    }
}

extension Double {
    var formattedWeight: String {
        return String(format: "%.1f kg", self) // Adjust format as needed
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}

// Generate a random date within the past year
func randomDateWithinPastYear() -> Date {
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
    let timeInterval = Date().timeIntervalSince(startDate)
    let randomInterval = TimeInterval(arc4random_uniform(UInt32(timeInterval)))
    return startDate.addingTimeInterval(randomInterval)
}

func randomDateWithinLastTwoYears() -> Date {
    let calendar = Calendar.current
    let twoYearsAgo = calendar.date(byAdding: .year, value: -2, to: Date())!
    let timeInterval = Date().timeIntervalSince(twoYearsAgo)
    let randomInterval = TimeInterval(arc4random_uniform(UInt32(timeInterval)))
    return twoYearsAgo.addingTimeInterval(randomInterval)


}

func randomWeight(min: Int, max: Int) -> Double {
    return Double(Int.random(in: min...max))
}

// Global function to sort an array of LiftEntry by date
func sortLiftEntriesByDate(_ lifts: [LiftEntry]) -> [LiftEntry] {
  return lifts.sorted { $0.date > $1.date }
}



func poundsToKilograms(pounds: Double) -> Double {
    return pounds * 0.453592
}

func printUserDefaults() {
    let defaults = UserDefaults.standard
    let dictionary = defaults.dictionaryRepresentation()

    for (key, value) in dictionary {
        print("\(key): \(value)")
    }
}

// Manually create data for each lift type
//let benchEntries: [LiftEntry] = [
//    LiftEntry(liftType: .bench, date: randomDateWithinPastYear(), weight: 225),
//    LiftEntry(liftType: .bench, date: randomDateWithinPastYear(), weight: 240),
//    LiftEntry(liftType: .bench, date: randomDateWithinPastYear(), weight: 260),
//    LiftEntry(liftType: .bench, date: randomDateWithinPastYear(), weight: 280),
//    LiftEntry(liftType: .bench, date: randomDateWithinPastYear(), weight: 300)
//]
//
//let squatEntries: [LiftEntry] = [
//    LiftEntry(liftType: .squat, date: randomDateWithinPastYear(), weight: 300),
//    LiftEntry(liftType: .squat, date: randomDateWithinPastYear(), weight: 320),
//    LiftEntry(liftType: .squat, date: randomDateWithinPastYear(), weight: 340),
//    LiftEntry(liftType: .squat, date: randomDateWithinPastYear(), weight: 360),
//    LiftEntry(liftType: .squat, date: randomDateWithinPastYear(), weight: 380)
//]
//
//let snatchEntries: [LiftEntry] = [
//    LiftEntry(liftType: .snatch, date: randomDateWithinPastYear(), weight: 100),
//    LiftEntry(liftType: .snatch, date: randomDateWithinPastYear(), weight: 110),
//    LiftEntry(liftType: .snatch, date: randomDateWithinPastYear(), weight: 120),
//    LiftEntry(liftType: .snatch, date: randomDateWithinPastYear(), weight: 130),
//    LiftEntry(liftType: .snatch, date: randomDateWithinPastYear(), weight: 140)
//]
//
//let allLiftEntries: [LiftEntry] = benchEntries + squatEntries + snatchEntries

