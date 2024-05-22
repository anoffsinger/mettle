//
//  AppState.swift
//  Mettle
//
//  Created by Adam Noffsinger on 5/19/24.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false

    init() {
        // Check if the user is already authenticated
        if let _ = UserDefaults.standard.string(forKey: "userIdentifier") {
            self.isAuthenticated = true
        }
    }
}
