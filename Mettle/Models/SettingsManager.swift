//
//  SettingsManager.swift
//  Mettle
//
//  Created by Adam Noffsinger on 6/16/24.
//

import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var displayInKilograms: Bool {
        didSet {
            UserDefaults.standard.set(displayInKilograms, forKey: "displayInKilograms")
        }
    }
    
    private init() {
        self.displayInKilograms = UserDefaults.standard.bool(forKey: "displayInKilograms")
    }
}
