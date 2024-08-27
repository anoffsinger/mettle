//
//  HomeView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/27/24.
//

import SwiftUI
import Charts

struct ChartData: Identifiable {
  let id: UUID
  let liftType: LiftType
  let date: Date
  let weight: Double
}

struct HomeView: View {
  @State private var liftEntries: [LiftEntry] = []
  @State private var searchText = ""
  @State private var showSettingsModal = false
  @State var addingPR = false
  @State var viewingOverview = false
  @State var needsRefresh = false
  @EnvironmentObject var settingsManager: SettingsManager
  let weight: Double = 200.0 // Example weight
  
  @State private var showErrorAlert = false
  @State private var errorMessage = ""
  
  var body: some View {
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    
    
    NavigationView {
      ZStack {
        ScrollView {
          LazyVGrid(columns: columns, spacing: 8) {
            
            let filteredLiftEntries = liftEntries.filter { lift in
              searchText.isEmpty || lift.liftType.description.lowercased().contains(searchText.lowercased())
            }
            
            let groupedLiftEntries = Dictionary(grouping: filteredLiftEntries, by: { $0.liftType })
            
            ForEach(
              groupedLiftEntries.keys.sorted(by: {
                let date1 = groupedLiftEntries[$0]?.max(by: { $0.date < $1.date })?.date ?? Date.distantPast
                let date2 = groupedLiftEntries[$1]?.max(by: { $0.date < $1.date })?.date ?? Date.distantPast
                return date1 > date2
              }), id: \.self
            ) { liftType in
              if let specificLifts = groupedLiftEntries[liftType] {
                let maxWeightLift = specificLifts.max(by: { $0.weight < $1.weight })
                
                NavigationLink(
                  destination: LiftOverviewView(
                    liftType: liftType,
                    specificLifts: specificLifts,
                    maxWeightLift: maxWeightLift,
                    kgViewEnabled: settingsManager.displayInKilograms,
                    needsRefresh: $needsRefresh
                  )
                ) {
                  LiftTileView(liftType: liftType, specificLifts: specificLifts, maxWeightLift: maxWeightLift)
                }
              }
            }
          }
          .padding(.horizontal)
          Spacer()
            .frame(height: 88)
        }
        .background(Color("Background"))
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search your lifts")
        .toolbar {
          ToolbarItem(placement: .principal) {
            ZStack(alignment: .center) {
              Image("Logo Header")
                .resizable()
                .frame(width: 32, height: 32)
                .offset(x: 2.5, y: -1)
              
              
            }
            .padding(0)
            .frame(width: 32, height: 32, alignment: .center)
            .background(
              LinearGradient(
                stops: [
                  Gradient.Stop(color: Color(red: 1, green: 0.04, blue: 0.41), location: 0.00),
                  Gradient.Stop(color: Color(red: 0.84, green: 0.08, blue: 0.44), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
              )
            )
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 2.5, x: 0, y: 2)
          }
          
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
              showSettingsModal = true
            }) {
              Image(systemName: "gearshape.fill")
                .font(.system(size: 17))
              
                .foregroundColor(Color("TextPrimary"))
              
            }
          }
        }
        
        VStack {
          Spacer()
          VStack(spacing: 0) {
            Divider()
            //            .frame(height: 0.5)
            
            Spacer()
              .frame(height: 16)
            VStack {
              ButtonAddPR(addingPR: $addingPR, needsRefresh: $needsRefresh)
            }
            .padding(.horizontal, 16)
          }
          .frame(maxWidth: .infinity)
          .background(Color("Background"))
        }
      }
      .navigationBarTitleDisplayMode(.inline)
    }
    
    
    .alert(isPresented: $showErrorAlert) {
      Alert(
        title: Text("Error"),
        message: Text(errorMessage),
        dismissButton: .default(Text("OK"))
      )
    }
    .accentColor(Color("Action"))
    
    .sheet(isPresented: $showSettingsModal) {
      // Replace with your modal view
      SettingsView()
    }
    .onAppear {
      fetchLiftEntries()
    }
    .onChange(of: needsRefresh) { newValue in
      if newValue == true {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          fetchLiftEntries()
          needsRefresh = false
        }
      }
    }
  }
  
  private func fetchLiftEntries() {
    CloudKitManager.shared.fetchLiftEntries { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let entries):
          self.liftEntries = entries
          print("lift entries fetched")
          print(entries)
          
        case .failure(let error):
          self.errorMessage = error.localizedDescription
          self.showErrorAlert = true
          print("Error fetching entries: \(error)")
        }
      }
    }
  }
  
  private func sortLiftEntriesByDate(_ lifts: [LiftEntry]) -> [LiftEntry] {
    lifts.sorted { $0.date < $1.date }
  }
}

#Preview {
  HomeView()
    .environmentObject(SettingsManager.shared)
}

struct CustomToggleStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.label
      Spacer()
      ZStack {
        Rectangle() // Custom switch background
          .frame(width: 80, height: 32)
          .foregroundColor(Color("ToggleBackground"))
          .cornerRadius(10)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color(.white).opacity(0.5), lineWidth: 0.07)
          )
          .overlay(
            RoundedRectangle(cornerRadius: 7)
              .frame(width: 36, height: 24)
              .foregroundColor(Color("ToggleForeground"))
              .offset(x: configuration.isOn ? 18 : -18)
              .animation(.spring(), value: configuration.isOn)
              .overlay(
                RoundedRectangle(cornerRadius: 7)
                  .stroke(Color(.white).opacity(0.5), lineWidth: 0.07)
                  .offset(x: configuration.isOn ? 18 : -18)
                  .animation(.spring(), value: configuration.isOn)
              )
          )
          .onTapGesture {
            configuration.isOn.toggle()
          }
        HStack(spacing: 0) {
          Text("Lb")
            .frame(width: 36, height: 24)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color("TextPrimary"))
          
          Text("Kg")
            .frame(width: 36, height: 24)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color("TextPrimary"))
        }
        .padding(.horizontal, 4)
      }
    }
  }
}



struct ButtonAddPR: View {
  @Binding var addingPR: Bool
  @Binding var needsRefresh: Bool
  
  var body: some View {
    Button(action: {
      addingPR = true
    }) {
      Text("Add New PR")
        .font(.system(size: 17, weight: .bold))
        .foregroundColor(Color.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
          LinearGradient(
            gradient: Gradient(colors: [Color(hex: "F91F60"), Color(hex: "EC1B80")]),
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .cornerRadius(20)
    }
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .inset(by: 1) // Adjust by half of the stroke line width
        .stroke(Color("ButtonBorder"), lineWidth: 2)
    )
    .sheet(isPresented: $addingPR) {
      AddPRView(addingPR: $addingPR, needsRefresh: $needsRefresh)
    }
  }
}








