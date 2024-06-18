//
//  SettingsView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 5/23/24.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var settingsManager: SettingsManager
  var body: some View {
      
      List {
        Toggle("Display in Kilograms", isOn: $settingsManager.displayInKilograms)
          .padding()
      }
    }
}

#Preview {
    SettingsView()
}
