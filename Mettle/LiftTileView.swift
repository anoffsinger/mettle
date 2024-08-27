//
//  LiftTileView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 8/26/24.
//

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
            // Perform kg conversion if necessary
            let weight = settingsManager.displayInKilograms ? poundsToKilograms(pounds: maxWeightLift.weight) : maxWeightLift.weight
            let weightString = formattedWeight(weight) + (settingsManager.displayInKilograms ? " kg" : " lbs")
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

// Preview for LiftTileView
#Preview {
  LiftTileView(
    liftType: .bench, // Assuming you have a LiftType enum with a .bench case
    specificLifts: [
      LiftEntry(liftType: .bench, date: Date(), weight: 100, note: "First PR"),
      LiftEntry(liftType: .bench, date: Date().addingTimeInterval(-86400), weight: 95, note: "Earlier PR"),
      LiftEntry(liftType: .bench, date: Date().addingTimeInterval(-172800), weight: 90, note: "Old PR")
    ],
    maxWeightLift: LiftEntry(liftType: .bench, date: Date(), weight: 100, note: "Current Max PR")
  )
  .environmentObject(SettingsManager.shared) // Assuming you have a shared SettingsManager object
}

