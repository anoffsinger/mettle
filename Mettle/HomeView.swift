//
//  ContentView.swift
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
    @State private var addingPR = false
    @State private var needsRefresh: Bool = false
    
    //  let specificLifts: [LiftEntry] = [
    //    LiftEntry(liftType: .backSquat, date: dates[0], weight: weights[0], note: "A nice note"),
    //    LiftEntry(liftType: .backSquat, date: dates[1], weight: weights[1], note: nil),
    //    LiftEntry(liftType: .backSquat, date: dates[2], weight: weights[2], note: "A nice note"),
    //    LiftEntry(liftType: .backSquat, date: dates[3], weight: weights[3], note: "A nice note"),
    //    LiftEntry(liftType: .backSquat, date: dates[4], weight: weights[4], note: "A nice note"),
    //    LiftEntry(liftType: .backSquat, date: dates[5], weight: weights[5], note: "A nice note"),
    //    LiftEntry(liftType: .backSquat, date: dates[6], weight: weights[6], note: "A nice note"),
    //    LiftEntry(liftType: .backSquat, date: dates[7], weight: weights[7], note: "A nice note"),
    //    LiftEntry(liftType: .backSquat, date: dates[8], weight: weights[8], note: "A nice note")
    //  ]
    //
    //  let allLifts: [LiftEntry] = [
    //    LiftEntry(
    //      liftType: .backSquat,
    //      date: randomDateWithinLastTwoYears(),
    //      weight: randomWeight(min: 225, max: 275), note: "A nice note"
    //    ),
    //    LiftEntry(
    //      liftType: .backSquat,
    //      date: randomDateWithinLastTwoYears(),
    //      weight: randomWeight(min: 225, max: 275), note: "A nice note"
    //    ),
    //    LiftEntry(
    //      liftType: .backSquat,
    //      date: randomDateWithinLastTwoYears(),
    //      weight: randomWeight(min: 225, max: 275), note: "A nice note"
    //    ),
    //    LiftEntry(
    //      liftType: .frontSquat,
    //      date: randomDateWithinLastTwoYears(),
    //      weight: randomWeight(min: 185, max: 270), note: "A nice note"
    //    ),
    //    LiftEntry(
    //      liftType: .frontSquat,
    //      date: randomDateWithinLastTwoYears(),
    //      weight: randomWeight(min: 185, max: 270), note: "A nice note"
    //    ),
    //    LiftEntry(
    //      liftType: .frontSquat,
    //      date: randomDateWithinLastTwoYears(),
    //      weight: randomWeight(min: 185, max: 270), note: "A nice note"
    //    ),
    //    LiftEntry(
    //      liftType: .deadlift,
    //      date: randomDateWithinLastTwoYears(),
    //      weight: randomWeight(min: 225, max: 310), note: "A nice note"
    //    ),
    //    LiftEntry(
    //      liftType: .deadlift,
    //      date: randomDateWithinLastTwoYears(),
    //      weight: randomWeight(min: 225, max: 310), note: "A nice note"
    //    ),
    //    LiftEntry(
    //      liftType: .deadlift,
    //      date: randomDateWithinLastTwoYears(),
    //      weight: randomWeight(min: 225, max: 310), note: "A nice note")
    //  ]
    
    
    
    //  private func prepareChartData() -> [ChartData] {
    //    var result = [ChartData]()
    //    for liftType in LiftType.allCases {
    //      let filtered = allLifts.filter { $0.liftType == liftType }
    //      let sorted = filtered.sorted(by: { $0.date < $1.date })
    //      for entry in sorted {
    //        result.append(ChartData(id: UUID(), liftType: liftType, date: entry.date, weight: entry.weight))
    //      }
    //    }
    //    return result
    //  }
    
    private func sortLiftEntriesByDate(_ lifts: [LiftEntry]) -> [LiftEntry] {
        lifts.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        let addedLiftTypes = [LiftType.bench, LiftType.backSquat, LiftType.deadlift]
        
        ZStack {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        let groupedLiftEntries = Dictionary(grouping: liftEntries, by: { $0.liftType })
                        ForEach(groupedLiftEntries.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { liftType in
                            if let specificLifts = groupedLiftEntries[liftType] {
                                NavigationLink(destination: LiftOverviewView(liftType: liftType)) {
                                    LiftTileView(liftType: liftType, specificLifts: specificLifts)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    if !liftEntries.isEmpty {
                        ForEach(liftEntries) { lift in
                            Text("\(lift.liftType.description): \(lift.weight) lbs on \(lift.date.formatted())")
                                .padding()
                        }
                    } else {
                        Text("No entries found")
                            .padding()
                    }
                }
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
                                    .foregroundColor(Color("Primary"))
                            }
                            .frame(width: 32, height: 32)
                            .background(Color(hex: "E6E1E3"))
                            .cornerRadius(20)
                        }
                    }
                }
            }
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    Divider()
                    Spacer()
                        .frame(height: 16)
                    VStack {
                        ButtonAddPR(addingPR: addingPR, needsRefresh: $needsRefresh)
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
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
            if newValue {
                fetchLiftEntries()
                needsRefresh = false
                print("fetched")
            }
        }
    }
    
    private func fetchLiftEntries() {
        CloudKitManager.shared.fetchLiftEntries { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self.liftEntries = entries
                case .failure(let error):
                    print("Error fetching entries: \(error)")
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack {
                Rectangle() // Custom switch background
                    .frame(width: 80, height: 32)
                    .foregroundColor(Color(hex: "e4e4e4"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .frame(width: 36, height: 24)
                            .foregroundColor(.white)
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
                        .foregroundColor(Color("Primary"))
                    
                    Text ("Kg")
                        .frame(width: 36, height: 24)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("Primary"))
                    
                }
                .padding(.horizontal, 4)
            }
            
        }
    }
}


struct ButtonAddPR: View {
    @State var addingPR: Bool
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
                .stroke(Color.white.opacity(0.25), lineWidth: 2)
            
        )
        .sheet(isPresented: $addingPR) {
            AddPRView(needsRefresh: $needsRefresh)
        }
    }
}

struct LiftTileView: View {
    let liftType: LiftType
    let specificLifts: [LiftEntry]
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(liftType.description)
                        .font(.system(size: 12))
                        .foregroundColor(Color("Secondary"))
                    Spacer()
                }
                HStack {
                    Text("225 lbs.")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("Primary"))
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(0)
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
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .inset(by: 0.25) // Adjust by half of the stroke line width
                .stroke(Color.black.opacity(0.15), lineWidth: 0.5)
        )
    }
}
