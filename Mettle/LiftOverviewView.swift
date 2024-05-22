//
//  LiftOverviewView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/29/24.
//

import SwiftUI
import Charts

let calendar = Calendar.current
let today = Date()
let lastYear = calendar.date(byAdding: .year, value: -1, to: today)!

let weights: [Double] = [210.0, 220.0, 230.0, 240.0, 250.0, 260.0, 270.0, 280.0, 290.0]

let dates = (0..<weights.count).map { index in
    calendar.date(byAdding: .day, value: index * (365 / weights.count), to: lastYear)!
}


struct LiftOverviewView: View {

  let lifts: [LiftEntry] = [
      LiftEntry(liftType: .backSquat, date: dates[0], weight: weights[0]),
      LiftEntry(liftType: .backSquat, date: dates[1], weight: weights[1]),
      LiftEntry(liftType: .backSquat, date: dates[2], weight: weights[2]),
      LiftEntry(liftType: .backSquat, date: dates[3], weight: weights[3]),
      LiftEntry(liftType: .backSquat, date: dates[4], weight: weights[4]),
      LiftEntry(liftType: .backSquat, date: dates[5], weight: weights[5]),
      LiftEntry(liftType: .backSquat, date: dates[6], weight: weights[6]),
      LiftEntry(liftType: .backSquat, date: dates[7], weight: weights[7]),
      LiftEntry(liftType: .backSquat, date: dates[8], weight: weights[8])
  ]


  let liftType: LiftType
  @State private var kgViewEnabled: Bool = false
  let currentPR: Double = 232.00

  var body: some View {
    List {
      Section {
        VStack (alignment: .leading) {
          VStack(alignment: .leading) {
            Text("Current PR")
              .font(.system(size: 12))
              .foregroundStyle(Color("Secondary"))
            Text(kgViewEnabled ? "\(formattedWeight(poundsToKilograms(pounds: currentPR))) kg" : "\(formattedWeight(currentPR)) lb")
              .font(.system(size: 28, weight: .bold, design: .rounded))
              .foregroundColor(Color("Primary"))
          }

          Chart {
            ForEach(sortLiftEntriesByDate(lifts), id: \.self) { lift in
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
          .foregroundStyle(Color("Primary"))
          .padding(.leading, -20)
          .textCase(.none)
      ) {
        ForEach(sortLiftEntriesByDate(lifts), id: \.self) { lift in
          NavigationLink(destination: LiftEntryView(liftEntry: lift)) {
            HStack {
              VStack (alignment: .leading) {

                Text("\(lift.date, formatter: itemFormatter)")
                  .font(.system(size: 16, weight: .regular))
                  .foregroundColor(Color("Primary"))
              }
              Spacer()
              VStack {
                Text(kgViewEnabled ? "\(formattedWeight(poundsToKilograms(pounds: lift.weight))) kg" : "\(formattedWeight(lift.weight)) lb")
                  .font(.system(size: 16, weight: .semibold))
                  .foregroundColor(Color("Primary"))
                Text("+0.75%")
                  .font(.system(size: 12, weight: .regular))
                  .foregroundColor(Color("Positive"))
              }
            }
            .frame(height: 40)
          }
        }
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
  }

}

#Preview {
  LiftOverviewView(liftType: .bench)
}

func formattedWeight(_ weight: Double) -> String {
    let formattedString = String(format: "%.2f", weight)
    if formattedString.hasSuffix(".00") {
      return String(format: "%.0f", weight)
    } else {
      return formattedString
    }
  }

// Global date formatter
let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
  formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()
