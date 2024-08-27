//
//  LiftOverviewView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/29/24.
//

import SwiftUI
import Charts

struct LiftOverviewView: View {
  let liftType: LiftType
  let specificLifts: [LiftEntry]
  let maxWeightLift: LiftEntry?
  
  @EnvironmentObject var settingsManager: SettingsManager
  @State var kgViewEnabled: Bool
  @Binding var needsRefresh: Bool
  @State var addingPR = false
  
  @State private var showErrorAlert = false
  @State private var errorMessage = ""
  
  @State private var sliderValue: Double = 75
  @State private var textFieldValue: String = "75"
  let generator = UIImpactFeedbackGenerator(style: .medium)
  @FocusState private var isTextFieldFocused: Bool
  
  // Custom init needed because we are setting kgViewEnabled in a custom way
  public init(liftType: LiftType, specificLifts: [LiftEntry], maxWeightLift: LiftEntry?, kgViewEnabled: Bool, needsRefresh: Binding<Bool>) {
    self.liftType = liftType
    self.specificLifts = specificLifts
    self.maxWeightLift = maxWeightLift
    self._kgViewEnabled = State(initialValue: kgViewEnabled)
    self._needsRefresh = needsRefresh
  }
  
  var maxWeight: Double {
    maxWeightLift?.weight ?? 0.0
  }
  
