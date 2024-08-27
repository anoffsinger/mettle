//
//  AddPRView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 5/7/24.
//

import SwiftUI

struct AddPRView: View {
  @Binding var addingPR: Bool
  @Binding var needsRefresh: Bool
  @State private var searchText = ""
  
  var body: some View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var filteredLiftTypes: [LiftType] {
      if searchText.isEmpty {
        return LiftType.allCases
      } else {
        return LiftType.allCases.filter { $0.description.lowercased().contains(searchText.lowercased()) }
      }
    }
    NavigationView {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 8) {
          ForEach(filteredLiftTypes, id: \.self) { liftType in
            NavigationLink(destination: AddWeightView(liftType: liftType, needsRefresh: $needsRefresh, addingPR: $addingPR, kgViewEnabled: SettingsManager.shared.displayInKilograms)) {
              VStack {
                Text(liftType.description)
                  .font(.headline)
                  .foregroundColor(Color("TextPrimary"))
                  .padding()
                  .frame(maxWidth: .infinity, minHeight: 100)
                  .background(Color("Background"))
                  .cornerRadius(10)
              }
            }
          }
        }
        .padding(.horizontal)
      }
      
      .navigationTitle("Add PR")
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search lift types")
    }
    .accentColor(Color("Action"))
  }
}

#Preview {
  AddPRView(addingPR: .constant(false), needsRefresh: .constant(false))
}
