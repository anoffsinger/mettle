//
//  MettleApp.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/27/24.
//

import SwiftUI

@main
struct MettleApp: App {
  @StateObject private var settingsManager = SettingsManager.shared
  
    var body: some Scene {
        WindowGroup {
            HomeView()
            .environmentObject(settingsManager)
        }
    }
}