  var body: some View {
    List {
      Section(
        header:
          VStack (alignment: .leading, spacing: 24) {
            VStack(alignment: .leading) {
              VStack(alignment: .leading) {
                Text("Current PR")
                  .font(.system(size: 12))
                  .foregroundStyle(Color("TextSecondary"))
                Text(kgViewEnabled ? "\(formattedWeight(poundsToKilograms(pounds: maxWeightLift?.weight ?? 0.0))) kg" : "\(formattedWeight(maxWeightLift?.weight ?? 0.0)) lb")
                  .font(.system(size: 28, weight: .bold, design: .rounded))
                  .foregroundColor(Color("TextPrimary"))
              }
              
              Chart {
                ForEach(sortLiftEntriesByDate(specificLifts), id: \.self) { lift in
                  let adjustedWeight = kgViewEnabled ? poundsToKilograms(pounds: lift.weight) : lift.weight
                  
                  AreaMark(
                    x: .value("Date", lift.date),
                    yStart: .value("Strength", adjustedWeight),
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
                    y: .value("Strength", adjustedWeight)
                  )
                  .lineStyle(StrokeStyle(lineWidth: 4))
                  .foregroundStyle(Color(hex: "#F90C6A"))
                  
                  PointMark(
                    x: .value("Date", lift.date),
                    y: .value("Strength", adjustedWeight)
                  )
                  .symbol {
                    Circle().strokeBorder(Color(hex: "#F90C6A"), lineWidth: 4)
                      .background(Circle().fill(Color(.white)))
                      .frame(width: 14, height: 14)
                  }
                }
              }
              
              .frame(height: 142)
              .chartXAxis {
                AxisMarks(preset: .aligned, position: .bottom)
              }
              .chartYAxis {
                AxisMarks(preset: .aligned, position: .leading)
              }
              Spacer()
                .frame(height: 18)
              ButtonAddPRSubpage(liftType: liftType, addingPR: $addingPR, needsRefresh: $needsRefresh, kgViewEnabled: $kgViewEnabled)
            }
            .padding(16)
            .background(Color("Foreground"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .textCase(.none)
            
            PercentageCalculatorView(maxWeightLift: maxWeight, kgViewEnabled: $kgViewEnabled)
              .padding(16)
              .background(Color("Foreground"))
              .clipShape(RoundedRectangle(cornerRadius: 16))
              .textCase(.none)
            
            
            Text("All PRs")
              .font(.system(size: 20, weight: .semibold))
              .foregroundStyle(Color("TextPrimary"))
              .textCase(.none)
            
              .padding(.bottom, 8)
            
            
            
          }
          .frame(maxWidth: .infinity)
          .listRowInsets(EdgeInsets())
        
      ) {
        ForEach(sortLiftEntriesByDate(specificLifts).indices, id: \.self) { index in
            let lift = sortLiftEntriesByDate(specificLifts)[index]
            let nextLift: LiftEntry? = index + 1 < sortLiftEntriesByDate(specificLifts).count ? sortLiftEntriesByDate(specificLifts)[index + 1] : nil

            NavigationLink(destination: LiftEntryView(liftEntry: lift, kgViewEnabled: settingsManager.displayInKilograms, needsRefresh: $needsRefresh)) {
                HStack {
                    HStack(spacing: 4) {
                        Text("\(lift.date, formatter: itemFormatter)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color("TextPrimary"))

                        if lift.note != nil && !lift.note!.isEmpty {
                            Image(systemName: "doc.text")
                                .foregroundColor(Color("TextSecondary"))
                                .font(.system(size: 16, weight: .regular))
                        }
                    }
                    Spacer()
                  VStack (alignment: .trailing) {
                        // Convert the weight based on kgViewEnabled
                        let displayedWeight = kgViewEnabled ? poundsToKilograms(pounds: lift.weight) : lift.weight
                        Text("\(formattedWeight(displayedWeight)) \(kgViewEnabled ? "kg" : "lb")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("TextPrimary"))

                        if let nextLift = nextLift {
                            let percentageChange = ((lift.weight - nextLift.weight) / nextLift.weight) * 100
                            Text("\(percentageChange >= 0 ? "+" : "")\(String(format: "%.2f", percentageChange))%")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(percentageChange >= 0 ? Color("Positive") : Color("Negative"))
                        }
                    }
                }
                .frame(height: 40)
            }
        }

        .onDelete(perform: deleteLiftEntries)
      }
    }
    .navigationTitle(liftType.description)
    .navigationBarTitleDisplayMode(.large)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Toggle(isOn: $kgViewEnabled) {
          Text("")
        }
        .toggleStyle(CustomToggleStyle())
      }
    }
    .onAppear {
      kgViewEnabled = settingsManager.displayInKilograms // initialize the unit setting
    }
    .onChange(of: needsRefresh) { newValue in
      if newValue {
        // Fetch or refresh data as needed
        needsRefresh = false
      }
    }
    .alert(isPresented: $showErrorAlert) {
      Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
    }
  }
  
  private func deleteLiftEntries(at offsets: IndexSet) {
    offsets.forEach { index in
      let liftEntry = specificLifts[index]
      CloudKitManager.shared.deleteLiftEntry(liftEntry) { result in
        DispatchQueue.main.async {
          switch result {
          case .success:
            needsRefresh = true
          case .failure(let error):
            showErrorAlert = true
            errorMessage = "Error deleting lift entry: \(error.localizedDescription)"
            print("Error deleting lift entry: \(error)")
          }
        }
      }
    }
  }
}


#Preview {
  LiftOverviewView(
    liftType: .bench,
    specificLifts: testLifts,
    maxWeightLift: LiftEntry(
      liftType: .backSquat,
      date: dates[2],
      weight: weights[2],
      note: "A nice note"),
    kgViewEnabled: SettingsManager.shared.displayInKilograms,
    needsRefresh: .constant(false)
  )
  .environmentObject(SettingsManager.shared)
}

let calendar = Calendar.current
let today = Date()
let lastYear = calendar.date(byAdding: .year, value: -1, to: today)!
let weights: [Double] = [210.0, 220.0, 230.0, 240.0, 250.0, 260.0, 270.0, 280.0, 290.0]
let dates = (0..<weights.count).map { index in
  calendar.date(byAdding: .day, value: index * (365 / weights.count), to: lastYear)!
}

let testLifts: [LiftEntry] = [
  LiftEntry(liftType: .backSquat, date: dates[0], weight: weights[0], note: "A nice note"),
  LiftEntry(liftType: .backSquat, date: dates[1], weight: weights[1], note: "A nice note"),
  LiftEntry(liftType: .backSquat, date: dates[2], weight: weights[2], note: "A nice note"),
]

struct ButtonAddPRSubpage: View {
  let liftType: LiftType
  @Binding var addingPR: Bool
  @Binding var needsRefresh: Bool
  @Binding var kgViewEnabled: Bool
  
  var body: some View {
    Button(action: {
      addingPR = true
    }) {
      Text("Add New PR")
        .font(.system(size: 17, weight: .bold))
        .foregroundColor(Color.white)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(
          LinearGradient(
            gradient: Gradient(colors: [Color(hex: "F91F60"), Color(hex: "EC1B80")]),
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .cornerRadius(14)
    }
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .inset(by: 1) // Adjust by half of the stroke line width
        .stroke(Color("ButtonBorder"), lineWidth: 2)
    )
    .sheet(isPresented: $addingPR) {
      NavigationView {
        AddWeightView(
          liftType: liftType,
          needsRefresh: $needsRefresh,
          addingPR: $addingPR,
          kgViewEnabled: kgViewEnabled
        )
      }
      .accentColor(Color("Action"))
    }
  }
}

