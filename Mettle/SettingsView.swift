//
//  SettingsView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 5/23/24.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var settingsManager: SettingsManager
  @State private var showWelcomeModal = false
  var body: some View {
    
    List {
      Section {
        Toggle("Display in Kilograms", isOn: $settingsManager.displayInKilograms)
          .padding()
      }
      Section {
        Button(action: {
          showWelcomeModal = true
        }) {
          Text("Show Intro Modal")
        }
      }
      
    }
    .sheet(isPresented: $showWelcomeModal) {
      WelcomeView(showWelcomeModal: $showWelcomeModal)
    }
  }
}

#Preview {
  SettingsView()
}
