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
  @State private var kgViewEnabled: Bool
  @Binding var needsRefresh: Bool
  
  // Custom init needed because we are setting kgViewEnabled in a custom way
  public init(liftType: LiftType, specificLifts: [LiftEntry], maxWeightLift: LiftEntry?, kgViewEnabled: Bool, needsRefresh: Binding<Bool>) {
      self.liftType = liftType
      self.specificLifts = specificLifts
      self.maxWeightLift = maxWeightLift
      self._kgViewEnabled = State(initialValue: kgViewEnabled)
      self._needsRefresh = needsRefresh
  }

  var body: some View {
    List {
      Section {
        VStack (alignment: .leading) {
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
          .frame(height: 142)
          .chartXAxis {
            AxisMarks(preset: .aligned, position: .bottom)
          }
          .chartYAxis {
            AxisMarks(preset: .aligned, position: .leading)
          }
        }
      }
      .frame(height: 240)
      Section(
        header:
          Text("All PRs")
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(Color("TextPrimary"))
          .padding(.leading, -20)
          .textCase(.none)
      ) {
        ForEach(sortLiftEntriesByDate(specificLifts), id: \.self) { lift in
          NavigationLink(destination: LiftEntryView(liftEntry: lift, kgViewEnabled: settingsManager.displayInKilograms, needsRefresh: $needsRefresh)) {
            HStack {
              VStack (alignment: .leading) {
                Text("\(lift.date, formatter: itemFormatter)")
                  .font(.system(size: 16, weight: .regular))
                  .foregroundColor(Color("TextPrimary"))
              }
              Spacer()
              VStack {
                Text(kgViewEnabled ? "\(formattedWeight(poundsToKilograms(pounds: lift.weight))) kg" : "\(formattedWeight(lift.weight)) lb")
                  .font(.system(size: 16, weight: .semibold))
                  .foregroundColor(Color("TextPrimary"))
                Text("+0.75%")
                  .font(.system(size: 12, weight: .regular))
                  .foregroundColor(Color("Positive"))
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


