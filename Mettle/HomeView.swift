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
  @State var needsRefresh = false
  @EnvironmentObject var settingsManager: SettingsManager
  let weight: Double = 200.0 // Example weight
  
  @State private var showErrorAlert = false
  @State private var errorMessage = ""
  
  var body: some View {
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    ZStack {
      
      NavigationView {
        ScrollView {
          LazyVGrid(columns: columns, spacing: 8) {
            
            let filteredLiftEntries = liftEntries.filter { lift in
              searchText.isEmpty || lift.liftType.description.lowercased().contains(searchText.lowercased())
            }
            
            let groupedLiftEntries = Dictionary(grouping: filteredLiftEntries, by: { $0.liftType })
            
            ForEach(groupedLiftEntries.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { liftType in
              
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
                )
                {
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
          
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
              showSettingsModal = true
            }) {
              ZStack {
                Image(systemName: "person.fill")
                  .resizable()
                  .frame(width: 16, height: 16)
                  .foregroundColor(Color("TextPrimary"))
              }
              .frame(width: 32, height: 32)
              .background(Color("Foreground"))
              .cornerRadius(20)
            }
          }
        }
      }
      .alert(isPresented: $showErrorAlert) {
        Alert(
          title: Text("Error"),
          message: Text(errorMessage),
          dismissButton: .default(Text("OK"))
        )
      }
      .accentColor(Color("Action"))
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
          .foregroundColor(Color("Foreground"))
          .cornerRadius(10)
          .overlay(
            RoundedRectangle(cornerRadius: 7)
              .frame(width: 36, height: 24)
              .foregroundColor(Color("Background"))
              .offset(x: configuration.isOn ? 18 : -18)
              .animation(.spring(), value: configuration.isOn)
          )
          .onTapGesture {
            configuration.isOn.toggle()
          }
        HStack (spacing: 0) {
          Text ("Lb")
            .frame(width: 36, height: 24)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color("TextPrimary"))
          
          Text ("Kg")
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

import SwiftUI
import Charts

import SwiftUI
import Charts

import SwiftUI
import Charts

import SwiftUI
import Charts

import SwiftUI
import Charts

struct LiftTileView: View {
    let liftType: LiftType
    let specificLifts: [LiftEntry]
    let maxWeightLift: LiftEntry?
    @EnvironmentObject var settingsManager: SettingsManager

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(liftType.description)
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary"))
                    Spacer()
                }
                HStack {
                    if let maxWeightLift = maxWeightLift {
                        let weightString = maxWeightLift.weight.formattedWeight(displayInKilograms: settingsManager.displayInKilograms)
                        Text(weightString)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("TextPrimary"))
                    } else {
                        Text("0 lbs.")
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("TextPrimary"))
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(0)
            Chart {
                if specificLifts.count == 1 {
                    let singleLift = specificLifts[0]
                    let calendar = Calendar.current
                    let startDate = calendar.date(byAdding: .month, value: -6, to: singleLift.date)!
                    let endDate = calendar.date(byAdding: .month, value: 6, to: singleLift.date)!

                    RuleMark(y: .value("Strength", singleLift.weight))
                        .lineStyle(StrokeStyle(lineWidth: 4))
                        .foregroundStyle(Color(hex: "#F90C6A"))

                    AreaMark(
                        xStart: .value("Date", startDate),
                        xEnd: .value("Date", endDate),
                        y: .value("Strength", singleLift.weight),
                        series: .value("Base", 0)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#F90C6A").opacity(0.5), Color(hex: "#F90C6A").opacity(0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    PointMark(
                        x: .value("Date", singleLift.date),
                        y: .value("Strength", singleLift.weight)
                    )
                    .symbol {
                        Circle().strokeBorder(Color(hex: "#F90C6A"), lineWidth: 4)
                            .background(Circle().fill(Color(.white)))
                            .frame(width: 14, height: 14)
                    }
                } else {
                    ForEach(sortLiftEntriesByDate(specificLifts), id: \.self) { lift in
                        AreaMark(
                            x: .value("Date", lift.date),
                            yStart: .value("Strength", lift.weight),
                            yEnd: .value("Base", 0)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#F90C6A").opacity(0.5), Color(hex: "#F90C6A").opacity(0)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        LineMark(
                            x: .value("Date", lift.date),
                            y: .value("Strength", lift.weight)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 4))
                        .foregroundStyle(Color(hex: "#F90C6A"))

                        PointMark(
                            x: .value("Date", lift.date),
                            y: .value("Strength", lift.weight)
                        )
                        .symbol {
                            Circle().strokeBorder(Color(hex: "#F90C6A"), lineWidth: 4)
                                .background(Circle().fill(Color(.white)))
                                .frame(width: 14, height: 14)
                        }
                    }
                }
            }
            .chartXScale(domain: getChartDomain(for: specificLifts))
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    // hiding marks
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    // hiding marks
                }
            }
        }
        .frame(height: 114)
        .padding(16)
        .background(Color("Foreground"))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .inset(by: 0.25) // Adjust by half of the stroke line width
                .stroke(Color("Border"), lineWidth: 0.5)
        )
    }

    private func getChartDomain(for lifts: [LiftEntry]) -> ClosedRange<Date> {
        if lifts.count == 1 {
            let singleLift = lifts[0]
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .month, value: -6, to: singleLift.date)!
            let endDate = calendar.date(byAdding: .month, value: 6, to: singleLift.date)!
            return startDate...endDate
        } else if let minDate = lifts.min(by: { $0.date < $1.date })?.date, let maxDate = lifts.max(by: { $0.date < $1.date })?.date {
            return minDate...maxDate
        } else {
            // Fallback range if there are no lifts
            let now = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -6, to: now)!
            let endDate = Calendar.current.date(byAdding: .month, value: 6, to: now)!
            return startDate...endDate
        }
    }
}








