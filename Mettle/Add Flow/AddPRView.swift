//
//  AddPRView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 5/7/24.
//

import SwiftUI

struct AddPRView: View {
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
              NavigationLink(destination: AddWeightView(liftType: liftType, needsRefresh: $needsRefresh)) {
              VStack {
                Text(liftType.description)
                  .font(.headline)
                  .foregroundColor(.black)
                  .padding()
                  .frame(maxWidth: .infinity, minHeight: 100)
                  .background(Color(hex: "f2f2f2"))
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
  }

  // Dismiss the modal
//  @Environment(\.dismiss) var dismiss
}

#Preview {
    AddPRView(needsRefresh: .constant(false))
}

struct Tile: Identifiable {
  let id = UUID()
  let title: String
  let color: Color
}

struct TileDetailView: View {
  let tile: Tile

  var body: some View {
    VStack {
      Text("Detail View")
        .font(.largeTitle)
        .padding()

      Text(tile.title)
        .font(.title)
        .padding()
        .foregroundColor(tile.color)
        .background(tile.color.opacity(0.1))
        .cornerRadius(10)
    }
  }
}
